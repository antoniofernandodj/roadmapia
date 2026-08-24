## DPI e Scaling

Ao contrário do que muitos desenvolvedores assumem, um pixel não é necessariamente uma unidade física fixa. Em monitores de alta densidade (como "retina displays"), o sistema aplica um fator de escala para manter a legibilidade. O Wayland lida com isso através de dois conceitos fundamentais:

1. **DPI (Dots Per Inch)**: Mede a densidade física de pixels da tela
2. **Scale Factor**: Multiplicador aplicado pelo compositor para ajustar o conteúdo

Veja o que acontece quando você ignora o scaling:

```rust
use wayland_client::{Display, GlobalManager};
use wayland_protocols::xdg_shell::client::xdg_surface;

let display = Display::connect_to_env().unwrap();
let mut event_queue = display.create_event_queue();
let attached_display = display.attach(event_queue.token());
let globals = GlobalManager::new(&attached_display);

// Criando uma surface sem considerar DPI
let surface = compositor.create_surface(&qh, ());
let xdg_surface = xdg_wm_base.get_xdg_surface(&surface, &qh, ());
```

O resultado será texto borrado e elementos de UI pequenos demais em monitores de alta DPI. O Wayland emite um aviso (visível com `WAYLAND_DEBUG=1`):

```
[wayland-client] Warning: surface scale not set, assuming 1
```

Para corrigir, precisamos consultar o scale factor atual. Em aplicações reais, ele pode mudar dinamicamente (quando a janela é movida entre monitores com DPI diferente):

```rust
use wayland_protocols::xdg_shell::client::xdg_toplevel;

let toplevel = xdg_surface.get_toplevel(&qh, ());
let output = globals.instantiate_exact::<wl_output::WlOutput>(1).unwrap();

// Handler para eventos de output
output.quick_assign(move |output, event, _| {
    match event {
        wl_output::Event::Scale(factor) => {
            println!("Novo scale factor: {}", factor);
            surface.set_buffer_scale(factor);
            surface.commit();
        },
        _ => {}
    }
});
```

A implementação correta envolve três passos:

1. **Detectar o output atual**: O monitor onde a janela está sendo exibida
2. **Monitorar mudanças**: Através do evento `wl_output::Event::Scale`
3. **Ajustar buffers**: Usando `set_buffer_scale` antes do commit

Exemplo completo de tratamento de DPI:

```rust
use wayland_client::protocol::wl_surface;

struct DpiHandler {
    current_scale: i32,
    surface: wl_surface::WlSurface,
}

impl DpiHandler {
    fn new(surface: wl_surface::WlSurface) -> Self {
        DpiHandler {
            current_scale: 1, // Default
            surface,
        }
    }

    fn update_scale(&mut self, new_scale: i32) {
        if self.current_scale != new_scale {
            self.surface.set_buffer_scale(new_scale);
            self.current_scale = new_scale;
            println!("DPI atualizado para: {}", new_scale);
        }
    }
}
```

Erro comum é assumir que o scale factor é sempre inteiro. Alguns compositors modernos suportam fatores fracionários (1.5, 2.5). Para isso, precisamos usar `wl_surface::set_buffer_transform` combinado com scaling:

```rust
surface.set_buffer_transform(wl_output::Transform::Flipped180);
surface.set_buffer_scale(2); // 2x scaling
```

A saída esperada em um monitor 4K (3840x2160) com scale factor 2 seria:

```
Buffer size: 1920x1080
Surface size: 3840x2160
```

**Exercício**: Crie um handler que reage a mudanças de DPI alternando entre scale factors 1 e 2 quando receber o evento `wl_keyboard::Event::Key` com a tecla F11.

Solução:

```rust
use wayland_client::protocol::{wl_keyboard, wl_surface};

struct DpiToggle {
    surface: wl_surface::WlSurface,
    high_dpi: bool,
}

impl DpiToggle {
    fn handle_key(&mut self, event: wl_keyboard::Event) {
        if let wl_keyboard::Event::Key { key, state, .. } = event {
            if key == 95 && state == wl_keyboard::KeyState::Pressed { // F11
                self.high_dpi = !self.high_dpi;
                let scale = if self.high_dpi { 2 } else { 1 };
                self.surface.set_buffer_scale(scale);
                println!("Scale factor toggled to: {}", scale);
            }
        }
    }
}
```

Lembre-se: buffers devem sempre ser criados considerando o scale factor atual. Um buffer de 800x600 com scale factor 2 ocupará 1600x1200 pixels físicos na tela.