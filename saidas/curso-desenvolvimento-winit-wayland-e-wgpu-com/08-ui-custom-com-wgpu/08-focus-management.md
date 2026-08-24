## Focus Management

Em uma interface gráfica, o foco é o elemento que atualmente recebe input do teclado. Sem um gerenciamento adequado, o usuário pode ficar perdido, sem saber onde suas teclas estão sendo direcionadas. Vamos implementar um sistema simples que gerencia o foco entre elementos, sem a complexidade de uma navegação por teclado completa.

Primeiro, precisamos identificar qual elemento está em foco. Para isso, vamos criar uma estrutura `FocusManager` que mantém o controle do elemento atual:

```rust
#[derive(Debug)]
struct FocusManager {
    focused_element: Option<u32>,
}

impl FocusManager {
    fn new() -> Self {
        FocusManager { focused_element: None }
    }

    fn set_focus(&mut self, element_id: u32) {
        self.focused_element = Some(element_id);
    }

    fn clear_focus(&mut self) {
        self.focused_element = None;
    }

    fn is_focused(&self, element_id: u32) -> bool {
        self.focused_element == Some(element_id)
    }
}
```

Agora, vamos criar alguns elementos de interface simples para testar nosso gerenciador de foco:

```rust
#[derive(Debug)]
struct UIElement {
    id: u32,
    label: String,
}

impl UIElement {
    fn new(id: u32, label: &str) -> Self {
        UIElement {
            id,
            label: label.to_string(),
        }
    }

    fn render(&self, focus_manager: &FocusManager) {
        let focus_indicator = if focus_manager.is_focused(self.id) {
            "[*]"
        } else {
            "[ ]"
        };
        println!("{} {}", focus_indicator, self.label);
    }
}
```

Podemos usar esses componentes para criar uma interface básica:

```rust
fn main() {
    let mut focus_manager = FocusManager::new();
    let elements = vec![
        UIElement::new(1, "Botão 1"),
        UIElement::new(2, "Botão 2"),
        UIElement::new(3, "Campo de Texto"),
    ];

    // Simula a interação do usuário
    focus_manager.set_focus(2);
    for element in &elements {
        element.render(&focus_manager);
    }
}
```

A saída deste código será:

```
[ ] Botão 1
[*] Botão 2
[ ] Campo de Texto
```

Agora, vamos implementar uma navegação básica entre elementos usando as teclas Tab e Shift+Tab. Primeiro, precisamos modificar nosso `FocusManager` para incluir uma lista de elementos focáveis:

```rust
impl FocusManager {
    fn focus_next(&mut self, elements: &[UIElement]) {
        let current_index = self.focused_element
            .and_then(|id| elements.iter().position(|e| e.id == id))
            .unwrap_or(0);

        let next_index = (current_index + 1) % elements.len();
        self.set_focus(elements[next_index].id);
    }

    fn focus_previous(&mut self, elements: &[UIElement]) {
        let current_index = self.focused_element
            .and_then(|id| elements.iter().position(|e| e.id == id))
            .unwrap_or(elements.len() - 1);

        let prev_index = if current_index == 0 {
            elements.len() - 1
        } else {
            current_index - 1
        };
        self.set_focus(elements[prev_index].id);
    }
}
```

Podemos testar essa funcionalidade com um loop de eventos simples:

```rust
fn main() {
    let mut focus_manager = FocusManager::new();
    let elements = vec![
        UIElement::new(1, "Botão 1"),
        UIElement::new(2, "Botão 2"),
        UIElement::new(3, "Campo de Texto"),
    ];

    // Simula pressionar Tab três vezes
    focus_manager.focus_next(&elements);
    focus_manager.focus_next(&elements);
    focus_manager.focus_next(&elements);

    for element in &elements {
        element.render(&focus_manager);
    }
}
```

A saída mostrará o foco circulando pelos elementos:

```
[*] Botão 1
[ ] Botão 2
[ ] Campo de Texto
```

Este sistema básico pode ser estendido para incluir elementos que não devem receber foco, hierarquias de foco mais complexas, e tratamento especial para diferentes tipos de input. O importante é manter o gerenciador de foco separado da lógica de renderização, permitindo que ele seja reutilizado em diferentes partes da interface.

**Exercício:** Modifique o código para incluir um quarto elemento que não pode receber foco. Quando o usuário navega com Tab, ele deve pular esse elemento.

**Solução:** Adicione um campo `focusable` à estrutura `UIElement` e modifique os métodos `focus_next` e `focus_previous` para pular elementos não focáveis:

```rust
#[derive(Debug)]
struct UIElement {
    id: u32,
    label: String,
    focusable: bool,
}

impl FocusManager {
    fn focus_next(&mut self, elements: &[UIElement]) {
        let current_index = self.focused_element
            .and_then(|id| elements.iter().position(|e| e.id == id))
            .unwrap_or(0);

        let mut next_index = (current_index + 1) % elements.len();
        while !elements[next_index].focusable {
            next_index = (next_index + 1) % elements.len();
        }
        self.set_focus(elements[next_index].id);
    }

    fn focus_previous(&mut self, elements: &[UIElement]) {
        let current_index = self.focused_element
            .and_then(|id| elements.iter().position(|e| e.id == id))
            .unwrap_or(elements.len() - 1);

        let mut prev_index = if current_index == 0 {
            elements.len() - 1
        } else {
            current_index - 1
        };
        while !elements[prev_index].focusable {
            prev_index = if prev_index == 0 {
                elements.len() - 1
            } else {
                prev_index - 1
            };
        }
        self.set_focus(elements[prev_index].id);
    }
}
```