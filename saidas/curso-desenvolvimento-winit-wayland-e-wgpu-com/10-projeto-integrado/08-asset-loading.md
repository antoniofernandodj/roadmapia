## Asset Loading

Um editor de texto precisa carregar recursos como fontes, ícones e texturas de interface. Em Rust com WGPU, isso envolve três desafios principais: ler arquivos do disco sem bloquear o thread principal, decodificar formatos binários (como PNG ou TTF), e transferir dados para a GPU de forma eficiente.

Vamos começar com um caso concreto: carregar uma textura PNG para usar como ícone de botão. O erro mais comum é tentar fazer tudo no thread principal, travando a interface durante o carregamento:

```rust
// ERRADO: Bloqueia o thread da UI
let icon = load_texture_blocking("assets/icon.png"); // Congela a aplicação por 200ms
```

A solução é dividir em etapas assíncronas:

```rust
struct TextureLoader {
    runtime: tokio::runtime::Runtime,
    sender: mpsc::Sender<TextureLoadTask>,
}

impl TextureLoader {
    pub fn new(device: Arc<wgpu::Device>) -> Self {
        let (sender, receiver) = mpsc::channel(32);
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_io()
            .build()
            .unwrap();

        std::thread::spawn(move || {
            while let Ok(task) = receiver.blocking_recv() {
                let pixels = image::load_from_memory(&task.bytes)
                    .unwrap()
                    .to_rgba8();
                let texture = create_texture(&device, &pixels);
                task.callback.send(texture).unwrap();
            }
        });

        Self { runtime, sender }
    }

    pub fn load_async(&self, path: &str) -> oneshot::Receiver<wgpu::Texture> {
        let (callback, receiver) = oneshot::channel();
        let bytes = std::fs::read(path).unwrap();
        self.sender.send(TextureLoadTask { bytes, callback }).unwrap();
        receiver
    }
}
```

Quando chamamos `load_async`, o padrão ocorre:
1. O arquivo é lido do disco em um thread dedicado
2. A imagem é decodificada para RGBA8
3. A textura é criada na GPU
4. O resultado é enviado de volta via canal

Para texturas na GPU, a criação envolve múltiplos passos:

```rust
fn create_texture(device: &wgpu::Device, pixels: &[u8]) -> wgpu::Texture {
    device.create_texture(&wgpu::TextureDescriptor {
        size: wgpu::Extent3d {
            width: 1024,
            height: 1024,
            depth_or_array_layers: 1,
        },
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::Rgba8Unorm,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        label: Some("icon_texture"),
    })
}
```

Um erro frequente é esquecer de alinhar os dados corretamente para a GPU. Se tentarmos enviar pixels diretamente sem verificar o tamanho:

```rust
queue.write_texture(
    texture.as_image_copy(),
    pixels, // Pode falhar se não for múltiplo de 256 bytes
    wgpu::ImageDataLayout {
        bytes_per_row: Some(4 * 1024), // 4 canais × largura
        ..Default::default()
    },
    texture.size(),
);
```

A mensagem de erro típica será:
```
wgpu error: Validation Error: Buffer binding size/offset is not a multiple of 256
```

A correção envolve padding nos dados:

```rust
let bytes_per_row = 4 * 1024;
let padded_size = ((pixels.len() + 255) / 256) * 256;
let mut padded = Vec::with_capacity(padded_size);
padded.extend_from_slice(pixels);
padded.resize(padded_size, 0); // Preenche com zeros
```

Para fontes, o processo é similar mas com desafios adicionais de layout. Um exemplo com `fontdue`:

```rust
let font_data = std::fs::read("assets/FiraCode.ttf")?;
let font = fontdue::Font::from_bytes(font_data, fontdue::FontSettings::default())?;
let (metrics, bitmap) = font.rasterize('A', 16.0);

let texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: metrics.width as u32,
        height: metrics.height as u32,
        depth_or_array_layers: 1,
    },
    // ... mesmo formato anterior
});
```

Exercício: Implemente um `AssetCache` que:
1. Mantém texturas já carregadas em um `HashMap`
2. Retorna futuros para carregamentos em andamento
3. Limpa recursos não usados após 60 segundos

Solução base:

```rust
struct AssetCache {
    loaded: Mutex<HashMap<String, Arc<wgpu::Texture>>>,
    pending: Mutex<HashMap<String, oneshot::Sender<Arc<wgpu::Texture>>>>,
    loader: TextureLoader,
}

impl AssetCache {
    pub fn get(&self, path: &str) -> impl Future<Output = Arc<wgpu::Texture>> {
        let mut loaded = self.loaded.lock().unwrap();
        if let Some(texture) = loaded.get(path) {
            return future::ready(texture.clone());
        }
        
        let mut pending = self.pending.lock().unwrap();
        if let Some(sender) = pending.get(path) {
            return Box::pin(sender.subscribe());
        }
        
        let (sender, receiver) = oneshot::channel();
        pending.insert(path.to_string(), sender);
        self.loader.load_async(path);
        Box::pin(receiver.map(|tex| tex.unwrap()))
    }
}
```