## Vertex Buffers

Quando precisamos renderizar um triângulo na tela, a GPU não recebe as coordenadas diretamente como variáveis soltas. Em vez disso, os dados dos vértices são organizados em buffers - blocos contíguos de memória que a GPU consome de forma otimizada. Veja como criar um buffer simples para um triângulo:

```rust
// Dados dos vértices: posição (x,y) e cor (r,g,b)
#[repr(C)]
#[derive(Copy, Clone, Debug)]
struct Vertex {
    position: [f32; 2],
    color: [f32; 3],
}

const VERTICES: &[Vertex] = &[
    Vertex { position: [ 0.0,  0.5], color: [1.0, 0.0, 0.0] }, // Topo, vermelho
    Vertex { position: [-0.5, -0.5], color: [0.0, 1.0, 0.0] }, // Esquerda, verde
    Vertex { position: [ 0.5, -0.5], color: [0.0, 0.0, 1.0] }, // Direita, azul
];

let vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Vertex Buffer"),
    contents: bytemuck::cast_slice(VERTICES),
    usage: wgpu::BufferUsages::VERTEX,
});
```

Dois detalhes críticos aqui:
1. `#[repr(C)]` garante que o layout da struct seja compatível com a GPU
2. `bytemuck::cast_slice` converte nossos dados para bytes brutos sem cópia

Se esquecermos o `#[repr(C)]`, o erro será claro:
```text
error: cannot derive `Pod` for `Vertex` due to non-C-compatible layout
```

Para usar este buffer no pipeline, precisamos descrever seu layout:

```rust
impl Vertex {
    fn desc() -> wgpu::VertexBufferLayout<'static> {
        wgpu::VertexBufferLayout {
            array_stride: std::mem::size_of::<Vertex>() as wgpu::BufferAddress,
            step_mode: wgpu::VertexStepMode::Vertex,
            attributes: &[
                // Posição
                wgpu::VertexAttribute {
                    offset: 0,
                    shader_location: 0,
                    format: wgpu::VertexFormat::Float32x2,
                },
                // Cor
                wgpu::VertexAttribute {
                    offset: std::mem::size_of::<[f32; 2]>() as wgpu::BufferAddress,
                    shader_location: 1,
                    format: wgpu::VertexFormat::Float32x3,
                },
            ],
        }
    }
}
```

No shader WGSL, os atributos correspondem exatamente:
```rust
// vertex_shader.wgsl
[[stage(vertex)]]
fn vs_main(
    [[location(0)]] position: vec2<f32>,
    [[location(1)]] color: vec3<f32>,
) -> VertexOutput {
    var output: VertexOutput;
    output.position = vec4<f32>(position, 0.0, 1.0);
    output.color = color;
    return output;
}
```

Um erro comum é desalinhar os offsets entre CPU e GPU. Se mudarmos o offset da cor para 8 bytes (em vez do correto 8 bytes de um `[f32; 2]`):
```text
Buffer binding size (20) is smaller than buffer size (24)
```

Para renderizar, vinculamos o buffer no render pass:
```rust
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw(0..3, 0..1);
```

**Exercício**: Modifique o buffer para desenhar um quadrado (2 triângulos) com cores diferentes em cada vértice. Use `VERTEX` e `INDEX` buffers.

**Solução**:
```rust
const QUAD_VERTICES: &[Vertex] = &[
    Vertex { position: [-0.5,  0.5], color: [1.0, 0.0, 0.0] },
    Vertex { position: [-0.5, -0.5], color: [0.0, 1.0, 0.0] },
    Vertex { position: [ 0.5, -0.5], color: [0.0, 0.0, 1.0] },
    Vertex { position: [ 0.5,  0.5], color: [1.0, 1.0, 0.0] },
];

const INDICES: &[u16] = &[0, 1, 2, 0, 2, 3];

let index_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Index Buffer"),
    contents: bytemuck::cast_slice(INDICES),
    usage: wgpu::BufferUsages::INDEX,
});

// No render pass:
render_pass.set_index_buffer(index_buffer.slice(..), wgpu::IndexFormat::Uint16);
render_pass.draw_indexed(0..INDICES.len() as u32, 0, 0..1);
```