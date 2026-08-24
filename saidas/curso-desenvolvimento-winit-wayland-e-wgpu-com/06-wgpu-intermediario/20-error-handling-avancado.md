## Error Handling Avançado

Quando uma aplicação gráfica falha, simplesmente abortar não é uma opção aceitável. O usuário espera que a renderização continue, mesmo que com qualidade reduzida. Vejamos como implementar estratégias robustas de fallback em WGPU.

### Erros Recuperáveis vs. Não-Recuperáveis

Comecemos com um exemplo comum: criação de textura. Se o formato pedido não for suportado, podemos tentar um fallback:

```rust
fn create_texture(device: &wgpu::Device, size: (u32, u32), format: wgpu::TextureFormat) -> Result<wgpu::Texture, wgpu::Error> {
    let texture = device.create_texture(&wgpu::TextureDescriptor {
        size: wgpu::Extent3d {
            width: size.0,
            height: size.1,
            depth_or_array_layers: 1,
        },
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        label: None,
    });
    
    match texture {
        Ok(t) => Ok(t),
        Err(e) if e.to_string().contains("FORMAT_NOT_SUPPORTED") => {
            log::warn!("Format {:?} not supported, falling back to Rgba8Unorm", format);
            device.create_texture(&wgpu::TextureDescriptor {
                /* mesma configuração, mas com Rgba8Unorm */
                format: wgpu::TextureFormat::Rgba8Unorm,
                ..descriptor
            })
        }
        Err(e) => Err(e),
    }
}
```

### Pipeline de Fallback

Ao criar um pipeline de renderização, podemos preparar alternativas:

```rust
struct PipelineSet {
    main: wgpu::RenderPipeline,
    fallback: Option<wgpu::RenderPipeline>,
}

impl PipelineSet {
    fn new(device: &wgpu::Device, layout: &wgpu::PipelineLayout, main_desc: wgpu::RenderPipelineDescriptor) -> Self {
        let main = device.create_render_pipeline(&main_desc);
        
        let fallback = if main_desc.multisample.count > 1 {
            let mut desc = main_desc.clone();
            desc.multisample.count = 1;
            Some(device.create_render_pipeline(&desc))
        } else {
            None
        };
        
        PipelineSet { main, fallback }
    }
    
    fn get(&self) -> &wgpu::RenderPipeline {
        if device.is_valid(&self.main) {
            &self.main
        } else {
            self.fallback.as_ref().expect("No fallback pipeline available")
        }
    }
}
```

### Tratamento de Device Lost

Quando a GPU é desconectada (comum em laptops ao fechar a tampa), precisamos recriar todos os recursos:

```rust
fn handle_device_lost(
    device: &wgpu::Device,
    surface: &wgpu::Surface,
    old_config: &wgpu::SurfaceConfiguration,
) -> (wgpu::Device, wgpu::Queue, wgpu::SurfaceConfiguration) {
    let instance = wgpu::Instance::new(wgpu::InstanceDescriptor::default());
    let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::HighPerformance,
        compatible_surface: Some(surface),
        ..Default::default()
    })).unwrap();
    
    let (new_device, new_queue) = pollster::block_on(adapter.request_device(
        &wgpu::DeviceDescriptor {
            features: wgpu::Features::empty(),
            limits: wgpu::Limits::default(),
            label: None,
        },
        None,
    )).unwrap();
    
    let new_config = surface.get_default_config(&adapter, old_config.width, old_config.height).unwrap();
    surface.configure(&new_device, &new_config);
    
    (new_device, new_queue, new_config)
}
```

### Monitoramento de Erros em Tempo Real

Adicione um callback global para capturar erros não tratados:

```rust
wgpu_subscriber::initialize_default_subscriber(None);
std::panic::set_hook(Box::new(|info| {
    log::error!("Panic occurred: {:?}", info);
    // Tentar salvar estado da aplicação antes de sair
}));
```

### Exercício Prático

Implemente um sistema de fallback para shaders que:
1. Tenta compilar o shader principal
2. Se falhar, carrega um shader simplificado embutido
3. Se ainda falhar, usa um quad branco sólido

Solução comentada:

```rust
struct ShaderSet {
    source: String,
    fallback: &'static str,
    module: Option<wgpu::ShaderModule>,
}

impl ShaderSet {
    fn new(device: &wgpu::Device, source: String) -> Self {
        let fallback = include_str!("fallback.wgsl");
        let module = match device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: None,
            source: wgpu::ShaderSource::Wgsl(source.into()),
        }) {
            Ok(m) => Some(m),
            Err(_) => None,
        };
        
        Self { source, fallback, module }
    }
    
    fn get_module(&mut self, device: &wgpu::Device) -> &wgpu::ShaderModule {
        if self.module.is_none() {
            self.module = Some(device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: None,
                source: wgpu::ShaderSource::Wgsl(self.fallback.into()),
            }).unwrap_or_else(|_| {
                device.create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: None,
                    source: wgpu::ShaderSource::Wgsl(
                        "fn fs_main() -> @location(0) vec4<f32> { return vec4(1.0); }".into(),
                    ),
                })
            }));
        }
        self.module.as_ref().unwrap()
    }
}
```