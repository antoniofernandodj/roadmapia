## Surfaces Personalizadas

Quando você remove as decorações padrão de uma janela com `window.with_decorations(false)`, surge um problema prático: como implementar comportamentos de janela personalizados como redimensionamento pelo canto ou arrastar pela barra de título? O Wayland oferece controle fino sobre surfaces através da interface `wl_surface`, mas a integração com Winit requer entendimento de três conceitos:

1. **Role**: Define o tipo de surface (janela normal, diálogo, etc.)
2. **States**: Propriedades como maximizado, fullscreen
3. **Regions**: Áreas interativas para redimensionamento

Vamos criar uma janela minimalista com redimensionamento customizado. Primeiro, o código básico:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_decorations(false)
        .with_title("Surface Custom")
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            _ => (),
        }
    });
}
```

Se executarmos este código, teremos uma janela sem bordas que não pode ser movida ou redimensionada - completamente estática. Para adicionar interatividade, precisamos acessar o protocolo Wayland subjacente:

```rust
use wayland_client::{protocol::wl_surface, Proxy};

let wayland_surface = window.wayland_surface().unwrap();
let xdg_surface = window.xdg_surface().unwrap();
```

O erro comum aqui é tentar usar estas superfícies diretamente sem configurar os estados adequados. Se você tentar definir uma região de redimensionamento sem primeiro configurar a role, receberá:

```
error: XDG Surface not configured (must call get_toplevel/popup/etc)
```

A solução é configurar a role corretamente antes de qualquer customização:

```rust
let toplevel = xdg_surface.get_toplevel(); // Configura como janela normal
```

Agora podemos implementar o redimensionamento. No Wayland, isso é feito definindo regiões ativas usando `xdg_toplevel.set_resize_edges()`. Vamos adicionar uma área de 10px em cada borda:

```rust
use wayland_client::protocol::xdg_toplevel::ResizeEdge;

toplevel.set_resize_edges(
    ResizeEdge::Top | 
    ResizeEdge::Bottom | 
    ResizeEdge::Left | 
    ResizeEdge::Right |
    ResizeEdge::TopLeft |
    ResizeEdge::TopRight |
    ResizeEdge::BottomLeft |
    ResizeEdge::BottomRight
);
```

Para arrastar a janela, precisamos interceptar eventos de mouse. O padrão é usar a barra de título, mas em nossa UI custom, podemos definir qualquer área:

```rust
WindowEvent::MouseInput { state, button, .. } => {
    if button == MouseButton::Left && state == ElementState::Pressed {
        toplevel.move_(seat, serial); // serial precisa ser do evento
    }
}
```

Um erro frequente é esquecer de manter o estado do mouse:

```
warning: move started but no matching end event
```

A implementação correta requer rastrear o estado:

```rust
let mut drag_active = false;

match event {
    WindowEvent::MouseInput { state, button, .. } => {
        if button == MouseButton::Left {
            drag_active = state == ElementState::Pressed;
            if drag_active {
                toplevel.move_(seat, serial);
            }
        }
    }
    WindowEvent::CursorLeft { .. } => {
        drag_active = false;
    }
    _ => {}
}
```

Para feedback visual, podemos mudar o cursor quando estiver sobre a área de redimensionamento:

```rust
use winit::window::CursorIcon;

window.set_cursor_icon(CursorIcon::NwseResize);
```

O exemplo completo combina tudo isso em uma janela totalmente customizável:

```rust
let window = WindowBuilder::new()
    .with_decorations(false)
    .with_inner_size(LogicalSize::new(400, 300))
    .build(&event_loop)?;

let toplevel = window.xdg_surface()?.get_toplevel();
toplevel.set_title("My Custom Window");
toplevel.set_resize_edges(ResizeEdge::all());
```

**Saída esperada**: Uma janela sem decorações padrão que pode ser redimensionada pelas bordas e arrastada por qualquer área, com cursores que indicam as operações disponíveis.

**Exercício**: Implemente uma janela com três áreas distintas:
1. Topo (20px) - arrastar
2. Cantos inferiores (15px) - redimensionar
3. Centro - clica exibe coordenadas

**Solução**:

```rust
match event {
    WindowEvent::CursorMoved { position, .. } => {
        let inner_size = window.inner_size();
        let (x, y) = (position.x, position.y);

        if y <= 20.0 {
            window.set_cursor_icon(CursorIcon::Grabbing);
        } else if (x <= 15.0 && y >= inner_size.height - 15.0) || 
                  (x >= inner_size.width - 15.0 && y >= inner_size.height - 15.0) {
            window.set_cursor_icon(CursorIcon::NwseResize);
        } else {
            window.set_cursor_icon(CursorIcon::Default);
        }
    }
    WindowEvent::MouseInput { button, state, .. } => {
        if button == MouseButton::Left && state == ElementState::Pressed {
            if y <= 20.0 {
                // Iniciar arrasto
            } else if /* verificar cantos */ {
                // Iniciar redimensionamento
            } else {
                println!("Clicked at: {}, {}", x, y);
            }
        }
    }
}
```