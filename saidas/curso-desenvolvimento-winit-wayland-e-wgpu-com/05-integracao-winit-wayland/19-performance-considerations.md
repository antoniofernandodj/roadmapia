## Performance Considerations

Ao integrar Winit com Wayland para aplicações gráficas, a performance bruta muitas vezes fica escondida atrás de abstrações convenientes. Vamos desmontar essas camadas para entender os custos reais de operações aparentemente simples.

### O Custo da Troca de Contexto

Considere este exemplo mínimo que redimensiona uma janela:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_decorations(false) // Decorações client-side
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event: WindowEvent::Resized(size), .. } => {
                println!("Novo tamanho: {:?}", size);
                // Aqui você atualizaria a swapchain no WGPU
            },
            _ => (),
        }
    });
}
```

Ao redimensionar a janela, você verá no terminal:

```
Novo tamanho: PhysicalSize { width: 800, height: 600 }
Novo tamanho: PhysicalSize { width: 801, height: 600 }
Novo tamanho: PhysicalSize { width: 802, height: 601 }
...
```

Cada evento `Resized` dispara uma comunicação completa entre cliente e compositor Wayland, envolvendo:

1. Round-trip para negociar o novo tamanho
2. Atualização dos buffers de framebuffer
3. Sincronização implícita via `wl_surface.commit`

### O Problema do Polling

Mudar para `ControlFlow::Poll` parece uma solução para animações suaves:

```rust
*control_flow = ControlFlow::Poll;
```

Mas isso causa uso constante de CPU em 100%, mesmo quando ocioso. O Wayland não tem um mecanismo de "repaint necessário" como o X11 - você precisa implementar:

```rust
use std::time::{Instant, Duration};

let mut last_update = Instant::now();
let target_fps = Duration::from_micros(1_000_000 / 60);

event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::WaitUntil(Instant::now() + target_fps);

    match event {
        Event::MainEventsCleared => {
            if last_update.elapsed() >= target_fps {
                window.request_redraw();
                last_update = Instant::now();
            }
        },
        Event::RedrawRequested(_) => {
            // Renderização real aqui
        },
        _ => (),
    }
});
```

### Buffer Swapping e Latência

Ao usar WGPU com Wayland, o padrão de double buffering tem um custo oculto:

```rust
// Configuração da swapchain WGPU
let config = wgpu::SurfaceConfiguration {
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
    format: surface.get_supported_formats(&adapter)[0],
    width: size.width,
    height: size.height,
    present_mode: wgpu::PresentMode::Fifo, // VSync padrão
};
```

Os modos de apresentação têm características distintas:

1. `Fifo` (VSync): Latência ~16-33ms, sem tearing
2. `Mailbox` (Fast sync): Latência ~0-16ms, sem tearing quando há GPU headroom
3. `Immediate` (No VSync): Latência ~0ms, com tearing visível

### Erro Comum: Bloqueio Implícito

Este código parece inofensivo:

```rust
Event::WindowEvent { event: WindowEvent::CursorMoved { position, .. }, .. } => {
    let logical_pos = position.to_logical(window.scale_factor());
    update_mouse_position(logical_pos);
    window.set_cursor_icon(winit::window::CursorIcon::Grabbing);
}
```

Mas causa um bloqueio de ~2ms cada chamada, pois o Wayland:

1. Espera confirmação do compositor para mudar o cursor
2. Realiza um round-trip implícito
3. Só então continua a execução

A solução é agrupar operações:

```rust
let mut cursor_changed = false;

Event::WindowEvent { event: WindowEvent::CursorMoved { position, .. }, .. } => {
    let logical_pos = position.to_logical(window.scale_factor());
    update_mouse_position(logical_pos);
    cursor_changed = true;
}

Event::MainEventsCleared => {
    if cursor_changed {
        window.set_cursor_icon(winit::window::CursorIcon::Grabbing);
        cursor_changed = false;
    }
}
```

### Exercício Prático

Implemente um contador de FPS preciso que:
1. Use `Instant` para medir intervalos reais
2. Calcule a média móvel dos últimos 60 frames
3. Exiba o valor apenas quando mudar significativamente (>1 FPS)
4. Minimize alocações durante o cálculo

Solução comentada:

```rust
use std::collections::VecDeque;

struct FpsCounter {
    frame_times: VecDeque<Duration>,
    last_update: Instant,
    last_display: u32,
}

impl FpsCounter {
    fn new() -> Self {
        Self {
            frame_times: VecDeque::with_capacity(60),
            last_update: Instant::now(),
            last_display: 0,
        }
    }

    fn tick(&mut self) -> Option<u32> {
        let now = Instant::now();
        let elapsed = now - self.last_update;
        self.last_update = now;

        self.frame_times.push_back(elapsed);
        if self.frame_times.len() > 60 {
            self.frame_times.pop_front();
        }

        let sum: Duration = self.frame_times.iter().sum();
        let avg = sum.as_secs_f32() / self.frame_times.len() as f32;
        let fps = (1.0 / avg).round() as u32;

        if (fps as i32 - self.last_display as i32).abs() > 1 {
            self.last_display = fps;
            Some(fps)
        } else {
            None
        }
    }
}
```