## Bind Groups e Layouts

Você está renderizando um objeto que precisa de três recursos no shader: uma textura, um sampler e uma matriz de transformação. Até agora, você provavelmente vinha criando bind groups individuais para cada recurso, resultando em código como:

```rust
// Anti-padrão - bind groups separados
let texture_bind_group = device.create_bind_group(&BindGroupDescriptor {
    layout: &texture_bind_group_layout,
    entries: &[BindGroupEntry {
        binding: 0,
        resource: BindingResource::TextureView(&texture_view),
    }],
    label: Some("texture_bind_group"),
});

let sampler_bind_group = device.create_bind_group(/* ... */);
let uniform_bind_group = device.create_bind_group(/* ... */);
```

Isso funciona, mas é ineficiente. Cada `draw` call precisa vincular múltiplos bind groups, e há limite físico para bind groups por pipeline (normalmente 4 na maioria das GPUs). A solução? Agrupar recursos relacionados em um único bind group.

### Como os Bind Groups Funcionam na GPU

Quando você chama `set_bind_group`, a GPU não copia os dados - ela apenas registra onde estão os recursos na memória. Cada bind group consome espaço nos registradores limitados da GPU. Agrupar recursos reduz chamadas de API e economiza registradores.

Vamos criar um bind group unificado:

```rust
// Layout define como os recursos serão organizados no grupo
let bind_group_layout = device.create_bind_group_layout(&BindGroupLayoutDescriptor {
    entries: &[
        // Slot 0: Uniform buffer
        BindGroupLayoutEntry {
            binding: 0,
            visibility: ShaderStages::VERTEX,
            ty: BindingType::Buffer {
                ty: BufferBindingType::Uniform,
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        },
        // Slot 1: Texture
        BindGroupLayoutEntry {
            binding: 1,
            visibility: ShaderStages::FRAGMENT,
            ty: BindingType::Texture {
                sample_type: TextureSampleType::Float { filterable: true },
                view_dimension: TextureViewDimension::D2,
                multisampled: false,
            },
            count: None,
        },
        // Slot 2: Sampler
        BindGroupLayoutEntry {
            binding: 2,
            visibility: ShaderStages::FRAGMENT,
            ty: BindingType::Sampler(SamplerBindingType::Filtering),
            count: None,
        },
    ],
    label: Some("combined_bind_group_layout"),
});

// Criando o bind group com todos os recursos
let combined_bind_group = device.create_bind_group(&BindGroupDescriptor {
    layout: &bind_group_layout,
    entries: &[
        BindGroupEntry {
            binding: 0,
            resource: uniform_buffer.as_entire_binding(),
        },
        BindGroupEntry {
            binding: 1,
            resource: BindingResource::TextureView(&texture_view),
        },
        BindGroupEntry {
            binding: 2,
            resource: BindingResource::Sampler(&sampler),
        },
    ],
    label: Some("combined_bind_group"),
});
```

No shader, acessamos os recursos pelos mesmos índices:

```wgsl
// Vertex shader
@group(0) @binding(0)
var<uniform> transform: mat4x4<f32>;

// Fragment shader
@group(0) @binding(1)
var texture: texture_2d<f32>;
@group(0) @binding(2)
var texture_sampler: sampler;
```

### Erro Comum: Desalinhamento de Bindings

Um erro frequente é definir o layout com binding 0 como textura, mas no bind group colocar o uniforme no binding 0. O erro será:

```
thread 'main' panicked at 'Binding 0 is expected to be Buffer but got Texture'
```

A solução é garantir que os tipos e índices correspondam exatamente entre layout e bind group.

### Quando Criar Múltiplos Bind Groups

Separe bind groups quando:
1. Recursos são atualizados em frequências diferentes (ex: transformações por objeto vs textura compartilhada)
2. Você precisa ultrapassar o limite de bindings por grupo (normalmente 16)
3. Recursos são usados por subconjuntos diferentes de pipelines

Exemplo de organização recomendada:
- Bind Group 0: Dados globais (view/projection matrix, luzes)
- Bind Group 1: Recursos por material (texturas, parâmetros)
- Bind Group 2: Dados por objeto (transformações)

### Exercício Prático

Modifique um pipeline existente para usar um único bind group contendo:
1. Um uniform buffer com cor base (vec4<f32>)
2. Uma textura difusa
3. Um sampler linear

Depois, compare o desempenho com o método anterior usando múltiplos bind groups.

**Solução comentada:**

```rust
// 1. Crie o layout unificado
let layout = device.create_bind_group_layout(&BindGroupLayoutDescriptor {
    entries: &[
        // Uniform
        BindGroupLayoutEntry { /* ... */ },
        // Texture
        BindGroupLayoutEntry { /* ... */ },
        // Sampler
        BindGroupLayoutEntry { /* ... */ },
    ],
    /* ... */
});

// 2. No pipeline, use este layout
let render_pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
    layout: Some(&pipeline_layout), // Contém nosso novo layout
    /* ... */
});

// 3. Ao renderizar, vincule apenas um bind group
render_pass.set_bind_group(0, &combined_bind_group, &[]);
```