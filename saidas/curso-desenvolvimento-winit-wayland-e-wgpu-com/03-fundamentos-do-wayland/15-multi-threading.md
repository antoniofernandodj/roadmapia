## Multi-threading

Em aplicações gráficas modernas, a capacidade de processar eventos de entrada enquanto renderiza frames é essencial para uma experiência responsiva. O protocolo Wayland foi projetado para operar em um único thread por padrão, mas isso não significa que sua aplicação deva ficar limitada a isso.

O principal desafio ao usar múltiplos threads com Wayland surge da natureza do protocolo: a conexão (`wl_display`) não é thread-safe por padrão. Tentar enviar requests ou processar eventos de threads diferentes sem sincronização resulta em erros:

```rust
// ERRO COMUM: Acesso concorrente à conexão Wayland
let display = wayland_client::Display::connect_to_env().unwrap();
let registry = display.get_registry();

std::thread::spawn(move || {
    // ⚠️ PANIC: `Wayland connection is not thread-safe`
    registry.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();
});
```

A mensagem de erro é clara: `Wayland connection is not thread-safe`. Para resolver isso, temos três abordagens principais:

1. **Thread dedicada para Wayland**: Criamos um thread exclusivo para toda comunicação Wayland e usamos canais para coordenar com outros threads:

```rust
use std::sync::mpsc;

let (sender, receiver) = mpsc::channel();

let wayland_thread = std::thread::spawn(move || {
    let display = wayland_client::Display::connect_to_env().unwrap();
    let registry = display.get_registry();
    
    // Processa eventos Wayland neste thread
    while let Ok(event) = receiver.recv() {
        match event {
            // Trata eventos da aplicação
        }
    }
});

// Outros threads enviam comandos para o thread Wayland
sender.send(Event::RedrawRequest).unwrap();
```

2. **Event Loop integrado**: Usamos o event loop do Winit que já é multi-thread friendly:

```rust
use winit::event_loop::EventLoopProxy;

let event_loop = EventLoop::new();
let proxy = event_loop.create_proxy();

std::thread::spawn(move || {
    // Trabalho pesado em outro thread
    proxy.send_event(Event::CalculationDone(result)).unwrap();
});
```

3. **Wrapper thread-safe**: Para casos avançados, podemos criar um wrapper que sincroniza o acesso:

```rust
use std::sync::{Arc, Mutex};

struct ThreadSafeDisplay {
    inner: Arc<Mutex<wayland_client::Display>>,
}

impl ThreadSafeDisplay {
    fn sync_roundtrip(&self) -> Result<(), wayland_client::ConnectError> {
        let guard = self.inner.lock().unwrap();
        guard.sync_roundtrip(&mut (), |_, _, _| {})
    }
}
```

Um padrão comum em aplicações gráficas é o **thread de renderização separado**. Veja como implementar isso com segurança:

```rust
let (render_sender, render_receiver) = mpsc::channel();
let display = wayland_client::Display::connect_to_env().unwrap();

// Thread de renderização
std::thread::spawn({
    let display = display.clone();
    move || {
        while let Ok(cmd) = render_receiver.recv() {
            // Gera frame
            let frame = render_frame(cmd);
            
            // Envia para o thread principal via callback
            display.dispatch(|| {
                update_surface_with_frame(frame);
            }).unwrap();
        }
    }
});

// Thread principal continua processando eventos Wayland
loop {
    display.dispatch(&mut (), |_, _, _| {}).unwrap();
}
```

**Armadilhas comuns**:
- Deadlocks ao misturar locks de diferentes objetos Wayland
- Race conditions ao atualizar estado compartilhado entre threads
- Starvation do thread principal por cálculos longos em threads secundários

**Exercício**: Implemente um contador de FPS que atualiza a cada segundo em um thread separado, enquanto o thread principal continua responsivo a eventos de entrada. Use um `Arc<Mutex<u32>>` para compartilhar o contador e um canal para notificar atualizações.

**Solução**:

```rust
use std::sync::{Arc, Mutex};
use std::time::Duration;

let fps_counter = Arc::new(Mutex::new(0u32));
let display = wayland_client::Display::connect_to_env().unwrap();
let proxy = display.create_proxy();

// Thread de contagem
let counter = fps_counter.clone();
std::thread::spawn(move || {
    let mut frame_count = 0;
    loop {
        std::thread::sleep(Duration::from_secs(1));
        *counter.lock().unwrap() = frame_count;
        frame_count = 0;
        proxy.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();
    }
});

// No loop principal
loop {
    display.dispatch(&mut (), |_, _, _| {}).unwrap();
    *fps_counter.lock().unwrap() += 1;
}
```