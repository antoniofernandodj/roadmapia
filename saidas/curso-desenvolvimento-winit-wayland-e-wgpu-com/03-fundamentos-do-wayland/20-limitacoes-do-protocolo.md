## Limitações do Protocolo

Um compositor Wayland recebe este erro ao tentar redimensionar uma janela:

```rust
[wayland-client] Protocol error 0: invalid object 42 (wl_region@42), object doesn't exist
```

O problema ocorre porque o protocolo não permite redimensionamento direto de janelas pelo cliente - o controle final é sempre do compositor. Esta é uma limitação intencional do modelo de segurança, mas traz desafios práticos.

**Problema 1: Controle restrito de janelas**  
No X11, um cliente podia fazer:

```c
XResizeWindow(display, window, 800, 600);  // Funciona imediatamente
```

Em Wayland, o fluxo é assíncrono e condicional:

```rust
let surface = compositor.create_surface();
let xdg_surface = xdg_wm_base.get_xdg_surface(&surface);
let toplevel = xdg_surface.get_toplevel();
toplevel.set_size(800, 600);  // Apenas uma SUGESTÃO

// O compositor pode ignorar ou modificar o pedido
```

O cliente só saberá o tamanho real quando receber o evento `Configure`:

```rust
impl Dispatch<xdg_toplevel::XdgToplevel> for MyState {
    fn configure(
        event: xdg_toplevel::Event::Configure,
        toplevel: &xdg_toplevel::XdgToplevel,
        data: &Self,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        println!("Tamanho real: {}x{}", event.new_size.0, event.new_size.1);
    }
}
```

**Problema 2: Screenshot restrito**  
A captura de tela requer um protocolo especial (`wlr-screencopy` ou `xdg-desktop-portal`), que pode ser negado:

```rust
let screencopy = globals.bind::<WlrScreencopyManagerV1, _, _>(1..=1, qh).unwrap();
let frame = screencopy.capture_output(1, output);  // Pode falhar com AccessDenied
```

Compare com X11:
```c
XImage *img = XGetImage(display, root, 0, 0, width, height, AllPlanes, ZPixmap);  // Sem permissões
```

**Problema 3: Input global limitado**  
Em Wayland, um cliente não pode:
- Monitorar teclas globais (atalhos do sistema)
- Capturar input de outras janelas
- Forçar foco em uma janela

A tentativa resulta em:
```
[wayland-client] Protocol error 1: permission_denied (wl_keyboard@7)
```

**Solução parcial: Protocolos adicionais**  
Algumas distros implementam extensões como:
- `input-method-unstable-v2` para IMEs
- `keyboard-shortcuts-inhibit-unstable-v1` para atalhos
- `xdg-desktop-portal` para screenshots

Mas a disponibilidade varia:

```rust
let has_screenshot = globals.iter().any(|g| g.interface == "wlr-screencopy-v1");
if !has_screenshot { /* Fallback para portal */ }
```

**Exercício**: Crie um client que tenta redimensionar para 400x300 e mostra o tamanho real recebido no Configure. Solução:

```rust
use wayland_client::{Connection, QueueHandle};
use wayland_protocols::xdg::shell::client::{xdg_surface, xdg_toplevel};

struct State { actual_size: (i32, i32) }

impl Dispatch<xdg_toplevel::XdgToplevel> for State {
    fn configure(/* ... */) {
        data.actual_size = (event.new_size.0, event.new_size.1);
    }
}

let toplevel = /* ... */;
toplevel.set_size(400, 300);
loop {
    if state.actual_size != (0, 0) {
        println!("Tamanho real: {:?}", state.actual_size);  // Ex: (392, 294)
        break;
    }
}
```

A saída mostra como o compositor ajustou o pedido inicial.