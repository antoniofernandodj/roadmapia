## Múltiplas Janelas

Quando você precisa exibir conteúdo independente em áreas separadas da tela - como um editor de código com painéis laterais, um dashboard com múltiplas visualizações ou uma ferramenta de debug com janelas auxiliares - criar múltiplas janelas nativas é a solução mais eficiente. Veja como o Winit lida com esse cenário:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    
    // Janela principal
    let main_window = WindowBuilder::new()
        .with_title("Editor de Texto")
        .build(&event_loop)
        .unwrap();

    // Janela secundária (painel lateral)
    let side_panel = WindowBuilder::new()
        .with_title("Explorador de Arquivos")
        .with_inner_size(winit::dpi::LogicalSize::new(300.0, 600.0))
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                window_id,
            } if window_id == main_window.id() => *control_flow = ControlFlow::Exit,
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                window_id,
            } if window_id == side_panel.id() => side_panel.set_visible(false),
            _ => (),
        }
    });
}
```

Neste exemplo, criamos duas janelas: uma principal que encerra a aplicação quando fechada, e uma secundária que apenas se torna invisível ao ser fechada. Observe como distinguimos entre as janelas usando `window_id` nos eventos.

Um erro comum é tentar usar diretamente as instâncias de `Window` dentro do loop de eventos sem verificar o ID:

```rust
// ERRO COMUM: isso não funciona como esperado
Event::WindowEvent { event: WindowEvent::CloseRequested, .. } => {
    main_window.set_visible(false); // Pode afetar a janela errada!
}
```

A mensagem de erro que você receberia ao tentar acessar diretamente a janela seria sobre ownership (como "borrowed value does not live long enough"), porque o borrow checker impede o uso direto das janelas após o início do loop.

### Compartilhando Estado Entre Janelas

Para sincronizar dados entre janelas, precisamos de um mecanismo thread-safe. Aqui está um padrão eficiente usando `Arc<Mutex<T>>`:

```rust
use std::sync::{Arc, Mutex};
use winit::window::WindowId;

struct AppState {
    active_document: String,
    windows: Vec<WindowId>,
}

fn main() {
    let event_loop = EventLoop::new();
    let app_state = Arc::new(Mutex::new(AppState {
        active_document: String::new(),
        windows: Vec::new(),
    }));

    let state_clone = Arc::clone(&app_state);
    let main_window = WindowBuilder::new()
        .with_title("Editor")
        .build(&event_loop)
        .unwrap();

    // Registrar janela no estado compartilhado
    state_clone.lock().unwrap().windows.push(main_window.id());

    let state_clone = Arc::clone(&app_state);
    let preview_window = WindowBuilder::new()
        .with_title("Preview")
        .build(&event_loop)
        .unwrap();
    state_clone.lock().unwrap().windows.push(preview_window.id());

    // ... restante do loop de eventos
}
```

### Gerenciando Foco e Z-Order

Controlar qual janela está em foco e sua ordem de empilhamento é crucial para a experiência do usuário:

```rust
// Trazer janela para frente quando receber foco
Event::WindowEvent {
    event: WindowEvent::Focused(true),
    window_id,
} => {
    if let Some(window) = find_window_by_id(window_id) {
        window.focus_window();
    }
}
```

### Exemplo Completo: Editor com Preview

Vamos criar um editor Markdown com visualização em tempo real em uma janela separada:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::{Window, WindowBuilder},
};

struct MarkdownEditor {
    editor_window: Window,
    preview_window: Window,
    content: String,
}

fn main() {
    let event_loop = EventLoop::new();
    
    let editor = MarkdownEditor::new(&event_loop);
    
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;
        
        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                window_id,
            } if window_id == editor.editor_window.id() => *control_flow = ControlFlow::Exit,
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                window_id,
            } if window_id == editor.preview_window.id() => editor.preview_window.set_visible(false),
            Event::WindowEvent {
                event: WindowEvent::KeyboardInput { input, .. },
                window_id,
            } if window_id == editor.editor_window.id() => {
                editor.handle_key_input(input);
                editor.update_preview();
            },
            _ => (),
        }
    });
}

impl MarkdownEditor {
    fn new(event_loop: &EventLoop<()>) -> Self {
        let editor_window = WindowBuilder::new()
            .with_title("Editor Markdown")
            .build(event_loop)
            .unwrap();
            
        let preview_window = WindowBuilder::new()
            .with_title("Preview")
            .build(event_loop)
            .unwrap();
            
        Self {
            editor_window,
            preview_window,
            content: String::new(),
        }
    }
    
    fn update_preview(&self) {
        // Aqui iria a lógica para renderizar o markdown no preview_window
    }
    
    fn handle_key_input(&mut self, input: winit::event::KeyboardInput) {
        // Lógica simplificada para capturar entrada de texto
        if let Some(key) = input.virtual_keycode {
            // ... processar entrada
        }
    }
}
```

### Exercício Prático

Crie um aplicativo com três janelas:
1. Uma janela principal com um botão "Adicionar"
2. Uma janela de lista que mostra itens adicionados
3. Uma janela de status que mostra o contador de itens

Quando o botão na janela principal é clicado, todas as janelas devem ser atualizadas.

**Solução:**

```rust
use std::sync::{Arc, Mutex};
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

struct AppData {
    items: Vec<String>,
    counter: usize,
}

fn main() {
    let event_loop = EventLoop::new();
    let app_data = Arc::new(Mutex::new(AppData {
        items: Vec::new(),
        counter: 0,
    }));

    // Janela principal
    let data_clone = Arc::clone(&app_data);
    let main_window = WindowBuilder::new()
        .with_title("Adicionador")
        .build(&event_loop)
        .unwrap();

    // Janela de lista
    let data_clone = Arc::clone(&app_data);
    let list_window = WindowBuilder::new()
        .with_title("Lista")
        .build(&event_loop)
        .unwrap();

    // Janela de status
    let status_window = WindowBuilder::new()
        .with_title("Status")
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                window_id,
            } if window_id == main_window.id() => *control_flow = ControlFlow::Exit,
            Event::WindowEvent {
                event: WindowEvent::MouseInput { state, .. },
                window_id,
            } if window_id == main_window.id() && state == winit::event::ElementState::Pressed => {
                let mut data = app_data.lock().unwrap();
                data.counter += 1;
                data.items.push(format!("Item {}", data.counter));
                
                // Aqui atualizariamos a UI nas outras janelas
                println!("Itens atualizados: {:?}", data.items);
            },
            _ => (),
        }
    });
}
```