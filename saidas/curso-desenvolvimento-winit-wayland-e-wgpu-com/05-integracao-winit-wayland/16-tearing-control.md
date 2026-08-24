## Tearing Control

O problema do tearing ocorre quando a atualização do buffer de imagem não está sincronizada com a taxa de atualização do monitor, resultando em partes de frames diferentes aparecendo simultaneamente na tela. Em aplicações gráficas que priorizam baixa latência (como jogos ou players de vídeo), o controle manual do tearing pode ser essencial.

Wayland tradicionalmente evita tearing através da sincronização estrita entre cliente e compositor, mas isso introduz latência. Para casos onde a sincronização perfeita não é necessária, podemos usar a extensão `wp_tearing_control_v1`.

### Configurando o Protocolo de Tearing

Primeiro, verifique se o compositor suporta o protocolo:

```rust
use winit::platform::wayland::EventLoopBuilderExtWayland;

let event_loop = EventLoopBuilder::new()
    .with_tearing(true)  // Habilita suporte a tearing control
    .build();

let window = WindowBuilder::new()
    .with_tearing(true)  // Aplica à janela específica
    .build(&event_loop)?;
```

Se o protocolo não estiver disponível, o sistema continuará funcionando com VSync padrão. Verifique o suporte em runtime:

```rust
if window.wayland_tearing_supported() {
    println!("Tearing control disponível");
} else {
    println!("Falling back para VSync padrão");
}
```

### Controle Prático do Tearing

No WGPU, configuramos o PresentMode para Immediate quando queremos permitir tearing:

```rust
let swap_chain = device.create_swap_chain(
    &surface,
    &wgpu::SwapChainDescriptor {
        usage: wgpu::TextureUsage::RENDER_ATTACHMENT,
        format: wgpu::TextureFormat::Bgra8Unorm,
        width: size.width,
        height: size.height,
        present_mode: wgpu::PresentMode::Immediate,  // Permite tearing
    },
);
```

Um erro comum é esquecer de sincronizar manualmente quando o tearing está ativado. Sem tratamento adequado, isso pode causar artefatos visuais:

```rust
// ERRADO: Falta sincronização manual
surface.get_current_texture().unwrap();

// CORRETO: Sincronização explícita
let frame = surface.get_current_texture()?;
frame.present();  // Libera o frame imediatamente
```

### Benchmarking de Performance

Compare os tempos de frame com e sem tearing control:

```rust
use std::time::{Instant, Duration};

let mut last_frame = Instant::now();
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::RedrawRequested(_) => {
            let now = Instant::now();
            let delta = now - last_frame;
            println!("Frame time: {:?}", delta);
            last_frame = now;
            
            // Renderização normal...
            window.request_redraw();
        }
        _ => (),
    }
});
```

Com `PresentMode::Fifo` (VSync), os tempos serão consistentes com a taxa de atualização do monitor. No modo `Immediate`, os tempos serão variáveis, refletindo a velocidade real de renderização.

### Exercício Prático

Implemente um alternador de tearing control que responda à tecla F1:

```rust
// Solução:
let mut tearing_enabled = false;

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event: WindowEvent::KeyboardInput { input, .. }, .. } => {
            if input.virtual_keycode == Some(VirtualKeyCode::F1) && input.state == ElementState::Pressed {
                tearing_enabled = !tearing_enabled;
                window.set_tearing(tearing_enabled);
                println!("Tearing {}", if tearing_enabled { "ativado" } else { "desativado" });
            }
        }
        Event::RedrawRequested(_) => {
            let present_mode = if tearing_enabled {
                wgpu::PresentMode::Immediate
            } else {
                wgpu::PresentMode::Fifo
            };
            
            // Recria a swap chain com o novo modo
            let config = surface.get_supported_formats(&adapter)[0];
            surface.configure(&device, &wgpu::SurfaceConfiguration {
                usage: wgpu::TextureUsage::RENDER_ATTACHMENT,
                format: config,
                width: size.width,
                height: size.height,
                present_mode,
            });
            
            window.request_redraw();
        }
        _ => (),
    }
});
```