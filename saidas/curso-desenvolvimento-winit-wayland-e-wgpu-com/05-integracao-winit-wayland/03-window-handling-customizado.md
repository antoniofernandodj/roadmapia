## Window Handling Customizado

Quando você cria uma janela com Winit no Wayland, o compositor normalmente fornece decorações padrão (bordas, botões de minimizar/fechar). Mas para aplicações como players de vídeo, dashboards ou ferramentas criativas, você quer controle total sobre a área visível da janela.

O protocolo Wayland oferece o `xdg_toplevel` para controlar essas características. Veja como desativar as decorações do servidor e assumir o controle:

```rust
use winit::{
    event_loop::EventLoop,
    window::WindowBuilder,
    platform::wayland::WindowBuilderExtWayland as _,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_decorations(false)  // Remove decorações do servidor
        .with_transparent(true)   // Permite áreas transparentes
        .with_resizable(false)    // Controle manual do redimensionamento
        .build(&event_loop)
        .unwrap();
}
```

Se você tentar apenas `with_decorations(false)` sem implementar o redimensionamento client-side, pode encontrar este erro:

```
Wayland protocol error: xdg_toplevel error: resize not implemented"
```

Vamos implementar um redimensionamento básico via arrasto das bordas. Primeiro, precisamos estender nosso `WindowBuilder`:

```rust
use winit::{
    dpi::PhysicalSize,
    platform::wayland::EventLoopWindowTargetExtWayland,
};

let window = WindowBuilder::new()
    .with_decorations(false)
    .with_min_inner_size(PhysicalSize::new(400, 300))
    .build(&event_loop)
    .unwrap();

let surface = event_loop.wayland_surface().unwrap();
let toplevel = surface.xdg_surface().get_toplevel();
toplevel.set_title("Janela Customizada");
```

Para manipulação de eventos de redimensionamento, precisamos interceptar os eventos de input:

```rust
use winit::event::{Event, WindowEvent};

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event, .. } => match event {
            WindowEvent::CursorMoved { position, .. } if is_resizing => {
                let new_size = PhysicalSize::new(position.x as u32, position.y as u32);
                window.set_inner_size(new_size);
            }
            _ => (),
        },
        _ => (),
    }
});
```

Um exemplo completo com arrasto para mover a janela:

```rust
use winit::{
    event::{Event, WindowEvent, ElementState},
    dpi::PhysicalPosition,
};

let mut is_dragging = false;
let mut drag_start = PhysicalPosition::new(0.0, 0.0);

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event, window_id } if window_id == window.id() => {
            match event {
                WindowEvent::MouseInput { state, button, .. } => {
                    if button == MouseButton::Left {
                        is_dragging = state == ElementState::Pressed;
                        drag_start = window.inner_position().unwrap();
                    }
                }
                WindowEvent::CursorMoved { position, .. } if is_dragging => {
                    let delta_x = position.x - drag_start.x as f64;
                    let delta_y = position.y - drag_start.y as f64;
                    window.set_outer_position(PhysicalPosition::new(
                        drag_start.x + delta_x as i32,
                        drag_start.y + delta_y as i32,
                    ));
                }
                _ => (),
            }
        }
        _ => (),
    }
});
```

**Exercício:** Implemente um redimensionamento pelo canto inferior direito. Dica: você precisará:
1. Identificar quando o cursor está na área de redimensionamento
2. Armazenar o tamanho inicial quando o clique começar
3. Calcular o novo tamanho baseado no movimento do mouse

**Solução:**

```rust
let mut is_resizing = false;
let mut initial_size = PhysicalSize::new(0, 0);

match event {
    WindowEvent::CursorMoved { position, .. } => {
        let window_size = window.inner_size();
        let resize_margin = 15;
        let in_resize_area = position.x > (window_size.width as f64 - resize_margin) &&
                            position.y > (window_size.height as f64 - resize_margin);
        
        window.set_cursor_icon(if in_resize_area {
            CursorIcon::NwSeResize
        } else {
            CursorIcon::Default
        });
    }
    WindowEvent::MouseInput { state, button, .. } => {
        if button == MouseButton::Left {
            is_resizing = state == ElementState::Pressed && in_resize_area;
            initial_size = window.inner_size();
        }
    }
    WindowEvent::CursorMoved { position, .. } if is_resizing => {
        let new_width = initial_size.width.max(position.x as u32);
        let new_height = initial_size.height.max(position.y as u32);
        window.set_inner_size(PhysicalSize::new(new_width, new_height));
    }
    _ => (),
}
```