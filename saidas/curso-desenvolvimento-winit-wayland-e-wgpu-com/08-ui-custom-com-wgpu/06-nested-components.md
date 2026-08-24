## Nested Components

Criar uma interface de usuário complexa exige dividi-la em partes menores que se encaixam de forma previsível. O problema aparece quando você tenta aninhar componentes: como um botão dentro de um painel, que por sua vez está dentro de uma janela. Sem uma estrutura clara, as coordenadas de renderização se perdem, os eventos de input não são roteados corretamente e o layout vira um quebra-cabeça impossível.

Vamos resolver isso com um sistema baseado em árvore, onde cada componente sabe:
1. Sua posição relativa ao pai
2. Quais componentes ele contém
3. Como delegar operações de layout e renderização

Comece definindo o trait `Widget` como base:

```rust
pub trait Widget {
    fn layout(&mut self, constraints: Constraints) -> Size;
    fn draw(&self, canvas: &mut Canvas, position: Point);
    fn children(&self) -> Vec<&dyn Widget>;
}
```

Um erro comum é esquecer de propagar as constraints aos filhos. Veja o que acontece se você não fizer isso:

```rust
// ERRADO: o botão ignora as constraints do pai
struct BrokenPanel {
    child: Button,
}

impl Widget for BrokenPanel {
    fn layout(&mut self, constraints: Constraints) -> Size {
        let child_size = self.child.layout(Constraints::loose()); // Ops!
        Size::new(constraints.max_width, child_size.height + 20)
    }
    // ...
}
```

Ao executar, o botão vaza do painel porque recebeu constraints frouxas. A mensagem de erro do WGPU será confusa:
```
wgpu error: Validation Error: Vertex buffer is not large enough
```

A versão correta considera as constraints do pai:

```rust
// CERTO: o botão respeita o espaço disponível
struct FixedPanel {
    child: Button,
}

impl Widget for FixedPanel {
    fn layout(&mut self, constraints: Constraints) -> Size {
        let child_constraints = Constraints::tight(Size::new(
            constraints.max_width - 20,
            constraints.max_height - 20,
        ));
        let child_size = self.child.layout(child_constraints);
        Size::new(constraints.max_width, child_size.height + 20)
    }
    // ...
}
```

Para coordenar a renderização, usamos um `Canvas` que mantém o estado da GPU:

```rust
pub struct Canvas<'a> {
    encoder: &'a mut wgpu::CommandEncoder,
    render_pass: wgpu::RenderPass<'a>,
    current_pipeline: Option<wgpu::RenderPipeline>,
}
```

O segredo está na recursão durante o desenho. Cada widget:
1. Aplica sua própria transformação (posição relativa)
2. Desenha seu conteúdo
3. Chama `draw()` nos filhos

```rust
impl Widget for FixedPanel {
    fn draw(&self, canvas: &mut Canvas, position: Point) {
        // 1. Desenha fundo
        canvas.draw_rect(position, self.size, Color::GRAY);
        
        // 2. Posiciona filho
        let child_position = position + Point::new(10, 10);
        
        // 3. Renderiza filho
        self.child.draw(canvas, child_position);
    }
}
```

Para testar, crie uma hierarquia simples:

```rust
let mut ui = FixedPanel {
    child: Button {
        label: "Clique".to_string(),
        size: Size::zero(), // Será calculado no layout
    },
};

let constraints = Constraints::tight(Size::new(200, 100));
ui.layout(constraints);

let mut canvas = Canvas::new(...);
ui.draw(&mut canvas, Point::origin());
```

**Exercício**: Implemente um `Row` que distribui três botões horizontalmente com espaçamento igual. Trate o caso onde os botões não cabem (deve retornar um erro de layout).

**Solução**:

```rust
struct Row {
    buttons: [Button; 3],
    spacing: f32,
}

impl Widget for Row {
    fn layout(&mut self, constraints: Constraints) -> Size {
        let available_width = constraints.max_width - 2.0 * self.spacing;
        let button_width = available_width / 3.0;
        
        if button_width < MIN_BUTTON_WIDTH {
            return Size::zero(); // Indica erro
        }
        
        let button_constraints = Constraints::tight(Size::new(
            button_width,
            constraints.max_height,
        ));
        
        let mut total_height = 0.0;
        for button in &mut self.buttons {
            let size = button.layout(button_constraints);
            total_height = total_height.max(size.height);
        }
        
        Size::new(constraints.max_width, total_height)
    }
    
    fn draw(&self, canvas: &mut Canvas, position: Point) {
        let button_width = (self.size.width - 2.0 * self.spacing) / 3.0;
        for (i, button) in self.buttons.iter().enumerate() {
            let x = position.x + i as f32 * (button_width + self.spacing);
            button.draw(canvas, Point::new(x, position.y));
        }
    }
}
```