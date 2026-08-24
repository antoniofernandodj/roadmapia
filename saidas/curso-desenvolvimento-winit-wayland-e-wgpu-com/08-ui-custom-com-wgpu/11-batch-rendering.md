## Batch Rendering

Renderizar milhares de objetos individuais com um draw call para cada um é um caminho direto para o gargalo de desempenho. Considere uma interface com 100 botões - sem batch rendering, você estaria fazendo:

```rust
for button in &buttons {
    renderer.draw_button(button); // 100 draw calls!
}
```

O problema real está na comunicação CPU-GPU. Cada `draw()` tem overhead fixo de validação e sincronização. WGPU mostra o impacto quando você excede ~1000 draw calls por frame - o FPS despenca mesmo para objetos simples.

A solução é agrupar geometrias compatíveis em buffers únicos e renderizá-las em lotes. Veja a diferença na prática com um exemplo de renderização de texto:

```rust
// ANTES (ineficiente)
for character in text.chars() {
    let glyph = font.get_glyph(character);
    renderer.draw_glyph(glyph); // Draw call por caractere!
}

// DEPOIS (com batch)
let mut vertex_buffer = Vec::new();
for character in text.chars() {
    let glyph = font.get_glyph(character);
    vertex_buffer.extend(glyph.to_vertices()); // Acumula vértices
}
renderer.draw_vertices(&vertex_buffer); // Único draw call
```

O segredo está em quatro componentes:

1. **Vertex Buffer Único**: Acumula todos os vértices dos objetos compatíveis (mesmo shader, mesma textura)
2. **Index Buffer de Offset**: Usa índices relativos para partes diferentes do buffer
3. **Texture Atlas**: Agrupa múltiplas imagens em uma única textura GPU
4. **Uniforms Dinâmicos**: Matrizes de transformação por objeto em buffer separado

Implementando isso corretamente, seu código de renderização muda radicalmente. Veja a estrutura de dados central:

```rust
pub struct RenderBatch {
    pipeline: wgpu::RenderPipeline,
    vertex_buffer: wgpu::Buffer,
    index_buffer: wgpu::Buffer,
    index_counts: Vec<(u32, u32)>, // (start, count)
    texture: wgpu::BindGroup,
}

impl RenderBatch {
    pub fn add_mesh(&mut self, vertices: &[Vertex], indices: &[u16]) {
        // Atualiza buffers GPU (omiti implementação por brevity)
        self.index_counts.push((start_idx, indices.len() as u32));
    }

    pub fn execute(&self, pass: &mut wgpu::RenderPass) {
        pass.set_pipeline(&self.pipeline);
        pass.set_vertex_buffer(0, self.vertex_buffer.slice(..));
        pass.set_index_buffer(self.index_buffer.slice(..), wgpu::IndexFormat::Uint16);
        
        for (start_idx, count) in &self.index_counts {
            pass.draw_indexed(*start_idx..(*start_idx + *count), 0, 0..1);
        }
    }
}
```

Erro comum: esquecer que objetos no mesmo batch devem compartilhar pipeline e textura. Se tentar misturar:

```rust
batch.add_mesh(&red_button_verts, &red_button_indices);
batch.add_mesh(&blue_button_verts, &blue_button_indices); // ERRO: Textura diferente!
```

O WGPU emitirá:
```
Validation Error: Bind group at index 0 is not compatible with pipeline layout
```

A solução é agrupar por material/textura. Na prática, você terá múltiplos batches ativos:

```rust
let mut batches: HashMap<TextureId, RenderBatch> = HashMap::new();

for ui_element in ui_elements {
    let batch = batches.entry(element.texture_id)
        .or_insert_with(|| create_batch_for_texture(element.texture));
    batch.add_mesh(element.vertices(), element.indices());
}
```

**Exercício Prático**: Converta um sistema de renderização de ícones que faz um draw call por ícone para usar batch rendering. Os ícones estão em um atlas de textura com esta estrutura:

```rust
struct Icon {
    position: (f32, f32),
    size: (f32, f32),
    atlas_coords: (f32, f32), // UV min
    atlas_size: (f32, f32),   // UV width/height
}
```

**Solução**:

```rust
// 1. Criar vertex buffer unificado
let mut vertices = Vec::new();
let mut indices = Vec::new();
let mut index_offset = 0;

for icon in icons {
    let (x, y) = icon.position;
    let (w, h) = icon.size;
    let (u, v) = icon.atlas_coords;
    let (uw, uh) = icon.atlas_size;

    vertices.extend(&[
        Vertex { pos: [x, y, 0.0], uv: [u, v] },
        Vertex { pos: [x + w, y, 0.0], uv: [u + uw, v] },
        Vertex { pos: [x + w, y + h, 0.0], uv: [u + uw, v + uh] },
        Vertex { pos: [x, y + h, 0.0], uv: [u, v + uh] },
    ]);

    indices.extend(&[
        index_offset, index_offset + 1, index_offset + 2,
        index_offset, index_offset + 2, index_offset + 3,
    ]);
    
    index_offset += 4;
}

// 2. Upload para GPU (exemplo simplificado)
let vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Icon Batch VB"),
    contents: bytemuck::cast_slice(&vertices),
    usage: wgpu::BufferUsages::VERTEX,
});

// 3. Renderizar em único draw call
render_pass.set_pipeline(icon_pipeline);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw(0..vertices.len() as u32, 0..1);
```

A chave é perceber que a otimização vem da redução de chamadas de API, não necessariamente da quantidade de dados transferidos. Mesmo com mais vértices na CPU, o ganho de performance é significativo.