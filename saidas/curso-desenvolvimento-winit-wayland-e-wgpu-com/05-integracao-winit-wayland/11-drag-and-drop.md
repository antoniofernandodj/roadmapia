## Drag and Drop

Implementar drag and drop em aplicações gráficas modernas requer integração direta com o protocolo de exibição. No contexto Wayland, isso significa lidar com três componentes principais: a origem do drag (fonte), o destino (alvo) e o compositor que coordena a operação.

Vamos começar com um exemplo mínimo que permite arrastar texto de uma área para outra dentro da mesma janela. O código abaixo cria duas regiões retangulares e implementa a lógica básica de drag:

```rust
use winit::{
    event::{Event, WindowEvent, ElementState, MouseButton},
    event_loop::{EventLoop, ControlFlow},
    window::WindowBuilder,
};
use winit::dpi::PhysicalPosition;

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    // Estado do drag
    let mut drag_state = DragState {
        active: false,
        start_pos: PhysicalPosition::default(),
        current_content: None,
    };

    // Áreas de origem e destino
    let source_rect = Rect::new(50.0, 50.0, 200.0, 100.0);
    let target_rect = Rect::new(300.0, 50.0, 200.0, 100.0);

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::MouseInput { state, button, .. } => {
                    if button == MouseButton::Left {
                        drag_state.active = state == ElementState::Pressed;
                        if drag_state.active {
                            drag_state.start_pos = window.cursor_position().unwrap();
                            drag_state.current_content = Some("Texto arrastável".to_string());
                        } else {
                            // Lógica de soltar
                            if let Some(content) = &drag_state.current_content {
                                if target_rect.contains(drag_state.start_pos) {
                                    println!("Drop realizado: {}", content);
                                }
                            }
                            drag_state.current_content = None;
                        }
                    }
                }
                WindowEvent::CursorMoved { position, .. } => {
                    if drag_state.active {
                        println!("Arrastando para: {:?}", position);
                    }
                }
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            _ => (),
        }
    });
}

struct DragState {
    active: bool,
    start_pos: PhysicalPosition<f64>,
    current_content: Option<String>,
}

struct Rect {
    x: f64,
    y: f64,
    width: f64,
    height: f64,
}

impl Rect {
    fn new(x: f64, y: f64, width: f64, height: f64) -> Self {
        Self { x, y, width, height }
    }

    fn contains(&self, point: PhysicalPosition<f64>) -> bool {
        point.x >= self.x && point.x <= self.x + self.width &&
        point.y >= self.y && point.y <= self.y + self.height
    }
}
```

A saída durante a operação de drag mostra:
```
Arrastando para: PhysicalPosition { x: 120.0, y: 80.0 }
Arrastando para: PhysicalPosition { x: 150.0, y: 90.0 }
Drop realizado: Texto arrastável
```

### Integração com Wayland

Para operações entre janelas diferentes, precisamos ativar o protocolo `wl_data_device_manager` no Wayland. O Winit expõe essa funcionalidade através da extensão `WindowExtWayland`:

```rust
use winit::platform::wayland::WindowExtWayland;

let wayland_window = window.wayland_surface().unwrap();
let data_device = wayland_window.data_device_manager().unwrap()
    .get_data_device(&wayland_window.seat());
```

Um erro comum é esquecer de verificar se o protocolo está disponível:
```
Error: Protocol "wl_data_device_manager" not found
```

A correção envolve verificar explicitamente a presença do protocolo antes de usá-lo:

```rust
let data_device_manager = match wayland_window.data_device_manager() {
    Some(manager) => manager,
    None => {
        eprintln!("Drag and drop não suportado neste compositor");
        return;
    }
};
```

### Exercício Prático

Implemente um drag and drop que:
1. Mostre visualmente o conteúdo sendo arrastado
2. Aceite apenas arquivos de imagem (MIME type `image/*`)
3. Valide o drop somente se ocorrer na metade direita da janela

Solução comentada:

```rust
// Adicione ao estado do drag
struct DragState {
    // ... campos anteriores
    drag_visual: Option<Rectangle>, // Retângulo semitransparente
    accepted_types: Vec<String>,    // MIME types aceitos
}

// No tratamento do cursor movido
if drag_state.active {
    if let Some(rect) = &mut drag_state.drag_visual {
        rect.x = position.x - 25.0; // Centraliza visual
        rect.y = position.y - 25.0;
    }
}

// Na lógica de drop
if position.x > window.inner_size().width as f64 / 2.0 {
    if drag_state.accepted_types.iter().any(|t| t.starts_with("image/")) {
        println!("Arquivo de imagem aceito");
    }
}
```