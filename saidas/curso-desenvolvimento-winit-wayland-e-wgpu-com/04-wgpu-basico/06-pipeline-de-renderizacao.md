## Pipeline de Renderização

Um pipeline de renderização em WGPU é como uma linha de montagem que transforma dados brutos em pixels na tela. Vamos construir um pipeline mínimo que desenha um triângulo colorido - o "Hello World" dos gráficos modernos.

### Estrutura Básica

Começamos definindo os estágios do pipeline em um `RenderPipelineDescriptor`:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    label: Some("Pipeline Básico"),
    layout: Some(&pipeline_layout),
    vertex: wgpu::VertexState {
        module: &shader_module,
        entry_point: "vs_main",
        buffers: &[],
    },
    fragment: Some(wgpu::FragmentState {
        module: &shader_module,
        entry_point: "fs_main",
        targets: &[Some(surface_config.format.into())],
    }),
    // ... outros campos obrigatórios
});
```

Este código falhará com:
```
Error: missing field `primitive` in initializer of `wgpu::RenderPipelineDescriptor`
```

Corrija adicionando a configuração de primitivas:

```rust
primitive: wgpu::PrimitiveState {
    topology: wgpu::PrimitiveTopology::TriangleList,
    strip_index_format: None,
    front_face: wgpu::FrontFace::Ccw,
    cull_mode: Some(wgpu::Face::Back),
    polygon_mode: wgpu::PolygonMode::Fill,
    unclipped_depth: false,
    conservative: false,
},
```

### Shader Mínimo

Crie um arquivo `shader.wgsl` com:

```wgsl
// Vertex Shader
@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
    let x = f32(i32(in_vertex_index) - 1) * 0.5;
    let y = f32(i32(in_vertex_index & 1u) * 2 - 1) * 0.5;
    return vec4<f32>(x, y, 0.0, 1.0);
}

// Fragment Shader
@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return vec4<f32>(0.4, 0.6, 0.8, 1.0);
}
```

Carregue-o com:

```rust
let shader_module = device.create_shader_module(wgpu::ShaderModuleDescriptor {
    label: Some("Shader Básico"),
    source: wgpu::ShaderSource::Wgsl(include_str!("shader.wgsl").into()),
});
```

### Executando o Pipeline

Na função de renderização:

```rust
{
    let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        label: Some("Render Pass"),
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &frame.view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
                store: true,
            },
        })],
        depth_stencil_attachment: None,
    });

    render_pass.set_pipeline(&pipeline);
    render_pass.draw(0..3, 0..1); // 3 vértices, 1 instância
}
```

Saída esperada:
```
[Uma janela com fundo preto e um triângulo azul claro no centro]
```

### Erro Comum: Falta de Synchronization

Se você esquecer de chamar `encoder.finish()` antes de submeter, verá:

```
thread 'main' panicked at 'Command buffer must be finished before submission'
```

Corrija com:

```rust
let command_buffer = encoder.finish();
queue.submit(std::iter::once(command_buffer));
```

### Exercício: Modifique o Pipeline

1. Altere o shader para desenhar um quadrado (2 triângulos, 6 vértices)
2. Mude a cor para um gradiente baseado na posição do vértice

Solução parcial para o gradiente:

```wgsl
@fragment
fn fs_main(@builtin(position) pos: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(pos.x, pos.y, 0.5, 1.0);
}
```