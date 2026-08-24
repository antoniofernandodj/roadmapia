## Text Rendering Básico

Renderizar texto em uma aplicação gráfica parece simples até você tentar fazê-lo eficientemente na GPU. Ao contrário de formas geométricas, texto envolve centenas de glifos com formas complexas que mudam dinamicamente. Vamos implementar um sistema básico usando atlas de texturas (uma única textura contendo todos os glifos necessários) e shaders para posicioná-los corretamente.

### O Problema Fundamental

Considere este código que tenta desenhar texto de forma ingênua:

```rust
// NÃO FAÇA ISSO - abordagem ingênua
fn draw_text(text: &str, x: f32, y: f32) {
    for (i, c) in text.chars().enumerate() {
        let glyph = load_glyph(c); // Carrega a textura do glifo
        draw_quad(x + i as f32 * 10.0, y, glyph.width, glyph.height, glyph.texture);
    }
}
```

Os problemas são:
1. **Performance**: Cada chamada a `load_glyph` gera um carregamento de textura separado
2. **Memória**: 100 caracteres = 100 texturas individuais na VRAM
3. **Alinhamento**: Espaçamento entre caracteres (kerning) é ignorado

### Solução: Atlas de Glifos

Um atlas de glifos armazena todos os caracteres necessários em uma única textura:

```rust
struct GlyphAtlas {
    texture: wgpu::Texture,
    glyphs: HashMap<char, GlyphData>,
}

struct GlyphData {
    uv_rect: (f32, f32, f32, f32), // Coordenadas UV na textura
    size: (f32, f32),              // Tamanho em pixels
    bearing: (f32, f32),           // Offset do baseline
    advance: f32,                  // Espaço até próximo caractere
}
```

### Carregando a Fonte

Usaremos a crate `rusttype` para processar fontes TrueType:

```rust
fn build_atlas(device: &wgpu::Device, font_data: &[u8]) -> GlyphAtlas {
    let font = rusttype::Font::try_from_bytes(font_data).unwrap();
    let scale = rusttype::Scale::uniform(32.0);
    
    // Pré-renderiza os glifos ASCII básicos
    let glyphs: Vec<_> = (32u8..128).filter_map(|c| {
        let c = c as char;
        font.glyph(c).scaled(scale).h_metrics().next().map(|glyph| {
            let rect = glyph.pixel_bounds()?;
            let mut bitmap = Vec::new();
            glyph.draw(|x, y, v| {
                bitmap.push((255.0 * v) as u8);
            });
            Some((c, (rect, bitmap, glyph.advance_width())))
        }).flatten()
    }).collect();
    
    // Cria textura WGPU e preenche com os glifos
    let texture = create_texture(device, 512, 512);
    let mut glyph_map = HashMap::new();
    
    let mut x = 0;
    let mut y = 0;
    let mut row_height = 0;
    
    for (c, (rect, bitmap, advance)) in glyphs {
        if x + rect.width() > 512 {
            x = 0;
            y += row_height;
            row_height = 0;
        }
        
        // Copia bitmap para a textura
        texture.write(x, y, rect.width(), rect.height(), &bitmap);
        
        glyph_map.insert(c, GlyphData {
            uv_rect: (
                x as f32 / 512.0,
                y as f32 / 512.0,
                (x + rect.width()) as f32 / 512.0,
                (y + rect.height()) as f32 / 512.0
            ),
            size: (rect.width() as f32, rect.height() as f32),
            bearing: (rect.min.x as f32, rect.min.y as f32),
            advance,
        });
        
        x += rect.width();
        row_height = row_height.max(rect.height());
    }
    
    GlyphAtlas { texture, glyphs: glyph_map }
}
```

### Renderizando o Texto

Com o atlas pronto, podemos renderizar strings eficientemente:

```rust
struct TextRenderer {
    atlas: GlyphAtlas,
    pipeline: wgpu::RenderPipeline,
    vertex_buf: wgpu::Buffer,
    bind_group: wgpu::BindGroup,
}

impl TextRenderer {
    fn draw(&mut self, text: &str, x: f32, y: f32, queue: &wgpu::Queue) {
        let mut vertices = Vec::new();
        let mut cursor_x = x;
        let mut cursor_y = y;
        
        for c in text.chars() {
            if let Some(glyph) = self.atlas.glyphs.get(&c) {
                let x0 = cursor_x + glyph.bearing.0;
                let y0 = cursor_y - glyph.bearing.1;
                let x1 = x0 + glyph.size.0;
                let y1 = y0 + glyph.size.1;
                
                vertices.extend(&[
                    TextVertex { pos: [x0, y0], uv: [glyph.uv_rect.0, glyph.uv_rect.1] },
                    TextVertex { pos: [x1, y0], uv: [glyph.uv_rect.2, glyph.uv_rect.1] },
                    TextVertex { pos: [x1, y1], uv: [glyph.uv_rect.2, glyph.uv_rect.3] },
                    TextVertex { pos: [x0, y0], uv: [glyph.uv_rect.0, glyph.uv_rect.1] },
                    TextVertex { pos: [x1, y1], uv: [glyph.uv_rect.2, glyph.uv_rect.3] },
                    TextVertex { pos: [x0, y1], uv: [glyph.uv_rect.0, glyph.uv_rect.3] },
                ]);
                
                cursor_x += glyph.advance;
            }
        }
        
        queue.write_buffer(&self.vertex_buf, 0, bytemuck::cast_slice(&vertices));
    }
}
```

### Shader de Texto

O vertex e fragment shader precisam lidar com as coordenadas UV:

```rust
// Vertex shader
[[stage(vertex)]]
fn vs_main(
    [[location(0)]] pos: vec2<f32>,
    [[location(1)]] uv: vec2<f32>,
) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = vec4<f32>(pos, 0.0, 1.0);
    out.uv = uv;
    return out;
}

// Fragment shader
[[stage(fragment)]]
fn fs_main(
    [[location(0)]] uv: vec2<f32>,
    [[binding(0)]] tex: texture_2d<f32>,
    [[binding(1)]] smp: sampler,
) -> [[location(0)]] vec4<f32> {
    let value = textureSample(tex, smp, uv).r;
    return vec4<f32>(1.0, 1.0, 1.0, value);
}
```

### Erro Comum: Esquecer o Baseline

Um erro frequente é ignorar o baseline (linha de base) das fontes, fazendo com que caracteres como 'g' e 'y' apareçam desalinhados:

```rust
// ERRADO - ignora o baseline
let y0 = cursor_y; // Deve ser cursor_y - bearing.y
```

A saída ficará assim (com 'y' e 'g' mal posicionados):
```
Hello wyrd
```

### Exemplo Completo

Juntando tudo, aqui está como inicializar e usar o renderizador:

```rust
fn main() {
    // Inicialização do WGPU e Winit omitida por brevidade
    
    let font_data = include_bytes!("Roboto-Regular.ttf");
    let atlas = build_atlas(&device, font_data);
    
    let renderer = TextRenderer::new(&device, &atlas);
    
    event_loop.run(move |event, _, control_flow| {
        match event {
            Event::RedrawRequested(_) => {
                let mut encoder = device.create_command_encoder();
                let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    // Configuração omitida
                });
                
                renderer.draw("Hello World!", 50.0, 50.0, &queue);
                render_pass.end();
                
                queue.submit(std::iter::once(encoder.finish()));
            }
            _ => (),
        }
    });
}
```

### Exercício: Suporte a Unicode Básico

Modifique o `GlyphAtlas` para suportar caracteres Unicode além do ASCII básico. A solução deve:
1. Carregar glifos sob demanda quando encontrados
2. Expandir a textura do atlas quando necessário
3. Manter um cache LRU para glifos raramente usados

**Solução comentada**:

```rust
impl GlyphAtlas {
    fn get_glyph(&mut self, c: char, font: &rusttype::Font) -> &GlyphData {
        self.glyphs.entry(c).or_insert_with(|| {
            // Lógica para renderizar novo glifo
            // Se a textura estiver cheia, dobre seu tamanho
            if self.texture.remaining_space() < estimated_size {
                self.resize_texture(self.texture.width() * 2);
            }
            
            // Renderiza o novo glifo e adiciona ao atlas
            // Implementação similar a build_atlas
        })
    }
}
```