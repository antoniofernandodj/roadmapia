## Scrolling Básico

Uma interface sem scrolling é como uma página de livro fixa — quando o conteúdo ultrapassa a área visível, você perde acesso a ele. Vamos implementar um sistema de rolagem vertical simples para um widget de texto longo, sem física ou momentum, apenas o deslocamento manual controlado pelo mouse.

O cerne do problema está em coordenadas: precisamos deslocar o conteúdo renderizado enquanto mantemos a área de clipping intacta. Começamos com um buffer de texto que excede a altura do container:

```rust
struct ScrollableText {
    content: String,  // Texto longo que não cabe na tela
    scroll_offset: f32,  // Deslocamento atual em pixels
    bounds: Rectangle,  // Área visível do widget
}
```

A renderização básica sem scrolling seria:

```rust
fn draw(&self, canvas: &mut Canvas) {
    canvas.draw_text(
        &self.content,
        Point::new(self.bounds.x, self.bounds.y),
        TextStyle::default(),
    );
}
```

Isso mostra apenas o início do texto, cortando o resto. Para implementar o scrolling, ajustamos a posição Y do texto baseado no `scroll_offset`:

```rust
fn draw(&self, canvas: &mut Canvas) {
    canvas.draw_text(
        &self.content,
        Point::new(
            self.bounds.x,
            self.bounds.y - self.scroll_offset,  // Desloca para cima
        ),
        TextStyle::default(),
    );
    
    // Aplica clipping para não vazar da área visível
    canvas.push_clip_rect(self.bounds);
}
```

O erro clássico aqui é esquecer o clipping, resultando em texto vazando para outras partes da UI. Sem `push_clip_rect`, o texto deslocado apareceria sobreposto a widgets vizinhos.

Para controlar o deslocamento, capturamos eventos de roda do mouse:

```rust
fn handle_event(&mut self, event: &WindowEvent) -> bool {
    match event {
        WindowEvent::MouseWheel { delta, .. } => {
            match delta {
                MouseScrollDelta::LineDelta(_, y) => {
                    // 1. Calcula o novo offset
                    let new_offset = self.scroll_offset + (*y * 20.0);
                    
                    // 2. Limita entre 0 e o máximo necessário
                    let max_offset = self.content_height() - self.bounds.height;
                    self.scroll_offset = new_offset.clamp(0.0, max_offset);
                    
                    true  // Evento tratado
                }
                _ => false,
            }
        }
        _ => false,
    }
}
```

Dois detalhes críticos:
1. **Multiplicador de velocidade**: `*20.0` converte unidades lógicas (linhas) para pixels
2. **Clamping**: Evita scrolling negativo ou além do conteúdo

Para testar, crie um widget com texto maior que a tela:

```rust
let long_text = "Lorem ipsum...".repeat(50);
let mut scroller = ScrollableText {
    content: long_text,
    scroll_offset: 0.0,
    bounds: Rectangle::new(Point::new(50.0, 50.0), Size::new(300.0, 200.0)),
};

// No loop de eventos:
event_loop.run(move |event, _, control_flow| {
    if scroller.handle_event(&event) {
        window.request_redraw();  // Força redesenho
    }
    // ... resto do loop
});
```

A saída esperada ao rodar o mouse wheel:
1. Roda para baixo: texto sobe (scroll_offset aumenta)
2. Roda para cima: texto desce (scroll_offset diminui)
3. Para no início e fim do conteúdo

**Problema comum**: O cálculo de `content_height` precisa incluir todas as linhas do texto. Uma implementação ingênua retornaria apenas `text.len()` como altura, causando scrolling incorreto. A versão correta considera a formatação:

```rust
fn content_height(&self) -> f32 {
    let line_height = 24.0;  // Altura da fonte + espaçamento
    let line_count = self.content.lines().count() as f32;
    line_count * line_height
}
```

**Exercício**: Implemente uma barra de scroll visual que:
1. Mostre a posição relativa do conteúdo
2. Permita arrastar para rolar
3. Ajuste dinamicamente seu tamanho baseado na razão conteúdo/área visível

**Solução comentada**:

```rust
struct ScrollBar {
    thumb_rect: Rectangle,
    is_dragging: bool,
}

impl ScrollableText {
    fn draw_scrollbar(&self, canvas: &mut Canvas) {
        let thumb_height = self.bounds.height * 
            (self.bounds.height / self.content_height()).min(1.0);
        
        let thumb_y = self.scroll_offset * 
            (self.bounds.height - thumb_height) / 
            (self.content_height() - self.bounds.height);
        
        let thumb_rect = Rectangle::new(
            Point::new(self.bounds.right() - 10.0, self.bounds.y + thumb_y),
            Size::new(8.0, thumb_height),
        );
        
        canvas.draw_rect(thumb_rect, Color::GRAY);
    }
    
    fn handle_drag(&mut self, mouse_pos: Point) {
        let thumb_height = self.bounds.height * 
            (self.bounds.height / self.content_height()).min(1.0);
        
        let relative_y = (mouse_pos.y - self.bounds.y - thumb_height / 2.0)
            .clamp(0.0, self.bounds.height - thumb_height);
        
        self.scroll_offset = relative_y * 
            (self.content_height() - self.bounds.height) / 
            (self.bounds.height - thumb_height);
    }
}
```