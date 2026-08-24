## Fallback para X11

Em sistemas Linux modernos, o Wayland é o protocolo preferencial para aplicações gráficas, mas nem todos os ambientes ou hardware oferecem suporte completo. Quando o Wayland não está disponível, uma aplicação robusta deve cair para o X11 sem interromper a experiência do usuário. Veja como implementar isso na prática.

### O problema real

Se você tentar criar uma janela Wayland em um sistema sem suporte, o Winit emitirá este erro:

```rust
let event_loop = EventLoop::new_wayland();
// thread 'main' panicked at 'Failed to create Wayland event loop:
// No supported backend was available'
```

Isso quebra a aplicação completamente. Precisamos de uma estratégia que:

1. Tente Wayland primeiro (performance e integração superiores)
2. Caia para X11 automaticamente se necessário
3. Mantenha a mesma interface para o código principal

### Implementação básica

Comece adicionando a verificação de backend no `Cargo.toml`:

```toml
[dependencies]
winit = { version = "0.29", features = ["wayland", "x11"] }
```

Agora, a função de inicialização segura:

```rust
use winit::event_loop::EventLoop;
use winit::platform::unix::{EventLoopExtUnix, WindowExtUnix};

fn create_event_loop() -> EventLoop<()> {
    match EventLoop::new_wayland() {
        Ok(el) => {
            println!("Running on Wayland");
            el
        },
        Err(_) => {
            println!("Falling back to X11");
            EventLoop::new_x11()
                .expect("Failed to create X11 event loop")
        }
    }
}
```

### Diferenças críticas entre backends

Ao implementar o fallback, você encontrará estas divergências:

1. **Identificação de janelas**:
   ```rust
   // Wayland
   let surface_id = window.wayland_surface().unwrap().id();
   // X11
   let x11_window = window.xlib_window().unwrap();
   ```

2. **Eventos de redimensionamento**:
   - Wayland: `ScaleFactorChanged` é mais preciso
   - X11: Pode requerer polling manual do DPI

3. **Decorações client-side**:
   ```rust
   window.set_decorations(false); // Comportamento diferente no X11
   ```

### Exemplo completo com tratamento de eventos

Este código funciona em ambos os backends:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::EventLoop,
    window::WindowBuilder,
};

fn main() {
    let event_loop = create_event_loop();
    let window = WindowBuilder::new()
        .with_title("Fallback Demo")
        .build(&event_loop)
        .unwrap();

    println!(
        "Backend ativo: {:?}",
        event_loop.is_wayland()
    );

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

Saída esperada (Wayland disponível):
```
Running on Wayland
Backend ativo: true
```

Saída esperada (somente X11):
```
Falling back to X11
Backend ativo: false
```

### Limitações do fallback

1. **Feature parity**: Algumas funcionalidades Wayland não têm equivalente direto:
   - Protocolos extendidos (ex: `zwlr_layer_shell_v1`)
   - Controle preciso de sincronização (`wp_tearing_control_v1`)

2. **DPI handling**: X11 pode reportar valores incorretos em multi-monitor

3. **Performance**: O caminho de renderização X11 é menos otimizado

### Solução para features ausentes

Para funcionalidades críticas, você pode verificar o backend em runtime:

```rust
fn set_window_blur(window: &Window, enable: bool) {
    if window.is_wayland() {
        // Implementação Wayland com protocolos extendidos
        if let Some(surface) = window.wayland_surface() {
            // Configura blur via zwlr_layer_shell
        }
    } else {
        // Fallback X11 (pode ser vazio ou implementar via XRender)
        eprintln!("Blur effect not available on X11");
    }
}
```

### Exercício prático

**Problema**: Modifique o exemplo anterior para:
1. Exibir o tamanho físico da janela após criação
2. Atualizar sempre que o tamanho mudar
3. Funcionar em ambos os backends

**Solução**:

```rust
event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Wait;

    match event {
        Event::WindowEvent {
            event: WindowEvent::CloseRequested,
            ..
        } => *control_flow = ControlFlow::Exit,
        Event::WindowEvent {
            event: WindowEvent::Resized(size),
            ..
        } => {
            println!(
                "Tamanho físico: {}x{}",
                size.width,
                size.height
            );
        },
        Event::RedrawRequested(_) => {
            println!(
                "Tamanho atual: {:?}",
                window.inner_size()
            );
        },
        _ => (),
    }
});
```