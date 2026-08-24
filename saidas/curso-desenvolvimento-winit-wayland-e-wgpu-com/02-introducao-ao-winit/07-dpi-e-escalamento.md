## DPI e Escalamento

Um monitor 4K de 27" e um notebook Full HD de 13" têm densidades de pixels radicalmente diferentes. Se você desenhar um quadrado de 100×100 pixels em ambos, o tamanho físico na tela será drasticamente distinto. É aqui que o DPI (dots per inch) e o escalamento entram - para garantir que sua interface tenha proporções consistentes em qualquer dispositivo.

O Winit trabalha com dois sistemas de coordenadas:

1. **Logical Size**: Tamanhos independentes de DPI, em "pontos lógicos"
2. **Physical Size**: Pixels reais no dispositivo, considerando o escalamento

Veja como isso se manifesta na prática:

```rust
use winit::{
    dpi::{LogicalSize, PhysicalSize},
    window::WindowBuilder,
    event_loop::EventLoop,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("DPI Demo")
        .with_inner_size(LogicalSize::new(800.0, 600.0))
        .build(&event_loop)
        .unwrap();

    // Obtendo ambos os tamanhos após a criação
    let logical: LogicalSize<f64> = window.inner_size().to_logical(window.scale_factor());
    let physical: PhysicalSize<u32> = window.inner_size();

    println!(
        "Tamanho lógico: {}x{} (escala: {})",
        logical.width, logical.height, window.scale_factor()
    );
    println!(
        "Tamanho físico: {}x{}",
        physical.width, physical.height
    );
}
```

Executando em um MacBook Pro com escala de 2x, você verá:

```
Tamanho lógico: 800x600 (escala: 2)
Tamanho físico: 1600x1200
```

O erro mais comum é assumir que `window.inner_size()` retorna valores lógicos. Na verdade, ele sempre retorna o tamanho físico. Tentar usar esses valores diretamente para renderização sem considerar o `scale_factor` resultará em elementos de UI minúsculos em telas de alta densidade.

Para lidar corretamente com redimensionamentos, você deve monitorar dois eventos:

```rust
event_loop.run(move |event, _, control_flow| {
    *control_flow = winit::event_loop::ControlFlow::Wait;

    match event {
        winit::event::Event::WindowEvent {
            event: winit::event::WindowEvent::ScaleFactorChanged { scale_factor, new_inner_size },
            ..
        } => {
            println!("Escala alterada para: {}", scale_factor);
            handle_resize(*new_inner_size, *scale_factor);
        }
        winit::event::Event::WindowEvent {
            event: winit::event::WindowEvent::Resized(new_size),
            ..
        } => {
            let scale_factor = window.scale_factor();
            handle_resize(new_size, scale_factor);
        }
        _ => (),
    }
});

fn handle_resize(new_size: PhysicalSize<u32>, scale_factor: f64) {
    let logical_size = new_size.to_logical(scale_factor);
    println!("Novo tamanho - Físico: {:?}, Lógico: {:?}", new_size, logical_size);
}
```

A armadilha do DPI fica evidente quando você tenta posicionar elementos:

```rust
// ERRADO - Ignora o fator de escala
let pos_x = 100;
let pos_y = 100;

// CORRETO - Considera o DPI
let logical_pos = LogicalPosition::new(100.0, 100.0);
let physical_pos = logical_pos.to_physical(window.scale_factor());
```

Em sistemas com múltiplos monitores, a situação complica - cada tela pode ter seu próprio fator de escala. O Winit fornece:

```rust
if let Some(monitor) = window.current_monitor() {
    println!("Escala do monitor atual: {}", monitor.scale_factor());
}
```

Para renderização real com WGPU ou outros backends, você precisará converter entre os sistemas:

```rust
// Para criar uma textura do tamanho da janela
let physical_size = window.inner_size();
let surface_config = wgpu::SurfaceConfiguration {
    width: physical_size.width,
    height: physical_size.height,
    // ...
};

// Para posicionar elementos na UI
let logical_mouse_pos = LogicalPosition::new(mouse_x, mouse_y);
let physical_mouse_pos = logical_mouse_pos.to_physical(window.scale_factor());
```

**Exercício**: Crie uma janela que exiba continuamente (a) seu tamanho físico, (b) tamanho lógico, e (c) fator de escala, atualizando essas informações durante redimensionamentos e mudanças de DPI (como arrastar a janela entre monitores com escalas diferentes).

**Solução comentada**:

```rust
use winit::{
    dpi::{LogicalSize, PhysicalSize},
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

struct State {
    physical_size: PhysicalSize<u32>,
    scale_factor: f64,
}

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("DPI Monitor")
        .with_inner_size(LogicalSize::new(400.0, 300.0))
        .build(&event_loop)
        .unwrap();

    let mut state = State {
        physical_size: window.inner_size(),
        scale_factor: window.scale_factor(),
    };

    update_title(&window, &state);

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::ScaleFactorChanged { scale_factor, new_inner_size },
                ..
            } => {
                state.scale_factor = scale_factor;
                state.physical_size = *new_inner_size;
                update_title(&window, &state);
            }
            Event::WindowEvent {
                event: WindowEvent::Resized(new_size),
                ..
            } => {
                state.physical_size = new_size;
                update_title(&window, &state);
            }
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}

fn update_title(window: &winit::window::Window, state: &State) {
    let logical_size = state.physical_size.to_logical(state.scale_factor);
    window.set_title(&format!(
        "Físico: {}x{} | Lógico: {:.1}x{:.1} | Escala: {}",
        state.physical_size.width,
        state.physical_size.height,
        logical_size.width,
        logical_size.height,
        state.scale_factor
    ));
}
```