## Multi-window Avançado

Quando você precisa de múltiplas janelas interconectadas em Rust (como um editor de código com janelas flutuantes ou um painel de controle com múltiplos monitores), o gerenciamento manual pode rapidamente se tornar complexo. Veja o que acontece quando tentamos uma abordagem ingênua:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    
    let main_window = WindowBuilder::new()
        .with_title("Janela Principal")
        .build(&event_loop)
        .unwrap();

    let secondary_window = WindowBuilder::new()
        .with_title("Janela Secundária")
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event: WindowEvent::CloseRequested, window_id } => {
                if window_id == main_window.id() {
                    *control_flow = ControlFlow::Exit;
                } else {
                    // Como fechar apenas a secundária?
                }
            },
            _ => (),
        }
    });
}
```

O problema imediato aparece quando tentamos fechar apenas a janela secundária: não há uma API direta para destruir uma janela específica em runtime. A mensagem de erro típica seria:

```
error[E0382]: borrow of moved value: `secondary_window`
   --> src/main.rs:20:45
    |
12  |     let secondary_window = WindowBuilder::new()
    |         --------------- move occurs because `secondary_window` has type `winit::window::Window`, which does not implement the `Copy` trait
...
20  |         .build(&event_loop)
    |         ------------------ value moved here
...
27  |             if window_id == main_window.id() {
    |                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ value borrowed here after move
```

### Solução com WindowStore

A abordagem correta envolve usar um `Arc<Mutex<HashMap<WindowId, Window>>>` para gerenciar as janelas dinamicamente:

```rust
use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};
use winit::{
    dpi::LogicalSize,
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::{Window, WindowBuilder, WindowId},
};

struct WindowManager {
    windows: Arc<Mutex<HashMap<WindowId, Window>>>,
}

impl WindowManager {
    fn new() -> Self {
        Self {
            windows: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    fn add_window(&self, event_loop: &EventLoop<()>, title: &str, size: LogicalSize<u32>) -> WindowId {
        let window = WindowBuilder::new()
            .with_title(title)
            .with_inner_size(size)
            .build(event_loop)
            .unwrap();
        
        let id = window.id();
        self.windows.lock().unwrap().insert(id, window);
        id
    }

    fn close_window(&self, id: WindowId) -> bool {
        self.windows.lock().unwrap().remove(&id).is_some()
    }
}

fn main() {
    let event_loop = EventLoop::new();
    let manager = WindowManager::new();

    let main_id = manager.add_window(&event_loop, "Principal", LogicalSize::new(800, 600));
    let secondary_id = manager.add_window(&event_loop, "Secundária", LogicalSize::new(400, 300));

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event: WindowEvent::CloseRequested, window_id } => {
                if window_id == main_id {
                    *control_flow = ControlFlow::Exit;
                } else {
                    manager.close_window(window_id);
                }
            },
            _ => (),
        }
    });
}
```

### Comunicação entre Janelas

Para sincronizar estado entre janelas (como um painel de configurações que atualiza a janela principal), usamos canais assíncronos:

```rust
use crossbeam::channel::{unbounded, Sender, Receiver};

enum WindowMessage {
    ConfigChanged(String),
    RequestRedraw(WindowId),
}

struct AppState {
    manager: WindowManager,
    tx: Sender<WindowMessage>,
    rx: Receiver<WindowMessage>,
}

impl AppState {
    fn new() -> Self {
        let (tx, rx) = unbounded();
        Self {
            manager: WindowManager::new(),
            tx,
            rx,
        }
    }
}

// Em uma thread secundária:
std::thread::spawn(move || {
    while let Ok(msg) = state.rx.recv() {
        match msg {
            WindowMessage::ConfigChanged(config) => {
                // Atualizar todas as janelas
                let windows = state.manager.windows.lock().unwrap();
                for window in windows.values() {
                    window.set_title(&config);
                }
            },
            WindowMessage::RequestRedraw(id) => {
                if let Some(window) = state.manager.windows.lock().unwrap().get(&id) {
                    window.request_redraw();
                }
            },
        }
    }
});
```

### Wayland Multi-window

No Wayland, cada janela é um `wl_surface` independente. O código anterior funcionaria, mas para controle fino sobre o posicionamento:

```rust
#[cfg(target_os = "linux")]
fn position_window(window: &Window, x: i32, y: i32) {
    use winit::platform::unix::WindowExtUnix;
    
    if let Some(surface) = window.wayland_surface() {
        let shell_surface = window.xdg_surface().unwrap();
        shell_surface.set_window_geometry(x, y, 800, 600);
    }
}
```

### Exercício Prático

Implemente um sistema de janelas flutuantes onde:
1. A janela principal cria janelas filhas com posições relativas
2. O fechamento da principal fecha todas
3. As filhas podem ser arrastadas mantendo a posição relativa

Solução comentada:

```rust
struct ChildWindow {
    id: WindowId,
    offset: (i32, i32),
}

struct FloatingWindows {
    main: WindowId,
    children: Vec<ChildWindow>,
}

impl FloatingWindows {
    fn new(manager: &WindowManager, event_loop: &EventLoop<()>) -> Self {
        let main = manager.add_window(event_loop, "Main", LogicalSize::new(1024, 768));
        let mut children = Vec::new();

        for i in 0..3 {
            let child = ChildWindow {
                id: manager.add_window(
                    event_loop,
                    &format!("Child {}", i),
                    LogicalSize::new(300, 200),
                ),
                offset: (50 + i * 50, 50 + i * 50),
            };
            children.push(child);
        }

        Self { main, children }
    }
}
```