## Protocolos Extendidos

Quando criamos uma janela básica com Winit no Wayland, estamos usando apenas o protocolo core (xdg-shell). Mas e se precisarmos de funcionalidades específicas como arrastar arquivos, notificações do sistema ou controle de energia? Esses recursos estão em protocolos extendidos que precisamos ativar manualmente.

Vamos começar com um exemplo concreto: queremos que nossa janela exiba uma notificação quando minimizada, usando o protocolo `xdg-decoration`. Primeiro, verificamos se o protocolo está disponível:

```rust
use winit::platform::wayland::WindowExtWayland;

let window = WindowBuilder::new()
    .with_title("Protocolos Extendidos")
    .build(&event_loop)
    .unwrap();

let wayland_display = window.wayland_display().unwrap();
let has_xdg_decoration = unsafe {
    wayland_client::protocol::wl_registry::WlRegistry::from_interface(
        wayland_display.interface().clone()
    ).bind::<wayland_protocols::xdg::decoration::zv1::client::zxdg_decoration_manager_v1::ZxdgDecorationManagerV1>(
        1, 1
    ).is_ok()
};

println!("Suporte a xdg-decoration: {}", has_xdg_decoration);
```

Se executarmos isso sem o protocolo ativo, veremos o erro típico:

```
error: Protocol 'zxdg_decoration_manager_v1' not available
```

Para corrigir, precisamos criar um contexto Wayland explícito antes da janela. Veja como ativar múltiplos protocolos extendidos:

```rust
use wayland_client::{Display, EventQueue};
use wayland_protocols::xdg::decoration::zv1::client::zxdg_decoration_manager_v1::ZxdgDecorationManagerV1;

let display = Display::connect_to_env().unwrap();
let mut event_queue = display.create_event_queue();
let registry = display.get_registry(&event_queue.handle(), ());

// Solicita os protocolos extendidos
let mut globals = wayland_client::globals::GlobalList::new();
event_queue.sync_roundtrip(&mut globals).unwrap();

let decoration_manager = globals.bind::<ZxdgDecorationManagerV1, _>(
    &event_queue.handle(),
    1..=1,
    ()
).expect("Compositor não suporta xdg-decoration");

// Agora podemos criar a janela Winit com esses protocolos
let window = WindowBuilder::new()
    .with_title("Com Decoração Client-side")
    .build(&event_loop)
    .unwrap();
```

Um caso comum é querer arrastar arquivos para nossa aplicação. O protocolo `wl_data_device_manager` é essencial para isso:

```rust
use wayland_protocols::wlr::unstable::data_control::v1::client::zwlr_data_control_manager_v1::ZwlrDataControlManagerV1;

let data_control = globals.bind::<ZwlrDataControlManagerV1, _>(
    &event_queue.handle(),
    1..=1,
    ()
);

match data_control {
    Ok(_) => println!("Drag-and-drop habilitado"),
    Err(_) => eprintln!("wl_data_device_manager não disponível"),
}
```

Quando combinamos vários protocolos, precisamos gerenciar seus ciclos de vida. Veja um exemplo completo que ativa três protocolos populares:

```rust
use wayland_client::globals::BindError;

struct WaylandExtensions {
    decoration: Option<ZxdgDecorationManagerV1>,
    data_control: Option<ZwlrDataControlManagerV1>,
    idle_inhibit: Option<zwp_idle_inhibit_manager_v1::ZwpIdleInhibitManagerV1>,
}

fn setup_extensions(globals: &GlobalList, queue: &EventQueue) -> Result<WaylandExtensions, BindError> {
    Ok(WaylandExtensions {
        decoration: globals.bind(queue.handle(), 1..=1, ()).ok(),
        data_control: globals.bind(queue.handle(), 1..=1, ()).ok(),
        idle_inhibit: globals.bind(queue.handle(), 1..=1, ()).ok(),
    })
}

let extensions = setup_extensions(&globals, &event_queue).unwrap();

if extensions.decoration.is_none() {
    eprintln!("AVISO: Decorações client-side não disponíveis");
}
```

A integração com Winit requer que passemos esses protocolos para o contexto da janela. O método `wayland_window_init` permite isso:

```rust
use winit::platform::wayland::EventLoopBuilderExtWayland;

let event_loop = EventLoopBuilder::new()
    .with_wayland()
    .build();

let window = WindowBuilder::new()
    .with_wayland_extensions(|ext| {
        ext.add_extension::<ZxdgDecorationManagerV1>()
           .add_extension::<ZwlrDataControlManagerV1>()
    })
    .build(&event_loop)
    .unwrap();
```

Um erro comum é tentar usar um protocolo sem verificar sua versão. Cada protocolo tem versões compatíveis:

```rust
let required = globals.required_version("zxdg_decoration_manager_v1");
println!("Versão disponível: {:?}", required);
// Saída: Ok(1) se suportado
```

Para protocolos complexos como `zwp_pointer_constraints_v1` (para travar o ponteiro), precisamos de tratamento especial:

```rust
use wayland_protocols::unstable::pointer_constraints::v1::client::zwp_pointer_constraints_v1::ZwpPointerConstraintsV1;

let constraints = globals.bind::<ZwpPointerConstraintsV1, _>(
    &event_queue.handle(),
    1..=1,
    ()
);

if let Ok(constraints) = constraints {
    let surface = window.wayland_surface().unwrap();
    let pointer = // obtém o wl_pointer do evento
    let locked = constraints.lock_pointer(
        &surface,
        pointer,
        None,
        zwp_pointer_constraints_v1::Lifetime::Persistent
    );
}
```

Exercício: Crie uma aplicação que verifica a disponibilidade dos protocolos `xdg-decoration`, `wl_data_device_manager` e `zwp_idle_inhibit_manager_v1`. Para cada um disponível, imprima sua versão máxima suportada.

Solução comentada:

```rust
use wayland_client::{Display, EventQueue, globals::GlobalList};

fn main() {
    let display = Display::connect_to_env().unwrap();
    let mut event_queue = display.create_event_queue();
    let globals = GlobalList::new();
    event_queue.sync_roundtrip(&mut globals).unwrap();

    check_protocol(&globals, "zxdg_decoration_manager_v1");
    check_protocol(&globals, "wl_data_device_manager");
    check_protocol(&globals, "zwp_idle_inhibit_manager_v1");
}

fn check_protocol(globals: &GlobalList, name: &str) {
    match globals.required_version(name) {
        Ok(ver) => println!("{}: versão {}", name, ver),
        Err(_) => println!("{}: não disponível", name),
    }
}
```

Este código verifica cada protocolo e mostra sua versão máxima. A saída típica em um sistema moderno seria:

```
zxdg_decoration_manager_v1: versão 1
wl_data_device_manager: versão 3
zwp_idle_inhibit_manager_v1: versão 1
```