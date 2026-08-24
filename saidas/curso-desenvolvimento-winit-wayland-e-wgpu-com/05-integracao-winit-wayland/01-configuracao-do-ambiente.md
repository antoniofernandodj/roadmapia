## Configuração do Ambiente

O primeiro obstáculo ao trabalhar com Winit e Wayland surge antes mesmo de escrever código: a configuração do ambiente pode falhar silenciosamente, com erros que só aparecem em runtime. Vamos resolver isso de forma definitiva.

Comece instalando as dependências do Wayland no Ubuntu/Debian:

```bash
sudo apt install libwayland-dev wayland-protocols libxkbcommon-dev
```

Para Fedora/RHEL:

```bash
sudo dnf install wayland-devel libxkbcommon-devel
```

Agora, crie um novo projeto Rust com as dependências essenciais:

```toml
[dependencies]
winit = { version = "0.29", features = ["wayland"] }
wayland-client = "0.30"
wayland-protocols = { version = "0.30", features = ["client"] }
```

O erro mais comum ocorre quando o sistema não encontra as bibliotecas necessárias. Se executar um programa Winit e receber:

```
thread 'main' panicked at 'Failed to initialize any backend!'
```

Significa que o ambiente não está configurado corretamente. Verifique com:

```bash
ldd target/debug/seu_programa | grep wayland
```

Que deve mostrar linhas como:
```
libwayland-client.so.0 => /usr/lib/x86_64-linux-gnu/libwayland-client.so.0
```

Para desenvolvimento local, configure a variável de ambiente `WAYLAND_DEBUG=1` para log detalhado:

```bash
WAYLAND_DEBUG=1 cargo run
```

Isso produzirá logs como:
```
[1710287.123]  -> wl_display@1.get_registry(new id wl_registry@2)
[1710287.145]  -> wl_display@1.sync(new id wl_callback@3)
```

Um exemplo mínimo funcional para testar a configuração:

```rust
use winit::event_loop::EventLoop;
use winit::window::WindowBuilder;

fn main() {
    let event_loop = EventLoop::new().unwrap();
    let _window = WindowBuilder::new()
        .with_title("Wayland Test")
        .build(&event_loop)
        .unwrap();
    
    event_loop.run().unwrap();
}
```

Ao executar, você deve ver:
1. Uma janela vazia com o título "Wayland Test"
2. Nenhum erro no terminal
3. Logs Wayland se `WAYLAND_DEBUG=1` estiver setado

Se o sistema tentar cair para X11 (o que não queremos), você verá:
```
Using X11 backend
```

Para forçar Wayland, use:

```bash
env XDG_SESSION_TYPE=wayland cargo run
```

Caso precise depurar problemas de protocolo Wayland, instale:

```bash
sudo apt install weston
```

E execute seu programa dentro do compositor Weston:

```bash
weston &
env WAYLAND_DISPLAY=wayland-0 cargo run
```

Isso isolará seu ambiente de desenvolvimento dos possíveis problemas do compositor principal.

Para verificar todas as extensões Wayland disponíveis no seu sistema:

```rust
use wayland_client::Display;

fn main() {
    let display = Display::connect_to_env().unwrap();
    let registry = display.get_registry();
    
    println!("Extensions suportadas:");
    for &name in registry.available_globals().keys() {
        println!("- {}", name);
    }
}
```

A saída mostrará algo como:
```
Extensions suportadas:
- wl_compositor
- wl_shm
- wl_output
- wl_seat
- zxdg_shell_v6
```

Exercício: Modifique o exemplo mínimo para verificar se a extensão `xdg_wm_base` (necessária para janelas modernas) está disponível. Se não estiver, imprima um aviso explicando que alguns recursos podem não funcionar.

Solução:

```rust
use wayland_client::{Display, globals::GlobalListContents};
use winit::event_loop::EventLoop;

fn main() {
    let display = Display::connect_to_env().unwrap();
    let globals = display.get_registry().globals();
    
    if !globals.list().any(|name| name == "xdg_wm_base") {
        eprintln!("AVISO: xdg_wm_base não disponível. Suporte a janelas pode ser limitado.");
    }

    let event_loop = EventLoop::new().unwrap();
    event_loop.run().unwrap();
}
```