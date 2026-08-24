## Seleção de Backend

Quando desenvolvemos aplicações gráficas para Linux moderno, queremos garantir que o Wayland seja usado como backend, evitando fallbacks para X11 que podem impactar performance e integração. O Winit oferece controle preciso sobre essa seleção, mas requer configuração explícita em ambientes onde ambos os protocolos estão disponíveis.

Vamos criar um exemplo que força o uso do Wayland e verifica seu funcionamento. Comece com estas dependências no `Cargo.toml`:

```toml
[dependencies]
winit = { version = "0.28", features = ["wayland"] }
```

Este é o código mínimo para forçar o Wayland e verificar o backend ativo:

```rust
use winit::{
    event_loop::{EventLoop, ControlFlow},
    platform::wayland::EventLoopBuilderExtWayland,
    window::WindowBuilder,
};

fn main() {
    // Força a criação do event loop usando Wayland
    let event_loop = EventLoop::new_wayland()
        .expect("Falha ao criar event loop Wayland");

    // Cria a janela
    let _window = WindowBuilder::new()
        .with_title("Wayland Forçado")
        .build(&event_loop)
        .unwrap();

    println!("Backend ativo: Wayland");

    event_loop.run(move |_, _, control_flow| {
        *control_flow = ControlFlow::Wait;
    });
}
```

Se executado em um ambiente Wayland, você verá:
```
Backend ativo: Wayland
```

O erro comum é esquecer de habilitar o recurso "wayland" no Winit, resultando em:
```
thread 'main' panicked at 'Falha ao criar event loop Wayland: NotSupported(())'
```

Para diagnóstico avançado, exporte estas variáveis antes de executar:
```bash
export WAYLAND_DEBUG=1
export WINIT_UNIX_BACKEND=wayland
```

Agora vamos implementar uma verificação robusta do backend em tempo de execução:

```rust
use winit::platform::run_return::EventLoopExtRunReturn;

fn check_backend() {
    let mut event_loop = EventLoop::new_wayland();
    
    if event_loop.is_err() {
        event_loop = EventLoop::new();
    }

    let event_loop = event_loop.unwrap();
    
    match event_loop.is_wayland() {
        true => println!("Backend confirmado: Wayland"),
        false => println!("Backend alternativo em uso (provavelmente X11)"),
    }

    // Versão avançada com enum
    match event_loop.backend_id() {
        winit::platform::BackendId::Wayland => println!("Wayland ativo via enum"),
        _ => println!("Outro backend"),
    }
}
```

A diferença crítica entre `new_wayland()` e `new()`:
- `new_wayland()` falha se o Wayland não estiver disponível
- `new()` tenta Wayland primeiro, mas faz fallback para X11

Para aplicações que exigem Wayland, sempre use `new_wayland()` e trate o erro explicitamente:

```rust
let event_loop = match EventLoop::new_wayland() {
    Ok(el) => el,
    Err(e) => {
        eprintln!("Wayland é obrigatório: {:?}", e);
        std::process::exit(1);
    }
};
```

**Exercício**: Modifique o verificador de backend para exibir todas as informações disponíveis sobre o compositor Wayland em uso, incluindo nome e versão.

**Solução**:

```rust
use winit::platform::wayland::EventLoopBuilderExtWayland;

fn display_compositor_info() {
    let event_loop = EventLoop::new_wayland().unwrap();
    
    if let Some(display) = event_loop.wayland_display() {
        println!(
            "Compositor: {} (versão {})",
            display.compositor_name().unwrap_or("desconhecido"),
            display.compositor_version()
        );
    } else {
        println!("Informações do compositor não disponíveis");
    }
}
```