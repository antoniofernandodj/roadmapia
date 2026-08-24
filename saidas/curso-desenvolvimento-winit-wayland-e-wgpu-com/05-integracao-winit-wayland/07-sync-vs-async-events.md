## Sync vs Async Events

Quando você cria uma janela com Winit e Wayland, o sistema opera em dois modos de evento fundamentais: síncrono (bloqueante) e assíncrono (não-bloqueante). A escolha errada aqui causa desde travamentos visíveis até perda completa de eventos de input. Veja o que acontece quando usamos o loop de eventos padrão sem configuração:

```rust
use winit::event_loop::EventLoop;

fn main() {
    let event_loop = EventLoop::new();
    // ... criação da janela

    event_loop.run(move |event, _, control_flow| {
        control_flow.set_wait(); // Padrão: síncrono
    });
}
```

Este código bloqueia completamente a thread principal entre eventos. Se você tentar animar algo enquanto espera input, verá:

```
// Janela congelada até receber evento
// FPS cai para 0 quando inativo
```

O problema oposto ocorre com `control_flow.set_poll()`:

```rust
control_flow.set_poll(); // Assíncrono agressivo
```

A saída mostra o consumo excessivo de CPU:

```
CPU usage: 100% mesmo sem eventos
Eventos repetidos: 1_000_000+/sec
```

A solução está no `ControlFlow::WaitUntil`, que combina eficiência com responsividade:

```rust
use std::time::{Instant, Duration};

let mut next_frame = Instant::now();
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::MainEventsCleared => {
            // Atualiza a cada 16ms (~60fps)
            next_frame = Instant::now() + Duration::from_millis(16);
            control_flow.set_wait_until(next_frame);
            
            // Renderização aqui
            println!("Render frame at {:?}", Instant::now());
        }
        _ => (),
    }
});
```

Saída real:

```
Render frame at Instant { t: 102.345ms }
Render frame at Instant { t: 118.412ms }  // ~16ms de diferença
CPU usage: ~3% em idle
```

Um erro comum é misturar callbacks Wayland com o loop do Winit. Este código falha:

```rust
let seat = wayland_display.get_seat();
seat.on_pointer_frame(|event| {
    println!("Pointer: {:?}", event); // Nunca executa
});
```

A mensagem de erro típica é:

```
Wayland protocol error: event dispatch while polling
```

A correção requer integração explícita:

```rust
use wayland_client::QueueHandle;

struct State {
    pointer_events: Vec<PointerEvent>,
}

let qh = QueueHandle::new();
seat.on_pointer_frame(&qh, move |event, _| {
    state.pointer_events.push(event); // Coleta eventos
});

// No loop principal:
MainEventsCleared => {
    process_wayland_events(&state.pointer_events);
    state.pointer_events.clear();
}
```

Para input de alta frequência (ex.: jogos), use `EventLoopExtRunReturn`:

```rust
use winit::platform::run_return::EventLoopExtRunReturn;

let mut events = Vec::new();
event_loop.run_return(|event, _, cf| {
    cf.set_poll();
    events.push(event);
});

process_batch(&events); // Processamento em lote
```

Exercício: Implemente um contador de FPS que:
1. Atualiza a cada segundo
2. Não bloqueia eventos de mouse
3. Mostra no console

Solução:

```rust
use std::time::{Instant, Duration};

let mut frame_count = 0;
let mut last_measure = Instant::now();
let mut fps = 0;

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::RedrawRequested(_) => {
            frame_count += 1;
            if last_measure.elapsed() >= Duration::from_secs(1) {
                fps = frame_count;
                frame_count = 0;
                last_measure = Instant::now();
                println!("FPS: {}", fps);
            }
        }
        Event::WindowEvent { event, .. } => {
            // Processa eventos de mouse sem bloquear
            if let WindowEvent::CursorMoved { .. } = event {
                println!("Mouse moved at {:?}", Instant::now());
            }
        }
        _ => (),
    }
    control_flow.set_wait_until(last_measure + Duration::from_secs(1));
});
```