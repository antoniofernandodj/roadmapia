## Loop de Eventos Básico

Quando você cria uma janela com Winit, tudo acontece dentro de um *event loop* - um loop infinito que espera por eventos do sistema operacional (cliques, redimensionamentos, teclas pressionadas) e os entrega para seu código processar. Vamos dissecar um exemplo mínimo que mostra como esse ciclo funciona na prática:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let _window = WindowBuilder::new().build(&event_loop).unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
```

Ao executar, você vê uma janela vazia que responde apenas ao botão de fechar. O segredo está no `run()`: ele toma um closure que será chamado para cada evento. Vamos analisar os componentes críticos:

1. **`ControlFlow`** - Determina como o loop lida com o tempo entre eventos:
   - `Wait` (padrão): economiza energia, só acorda quando há eventos
   - `Poll`: verifica eventos continuamente (útil para jogos/animções)
   - `Exit`: termina o aplicativo

2. **Padrão de Eventos** - Winit usa uma hierarquia de enums:
   - `Event::WindowEvent` para interações com a janela
   - `Event::DeviceEvent` para input direto de dispositivos
   - `Event::MainEventsCleared` para lógica de frame

Um erro comum é tentar usar a janela após o `run()`, o que causa este erro em tempo de compilação:

```rust
let window = WindowBuilder::new().build(&event_loop).unwrap();
event_loop.run(/* ... */);
window.set_title("Novo título"); // ERRO!
```

```
error[E0382]: borrow of moved value: `window`
   --> src/main.rs:9:5
    |
7   | let window = WindowBuilder::new().build(&event_loop).unwrap();
    |     ------ move occurs because `window` has type `Window`, which does not implement the `Copy` trait
8   | event_loop.run(/* ... */);
    | ------------------------- `window` moved into event closure here
9   | window.set_title("Novo título");
    | ^^^^^^^^^^^^^^^^ value borrowed here after move
```

A correção é armazenar o estado da aplicação dentro do closure, usando `move`:

```rust
event_loop.run(move |event, _, control_flow| {
    // `window` agora pertence ao closure
    window.set_title("Título Dinâmico");
    *control_flow = ControlFlow::Wait;
    // ...
});
```

Para um exemplo mais completo, vamos adicionar um contador de frames:

```rust
use winit::event::Event;

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    let mut frame_count = 0;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            Event::MainEventsCleared => {
                frame_count += 1;
                window.set_title(&format!("Frame {}", frame_count));
            }
            _ => (),
        }
    });
}
```

A saída mostra o título da janela atualizando a cada frame limpo - você verá números incrementando rapidamente, mesmo sem renderização ativa.

**Exercício**: Modifique o exemplo para fechar a janela após 60 frames, exibindo uma mensagem no console ao sair.

<details>
<summary>Solução</summary>

```rust
use winit::event::Event;

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    let mut frame_count = 0;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            Event::MainEventsCleared => {
                frame_count += 1;
                window.set_title(&format!("Frame {}", frame_count));

                if frame_count >= 60 {
                    println!("Terminando após 60 frames");
                    *control_flow = ControlFlow::Exit;
                }
            }
            _ => (),
        }
    });
}
```
</details>