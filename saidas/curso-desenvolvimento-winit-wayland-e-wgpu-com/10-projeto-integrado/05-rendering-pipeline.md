## Rendering Pipeline

Um editor de texto precisa renderizar milhares de caracteres por frame, cada um com posição, cor e estilo próprios, sem travar a interface. O desafio começa ao tentar desenhar texto direto na swap chain: você recebe um erro `OUT_OF_MEMORY` após alguns segundos porque cada caractere gera um draw call separado, sobrecarregando a GPU.

A solução é um pipeline de renderização estruturado em três estágios:

1. **Vertex Generation**: Transforma caracteres em vértices prontos para a GPU
2. **Batch Rendering**: Agrupa primitivas para minimizar chamadas de desenho
3. **Composição Final**: Combina layers de texto, cursor e seleção

Começamos com a estrutura básica do pipeline:

```rust
pub struct TextPipeline {
    device: Arc<wgpu::Device>,
    queue: Arc<wgpu::Queue>,
    pipeline: wgpu::RenderPipeline,
    vertex_buffers: Vec<wgpu::Buffer>,
    uniform_buf: wgpu::Buffer,
    bind_group: wgpu::BindGroup,
}
```

O erro mais comum aqui é esquecer de compartilhar `device` e `queue` via `Arc`, resultando em borrow checker travando o código quando tentamos atualizar buffers de outros threads.

A configuração do pipeline requer atenção especial aos formatos de vértice:

```rust
wgpu::VertexBufferLayout {
    array_stride: std::mem::size_of::<TextVertex>() as wgpu::BufferAddress,
    step_mode: wgpu::VertexStepMode::Vertex,
    attributes: &[
        wgpu::VertexAttribute { // posição
            offset: 0,
            shader_location: 0,
            format: wgpu::VertexFormat::Float32x2,
        },
        wgpu::VertexAttribute { // coordenadas UV
            offset: 4 * 2,
            shader_location: 1,
            format: wgpu::VertexFormat::Float32x2,
        },
        wgpu::VertexAttribute { // cor
            offset: 4 * 4,
            shader_location: 2,
            format: wgpu::VertexFormat::Float32x4,
        },
    ],
}
```

Um erro sutil ocorre se os offsets não corresponderem ao layout real da struct `TextVertex` no Rust. A mensagem de erro será obscura: `Vertex attribute is not aligned to 4 bytes`.

Para renderizar um frame completo, seguimos esta sequência:

```rust
// 1. Atualizar buffers de vértice com novos caracteres
self.update_vertex_buffers(text_chunks);

// 2. Iniciar um render pass
let mut encoder = self.device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Text Render Encoder"),
});

let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Text Render Pass"),
    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
        view: &frame_view,
        resolve_target: None,
        ops: wgpu::Operations {
            load: wgpu::LoadOp::Clear(wgpu::Color::WHITE),
            store: wgpu::StoreOp::Store,
        },
    })],
    depth_stencil_attachment: None,
});

// 3. Desenhar batches de texto
render_pass.set_pipeline(&self.pipeline);
render_pass.set_bind_group(0, &self.bind_group, &[]);

for (i, buffer) in self.vertex_buffers.iter().enumerate() {
    render_pass.set_vertex_buffer(i as u32, buffer.slice(..));
    render_pass.draw(0..buffer.size() as u32 / TEXT_VERTEX_SIZE, 0..1);
}

drop(render_pass);

// 4. Submeter comandos
self.queue.submit(std::iter::once(encoder.finish()));
```

O erro mais crítico aqui é esquecer de chamar `drop(render_pass)` antes de submeter os comandos, resultando em um panic com a mensagem `Command encoder is still locked`.

Para otimizar, implementamos instancing para caracteres repetidos:

```rust
#[derive(bytemuck::Pod, bytemuck::Zeroable, Clone, Copy)]
#[repr(C)]
struct InstanceData {
    position: [f32; 2],
    glyph_index: u32,
};

let instance_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Instance Buffer"),
    contents: bytemuck::cast_slice(&instances),
    usage: wgpu::BufferUsages::VERTEX,
});
```

Isso reduz os vértices necessários para texto estático em até 90%. O shader correspondente precisa ser ajustado para ler os dados de instância:

```glsl
// Vertex shader
layout(location = 3) in vec2 instance_pos;
layout(location = 4) in uint instance_glyph;

void main() {
    vec2 final_pos = position + instance_pos;
    gl_Position = u_view_proj * vec4(final_pos, 0.0, 1.0);
    // ...
}
```

Um exercício prático: implemente um cache de vértices que só atualiza buffers quando o texto muda. A solução envolve:

1. Um hash do conteúdo atual do buffer
2. Comparação com o hash anterior antes de atualizar
3. Uso de `wgpu::BufferUsages::COPY_DST` para atualizações parciais

```rust
impl TextPipeline {
    fn update_if_changed(&mut self, new_vertices: &[TextVertex], hash: u64) {
        if hash != self.last_hash {
            self.queue.write_buffer(
                &self.vertex_buffers[0],
                0,
                bytemuck::cast_slice(new_vertices),
            );
            self.last_hash = hash;
        }
    }
}
```