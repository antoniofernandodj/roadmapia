## Accessibility Básica

Quando desenvolvemos uma interface gráfica customizada, é comum focarmos apenas na aparência e funcionalidade, esquecendo que nem todos os usuários interagem com o aplicativo da mesma forma. Usuários com deficiências visuais ou motoras dependem de tecnologias assistivas, como leitores de tela ou navegação por teclado, para utilizar aplicativos. Ignorar essas necessidades não apenas exclui parte do público, mas também viola diretrizes de acessibilidade em muitos países.

O primeiro passo para tornar uma UI acessível é garantir que todos os elementos sejam navegáveis e compreensíveis sem o uso do mouse. Isso inclui a navegação por teclado e a identificação clara de cada elemento. No Winit, o tratamento de eventos de teclado já está implementado, mas precisamos integrá-los com nossa UI customizada. Aqui está um exemplo básico de como fazer isso:

```rust
struct Button {
    label: String,
    focused: bool,
    callback: Box<dyn Fn()>,
}

impl Button {
    fn new(label: &str, callback: Box<dyn Fn()>) -> Self {
        Self {
            label: label.to_string(),
            focused: false,
            callback,
        }
    }

    fn handle_key(&self, key: winit::event::VirtualKeyCode) {
        if self.focused && key == winit::event::VirtualKeyCode::Return {
            (self.callback)();
        }
    }
}
```

Neste exemplo, um botão pode ser "clicado" usando a tecla `Enter` quando está em foco. Para que isso funcione, precisamos de um sistema de gerenciamento de foco que permita alternar entre os elementos da UI usando `Tab` e `Shift+Tab`:

```rust
struct FocusManager {
    elements: Vec<Box<dyn Focusable>>,
    current: usize,
}

impl FocusManager {
    fn new() -> Self {
        Self {
            elements: Vec::new(),
            current: 0,
        }
    }

    fn add_element(&mut self, element: Box<dyn Focusable>) {
        self.elements.push(element);
    }

    fn handle_tab(&mut self) {
        self.elements[self.current].set_focus(false);
        self.current = (self.current + 1) % self.elements.len();
        self.elements[self.current].set_focus(true);
    }

    fn handle_shift_tab(&mut self) {
        self.elements[self.current].set_focus(false);
        self.current = if self.current == 0 {
            self.elements.len() - 1
        } else {
            self.current - 1
        };
        self.elements[self.current].set_focus(true);
    }
}
```

Para que os elementos funcionem com o `FocusManager`, eles precisam implementar uma trait `Focusable`:

```rust
trait Focusable {
    fn set_focus(&self, focused: bool);
    fn handle_key(&self, key: winit::event::VirtualKeyCode);
}
```

Outro aspecto crucial da acessibilidade é fornecer descrições textuais para elementos visuais, como ícones ou imagens. Essas descrições são usadas por leitores de tela para descrever o conteúdo aos usuários. No caso de botões, podemos adicionar um atributo `aria-label`:

```rust
impl Button {
    fn aria_label(&self) -> String {
        format!("Botão: {}", self.label)
    }
}
```

Para elementos que mudam de estado, como um botão de alternância, é importante notificar o usuário sobre a mudança. Isso pode ser feito usando `aria-live`:

```rust
impl Button {
    fn toggle(&mut self) {
        self.focused = !self.focused;
        println!("{}", if self.focused { "Botão ativo" } else { "Botão inativo" });
    }
}
```

Um erro comum é esquecer de atualizar o estado visual do foco. Se o usuário não consegue ver onde o foco está, a navegação por teclado torna-se inútil. Aqui está um exemplo de como evitar isso:

```rust
impl Button {
    fn draw(&self) {
        if self.focused {
            println!("[{}]", self.label);
        } else {
            println!(" {}", self.label);
        }
    }
}
```

Finalmente, é importante testar a acessibilidade da aplicação com ferramentas específicas. No Linux, o `orca` é um leitor de tela comum que pode ser usado para verificar se os elementos estão sendo anunciados corretamente. No Windows, o `Narrator` serve ao mesmo propósito.

### Exercício

Implemente um sistema de navegação por teclado para uma lista de botões. Cada botão deve ser focável e "clicável" com `Enter`. Use o `FocusManager` para alternar o foco entre os botões.

#### Solução

```rust
fn main() {
    let mut manager = FocusManager::new();

    let button1 = Button::new("Botão 1", Box::new(|| println!("Botão 1 clicado")));
    let button2 = Button::new("Botão 2", Box::new(|| println!("Botão 2 clicado")));

    manager.add_element(Box::new(button1));
    manager.add_element(Box::new(button2));

    manager.handle_tab(); // Foca no Botão 1
    manager.handle_key(winit::event::VirtualKeyCode::Return); // Clica no Botão 1
    manager.handle_tab(); // Foca no Botão 2
    manager.handle_key(winit::event::VirtualKeyCode::Return); // Clica no Botão 2
}
```

Este exemplo mostra como integrar navegação por teclado e tratamento de eventos em uma UI customizada, garantindo que todos os usuários possam interagir com a aplicação de forma eficiente.