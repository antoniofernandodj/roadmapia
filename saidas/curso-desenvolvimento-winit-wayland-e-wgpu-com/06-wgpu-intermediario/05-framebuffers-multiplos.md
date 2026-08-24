## Framebuffers Múltiplos

Quer renderizar simultaneamente para vários alvos diferentes? Imagine um efeito de pós-processamento onde você precisa da cor original e de um buffer de profundidade, ou um sistema de visão dividida que renderiza cenas independentes para cada viewport. Framebuffers múltiplos resolvem isso de forma eficiente na GPU.

### O Problema do Framebuffer Único

Por padrão, o WGPU renderiza para um único alvo (geralmente a textura da janela). Se tentarmos acessar múltiplos outputs em um shader com:

```rust
// Isso NÃO funciona como esperado!
[[location(0)]] var<out> color1: vec4<f32>;
[[location(1)]] var<out> color2: vec4<f32>;
```

O compilador de shaders reclama:

```
error: fragment shader has multiple outputs targeting location 0
```

Isso ocorre porque precisamos configurar explicitamente os attachments adicionais.

### Configurando Múltiplos Color Attachments

Vamos criar um framebuffer com dois alvos de cor e um de profundidade:

```rust
// Cria texturas para os attachments
let color_texture1 = device.create_texture(&wgpu::TextureDescriptor {
    size: size,
    mip_level_count: 1,
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Rgba8Unorm,
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
    label: Some("color_texture1"),
});

let color_texture2 = device.create_texture(&wgpu::TextureDescriptor {
    size: size,
    format: wgpu::TextureFormat::Rgba16Float, // Precisão maior para dados HDR
    // ... restante igual ao anterior
});

let depth_texture = device.create_texture(&wgpu::TextureDescriptor {
    // Configuração padrão de depth texture...
});
```

Agora, no RenderPass:

```rust
let render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("multi_target_render_pass"),
    color_attachments: &[
        wgpu::RenderPassColorAttachment {
            view: &color_texture1.create_view(&wgpu::TextureViewDescriptor::default()),
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
                store: true,
            },
        },
        wgpu::RenderPassColorAttachment {
            view: &color_texture2.create_view(&wgpu::TextureViewDescriptor::default()),
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::TRANSPARENT),
                store: true,
            },
        },
    ],
    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
        view: &depth_texture.create_view(&wgpu::TextureViewDescriptor::default()),
        depth_ops: Some(wgpu::Operations {
            load: wgpu::LoadOp::Clear(1.0),
            store: true,
        }),
        stencil_ops: None,
    }),
});
```

### Ajustando o Pipeline

O pipeline precisa corresponder aos attachments configurados. O erro comum aqui é esquecer de atualizar o `FragmentState`:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    fragment: Some(wgpu::FragmentState {
        module: &shader_module,
        entry_point: "fs_main",
        targets: &[
            wgpu::ColorTargetState { // Primeiro attachment
                format: wgpu::TextureFormat::Rgba8Unorm,
                blend: Some(wgpu::BlendState::REPLACE),
                write_mask: wgpu::ColorWrites::ALL,
            },
            wgpu::ColorTargetState { // Segundo attachment
                format: wgpu::TextureFormat::Rgba16Float,
                blend: None, // Sem blending para dados técnicos
                write_mask: wgpu::ColorWrites::ALL,
            },
        ],
    }),
    // ... restante da configuração do pipeline
});
```

### Shader Múltiplos Alvos

No shader WGSL, agora podemos escrever para ambos os attachments:

```rust
[[stage(fragment)]]
fn fs_main(
    [[builtin(position)]] pos: vec4<f32>,
    [[location(0)]] uv: vec2<f32>
) -> [[location(0)]] vec4<f32> {
    // Primeiro output (cor padrão)
    var color1 = vec4<f32>(uv.x, uv.y, 0.5, 1.0);
    
    // Segundo output (dados técnicos)
    var color2 = vec4<f32>(pos.z, 0.0, 0.0, 1.0);
    
    return vec4<f32>(color1, color2);
}
```

Erro comum: misturar a ordem dos locations. Se o shader retornar para [[location(1)]] primeiro, os dados vão para o attachment errado.

### Aplicação Prática: Deferred Rendering

Um caso de uso real é o deferred shading, onde separamos os atributos da cena:

```rust
// G-Buffer com 4 attachments:
// 0: Albedo (RGB) + Roughness (A)
// 1: Normais (RGB)
// 2: Metallic (R) + Occlusion (G) + Emissive (B)
// 3: Depth (RGBA, encoded)
let g_buffer_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    fragment: Some(wgpu::FragmentState {
        targets: &[
            wgpu::ColorTargetState { /* Albedo */ }, 
            wgpu::ColorTargetState { /* Normais */ },
            wgpu::ColorTargetState { /* Metallic */ },
            wgpu::ColorTargetState { /* Depth */ },
        ],
    }),
    // ...
});
```

### Limitações e Otimizações

1. **Limite de Attachments**: A maioria das GPUs modernas suporta 8 attachments simultâneos, mas verifique com `limits.max_color_attachments`.

2. **Performance**: Cada attachment adicional consome largura de banda. Use formatos compactados quando possível:

```rust
wgpu::TextureFormat::Rgba8UnormSrgb // Para cor
wgpu::TextureFormat::Rg11b10Float   // Para normais HDR
```

3. **Leitura dos Resultados**: Para usar os buffers gerados em passes subsequentes:

```rust
// Em um render pass posterior:
bind_group_layouts.push(&device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[wgpu::BindGroupLayoutEntry {
        binding: 0,
        visibility: wgpu::ShaderStages::FRAGMENT,
        ty: wgpu::BindingType::Texture {
            sample_type: wgpu::TextureSampleType::Float { filterable: true },
            view_dimension: wgpu::TextureViewDimension::D2,
            multisampled: false,
        },
    }],
}));
```

### Exercício: MRT para Edge Detection

Implemente um efeito de detecção de bordas que:
1. Renderiza a cena normal para o attachment 0
2. Gera um buffer de normais e profundidade no attachment 1
3. Em um segundo pass, usa ambos para calcular bordas

**Solução comentada**:

```rust
// 1. Pipeline de geometria (primeiro pass)
let geom_pipeline = device.create_render_pipeline(/* 2 attachments */);

// 2. Pipeline de pós-processamento (segundo pass)
let edge_pipeline = device.create_render_pipeline(/* usa texturas do primeiro pass */);

// 3. Shader de bordas
fn edge_detection(
    [[location(0)]] color: vec4<f32>,
    [[binding(0)]] normal_depth: texture_2d<f32>,
) -> [[location(0)]] vec4<f32> {
    // Implementação do edge detection usando derivadas
    let delta = dfdx(normal_depth) + dfdy(normal_depth);
    return mix(color, vec4(1.0, 0.0, 0.0, 1.0), length(delta));
}
```