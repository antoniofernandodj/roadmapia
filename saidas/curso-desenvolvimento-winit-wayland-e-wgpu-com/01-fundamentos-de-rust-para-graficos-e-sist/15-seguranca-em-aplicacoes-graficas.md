## Segurança em Aplicações Gráficas

Um buffer de vértices mal validado pode se tornar uma vulnerabilidade de execução arbitrária na GPU. O mesmo ocorre com texturas não sanitizadas, que podem vazar dados sensíveis ou crashar o driver gráfico. Em Rust, o sistema de tipos nos dá ferramentas para impedir esses erros na compilação, mas precisamos aplicá-los corretamente.

Considere este exemplo perigoso que aceita dados brutos para criar um buffer:

```rust
// UNSAFE: Problemas múltiplos de segurança
fn create_buffer(device: &wgpu::Device, data: &[u8], size: usize) -> wgpu::Buffer {
    device.create_buffer(&wgpu::BufferDescriptor {
        size,
        usage: wgpu::BufferUsages::VERTEX,
        mapped_at_creation: true,  // Permite escrita direta
    }).slice(..).get_mapped_range()[..data.len()].copy_from_slice(data);
}
```

Os problemas aqui incluem:
1. Não verificar se `size` é múltiplo do tamanho do vértice (vuln. de alinhamento)
2. Permitir sobrescrita além dos limites se `data.len() > size`
3. Não validar se `data` contém valores numéricos válidos

A versão segura usa tipos fortemente tipados e verificações:

```rust
#[derive(Debug)]
struct SafeBuffer {
    inner: wgpu::Buffer,
    vertex_count: usize,
}

impl SafeBuffer {
    fn new<T: bytemuck::Pod>(
        device: &wgpu::Device,
        vertices: &[T],
    ) -> Result<Self, BufferError> {
        let size = std::mem::size_of_val(vertices);
        
        // Validação em tempo de compilação via trait bound
        if !bytemuck::must_cast_slice::<T>(vertices).is_empty() {
            return Err(BufferError::EmptyData);
        }

        let buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Vertex Buffer"),
            contents: bytemuck::cast_slice(vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });

        Ok(Self {
            inner: buffer,
            vertex_count: vertices.len(),
        })
    }
}
```

Erro comum ao migrar de código inseguro:
```text
error[E0277]: the trait bound `[f32; 3]: bytemuck::Pod` is not satisfied
  --> src/buffer.rs:42:10
   |
42 |     SafeBuffer::new(device, &[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
   |          ^^^ the trait `bytemuck::Pod` is not implemented for `[f32; 3]`
```

A solução é garantir que o tipo implemente os traits necessários:
```rust
#[repr(C)]
#[derive(Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct Vertex {
    position: [f32; 3],
}
```

Para texturas, o principal risco é o carregamento de dados não sanitizados. Este exemplo mostra como validar dimensões e formato:

```rust
fn load_texture(
    device: &wgpu::Device,
    queue: &wgpu::Queue,
    pixels: &[u8],
    width: u32,
    height: u32,
) -> Result<wgpu::Texture, TextureError> {
    // 1. Validação de tamanho
    let expected_len = (width * height * 4) as usize; // RGBA8
    if pixels.len() != expected_len {
        return Err(TextureError::SizeMismatch {
            expected: expected_len,
            actual: pixels.len(),
        });
    }

    // 2. Validação de alinhamento
    if pixels.as_ptr() as usize % 4 != 0 {
        return Err(TextureError::UnalignedData);
    }

    // 3. Criação segura
    let texture = device.create_texture(&wgpu::TextureDescriptor {
        size: wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
        format: wgpu::TextureFormat::Rgba8Unorm,
        usage: wgpu::TextureUsages::TEXTURE_BINDING,
        mip_level_count: 1,
        sample_count: 1,
        dimension: wgpu::TextureDimension::D2,
    });

    queue.write_texture(
        wgpu::ImageCopyTexture {
            texture: &texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
        },
        pixels,
        wgpu::ImageDataLayout {
            offset: 0,
            bytes_per_row: Some(width * 4),
            rows_per_image: Some(height),
        },
        wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
    );

    Ok(texture)
}
```

**Thread Safety**: Recursos gráficos frequentemente precisam ser compartilhados entre threads. O padrão `Arc<Mutex<T>>` pode causar deadlocks. Melhor usar o sistema de ownership do WGPU:

```rust
struct SharedTexture {
    texture: Arc<wgpu::Texture>,
    // Usamos Atomic para contagem thread-safe
    ref_count: AtomicUsize,
}

impl SharedTexture {
    fn new(texture: wgpu::Texture) -> Self {
        Self {
            texture: Arc::new(texture),
            ref_count: AtomicUsize::new(1),
        }
    }

    // Clone seguro entre threads
    fn clone(&self) -> Self {
        self.ref_count.fetch_add(1, Ordering::SeqCst);
        Self {
            texture: self.texture.clone(),
            ref_count: self.ref_count.clone(),
        }
    }
}

// Uso seguro:
let texture = SharedTexture::new(create_texture(device));
let texture_clone = texture.clone();

thread::spawn(move || {
    renderer.use_texture(&texture_clone.texture);
});
```

**Exercício**: Implemente um `SafeUniformBuffer` que:
1. Valida o tamanho dos dados contra o layout do shader
2. Impede aliasing entre buffers
3. Garante alinhamento correto

```rust
// Solução parcial - complete as validações
struct SafeUniformBuffer<T: bytemuck::Pod> {
    buffer: wgpu::Buffer,
    _marker: PhantomData<T>,
}

impl<T: bytemuck::Pod> SafeUniformBuffer<T> {
    fn new(device: &wgpu::Device, initial: &T) -> Result<Self, BufferError> {
        // 1. Validar que T tem tamanho múltiplo de 256 (requerimento comum)
        // 2. Criar buffer com usage UNIFORM
        // 3. Escrever dados iniciais
        todo!()
    }
}
```

**Dica**: Use `std::mem::size_of::<T>()` e `wgpu::COPY_BUFFER_ALIGNMENT` para as validações de tamanho. Para o aliasing, adicione um campo `usage: wgpu::BufferUsages` na struct e verifique conflitos antes de cada operação.