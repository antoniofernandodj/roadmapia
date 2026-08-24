## Performance Tuning

O editor de texto renderiza sem travamentos em buffers pequenos, mas quando o arquivo ultrapassa 10.000 linhas, a rolagem fica irregular e o consumo de memória dispara. O problema não está no Rust ou no WGPU, mas em como organizamos as operações entre CPU e GPU. Veja o gargalo real:

```rust
// ANTES: renderização ingênua
fn render_text(rope: &Rope, glyph_brush: &mut GlyphBrush) {
    for line in 0..rope.len_lines() {
        let line_text = rope.line(line).to_string();
        glyph_brush.queue(Section {
            text: &line_text,
            screen_position: (30.0, 30.0 + line as f32 * 20.0),
            ..Default::default()
        });
    }
    glyph_brush.draw_queued();
}
```

Este código converte todo o texto para String a cada frame, alocando memória desnecessariamente. O `ropey::Rope` já fornece acesso eficiente a fatias do texto:

```rust
// DEPOIS: renderização otimizada
fn render_text(rope: &Rope, glyph_brush: &mut GlyphBrush) {
    let visible_lines = current_scroll..(current_scroll + visible_line_count);
    for line in visible_lines {
        let line_slice = rope.line(line);
        glyph_brush.queue(Section {
            text: line_slice.as_str(), // Sem alocação!
            screen_position: (30.0, 30.0 + (line - current_scroll) as f32 * 20.0),
            ..Default::default()
        });
    }
    glyph_brush.draw_queued();
}
```

**Diferença prática** em um arquivo de 50.000 linhas:
- Antes: 120ms/frame, alocando 8MB por frame
- Depois: 2ms/frame, zero alocações

### Otimização 1: Vertex Buffers Dinâmicos

Quando renderizamos UI, cada botão e painel gera vértices. Criar um buffer novo a cada mudança é catastrófico:

```rust
// ERRADO: buffer novo a cada frame
let vertex_buffer = device.create_buffer_init(&BufferInitDescriptor {
    label: Some("Vertex Buffer"),
    contents: bytemuck::cast_slice(&vertices),
    usage: BufferUsages::VERTEX,
});
```

A solução é reutilizar buffers com `write_buffer`:

```rust
// CERTO: buffer reaproveitado
if vertex_buffer.size() < new_vertex_data_size {
    vertex_buffer = device.create_buffer(&BufferDescriptor {
        label: Some("Vertex Buffer"),
        size: new_vertex_data_size.next_multiple_of(256), // Alinhamento GPU
        usage: BufferUsages::VERTEX | BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });
}
queue.write_buffer(&vertex_buffer, 0, bytemuck::cast_slice(&vertices));
```

### Otimização 2: Pipeline Caching

Recompilar shaders em runtime é lento. O WGPU não tem cache interno, mas podemos implementar:

```rust
struct PipelineCache {
    pipelines: HashMap<(ShaderKey, VertexLayout), wgpu::RenderPipeline>,
}

impl PipelineCache {
    fn get_pipeline(
        &mut self,
        device: &wgpu::Device,
        shader_key: ShaderKey,
        layout: VertexLayout,
    ) -> &wgpu::RenderPipeline {
        self.pipelines.entry((shader_key, layout))
            .or_insert_with(|| compile_pipeline(device, shader_key, layout))
    }
}
```

### Otimização 3: Batch Rendering

Desenhar cada caractere individualmente causa overhead. Agrupe por textura e estado:

```rust
// Agrupa por fonte/cor
let mut batches: HashMap<(FontId, Color), Vec<Section>> = HashMap::new();

for section in text_sections {
    batches.entry((section.font_id, section.color))
           .or_default()
           .push(section);
}

for ((font_id, color), sections) in batches {
    glyph_brush.queue(sections);
    glyph_brush.draw_queued_with_transform(projection);
}
```

### Exercício Prático

Implemente um sistema de cache para vértices de UI que:
1. Mantém buffers alocados entre frames
2. Redimensiona buffers apenas quando necessário
3. Reutiliza memória para elementos que não mudaram

**Solução comentada**:

```rust
struct UiVertexCache {
    buffer: wgpu::Buffer,
    current_size: usize,
    generation: u32,
    last_used: HashMap<UiElementId, (u32, Range<usize>)>,
}

impl UiVertexCache {
    fn update(
        &mut self,
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        elements: &[UiElement],
    ) {
        let needed_size = elements.iter().map(|e| e.vertex_size()).sum();
        
        // Redimensiona o buffer se necessário (com padding para alinhamento)
        if needed_size > self.current_size {
            self.buffer = device.create_buffer(&BufferDescriptor {
                size: (needed_size * 3 / 2).next_multiple_of(256), // Oversize + alinhamento
                usage: BufferUsages::VERTEX | BufferUsages::COPY_DST,
                ..Default::default()
            });
            self.current_size = needed_size;
            self.last_used.clear(); // Força upload completo
        }

        let mut offset = 0;
        self.generation += 1;

        for element in elements {
            let vertex_data = element.generate_vertices();
            let data_size = vertex_data.len() * mem::size_of::<Vertex>();

            // Verifica se o elemento mudou
            if let Some((gen, range)) = self.last_used.get(&element.id) {
                if *gen == self.generation - 1 && data_size == range.len() {
                    offset += data_size;
                    continue; // Dados idênticos, pula o upload
                }
            }

            queue.write_buffer(&self.buffer, offset as u64, bytemuck::cast_slice(&vertex_data));
            self.last_used.insert(element.id, (self.generation, offset..offset + data_size));
            offset += data_size;
        }
    }
}
```