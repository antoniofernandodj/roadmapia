## Shaders Básicos

Renderizar um triângulo colorido é o "Hello World" da computação gráfica, mas até essa tarefa simples exige entender como a GPU processa dados através de shaders. Vamos criar um triângulo onde cada vértice tem uma cor diferente, demonstrando como os shaders transformam dados brutos em pixels na tela.

Primeiro, declare a estrutura de vértices com cores RGB:

```rust
#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
struct Vertex {
    position: [f32; 3],
    color: [f32; 3],
}
```

O atributo `#[repr(C)]` garante que o layout na memória seja compatível com o que a GPU espera. Agora crie os vértices do triângulo:

```rust
const VERTICES: &[Vertex] = &[
    Vertex { position: [0.0, 0.5, 0.0], color: [1.0, 0.0, 0.0] },  // Topo - Vermelho
    Vertex { position: [-0.5, -0.5, 0.0], color: [0.0, 1.0, 0.0] }, // Esquerda - Verde
    Vertex { position: [0.5, -0.5, 0.0], color: [0.0, 0.0, 1.0] },  // Direita - Azul
];
```

O shader de vértice (em WGSL) processa cada vértice individualmente:

```rust
const VERTEX_SHADER: &str = r#"
    struct VertexInput {
        @location(0) position: vec3<f32>,
        @location(1) color: vec3<f32>,
    };

    struct VertexOutput {
        @builtin(position) clip_position: vec4<f32>,
        @location(0) color: vec3<f32>,
    };

    @vertex
    fn vs_main(model: VertexInput) -> VertexOutput {
        var out: VertexOutput;
        out.clip_position = vec4<f32>(model.position, 1.0);
        out.color = model.color;
        return out;
    }
"#;
```

O shader de fragmento recebe os valores interpolados automaticamente:

```rust
const FRAGMENT_SHADER: &str = r#"
    @fragment
    fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
        return vec4<f32>(in.color, 1.0);
    }
"#;
```

Um erro comum é esquecer de declarar os layouts corretamente no pipeline:

```rust
let render_pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
    vertex: wgpu::VertexState {
        module: &shader_module,
        entry_point: "vs_main",
        buffers: &[Vertex::desc()],  // ← Esse desc() precisa ser implementado!
    },
    fragment: Some(wgpu::FragmentState {
        module: &shader_module,
        entry_point: "fs_main",
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: Some(wgpu::BlendState::REPLACE),
            write_mask: wgpu::ColorWrites::ALL,
        })],
    }),
    // ... outros campos necessários
});
```

Se você esquecer o `Vertex::desc()`, receberá este erro:

```
thread 'main' panicked at 'called `Option::unwrap()` on a `None` value',
src/libcore/option.rs:378:21
```

A implementação correta seria:

```rust
impl Vertex {
    fn desc() -> wgpu::VertexBufferLayout<'static> {
        wgpu::VertexBufferLayout {
            array_stride: std::mem::size_of::<Vertex>() as wgpu::BufferAddress,
            step_mode: wgpu::VertexStepMode::Vertex,
            attributes: &[
                wgpu::VertexAttribute {
                    offset: 0,
                    shader_location: 0,
                    format: wgpu::VertexFormat::Float32x3,
                },
                wgpu::VertexAttribute {
                    offset: std::mem::size_of::<[f32; 3]>() as wgpu::BufferAddress,
                    shader_location: 1,
                    format: wgpu::VertexFormat::Float32x3,
                },
            ],
        }
    }
}
```

Quando executado corretamente, você verá um triângulo com gradiente de cores:

```
[Renderizado] Triângulo com vértices:
- Topo: Vermelho puro (1.0, 0.0, 0.0)
- Esquerda: Verde puro (0.0, 1.0, 0.0)
- Direita: Azul puro (0.0, 0.0, 1.0)
As cores são interpoladas automaticamente entre os vértices
```

**Exercício:** Modifique o shader de fragmento para inverter as cores (subtraia cada componente de 1.0) e adicione um efeito de pulsação usando o tempo (que pode ser passado como uniform em exercícios futuros).

**Solução:**

```rust
const FRAGMENT_SHADER_EXERCISE: &str = r#"
    @fragment
    fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
        return vec4<f32>(1.0 - in.color.r, 1.0 - in.color.g, 1.0 - in.color.b, 1.0);
    }
"#;
```