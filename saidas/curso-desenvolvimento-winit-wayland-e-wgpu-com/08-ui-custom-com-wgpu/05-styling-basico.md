## Styling Básico

Renderizar um quadrado vermelho na tela parece simples até você precisar controlar exatamente como cada pixel é desenhado. No WGPU, cores não são apenas valores RGB - são estados complexos que interagem com o pipeline de renderização. Vamos começar com um retângulo sólido e evoluir para bordas arredondadas e gradientes.

O cerne do styling está no fragment shader. Este exemplo mostra um shader que aplica uma cor uniforme:

```rust
// Dentro do seu pipeline de renderização
let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    fragment: wgpu::FragmentState {
        entry_point: "fs_main",
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: Some(wgpu::BlendState::REPLACE),
            write_mask: wgpu::ColorWrites::ALL,
        })],
        // ...
    },
    // ...
});

// No seu shader.wgsl
[[stage(fragment)]]
fn fs_main() -> [[location(0)]] vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0); // Vermelho sólido
}
```

A saída será um retângulo vermelho puro. Mas e se quisermos um vermelho com 50% de transparência? Mudar para `vec4(1.0, 0.0, 0.0, 0.5)` não funciona imediatamente - precisamos ajustar o blend state:

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

Agora a transparência funciona corretamente, misturando com o conteúdo abaixo. Para estilos mais complexos, como bordas arredondadas, precisamos passar parâmetros adicionais para o shader:

```rust
// Estrutura de uniformes para estilização
#[repr(C)]
#[derive(Debug, Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct StyleUniforms {
    color: [f32; 4],
    radius: f32,
    size: [f32; 2],
    _padding: [f32; 2], // Alinhamento para 16 bytes
}

// Shader atualizado
[[stage(fragment)]]
fn fs_main(
    [[location(0)]] uv: vec2<f32>,
    [[binding(0)]] uniforms: &StyleUniforms,
) -> [[location(0)]] vec4<f32> {
    let center = vec2<f32>(0.5, 0.5);
    let dist = distance(uv, center);
    let radius = uniforms.radius;
    
    if dist > 0.5 {
        discard;
    } else if dist > 0.5 - radius {
        let alpha = 1.0 - smoothstep(0.5 - radius, 0.5, dist);
        return vec4<f32>(uniforms.color.rgb, uniforms.color.a * alpha);
    }
    return uniforms.color;
}
```

Este shader produz um retângulo com cantos arredondados suaves. O parâmetro `radius` controla o raio da curvatura (0.0 para cantos quadrados, 0.5 para um círculo perfeito).

Para gradientes lineares, modificamos o shader:

```rust
[[stage(fragment)]]
fn fs_main(
    [[location(0)]] uv: vec2<f32>,
    [[binding(0)]] uniforms: &StyleUniforms,
) -> [[location(0)]] vec4<f32> {
    let t = uv.x; // Gradiente horizontal
    let color_start = vec3<f32>(1.0, 0.0, 0.0); // Vermelho
    let color_end = vec3<f32>(0.0, 0.0, 1.0); // Azul
    let color = mix(color_start, color_end, t);
    return vec4<f32>(color, 1.0);
}
```

Um erro comum é esquecer de atualizar os bind groups quando os parâmetros de estilo mudam. Se você alterar `uniforms.color` na CPU mas não atualizar o buffer, verá cores incorretas sem mensagens de erro:

```rust
// Atualização correta dos uniforms
queue.write_buffer(
    &uniform_buffer,
    0,
    bytemuck::cast_slice(&[StyleUniforms {
        color: [0.5, 0.8, 0.3, 1.0], // Verde
        radius: 0.1,
        size: [width, height],
        _padding: [0.0, 0.0],
    }]),
);
```

**Exercício:** Implemente um shader que desenha um retângulo com borda. O shader deve aceitar a cor de fundo, cor da borda e espessura da borda como parâmetros uniformes.

**Solução:**

```rust
[[stage(fragment)]]
fn fs_main(
    [[location(0)]] uv: vec2<f32>,
    [[binding(0)]] uniforms: &StyleUniforms,
) -> [[location(0)]] vec4<f32> {
    let edge = uniforms.border_width;
    let outer_color = uniforms.border_color;
    let inner_color = uniforms.fill_color;
    
    if uv.x < edge || uv.x > 1.0 - edge || 
       uv.y < edge || uv.y > 1.0 - edge {
        return outer_color;
    }
    return inner_color;
}
```