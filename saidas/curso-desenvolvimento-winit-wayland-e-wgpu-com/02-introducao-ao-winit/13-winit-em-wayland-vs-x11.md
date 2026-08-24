## Winit em Wayland vs X11

Quando você cria uma janela com Winit em Linux, o sistema escolhe automaticamente entre os backends Wayland e X11, mas os comportamentos diferem de maneiras críticas para aplicações gráficas. Veja o problema na prática:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    println!(
        "Backend em uso: {:?}", 
        window.current_monitor().unwrap().scale_factor()
    );

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
```

Execute em um sistema com ambos os protocolos instalados e você verá diferenças imediatas:

1. **Posicionamento Inicial**: No X11, a janela aparece exatamente onde você especificou com `with_position`. No Wayland, o compositor decide - seu código de posição é apenas uma sugestão.

2. **Escalamento de DPI**: 
```rust
window.set_outer_position(winit::dpi::LogicalPosition::new(100.0, 100.0));
println!("Posição lógica: {:?}", window.outer_position().unwrap());
println!("Posição física: {:?}", window.outer_position().unwrap().to_physical(window.scale_factor()));
```
Wayland reporta DPI por-monitor dinamicamente, enquanto X11 frequentemente usa um valor global.

3. **Decorations Personalizadas**:
```rust
let window = WindowBuilder::new()
    .with_decorations(false)
    .with_transparent(true)
    .build(&event_loop)
    .unwrap();
```
No X11, isso cria uma janela completamente sem bordas. No Wayland, alguns compositors (como GNOME) podem ignorar `with_decorations(false)` por políticas de segurança.

O erro mais comum é assumir comportamento consistente ao mover janelas:

```rust
// Isso falha silenciosamente no Wayland se o compositor rejeitar movimento
window.set_outer_position(winit::dpi::PhysicalPosition::new(0, 0));
```

A solução robusta verifica o backend atual:

```rust
use raw_window_handle::{HasRawWindowHandle, RawWindowHandle};

match window.raw_window_handle() {
    RawWindowHandle::Wayland(_) => {
        // Lógica específica para Wayland
    }
    RawWindowHandle::Xlib(_) | RawWindowHandle::Xcb(_) => {
        // Lógica X11
    }
    _ => unimplemented!(),
}
```

**Input Handling** difere radicalmente:

```rust
match event {
    Event::WindowEvent {
        event: WindowEvent::KeyboardInput { input, .. },
        ..
    } => {
        println!("{:?}", input.scancode);
    }
    _ => (),
}
```
No X11, `scancode` é consistente entre teclados. No Wayland, pode variar pelo driver.

**Exercício Prático**: Crie um programa que mostra:
1. O backend gráfico em uso
2. A lista de monitores e seus DPI
3. Trate corretamente o posicionamento em ambos os protocolos

Solução:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::{Window, WindowBuilder},
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    print_backend_info(&window);
    
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            Event::WindowEvent {
                event: WindowEvent::Resized(size),
                ..
            } => {
                println!("Janela redimensionada: {:?}", size);
            }
            _ => (),
        }
    });
}

fn print_backend_info(window: &Window) {
    println!("Backend: {:?}", window.raw_window_handle());
    
    window.available_monitors().for_each(|monitor| {
        println!(
            "Monitor: {} (DPI: {:.1})",
            monitor.name().unwrap_or("Unknown".into()),
            monitor.scale_factor()
        );
    });
}
```