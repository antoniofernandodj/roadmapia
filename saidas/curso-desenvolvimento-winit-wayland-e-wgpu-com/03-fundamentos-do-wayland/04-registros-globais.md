## Registros Globais

No protocolo Wayland, os *registros globais* são o ponto de entrada para descobrir quais recursos o servidor (compositor) oferece. Imagine que você acabou de se conectar ao socket Wayland - como saber se o servidor suporta criação de surfaces, input devices ou compartilhamento de memória? Os globals resolvem isso.

**Problema típico**: Tentar criar uma surface sem verificar se o compositor suporta a interface `wl_compositor` resulta em:

```rust
thread 'main' panicked at 'No global interface wl_compositor v4 found'
```

O mecanismo funciona assim:
1. O servidor anuncia todos os globals disponíveis durante a conexão inicial
2. O cliente pode solicitar esses globals usando `GlobalManager`
3. Cada global tem:
   - Nome da interface (ex: `wl_compositor`)
   - Número da versão (ex: `4`)
   - Um ID único

Vamos ver na prática como listar todos os globals disponíveis:

```rust
use wayland_client::{Display, GlobalManager};

fn main() {
    let display = Display::connect_to_env().unwrap();
    let mut event_queue = display.create_event_queue();
    let attached_display = display.attach(event_queue.token());
    
    let globals = GlobalManager::new(&attached_display);
    
    // Sincroniza com o servidor para receber todos os globals
    event_queue.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();
    
    println!("Globals disponíveis:");
    for global in globals.list() {
        println!(
            "Interface: {} v{}, Name: {}",
            global.interface,
            global.version,
            global.name
        );
    }
}
```

Saída típica (varia por compositor):
```
Interface: wl_compositor v4, Name: 1
Interface: wl_shm v1, Name: 2  
Interface: wl_seat v7, Name: 3
Interface: xdg_wm_base v4, Name: 4
```

**Erro comum 1**: Esquecer o `sync_roundtrip` faz com que a lista de globals fique vazia. A sincronização é necessária porque os anúncios são assíncronos.

**Erro comum 2**: Tentar usar uma versão não suportada. Se você pedir `wl_compositor` v5 mas o servidor só tem v4:

```rust
let compositor = globals.instantiate_exact::<WlCompositor>(5).unwrap();
// thread 'main' panicked at 'No global interface wl_compositor v5 found'
```

A forma correta é verificar a versão disponível antes de usar:

```rust
let compositor_version = globals.interface_supported_version("wl_compositor").unwrap();
let compositor = if compositor_version >= 4 {
    globals.instantiate_exact::<WlCompositor>(4).unwrap()
} else {
    panic!("Versão muito antiga do wl_compositor");
};
```

**Dica de performance**: Se você só precisa de um global específico, use `bind` em vez de listar todos:

```rust
let seat = globals.bind::<WlSeat>(7, |seat| {
    // Callback quando o seat estiver pronto
}).unwrap();
```

**Exercício**: Modifique o código de listagem para mostrar apenas globals que implementam buffers compartilhados (procure por `wl_shm`). Depois, crie uma função que retorne a versão mais alta disponível de uma interface específica.

**Solução comentada**:

```rust
fn highest_version(globals: &GlobalManager, interface: &str) -> Option<u32> {
    globals.list()
        .iter()
        .filter(|g| g.interface == interface)
        .map(|g| g.version)
        .max()
}

fn main() {
    // ... (código anterior de conexão)
    
    println!("Versão mais alta de wl_shm: {:?}",
        highest_version(&globals, "wl_shm"));
    
    // Versão segura para wl_seat:
    match highest_version(&globals, "wl_seat") {
        Some(v) if v >= 7 => println!("Suporta touch events"),
        Some(v) if v >= 5 => println!("Suporta pointer events"),
        Some(_) => println!("Versão muito antiga"),
        None => println!("wl_seat não disponível"),
    }
}
```