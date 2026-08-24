## Shell Protocol

Um compositor Wayland precisa definir como as janelas se comportam: como são movidas, redimensionadas, minimizadas ou maximizadas. O protocolo base do Wayland não especifica isso - ele apenas oferece `wl_surface` para desenhar pixels. É o **shell protocol** que define essas regras, e o mais comum é o `xdg-shell`.

### O Problema da Janela Básica

Suponha que você já tenha um compositor que renderiza surfaces:

```rust
struct Compositor {
    surfaces: HashMap<u32, SurfaceState>, // ID -> Surface
}
```

Se um cliente criar uma surface e anexar um buffer, ela aparecerá na tela, mas:
- Não terá bordas
- Não poderá ser movida
- Não responderá a ações de minimizar/fechar

### Implementando xdg_surface

Primeiro, registre a interface global no handshake:

```rust
// No setup do display:
display.global_create(
    1, // version
    wl_shell::WlShell::interface(),
    |shell, _| {
        // Callback quando cliente cria shell surface
        shell.implement(|shell, request, _| match request {
            wl_shell::Request::GetShellSurface { id, surface } => {
                let xdg_surface = XdgSurface::new(id, surface);
                // Armazene em seu estado
            }
            _ => {}
        });
    },
);
```

A estrutura central é `XdgSurface`, que decora uma `wl_surface`:

```rust
struct XdgSurface {
    surface: wl_surface::WlSurface,
    role: Option<SurfaceRole>, // "window", "popup", etc.
    geometry: Rectangle,
    states: Vec<XdgState>,
}

enum SurfaceRole {
    TopLevel(XdgToplevel),
    Popup,
    // ...
}
```

### Toplevel: Janelas Principais

Quando o cliente quer uma janela normal:

```rust
impl XdgSurface {
    fn configure(&mut self) {
        let states = match self.role {
            Some(SurfaceRole::TopLevel(ref toplevel)) => {
                vec![
                    XdgState::Activated,
                    XdgState::Maximized, // Se aplicável
                ]
            }
            // ...
        };
        
        // Envia evento para o cliente
        self.surface.configure(serial, states);
    }
}
```

O cliente responderá com um novo buffer contendo a janela configurada.

### Gerenciando Estados

Os estados mais comuns são:

```rust
#[derive(Debug, Clone, Copy)]
enum XdgState {
    Maximized,
    Fullscreen,
    Resizing,
    Activated,
    // ...
}
```

Quando o usuário maximiza uma janela:

1. O compositor envia `configure` com `Maximized`
2. O cliente redesenha no tamanho maximizado
3. O compositor reposiciona a surface

### Movimento e Redimensionamento

Para implementar arrastar:

```rust
// No handler do pointer:
if pointer.button == BTN_LEFT && surface.is_top_level() {
    let grab = MoveGrab {
        surface,
        start_x,
        start_y,
    };
    self.set_pointer_grab(grab);
}
```

O erro comum aqui é esquecer de verificar `surface.role`:

```
thread 'main' panicked at 'called `Option::unwrap()` on a `None` value'
```

A solução é sempre verificar:

```rust
if let Some(SurfaceRole::TopLevel(_)) = surface.role {
    // Operação segura
}
```

### Exemplo Completo: Minimizar

```rust
impl Compositor {
    fn minimize_window(&mut self, surface_id: u32) {
        if let Some(surface) = self.surfaces.get_mut(&surface_id) {
            if let Some(XdgSurface { role, .. }) = &mut surface.xdg_surface {
                if let SurfaceRole::TopLevel(toplevel) = role {
                    toplevel.states.remove(XdgState::Activated);
                    surface.visible = false;
                    self.send_configure(surface_id);
                }
            }
        }
    }
}
```

### Exercício: Implementar Maximize

**Problema**: Complete o código para alternar entre maximizado e normal:

```rust
fn toggle_maximize(&mut self, surface_id: u32) {
    // Sua implementação aqui
}
```

**Solução**:

```rust
fn toggle_maximize(&mut self, surface_id: u32) {
    if let Some(surface) = self.surfaces.get_mut(&surface_id) {
        if let Some(XdgSurface { role, states, .. }) = &mut surface.xdg_surface {
            if let SurfaceRole::TopLevel(_) = role {
                if states.contains(&XdgState::Maximized) {
                    states.retain(|s| *s != XdgState::Maximized);
                } else {
                    states.push(XdgState::Maximized);
                }
                self.send_configure(surface_id);
            }
        }
    }
}
```