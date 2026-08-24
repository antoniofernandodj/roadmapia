## Pipeline States Avançados

Renderizar um triângulo com WGPU requer um pipeline básico, mas aplicações reais precisam controlar como a GPU combina cores, testa profundidade e processa geometria. Vamos criar um pipeline que renderiza objetos semitransparentes com culling personalizado, mostrando como os estados do pipeline funcionam na prática.

Começamos com um pipeline simples que sempre sobrescreve pixels:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    // ...
    primitive: wgpu::PrimitiveState::default(),
    depth_stencil: None,
    multisample: wgpu::MultisampleState::default(),
    fragment: Some(wgpu::FragmentState {
        // ...
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: None, // Sobrescreve sempre
            write_mask: wgpu::ColorWrites::ALL,
        })],
    }),
});
```

Isso funciona, mas produz artefatos quando renderizamos objetos transparentes. Vamos adicionar blending para composição alpha:

```rust
blend: Some(wgpu::BlendState {
    color: wgpu::BlendComponent {
        src_factor: wgpu::BlendFactor::SrcAlpha,
        dst_factor: wgpu::BlendFactor::OneMinusSrcAlpha,
        operation: wgpu::BlendOperation::Add,
    },
    alpha: wgpu::BlendComponent::OVER,
}),
```

Um erro comum é esquecer de ordenar os objetos por profundidade. Mesmo com blending ativado, objetos renderizados na ordem errada causam resultados incorretos:

```
// Objeto vermelho (0.5 de alpha) desenhado ANTES do azul
// Resultado: Vermelho aparece por cima indevidamente
```

Ativamos o depth test para corrigir isso:

```rust
depth_stencil: Some(wgpu::DepthStencilState {
    format: wgpu::TextureFormat::Depth32Float,
    depth_write_enabled: true,
    depth_compare: wgpu::CompareFunction::Less,
    stencil: wgpu::StencilState::default(),
    bias: wgpu::DepthBiasState::default(),
}),
```

Para otimização, configuramos culling para descartar triângulos que não estão visíveis:

```rust
primitive: wgpu::PrimitiveState {
    topology: wgpu::PrimitiveTopology::TriangleList,
    front_face: wgpu::FrontFace::Ccw,
    cull_mode: Some(wgpu::Face::Back),
    // Configurações avançadas:
    polygon_mode: wgpu::PolygonMode::Fill,
    unclipped_depth: false,
    conservative: false,
},
```

Experimente inverter o `front_face` para `Cw` e observe como os objetos desaparecem - isso acontece porque agora estamos considerando a ordem dos vértices ao contrário.

**Exercício**: Crie um pipeline que:
1. Use additive blending (SrcAlpha + One)
2. Desabilite depth write
3. Habilite wireframe mode

<details>
<summary>Solução</summary>

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    primitive: wgpu::PrimitiveState {
        polygon_mode: wgpu::PolygonMode::Line,
        // ... outras configurações
    },
    fragment: Some(wgpu::FragmentState {
        targets: &[Some(wgpu::ColorTargetState {
            blend: Some(wgpu::BlendState {
                color: wgpu::BlendComponent {
                    src_factor: wgpu::BlendFactor::SrcAlpha,
                    dst_factor: wgpu::BlendFactor::One,
                    operation: wgpu::BlendOperation::Add,
                },
                alpha: wgpu::BlendComponent::OVER,
            }),
            // ...
        })],
    }),
    depth_stencil: Some(wgpu::DepthStencilState {
        depth_write_enabled: false,
        // ...
    }),
    // ...
});
```
</details>