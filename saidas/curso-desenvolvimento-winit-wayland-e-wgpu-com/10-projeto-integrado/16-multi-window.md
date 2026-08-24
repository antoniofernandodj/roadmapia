## Multi-window

Um editor de texto moderno exige múltiplas janelas: para abrir arquivos lado a lado, mostrar pré-visualizações ou exibir painéis auxiliares. Implementar isso em Rust com Winit e WGPU traz desafios específicos - cada janela precisa de seu próprio contexto gráfico, estado de renderização e tratamento de eventos, tudo coordenado sem violar as regras de ownership.

O problema central aparece ao tentar criar uma segunda janela:

```rust
let window_1 = WindowBuilder::new().build(&event_loop).unwrap();
let window_2 = WindowBuilder::new().build(&event_loop).unwrap(); // Panic!
```

O erro ocorre porque o Winit, por padrão, não permite múltiplas janelas no mesmo thread. A mensagem exata é clara: `Creating a second window in an event loop is not supported on this platform`. A solução envolve estruturar nosso aplicativo para gerenciar janelas de forma independente.

### Arquitetura de Multi-janela

O padrão `WindowManager` resolve isso encapsulando cada janela em seu próprio contexto:

```rust
struct ManagedWindow {
    window: Window,
    surface: wgpu::Surface,
    size: PhysicalSize<u32>,
    // Outros estados específicos da janela
}

struct WindowManager {
    windows: HashMap<WindowId, ManagedWindow>,
    next_id: WindowId,
}
```

Cada `ManagedWindow` contém:
1. A janela Winit (`window`)
2. A surface WGPU (`surface`)
3. O tamanho físico atual (`size`)
4. Recursos gráficos específicos (swap chain, pipelines)

### Inicialização Segura

A criação de novas janelas deve ser feita dentro do event loop:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::UserEvent(WindowCommand::CreateNew) => {
            let window = WindowBuilder::new()
                .with_title("Nova Janela")
                .build(&event_loop)
                .unwrap();
            
            let surface = unsafe { instance.create_surface(&window) };
            let size = window.inner_size();
            
            let managed = ManagedWindow::new(window, surface, size);
            window_manager.add_window(managed);
        }
        // Outros eventos...
    }
});
```

### Renderização Coordenada

O loop principal precisa renderizar cada janela sequencialmente:

```rust
for (_, managed) in &mut window_manager.windows {
    let frame = managed.surface.get_current_texture()?;
    let view = frame.texture.create_view(&wgpu::TextureViewDescriptor::default());
    
    let mut encoder = device.create_command_encoder(/* ... */);
    // Configuração do render pass...
    
    queue.submit(std::iter::once(encoder.finish()));
    frame.present();
}
```

Erro comum: tentar renderizar janelas em paralelo causará falhas como `SurfaceError::Lost` quando duas threads acessam o mesmo adaptador gráfico. A solução é renderizar sequencialmente ou usar um `Mutex` no dispositivo WGPU.

### Sincronização de Estado

Para compartilhar dados entre janelas (como o texto do editor), usamos `Arc<RwLock<T>>`:

```rust
#[derive(Default)]
struct SharedState {
    document: ropey::Rope,
    cursor_pos: (usize, usize),
}

let shared_state = Arc::new(RwLock::new(SharedState::default()));

// Em cada janela:
let local_state = shared_state.clone();
```

Isso permite leitura concorrente e escrita exclusiva, essencial para performance em aplicações com muitas janelas.

### Eventos Específicos

Cada janela gera eventos independentes que devem ser roteados corretamente:

```rust
Event::WindowEvent { event, window_id } => {
    if let Some(managed) = window_manager.get_mut(window_id) {
        match event {
            WindowEvent::Resized(new_size) => {
                managed.resize(new_size);
            }
            // Outros eventos...
        }
    }
}
```

### Exemplo Completo

Veja um editor básico com duas janelas sincronizadas:

```rust
use winit::event::{Event, WindowEvent};
use winit::event_loop::{ControlFlow, EventLoop};
use winit::window::{Window, WindowBuilder, WindowId};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};

struct EditorWindow {
    // Recursos gráficos...
}

struct EditorState {
    text: Arc<RwLock<String>>,
    windows: HashMap<WindowId, EditorWindow>,
}

fn main() {
    let event_loop = EventLoop::with_user_event();
    let mut state = EditorState {
        text: Arc::new(RwLock::new(String::new())),
        windows: HashMap::new(),
    };

    // Primeira janela
    let window = WindowBuilder::new()
        .with_title("Editor 1")
        .build(&event_loop)
        .unwrap();
    state.windows.insert(window.id(), EditorWindow::new(window));

    // Segunda janela
    let window = WindowBuilder::new()
        .with_title("Editor 2")
        .build(&event_loop)
        .unwrap();
    state.windows.insert(window.id(), EditorWindow::new(window));

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, window_id } => {
                if let Some(editor) = state.windows.get_mut(&window_id) {
                    match event {
                        WindowEvent::CloseRequested => {
                            state.windows.remove(&window_id);
                            if state.windows.is_empty() {
                                *control_flow = ControlFlow::Exit;
                            }
                        }
                        WindowEvent::KeyboardInput { input, .. } => {
                            let mut text = state.text.write().unwrap();
                            // Atualiza texto compartilhado...
                        }
                        _ => {}
                    }
                }
            }
            Event::RedrawRequested(window_id) => {
                if let Some(editor) = state.windows.get_mut(&window_id) {
                    editor.redraw(&state.text.read().unwrap());
                }
            }
            _ => {}
        }
    });
}
```

### Exercício Prático

Implemente um sistema onde:
1. Uma tecla de atalho (Ctrl+N) cria novas janelas
2. Todas as janelas mostram o mesmo conteúdo de texto
3. Alterações em qualquer janela refletem nas outras
4. A última janela fechada encerra o aplicativo

Solução parcial:

```rust
// No match do event loop...
WindowEvent::KeyboardInput { input, .. } if input.modifiers.ctrl() && input.virtual_keycode == Some(VirtualKeyCode::N) => {
    let window = WindowBuilder::new()
        .with_title(format!("Editor {}", state.windows.len() + 1))
        .build(&event_loop)
        .unwrap();
    state.windows.insert(window.id(), EditorWindow::new(window));
}
```