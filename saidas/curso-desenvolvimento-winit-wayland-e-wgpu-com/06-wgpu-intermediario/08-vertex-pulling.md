## Vertex Pulling

Quando você tem milhares de objetos para renderizar, chamar `draw` para cada um deles individualmente cria uma sobrecarga significativa na CPU. O vertex pulling resolve isso movendo a lógica de seleção de vértices para a GPU, usando um buffer indireto que contém todos os parâmetros necessários para as chamadas de desenho.

Vamos começar com um exemplo problemático que você provavelmente já enfrentou:

```rust
// Código ineficiente - chamadas de draw individuais
for object in &objects {
    render_pass.set_pipeline(&pipeline);
    render_pass.set_vertex_buffer(0, object.vertex_buffer.slice(..));
    render_pass.set_index_buffer(object.index_buffer.slice(..), wgpu::IndexFormat::Uint32);
    render_pass.draw_indexed(0..object.index_count, 0, 0..1);
}
```

O problema aqui é evidente: para 10.000 objetos, você faz 10.000 chamadas de API, mesmo que todos compartilhem o mesmo pipeline e shaders. A solução é mover esses parâmetros para a GPU.

### Implementando Vertex Pulling

Primeiro, criamos um buffer que contém todos os parâmetros de desenho:

```rust
#[repr(C)]
#[derive(Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct DrawIndirect {
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
}

let draw_commands: Vec<DrawIndirect> = objects.iter()
    .map(|obj| DrawIndirect {
        vertex_count: obj.vertex_count,
        instance_count: 1,
        first_vertex: obj.vertex_offset,
        first_instance: 0,
    })
    .collect();

let indirect_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Indirect Buffer"),
    contents: bytemuck::cast_slice(&draw_commands),
    usage: wgpu::BufferUsages::INDIRECT | wgpu::BufferUsages::COPY_DST,
});
```

Agora, modificamos o shader de vértice para "puxar" os dados corretos:

```rust
// WGSL
struct DrawCommand {
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
};

[[group(0), binding(0)]] var<storage, read> draw_commands: array<DrawCommand>;

[[stage(vertex)]]
fn vs_main(
    [[builtin(vertex_index)]] vertex_idx: u32,
    [[builtin(instance_index)]] instance_idx: u32,
) -> VertexOutput {
    let cmd = draw_commands[instance_idx];
    let actual_vertex = cmd.first_vertex + (vertex_idx % cmd.vertex_count);
    // ... continua com o processamento normal do vértice
}
```

O erro mais comum aqui é esquecer de atualizar o layout do bind group:

```rust
// ERRO COMUM: BindGroupLayout não corresponde ao shader
let layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[
        wgpu::BindGroupLayoutEntry {
            binding: 0,
            visibility: wgpu::ShaderStages::VERTEX,
            ty: wgpu::BindingType::Buffer {
                ty: wgpu::BufferBindingType::Storage { read_only: true },
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        },
    ],
});
```

A chamada de renderização final fica drasticamente simplificada:

```rust
render_pass.set_pipeline(&pipeline);
render_pass.set_bind_group(0, &bind_group, &[]);
render_pass.set_vertex_buffer(0, mega_vertex_buffer.slice(..));
render_pass.draw_indirect(&indirect_buffer, 0);
```

### Comparação de Performance

Em um teste com 10.000 objetos simples:
- Método tradicional: ~2.3ms por frame
- Vertex pulling: ~0.4ms por frame

A diferença vem principalmente da redução das chamadas entre CPU-GPU. A GPU pode processar todos os objetos em lotes contíguos sem interrupções.

### Exercício Prático

Modifique o código para suportar instancing combinado com vertex pulling. O buffer indireto deve conter tanto os parâmetros de desenho quanto os dados de instância (posição, escala).

**Solução:**

```rust
#[repr(C)]
#[derive(Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct DrawIndirect {
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
    position: [f32; 3],
    scale: f32,
};

// No shader:
let transform = mat4x4<f32>(
    vec4(cmd.scale, 0.0, 0.0, 0.0),
    vec4(0.0, cmd.scale, 0.0, 0.0),
    vec4(0.0, 0.0, cmd.scale, 0.0),
    vec4(cmd.position, 1.0)
);
```