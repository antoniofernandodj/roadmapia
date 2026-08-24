## Transparência e Blur

Quando você remove as decorações padrão da janela com `with_decorations(false)`, a aplicação ganha controle total sobre a aparência, mas perde efeitos visuais como sombras e transparência que o compositor normalmente fornece. Vamos implementar esses efeitos manualmente usando os protocolos Wayland.

O segredo está na interface `zwlr_layer_shell_v1`, um protocolo estendido que permite configurar camadas de janela com efeitos especiais. Primeiro, verifique se o compositor suporta este protocolo:

```rust
let layer_shell = wayland_display
    .bind::<ZwlrLayerShellV1, _>(1..=4)
    .expect("Compositor não suporta layer_shell");
```

Para uma janela transparente, precisamos configurar o buffer de pixels com canal alfa e informar ao compositor:

```rust
window.set_transparent(true);

// No WGPU, configure a textura de swapchain com formato BGRA8UnormSrgb
let config = wgpu::SurfaceConfiguration {
    format: wgpu::TextureFormat::Bgra8UnormSrgb,
    // ... outras configurações
};
surface.configure(&device, &config);
```

O erro comum aqui é esquecer de habilitar a mistura alfa no pipeline de renderização:

```rust
let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    fragment: wgpu::FragmentState {
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: Some(wgpu::BlendState::ALPHA_BLENDING), // ← ESSENCIAL
            write_mask: wgpu::ColorWrites::ALL,
        })],
        // ... restante da configuração
    },
    // ... outros parâmetros
});
```

Sem isso, você verá o erro:
```
wgpu error: Validation Error: Fragment output at 0 has no blend state but format has alpha channel
```

Para o efeito de blur, usamos o protocolo `xdg_decoration_manager` em conjunto com shaders personalizados. Um exemplo mínimo de fragment shader em WGSL:

```rust
// blur.wgsl
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let texture = &texture_2d<f32>(in.texture);
    let sampler = &sampler;
    
    // Kernel simples de blur 3x3
    var color = vec4<f32>(0.0);
    let texel_size = 1.0 / vec2<f32>(textureDimensions(texture));
    for (var i = -1; i <= 1; i++) {
        for (var j = -1; j <= 1; j++) {
            let offset = vec2<f32>(f32(i), f32(j)) * texel_size;
            color += textureSample(texture, sampler, in.uv + offset);
        }
    }
    return color / 9.0;
}
```

A implementação completa requer três passos principais:

1. Criar uma textura intermediária para o efeito
2. Aplicar o blur como pós-processamento
3. Configurar a transparência no Wayland

Veja o fluxo completo:

```rust
// 1. Textura intermediária
let blur_texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: size.width,
        height: size.height,
        depth_or_array_layers: 1,
    },
    mip_level_count: 1,
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Bgra8UnormSrgb,
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
    label: Some("blur_texture"),
});

// 2. Pipeline de blur
let blur_pipeline = create_blur_pipeline(&device, &config);

// 3. Configuração Wayland
if let Some(surface) = window.wayland_surface() {
    let xdg_surface = XdgSurface::from(surface);
    xdg_surface.set_window_geometry(0, 0, width, height);
    xdg_surface.set_opaque_region(None); // ← Transparência global
}
```

O erro mais comum nessa etapa é a sincronização incorreta entre os buffers, resultando em artefatos visuais. Sempre verifique os eventos `Frame` do Wayland:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::RedrawRequested(window_id) if window_id == window.id() => {
            // Renderização principal aqui
            window.pre_present_notify(); // ← Sincronização crítica
        }
        _ => (),
    }
});
```

Para janelas com blur dinâmico (onde o efeito muda conforme o conteúdo), é necessário reconfigurar a textura sempre que o tamanho da janela mudar:

```rust
window.resize_callback = Some(Box::new(|new_size| {
    // Recreate blur texture with new dimensions
    blur_texture = device.create_texture(/* ... */);
}));
```

Exercício: Implemente um controle deslizante que ajusta a intensidade do blur em tempo real. Dica: você precisará:

1. Criar uma uniform buffer para o parâmetro de intensidade
2. Modificar o shader para usar esse parâmetro
3. Atualizar o buffer quando o slider mudar

Solução comentada:

```rust
// 1. Buffer uniforme
let blur_intensity = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Blur Intensity Buffer"),
    contents: bytemuck::cast_slice(&[0.5f32]), // Valor inicial
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
});

// 2. Shader modificado
@group(0) @binding(0) var<uniform> intensity: f32;

// No loop de blur:
let offset = vec2<f32>(f32(i), f32(j)) * texel_size * intensity;

// 3. Atualização via UI
slider.on_change(|new_value| {
    queue.write_buffer(&blur_intensity, 0, bytemuck::cast_slice(&[new_value]));
});
```