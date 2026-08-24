## Clipboard e Drag-and-Drop

Copiar e colar parece simples até você precisar implementá-lo. No Winit, a abstração do clipboard esconde um labirinto de implementações específicas por plataforma - mas a API Rust nos dá um caminho seguro.

Vamos começar com o clipboard básico. O Winit expõe esta funcionalidade através do objeto `Clipboard`, que você obtém da janela:

```rust
use winit::event_loop::EventLoop;
use winit::window::Window;

let event_loop = EventLoop::new();
let window = Window::new(&event_loop).unwrap();

// Obtém o clipboard - pode falhar em algumas plataformas
let clipboard = window.clipboard()
    .expect("Clipboard não suportado nesta plataforma");
```

Um erro comum é tentar usar o clipboard fora do thread principal. Isso causará um panic com a mensagem:

```
thread 'main' panicked at 'clipboard must be accessed from the main thread'
```

A solução é garantir que todas as operações com o clipboard aconteçam dentro do loop de eventos principal. Vejamos como implementar Ctrl+C/Ctrl+V:

```rust
use winit::event::{Event, WindowEvent};
use winit::event_loop::ControlFlow;

event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Poll;

    match event {
        Event::WindowEvent { event, .. } => match event {
            WindowEvent::KeyboardInput { input, .. } => {
                if input.modifiers.ctrl() {
                    match input.virtual_keycode {
                        Some(Key::V) => {
                            if let Ok(text) = clipboard.read() {
                                println!("Texto colado: {}", text);
                            }
                        }
                        Some(Key::C) => {
                            clipboard.write("Texto copiado".to_owned())
                                .expect("Falha ao escrever no clipboard");
                        }
                        _ => (),
                    }
                }
            }
            _ => (),
        },
        _ => (),
    }
});
```

A saída quando pressionamos Ctrl+V após copiar seria:

```
Texto colado: Texto copiado
```

Para drag-and-drop, o Winit oferece eventos específicos. O fluxo típico envolve:

1. `DragStarted` - Quando o usuário começa a arrastar
2. `DragOver` - Enquanto o item é movido
3. `Dropped` - Quando solto
4. `DragCancelled` - Se a operação é abortada

Vamos implementar um receptor de arquivos:

```rust
match event {
    Event::WindowEvent { event, .. } => match event {
        WindowEvent::DragOver { position, .. } => {
            println!("Arrastando sobre: {:?}", position);
        }
        WindowEvent::DroppedFile(path) => {
            println!("Arquivo solto: {}", path.display());
        }
        _ => (),
    },
    _ => (),
}
```

Um erro frequente é não habilitar explicitamente o drag-and-drop. Isso é feito no WindowBuilder:

```rust
let window = WindowBuilder::new()
    .with_drag_and_drop(true)
    .build(&event_loop)?;
```

Se esquecer deste passo, os eventos de drag-and-drop simplesmente não serão emitidos, sem nenhum aviso - um comportamento silencioso que pode causar confusão durante o debug.

Para conteúdo mais complexo como imagens, você precisará serializar os dados. Uma abordagem comum é usar o formato MIME:

```rust
use clipboard::ClipboardFormat;

clipboard.set_contents(
    "image/png".to_string(),
    image_data,
    ClipboardFormat::Mime
).expect("Falha ao copiar imagem");
```

No Linux/Wayland, o clipboard funciona de forma fundamentalmente diferente do Windows/macOS - ele é "lazy", só transferindo os dados quando realmente necessário. Isso pode causar atrasos inesperados se sua aplicação assumir comportamento síncrono.