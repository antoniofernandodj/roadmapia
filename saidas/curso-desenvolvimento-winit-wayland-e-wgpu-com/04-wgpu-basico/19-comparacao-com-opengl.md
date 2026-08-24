## Comparação com OpenGL

Quando você vem do OpenGL para o WGPU, a primeira impressão é de que tudo ficou mais complexo. Mas essa complexidade adicional existe por um motivo: WGPU reflete como as GPUs modernas realmente funcionam, enquanto OpenGL esconde muitos detalhes que hoje são críticos para performance.

### Estado Global vs. Pipeline Explicito

No OpenGL, você altera o estado global da máquina de estado fixa:

```rust
// OpenGL (pseudo-código)
glEnable(GL_DEPTH_TEST);
glDepthFunc(GL_LESS);
glBindTexture(GL_TEXTURE_2D, texture_id);
glDrawArrays(GL_TRIANGLES, 0, 3);
```

Em WGPU, você declara todo o estado antecipadamente no pipeline:

```rust
// WGPU
let render_pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
    depth_stencil: Some(DepthStencilState {
        format: TextureFormat::Depth32Float,
        depth_write_enabled: true,
        depth_compare: CompareFunction::Less,
        ..Default::default()
    }),
    // ... outros estados
});
```

A diferença crucial é que no OpenGL o estado pode mudar a qualquer momento (e frequentemente causa bugs sutis), enquanto no WGPU o pipeline é imutável após criação - você sabe exatamente quais operações são válidas em cada ponto.

### Gerenciamento de Memória

OpenGL gerencia memória de forma opaca:

```rust
let mut vbo: GLuint = 0;
glGenBuffers(1, &mut vbo);
glBindBuffer(GL_ARRAY_BUFFER, vbo);
glBufferData(GL_ARRAY_BUFFER, size, data, GL_STATIC_DRAW);
```

WGPU torna explícito quem controla cada recurso:

```rust
let buffer = device.create_buffer(&BufferDescriptor {
    size: buffer_size,
    usage: BufferUsages::VERTEX | BufferUsages::COPY_DST,
    mapped_at_creation: false,
});

queue.write_buffer(&buffer, 0, bytemuck::cast_slice(&vertex_data));
```

O erro mais comum ao migrar é esquecer que em WGPU você precisa explicitamente:
1. Especificar todos os usos possíveis do buffer (`VERTEX`, `COPY_DST`, etc)
2. Gerenciar manualmente uploads de dados via `Queue`
3. Lidar com alinhamentos de memória (ex: `write_buffer` requer alinhamento de 256 bytes)

### Shaders e Bindings

OpenGL usa binding points mágicos:

```glsl
// GLSL
uniform sampler2D diffuseTexture;
uniform mat4 modelViewProjection;
```

WGPU requer bind groups explícitos:

```rust
// WGSL
@group(0) @binding(0) var diffuse_texture: texture_2d<f32>;
@group(0) @binding(1) var<uniform> mvp: Mat4x4<f32>;
```

E no código Rust:

```rust
let bind_group = device.create_bind_group(&BindGroupDescriptor {
    layout: &bind_group_layout,
    entries: &[
        BindGroupEntry {
            binding: 0,
            resource: BindingResource::TextureView(&texture_view),
        },
        BindGroupEntry {
            binding: 1,
            resource: BindingResource::Buffer(uniform_buffer.as_entire_buffer_binding()),
        },
    ],
});
```

Se você esquecer de criar o bind group ou errar os índices, o erro será claro:

```
Validation Error: Bind group 0 entry 1 expects buffer binding, got texture
```

### Sincronização

OpenGL tem sincronização implícita que frequentemente causa gargalos:

```rust
glDrawArrays(...);
glReadPixels(...); // Bloqueia até a renderização terminar
```

WGPU é explicitamente assíncrono:

```rust
queue.submit(std::iter::once(encoder.finish()));
surface_texture.present(); // Não bloqueia
```

Para sincronização explícita, você usa:

```rust
let fence = device.create_fence();
queue.submit(Some(encoder.finish()));
device.poll(wgpu::Maintain::WaitForFence(fence)); // Bloqueia se necessário
```

### Erros Comuns na Migração

1. **Esquecer de finalizar o command buffer**:
   ```rust
   let command_buffer = encoder.finish(); // Obrigatório!
   queue.submit(Some(command_buffer));
   ```

   Sem o `finish()`, você verá:
   ```
   Validation Error: Command buffer handle does not exist
   ```

2. **Não verificar limites do adapter**:
   ```rust
   // Sem isso, pode falhar em GPUs diferentes
   let limits = adapter.limits();
   if required_buffer_size > limits.max_buffer_size {
       panic!("Buffer muito grande para esta GPU!");
   }
   ```

3. **Confundir Queue com Device**:
   - `Device`: cria recursos (buffers, texturas)
   - `Queue`: envia comandos e dados

### Quando OpenGL ainda faz sentido

WGPU não é sempre a melhor escolha:
- Dispositivos muito antigos (OpenGL 2.1)
- Prototipagem rápida onde a sobrecarga de boilerplate não vale a pena
- Projetos que precisam rodar em navegadores antigos (WebGL 1.0)

### Exercício Prático

Converta este trecho OpenGL para WGPU:

```c
// OpenGL
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
glBindVertexArray(vao);
glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
```

Solução:

```rust
// WGPU
let render_pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
    fragment: FragmentState {
        target: &[Some(ColorTargetState {
            format: swapchain_format,
            blend: Some(BlendState {
                color: BlendComponent {
                    src_factor: BlendFactor::SrcAlpha,
                    dst_factor: BlendFactor::OneMinusSrcAlpha,
                    operation: BlendOperation::Add,
                },
                alpha: BlendComponent::REPLACE,
            }),
            write_mask: ColorWrites::ALL,
        })],
        // ...
    },
    // ...
});

render_pass.set_pipeline(&render_pipeline);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.set_index_buffer(index_buffer.slice(..), IndexFormat::Uint32);
render_pass.draw_indexed(0..6, 0, 0..1);
```