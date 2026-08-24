## Criação e Gerenciamento de Janelas

Quando você precisa exibir conteúdo gráfico em Rust, a primeira barreira é criar uma janela nativa do sistema operacional. O Winit resolve isso provendo uma API cross-platform que abstrai as diferenças entre Windows, macOS e Linux/X11/Wayland. 

Vamos começar com um exemplo mínimo que cria uma janela e mantém ela aberta até o usuário fechar:

```rust
use winit::{
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let _window = WindowBuilder::new()
        .with_title("Minha Primeira Janela")
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |_, _, control_flow| {
        *control_flow = ControlFlow::Wait;
    });
}
```

Execute este código e você verá uma janela com:
- Título "Minha Primeira Janela"
- Tamanho padrão do sistema (geralmente 800×600)
- Botões de minimizar/maximizar/fechar
- Comportamento normal de janela (pode ser arrastada, redimensionada)

O padrão builder (`WindowBuilder`) permite configurar propriedades antes de criar a janela. Vamos customizar mais:

```rust
let window = WindowBuilder::new()
    .with_title("Janela Customizada")
    .with_inner_size(winit::dpi::LogicalSize::new(400.0, 300.0))
    .with_resizable(false)
    .with_maximized(true)
    .build(&event_loop)?;
```

**Erro comum:** tentar usar a janela após o `event_loop.run()`. Este é um erro de lifetime que o compilador Rust vai pegar:

```rust
let window = WindowBuilder::new().build(&event_loop)?;
event_loop.run(...);
window.set_title("Novo Título"); // ERRO: borrowed value does not live long enough
```

A solução é usar closures para interagir com a janela durante o loop de eventos, como veremos em trechos posteriores.

**Configurações avançadas importantes:**

1. **DPI Awareness** - Crucial para renderização nítida:
```rust
.use_dpi_aware(true) // Windows/Linux
```

2. **Transparência** (requer compositor ativo):
```rust
.with_transparent(true)
```

3. **Always on Top**:
```rust
.with_always_on_top(true)
```

**Plataformas específicas:** No macOS, você precisará lidar com:

```rust
#[cfg(target_os = "macos")]
WindowBuilder::new()
    .with_titlebar_transparent(true)
    .with_fullsize_content_view(true);
```

**Exercício:** Crie uma janela que:
1. Tenha tamanho fixo 500×500
2. Não possa ser maximizada
3. Exiba um ícone personalizado
4. Inicie no centro da tela

**Solução comentada:**

```rust
use winit::window::Icon;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let event_loop = EventLoop::new();
    
    // Carrega ícone de arquivo (deve ser 32x32 RGBA)
    let icon = Icon::from_rgba(
        include_bytes!("icon.rgba").to_vec(),
        32,
        32,
    )?;

    let window = WindowBuilder::new()
        .with_inner_size(winit::dpi::LogicalSize::new(500.0, 500.0))
        .with_resizable(false)
        .with_maximizable(false)
        .with_window_icon(Some(icon))
        .with_position(winit::dpi::LogicalPosition::new(
            // Centraliza na tela
            winit::dpi::PhysicalPosition::new(
                unsafe { winit::platform::windows::WindowExtWindows::get_current_monitor(&window) }
                    .size()
                    .width / 2,
                // (... similar para height)
            )
        ))
        .build(&event_loop)?;

    event_loop.run(...);
    Ok(())
}
```