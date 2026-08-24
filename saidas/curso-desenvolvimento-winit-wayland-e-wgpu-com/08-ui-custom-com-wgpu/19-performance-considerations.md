## Performance Considerations

Criar interfaces gráficas fluidas em WGPU exige atenção a gargalos que não aparecem em aplicações convencionais. O problema central é a latência entre CPU e GPU: cada operação gráfica tem um custo fixo, e pequenas ineficiências acumuladas causam frames perdidos. Vamos analisar um caso real:

```rust
// Exemplo problemático: renderização ingênua de 1000 widgets
for widget in &widgets {
    encoder.begin_render_pass(&render_pass_descriptor);
    widget.draw(&mut encoder, &queue);
    encoder.finish();
    queue.submit(std::iter::once(encoder.finish()));
}
```

Esse código gera 1000 draw calls separados, cada um com overhead de sincronização. Em um teste com WGPU (RTX 3060, Linux), o frametime salta para 16ms (60 FPS máximo), impossibilitando animações suaves. A mensagem de erro do profiler é clara:

```
WARN: Excessive encoder submissions (1000), prefer batching
```

A solução é o batch rendering - agrupar geometria semelhante em buffers únicos:

```rust
// 1. Coletar vértices de todos os widgets
let mut vertices = Vec::new();
let mut indices = Vec::new();
for widget in &widgets {
    widget.append_geometry(&mut vertices, &mut indices);
}

// 2. Criar buffers unificados
let vertex_buffer = device.create_buffer_init(&BufferInitDescriptor {
    contents: bytemuck::cast_slice(&vertices),
    usage: BufferUsages::VERTEX,
});

// 3. Renderização em lote único
encoder.begin_render_pass(&render_pass_descriptor);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw_indexed(0..indices.len() as u32, 0, 0..1);
```

Resultado: 1 draw call, frametime cai para 2.3ms (430 FPS potencial). Mas surgem novos problemas:

1. **Texture Switching**: Mesclar objetos com texturas diferentes quebra o batch. Solução: atlas de texturas.

```rust
// Antes: 100 texturas individuais
// Depois: 1 textura atlas (4096x4096) com regiões mapeadas
let atlas = TextureAtlas::new(device, &[("icon1", icon1_data), ("icon2", icon2_data)]);
```

2. **State Changes**: Alterações frequentes de pipeline (blending, shaders) forçam flushes. Agrupe por estado:

```rust
// Ordenar widgets por tipo de material antes do batch
widgets.sort_by_key(|w| w.pipeline_id());
```

3. **Uploads Dinâmicos**: Atualizar buffers GPU a cada frame é caro. Use staging buffers para dados mutáveis:

```rust
let staging = device.create_buffer(BufferDescriptor {
    size: data_size,
    usage: BufferUsages::MAP_WRITE | BufferUsages::COPY_SRC,
    mapped_at_creation: true,
});

// Escrever diretamente na memória mapeada
{
    let mut view = staging.slice(..).get_mapped_range_mut();
    view.copy_from_slice(&new_data);
}

queue.write_buffer(&main_buffer, 0, &new_data); // Evitar isso
```

**Erro Comum**: Esquecer de reutilizar recursos. Este código vaza memory GPU:

```rust
fn render_frame() {
    let buffer = device.create_buffer(...); // Novo buffer a cada frame!
    // ...
}
```

A solução é cachear com `Arc<wgpu::Buffer>` e estruturas como:

```rust
struct FrameCache {
    vertex_buffers: LruCache<VertexLayout, Arc<wgpu::Buffer>>,
    uniform_buffers: HashMap<String, Arc<wgpu::Buffer>>,
}
```

**Exercício Prático**: Implemente um sistema de renderização de texto que:
1. Rasterize glyphs para uma textura atlas no startup
2. Atualize apenas regiões modificadas durante runtime
3. Use instanced rendering para caracteres repetidos

Solução:

```rust
struct GlyphRenderer {
    atlas: TextureAtlas,
    instances: HashMap<char, GlyphInstance>,
    dirty: bool,
}

impl GlyphRenderer {
    fn update_text(&mut self, text: &str) {
        for ch in text.chars() {
            if !self.atlas.contains(ch) {
                self.atlas.add_glyph(ch); // Marca 'dirty' se necessário
            }
            self.instances.entry(ch).or_insert_with(|| GlyphInstance::new(ch));
        }
        
        if self.dirty {
            self.upload_atlas(); // Upload parcial via write_texture
        }
    }
}
```