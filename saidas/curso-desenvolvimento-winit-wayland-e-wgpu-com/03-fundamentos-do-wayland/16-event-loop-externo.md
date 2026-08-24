## Event Loop Externo

Aplicações gráficas modernas precisam responder a eventos de várias fontes: entrada do usuário, atualizações de janela, temporizadores e operações assíncronas. O Wayland, por padrão, oferece seu próprio event loop via `Display::dispatch()`, mas em muitos casos precisamos integrá-lo com outros sistemas de eventos, como o do Winit ou um loop personalizado.

### O Problema do Loop Bloqueante

O método ingênuo de usar o event loop do Wayland bloqueia a thread quando não há eventos:

```rust
let display = wayland_client::Display::connect_to_env()?;
loop {
    display.dispatch().expect("Falha ao despachar eventos");
}
```

Isso torna impossível processar eventos de outras fontes simultaneamente. Se tentarmos adicionar um timeout:

```rust
loop {
    if display.prepare_read().is_ok() {
        display.read_events().ok();
    }
    display.dispatch_pending().expect("Falha ao despachar pendentes");
    // Como adicionar nosso timeout aqui?
}
```

O código acima ainda não resolve - precisamos de uma maneira de monitorar múltiplas fontes de eventos simultaneamente.

### Integrando com Poll

A solução está no mecanismo de polling do sistema operacional. No Linux, podemos usar `epoll` (ou `poll` para portabilidade) para monitorar o socket do Wayland junto com outros descritores:

```rust
use std::os::unix::io::AsRawFd;

let display = wayland_client::Display::connect_to_env()?;
let fd = display.as_raw_fd();

let mut epoll = epoll::create()?;
epoll::ctl(
    epoll,
    epoll::ControlOptions::EPOLL_CTL_ADD,
    fd,
    epoll::Event::new(epoll::Events::EPOLLIN, 0),
)?;

let mut events = [epoll::Event::new(epoll::Events::empty(), 0); 10];
loop {
    let timeout = -1; // Bloqueia indefinidamente
    let num_events = epoll::wait(epoll, timeout, &mut events)?;
    
    for event in &events[..num_events] {
        if event.data == 0 { // Evento do Wayland
            if display.prepare_read().is_ok() {
                display.read_events().ok();
            }
            display.dispatch_pending().expect("Falha ao despachar");
        }
        // Outros eventos podem ser tratados aqui
    }
}
```

Este padrão permite que o loop principal espere por eventos do Wayland e de outras fontes simultaneamente.

### Integração com Winit

Para integrar com o event loop do Winit, precisamos acessar o socket subjacente e registrá-lo no loop do Winit:

```rust
use winit::event_loop::EventLoopProxy;
use wayland_client::{Display, EventQueue};

struct WaylandEventSource {
    display: Display,
    queue: EventQueue,
    proxy: EventLoopProxy<()>,
}

impl WaylandEventSource {
    fn new(display: Display, proxy: EventLoopProxy<()>) -> Self {
        let queue = display.create_event_queue();
        Self { display, queue, proxy }
    }

    fn register(&self, event_loop: &winit::event_loop::EventLoop<()>) {
        let fd = self.queue.as_raw_fd();
        // Implementação específica da plataforma para registrar o fd
        // no event loop do Winit
    }
}
```

O Winit expõe APIs específicas de plataforma para isso. No Linux com X11 ou Wayland nativo:

```rust
#[cfg(target_os = "linux")]
fn register_wayland_fd(event_loop: &winit::event_loop::EventLoop<()>, fd: std::os::unix::io::RawFd) {
    use winit::platform::unix::EventLoopExtUnix;
    event_loop.register_fd(fd, move |_, _| {
        // Tratar eventos Wayland aqui
    });
}
```

### Padrão de Callback Assíncrono

Para aplicações que usam async/await, podemos integrar o Wayland com um executor como tokio:

```rust
use tokio::io::unix::AsyncFd;

async fn wayland_event_loop(display: Display) {
    let async_fd = AsyncFd::new(display.as_raw_fd()).unwrap();
    
    loop {
        async_fd.readable().await.unwrap();
        if display.prepare_read().is_ok() {
            display.read_events().ok();
        }
        display.dispatch_pending().expect("Falha ao despachar");
    }
}
```

### Erro Comum: Starvation de Eventos

Um erro frequente é não processar todos os eventos pendentes em cada iteração:

```rust
// ERRADO - pode perder eventos se houver muitos
display.dispatch_pending().expect("Falha ao despachar");

// CORRETO - processa todos os eventos pendentes
while display.dispatch_pending().expect("Falha ao despachar") > 0 {}
```

### Exercício Prático

Implemente um loop de eventos que combina:
1. Eventos Wayland (via socket)
2. Eventos de teclado stdin (via poll)
3. Um temporizador periódico (via timerfd)

Mostre como esses três tipos de eventos podem ser processados em um único loop.

**Solução:**

```rust
use std::os::unix::io::AsRawFd;
use nix::sys::timerfd::{TimerFd, TimerFlags, TimerSetTimeFlags, Expiration};
use nix::sys::time::TimeSpec;
use std::time::Duration;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Configura Wayland
    let display = wayland_client::Display::connect_to_env()?;
    let wayland_fd = display.as_raw_fd();
    
    // Configura stdin para entrada não bloqueante
    let stdin_fd = 0; // STDIN_FILENO
    
    // Configura timer
    let timer = TimerFd::new(TimerFlags::empty())?;
    timer.set(
        Expiration::Interval(TimeSpec::from_duration(Duration::from_secs(1))),
        TimerSetTimeFlags::empty(),
    )?;
    let timer_fd = timer.as_raw_fd();
    
    // Configura epoll
    let epoll_fd = epoll::create()?;
    for &(fd, id) in &[(wayland_fd, 1), (stdin_fd, 2), (timer_fd, 3)] {
        epoll::ctl(
            epoll_fd,
            epoll::ControlOptions::EPOLL_CTL_ADD,
            fd,
            epoll::Event::new(epoll::Events::EPOLLIN, id),
        )?;
    }
    
    let mut events = [epoll::Event::new(epoll::Events::empty(), 0); 10];
    loop {
        epoll::wait(epoll_fd, -1, &mut events)?;
        
        for event in &events {
            match event.data {
                1 => { // Wayland
                    if display.prepare_read().is_ok() {
                        display.read_events().ok();
                    }
                    while display.dispatch_pending()? > 0 {}
                }
                2 => { // STDIN
                    let mut input = String::new();
                    std::io::stdin().read_line(&mut input)?;
                    println!("Input: {}", input.trim());
                }
                3 => { // Timer
                    timer.wait()?;
                    println!("Timer tick");
                }
                _ => unreachable!(),
            }
        }
    }
}
```

Este exemplo demonstra como integrar três fontes de eventos diferentes em um único loop eficiente, processando cada tipo de evento conforme eles chegam sem bloquear indevidamente as outras fontes.