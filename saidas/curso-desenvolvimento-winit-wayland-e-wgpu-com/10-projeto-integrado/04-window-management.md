## Window Management

Criar uma janela é apenas o primeiro passo. O verdadeiro desafio começa quando precisamos gerenciar seu ciclo de vida, responder a eventos de redimensionamento e coordenar sua superfície com a GPU. Veja o que acontece quando tentamos apenas criar uma janela básica:

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
                *control_flow = ControlFlow::Exit
            },
            _ => (),
        }
    });
}
```

Este código cria uma janela vazia que fecha ao clicar no "X", mas esconde vários problemas práticos:

1. **Vazamento de recursos**: A janela não é destruída corretamente em todas as plataformas
2. **DPI incorreto**: O tamanho lógico não corresponde às coordenadas físicas
3. **Redimensionamento**: A superfície gráfica não se adapta às mudanças de tamanho

Para um gerenciamento robusto, precisamos de uma estrutura que encapsule o estado da janela:

```rust
struct ManagedWindow {
    window: winit::window::Window,
    size: winit::dpi::PhysicalSize<u32>,
    scale_factor: f64,
    should_close: bool,
}

impl ManagedWindow {
    fn new(event_loop: &EventLoop<()>) -> Self {
        let window = WindowBuilder::new()
            .with_title("Editor Rust")
            .build(event_loop)
            .unwrap();
        
        let scale_factor = window.scale_factor();
        let size = window.inner_size();

        Self {
            window,
            size,
            scale_factor,
            should_close: false,
        }
    }

    fn handle_event(&mut self, event: &WindowEvent) {
        match event {
            WindowEvent::CloseRequested => self.should_close = true,
            WindowEvent::Resized(new_size) => {
                self.size = *new_size;
                println!("Janela redimensionada: {:?}", new_size);
            },
            WindowEvent::ScaleFactorChanged { scale_factor, new_inner_size } => {
                self.scale_factor = *scale_factor;
                self.size = *new_inner_size;
                println!("DPI alterado: {:.1}, novo tamanho: {:?}", scale_factor, new_inner_size);
            },
            _ => (),
        }
    }
}
```

Agora podemos integrar esta estrutura ao loop principal:

```rust
fn main() {
    let event_loop = EventLoop::new();
    let mut managed_window = ManagedWindow::new(&event_loop);

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, window_id } if window_id == managed_window.window.id() => {
                managed_window.handle_event(&event);
                
                if managed_window.should_close {
                    *control_flow = ControlFlow::Exit;
                }
            },
            Event::MainEventsCleared => {
                managed_window.window.request_redraw();
            },
            _ => (),
        }
    });
}
```

O erro mais comum ocorre ao não tratar o redimensionamento da superfície gráfica. Se você estiver usando WGPU, verá este erro ao tentar renderizar após redimensionar:

```
wgpu error: Validation Error: Surface must be configured before use
```

A solução é recriar a swap chain quando o tamanho muda:

```rust
struct RenderState {
    surface: wgpu::Surface,
    device: wgpu::Device,
    queue: wgpu::Queue,
    config: wgpu::SurfaceConfiguration,
    // ...
}

impl ManagedWindow {
    fn resize(&mut self, render_state: &mut RenderState) {
        render_state.config.width = self.size.width;
        render_state.config.height = self.size.height;
        render_state.surface.configure(&render_state.device, &render_state.config);
    }
}
```

Para Wayland especificamente, precisamos lidar com dois detalhes adicionais:

1. **Decorations client-side**: Remover as bordas padrão e implementar nosso próprio controle
2. **Protocolos estendidos**: Ativar recursos como redimensionamento interativo

```rust
use winit::platform::wayland::WindowBuilderExtWayland;

fn create_wayland_window(event_loop: &EventLoop<()>) -> winit::window::Window {
    WindowBuilder::new()
        .with_decorations(false) // Remove bordas padrão
        .with_wayland_decorate_mode(winit::platform::wayland::DecorationsMode::Client)
        .build(event_loop)
        .unwrap()
}
```

Um problema específico do Wayland ocorre ao tentar obter o tamanho da janela imediatamente após a criação:

```rust
let window = WindowBuilder::new().build(&event_loop).unwrap();
println!("Tamanho: {:?}", window.inner_size()); // Pode retornar (0, 0) no Wayland!
```

A solução é esperar pelo primeiro evento `RedrawRequested` antes de acessar as propriedades da janela.

**Exercício**: Implemente um window manager que suporte múltiplas janelas com renderização independente. Cada janela deve:
- Manter seu próprio estado de tamanho e DPI
- Fechar independentemente das outras
- Recriar sua swap chain quando redimensionada

```rust
// Solução base
struct WindowManager {
    windows: HashMap<winit::window::WindowId, (ManagedWindow, RenderState)>,
}

impl WindowManager {
    fn new_window(&mut self, event_loop: &EventLoop<()>) {
        let managed_window = ManagedWindow::new(event_loop);
        let render_state = create_render_state(&managed_window.window);
        self.windows.insert(managed_window.window.id(), (managed_window, render_state));
    }

    fn handle_event(&mut self, event: &Event<()>) {
        match event {
            Event::WindowEvent { event, window_id } => {
                if let Some((window, render_state)) = self.windows.get_mut(window_id) {
                    window.handle_event(event);
                    
                    if let WindowEvent::Resized(_) = event {
                        window.resize(render_state);
                    }
                }
            },
            _ => (),
        }
    }
}
```