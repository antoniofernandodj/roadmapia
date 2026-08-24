## Input Direto

Quando você remove as decorações padrão da janela com `with_decorations(false)`, perde também os controles de input que o compositor normalmente fornece. Vamos implementar um sistema de arrastar a janela pelo título, capturando eventos diretamente do protocolo Wayland.

O primeiro passo é entender o fluxo de eventos brutos:

```rust
use winit::event::{Event, WindowEvent};
use winit::event_loop::{ControlFlow, EventLoop};

let event_loop = EventLoop::new_wayland();
let window = winit::window::WindowBuilder::new()
    .with_decorations(false)
    .build(&event_loop)?;

let mut drag_position = None;

event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Poll;

    match event {
        Event::WindowEvent { event, .. } => match event {
            WindowEvent::MouseInput { button, state, .. } => {
                if button == winit::event::MouseButton::Left {
                    drag_position = match state {
                        winit::event::ElementState::Pressed => {
                            window.drag_window().ok();
                            Some(window.outer_position().unwrap())
                        }
                        _ => None,
                    };
                }
            },
            WindowEvent::CursorMoved { position, .. } => {
                if let Some(start_pos) = drag_position {
                    let current_pos = window.outer_position().unwrap();
                    let delta = (position.x as i32, position.y as i32);
                    window.set_outer_position(winit::dpi::PhysicalPosition {
                        x: current_pos.x + delta.0 - start_pos.x,
                        y: current_pos.y + delta.1 - start_pos.y,
                    });
                }
            },
            _ => (),
        },
        _ => (),
    }
});
```

Este código tem um problema crítico: o movimento fica instável porque estamos misturando coordenadas relativas e absolutas. A saída do erro quando você arrasta rápido mostra:

```
[wayland-client] Queue dispatch failed: Protocol error: invalid object or id
```

A solução é trabalhar exclusivamente com coordenadas relativas desde o início:

```rust
WindowEvent::CursorMoved { position, .. } => {
    if let Some((start_x, start_y)) = drag_position {
        let delta_x = position.x as i32 - start_x;
        let delta_y = position.y as i32 - start_y;
        window.set_outer_position(winit::dpi::PhysicalPosition {
            x: delta_x,
            y: delta_y,
        });
    }
},
```

Para inputs de teclado direto, acessamos os eventos raw do Wayland através da extensão `wl_keyboard`:

```rust
use wayland_client::protocol::wl_keyboard::WlKeyboard;

let keyboard = wayland_client::Connection::connect_to_env()?
    .display()
    .get_registry()
    .bind::<WlKeyboard, _>(1..=1, None);

keyboard.quick_assign(|keyboard, event, _| {
    match event {
        wayland_client::protocol::wl_keyboard::Event::Key { key, state, .. } => {
            println!("Tecla {} {}", key, match state {
                wayland_client::protocol::wl_keyboard::KeyState::Pressed => "pressionada",
                _ => "liberada",
            });
        },
        _ => (),
    }
});
```

Isso gera saídas como:
```
Tecla 30 pressionada
Tecla 30 liberada
```

Para mapear os códigos de tecla (30 no exemplo) para caracteres, precisamos do mapa de keycodes XKB:

```rust
use xkbcommon::xkb;

let context = xkb::Context::new(xkb::CONTEXT_NO_FLAGS);
let keymap = xkb::Keymap::new_from_names(
    &context,
    "",
    "",
    "",
    "",
    None,
    xkb::KEYMAP_COMPILE_NO_FLAGS,
).unwrap();
let state = xkb::State::new(&keymap);

// Dentro do handler de eventos
let keysym = state.key_get_one_sym(key + 8); // Offset padrão do Wayland
println!("Tecla: {}", xkb::keysym_get_name(keysym));
```

Agora a saída mostra:
```
Tecla: a
```

**Exercício**: Implemente um atalho Ctrl+Q para fechar a janela. Use o estado do modificador do evento `wl_keyboard` e verifique o keysym correspondente a 'q'.

**Solução**:

```rust
let mut ctrl_pressed = false;

keyboard.quick_assign(|keyboard, event, _| {
    match event {
        wayland_client::protocol::wl_keyboard::Event::Key { key, state, .. } => {
            let keysym = state.key_get_one_sym(key + 8);
            if keysym == xkb::keysym_from_name("q", xkb::KEYSYM_NO_FLAGS) 
                && ctrl_pressed {
                std::process::exit(0);
            }
        },
        wayland_client::protocol::wl_keyboard::Event::Modifiers { mods_depressed, .. } => {
            ctrl_pressed = (mods_depressed & xkb::MOD_CONTROL_MASK) != 0;
        },
        _ => (),
    }
});
```