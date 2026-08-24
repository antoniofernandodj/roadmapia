## Arquitetura de UI Custom

Uma interface de usuário renderizada diretamente na GPU difere radicalmente dos toolkits tradicionais baseados em widgets do sistema operacional. Aqui, cada pixel é controlado por sua aplicação, desde o retângulo mais simples até textos complexos. Veja como isso se estrutura:

### Pipeline de Renderização

O núcleo de uma UI custom é um grafo de renderização que transforma comandos abstratos (como "desenhar um botão") em operações concretas na GPU. Um fluxo típico opera em três fases:

```rust
// Exemplo simplificado do fluxo principal
fn render_ui_frame(
    widgets: &[Widget],
    gpu_ctx: &mut GpuContext,
    input_state: &InputState
) {
    // 1. Processamento de layout
    let layout_tree = calculate_layout(widgets, input_state.window_size);
    
    // 2. Geração de comandos de desenho
    let mut draw_commands = Vec::new();
    for node in layout_tree.traverse() {
        node.widget.generate_commands(&mut draw_commands);
    }
    
    // 3. Execução na GPU
    let mut render_pass = gpu_ctx.begin_render_pass();
    for cmd in draw_commands {
        cmd.execute(&mut render_pass);
    }
}
```

### Componentes Fundamentais

1. **Widgets**: Unidades atômicas da UI (botões, textos, containers). Cada um sabe como se desenhar:

```rust
trait Widget {
    fn layout(&self, constraints: LayoutConstraints) -> LayoutResult;
    fn generate_commands(&self, commands: &mut Vec<DrawCommand>);
}

struct Button {
    text: String,
    bounds: Rect,
    state: ButtonState,
}

impl Widget for Button {
    fn generate_commands(&self, commands: &mut Vec<DrawCommand>) {
        // Background
        commands.push(DrawCommand::Rectangle {
            rect: self.bounds,
            color: match self.state {
                ButtonState::Normal => Color::rgb(0.2, 0.5, 0.8),
                ButtonState::Hovered => Color::rgb(0.3, 0.6, 0.9),
                ButtonState::Pressed => Color::rgb(0.1, 0.4, 0.7),
            },
        });
        
        // Texto (simplificado)
        commands.push(DrawCommand::Text {
            position: self.bounds.center(),
            content: self.text.clone(),
            color: Color::WHITE,
        });
    }
}
```

2. **Sistema de Layout**: Resolve restrições espaciais como o CSS Flexbox, mas mais leve:

```rust
struct LayoutConstraints {
    min_width: f32,
    max_width: f32,
    min_height: f32,
    max_height: f32,
}

struct LayoutResult {
    width: f32,
    height: f32,
    children: Vec<LayoutNode>,
}
```

3. **GPU Abstraction Layer**: Traduz comandos lógicos para WGPU:

```rust
enum DrawCommand {
    Rectangle { rect: Rect, color: Color },
    Text { position: Point, content: String, color: Color },
    // Outros primitivos...
}

impl DrawCommand {
    fn execute(&self, render_pass: &mut wgpu::RenderPass) {
        match self {
            Self::Rectangle { rect, color } => {
                // Upload geometry e uniforms para a GPU
                // Bind pipeline de retângulos
                // Draw call
            },
            // Outras implementações...
        }
    }
}
```

### Erro Comum e Correção

Um erro frequente é tentar criar widgets sem considerar o sistema de layout:

```rust
// ERRADO - coordenadas hardcoded
struct BadButton {
    x: f32,
    y: f32,
}

// CERTO - widget responsivo
struct GoodButton {
    text: String,
    // Layout calculado dinamicamente
}
```

A mensagem de erro típica quando se ignora o layout seria:
```
Widget 'BadButton' não se adapta a tamanhos de tela diferentes (400x300 vs 1920x1080)
```

### Hierarquia de Renderização

A ordem de desenho é crítica para sobreposição correta de elementos. Uma UI eficiente usa:

1. **Painéis de fundo** (primeiros a serem desenhados)
2. **Containers** (grupos lógicos)
3. **Widgets interativos** (botões, inputs)
4. **Overlays** (tooltips, menus)

```rust
// Exemplo de ordenação por camadas
draw_commands.sort_by_key(|cmd| cmd.z_index());
```

### Exercício Prático

Implemente um `Widget` simples que desenha um retângulo com borda arredondada. O widget deve:
- Aceitar cor de fundo e borda como parâmetros
- Calcular seu tamanho baseado nas constraints
- Gerar os comandos de desenho apropriados

**Solução comentada**:

```rust
struct RoundedRect {
    fill_color: Color,
    border_color: Color,
    border_radius: f32,
    // Layout calculado
    computed_size: Option<Size>,
}

impl Widget for RoundedRect {
    fn layout(&mut self, constraints: LayoutConstraints) -> LayoutResult {
        // Usa todo espaço disponível
        let width = constraints.max_width;
        let height = constraints.max_height;
        self.computed_size = Some(Size { width, height });
        LayoutResult { width, height, children: Vec::new() }
    }

    fn generate_commands(&self, commands: &mut Vec<DrawCommand>) {
        let size = self.computed_size.unwrap();
        commands.push(DrawCommand::RoundedRect {
            rect: Rect::new(0.0, 0.0, size.width, size.height),
            fill_color: self.fill_color,
            border_color: self.border_color,
            radius: self.border_radius,
        });
    }
}
```