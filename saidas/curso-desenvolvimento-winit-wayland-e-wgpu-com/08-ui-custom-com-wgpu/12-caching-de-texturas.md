## Caching de Texturas

Renderizar interfaces gráficas frequentemente exibe os mesmos elementos visuais repetidamente - ícones, bordas arredondadas, texturas de fundo. Criar uma nova textura GPU para cada instância é desperdício: consome VRAM, sobrecarrega o barramento PCIe com uploads repetidos e força recompilações de pipelines. O cache de texturas resolve isso mantendo versões GPU de imagens comuns em memória.

Considere um botão simples com fundo arredondado e ícone. Sem cache, cada botão na tela faria:

```rust
// CÓDIGO RUIM - recria textura a cada frame
fn render_button(device: &wgpu::Device, queue: &wgpu::Queue) -> wgpu::Texture {
    let texture = device.create_texture(&wgpu::TextureDescriptor {
        size: wgpu::Extent3d { width: 64, height: 64, depth_or_array_layers: 1 },
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::Rgba8UnormSrgb,
        usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
        label: Some("button_texture"),
    });
    
    // Upload dos dados (simplificado)
    queue.write_texture(
        wgpu::ImageCopyTexture { texture: &texture, mip_level: 0, origin: wgpu::Origin3d::ZERO },
        &generate_button_texture(),
        wgpu::ImageDataLayout { offset: 0, bytes_per_row: Some(256), rows_per_image: None },
        wgpu::Extent3d { width: 64, height: 64, depth_or_array_layers: 1 },
    );
    
    texture
}
```

O problema aparece quando renderizamos 100 botões: 100 texturas idênticas ocupando VRAM. A solução é um cache centralizado:

```rust
struct TextureCache {
    device: Arc<wgpu::Device>,
    textures: HashMap<String, Arc<wgpu::Texture>>,
}

impl TextureCache {
    fn get_or_create(&mut self, key: &str, generator: fn() -> Vec<u8>) -> Arc<wgpu::Texture> {
        if let Some(texture) = self.textures.get(key) {
            return texture.clone();
        }
        
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            size: wgpu::Extent3d { width: 64, height: 64, depth_or_array_layers: 1 },
            // ... restante igual ao exemplo anterior
        });
        
        self.textures.insert(key.to_string(), Arc::new(texture));
        self.textures[key].clone()
    }
}
```

Erro comum: esquecer que texturas GPU não podem ser compartilhadas entre threads sem sincronização. A mensagem de erro típica seria:

```
thread 'main' panicked at 'wgpu::Texture cannot be sent between threads safely'
```

A correção usa `Arc` para compartilhamento seguro:

```rust
// Uso correto do cache entre threads
let cache = Arc::new(Mutex::new(TextureCache::new(device)));
let cached_texture = cache.lock().unwrap()
    .get_or_create("button_normal", generate_button_texture);
```

Para texturas dinâmicas (como thumbnails gerados em runtime), adicione um mecanismo de expiração:

```rust
struct CachedTexture {
    texture: Arc<wgpu::Texture>,
    last_used: Instant,
}

impl TextureCache {
    fn purge_old(&mut self, max_age: Duration) {
        self.textures.retain(|_, ct| ct.last_used.elapsed() < max_age);
    }
}
```

Exercício: Implemente um cache que armazene tanto texturas GPU quanto suas views correspondentes, evitando recriação de `TextureView`. Solução:

```rust
struct TextureCacheEntry {
    texture: Arc<wgpu::Texture>,
    view: Arc<wgpu::TextureView>,
}

impl TextureCache {
    fn get_view(&mut self, key: &str) -> Arc<wgpu::TextureView> {
        self.get_or_create(key).view.clone()
    }
}
```