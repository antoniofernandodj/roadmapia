## Configuração Inicial do Winit

Criar uma janela parece simples até você precisar lidar com as particularidades de cada plataforma. É aqui que o Winit brilha - ele abstrai as diferenças entre Windows, macOS, Linux (X11 e Wayland) e até WebAssembly, proporcionando uma API unificada.

Vamos começar um projeto do zero. Primeiro, crie um novo projeto Rust:

```bash
cargo new winit_example
cd winit_example
```

Edite o `Cargo.toml` para adicionar a dependência:

```toml
[dependencies]
winit = "0.28.6"
```

Agora, o código mínimo para uma janela que abre e fecha. Substitua o conteúdo de `src/main.rs` por:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("Janela Winit")
        .build(&event_loop)
        .unwrap();

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

Ao executar com `cargo run`, você verá uma janela com o título "Janela Winit" que responde ao botão de fechar. O que está acontecendo nos bastidores?

1. `EventLoop::new()` cria o loop de eventos específico para a plataforma
2. `WindowBuilder` configura propriedades da janela antes de criá-la
3. O `match` trata apenas o evento de fechamento (ignore outros por enquanto)

Um erro comum é esquecer de chamar `.build()` no `WindowBuilder`. O compilador ajudará:

```
error[E0599]: no method named `build` found for struct `WindowBuilder` in the current scope
  --> src/main.rs:10:10
   |
10 |         .build(&event_loop)
   |          ^^^^^ method not found in `WindowBuilder`
```

Isso ocorre porque o `WindowBuilder` é um padrão builder em Rust - você deve finalizar com `.build()` para obter a janela real.

Para personalização adicional, podemos adicionar mais configurações antes do `.build()`:

```rust
let window = WindowBuilder::new()
    .with_title("Janela Personalizada")
    .with_inner_size(winit::dpi::LogicalSize::new(800.0, 600.0))
    .with_resizable(false)
    .build(&event_loop)
    .unwrap();
```

Aqui usamos `LogicalSize` para definir dimensões independentes de DPI. Experimente remover o `unwrap()` para ver como lidar com erros:

```rust
let window = match WindowBuilder::new().build(&event_loop) {
    Ok(window) => window,
    Err(e) => {
        eprintln!("Falha ao criar janela: {}", e);
        std::process::exit(1);
    }
};
```

Algumas plataformas têm requisitos específicos. No macOS, você precisará adicionar isso ao `Cargo.toml` para uma experiência completa:

```toml
[target.'cfg(target_os = "macos")'.dependencies]
cocoa = "0.24"
objc = "0.2.7"
```

**Exercício:** Modifique o exemplo para criar uma janela com fundo transparente. Dica: procure por `with_transparent` na documentação do `WindowBuilder`.

**Solução:**

```rust
let window = WindowBuilder::new()
    .with_title("Janela Transparente")
    .with_transparent(true)
    .build(&event_loop)
    .unwrap();
```

Isso funciona na maioria das plataformas, mas em Linux/X11 você precisará ativar composição no seu gerenciador de janelas para ver o efeito.