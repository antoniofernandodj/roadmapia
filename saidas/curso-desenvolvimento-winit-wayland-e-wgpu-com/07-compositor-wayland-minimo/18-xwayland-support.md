## XWayland Support

Quando você desenvolve um compositor Wayland, eventualmente encontrará aplicações que ainda dependem do X11. Esses programas não podem ser simplesmente ignorados — eles precisam funcionar, mesmo que de forma limitada. O XWayland é o componente que faz essa ponte, permitindo que aplicações X11 rodem em um ambiente Wayland. Mas como integrá-lo ao seu compositor?

A primeira etapa é entender o que o XWayland precisa do compositor. Ele opera como um cliente Wayland especial, criando surfaces e buffers da mesma forma que qualquer outro cliente. No entanto, ele também precisa de acesso a funcionalidades específicas do X11, como gerenciamento de janelas e eventos de input. Para isso, o XWayland utiliza uma série de protocolos extendidos que seu compositor deve implementar.

Vamos começar com a configuração básica. Você precisa garantir que o XWayland possa se conectar ao seu compositor. Isso é feito através de um socket UNIX, semelhante ao que você já usa para clientes Wayland normais. Aqui está um exemplo de como configurar o socket:

```rust
use std::os::unix::net::UnixListener;
use std::path::PathBuf;

fn create_xwayland_socket() -> Result<UnixListener, std::io::Error> {
    let socket_path = PathBuf::from("/tmp/.X11-unix/X0");
    if socket_path.exists() {
        std::fs::remove_file(&socket_path)?;
    }
    UnixListener::bind(&socket_path)
}
```

Se você tentar executar esse código sem permissões adequadas, receberá um erro como `PermissionDenied`. Isso ocorre porque o diretório `/tmp/.X11-unix` é protegido. Para resolver isso, execute seu compositor com permissões elevadas ou mude o caminho do socket para um local acessível.

Com o socket configurado, o próximo passo é aceitar conexões do XWayland. Aqui, você encontrará o primeiro desafio: o XWayland não usa o protocolo Wayland padrão. Em vez disso, ele utiliza uma versão modificada que inclui extensões específicas para compatibilidade com X11. Você precisará implementar essas extensões no seu compositor.

Uma das extensões mais importantes é o `xwayland_shell`. Ele permite que o XWayland crie janelas e gerencie estados como fullscreen e maximizado. Aqui está um exemplo básico de como implementar essa extensão:

```rust
use wayland_server::protocol::wl_surface::WlSurface;
use wayland_server::protocol::xwayland_shell::XwaylandShell;

struct XwaylandShellImpl;

impl XwaylandShell for XwaylandShellImpl {
    fn create_surface(&mut self, surface: WlSurface) {
        println!("XWayland surface created: {:?}", surface);
    }

    fn set_fullscreen(&mut self, surface: WlSurface) {
        println!("XWayland surface set to fullscreen: {:?}", surface);
    }
}
```

Se você esquecer de implementar métodos como `set_fullscreen`, o XWayland falhará silenciosamente. Isso ocorre porque o protocolo é negociado dinamicamente, e métodos não implementados são simplesmente ignorados. Para diagnosticar esses problemas, use ferramentas como `WAYLAND_DEBUG=1` para verificar quais mensagens estão sendo trocadas.

Outro ponto crucial é o tratamento de eventos de input. O XWayland espera que seu compositor forneça eventos de teclado e mouse de forma compatível com o X11. Isso significa que você precisa converter eventos Wayland para o formato X11. Aqui está um exemplo de como fazer isso:

```rust
fn convert_key_event(wayland_event: &wayland_server::protocol::wl_keyboard::Event) -> x11::KeyEvent {
    x11::KeyEvent {
        time: wayland_event.time,
        keycode: wayland_event.keycode,
        state: match wayland_event.state {
            wayland_server::protocol::wl_keyboard::KeyState::Pressed => x11::KeyState::Pressed,
            wayland_server::protocol::wl_keyboard::KeyState::Released => x11::KeyState::Released,
        },
    }
}
```

Se você não converter os eventos corretamente, aplicações XWayland podem não responder ao input ou se comportar de forma errática. Para evitar isso, teste com várias aplicações X11 e verifique se o input funciona conforme o esperado.

Finalmente, você precisa gerenciar o ciclo de vida das janelas XWayland. Quando uma janela é fechada, você deve liberar todos os recursos associados a ela, incluindo buffers e surfaces. Aqui está um exemplo de como fazer isso:

```rust
fn destroy_xwayland_surface(surface: WlSurface) {
    println!("Destroying XWayland surface: {:?}", surface);
    // Libere buffers e outros recursos aqui
}
```

Se você esquecer de liberar recursos, pode causar vazamentos de memória ou corrupção de estado. Para evitar isso, mantenha um registro de todas as surfaces XWayland e seus recursos associados.

Integrar o XWayland ao seu compositor é um desafio, mas é essencial para garantir compatibilidade com aplicações legadas. Ao implementar os protocolos extendidos e gerenciar corretamente o ciclo de vida das janelas, você pode oferecer suporte a aplicações X11 sem sacrificar a segurança e performance do seu compositor Wayland.