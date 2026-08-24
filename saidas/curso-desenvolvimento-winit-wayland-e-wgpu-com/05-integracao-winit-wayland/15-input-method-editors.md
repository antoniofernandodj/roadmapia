## Input Method Editors

Quando você pressiona uma tecla em um teclado físico, o sistema operacional recebe um *keycode* (um número que identifica a posição física da tecla), não o caractere final. Para idiomas como japonês ou chinês, onde um mesmo pressionamento pode gerar múltiplos caracteres em composição, os Input Method Editors (IMEs) fazem a ponte entre os keycodes brutos e o texto finalizado.

O Winit fornece acesso a eventos de IME através do módulo `window::ime`. Vamos criar uma janela que mostra a pré-composição IME em tempo real:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_ime(true)  // Ativa suporte a IME
        .build(&event_loop)
        .unwrap();

    let mut composition = String::new();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::Ime(ime) => {
                    match ime {
                        winit::event::Ime::Preedit(text, cursor) => {
                            composition = text.unwrap_or_default();
                            println!("Pré-composição: '{}' (cursor em {:?})", composition, cursor);
                        }
                        winit::event::Ime::Commit(text) => {
                            println!("Texto finalizado: '{}'", text);
                            composition.clear();
                        }
                        winit::event::Ime::Enabled => {
                            println!("IME ativado");
                        }
                        winit::event::Ime::Disabled => {
                            println!("IME desativado");
                            composition.clear();
                        }
                    }
                }
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            _ => (),
        }
    });
}
```

Ao executar este código com um IME ativo (como o Mozc para japonês ou Fcitx para chinês), a saída mostrará:

```
IME ativado
Pré-composição: 'か' (cursor em Some(1))
Pré-composição: 'かな' (cursor em Some(2))
Texto finalizado: 'かな'
```

Um erro comum é esquecer de limpar o estado de pré-composição quando o IME é desativado. Se você não limpar `composition` no evento `Ime::Disabled`, poderá ver artefatos visuais quando o IME for reativado:

```
Pré-composição: '旧' (cursor em Some(1))
IME desativado
IME ativado
Pré-composição: '旧新' (cursor em Some(2))  // '旧' persiste indevidamente
```

Para integrar o IME com renderização WGPU, você precisa converter o texto de pré-composição em vértices. Aqui está um exemplo mínimo usando `glyph_brush`:

```rust
// Adicione ao seu Cargo.toml:
// glyph_brush = "0.7"
// wgpu = "0.12"

use glyph_brush::{GlyphBrush, GlyphBrushBuilder};
use wgpu::TextureFormat;

let mut glyph_brush: GlyphBrush<()> = GlyphBrushBuilder::using_font(include_bytes!("font.ttf"))
    .build(&device, TextureFormat::Bgra8UnormSrgb);

// No handler de eventos Ime::Preedit:
glyph_brush.queue(section(
    &composition,
    ScreenPosition::from((10.0, 20.0)),
    Color::WHITE,
));

// No render pass:
glyph_brush.draw_queued(
    &device,
    &staging_belt,
    &mut encoder,
    &output.view,
    size.width,
    size.height,
).unwrap();
```

**Exercício**: Modifique o exemplo para mostrar o cursor de texto durante a pré-composição. Dica: use um retângulo branco que muda de posição baseado no `cursor` do evento `Ime::Preedit`.

**Solução**:

```rust
// Adicione ao estado global
struct Cursor {
    position: (f32, f32),
    visible: bool,
}

// No handler Ime::Preedit:
cursor.position = (10.0 + cursor_pos.unwrap_or(0) as f32 * 8.0, 20.0);
cursor.visible = true;

// No render pass:
if cursor.visible {
    let cursor_rect = Rect {
        min: [cursor.position.0, cursor.position.1],
        max: [cursor.position.0 + 2.0, cursor.position.1 + 16.0],
    };
    glyph_brush.queue(section(
        &"|",
        ScreenPosition::from((cursor.position.0, cursor.position.1)),
        Color::WHITE,
    ));
}
```