## Debugging WGPU

Renderizar gráficos modernos envolve uma complexa orquestração entre CPU e GPU, onde erros podem surgir em qualquer estágio - desde a compilação de shaders até a sincronização de buffers. O WGPU oferece ferramentas integradas para diagnosticar esses problemas sem exigir modificações no driver gráfico.

### Validação de API com `InstanceFlags::DEBUG`

Ativar as camadas de validação é o primeiro passo para capturar erros comuns de configuração. Veja como inicializar uma instância WGPU com validação ativada:

```rust
use wgpu::InstanceDescriptor;

let instance = wgpu::Instance::new(InstanceDescriptor {
    backends: wgpu::Backends::all(),
    flags: wgpu::InstanceFlags::DEBUG,
    dx12_shader_compiler: Default::default(),
});
```

Sem essa flag, erros como bind groups incompletos ou formatos de textura não suportados podem passar despercebidos até causarem falhas visuais ou travamentos. Um erro típico que a validação captura:

```
ERROR: Validation Error
[VUID-VkDescriptorSetLayoutBinding-descriptorType-00339]
Binding 0: Descriptor type VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER but shader expects VK_DESCRIPTOR_TYPE_STORAGE_BUFFER
```

A mensagem indica um descompasso entre o tipo de buffer declarado no shader e o configurado no bind group. A correção envolve alinhar as definições:

```rust
// ANTES (errado)
let layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[wgpu::BindGroupLayoutEntry {
        binding: 0,
        visibility: wgpu::ShaderStages::VERTEX,
        ty: wgpu::BindingType::Buffer {
            ty: wgpu::BufferBindingType::Uniform,
            has_dynamic_offset: false,
            min_binding_size: None,
        },
        count: None,
    }],
});

// DEPOIS (correto)
let layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[wgpu::BindGroupLayoutEntry {
        binding: 0,
        visibility: wgpu::ShaderStages::VERTEX,
        ty: wgpu::BindingType::Buffer {
            ty: wgpu::BufferBindingType::Storage { read_only: true },
            has_dynamic_offset: false,
            min_binding_size: None,
        },
        count: None,
    }],
});
```

### Logging Hierárquico com `tracing`

Para monitorar o comportamento da aplicação em tempo real, integre o crate `tracing` ao seu projeto:

```toml
[dependencies]
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
```

Configure o subscriber no início da aplicação:

```rust
use tracing_subscriber::{EnvFilter, fmt};

fn main() {
    fmt().with_env_filter(EnvFilter::from_default_env()
        .add_directive("wgpu_core=warn".parse().unwrap())
        .add_directive("wgpu_hal=error".parse().unwrap())
    ).init();

    // Resto da inicialização...
}
```

Isso permite filtrar logs por nível de severidade e módulo. Durante a execução, você verá mensagens como:

```
WARN wgpu_core::device: Missing pipeline cache data, recompiling shaders
ERROR wgpu_hal::vulkan: Failed to allocate memory for buffer
```

### Debug de Shaders com `naga`

Problemas em shaders frequentemente causam falhas silenciosas. Use a ferramenta `naga` para validá-los antes da execução:

```rust
fn validate_shader(source: &str) -> Result<(), naga::Error> {
    let module = naga::front::wgsl::parse_str(source)?;
    let mut validator = naga::valid::Validator::new(
        naga::valid::ValidationFlags::all(),
        naga::valid::Capabilities::all(),
    );
    validator.validate(&module)?;
    Ok(())
}

let shader_src = r#"
    @vertex
    fn vs_main(@location(0) pos: vec3<f32>) -> @builtin(position) vec4<f32> {
        return vec4<f32>(pos, 1.0);
    }
"#;

if let Err(e) = validate_shader(shader_src) {
    eprintln!("Shader error: {:?}", e);
}
```

Erros comuns incluem tipos incompatíveis ou atributos faltantes:

```
Shader error: Function [1] 'vs_main' input is missing builtin(position) output
```

### Visualização de Recursos com `wgpu-profiler`

Para identificar gargalos de desempenho, o crate `wgpu-profiler` oferece medição precisa de tempo de execução:

```rust
use wgpu_profiler::{GpuProfiler, GpuProfilerSettings};

let mut profiler = GpuProfiler::new(GpuProfilerSettings::default());

// Dentro do loop de renderização:
profiler.begin_frame();
let mut encoder = device.create_command_encoder(...);

profiler.begin_scope("Main Pass", &mut encoder, &device);
// Comandos de renderização...
profiler.end_scope(&mut encoder);

profiler.end_frame().unwrap();
```

A saída mostra o tempo gasto em cada seção:

```
Frame 42:
- Main Pass: 2.4ms
  - Draw Calls: 1.8ms
  - Compute: 0.6ms
```

### Exercício: Debug de Pipeline

Crie um pipeline simples que renderiza um triângulo, mas intencionalmente:
1. Defina um formato de vértice incorreto no `VertexState`
2. Use um bind group layout incompatível com o shader
3. Ative as camadas de validação e capture as mensagens de erro
4. Corrija cada erro passo a passo

Solução comentada:

```rust
// 1. Pipeline com erro de formato de vértice
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    vertex: wgpu::VertexState {
        module: &shader_module,
        entry_point: "vs_main",
        buffers: &[wgpu::VertexBufferLayout {
            array_stride: 12, // Tamanho incorreto para vec3<f32>
            step_mode: wgpu::VertexStepMode::Vertex,
            attributes: &[wgpu::VertexAttribute {
                format: wgpu::VertexFormat::Float32x3,
                offset: 0,
                shader_location: 0,
            }],
        }],
    },
    // ... outros campos
});

// Mensagem de erro esperada:
// "Vertex stride 12 does not cover attribute 0 with format Float32x3"
```

Correção:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    vertex: wgpu::VertexState {
        // ...
        buffers: &[wgpu::VertexBufferLayout {
            array_stride: 12, // Correto: 3 floats × 4 bytes cada
            // ...
        }],
    },
    // ...
});
```