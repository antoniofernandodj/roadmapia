## Sincronização Vertical

Quando uma aplicação gráfica renderiza frames mais rápido que a taxa de atualização do monitor, ocorre um problema chamado *tearing* - partes de diferentes frames aparecem simultaneamente na tela, criando uma imagem rasgada. A sincronização vertical (VSync) resolve isso sincronizando a renderização com a taxa de atualização do display.

No Winit, o VSync é controlado através da configuração do *swap interval* quando criamos o contexto gráfico. Veja como habilitá-lo em uma aplicação básica:

```rust
use winit::{
    event_loop::EventLoop,
    window::WindowBuilder,
};
use softbuffer::GraphicsContext;

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("VSync Example")
        .build(&event_loop)
        .unwrap();

    // Configuração do contexto gráfico com VSync
    let mut graphics_context = unsafe {
        GraphicsContext::new(&window, &window)
            .expect("Failed to create graphics context")
    };
    
    // Habilita VSync (1 frame por atualização)
    graphics_context.set_swap_interval(1).unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = winit::event_loop::ControlFlow::Poll;

        match event {
            winit::event::Event::RedrawRequested(_) => {
                // Lógica de renderização aqui
                graphics_context.present().unwrap();
            }
            _ => (),
        }
    });
}
```

A chamada `set_swap_interval(1)` configura o VSync para esperar uma atualização vertical antes de apresentar o próximo frame. Valores maiores que 1 podem ser usados para reduzir ainda mais a taxa de quadros, economizando energia em aplicações menos exigentes.

**Erro comum:** Tentar configurar o VSync sem um contexto gráfico válido resultará em:

```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: UnsupportedOperation'
```

Isso ocorre quando a plataforma ou driver não suporta a configuração de VSync. Nesses casos, você pode implementar uma limitação manual de FPS:

```rust
use std::time::{Instant, Duration};

let target_fps = 60;
let frame_duration = Duration::from_secs_f32(1.0 / target_fps as f32);
let mut last_frame_time = Instant::now();

event_loop.run(move |event, _, control_flow| {
    let now = Instant::now();
    let elapsed = now - last_frame_time;
    
    if elapsed < frame_duration {
        *control_flow = ControlFlow::WaitUntil(now + (frame_duration - elapsed));
        return;
    }
    
    last_frame_time = now;
    // Restante da lógica do frame...
});
```

**Comparação de abordagens:**

| Método | Vantagens | Desvantagens |
|--------|-----------|--------------|
| VSync Nativo | Elimina tearing completamente, eficiente | Pode introduzir input lag |
| Limitação Manual | Mais controle sobre o FPS | Menos preciso, consome CPU |
| Sem Sincronização | Menor latência | Tearing visível |

Para aplicações críticas de renderização como jogos, combine VSync com técnicas como *triple buffering* para reduzir o input lag:

```rust
// Configuração avançada com triple buffering
graphics_context.set_swap_interval(2).unwrap();  // VSync com buffer extra
```

**Exercício:** Modifique o exemplo inicial para alternar entre VSync ativado e desativado ao pressionar a tecla 'V'. Mostre o FPS atual na janela quando VSync estiver desligado.

**Solução:**

```rust
use winit::{
    event::{Event, VirtualKeyCode},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};
use std::time::{Instant, Duration};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("VSync Toggle")
        .build(&event_loop)
        .unwrap();

    let mut vsync_enabled = true;
    let mut frame_count = 0;
    let mut last_fps_update = Instant::now();
    let mut fps = 0;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Poll;

        match event {
            Event::RedrawRequested(_) => {
                frame_count += 1;
                if last_fps_update.elapsed() > Duration::from_secs(1) {
                    fps = frame_count;
                    frame_count = 0;
                    last_fps_update = Instant::now();
                    window.set_title(&format!(
                        "VSync: {} | FPS: {}",
                        if vsync_enabled { "ON" } else { "OFF" },
                        fps
                    ));
                }
            }
            Event::WindowEvent { event, .. } => match event {
                winit::event::WindowEvent::KeyboardInput { input, .. } => {
                    if input.virtual_keycode == Some(VirtualKeyCode::V) && input.state.is_pressed() {
                        vsync_enabled = !vsync_enabled;
                    }
                }
                _ => (),
            },
            _ => (),
        }
    });
}
```