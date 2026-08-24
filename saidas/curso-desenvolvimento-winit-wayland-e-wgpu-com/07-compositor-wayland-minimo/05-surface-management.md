## Surface Management

No coração de um compositor Wayland está o gerenciamento de surfaces - as unidades básicas de conteúdo visual que os clientes criam para exibir suas interfaces. Uma surface representa uma região retangular de pixels que pode ser renderizada, movida, redimensionada e compostada. Vamos implementar o gerenciamento mínimo de surfaces sem composição ainda, apenas mantendo o estado interno.

O problema começa quando um cliente cria uma surface através do protocolo `wl_compositor`. Nosso compositor precisa:

1. Armazenar o estado de cada surface criada
2. Responder às solicitações de commit (quando o cliente finaliza as alterações)
3. Manter a hierarquia de surfaces (uma surface pode ser filha de outra)

Vamos começar definindo nossa estrutura de dados para surfaces:

```rust
use wayland_server::protocol::{wl_surface, wl_compositor};
use wayland_server::{Display, Global, Client, NewResource};
use std::sync::{Arc, Mutex};
use std::collections::HashMap;

#[derive(Debug)]
struct SurfaceState {
    id: u32,
    width: i32,
    height: i32,
    buffer: Option<wl_buffer::WlBuffer>,
    // Outros campos como transform, scale, etc.
}

struct CompositorState {
    surfaces: Mutex<HashMap<u32, Arc<Mutex<SurfaceState>>>>,
    next_id: Mutex<u32>,
}

impl CompositorState {
    fn new() -> Self {
        CompositorState {
            surfaces: Mutex::new(HashMap::new()),
            next_id: Mutex::new(1),
        }
    }

    fn create_surface(&self) -> u32 {
        let mut next_id = self.next_id.lock().unwrap();
        let id = *next_id;
        *next_id += 1;
        
        let surface = Arc::new(Mutex::new(SurfaceState {
            id,
            width: 0,
            height: 0,
            buffer: None,
        }));
        
        self.surfaces.lock().unwrap().insert(id, surface);
        id
    }
}
```

Agora vamos implementar o handler para o interface `wl_compositor`:

```rust
use wayland_server::{Dispatch, DisplayHandle};

impl<D> Dispatch<wl_compositor::WlCompositor, (), D> for CompositorState
where
    D: Dispatch<wl_compositor::WlCompositor, ()> + AsRef<CompositorState>,
{
    fn request(
        _state: &mut D,
        _client: &Client,
        _resource: &wl_compositor::WlCompositor,
        request: wl_compositor::Request,
        _data: &(),
        _dhandle: &DisplayHandle,
        _data_init: &mut wayland_server::DataInit<'_, D>,
    ) {
        match request {
            wl_compositor::Request::CreateSurface { id } => {
                let state = _state.as_ref();
                let surface_id = state.create_surface();
                println!("Surface {} created", surface_id);
            }
            wl_compositor::Request::CreateRegion { .. } => {
                // Implementar quando necessário
            }
            _ => unreachable!(),
        }
    }
}
```

Para testar, vamos registrar o global `wl_compositor`:

```rust
fn main() {
    let display = Display::new().unwrap();
    let state = Arc::new(CompositorState::new());

    // Registrar a interface wl_compositor
    let _global = display.create_global::<D, wl_compositor::WlCompositor, _>(
        4, // versão do protocolo
        state.clone(),
    );

    println!("Compositor running...");
    loop {
        display.dispatch(&state, None).unwrap();
    }
}
```

Quando um cliente se conecta e cria uma surface, você verá no terminal:
```
Compositor running...
Surface 1 created
```

O erro mais comum aqui é esquecer de incrementar o `next_id`, causando colisões de IDs. Se isso acontecer, o cliente receberá um protocolo error:
```
error@1: invalid object id 1 (already exists)
```

Para implementar o commit de surfaces, precisamos estender nosso `SurfaceState` e adicionar o handler para `wl_surface`:

```rust
impl<D> Dispatch<wl_surface::WlSurface, Arc<Mutex<SurfaceState>>, D> for CompositorState
where
    D: Dispatch<wl_surface::WlSurface, Arc<Mutex<SurfaceState>>> + AsRef<CompositorState>,
{
    fn request(
        _state: &mut D,
        _client: &Client,
        _resource: &wl_surface::WlSurface,
        request: wl_surface::Request,
        data: &Arc<Mutex<SurfaceState>>,
        _dhandle: &DisplayHandle,
        _data_init: &mut wayland_server::DataInit<'_, D>,
    ) {
        let mut surface = data.lock().unwrap();
        match request {
            wl_surface::Request::Attach { buffer, x, y } => {
                surface.buffer = buffer;
                println!("Buffer attached to surface {}", surface.id);
            }
            wl_surface::Request::Commit => {
                println!("Surface {} committed ({}x{})", 
                    surface.id, surface.width, surface.height);
                // Aqui seria onde a composição aconteceria
            }
            wl_surface::Request::Damage { x, y, width, height } => {
                println!("Surface {} damaged: {}x{} at {},{}", 
                    surface.id, width, height, x, y);
            }
            _ => {}
        }
    }
}
```

Agora, quando um cliente anexa um buffer e faz commit, veremos:
```
Buffer attached to surface 1
Surface 1 committed (800x600)
```

**Exercício**: Implemente o tratamento para `wl_surface::Request::SetBufferScale` que atualiza a escala da surface. A solução deve armazenar o fator de escala no `SurfaceState` e aplicar ao tamanho quando o commit for feito.

**Solução**:
```rust
#[derive(Debug)]
struct SurfaceState {
    id: u32,
    width: i32,
    height: i32,
    buffer: Option<wl_buffer::WlBuffer>,
    scale: i32,  // Novo campo
}

// No handler de wl_surface::Request:
wl_surface::Request::SetBufferScale { scale } => {
    surface.scale = scale;
    println!("Surface {} scale set to {}", surface.id, scale);
}

// Modificar o commit para considerar a escala:
wl_surface::Request::Commit => {
    let scaled_width = surface.width / surface.scale.max(1);
    let scaled_height = surface.height / surface.scale.max(1);
    println!("Surface {} committed ({}x{} @ {}x)", 
        surface.id, scaled_width, scaled_height, surface.scale);
}
```