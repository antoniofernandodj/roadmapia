## Integração com Winit

Você tem uma janela Winit criada e agora precisa conectá-la à WGPU para começar a renderização. O problema central é que a janela (Winit) e o backend gráfico (WGPU) falam linguagens diferentes - uma lida com eventos do sistema, a outra com comandos GPU. Vejamos como uni-los.

Primeiro, precisamos criar uma superfície que represente a janela na WGPU. Esta superfície será nosso alvo de renderização:

```rust
use winit::window::Window;
use wgpu::{Instance, Surface};

fn create_surface(instance: &Instance, window: &Window) -> Surface {
    // SAFETY: A janela deve ser válida e não ser destruída antes da surface
    unsafe { instance.create_surface(window) }.unwrap()
}
```

O método `create_surface` é marcado como `unsafe` porque requer que a janela permaneça válida enquanto a surface existir. Se você tentar destruir a janela primeiro, receberá um erro do tipo:

```
thread 'main' panicked at 'Surface is no longer valid: SurfaceLost'
```

A solução é garantir que a janela tenha um tempo de vida igual ou maior que a surface. Em aplicações reais, isso significa armazenar ambos na mesma estrutura:

```rust
struct GraphicsContext {
    window: Window,
    surface: Surface,
    // ... outros campos WGPU
}
```

Agora vamos configurar a swap chain, que gerencia os buffers de renderização para evitar flickering. O tamanho inicial deve corresponder ao tamanho da janela:

```rust
use wgpu::{SurfaceConfiguration, TextureFormat, PresentMode};

fn configure_surface(
    surface: &Surface,
    device: &Device,
    width: u32,
    height: u32,
) -> SurfaceConfiguration {
    let config = SurfaceConfiguration {
        usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
        format: surface.get_supported_formats(&adapter)[0],
        width,
        height,
        present_mode: PresentMode::Fifo, // VSync padrão
        alpha_mode: CompositeAlphaMode::Auto,
    };
    surface.configure(device, &config);
    config
}
```

Um erro comum é esquecer de reconfigurar a surface quando a janela é redimensionada. Se você fizer isso, verá mensagens como:

```
Texture width (800) does not match configured width (1024)
```

A solução é capturar o evento de redimensionamento e atualizar a configuração:

```rust
match event {
    WindowEvent::Resized(new_size) => {
        if new_size.width > 0 && new_size.height > 0 {
            config.width = new_size.width;
            config.height = new_size.height;
            surface.configure(&device, &config);
        }
    }
    // ... outros eventos
}
```

Com a surface configurada, podemos começar a renderizar. O fluxo básico é:

1. Obter um frame da swap chain
2. Criar um encoder de comandos
3. Iniciar um render pass
4. Executar comandos de desenho
5. Finalizar e submeter

Veja como fica na prática:

```rust
let output = surface.get_current_texture()?;
let view = output.texture.create_view(&wgpu::TextureViewDescriptor::default());

let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Render Encoder"),
});

{
    let _render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        label: Some("Render Pass"),
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::GREEN),
                store: true,
            },
        })],
        depth_stencil_attachment: None,
    });
}

let queue = device.create_queue();
queue.submit(std::iter::once(encoder.finish()));
output.present();
```

Se você esquecer de chamar `present()`, nada será exibido na tela. Se esquecer de `submit()`, receberá um erro como:

```
Texture is locked: Texture is used in a submit before being presented
```

Para fechar, vamos ver um exemplo completo que integra Winit e WGPU:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

async fn run() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();
    
    let instance = wgpu::Instance::new(wgpu::InstanceDescriptor::default());
    let surface = unsafe { instance.create_surface(&window) }.unwrap();
    
    let adapter = instance
        .request_adapter(&wgpu::RequestAdapterOptions {
            power_preference: wgpu::PowerPreference::default(),
            compatible_surface: Some(&surface),
            force_fallback_adapter: false,
        })
        .await
        .unwrap();
    
    let (device, queue) = adapter
        .request_device(
            &wgpu::DeviceDescriptor::default(),
            None,
        )
        .await
        .unwrap();
    
    let mut config = surface
        .get_default_config(&adapter, window.inner_size().width, window.inner_size().height)
        .unwrap();
    surface.configure(&device, &config);
    
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;
        
        match event {
            Event::RedrawRequested(_) => {
                let output = surface.get_current_texture().unwrap();
                let view = output.texture.create_view(&wgpu::TextureViewDescriptor::default());
                
                let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
                    label: Some("Render Encoder"),
                });
                
                {
                    let _render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                        label: Some("Render Pass"),
                        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                            view: &view,
                            resolve_target: None,
                            ops: wgpu::Operations {
                                load: wgpu::LoadOp::Clear(wgpu::Color::GREEN),
                                store: true,
                            },
                        })],
                        depth_stencil_attachment: None,
                    });
                }
                
                queue.submit(std::iter::once(encoder.finish()));
                output.present();
            }
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => {}
        }
    });
}
```

Exercício: Modifique o exemplo para alternar entre cores de limpeza (clear) quando o usuário clica na janela. A solução requer capturar o evento `MouseInput` do Winit e atualizar a cor no render pass.

Solução comentada:

```rust
// Adicione ao topo
use winit::event::MouseButton;

// Adicione à estrutura de estado
struct State {
    clear_color: wgpu::Color,
    // ... outros campos
}

// No tratamento de eventos
Event::WindowEvent {
    event: WindowEvent::MouseInput {
        button: MouseButton::Left,
        state: ElementState::Pressed,
        ..
    },
    ..
} => {
    state.clear_color = if state.clear_color == wgpu::Color::GREEN {
        wgpu::Color::BLUE
    } else {
        wgpu::Color::GREEN
    };
    window.request_redraw();
}

// No render pass, use state.clear_color
ops: wgpu::Operations {
    load: wgpu::LoadOp::Clear(state.clear_color),
    store: true,
},
```