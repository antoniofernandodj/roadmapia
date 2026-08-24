## Fullscreen e Modos de Exibição

Quando você quer que sua aplicação gráfica ocupe toda a tela - seja para um jogo, visualização de mídia ou ferramenta profissional - o Winit oferece dois caminhos distintos: fullscreen "exclusivo" (mais performático) e "borderless" (mais flexível). A diferença técnica entre eles é profunda:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::{Fullscreen, WindowBuilder},
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new().build(&event_loop).unwrap();

    // Alternância de fullscreen com F11
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::KeyboardInput { input, .. },
                ..
            } if input.virtual_keycode == Some(winit::event::VirtualKeyCode::F11) => {
                let current_fs = window.fullscreen().is_some();
                window.set_fullscreen(if current_fs {
                    None
                } else {
                    Some(Fullscreen::Borderless(None))
                });
            }
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
```

Ao executar este código e pressionar F11, a janela alternará para um modo fullscreen sem bordas. Mas se substituirmos `Fullscreen::Borderless(None)` por `Fullscreen::Exclusive`, o comportamento muda radicalmente:

```rust
Some(Fullscreen::Exclusive(
    window.available_monitors().next().unwrap().video_modes().next().unwrap()
))
```

O modo exclusivo exige que você especifique um `VideoMode` exato (resolução, taxa de atualização). Se escolher um modo não suportado, o Winit emitirá:

```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: "Video mode not supported"'
```

Para evitar isso, liste os modos disponíveis antes de aplicá-los:

```rust
for monitor in window.available_monitors() {
    println!("Monitor: {}", monitor.name());
    for mode in monitor.video_modes() {
        println!("  {}x{} @ {}Hz", mode.size().width, mode.size().height, mode.refresh_rate());
    }
}
```

Um erro comum é tentar acessar `window.fullscreen()` após `event_loop.run()`, o que causa um borrow checker error:

```
error[E0382]: borrow of moved value: `window`
   --> src/main.rs:8:9
    |
7   |     let window = WindowBuilder::new().build(&event_loop).unwrap();
    |         ------ move occurs because `window` has type `winit::window::Window`, which does not implement the `Copy` trait
8   |     event_loop.run(move |event, _, control_flow| {
    |     ^^^^^^^^^^^^^^ value moved here, in previous iteration of loop
    |
    = note: borrow occurs due to use in closure
```

A solução é usar `Rc<Window>` ou acessar a janela via `event.window_id()` nos callbacks.

**Exercício**: Modifique o exemplo para usar um menu de texto que lista os modos de vídeo disponíveis e permite selecioná-los com as teclas numéricas.

```rust
// Solução parcial - implemente a lógica de seleção
match input.virtual_keycode {
    Some(VirtualKeyCode::Key1) => apply_mode(0),
    Some(VirtualKeyCode::Key2) => apply_mode(1),
    _ => (),
}
```