## Objetos e Interfaces Wayland

Wayland organiza sua comunicação em torno de objetos virtuais que representam recursos do sistema. Cada objeto implementa uma ou mais interfaces que definem os métodos (requests) que podem ser chamados nele e os eventos que ele pode emitir. Vamos explorar isso na prática com um exemplo concreto.

Considere o cenário onde precisamos criar uma surface (área de desenho) e atribuir um papel (role) a ela, como uma janela comum. Primeiro, precisamos obter um objeto `wl_compositor` do registry:

```rust
use wayland_client::{protocol::wl_compositor, Display, GlobalManager};

let display = Display::connect_to_env().unwrap();
let mut event_queue = display.create_event_queue();
let attached_display = display.attach(event_queue.token());
let globals = GlobalManager::new(&attached_display);

// Obtendo o compositor
let compositor = globals.instantiate_exact::<wl_compositor::WlCompositor>(1).unwrap();
```

Este código cria uma conexão com o servidor Wayland, configura uma fila de eventos e obtém o objeto compositor global. A versão (1 neste caso) deve corresponder à versão suportada pelo servidor.

Cada objeto Wayland tem:
1. Um ID numérico único
2. Uma ou mais interfaces implementadas
3. Estado interno mantido pelo servidor

Vamos criar uma surface:

```rust
use wayland_client::protocol::wl_surface;

let surface = compositor.create_surface();
```

Se tentarmos usar esta surface imediatamente, encontraremos um erro comum:

```rust
surface.commit(); // Erro: Surface sem buffer atribuído
```

A mensagem de erro seria:
```
wayland error: Protocol error: wl_surface@2: error 0: no buffer attached since last commit
```

Isso ocorre porque uma surface recém-criada está vazia. Precisamos primeiro anexar um buffer e definir uma região de dano:

```rust
use wayland_client::protocol::wl_buffer;

// Supondo que temos um buffer criado via shared memory
let buffer: wl_buffer::WlBuffer = create_test_buffer(&attached_display); 

surface.attach(Some(&buffer), 0, 0);
surface.damage(0, 0, 320, 240); // Região alterada
surface.commit();
```

A hierarquia de objetos no Wayland segue um padrão de criação onde objetos pais são responsáveis por seus filhos:

```
wl_display (root)
├── wl_registry
│   ├── wl_compositor
│   │   └── wl_surface
│   ├── wl_shm
│   │   └── wl_buffer
│   └── wl_seat
│       └── wl_pointer
```

Interfaces no Wayland são definidas através de traits em Rust. Por exemplo, a interface `wl_surface` inclui:

```rust
pub trait WlSurface {
    fn destroy(&self);
    fn attach(&self, buffer: Option<&WlBuffer>, x: i32, y: i32);
    fn damage(&self, x: i32, y: i32, width: i32, height: i32);
    // ... outros métodos
}
```

Quando o servidor precisa notificar o cliente sobre eventos, ele invoca callbacks associados aos objetos. Veja como registrar um callback para erros:

```rust
use wayland_client::{protocol::wl_display, Proxy};

let display_proxy: wl_display::WlDisplay = attached_display.clone().into();
display_proxy.on_error(move |_, object_id, code, message| {
    eprintln!(
        "Wayland error on object {}: {} (code {})",
        object_id, message, code
    );
});
```

Um erro comum é tentar usar um objeto depois de destruí-lo:

```rust
surface.destroy();
surface.commit(); // PANIC: use of destroyed wayland object
```

O erro resultante é claro:
```
thread 'main' panicked at 'Attempted to use destroyed wayland object'
```

Para evitar isso, sempre verifique se o objeto ainda existe ou use o padrão de substituição:

```rust
let new_surface = compositor.create_surface();
std::mem::replace(&mut surface, new_surface);
```

**Exercício**: Crie uma aplicação que:
1. Conecta ao servidor Wayland
2. Obtém o compositor global
3. Cria duas surfaces
4. Destrói a primeira surface corretamente
5. Atribui um buffer simples à segunda surface

Solução comentada:

```rust
use wayland_client::{Display, GlobalManager};
use wayland_client::protocol::{wl_compositor, wl_surface};

fn main() {
    // 1. Conexão inicial
    let display = Display::connect_to_env().unwrap();
    let mut event_queue = display.create_event_queue();
    let attached_display = display.attach(event_queue.token());
    
    // 2. Obter compositor
    let globals = GlobalManager::new(&attached_display);
    let compositor = globals.instantiate_exact::<wl_compositor::WlCompositor>(1).unwrap();
    
    // 3. Criar surfaces
    let surface1 = compositor.create_surface();
    let surface2 = compositor.create_surface();
    
    // 4. Destruir surface1 corretamente
    surface1.destroy();
    
    // 5. Atribuir buffer (simulado) à surface2
    let buffer = create_test_buffer(&attached_display);
    surface2.attach(Some(&buffer), 0, 0);
    surface2.damage(0, 0, 320, 240);
    surface2.commit();
    
    // Processar eventos
    event_queue.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();
}

fn create_test_buffer(display: &wayland_client::Display) -> wayland_client::protocol::wl_buffer::WlBuffer {
    // Implementação simplificada para exemplo
    unimplemented!()
}
```