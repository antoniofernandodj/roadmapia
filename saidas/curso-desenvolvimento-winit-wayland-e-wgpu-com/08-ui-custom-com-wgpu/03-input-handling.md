## Input Handling

Uma interface gráfica sem interação é como uma pintura estática - bonita, mas inútil. O desafio começa quando precisamos traduzir eventos brutos de mouse e teclado em ações específicas da UI, como clicar em botões ou digitar em campos de texto. Vamos construir um sistema que:

1. Captura eventos do Winit
2. Mapeia coordenadas físicas para lógicas (DPI-aware)
3. Testa colisão com elementos da UI
4. Dispara callbacks de interação

Começamos com a estrutura básica de um elemento clicável:

```rust
pub struct Button {
    bounds: Rectangle,
    on_click: Box<dyn Fn()>,
    state: ButtonState,
}

#[derive(Debug, Clone, Copy)]
pub enum ButtonState {
    Normal,
    Hovered,
    Pressed,
}
```

O problema real aparece quando tentamos lidar com o evento de mouse:

```rust
// ERRO COMUM: esquecer de converter coordenadas para DPI
fn handle_mouse_move(&mut self, position: (f32, f32), scale_factor: f64) {
    let logical_position = (
        position.0 / scale_factor as f32,
        position.1 / scale_factor as f32,
    );
    
    for button in &mut self.buttons {
        button.state = if button.bounds.contains(logical_position) {
            ButtonState::Hovered
        } else {
            ButtonState::Normal
        };
    }
}
```

A saída esperada quando o mouse passa sobre um botão:
```
Button state changed: Hovered
```

Mas e se quisermos tratar clique? Precisamos gerenciar o estado do botão:

```rust
fn handle_mouse_input(
    &mut self,
    button: MouseButton,
    state: ElementState,
    position: (f32, f32),
    scale_factor: f64,
) {
    let logical_position = (
        position.0 / scale_factor as f32,
        position.1 / scale_factor as f32,
    );

    match (button, state) {
        (MouseButton::Left, ElementState::Pressed) => {
            for button in &mut self.buttons {
                if button.bounds.contains(logical_position) {
                    button.state = ButtonState::Pressed;
                }
            }
        }
        (MouseButton::Left, ElementState::Released) => {
            for button in &mut self.buttons {
                if button.bounds.contains(logical_position) 
                    && button.state == ButtonState::Pressed 
                {
                    (button.on_click)();
                }
                button.state = ButtonState::Normal;
            }
        }
        _ => {}
    }
}
```

O erro que você vai cometer (e a mensagem exata):
```rust
// ERRO: closure pode capturar variáveis do escopo externo
let counter = 0;
buttons.push(Button {
    on_click: Box::new(|| {
        counter += 1; // Erro: "cannot assign to `counter`, as it is a captured variable in a `Fn` closure"
    }),
    // ...
});
```

Solução: usar Cell ou RefCell para mutabilidade interior:
```rust
use std::cell::Cell;

let counter = Cell::new(0);
buttons.push(Button {
    on_click: Box::new(|| {
        counter.set(counter.get() + 1);
    }),
    // ...
});
```

Para entrada de teclado, o fluxo é diferente. Precisamos gerenciar foco:

```rust
pub struct TextInput {
    bounds: Rectangle,
    text: String,
    has_focus: bool,
    cursor_position: usize,
}

fn handle_key_input(&mut self, key: Key, modifiers: ModifiersState) {
    if !self.has_focus {
        return;
    }

    match key {
        Key::Character(c) => {
            self.text.insert(self.cursor_position, c.chars().next().unwrap());
            self.cursor_position += 1;
        }
        Key::Backspace if self.cursor_position > 0 => {
            self.text.remove(self.cursor_position - 1);
            self.cursor_position -= 1;
        }
        Key::ArrowLeft if self.cursor_position > 0 => {
            self.cursor_position -= 1;
        }
        Key::ArrowRight if self.cursor_position < self.text.len() => {
            self.cursor_position += 1;
        }
        _ => {}
    }
}
```

Exercício: Implemente um sistema de tabulação que muda o foco entre elementos com a tecla Tab. Considere:
1. Ordem dos elementos focáveis
2. Tratamento de Shift+Tab para navegação reversa
3. Visualização do foco atual

Solução comentada:
```rust
fn handle_tab_navigation(&mut self, reverse: bool) {
    let focussable: Vec<_> = self.elements.iter()
        .enumerate()
        .filter(|(_, e)| e.is_focusable())
        .collect();

    if let Some(current_idx) = self.focused_element_idx {
        let next_idx = if reverse {
            current_idx.checked_sub(1).unwrap_or(focussable.len() - 1)
        } else {
            (current_idx + 1) % focussable.len()
        };
        self.elements[current_idx].set_focus(false);
        self.elements[next_idx].set_focus(true);
        self.focused_element_idx = Some(next_idx);
    } else if !focussable.is_empty() {
        self.elements[focussable[0].0].set_focus(true);
        self.focused_element_idx = Some(0);
    }
}
```