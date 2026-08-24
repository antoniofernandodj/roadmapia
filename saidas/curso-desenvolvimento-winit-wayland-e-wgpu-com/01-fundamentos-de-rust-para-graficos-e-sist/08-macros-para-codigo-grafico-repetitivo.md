## Macros para Código Gráfico Repetitivo

Em código gráfico, padrões repetitivos surgem constantemente: criação de vértices, definição de layouts de buffer, declaração de pipelines de renderização. Cada `VertexBuffer` requer:

```rust
let vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Vertex Buffer"),
    contents: bytemuck::cast_slice(&VERTICES),
    usage: wgpu::BufferUsages::VERTEX,
});
```

E um pipeline de renderização básico:

```rust
let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    label: Some("Render Pipeline"),
    layout: Some(&pipeline_layout),
    vertex: wgpu::VertexState {
        module: &shader,
        entry_point: "vs_main",
        buffers: &[Vertex::desc()],
    },
    fragment: Some(wgpu::FragmentState {
        module: &shader,
        entry_point: "fs_main",
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: Some(wgpu::BlendState::REPLACE),
            write_mask: wgpu::ColorWrites::ALL,
        })],
    }),
    // ... +10 linhas de configurações padrão
});
```

Macros em Rust resolvem este problema permitindo gerar código repetitivo durante a compilação. Vamos criar uma macro `vertex_buffer!` que simplifica a criação de buffers:

```rust
#[macro_export]
macro_rules! vertex_buffer {
    ($device:expr, $vertices:expr) => {
        $device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some(concat!(file!(), ":", line!())),
            contents: bytemuck::cast_slice($vertices),
            usage: wgpu::BufferUsages::VERTEX,
        })
    };
}

// Uso:
let vb = vertex_buffer!(device, &VERTICES);
```

A macro automaticamente:
1. Insere o local de definição como label
2. Converte os dados usando `bytemuck`
3. Define o uso correto como buffer de vértices

Erro comum: esquecer que macros não respeitam escopo de tipos. Tentar usar `vertex_buffer!` com um tipo que não implementa `bytemuck::Pod` gera:

```
error[E0277]: the trait bound `MyVertex: Pod` is not satisfied
  --> src/main.rs:15:9
   |
15 |     vertex_buffer!(device, &CUSTOM_VERTICES);
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ the trait `Pod` is not implemented for `MyVertex`
```

Solução: adicionar `#[derive(bytemuck::Pod, bytemuck::Zeroable)]` ao tipo de vértice.

Para pipelines, uma macro mais complexa ajuda:

```rust
macro_rules! render_pipeline {
    ($device:expr, {
        layout: $layout:expr,
        shader: $shader:expr,
        vertex: { buffers: $v_buffers:expr },
        fragment: { targets: $f_targets:expr $(,)? }
    }) => {{
        $device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some(concat!(file!(), ":", line!())),
            layout: Some($layout),
            vertex: wgpu::VertexState {
                module: $shader,
                entry_point: "vs_main",
                buffers: $v_buffers,
            },
            fragment: Some(wgpu::FragmentState {
                module: $shader,
                entry_point: "fs_main",
                targets: $f_targets,
            }),
            primitive: wgpu::PrimitiveState::default(),
            depth_stencil: None,
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
        })
    }};
}

// Uso limpo:
let pipeline = render_pipeline!(device, {
    layout: &pipeline_layout,
    shader: &shader,
    vertex: { buffers: &[Vertex::desc()] },
    fragment: { targets: &[Some(target_state)] }
});
```

Macros também podem ajudar com repetição de vértices. Compare:

```rust
// Sem macro:
let VERTICES = [
    Vertex { pos: [-0.5, -0.5], color: [1.0, 0.0, 0.0] },
    Vertex { pos: [0.5, -0.5], color: [0.0, 1.0, 0.0] },
    Vertex { pos: [0.0, 0.5], color: [0.0, 0.0, 1.0] },
];

// Com macro vertices!:
let VERTICES = vertices![
    [-0.5, -0.5] => [1.0, 0.0, 0.0];
    [0.5, -0.5] => [0.0, 1.0, 0.0];
    [0.0, 0.5] => [0.0, 0.0, 1.0];
];
```

Implementação:

```rust
#[macro_export]
macro_rules! vertices {
    ($([$x:expr, $y:expr] => [$r:expr, $g:expr, $b:expr]);* $(;)?) => {
        [$(
            Vertex { pos: [$x, $y], color: [$r, $g, $b] },
        )*]
    };
}
```

Exercício: Crie uma macro `texture2d!` que aceite:
1. Um dispositivo WGPU
2. Dados de pixels como `&[u8]`
3. Largura e altura
4. Formato (opcional, padrão `wgpu::TextureFormat::Rgba8UnormSrgb`)

E retorne uma textura 2D configurada para uso como recurso de fragment shader.

Solução comentada:

```rust
#[macro_export]
macro_rules! texture2d {
    ($device:expr, $data:expr, $width:expr, $height:expr) => {
        texture2d!($device, $data, $width, $height, wgpu::TextureFormat::Rgba8UnormSrgb)
    };
    ($device:expr, $data:expr, $width:expr, $height:expr, $format:expr) => {
        $device.create_texture(&wgpu::TextureDescriptor {
            label: Some(concat!(file!(), ":", line!())),
            size: wgpu::Extent3d {
                width: $width,
                height: $height,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: $format,
            usage: wgpu::TextureUsages::TEXTURE_BINDING,
            view_formats: &[],
        })
    };
}

// Uso:
let tex = texture2d!(device, &image_data, 256, 256);
let tex_custom = texture2d!(device, &data, 512, 512, wgpu::TextureFormat::Bgra8UnormSrgb);
```