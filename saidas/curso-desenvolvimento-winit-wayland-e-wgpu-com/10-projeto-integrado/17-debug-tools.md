## Debug Tools

Quando seu editor de texto começa a travar ao digitar ou a renderização mostra artefatos visuais, você precisa de ferramentas que vão além do `println!`. Em aplicações gráficas, os problemas aparecem em três camadas: lógica do programa, comunicação com o sistema (Wayland/X11), e operações na GPU. Vamos configurar um arsenal de debug integrado.

### Logging Estruturado com `tracing`

O módulo `log` é básico demais para sistemas complexos. O `tracing` oferece spans (contextos aninhados) e eventos com metadados:

```rust
use tracing::{info_span, instrument, Level};
use tracing_subscriber::{fmt, EnvFilter};

#[instrument]
fn render_frame(device: &wgpu::Device, queue: &wgpu::Queue) {
    let _span = info_span!("RenderFrame").entered();
    // Comandos de renderização...
}

fn main() {
    // Configura o subscriber padrão com filtros
    fmt()
        .with_env_filter(EnvFilter::from_default_env()
            .add_directive("my_editor=info".parse().unwrap()))
        .init();

    // Exemplo de log com contexto
    tracing::info!(target: "gpu", "Iniciando dispositivo WGPU");
}
```

Saída:
```
Jul 12 10:00:00.123  INFO my_editor::gpu: Iniciando dispositivo WGPU
Jul 12 10:00:00.456  INFO my_editor::render: RenderFrame
```

Erro comum: esquecer de configurar o subscriber resulta em logs silenciosos. A solução é chamar `tracing_subscriber::fmt::init()` no início do `main`.

### Inspeção de Protocolo Wayland

Para debugar a comunicação entre seu editor e o compositor Wayland, use a variável `WAYLAND_DEBUG=1`:

```bash
WAYLAND_DEBUG=1 cargo run
```

Isso mostra todas as mensagens trocadas no protocolo. Um erro típico é não responder a eventos obrigatórios:

```
[17123456] error: O cliente não respondeu ao evento wl_surface.frame
```

### Debug de GPU com RenderDoc

RenderDoc captura frames individuais da GPU. Para integrá-lo ao WGPU:

1. Instale RenderDoc e execute via `renderdoccmd capture /path/to/your/app`
2. No código, marque os frames para captura:

```rust
#[cfg(feature = "renderdoc")]
fn capture_frame(device: &wgpu::Device) {
    use wgpu::util::renderdoc::RenderDoc;
    let rd = RenderDoc::new().unwrap();
    rd.start_frame_capture(device, None);
    // ... renderização ...
    rd.end_frame_capture(device, None);
}
```

Problema comum: esquecer de ativar a feature `renderdoc` no `Cargo.toml`:
```toml
[dependencies]
wgpu = { version = "0.15", features = ["renderdoc"] }
```

### Validação de API Gráfica

Ative as camadas de validação do WGPU para detectar erros comuns:

```rust
let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
    backends: wgpu::Backends::PRIMARY,
    dx12_shader_compiler: Default::default(),
    flags: wgpu::InstanceFlags::DEBUG, // Ativa validação
});
```

Isso gera mensagens como:
```
VALIDATION ERROR: Buffer 0x1 bound but never used in render pass
```

### Exercício: Diagnóstico de Vazamento de Memória

Sua aplicação está consumindo mais RAM a cada frame. Use o seguinte código com problema:

```rust
struct TextureCache {
    textures: HashMap<String, wgpu::Texture>,
}

impl TextureCache {
    fn load(&mut self, path: &str, device: &wgpu::Device) {
        let texture = create_texture_from_file(device, path); // Simulado
        self.textures.insert(path.to_string(), texture);
    }
}
```

**Solução**: O cache nunca limpa texturas. Modifique para usar `Arc` e referências fracas:

```rust
struct TextureCache {
    textures: HashMap<String, std::sync::Weak<wgpu::Texture>>,
}

impl TextureCache {
    fn load(&mut self, path: &str, device: &wgpu::Device) -> Arc<wgpu::Texture> {
        if let Some(tex) = self.textures.get(path).and_then(|w| w.upgrade()) {
            return tex;
        }
        let texture = Arc::new(create_texture_from_file(device, path));
        self.textures.insert(path.to_string(), Arc::downgrade(&texture));
        texture
    }
}
```