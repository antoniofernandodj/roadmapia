## Notificações do Sistema

Em aplicações gráficas modernas, notificações do sistema são essenciais para informar o usuário sobre eventos importantes sem interromper seu fluxo de trabalho. Vamos implementar um sistema básico de notificações usando Winit, que funciona em todas as plataformas suportadas.

O ponto de partida é uma aplicação Winit existente. Adicione a dependência `winit` ao seu `Cargo.toml`:

```toml
[dependencies]
winit = { version = "0.29", features = ["rwh_05"] }
```

A maneira mais direta de criar uma notificação é através do método `window.request_redraw()`, que aciona um evento `RedrawRequested`. Porém, para notificações mais ricas, usaremos a API de notificações do sistema operacional:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new().unwrap();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            Event::MainEventsCleared => {
                // Mostrar notificação após 2 segundos
                std::thread::sleep(std::time::Duration::from_secs(2));
                window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
            }
            _ => (),
        }
    });
}
```

Este código exibirá uma notificação visual (como um ícone piscando na barra de tarefas no Windows ou dock no macOS) após 2 segundos. O tipo `UserAttentionType` oferece dois níveis:
- `Informational`: Notificação não intrusiva
- `Critical`: Requer atenção imediata do usuário

Para erros comuns, observe o que acontece se tentarmos chamar `request_user_attention` antes da janela estar visível:

```rust
// ERRO: Chamada prematura
let window = WindowBuilder::new().build(&event_loop).unwrap();
window.request_user_attention(Some(winit::window::UserAttentionType::Informational)); // Pode ser ignorado pelo sistema
```

A solução é garantir que a janela está visível antes de solicitar atenção:

```rust
window.set_visible(true);
window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
```

Em plataformas Unix com Wayland, o comportamento pode variar dependendo do compositor. Para garantir compatibilidade, podemos verificar o backend em tempo de execução:

```rust
if window.is_wayland() {
    // Implementação específica para Wayland
    println!("Wayland requer tratamento especial para notificações");
} else {
    window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
}
```

Um exemplo mais completo com notificação persistente:

```rust
use winit::window::Window;

fn show_notification(window: &Window, title: &str, message: &str) {
    #[cfg(target_os = "windows")]
    {
        use winrt_notification::Toast;
        Toast::new()
            .title(title)
            .text1(message)
            .show()
            .expect("Falha ao mostrar notificação");
    }

    #[cfg(target_os = "macos")]
    {
        use mac_notification_sys::*;
        set_application("meu_app");
        send_notification(title, None, message, None)
            .expect("Falha ao mostrar notificação");
    }

    #[cfg(target_os = "linux")]
    {
        use notify_rust::Notification;
        Notification::new()
            .summary(title)
            .body(message)
            .show()
            .expect("Falha ao mostrar notificação");
    }

    // Fallback para Winit caso as APIs específicas falhem
    window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
}
```

Saída esperada (varia por sistema operacional):
```
[Notificação] Título: "Aviso"
              Corpo: "Sua sessão expirará em 5 minutos"
```

**Exercício**: Crie um sistema de notificações que:
1. Mostra uma notificação quando a janela perde foco
2. Exibe uma contagem regressiva de 5 segundos
3. Solicita atenção crítica quando chegar a zero

Solução:

```rust
use winit::window::Window;
use std::time::{Instant, Duration};

struct AppState {
    lost_focus_time: Option<Instant>,
}

fn main() {
    let event_loop = EventLoop::with_user_event().unwrap();
    let window = WindowBuilder::new().build(&event_loop).unwrap();
    let mut state = AppState { lost_focus_time: None };

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::Focused(false),
                ..
            } => {
                state.lost_focus_time = Some(Instant::now());
                window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
            }
            Event::MainEventsCleared => {
                if let Some(start_time) = state.lost_focus_time {
                    let elapsed = start_time.elapsed();
                    if elapsed >= Duration::from_secs(5) {
                        window.request_user_attention(Some(winit::window::UserAttentionType::Critical));
                        state.lost_focus_time = None;
                    }
                }
            }
            _ => (),
        }
    });
}
```