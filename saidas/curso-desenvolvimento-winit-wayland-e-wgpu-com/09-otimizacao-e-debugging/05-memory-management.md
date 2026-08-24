## Memory Management

Em aplicações gráficas, cada alocação de memória pode significar megabytes em VRAM ou buffers de staging na CPU. O gerenciamento manual comum em C++ é substituído em Rust por um sistema que previne erros em tempo de compilação, mas exige padrões específicos para evitar overhead.

### O Problema dos Buffers de Vértices

Considere um buffer de vértices simples para um quadrado:

```rust
use wgpu::util::DeviceExt;

#[repr(C)]
#[derive(Copy, Clone, Debug)]
struct Vertex {
    position: [f32; 3],
    color: [f32; 4],
}

let vertices = [
    Vertex { position: [-0.5, -0.5, 0.0], color: [1.0, 0.0, 0.0, 1.0] },
    Vertex { position: [0.5, -0.5, 0.0], color: [0.0, 1.0, 0.0, 1.0] },
    Vertex { position: [0.5, 0.5, 0.0], color: [0.0, 0.0, 1.0, 1.0] },
    Vertex { position: [-0.5, 0.5, 0.0], color: [1.0, 1.0, 1.0, 1.0] },
];

let vertex_buffer = device.create_buffer_init(
    &wgpu::util::BufferInitDescriptor {
        label: Some("Vertex Buffer"),
        contents: bytemuck::cast_slice(&vertices),
        usage: wgpu::BufferUsages::VERTEX,
    }
);
```

Aqui, `bytemuck::cast_slice` converte nosso array de vértices em bytes sem cópia. O erro comum é tentar usar a slice após a transferência:

```rust
// ERRADO: vertices foi consumido pela GPU
println!("{:?}", vertices[0]); 
```

A mensagem de erro seria clara:
```
borrow of moved value: `vertices`
```

### Gerenciamento de Texturas

Texturas consomem mais memória que buffers. Criar uma textura 4K RGBA:

```rust
let texture_size = wgpu::Extent3d {
    width: 4096,
    height: 4096,
    depth_or_array_layers: 1,
};

let texture = device.create_texture(
    &wgpu::TextureDescriptor {
        size: texture_size,
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::Rgba8Unorm,
        usage: wgpu::TextureUsages::TEXTURE_BINDING 
            | wgpu::TextureUsages::COPY_DST,
        label: Some("4K Texture"),
        view_formats: &[],
    }
);
```

Isso aloca ~67MB em VRAM. O erro frequente é não liberar:

```rust
// Textura vazia mantém a alocação
std::mem::forget(texture); 
```

Em Rust, o `Drop` trait cuida da liberação, mas em cenários complexos você pode precisar de `Arc<Texture>`.

### Compartilhamento entre Threads

Renderização e lógica frequentemente rodam em threads separadas. Para compartilhar um buffer:

```rust
use std::sync::Arc;

let shared_buffer = Arc::new(vertex_buffer);

// Na thread de renderização:
let buffer_clone = shared_buffer.clone();
render_thread.spawn(move || {
    render_pass.set_vertex_buffer(0, buffer_clone.slice(..));
});
```

O erro comum é tentar usar `Mutex` desnecessariamente:

```rust
// DESNECESSÁRIO: WGPU buffers já são thread-safe
let over_engineered = Arc::new(Mutex::new(vertex_buffer)); 
```

### Memory Mapping Assíncrono

Mapear memória da GPU para CPU é operação custosa. Forma correta:

```rust
let staging_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    size: 1024,
    usage: wgpu::BufferUsages::MAP_READ | wgpu::BufferUsages::COPY_DST,
    mapped_at_creation: false,
    label: None,
});

// Assíncrono
staging_buffer.slice(..).map_async(wgpu::MapMode::Read, |result| {
    match result {
        Ok(()) => {
            let data = staging_buffer.slice(..).get_mapped_range();
            // Processar dados...
        }
        Err(e) => eprintln!("Falha no mapeamento: {:?}", e),
    }
});

device.poll(wgpu::Maintain::Wait);
```

O erro típico é esquecer de `poll`:

```
Buffer mapping failed: Validation Error: Buffer must be mapped before calling get_mapped_range
```

### Pooling de Recursos

Alocações dinâmicas frequentes são caras. Solução: pooling:

```rust
struct BufferPool {
    buffers: Vec<wgpu::Buffer>,
    device: Arc<wgpu::Device>,
}

impl BufferPool {
    fn get(&mut self, size: u64) -> wgpu::Buffer {
        if let Some(buffer) = self.buffers.pop() {
            if buffer.size() >= size {
                return buffer;
            }
        }
        self.device.create_buffer(&wgpu::BufferDescriptor {
            size,
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
            label: None,
        })
    }

    fn recycle(&mut self, buffer: wgpu::Buffer) {
        self.buffers.push(buffer);
    }
}
```

### Exercício: Vazamento de Memória

Identifique o vazamento neste código:

```rust
let mut textures = Vec::new();
for _ in 0..100 {
    let texture = device.create_texture(&wgpu::TextureDescriptor {
        size: wgpu::Extent3d { width: 1024, height: 1024, depth_or_array_layers: 1 },
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
        format: wgpu::TextureFormat::Rgba8Unorm,
        usage: wgpu::TextureUsages::TEXTURE_BINDING,
        label: None,
        view_formats: &[],
    });
    textures.push(texture);
}
// Esqueceu de liberar as texturas
```

**Solução**: As texturas não são liberadas. Em Rust, recursos GPU implementam `Drop`, mas se a coleção persistir, a memória não será liberada. A solução é limpar a coleção quando as texturas não forem mais necessárias ou usar um padrão de pooling.