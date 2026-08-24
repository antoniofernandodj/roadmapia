## Shell Surfaces

Uma `wl_surface` sozinha não aparece na tela - ela precisa de um *role* que defina seu propósito no sistema. É aí que entram as shell surfaces, que atribuem funções específicas como janelas de aplicativo, diálogos ou menus. Vamos criar uma janela básica usando `xdg_shell`, o protocolo padrão para aplicações desktop.

```rust
use wayland_client::{
    globals::{registry_queue_init, GlobalListContents},
    protocol::{wl_surface, wl_compositor, xdg_shell, xdg_surface, xdg_toplevel},
    Connection, QueueHandle,
};

fn create_window(conn: &Connection, qh: &QueueHandle<MyHandler>) -> (wl_surface::WlSurface, xdg_toplevel::XdgToplevel) {
    // Obtém globais necessários
    let globals = registry_queue_init(conn, qh).unwrap();
    let compositor = globals.bind::<wl_compositor::WlCompositor>(1..=4, qh).unwrap();
    let xdg_shell = globals.bind::<xdg_shell::XdgShell>(1..=3, qh).unwrap();
    
    // Cria surface básica
    let surface = compositor.create_surface(qh);
    
    // Transforma em XDG surface
    let xdg_surface = xdg_shell.get_xdg_surface(&surface, qh);
    let toplevel = xdg_surface.get_toplevel(qh);
    
    // Força o compositor a processar os requests
    surface.commit();
    
    (surface, toplevel)
}
```

Se você executar este código agora, ainda nada aparecerá. Falta um passo crucial - configurar o buffer:

```rust
// Continuando o exemplo anterior
fn attach_buffer(surface: &wl_surface::WlSurface, width: i32, height: i32) {
    let pool = ShmPool::create(
        // Cria um buffer compartilhado
        create_shm_fd(width * height * 4).unwrap(),
        width * height * 4,
        &qh,
    ).unwrap();
    
    let buffer = pool.create_buffer(
        0,
        width,
        height,
        width * 4,
        wl_shm::Format::Xrgb8888,
    ).unwrap();
    
    surface.attach(Some(&buffer), 0, 0);
    surface.damage(0, 0, width, height);
    surface.commit();
}
```

O erro mais comum aqui é esquecer o `commit()`. Sem ele, você receberá:

```
[wayland-client] Protocol error 8 on object 4 (wl_surface): 
implementation error: wl_surface@4: no buffer attached
```

Vamos corrigir e implementar um handler mínimo para os eventos necessários:

```rust
struct WindowHandler;

impl Dispatch<xdg_surface::XdgSurface, ()> for WindowHandler {
    fn event(
        state: &mut (),
        surface: &xdg_surface::XdgSurface,
        event: xdg_surface::Event,
        _: &xdg_surface::XdgSurface,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        match event {
            Event::Configure { serial } => {
                surface.ack_configure(serial);
            }
            _ => (),
        }
    }
}
```

Agora, quando executar o código completo, você verá uma janela preta. Mas por que preta? Por padrão, buffers não anexados são transparentes, e o compositor mostra o que está por trás (geralmente preto). Para mudar isso:

```rust
// Preenche o buffer com uma cor (vermelho neste caso)
let mut pixels = pool.mmap::<u32>().unwrap();
for pixel in pixels.iter_mut() {
    *pixel = 0xFF0000FF; // ARGB (vermelho opaco)
}
```

Comparando com Winit, no Wayland você controla cada aspecto:
- Winit cria automaticamente o buffer e trata os eventos
- No nosso código, gerenciamos manualmente a alocação e configuração
- A surface XDG equivale à "janela" no Winit
- O toplevel corresponde ao WindowBuilder

**Exercício:** Modifique o código para criar uma janela azul que muda para verde quando recebe um evento de configuração. Inclua tratamento para redimensionamento.

<details>
<summary>Solução</summary>

```rust
struct ColorWindow {
    color: u32,
    width: i32,
    height: i32,
}

impl Dispatch<xdg_surface::XdgSurface, ColorWindow> for ColorWindow {
    fn event(
        state: &mut ColorWindow,
        surface: &xdg_surface::XdgSurface,
        event: xdg_surface::Event,
        _: &xdg_surface::XdgSurface,
        conn: &Connection,
        qh: &QueueHandle<Self>,
    ) {
        match event {
            Event::Configure { serial } => {
                state.color = 0xFF00FF00; // Verde
                redraw_surface(surface, state.width, state.height, state.color, conn, qh);
                surface.ack_configure(serial);
            }
            _ => (),
        }
    }
}

fn redraw_surface(
    surface: &wl_surface::WlSurface,
    width: i32,
    height: i32,
    color: u32,
    conn: &Connection,
    qh: &QueueHandle<ColorWindow>,
) {
    let pool = ShmPool::create(/* ... */).unwrap();
    let mut pixels = pool.mmap::<u32>().unwrap();
    pixels.fill(color);
    
    let buffer = pool.create_buffer(/* ... */).unwrap();
    surface.attach(Some(&buffer), 0, 0);
    surface.damage(0, 0, width, height);
    surface.commit();
}
```
</details>