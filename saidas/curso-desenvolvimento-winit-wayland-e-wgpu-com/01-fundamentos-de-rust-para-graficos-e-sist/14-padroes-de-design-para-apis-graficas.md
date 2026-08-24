## Padrões de Design para APIs Gráficas

Em APIs gráficas, objetos como texturas, buffers e pipelines exigem configuração complexa com múltiplos parâmetros interdependentes. O padrão Builder resolve isso permitindo construção gradual com verificações em tempo de compilação. Veja como implementar um Builder seguro para uma textura:

```rust
pub struct TextureBuilder<'a> {
    width: u32,
    height: u32,
    format: TextureFormat,
    label: Option<&'a str>,
    mip_levels: u32,
}

impl<'a> TextureBuilder<'a> {
    pub fn new(width: u32, height: u32) -> Self {
        Self {
            width,
            height,
            format: TextureFormat::Rgba8Unorm, // Valor padrão
            label: None,
            mip_levels: 1,
        }
    }

    pub fn format(mut self, format: TextureFormat) -> Self {
        self.format = format;
        self
    }

    pub fn label(mut self, label: &'a str) -> Self {
        self.label = Some(label);
        self
    }

    pub fn build(self, device: &Device) -> Texture {
        let desc = TextureDescriptor {
            size: Extent3d {
                width: self.width,
                height: self.height,
                depth_or_array_layers: 1,
            },
            mip_level_count: self.mip_levels,
            sample_count: 1,
            dimension: TextureDimension::D2,
            format: self.format,
            usage: TextureUsages::TEXTURE_BINDING | TextureUsages::COPY_DST,
            label: self.label,
        };
        
        device.create_texture(&desc)
    }
}
```

Uso típico:
```rust
let texture = TextureBuilder::new(512, 512)
    .format(TextureFormat::Bgra8Unorm)
    .label("Diffuse Map")
    .build(&device);
```

Erro comum ao esquecer parâmetros obrigatórios:
```rust
let texture = TextureBuilder::new(512, 512).build(&device);
// Funciona porque width/height são obrigatórios no new()
// e outros parâmetros têm defaults sensíveis
```

Para casos onde certas combinações são inválidas, podemos usar o tipo system para forçar configurações corretas:

```rust
pub struct TextureBuilderValidated<F, M> {
    // Campos internos...
    _marker: PhantomData<(F, M)>,
}

impl TextureBuilderValidated<(), ()> {
    pub fn new(width: u32, height: u32) -> Self { /* ... */ }
}

impl<F, M> TextureBuilderValidated<F, M> {
    pub fn format(self, format: TextureFormat) -> TextureBuilderValidated<TextureFormatSet, M> {
        // Transição de estado
    }
    
    pub fn build(self) -> Result<Texture, ValidationError> {
        // Verifica F e M através dos tipos
    }
}
```

Outro padrão essencial é o tipo de estado, que previne operações inválidas em tempo de compilação:

```rust
pub struct Texture<State = Uninitialized> {
    handle: TextureHandle,
    _state: PhantomData<State>,
}

impl Texture<Uninitialized> {
    pub fn new(/* ... */) -> Self { /* ... */ }
    
    pub fn initialize(self, data: &[u8]) -> Texture<Initialized> {
        // Upload de dados...
        Texture {
            handle: self.handle,
            _state: PhantomData,
        }
    }
}

impl Texture<Initialized> {
    pub fn bind(&self, slot: u32) { /* ... */ }
}
```

Isso previne erros como tentar vincular uma textura não inicializada:
```rust
let tex = Texture::new(/* ... */);
tex.bind(0); // Erro: método `bind` não existe para Texture<Uninitialized>
```

Para recursos compartilhados entre threads, combinamos Arc com trait objects:

```rust
pub trait GpuResource: Send + Sync {
    fn memory_usage(&self) -> usize;
}

pub struct ResourceCache {
    resources: HashMap<String, Arc<dyn GpuResource>>,
}

impl ResourceCache {
    pub fn insert(&mut self, key: String, res: impl GpuResource + 'static) {
        self.resources.insert(key, Arc::new(res));
    }
}
```

Exercício: Implemente um builder para um PipelineState que:
1. Exige vertex e fragment shaders antes do build
2. Valida que o formato de depth_stencil é compatível com o formato de depth attachment
3. Fornece defaults sensíveis para primitive topology (TriangleList) e cull mode (Back)

Solução comentada:
```rust
pub struct PipelineBuilder<'a> {
    vertex_shader: Option<&'a str>,
    fragment_shader: Option<&'a str>,
    depth_format: Option<TextureFormat>,
    // Outros campos com defaults...
}

impl<'a> PipelineBuilder<'a> {
    pub fn new() -> Self {
        Self {
            vertex_shader: None,
            fragment_shader: None,
            depth_format: None,
            // Inicializa outros campos com defaults
        }
    }
    
    pub fn vertex_shader(mut self, shader: &'a str) -> Self {
        self.vertex_shader = Some(shader);
        self
    }
    
    pub fn build(self) -> Result<Pipeline, PipelineError> {
        if self.vertex_shader.is_none() || self.fragment_shader.is_none() {
            return Err(PipelineError::MissingShaders);
        }
        
        if let (Some(ds_format), Some(depth_format)) = (self.depth_stencil_format, self.depth_format) {
            if !formats_compatible(ds_format, depth_format) {
                return Err(PipelineError::IncompatibleFormats);
            }
        }
        
        // Construção do pipeline...
        Ok(Pipeline { /* ... */ })
    }
}
```