## Build Cross-platform

Quando você começa a desenvolver aplicações gráficas com Winit, rapidamente percebe que cada plataforma tem suas peculiaridades. O mesmo código que funciona perfeitamente no Linux pode falhar silenciosamente no Windows ou ter comportamentos inesperados no macOS. Vamos resolver isso estruturando um projeto que compila corretamente em todas as plataformas principais.

### O problema do `#[cfg]`

Suponha que você queira definir um ícone padrão para sua janela. No Windows, isso é feito via `.ico`, enquanto no Linux/Unix usamos `.png`. Veja o que acontece se tentarmos uma abordagem ingênua:

```rust
use winit::window::Icon;

// Isso NÃO funciona - erro de compilação em plataformas não-Windows
let icon = Icon::from_path("assets/icon.ico").unwrap();
```

O compilador reclamará:
```
error[E0432]: unresolved import `winit::platform::windows::IconExtWindows`
  --> src/main.rs:5:5
   |
5  |     winit::platform::windows::IconExtWindows;
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ no `IconExtWindows` in `platform::windows`
```

A solução é usar atributos condicionais de compilação:

```rust
let icon = if cfg!(target_os = "windows") {
    Icon::from_path("assets/icon.ico")
} else {
    Icon::from_path("assets/icon.png")
}.unwrap();
```

### Estrutura de diretórios multiplataforma

Para assets como ícones, crie uma estrutura que acomode as diferenças:
```
assets/
├── icons/
│   ├── windows/
│   │   └── icon.ico
│   └── unix/
│       └── icon.png
src/
└── main.rs
```

### Dependências condicionais

No `Cargo.toml`, especifique dependências por plataforma:

```toml
[target.'cfg(target_os = "windows")'.dependencies]
winapi = { version = "0.3", features = ["winuser"] }

[target.'cfg(any(target_os = "linux", target_os = "macos"))'.dependencies]
x11-dl = "2.19"
```

### Tratando eventos específicos de plataforma

Alguns eventos só existem em certas plataformas. Por exemplo, o evento de redimensionamento no macOS tem um comportamento especial:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::RedrawRequested(_) => {
            // Lógica de renderização comum
        }
        #[cfg(target_os = "macos")]
        Event::WindowEvent {
            event: WindowEvent::ScaleFactorChanged { new_inner_size, .. },
            ..
        } => {
            // Tratamento especial para HiDPI no macOS
            handle_macos_scaling(*new_inner_size);
        }
        _ => (),
    }
});
```

### Build Scripts para assets

Crie um `build.rs` para processar assets específicos:

```rust
fn main() {
    if std::env::var("CARGO_CFG_TARGET_OS").unwrap() == "windows" {
        println!("cargo:rerun-if-changed=assets/icons/windows/icon.ico");
    } else {
        println!("cargo:rerun-if-changed=assets/icons/unix/icon.png");
    }
}
```

### Erro comum: esquecer o iOS

Ao desenvolver para mobile, um erro frequente é não considerar que o iOS requer tratamento especial para o ciclo de vida:

```rust
#[cfg(target_os = "ios")]
mod ios {
    pub fn setup_lifecycle_events() {
        // Configura listeners específicos do UIKit
    }
}
```

### Testando em múltiplas plataformas

Adicione ao seu `.github/workflows/build.yml`:

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v2
      - uses: actions-rs/toolchain@v1
        with:
          profile: minimal
          toolchain: stable
          override: true
      - run: cargo build --verbose
```

### Exercício: Adaptador de Plataforma

Crie uma struct `PlatformAdapter` que expõe uma interface unificada para:

1. Carregar ícones
2. Tratar eventos específicos
3. Acessar recursos do sistema

Solução proposta:

```rust
pub struct PlatformAdapter {
    #[cfg(target_os = "windows")]
    windows_specific: WindowsState,
    #[cfg(any(target_os = "linux", target_os = "macos"))]
    unix_specific: UnixState,
}

impl PlatformAdapter {
    pub fn new() -> Self {
        Self {
            #[cfg(target_os = "windows")]
            windows_specific: WindowsState::new(),
            #[cfg(any(target_os = "linux", target_os = "macos"))]
            unix_specific: UnixState::new(),
        }
    }

    pub fn load_icon(&self) -> Icon {
        #[cfg(target_os = "windows")]
        return Icon::from_path("assets/windows/icon.ico").unwrap();
        
        #[cfg(any(target_os = "linux", target_os = "macos"))]
        return Icon::from_path("assets/unix/icon.png").unwrap();
    }
}
```