## Depth e Stencil

Quando renderizamos objetos em 3D, precisamos resolver um problema fundamental: determinar quais pixels ficam na frente de outros. Sem isso, objetos distantes apareceriam sobre os próximos, quebrando a ilusão de profundidade. O buffer de depth (profundidade) resolve isso armazenando a distância de cada pixel em relação à câmera.

Vamos começar criando um buffer de depth. Em WGPU, isso é feito através da configuração do `DepthStencilState` no pipeline de renderização:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    // ...
    depth_stencil: Some(wgpu::DepthStencilState {
        format: wgpu::TextureFormat::Depth32Float,
        depth_write_enabled: true,
        depth_compare: wgpu::CompareFunction::Less,
        stencil: wgpu::StencilState::default(),
        bias: wgpu::DepthBiasState::default(),
    }),
    // ...
});
```

Os parâmetros principais são:
- `format`: Define como a profundidade será armazenada (32 bits float é comum)
- `depth_write_enabled`: Permite atualizar o buffer de depth
- `depth_compare`: Define a função de comparação (`Less` significa "mais perto da câmera vence")

Mas só configurar o pipeline não é suficiente - precisamos criar uma textura para armazenar os dados de depth. Aqui está como criar uma textura de depth compatível:

```rust
let depth_texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: config.width,
        height: config.height,
        depth_or_array_layers: 1,
    },
    mip_level_count: 1,
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Depth32Float,
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
    label: Some("depth_texture"),
});
```

Um erro comum é esquecer de anexar esta textura ao render pass. Se fizer isso, verá mensagens como:

```
ERROR wgpu::backend::direct] Missing depth/stencil attachment for render pass with depth/stencil load op
```

Para corrigir, inclua o attachment de depth ao criar o render pass:

```rust
let render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    // ...
    depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
        view: &depth_texture.create_view(&wgpu::TextureViewDescriptor::default()),
        depth_ops: Some(wgpu::Operations {
            load: wgpu::LoadOp::Clear(1.0), // 1.0 = valor máximo de profundidade
            store: true,
        }),
        stencil_ops: None,
    }),
    // ...
});
```

Já o buffer de stencil (estêncil) é menos usado, mas poderoso. Ele permite criar máscaras para controlar onde a renderização ocorre. Um uso clássico é para efeitos de portal ou silhuetas:

```rust
stencil: wgpu::StencilState {
    front: wgpu::StencilFaceState {
        compare: wgpu::CompareFunction::Always,
        fail_op: wgpu::StencilOperation::Keep,
        depth_fail_op: wgpu::StencilOperation::Keep,
        pass_op: wgpu::StencilOperation::Replace,
    },
    back: wgpu::StencilFaceState::IGNORE,
    read_mask: 0xFF,
    write_mask: 0xFF,
},
```

Para usar o stencil, você precisará:
1. Configurar o valor inicial no clear do render pass
2. Escrever valores no shader (usando `output.stencil`)
3. Configurar comparações diferentes para diferentes objetos

Um problema frequente é misturar depth e stencil de forma incorreta. Por exemplo, se você configurar:

```rust
depth_compare: wgpu::CompareFunction::Greater,
stencil: wgpu::StencilState { /* configurado */ },
```

Pode acabar com objetos sendo renderizados na ordem inversa enquanto o stencil tenta aplicar máscaras, criando artefatos visuais. A solução é garantir que as comparações de depth e stencil trabalhem harmonicamente.

**Exercício**: Crie uma cena com três cubos em diferentes profundidades (Z), onde o cubo do meio só é renderizado dentro da área do cubo da frente (use stencil como máscara). Mostre o código do pipeline e do shader.

**Solução**:

```rust
// Pipeline
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    // ...
    depth_stencil: Some(wgpu::DepthStencilState {
        format: wgpu::TextureFormat::Depth32Float,
        depth_write_enabled: true,
        depth_compare: wgpu::CompareFunction::Less,
        stencil: wgpu::StencilState {
            front: wgpu::StencilFaceState {
                compare: wgpu::CompareFunction::Equal,
                fail_op: wgpu::StencilOperation::Keep,
                depth_fail_op: wgpu::StencilOperation::Keep,
                pass_op: wgpu::StencilOperation::Keep,
            },
            // ...
        },
        // ...
    }),
    // ...
});

// No render pass do cubo da frente:
depth_stencil_attachment: Some(/* ... */ stencil_ops: Some(wgpu::Operations {
    load: wgpu::LoadOp::Clear(0),
    store: true,
})),

// Shader do cubo da frente:
[[stage(fragment)]]
fn fs_main() -> [[location(0)]] vec4<f32> {
    output.stencil = 1; // Escreve 1 no buffer stencil
    return color;
}

// Shader do cubo do meio (só renderiza onde stencil == 1)
[[stage(fragment)]]
fn fs_main() -> [[location(0)]] vec4<f32> {
    return color;
}
```