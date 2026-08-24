## Resource Management

Quando você renderiza um cubo, a GPU precisa dos buffers de vértices, índices, texturas e uniforms. Agora imagine renderizar 10.000 cubos - alocar e desalocar recursos para cada um seria catastrófico para a performance. O problema real é: como gerenciar recursos GPU eficientemente sem sobrecarregar a API ou desperdiçar memória?

WGPU opera com três tipos principais de recursos:

```rust
// Buffer - Dados genéricos (vértices, uniforms, etc)
let vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Vertex Buffer"),
    size: vertices_size,
    usage: wgpu::BufferUsages::VERTEX,
    mapped_at_creation: false,
});

// Texture - Dados de imagem
let texture = device.create_texture(&wgpu::TextureDescriptor {
    label: Some("Diffuse Texture"),
    size: texture_size,
    mip_level_count: 1,
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Rgba8UnormSrgb,
    usage: wgpu::TextureUsages::TEXTURE_BINDING,
});

// BindGroup - Agrupamento lógico
let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
    label: Some("Camera Bind Group"),
    layout: &camera_bind_group_layout,
    entries: &[wgpu::BindGroupEntry {
        binding: 0,
        resource: wgpu::BindingResource::Buffer(uniform_buffer.as_entire_binding()),
    }],
});
```

A armadilha mais comum é tentar recriar recursos a cada frame. O erro típico:

```rust
// ERRADO: Alocação por frame
fn render() {
    let new_buffer = device.create_buffer(...); // Alocação desnecessária!
    // ... usar buffer
} // Buffer é descartado
```

O correto é reutilizar:

```rust
// Estrutura de gerenciamento
struct MeshResources {
    vertex_buffer: wgpu::Buffer,
    index_buffer: wgpu::Buffer,
    texture: wgpu::Texture,
    bind_group: wgpu::BindGroup,
}

impl MeshResources {
    fn new(device: &wgpu::Device, mesh: &Mesh) -> Self {
        // Criação única dos recursos
        let vertex_buffer = device.create_buffer_init(...);
        let index_buffer = device.create_buffer_init(...);
        let texture = create_texture(device, mesh.texture_data);
        let bind_group = create_bind_group(device, &vertex_buffer, &texture);
        
        Self { vertex_buffer, index_buffer, texture, bind_group }
    }
}
```

Para cenas complexas, implementamos um sistema de pooling baseado em hashes:

```rust
struct ResourcePool {
    buffers: HashMap<u64, wgpu::Buffer>,
    textures: HashMap<u64, wgpu::Texture>,
    bind_groups: HashMap<u64, wgpu::BindGroup>,
}

impl ResourcePool {
    fn get_or_create_buffer(
        &mut self,
        device: &wgpu::Device,
        data: &[u8],
        usage: wgpu::BufferUsages,
    ) -> &wgpu::Buffer {
        let hash = calculate_hash(data, usage);
        self.buffers.entry(hash).or_insert_with(|| {
            device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("Pooled Buffer"),
                contents: data,
                usage,
            })
        })
    }
}
```

Quando a GPU reporta memória insuficiente (erro `OUT_OF_MEMORY`), a estratégia é:

1. Liberar recursos não usados recentemente
2. Reduzir qualidade de texturas
3. Implementar carregamento progressivo

Exemplo de tratamento:

```rust
match device.create_buffer(&descriptor) {
    Ok(buffer) => Ok(buffer),
    Err(wgpu::CreateBufferError::OutOfMemory) => {
        self.cleanup_old_resources();
        device.create_buffer(&descriptor)
    }
}
```

Para uniformes que mudam por frame, use buffers mapeáveis:

```rust
let dynamic_uniform_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Dynamic Uniform Buffer"),
    size: mem::size_of::<CameraUniform>() as u64,
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    mapped_at_creation: false,
});

// Atualização eficiente
queue.write_buffer(
    &dynamic_uniform_buffer,
    0,
    bytemuck::cast_slice(&[camera_uniform]),
);
```

Exercício: Implemente um sistema que carrega 1000 texturas, mas mantém apenas as 100 mais recentemente usadas na GPU, descarregando as outras para RAM.

Solução:

```rust
struct LRUTextureCache {
    textures: LinkedHashMap<TextureId, (wgpu::Texture, bool /* in_gpu */)>,
    device: Arc<wgpu::Device>,
    max_gpu_textures: usize,
}

impl LRUTextureCache {
    fn get(&mut self, id: TextureId) -> &wgpu::Texture {
        let (texture, in_gpu) = self.textures.get_refresh(&id).unwrap();
        
        if !*in_gpu {
            self.ensure_space();
            let texture = load_to_gpu(&self.device, id);
            *in_gpu = true;
        }
        
        texture
    }
    
    fn ensure_space(&mut self) {
        while self.textures.len() >= self.max_gpu_textures {
            if let Some((id, (texture, in_gpu))) = self.textures.pop_front() {
                if *in_gpu {
                    *in_gpu = false;
                    save_to_ram(id, texture);
                }
            }
        }
    }
}
```