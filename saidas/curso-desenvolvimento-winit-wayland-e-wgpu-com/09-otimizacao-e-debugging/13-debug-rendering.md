## Debug Rendering

Quando você está desenvolvendo uma aplicação gráfica, especialmente com WGPU e Wayland, nem sempre é óbvio por que um objeto não aparece na tela ou por que a performance está ruim. Debug rendering resolve isso adicionando visuais temporários que revelam informações internas do sistema, sem precisar de ferramentas externas ou métricas avançadas.

### O Problema Concreto

Imagine que você tem um cubo 3D que deveria estar visível, mas não aparece. As possíveis causas são muitas:
- A matriz de transformação está errada?
- O pipeline de renderização está configurado incorretamente?
- O objeto está fora do frustum da câmera?
- Há um problema com o depth testing?

Sem visuais de debug, você teria que adivinhar ou depender de logs textuais, que não mostram a relação espacial entre os elementos.

### Implementando Linhas de Debug

Vamos começar com a ferramenta mais básica: linhas coloridas. Elas podem mostrar bounding boxes, vetores normais, ou o frustum da câmera. Primeiro, precisamos de um pipeline dedicado:

```rust
// Pipeline para debug (vertex/fragment shaders simples)
let debug_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    label: Some("Debug Pipeline"),
    layout: Some(&debug_pipeline_layout),
    vertex: wgpu::VertexState {
        module: &debug_shader,
        entry_point: "vs_main",
        buffers: &[DebugVertex::desc()], // Struct com posição e cor
    },
    fragment: Some(wgpu::FragmentState {
        module: &debug_shader,
        entry_point: "fs_main",
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: Some(wgpu::BlendState::REPLACE),
            write_mask: wgpu::ColorWrites::ALL,
        })],
    }),
    primitive: wgpu::PrimitiveState {
        topology: wgpu::PrimitiveTopology::LineList, // Linhas, não triângulos
        strip_index_format: None,
        front_face: wgpu::FrontFace::Ccw,
        cull_mode: None, // Desativado para ver linhas de qualquer ângulo
        polygon_mode: wgpu::PolygonMode::Line,
        ..Default::default()
    },
    depth_stencil: None, // Desativado temporariamente
    multisample: wgpu::MultisampleState::default(),
});
```

O shader é extremamente simples:

```wgsl
// debug_shader.wgsl
struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec4<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
};

@vertex
fn vs_main(model: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = camera.view_proj * vec4<f32>(model.position, 1.0);
    out.color = model.color;
    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return in.color;
}
```

Para usar, criamos um buffer com as linhas:

```rust
// Exemplo: desenhar um bounding box vermelho
let bbox_lines = [
    // Linhas do cubo (12 no total)
    DebugVertex { position: [min.x, min.y, min.z], color: [1.0, 0.0, 0.0, 1.0] },
    DebugVertex { position: [max.x, min.y, min.z], color: [1.0, 0.0, 0.0, 1.0] },
    // ... outras linhas
];

let debug_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Debug Line Buffer"),
    contents: bytemuck::cast_slice(&bbox_lines),
    usage: wgpu::BufferUsages::VERTEX,
});
```

E no render pass:

```rust
render_pass.set_pipeline(&debug_pipeline);
render_pass.set_vertex_buffer(0, debug_buffer.slice(..));
render_pass.draw(0..24, 0..1); // 12 linhas * 2 vértices cada
```

### Visualizando o Frustum

Um caso comum é verificar se a câmera está configurada corretamente. Podemos renderizar as arestas do frustum:

```rust
fn build_frustum_lines(camera: &Camera) -> Vec<DebugVertex> {
    let corners = camera.frustum_corners(); // Método que calcula os 8 cantos
    let color = [0.0, 1.0, 1.0, 1.0]; // Ciano
    vec![
        // Linhas do near plane
        DebugVertex { position: corners[0], color },
        DebugVertex { position: corners[1], color },
        DebugVertex { position: corners[1], color },
        DebugVertex { position: corners[3], color },
        // ... todas as 12 arestas
    ]
}
```

### Erro Comum: Depth Testing

Se você ativar o depth testing no pipeline de debug sem configurar corretamente, as linhas podem desaparecer atrás dos objetos. A mensagem de erro não será clara - elas simplesmente não aparecerão. A solução é:

```rust
depth_stencil: Some(wgpu::DepthStencilState {
    format: wgpu::TextureFormat::Depth32Float,
    depth_write_enabled: false, // Não sobrescrever o depth buffer
    depth_compare: wgpu::CompareFunction::Always, // Sempre desenhar
    stencil: wgpu::StencilState::default(),
    bias: wgpu::DepthBiasState::default(),
}),
```

### Exercício: Vetores Normais

Adicione debug rendering para mostrar os vetores normais de um modelo 3D. Cada normal deve ser uma linha azul partindo do centro do triângulo. A solução requer:

1. Calcular o centro de cada triângulo
2. Criar linhas do centro até (centro + normal * escala)
3. Usar um buffer dinâmico que atualiza quando o modelo se move

```rust
// Solução parcial:
for triangle in mesh.triangles() {
    let center = (triangle.v0 + triangle.v1 + triangle.v2) / 3.0;
    normals_lines.push(DebugVertex { position: center, color: [0.0, 0.0, 1.0, 1.0] });
    normals_lines.push(DebugVertex { 
        position: center + triangle.normal * 0.5, // Escala ajustável
        color: [0.0, 0.0, 1.0, 1.0] 
    });
}
```