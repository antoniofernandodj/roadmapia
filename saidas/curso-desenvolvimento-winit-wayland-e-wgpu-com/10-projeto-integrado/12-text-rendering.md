## Text Rendering

Renderizar texto eficientemente em uma aplicação gráfica é um problema aparentemente simples que rapidamente se torna complexo. Considere um editor de texto básico: cada caractere precisa ser posicionado com precisão, renderizado com a fonte correta, e atualizado dinamicamente conforme o usuário digita. A solução ingênua — gerar texturas para cada caractere sob demanda — falha em escala, enquanto abordagens muito complexas introduzem overhead desnecessário.

### O Pipeline de Renderização de Texto

O processo completo envolve quatro etapas principais:

1. **Layout do Texto**: Determinar posições de cada glifo (representação visual de um caractere) considerando kerning, quebras de linha e direção do texto.
2. **Cache de Glifos**: Armazenar representações rasterizadas dos caracteres para reutilização.
3. **Geração de Vértices**: Criar geometria (quads) para cada glifo visível na tela.
4. **Renderização**: Desenhar os quads usando um shader especializado.

Vamos implementar cada parte com `wgpu_glyph`, uma biblioteca que abstrai essa complexidade enquanto mantém controle fino sobre o processo.

### Configuração Inicial

Primeiro, adicione as dependências ao `Cargo.toml`:

```toml
[dependencies]
wgpu_glyph = "0.18"
glyph_brush = "0.7"
```

A estrutura básica do renderizador:

```rust
pub struct TextRenderer {
    glyph_brush: wgpu_glyph::GlyphBrush<()>,
    section_cache: HashMap<String, wgpu_glyph::Section>,
}
```

Inicialização com o dispositivo WGPU:

```rust
impl TextRenderer {
    pub fn new(device: &wgpu::Device, format: wgpu::TextureFormat) -> Self {
        let glyph_brush = wgpu_glyph::GlyphBrushBuilder::using_font_bytes(include_bytes!("fonts/Roboto-Regular.ttf"))
            .build(device, format);
        
        Self {
            glyph_brush,
            section_cache: HashMap::new(),
        }
    }
}
```

### Renderizando Texto Básico

Para desenhar texto na tela, criamos uma "seção" que define conteúdo e posição:

```rust
pub fn draw_text(&mut self, text: &str, position: [f32; 2], color: [f32; 4], queue: &wgpu::Queue, encoder: &mut wgpu::CommandEncoder, target: &wgpu::TextureView) {
    let section = wgpu_glyph::Section {
        screen_position: position,
        bounds: [f32::INFINITY; 2],
        text: vec![
            wgpu_glyph::Text::new(text)
                .with_color(color)
                .with_scale(24.0),
        ],
        ..Default::default()
    };

    self.glyph_brush.queue(section);
    self.glyph_brush
        .draw_queued(device, &staging_belt, encoder, target)
        .expect("Failed to draw text");
}
```

Problema comum: esquecer de chamar `draw_queued` resulta em texto ausente sem mensagens de erro. A saída esperada é um texto branco no canto superior esquerdo da janela.

### Cache de Seções

Para texto estático (como labels de UI), podemos otimizar evitando recriação de seções:

```rust
pub fn draw_cached(&mut self, key: &str, text: &str, position: [f32; 2], color: [f32; 4]) {
    if !self.section_cache.contains_key(key) {
        let section = wgpu_glyph::Section {
            // ... mesma construção anterior
        };
        self.section_cache.insert(key.to_string(), section);
    }

    let section = self.section_cache.get(key).unwrap();
    self.glyph_brush.queue(section.clone());
}
```

### Alinhamento e Layout

Para alinhamento centralizado ou à direita, calculamos as dimensões do texto primeiro:

```rust
pub fn get_text_bounds(&mut self, text: &str, scale: f32) -> [f32; 2] {
    let section = wgpu_glyph::Section {
        text: vec![wgpu_glyph::Text::new(text).with_scale(scale)],
        ..Default::default()
    };

    let bounds = self.glyph_brush
        .glyph_brush()
        .compute_glyphs(&[section], &Default::default())
        .map(|g| g.glyph.position)
        .fold([0.0, 0.0], |[max_x, max_y], pos| {
            [max_x.max(pos.x + pos.width), max_y.max(pos.y + pos.height)]
        });

    bounds
}
```

### Erro Comum: Falta de Atualização

Um erro frequente é esquecer de reconstruir o cache quando a janela é redimensionada ou o DPI muda:

```rust
pub fn rebuild_cache(&mut self, new_scale_factor: f64) {
    self.glyph_brush.glyph_brush_mut().resize_scale(new_scale_factor as f32);
    self.section_cache.clear(); // Força recriação com novo scale factor
}
```

### Integração com o Editor

No editor, armazenamos buffers de texto e informações de layout:

```rust
pub struct TextBuffer {
    pub rope: ropey::Rope,
    pub line_metrics: Vec<LineMetric>,
}

pub struct LineMetric {
    pub y_offset: f32,
    pub height: f32,
    pub glyphs: Vec<GlyphPosition>,
}

pub struct GlyphPosition {
    pub x: f32,
    pub chr: char,
    pub color: [f32; 4],
}
```

### Exercício Prático

**Problema**: Implemente um visualizador de texto que:
1. Exibe um arquivo carregado com syntax highlighting básico (palavras-chave em azul)
2. Rola suavemente com o mouse
3. Mostra números de linha à esquerda

**Solução**:

```rust
// Estrutura de estado
pub struct TextViewer {
    text_buffer: TextBuffer,
    scroll_offset: f32,
    line_number_width: f32,
}

impl TextViewer {
    pub fn draw(&mut self, renderer: &mut TextRenderer, queue: &wgpu::Queue, encoder: &mut wgpu::CommandEncoder, target: &wgpu::TextureView) {
        // Números de linha
        for (i, line) in self.text_buffer.rope.lines().enumerate() {
            let line_num = (i + 1).to_string();
            let y_pos = i as f32 * LINE_HEIGHT - self.scroll_offset;
            
            renderer.draw_text(
                &line_num,
                [5.0, y_pos],
                [0.5, 0.5, 0.5, 1.0], // Cinza
                queue,
                encoder,
                target
            );
        }

        // Texto principal
        for (i, line) in self.text_buffer.rope.lines().enumerate() {
            let y_pos = i as f32 * LINE_HEIGHT - self.scroll_offset;
            let mut x_pos = self.line_number_width;
            
            for chr in line.chars() {
                let color = if KEYWORDS.contains(&chr.to_string().as_str()) {
                    [0.2, 0.5, 1.0, 1.0] // Azul para palavras-chave
                } else {
                    [0.9, 0.9, 0.9, 1.0] // Branco padrão
                };
                
                renderer.draw_text(
                    &chr.to_string(),
                    [x_pos, y_pos],
                    color,
                    queue,
                    encoder,
                    target
                );
                
                x_pos += CHAR_WIDTH;
            }
        }
    }
}
```