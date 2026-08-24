## Protocolos Extendidos

Um compositor Wayland básico consegue exibir janelas e responder a eventos de input, mas aplicações reais precisam de funcionalidades específicas: arrastar arquivos, compartilhar buffers DMA, sincronizar frames com VSync. Essas capacidades não estão no protocolo core - elas vêm como *protocolos extendidos*, negociados dinamicamente entre cliente e servidor.

O problema surge quando um cliente solicita um protocolo que seu compositor não implementa. Veja o que acontece ao tentar usar `zwp_linux_dmabuf_v1` sem suporte:

```rust
let dmabuf = globals.bind::<ZwpLinuxDmabufV1>(wl_seat.version(), &qh, ());
// Erro no cliente:
// [wayland-client] Global zwp_linux_dmabuf_v1 not found
```

A solução não é implementar todos os protocolos (impraticável), mas sim:
1. Registrar interesse nos protocolos suportados
2. Responder adequadamente quando clientes solicitarem extensões não disponíveis

Comece declarando os protocolos no registro global:

```rust
// No handler do wl_display:
display.global_add(
    &qh,
    WL_SHM_INTERFACE,
    WL_SHM_VERSION,
    |_| {}, // Implementação vazia
);
```

Agora, quando um cliente chamar `wl_registry::bind` para `wl_shm`, o compositor será notificado. Para protocolos não suportados, o cliente simplesmente não os verá na lista de globais.

Mas e se precisarmos de uma resposta mais sofisticada? Implemente um filtro de globais:

```rust
struct ProtocolFilter {
    supported: Vec<&'static str>,
}

impl GlobalDispatch<wl_shm::WlShm, ()> for ProtocolFilter {
    fn bind(
        _: &mut Self,
        _: &DisplayHandle,
        _: &Client,
        _: New<wl_shm::WlShm>,
        _: &QueueHandle<Self>,
        _: &(),
    ) {
        println!("Client bound to wl_shm");
    }
}

// Uso:
let filter = ProtocolFilter {
    supported: vec![WL_SHM_INTERFACE, WL_COMPOSITOR_INTERFACE],
};
```

Para testar na prática, vamos criar um cliente que tenta usar três protocolos - dois suportados e um não:

```rust
let conn = Connection::connect_to_env().unwrap();
let display = conn.display();
let mut event_queue = conn.new_event_queue();
let qh = event_queue.handle();

// Protocolos que o cliente tentará usar
let globals = registry.bind::<wl_compositor::WlCompositor>(1, &qh, ()); // OK
let shm = registry.bind::<wl_shm::WlShm>(1, &qh, ()); // OK
let xdg_decoration = registry.bind::<zxdg_decoration_manager_v1::ZxdgDecorationManagerV1>(1, &qh, ()); // Falha silenciosa
```

A saída do compositor mostra:
```
Client bound to wl_compositor
Client bound to wl_shm
```

Sem erros - o cliente simplesmente não recebe o handle para o protocolo não suportado. Isso é intencional no design do Wayland: extensões são opcionais por definição.

Para protocolos complexos como `xdg_decoration` (decorações de janela client-side), você pode querer implementar um subconjunto mínimo:

```rust
impl Dispatch<ZxdgDecorationManagerV1, ()> for ProtocolFilter {
    fn request(
        _: &mut Self,
        manager: &ZxdgDecorationManagerV1,
        request: zxdg_decoration_manager_v1::Request,
        _: &(),
        _: &DisplayHandle,
        _: &QueueHandle<Self>,
    ) {
        match request {
            Request::Destroy => manager.destroy(),
            Request::GetToplevelDecoration { id, toplevel } => {
                println!("Client requested decoration mode");
                id.configure(2); // Mode: Client-side
            }
            _ => unreachable!(),
        }
    }
}
```

Erro comum: esquecer de verificar versões. Cada protocolo tem múltiplas versões, e clientes podem pedir versões diferentes:

```rust
// Cliente pede versão 3 do protocolo (não suportada)
let dmabuf = globals.bind::<ZwpLinuxDmabufV1>(3, &qh, ());

// No compositor:
display.global_add(
    &qh,
    ZWP_LINUX_DMABUF_INTERFACE,
    2, // Versão máxima suportada
    |_| {},
);

// Resultado:
// [wayland-client] Version mismatch for zwp_linux_dmabuf_v1:
//  client wants 3, server provides 2
```

**Exercício**: Implemente um handler para `wp_viewporter` (protocolo para redimensionamento client-side) que:
1. Aceita requests `GetViewport`
2. Armazena viewports em um HashMap por surface
3. Responde a `SetDestination` com um erro se as dimensões forem maiores que 4096x4096

**Solução**:

```rust
use std::collections::HashMap;
use wayland_server::protocol::wp_viewporter::{self, WpViewporter};

struct ViewportState {
    viewports: HashMap<wl_surface::WlSurface, (i32, i32)>,
}

impl Dispatch<WpViewporter, ()> for ViewportState {
    fn request(
        &mut self,
        viewporter: &WpViewporter,
        request: wp_viewporter::Request,
        _: &(),
        _: &DisplayHandle,
        _: &QueueHandle<Self>,
    ) {
        match request {
            Request::Destroy => viewporter.destroy(),
            Request::GetViewport { id, surface } => {
                self.viewports.insert(surface.clone(), (0, 0));
                id.done(); // Viewport criado
            }
            _ => unreachable!(),
        }
    }
}

impl Dispatch<wp_viewporter::WpViewport, ()> for ViewportState {
    fn request(
        &mut self,
        viewport: &wp_viewporter::WpViewport,
        request: wp_viewporter::Request,
        _: &(),
        _: &DisplayHandle,
        _: &QueueHandle<Self>,
    ) {
        if let Request::SetDestination { width, height } = request {
            if width > 4096 || height > 4096 {
                viewport.failed("Dimensions too large");
            } else {
                println!("Viewport set to {}x{}", width, height);
                viewport.done();
            }
        }
    }
}
```