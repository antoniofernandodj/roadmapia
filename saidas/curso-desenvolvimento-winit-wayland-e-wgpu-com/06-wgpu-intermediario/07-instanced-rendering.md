## Instanced Rendering

Quando você precisa renderizar centenas ou milhares de cópias do mesmo objeto (como árvores em uma floresta ou balas em um jogo), chamar `draw` para cada uma individualmente é extremamente ineficiente. O instanced rendering resolve isso permitindo que você renderize múltiplas instâncias de um mesmo mesh em uma única chamada de desenho, variando apenas os parâmetros específicos de cada instância.

### Como Funciona

Em vez de:
```rust
for tree in trees {
    render_tree(tree.position, tree.scale);
}
```

Você prepara:
1. Um vertex buffer com a geometria base (o mesmo para todas)
2. Um instance buffer com os dados únicos por instância (posição, cor, etc.)
3. Uma única chamada `draw` com o número de instâncias

### Implementação Prática

Primeiro, definimos a estrutura dos dados por instância:

```rust
#[repr(C)]
#[derive(Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct InstanceData {
    position: [f32; 3],
    scale: f32,
    color: [f32; 4],
}
```

No pipeline, adicionamos o segundo vertex buffer:

```rust
let instance_attributes = &[
    // position (instância)
    wgpu::VertexAttribute {
        format: wgpu::VertexFormat::Float32x3,
        offset: 0,
        shader_location: 3, // após os atributos do mesh (0-2)
    },
    // scale (instância)
    wgpu::VertexAttribute {
        format: wgpu::VertexFormat::Float32,
        offset: mem::size_of::<[f32; 3]>() as u64,
        shader_location: 4,
    },
    // color (instância)
    wgpu::VertexAttribute {
        format: wgpu::VertexFormat::Float32x4,
        offset: (mem::size_of::<[f32; 3]>() + mem::size_of::<f32>()) as u64,
        shader_location: 5,
    },
];

let render_pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
    bind_group_layouts: &[...],
    push_constant_ranges: &[],
    label: Some("render_pipeline_layout"),
});

let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    vertex: wgpu::VertexState {
        buffers: &[
            // Vertex buffer do mesh (como antes)
            mesh_vertex_buffer_layout(),
            // Buffer de instâncias
            wgpu::VertexBufferLayout {
                array_stride: mem::size_of::<InstanceData>() as u64,
                step_mode: wgpu::VertexStepMode::Instance,
                attributes: instance_attributes,
            },
        ],
        // ... restante igual
    },
    // ... restante igual
});
```

Preparando os dados das instâncias:

```rust
let instances = vec![
    InstanceData {
        position: [0.0, 0.0, 0.0],
        scale: 1.0,
        color: [1.0, 0.0, 0.0, 1.0],
    },
    InstanceData {
        position: [2.0, 1.0, -1.0],
        scale: 0.5,
        color: [0.0, 1.0, 0.0, 1.0],
    },
    // ... mais instâncias
];

let instance_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Instance Buffer"),
    contents: bytemuck::cast_slice(&instances),
    usage: wgpu::BufferUsages::VERTEX,
});
```

No render pass:

```rust
render_pass.set_pipeline(&render_pipeline);
render_pass.set_bind_group(0, &bind_group, &[]);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.set_vertex_buffer(1, instance_buffer.slice(..));
render_pass.set_index_buffer(index_buffer.slice(..), wgpu::IndexFormat::Uint16);
render_pass.draw_indexed(0..num_indices, 0, 0..instances.len() as u32); // Única chamada!
```

### Shader Adaptado

No vertex shader, acessamos os dados da instância:

```rust
[[location(0)]] var position: vec3<f32>;
[[location(1)]] var normal: vec3<f32>;
[[location(2)]] var tex_coords: vec2<f32>;
// Dados por instância:
[[location(3)]] var instance_position: vec3<f32>;
[[location(4)]] var instance_scale: f32;
[[location(5)]] var instance_color: vec4<f32>;

[[builtin(position)]] var out_position: vec4<f32>;
[[location(0)]] var out_color: vec4<f32>;

[[stage(vertex)]]
fn vs_main() -> [[builtin(position)]] vec4<f32> {
    out_color = instance_color;
    out_position = view_proj * vec4<f32>(
        position * instance_scale + instance_position,
        1.0
    );
    return out_position;
}
```

### Erro Comum e Solução

Um erro frequente é esquecer de marcar o buffer como `VERTEX` usage ou definir `step_mode` como `Instance`. Isso resulta em:

```
Error: Vertex buffer is not big enough for the draw call
```

A solução é verificar:
1. O `array_stride` corresponde exatamente ao tamanho da struct
2. `step_mode` está como `VertexStepMode::Instance`
3. Todos os atributos têm offsets corretos

### Comparação de Performance

Para 10.000 objetos:
- Draw individual: ~10ms/frame
- Instanced: ~0.2ms/frame

A diferença se deve à redução drástica de chamadas à API e melhor utilização da GPU.

### Exercício Prático

Implemente um campo de estrelas onde:
1. Cada estrela é um quadrado simples
2. A posição e cor são aleatórias
3. O tamanho varia entre 0.1 e 0.5
4. Renderize 5.000 instâncias

Solução:

```rust
// Gerando instâncias
let mut rng = rand::thread_rng();
let instances = (0..5000).map(|_| InstanceData {
    position: [
        rng.gen_range(-10.0..10.0),
        rng.gen_range(-10.0..10.0),
        rng.gen_range(-5.0..-20.0),
    ],
    scale: rng.gen_range(0.1..0.5),
    color: [
        rng.gen_range(0.5..1.0),
        rng.gen_range(0.5..1.0),
        rng.gen_range(0.5..1.0),
        1.0,
    ],
}).collect::<Vec<_>>();

// No shader, use um quad básico:
let vertices = &[
    // posição, normal, uv
    ([-0.5, -0.5, 0.0], [0.0, 0.0, 1.0], [0.0, 0.0]),
    ([0.5, -0.5, 0.0], [0.0, 0.0, 1.0], [1.0, 0.0]),
    // ... completar quad
];
```