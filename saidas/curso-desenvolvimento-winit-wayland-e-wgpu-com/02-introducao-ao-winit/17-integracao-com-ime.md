## Integração com IME

Quando um usuário digita em um idioma como japonês ou chinês, os caracteres não aparecem imediatamente - primeiro surge uma "preview" interativa onde o usuário seleciona a forma final. Esse sistema é o Input Method Editor (IME), e aplicações gráficas precisam integrar-se com ele para suportar entrada de texto globalmente.

O Winit fornece eventos específicos para essa integração. Veja como capturar a composição IME em tempo real:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_ime_allowed(true)  // Habilita IME explicitamente
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::Ime(event) => {
                    println!("Evento IME: {:?}", event);
                    // Exemplo de saída para digitação em japonês:
                    // Ime(Preedit("か", Some(0..1))) -> Ime(Preedit("かき", Some(0..2))) -> Ime(Commit("書き"))
                }
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            _ => (),
        }
    });
}
```

Os três estados principais do IME são:

1. **Preedit**: Texto provisório sendo composto (ex: "かき" em japonês)
2. **Commit**: Texto final confirmado (ex: "書き" convertido do preedit)
3. **Disabled**: Quando o IME é desativado para campos numéricos

Um erro comum é esquecer de habilitar o IME na janela, resultando em comportamento inconsistente entre plataformas. A solução é sempre chamar `.with_ime_allowed(true)` no WindowBuilder.

Para posicionar corretamente a janela de composição do IME (aquela caixa que aparece sob o texto), use as coordenadas do cursor:

```rust
WindowEvent::CursorMoved { position, .. } => {
    window.set_ime_position(position.to_logical(window.scale_factor()));
}
```

Aqui está um exemplo completo com campo de texto simulando um editor básico:

```rust
use winit::{
    event::{Event, WindowEvent, ElementState, VirtualKeyCode, KeyboardInput},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

struct TextField {
    content: String,
    cursor_pos: usize,
}

fn main() {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_ime_allowed(true)
        .build(&event_loop)
        .unwrap();

    let mut text_field = TextField {
        content: String::new(),
        cursor_pos: 0,
    };

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::Ime(ime_event) => match ime_event {
                    winit::event::Ime::Preedit(text, cursor) => {
                        println!("Composição: {} (cursor: {:?})", text, cursor);
                    }
                    winit::event::Ime::Commit(text) => {
                        text_field.content.insert_str(text_field.cursor_pos, &text);
                        text_field.cursor_pos += text.len();
                        println!("Texto confirmado: {}", text_field.content);
                    }
                    winit::event::Ime::Disabled => {
                        println!("IME desativado");
                    }
                },
                WindowEvent::KeyboardInput { input, .. } => {
                    if let Some(keycode) = input.virtual_keycode {
                        if input.state == ElementState::Pressed {
                            match keycode {
                                VirtualKeyCode::Back => {
                                    if !text_field.content.is_empty() {
                                        text_field.content.pop();
                                        text_field.cursor_pos = text_field.cursor_pos.saturating_sub(1);
                                    }
                                },
                                _ => (),
                            }
                        }
                    }
                },
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            _ => (),
        }
    });
}
```

**Erro comum**: Tentar processar eventos IME sem considerar o estado do preedit pode levar a duplicação de caracteres. A saída mostra o fluxo correto:

```
Composição: か (cursor: Some(0..1))
Composição: かき (cursor: Some(0..2))
Texto confirmado: 書き
```

**Exercício**: Modifique o exemplo para suportar movimento do cursor com setas e adicione um retângulo de destaque na posição atual do cursor. Dica: use `Window::set_ime_position` com as coordenadas calculadas.

**Solução**:

```rust
// Adicione ao match de KeyboardInput
VirtualKeyCode::Left => {
    text_field.cursor_pos = text_field.cursor_pos.saturating_sub(1);
    update_ime_position(&window, &text_field);
},
VirtualKeyCode::Right => {
    text_field.cursor_pos = (text_field.cursor_pos + 1)
        .min(text_field.content.len());
    update_ime_position(&window, &text_field);
},

// Função auxiliar
fn update_ime_position(window: &winit::window::Window, text_field: &TextField) {
    // Simula posição X crescente com cada caractere
    let x_pos = text_field.cursor_pos as f64 * 10.0;
    window.set_ime_position(winit::dpi::LogicalPosition::new(x_pos, 20.0));
}
```