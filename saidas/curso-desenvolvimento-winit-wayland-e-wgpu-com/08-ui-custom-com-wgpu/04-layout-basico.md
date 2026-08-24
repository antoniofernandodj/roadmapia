## Layout Básico

Uma interface gráfica precisa organizar seus elementos na tela de forma coerente. O desafio começa quando você tem um botão que deve ficar 20 pixels à direita de uma caixa de texto, que por sua vez precisa se expandir para ocupar o espaço restante da janela. Como implementar isso sem hardcodar posições que quebram ao redimensionar a janela?

O sistema de layout que vamos construir tem três componentes principais:

1. **Medidas**: cada widget declara seu tamanho desejado
2. **Alocação**: o pai distribui o espaço disponível entre os filhos
3. **Posicionamento**: os filhos se posicionam dentro da área alocada

Vamos começar com um retângulo colorido que se ajusta ao tamanho da janela:

```rust
struct Rect {
    color: wgpu::Color,
    bounds: Rectangle,
}

impl Rect {
    fn new(color: [f32; 4]) -> Self {
        Self {
            color: wgpu::Color { r: color[0], g: color[1], b: color[2], a: color[3] },
            bounds: Rectangle::default(),
        }
    }

    fn layout(&mut self, constraints: Constraints) -> Size {
        self.bounds.size = constraints.max;
        constraints.max
    }

    fn render(&self, render_pass: &mut wgpu::RenderPass) {
        let vertices = self.bounds.to_vertices(self.color);
        render_pass.set_vertex_buffer(0, vertices.slice(..));
        render_pass.draw(0..6, 0..1);
    }
}
```

O erro mais comum aqui é esquecer de atualizar `bounds.size` no método `layout`. Se você fizer isso, verá o retângulo renderizado com tamanho zero:

```
wgpu error: Vertex buffer is empty
```

O sistema de constraints funciona com dois valores para cada dimensão:
- `min`: tamanho mínimo que o widget aceita
- `max`: tamanho máximo que o widget pode ocupar

```rust
pub struct Constraints {
    pub min: Size,
    pub max: Size,
}

impl Constraints {
    pub fn tight(size: Size) -> Self {
        Self {
            min: size,
            max: size,
        }
    }

    pub fn loose(max: Size) -> Self {
        Self {
            min: Size::ZERO,
            max,
        }
    }
}
```

Para empilhar widgets verticalmente, criamos um `Column`:

```rust
struct Column {
    children: Vec<Box<dyn Widget>>,
    spacing: f32,
}

impl Column {
    fn layout(&mut self, constraints: Constraints) -> Size {
        let mut y = 0.0;
        let mut width = 0.0;

        for child in &mut self.children {
            let child_size = child.layout(Constraints {
                min: Size::new(constraints.min.width, 0.0),
                max: Size::new(constraints.max.width, f32::INFINITY),
            });
            
            width = width.max(child_size.width);
            y += child_size.height + self.spacing;
        }

        Size::new(width, y - self.spacing)
    }
}
```

Se você esquecer de subtrair `self.spacing` no cálculo final, verá um espaço vazio abaixo do último elemento. Teste com esta hierarquia:

```rust
let mut col = Column::new(10.0);
col.add(Rect::new([1.0, 0.0, 0.0, 1.0]));
col.add(Rect::new([0.0, 1.0, 0.0, 1.0]));

let size = col.layout(Constraints::loose(Size::new(300.0, 600.0)));
assert_eq!(size.height, 210.0); // 100 + 10 + 100
```

Para posicionar os filhos corretamente durante a renderização, cada widget precisa saber sua posição absoluta na tela. Modificamos o trait `Widget` para incluir um método `set_position`:

```rust
trait Widget {
    fn layout(&mut self, constraints: Constraints) -> Size;
    fn set_position(&mut self, position: Point);
    fn render(&self, render_pass: &mut wgpu::RenderPass);
}
```

O exercício final é implementar um `Padding` widget que adiciona espaço ao redor de um filho:

```rust
struct Padding {
    child: Box<dyn Widget>,
    top: f32,
    right: f32,
    bottom: f32,
    left: f32,
}

impl Widget for Padding {
    fn layout(&mut self, constraints: Constraints) -> Size {
        let child_constraints = Constraints {
            min: Size::new(
                constraints.min.width - self.left - self.right,
                constraints.min.height - self.top - self.bottom,
            ),
            max: Size::new(
                constraints.max.width - self.left - self.right,
                constraints.max.height - self.top - self.bottom,
            ),
        };
        
        let child_size = self.child.layout(child_constraints);
        
        Size::new(
            child_size.width + self.left + self.right,
            child_size.height + self.top + self.bottom,
        )
    }
}
```

A solução completa deve lidar com casos extremos como padding negativo ou constraints impossíveis (quando o padding é maior que o espaço disponível).