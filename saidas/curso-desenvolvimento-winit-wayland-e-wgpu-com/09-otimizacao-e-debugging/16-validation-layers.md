## Validation Layers

Quando seu aplicativo gráfico falha silenciosamente ou exibe artefatos visuais inexplicáveis, a causa geralmente está em violações sutis das regras da API gráfica. Validation layers são ferramentas que interceptam chamadas à GPU para verificar erros em tempo de execução, sem modificar seu código de produção. Veja como implementá-las no WGPU:

```rust
use wgpu::InstanceDescriptor;

let instance = wgpu::Instance::new(InstanceDescriptor {
    backends: wgpu::Backends::PRIMARY,
    dx12_shader_compiler: None,
    // Ativa todas as camadas de validação disponíveis
    flags: wgpu::InstanceFlags::DEBUG,
});
```

Ao executar com `RUST_LOG=wgpu_hal=warn`, você verá avisos como:

```
WARN wgpu_hal::vulkan::instance] VALIDATION [VUID-VkBufferCreateInfo-size-06308 (0x7cd0911d)]
Size must be greater than 0
```

Isso indica que tentamos criar um buffer com tamanho zero - um erro que passaria despercebido sem as layers. A mensagem inclui:
1. Código de erro Vulkan (VUID-VkBufferCreateInfo-size-06308)
2. Descrição humana do problema
3. Localização no código (arquivo/linha)

Para erros comuns de renderização, como bind groups incompletos:

```rust
// ERRADO: Esqueceu de vincular o buffer uniforme
let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
    layout: &bind_group_layout,
    entries: &[], // Deveria conter o buffer
    label: None,
});
```

A validação captura:

```
ERROR wgpu_hal::vulkan::device] VALIDATION [VUID-VkDescriptorSet-allocation (0x4e5f466e)]
DescriptorSet 0x2d used with no descriptors bound
```

Para configurar níveis de detalhe na validação:

```rust
instance.describe().flags.set(
    wgpu::InstanceFlags::DEBUG 
    | wgpu::InstanceFlags::VALIDATION,
    true
);
```

Níveis de severidade:
- `INFO`: Logs informativos (criação de recursos)
- `WARN`: Problemas não críticos (performance)
- `ERROR`: Violações que causam comportamento indefinido

Em produção, desative as layers com:

```rust
InstanceFlags::empty() // Nenhuma validação
```

Exercício: Crie um pipeline de renderização sem definir o formato de profundidade/stencil quando seu shader usa `@builtin(position)`. Corrija o erro baseado na mensagem de validação.

Solução:

```rust
// Pipeline corrigido
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    depth_stencil: Some(wgpu::DepthStencilState {
        format: wgpu::TextureFormat::Depth24Plus, // Formato requerido
        depth_write_enabled: true,
        depth_compare: wgpu::CompareFunction::Less,
        stencil: wgpu::StencilState::default(),
        bias: wgpu::DepthBiasState::default(),
    }),
    ..Default::default()
});
```

A mensagem original indicaria:
```
ERROR Missing depth/stencil format for pipeline using position output
```