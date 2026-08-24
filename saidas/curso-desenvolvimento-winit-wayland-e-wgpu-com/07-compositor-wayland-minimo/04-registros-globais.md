## Registros Globais

No protocolo Wayland, tudo começa com os registros globais. Eles são o mecanismo pelo qual um cliente descobre quais interfaces estão disponíveis no servidor (compositor). Imagine que você entra em um shopping center e vê aqueles totens com o mapa da loja - os registros globais funcionam exatamente assim, anunciando quais "lojas" (interfaces) estão abertas e como acessá-las.

Vamos implementar um compositor que anuncia apenas as interfaces mais básicas. Começamos definindo os tipos essenciais:

```rust
use wayland_server::protocol::wl_display;
use wayland_server::{Display, Global};

struct CompositorState {
    display: Display,
    globals: Vec<Global<dyn Object>>,
}

impl CompositorState {
    fn new() -> Self {
        let display = Display::new().unwrap();
        let mut globals = Vec::new();

        // Registra a interface wl_compositor (versão 4)
        globals.push(
            display.create_global::<wl_compositor::WlCompositor, _>(4, |_| {})
        );

        // Registra a interface wl_shm (versão 1)
        globals.push(
            display.create_global::<wl_shm::WlShm, _>(1, |_| {})
        );

        Self { display, globals }
    }
}
```

Se você executar este código e conectar um cliente Wayland (como `weston-info`), verá:

```
interface: 'wl_compositor', version: 4, name: 1
interface: 'wl_shm', version: 1, name: 2
```

Mas espere - isso não funciona ainda! Falta o mais importante: o registro global `wl_display`, que é obrigatório e sempre tem o ID 1. Vamos corrigir:

```rust
impl CompositorState {
    fn new() -> Self {
        let display = Display::new().unwrap();
        let mut globals = Vec::new();

        // O wl_display é especial - criado automaticamente pelo Display
        // Agora adicionamos as outras interfaces globais
        globals.push(
            display.create_global::<wl_compositor::WlCompositor, _>(4, |_| {})
        );
        
        globals.push(
            display.create_global::<wl_shm::WlShm, _>(1, |_| {})
        );

        Self { display, globals }
    }
}
```

Agora sim, nosso compositor está anunciando corretamente suas capacidades. Mas por que essas interfaces específicas?

1. **wl_compositor**: Responsável por criar surfaces (superfícies onde o conteúdo é desenhado)
2. **wl_shm**: Permite compartilhamento de memória para buffers de pixels

Se esquecermos de registrar o `wl_compositor`, um cliente típico como o Firefox falhará com:

```
error: compositor didn't advertise wl_compositor
```

Cada registro global tem uma versão associada. A versão 4 do `wl_compositor` que usamos é a mais comum, mas poderíamos usar a versão 1 se quiséssemos compatibilidade máxima. Versões mais altas geralmente adicionam funcionalidades.

Vamos ver como um cliente realmente interage com esses registros. O fluxo é:

1. Cliente conecta ao socket do compositor
2. Compositor envia lista de globais disponíveis
3. Cliente escolhe quais globais usar e os vincula

Podemos simular isso em código de cliente:

```rust
use wayland_client::protocol::{wl_compositor, wl_shm};
use wayland_client::{Connection, QueueHandle};

fn main() {
    let conn = Connection::connect_to_env().unwrap();
    let display = conn.display();
    
    let mut event_queue = conn.new_event_queue();
    let qh = event_queue.handle();
    
    // Pega o registry global
    let registry = display.get_registry(&qh, ());
    
    // Espera pelo evento que lista os globais
    event_queue.roundtrip().unwrap();
    
    // Agora podemos criar os objetos globais
    let compositor = registry.bind::<wl_compositor::WlCompositor, _>(
        1, 4, qh, ()
    );
    
    let shm = registry.bind::<wl_shm::WlShm, _>(
        2, 1, qh, ()
    );
}
```

No lado do compositor, quando um cliente vincula um global, o callback que passamos para `create_global` é executado. Vamos melhorar nosso exemplo para lidar com essas ligações:

```rust
globals.push(
    display.create_global::<wl_compositor::WlCompositor, _>(4, |new_compositor| {
        println!("Novo compositor criado para cliente: {:?}", new_compositor);
    })
);
```

Um erro comum é tentar usar uma versão mais alta do que a implementada. Se registrarmos `wl_compositor` como versão 1 mas o cliente tentar usar a versão 4:

```
error: bind to global wl_compositor: version too high (has 1, wanted 4)
```

Para evitar isso, sempre registre versões compatíveis com seus clientes-alvo. A maioria dos clientes modernos espera pelo menos:

- wl_compositor: versão 4
- wl_shm: versão 1
- xdg_wm_base: versão 4 (que veremos depois)

**Exercício**: Modifique o `CompositorState` para registrar também `wl_seat` (versão 7) e `xdg_wm_base` (versão 4), imprimindo uma mensagem quando cada um for vinculado por um cliente.

**Solução**:

```rust
use wayland_server::protocol::{wl_seat, xdg_wm_base};

impl CompositorState {
    fn new() -> Self {
        let display = Display::new().unwrap();
        let mut globals = Vec::new();

        globals.push(
            display.create_global::<wl_compositor::WlCompositor, _>(4, |_| {
                println!("wl_compositor vinculado");
            })
        );
        
        globals.push(
            display.create_global::<wl_shm, _>(1, |_| {
                println!("wl_shm vinculado");
            })
        );
        
        globals.push(
            display.create_global::<wl_seat::WlSeat, _>(7, |_| {
                println!("wl_seat vinculado");
            })
        );
        
        globals.push(
            display.create_global::<xdg_wm_base::XdgWmBase, _>(4, |_| {
                println!("xdg_wm_base vinculado");
            })
        );

        Self { display, globals }
    }
}
```

Ao executar com um cliente como `weston-info`, você verá as mensagens de vinculação aparecerem conforme o cliente acessa cada interface global.