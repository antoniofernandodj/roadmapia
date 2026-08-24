## Redimensionamento de Janelas

Quando o usuário arrasta a borda de uma janela, seu programa precisa reagir imediatamente - mas se você simplesmente redesenhar o conteúdo a cada pixel de movimento, a aplicação ficará lenta e instável. Veja como o Winit resolve isso com eventos otimizados:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    let mut last_size = window.inner_size();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::Resized(size),
                ..
            } => {
                println!("Janela redimensionada para: {}x{}", size.width, size.height);
                last_size = size;
            }
            Event::MainEventsCleared => {
                // Aqui você atualizaria buffers ou texturas baseado em last_size
                // Mas NÃO redesenharia a cada frame durante o redimensionamento!
            }
            _ => (),
        }
    });
}
```

Quando executado e redimensionado, a saída mostra:
```
Janela redimensionada para: 800x600
Janela redimensionada para: 801x600
Janela redimensionada para: 802x600
```

O problema? Isso gera centenas de eventos desnecessários. A solução é usar `WindowEvent::ScaleFactorChanged` junto com uma lógica de debounce:

```rust
use std::time::{Duration, Instant};

let mut last_resize = Instant::now();
const RESIZE_DEBOUNCE: Duration = Duration::from_millis(100);

// No match de eventos:
Event::WindowEvent {
    event: WindowEvent::Resized(size),
    ..
} if last_resize.elapsed() > RESIZE_DEBOUNCE => {
    println!("Redimensionamento confirmado: {}x{}", size.width, size.height);
    last_resize = Instant::now();
    // Atualize layouts/texturas aqui
}
```

### Tamanhos Lógicos vs Físicos

Quando trabalhamos com DPI variável, Winit oferece dois tipos de tamanho:

```rust
let physical_size = window.inner_size();
let logical_size = physical_size.to_logical(window.scale_factor());
println!(
    "Físico: {}x{} | Lógico: {}x{} (DPI: {})",
    physical_size.width,
    physical_size.height,
    logical_size.width,
    logical_size.height,
    window.scale_factor()
);
```

Saída em um monitor 4K (200% de escala):
```
Físico: 3840x2160 | Lógico: 1920x1080 (DPI: 2.0)
```

### Erro Comum e Correção

Um padrão problemático que veremos frequentemente:

```rust
let window_size = window.inner_size(); // Captura no início
event_loop.run(move |event, _, _| {
    match event {
        Event::RedrawRequested(_) => {
            renderer.draw(window_size); // ❌ Usa tamanho obsoleto!
        }
        _ => (),
    }
});
```

A correção usa um `Arc<Mutex<Size>>` compartilhado:

```rust
use std::sync::{Arc, Mutex};

let size = Arc::new(Mutex::new(window.inner_size()));
let size_clone = Arc::clone(&size);

event_loop.run(move |event, _, _| {
    if let Event::WindowEvent {
        event: WindowEvent::Resized(new_size),
        ..
    } = event
    {
        *size_clone.lock().unwrap() = new_size;
    }
});
```

### Exercício Prático

Implemente um redimensionamento que:
1. Mantém aspect ratio 16:9
2. Só aplica mudanças após 200ms sem eventos
3. Atualiza um contador de redimensionamentos

Solução comentada:

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

static RESIZE_COUNT: AtomicUsize = AtomicUsize::new(0);

// No handler de eventos:
WindowEvent::Resized(size) => {
    let new_width = size.width;
    let new_height = (new_width as f64 / 16.0 * 9.0) as u32;
    window.set_inner_size(PhysicalSize::new(new_width, new_height));
    
    RESIZE_COUNT.fetch_add(1, Ordering::Relaxed);
    println!("Redimensionamentos: {}", RESIZE_COUNT.load(Ordering::Relaxed));
}
```