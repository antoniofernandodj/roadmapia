## Logging Gráfico

Quando você está desenvolvendo uma aplicação gráfica, especialmente uma que utiliza WGPU para renderização, os problemas podem ser difíceis de diagnosticar. Um erro em um shader pode resultar em uma tela preta, ou um buffer mal configurado pode causar artefatos visuais estranhos. Nessas situações, o logging é sua primeira linha de defesa. No entanto, o logging tradicional pode não ser suficiente para problemas gráficos, onde você precisa capturar informações específicas sobre o estado da GPU, os comandos enviados e os recursos alocados.

### Por que Logging Gráfico é Diferente?

O logging gráfico precisa lidar com a natureza assíncrona da renderização. A GPU executa comandos em paralelo com a CPU, e os erros podem não ser imediatamente visíveis. Além disso, os dados gráficos são frequentemente grandes e complexos, como buffers de vértices ou texturas, que precisam ser capturados de forma eficiente sem sobrecarregar o sistema.

### Implementando Logging com `log` e `tracing`

Rust oferece duas crates principais para logging: `log` e `tracing`. Ambas são compatíveis com o ecossistema Rust e podem ser estendidas para capturar informações gráficas específicas. Vamos começar configurando o `tracing` para capturar eventos em nossa aplicação WGPU.

```rust
use tracing::{info, error, debug};
use wgpu::InstanceDescriptor;

fn main() {
    tracing_subscriber::fmt::init();

    let instance = wgpu::Instance::new(InstanceDescriptor::default());
    debug!("Instância WGPU criada com sucesso.");

    // Exemplo de captura de erro
    if let Err(e) = instance.request_adapter(&wgpu::RequestAdapterOptions::default()) {
        error!("Falha ao solicitar adapter WGPU: {:?}", e);
    }
}
```

Neste exemplo, `tracing_subscriber::fmt::init()` inicializa o logger padrão, e usamos macros como `debug!` e `error!` para registrar eventos. Quando você executar este código, verá logs formatados no terminal, incluindo informações sobre a criação da instância WGPU e possíveis erros ao solicitar um adapter.

### Logging de Recursos Gráficos

Para capturar informações específicas sobre recursos gráficos, como buffers e texturas, podemos estender o `tracing` para incluir detalhes relevantes. Por exemplo, ao criar um buffer de vértices, podemos registrar seu tamanho e uso:

```rust
use wgpu::util::DeviceExt;

fn create_vertex_buffer(device: &wgpu::Device, data: &[f32]) -> wgpu::Buffer {
    let buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Vertex Buffer"),
        contents: bytemuck::cast_slice(data),
        usage: wgpu::BufferUsages::VERTEX,
    });

    debug!("Buffer de vértices criado com {} bytes", data.len() * std::mem::size_of::<f32>());
    buffer
}
```

Aqui, registramos o tamanho do buffer de vértices em bytes, o que pode ser útil para identificar problemas de alocação ou uso excessivo de memória.

### Capturando Erros de Shader

Erros em shaders são um dos problemas mais comuns em aplicações gráficas. Para capturar esses erros, podemos usar o `tracing` para registrar a compilação de shaders e quaisquer mensagens de erro:

```rust
fn compile_shader(device: &wgpu::Device, source: &str) -> wgpu::ShaderModule {
    let shader_module = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("Shader"),
        source: wgpu::ShaderSource::Wgsl(source.into()),
    });

    info!("Shader compilado com sucesso.");
    shader_module
}
```

Se o shader contiver erros de sintaxe, o próprio WGPU emitirá uma mensagem de erro, que será capturada pelo logger.

### Exercício: Logging de Pipeline de Renderização

Crie uma função que configure um pipeline de renderização básico com WGPU e registre cada etapa do processo, incluindo a criação de bind groups, pipeline layout e o pipeline em si. Certifique-se de capturar qualquer erro que possa ocorrer durante a configuração.

#### Solução

```rust
fn create_render_pipeline(device: &wgpu::Device, layout: &wgpu::PipelineLayout, shader: &wgpu::ShaderModule) -> wgpu::RenderPipeline {
    let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("Render Pipeline"),
        layout: Some(layout),
        vertex: wgpu::VertexState {
            module: shader,
            entry_point: "vs_main",
            buffers: &[],
        },
        fragment: Some(wgpu::FragmentState {
            module: shader,
            entry_point: "fs_main",
            targets: &[Some(wgpu::ColorTargetState {
                format: wgpu::TextureFormat::Bgra8UnormSrgb,
                blend: Some(wgpu::BlendState::REPLACE),
                write_mask: wgpu::ColorWrites::ALL,
            })],
        }),
        primitive: wgpu::PrimitiveState::default(),
        depth_stencil: None,
        multisample: wgpu::MultisampleState::default(),
        multiview: None,
    });

    info!("Pipeline de renderização criado com sucesso.");
    pipeline
}
```

Este código configura um pipeline de renderização simples e registra sua criação com `info!`. Se qualquer etapa falhar, o WGPU emitirá uma mensagem de erro que será capturada pelo logger.