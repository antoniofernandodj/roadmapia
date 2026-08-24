## Fullscreen Exclusivo

Quando um jogo ou aplicação gráfica precisa de máxima performance e controle sobre a saída de vídeo, o modo fullscreen exclusivo (exclusive fullscreen) elimina a sobrecarga do compositor de janelas, dando acesso direto ao framebuffer da GPU. Veja como implementá-lo no Wayland com Winit e WGPU.

### O Problema do Fullscreen Convencional

O modo fullscreen padrão no Wayland (via `set_fullscreen(true)`) ainda passa pelo compositor, o que introduz:

1. Composição adicional de camadas
2. VSync obrigatório
3. Latência de apresentação

```rust
// Isso NÃO é fullscreen exclusivo - apenas um "fake fullscreen"
window.set_fullscreen(Some(Fullscreen::Borderless(None)));
```

### Implementando o Fullscreen Exclusivo

O Wayland não tem suporte nativo a fullscreen exclusivo como o X11, mas podemos aproximar o comportamento:

1. Criar uma superfície sem bordas ocupando todo o monitor
2. Desativar a composição via protocolos específicos
3. Controlar diretamente a taxa de atualização

```rust
use winit::{
    event_loop::{EventLoop, ControlFlow},
    window::{Window, WindowBuilder},
    platform::wayland::WindowExtWayland,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_decorations(false)
        .with_fullscreen(Some(Fullscreen::Exclusive(
            event_loop.primary_monitor()
        )))
        .build(&event_loop)
        .unwrap();

    // Forçar modo exclusivo (se suportado)
    if let Some(surface) = window.wayland_surface() {
        let wl_surface = surface.as_ref();
        // Configurações específicas do compositor
        configure_exclusive_mode(wl_surface);
    }
}
```

### Controlando a Taxa de Atualização

Com WGPU, podemos sincronizar a renderização com a taxa nativa do monitor:

```rust
let instance = wgpu::Instance::new(wgpu::Backends::PRIMARY);
let surface = unsafe { instance.create_surface(&window) };
let adapter = instance.request_adapter(&wgpu::RequestAdapterOptions {
    power_preference: wgpu::PowerPreference::HighPerformance,
    compatible_surface: Some(&surface),
    force_fallback_adapter: false,
}).await.unwrap();

let (device, queue) = adapter.request_device(
    &wgpu::DeviceDescriptor {
        features: wgpu::Features::empty(),
        limits: wgpu::Limits::default(),
        label: None,
    },
    None,
).await.unwrap();

let swap_chain_desc = wgpu::SwapChainDescriptor {
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
    format: wgpu::TextureFormat::Bgra8Unorm,
    width: window.inner_size().width,
    height: window.inner_size().height,
    present_mode: wgpu::PresentMode::Immediate, // VSync desligado
};
```

### Erro Comum e Correção

Ao tentar usar `PresentMode::Immediate` sem suporte:

```
thread 'main' panicked at 'Adapter does not support present mode: Immediate'
```

Solução: verificar capacidades primeiro:

```rust
let surface_caps = surface.get_capabilities(&adapter);
let present_mode = if surface_caps.present_modes.contains(&wgpu::PresentMode::Immediate) {
    wgpu::PresentMode::Immediate
} else {
    wgpu::PresentMode::Fifo // Fallback para VSync
};
```

### Monitorando a Performance

Compare os modos com este código de benchmark:

```rust
use std::time::{Instant, Duration};

struct FrameTimer {
    last_frame: Instant,
    frame_count: u32,
    fps: f32,
}

impl FrameTimer {
    fn new() -> Self {
        Self {
            last_frame: Instant::now(),
            frame_count: 0,
            fps: 0.0,
        }
    }

    fn update(&mut self) {
        self.frame_count += 1;
        if self.last_frame.elapsed() >= Duration::from_secs(1) {
            self.fps = self.frame_count as f32;
            self.frame_count = 0;
            self.last_frame = Instant::now();
            println!("FPS: {:.1}", self.fps);
        }
    }
}
```

### Exercício Prático

Implemente um alternador de modos que:
1. Mostre o FPS atual na janela
2. Alterne entre `PresentMode::Fifo` e `Immediate` com a tecla F
3. Exiba as capacidades reais do adaptador

Solução comentada:

```rust
// Adicione ao seu State existente
struct State {
    // ...
    present_mode: wgpu::PresentMode,
    frame_timer: FrameTimer,
    surface_caps: wgpu::SurfaceCapabilities,
}

// No evento de teclado
match event {
    WindowEvent::KeyboardInput { input, .. } if input.state == ElementState::Pressed => {
        if let Some(VirtualKeyCode::F) = input.virtual_keycode {
            state.present_mode = match state.present_mode {
                wgpu::PresentMode::Fifo => {
                    if state.surface_caps.present_modes.contains(&wgpu::PresentMode::Immediate) {
                        wgpu::PresentMode::Immediate
                    } else {
                        wgpu::PresentMode::Mailbox
                    }
                },
                _ => wgpu::PresentMode::Fifo,
            };
            println!("Alternado para: {:?}", state.present_mode);
        }
    }
    _ => {}
}

// Na renderização
state.frame_timer.update();
let fps_text = format!("FPS: {:.1}\nModo: {:?}", 
    state.frame_timer.fps, 
    state.present_mode
);
render_text(&mut state, &fps_text); // Sua função de renderização de texto
```