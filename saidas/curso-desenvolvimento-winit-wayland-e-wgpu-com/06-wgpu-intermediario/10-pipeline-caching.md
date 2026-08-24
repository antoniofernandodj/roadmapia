## Pipeline Caching

Criar pipelines de renderização em WGPU é uma operação custosa. Cada vez que você chama `device.create_render_pipeline()`, a driver precisa compilar shaders, validar estados e alocar recursos internos. Em uma cena complexa com dezenas de materiais diferentes, essa criação sob demanda causa gargalos visíveis:

```rust
// Exemplo problemático: criação de pipeline a cada frame
for material in materials {
    let pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
        // Configuração complexa repetida a cada frame
        vertex: wgpu::VertexState {
            module: &shader_module,
            entry_point: "vs_main",
            buffers: &[vertex_layout],
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader_module,
            entry_point: "fs_main",
            targets: &[Some(color_target_state)],
        }),
        // ... outros 20+ parâmetros
    });
    // Uso do pipeline
}
```

A solução é implementar um cache simples usando `HashMap`. A chave do cache deve incluir todos os parâmetros que afetam a criação do pipeline:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct PipelineKey {
    shader_id: String,
    vertex_layout_hash: u64,
    blend_state: Option<wgpu::BlendState>,
    depth_stencil: Option<wgpu::DepthStencilState>,
    // Outros campos relevantes
}

struct PipelineCache {
    device: Arc<wgpu::Device>,
    pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
}

impl PipelineCache {
    fn get_or_create(
        &mut self,
        key: PipelineKey,
        create_fn: impl FnOnce(&wgpu::Device) -> wgpu::RenderPipeline,
    ) -> &wgpu::RenderPipeline {
        self.pipelines.entry(key).or_insert_with(|| create_fn(&self.device))
    }
}
```

Um erro comum é esquecer de incluir parâmetros críticos na chave. Por exemplo, se o blend state não fizer parte da chave, dois materiais com configurações diferentes de transparência podem acabar compartilhando o mesmo pipeline incorretamente:

```rust
// ERRO: blend_state não está na chave
let key = PipelineKey {
    shader_id: "basic".to_string(),
    vertex_layout_hash: 12345,
    // blend_state faltando!
};

// Dois materiais diferentes compartilham o mesmo pipeline
let opaque_pipeline = cache.get_or_create(key.clone(), |device| {
    create_pipeline(device, BlendState::REPLACE)
});

let transparent_pipeline = cache.get_or_create(key, |device| {
    create_pipeline(device, BlendState::ALPHA_BLENDING)
}); // Retorna o pipeline errado!
```

A mensagem de erro não será explícita - você simplesmente verá artefatos visuais na renderização. A correção é incluir todos os parâmetros relevantes:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct PipelineKey {
    shader_id: String,
    vertex_layout_hash: u64,
    blend_state: Option<wgpu::BlendState>,
    depth_stencil: Option<wgpu::DepthStencilState>,
    primitive: wgpu::PrimitiveState,
    multisample: wgpu::MultisampleState,
    // Todos os campos que afetam o pipeline
}
```

Para hashear layouts de vértice complexos, uma técnica eficiente é usar `std::hash::Hasher`:

```rust
fn hash_vertex_layout(layout: &wgpu::VertexBufferLayout) -> u64 {
    use std::hash::{Hash, Hasher};
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    layout.array_stride.hash(&mut hasher);
    for attribute in &layout.attributes {
        attribute.format.hash(&mut hasher);
        attribute.offset.hash(&mut hasher);
        attribute.shader_location.hash(&mut hasher);
    }
    hasher.finish()
}
```

Um cache completo deve lidar com o ciclo de vida dos pipelines. Quando o dispositivo WGPU é perdido (como em mudanças de tela ou driver crashes), todos os pipelines precisam ser recriados:

```rust
impl PipelineCache {
    fn clear(&mut self) {
        self.pipelines.clear();
    }

    fn recreate_all(&mut self) {
        let old_pipelines = std::mem::take(&mut self.pipelines);
        for (key, _) in old_pipelines {
            self.pipelines.insert(key, create_fn(&self.device));
        }
    }
}

// No handler de device lost:
device.on_uncaptured_error(Box::new(|error| {
    if let wgpu::Error::DeviceLost = error {
        pipeline_cache.recreate_all();
    }
}));
```

Exercício: Implemente um cache que reutiliza pipelines baseados no vertex layout e shader, mas recria pipelines quando o formato de saída (color target) muda. Mostre como lidar com a mudança dinâmica entre formatos como Rgba8Unorm e Bgra8Unorm.

Solução:

```rust
struct DynamicPipelineCache {
    inner: HashMap<(String, u64), wgpu::RenderPipeline>,
    current_format: wgpu::TextureFormat,
}

impl DynamicPipelineCache {
    fn get(
        &mut self,
        device: &wgpu::Device,
        shader_id: &str,
        vertex_layout: &wgpu::VertexBufferLayout,
        format: wgpu::TextureFormat,
    ) -> &wgpu::RenderPipeline {
        if format != self.current_format {
            self.inner.clear();
            self.current_format = format;
        }

        let layout_hash = hash_vertex_layout(vertex_layout);
        self.inner.entry((shader_id.to_string(), layout_hash))
            .or_insert_with(|| create_pipeline(device, vertex_layout, format))
    }
}

// Uso:
let format = surface.get_supported_formats(&adapter)[0];
let pipeline = cache.get(&device, "basic", &vertex_layout, format);
```