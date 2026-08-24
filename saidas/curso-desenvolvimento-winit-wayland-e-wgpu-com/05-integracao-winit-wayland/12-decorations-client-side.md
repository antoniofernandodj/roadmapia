## Decorations Client-side

Quando você cria uma janela sem decorações do sistema (`with_decorations(false)`), perde os controles padrão de fechar, maximizar e redimensionar. A solução é implementar essas funcionalidades manualmente no lado do cliente. Veja como criar decorações minimalistas funcionais:

```rust
use winit::{
    event::{Event, WindowEvent, MouseButton},
    event_loop::{EventLoop, ControlFlow},
    window::{Window, WindowBuilder, CursorIcon},
    dpi::PhysicalPosition,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_decorations(false)
        .build(&event_loop)
        .unwrap();

    let mut dragging = false;
    let mut drag_start_position: PhysicalPosition<f64> = PhysicalPosition::new(0.0, 0.0);
    let mut window_size = window.inner_size();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::MouseInput { button, state, .. } => {
                    if button == MouseButton::Left {
                        dragging = state == winit::event::ElementState::Pressed;
                        window.set_cursor_icon(if dragging {
                            CursorIcon::Grabbing
                        } else {
                            CursorIcon::Default
                        });
                    }
                }
                WindowEvent::CursorMoved { position, .. } => {
                    if dragging {
                        let delta_x = position.x - drag_start_position.x;
                        let delta_y = position.y - drag_start_position.y;
                        let new_x = window.outer_position().unwrap().x as f64 + delta_x;
                        let new_y = window.outer_position().unwrap().y as f64 + delta_y;
                        window.set_outer_position(winit::dpi::PhysicalPosition::new(new_x, new_y));
                    }
                    drag_start_position = position;
                }
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            _ => (),
        }
    });
}
```

Este código implementa o arrastar da janela quando o usuário mantém o botão esquerdo pressionado. O cursor muda para `Grabbing` durante a operação, dando feedback visual.

Para adicionar controles de fechar e redimensionamento, precisamos detectar áreas específicas na janela:

```rust
enum DecorationZone {
    TitleBar,
    CloseButton,
    ResizeHandle,
    None,
}

fn detect_zone(position: PhysicalPosition<f64>, window_size: winit::dpi::PhysicalSize<u32>) -> DecorationZone {
    let (x, y) = (position.x, position.y);
    let (width, height) = (window_size.width as f64, window_size.height as f64);

    // Área do botão de fechar (canto superior direito)
    if x >= width - 30.0 && x <= width && y >= 0.0 && y <= 30.0 {
        DecorationZone::CloseButton
    } 
    // Área de redimensionamento (canto inferior direito)
    else if x >= width - 15.0 && y >= height - 15.0 {
        DecorationZone::ResizeHandle
    }
    // Barra de título (topo da janela)
    else if y <= 30.0 {
        DecorationZone::TitleBar
    } else {
        DecorationZone::None
    }
}
```

Integre esta detecção com os eventos de mouse:

```rust
WindowEvent::MouseInput { button, state, .. } => {
    if button == MouseButton::Left {
        let zone = detect_zone(drag_start_position, window_size);
        match zone {
            DecorationZone::TitleBar => {
                dragging = state == winit::event::ElementState::Pressed;
                window.set_cursor_icon(if dragging {
                    CursorIcon::Grabbing
                } else {
                    CursorIcon::Grab
                });
            }
            DecorationZone::CloseButton if state == winit::event::ElementState::Released => {
                *control_flow = ControlFlow::Exit;
            }
            _ => (),
        }
    }
}
```

Para o redimensionamento, adicione:

```rust
WindowEvent::CursorMoved { position, .. } => {
    let zone = detect_zone(position, window_size);
    match zone {
        DecorationZone::ResizeHandle => {
            window.set_cursor_icon(CursorIcon::NwseResize);
        }
        DecorationZone::TitleBar if !dragging => {
            window.set_cursor_icon(CursorIcon::Grab);
        }
        _ => {
            window.set_cursor_icon(CursorIcon::Default);
        }
    }

    if dragging {
        // Código de arrastar existente
    }
}
```

Erro comum: esquecer de converter entre coordenadas lógicas e físicas. Se você usar `position` diretamente sem considerar o DPI, os cálculos ficarão incorretos em monitores HiDPI:

```rust
// ERRADO - ignora o fator de escala
let logical_position = position.to_logical(window.scale_factor());
```

A implementação completa incluiria também:
1. Desenho das decorações usando WGPU ou software rendering
2. Tratamento de duplo clique na barra de título para maximizar
3. Animações suaves durante redimensionamento

Exercício: Implemente um botão de maximizar/restaurar que alterna entre os estados. Dica: use `window.set_maximized()` e armazene o tamanho anterior da janela.

Solução comentada:

```rust
let mut is_maximized = false;
let mut previous_size = window.inner_size();

// No tratamento de eventos:
DecorationZone::MaximizeButton if state == winit::event::ElementState::Released => {
    is_maximized = !is_maximized;
    if is_maximized {
        previous_size = window.inner_size();
        window.set_maximized(true);
    } else {
        window.set_maximized(false);
        window.set_inner_size(previous_size);
    }
}
```