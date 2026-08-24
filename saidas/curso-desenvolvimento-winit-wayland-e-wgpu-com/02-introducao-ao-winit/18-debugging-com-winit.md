## Debugging com Winit

Quando sua aplicação Winit não se comporta como esperado, o primeiro passo é entender o fluxo de eventos. Veja um exemplo comum onde eventos parecem não estar sendo processados:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event: WindowEvent::CloseRequested, .. } => {
                println!("Close requested!");
                *control_flow = ControlFlow::Exit;
            },
            _ => (),
        }
    });
}
```

Ao executar, você pode fechar a janela e notar que nada é impresso no console. Por quê? Por padrão, muitas plataformas não habilitam o stdout para aplicações gráficas.

**Solução:** Redirecione a saída para um arquivo:

```bash
cargo run > debug.log 2>&1
```

Agora verá a mensagem "Close requested!" no arquivo. Esse é o primeiro obstáculo ao debugar aplicações gráficas.

### Logging Estruturado

O `env_logger` é mais eficiente que println:

```rust
use log::{info, warn};

fn main() {
    env_logger::init();
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    info!("Window created, starting event loop");
    
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event: WindowEvent::CloseRequested, .. } => {
                warn!("Close requested!");
                *control_flow = ControlFlow::Exit;
            },
            _ => (),
        }
    });
}
```

Configure o nível de log via variável de ambiente:

```bash
RUST_LOG=warn cargo run
```

Saída típica:
```
WARN: Close requested!
```

### Inspecionando Eventos

Para entender todos os eventos recebidos:

```rust
event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Wait;
    println!("Event: {:?}", event);  // Debug print para todos os eventos
    // ...
});
```

Isso revelará eventos ocultos como:
```
Event: NewEvents(Init)
Event: WindowEvent { window_id: WindowId(X(WindowId(69206022))), event: Resized(PhysicalSize { width: 800, height: 600 }) }
Event: MainEventsCleared
```

### Erro Comum: Janela Congelada

Um erro frequente é a janela parar de responder:

```rust
event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Poll;  // Isso sobrecarrega a CPU
    // ...
});
```

**Sintoma:** 100% de uso da CPU e janela não responde a cliques.

**Solução correta:**

```rust
*control_flow = ControlFlow::Wait;  // Ou WaitUntil com timeout
```

### Debug de DPI

Problemas de escala são comuns em multi-monitor:

```rust
window.scale_factor();  // Retorna o fator atual (ex: 1.0, 2.0)

// Registrar mudanças:
match event {
    Event::WindowEvent { event: WindowEvent::ScaleFactorChanged { scale_factor, .. }, .. } => {
        println!("DPI changed: {}", scale_factor);
    },
    // ...
}
```

### Exercício Prático

**Problema:** Crie uma janela que registre:
1. Todos os eventos recebidos em um arquivo `events.log`
2. O tempo entre eventos `RedrawRequested`
3. As mudanças de tamanho físico vs lógico

**Solução comentada:**

```rust
use std::{fs::File, io::Write, time::Instant};
use winit::{event::Event, window::WindowEvent};

fn main() {
    let mut log_file = File::create("events.log").unwrap();
    let mut last_redraw = Instant::now();
    let event_loop = winit::event_loop::EventLoop::new();
    let window = winit::window::WindowBuilder::new().build(&event_loop).unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = winit::event_loop::ControlFlow::Wait;
        
        writeln!(log_file, "{:?}", event).unwrap();
        
        match event {
            Event::RedrawRequested(_) => {
                let now = Instant::now();
                writeln!(log_file, "Time since last redraw: {:?}", now - last_redraw).unwrap();
                last_redraw = now;
            }
            Event::WindowEvent { event: WindowEvent::Resized(size), .. } => {
                writeln!(
                    log_file,
                    "Resized - Physical: {:?}, Logical: {:?}",
                    size,
                    size.to_logical(window.scale_factor())
                ).unwrap();
            }
            _ => (),
        }
    });
}
```