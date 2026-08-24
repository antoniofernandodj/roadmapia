## Render Passes Múltiplas

Quando você precisa renderizar cenas complexas com efeitos que dependem de resultados intermediários - como sombras, reflexos ou pós-processamento - múltiplos render passes se tornam essenciais. Vamos implementar um cenário comum: renderizar uma cena 3D simples para um buffer de textura, depois aplicar um efeito de desfoque (blur) em tela cheia.

Primeiro, criamos os recursos necessários:

```rust
// Textura alvo para o primeiro pass
let texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: config.width,
        height: config.height,
        depth_or_array_layers: 1,
    },
    mip_level_count: 1,
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Rgba8Unorm,
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
    label: Some("intermediate_texture"),
});

let texture_view = texture.create_view(&wgpu::TextureViewDescriptor::default());
```

O erro clássico aqui é esquecer o `TEXTURE_BINDING` no usage - se fizer isso, receberá:

```
Error: Texture usage TEXTURE_BINDING is not allowed for texture without the corresponding usage flag
```

Agora, vamos configurar o primeiro render pass que desenha na textura intermediária:

```rust
let rp_desc = wgpu::RenderPassDescriptor {
    label: Some("First Pass"),
    color_attachments: &[wgpu::RenderPassColorAttachment {
        view: &texture_view,
        resolve_target: None,
        ops: wgpu::Operations {
            load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
            store: wgpu::StoreOp::Store,
        },
    }],
    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
        view: &depth_texture_view,
        depth_ops: Some(wgpu::Operations {
            load: wgpu::LoadOp::Clear(1.0),
            store: wgpu::StoreOp::Store,
        }),
        stencil_ops: None,
    }),
};
```

Observe que usamos `StoreOp::Store` para preservar o resultado na textura. Se usássemos `Discard`, o segundo pass não teria acesso aos dados.

Para o segundo pass (fullscreen quad com efeito de blur), precisamos de um pipeline específico:

```rust
let blur_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    layout: Some(&blur_pipeline_layout),
    vertex: wgpu::VertexState {
        module: &blur_shader,
        entry_point: "vs_main",
        buffers: &[quad_vertex_buffer_layout],
    },
    fragment: Some(wgpu::FragmentState {
        module: &blur_shader,
        entry_point: "fs_main",
        targets: &[Some(config.view_formats[0].into())],
    }),
    // ... restante da configuração
});
```

O shader de blur acessa a textura do primeiro pass:

```rust
// WGSL
@group(0) @binding(0)
var tex_sampler: sampler;
@group(0) @binding(1)
var color_texture: texture_2d<f32>;

@fragment
fn fs_main(@builtin(position) pos: vec4<f32>) -> @location(0) vec4<f32> {
    let tex_coords = pos.xy / vec2<f32>(textureDimensions(color_texture));
    let color = textureSample(color_texture, tex_sampler, tex_coords);
    // Implementação simplificada do blur
    return vec4<f32>(color.rgb * 0.5, color.a);
}
```

Ao executar, você verá a cena original desfocada. Mas e se quiséssemos combinar ambos os resultados? Criamos um terceiro pass que mistura as texturas:

```rust
let combine_rp_desc = wgpu::RenderPassDescriptor {
    color_attachments: &[wgpu::RenderPassColorAttachment {
        view: &surface_view,
        resolve_target: None,
        ops: wgpu::Operations {
            load: wgpu::LoadOp::Load,
            store: wgpu::StoreOp::Store,
        },
    }],
    // ...
};

// No encoder de comandos
{
    let mut rpass = encoder.begin_render_pass(&combine_rp_desc);
    rpass.set_pipeline(&combine_pipeline);
    rpass.set_bind_group(0, &combine_bind_group, &[]);
    rpass.draw(0..3, 0..1); // Fullscreen quad
}
```

Erro comum: esquecer de atualizar os bind groups entre passes. Se usar o mesmo bind group do primeiro pass no segundo, você verá:

```
Error: Bind group 0 is invalid for pipeline layout
```

**Exercício**: Modifique o exemplo para implementar um efeito de "glow" - renderize objetos brilhantes em um pass separado com cor branca, aplique blur nesse buffer e depois some com a cena principal.

**Solução**:

1. Crie mais uma textura para os objetos brilhantes
2. No primeiro pass, renderize apenas os objetos com emissão
3. Aplique blur nessa textura
4. No pass final, some as três texturas: cena principal + objetos brilhantes + blur dos objetos brilhantes

```rust
// No shader de combinação final
let scene_color = textureSample(scene_texture, tex_sampler, tex_coords);
let glow_color = textureSample(glow_texture, tex_sampler, tex_coords);
let glow_blur = textureSample(blur_texture, tex_sampler, tex_coords);

return scene_color + glow_color * 0.3 + glow_blur * 0.7;
```