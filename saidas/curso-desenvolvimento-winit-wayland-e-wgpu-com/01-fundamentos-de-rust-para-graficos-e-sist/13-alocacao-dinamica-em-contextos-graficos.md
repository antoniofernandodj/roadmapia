## Alocação Dinâmica em Contextos Gráficos

Aplicações gráficas lidam com objetos cujo tamanho só é conhecido em tempo de execução - buffers de vértices, texturas alocadas dinamicamente, shaders gerados proceduralmente. Rust oferece três estratégias principais para esses casos:

1. **`Vec<T>` para alocação contígua**: O tipo padrão para coleções dinâmicas, mas com overhead de realocação. Em gráficos, usamos com moderação:

```rust
let mut dynamic_vertices: Vec<f32> = Vec::with_capacity(1024);
for i in 0..100 {
    dynamic_vertices.extend(&[i as f32, (i*2) as f32, 0.0]);
}

// Erro comum: esquecer de reservar capacidade
let mut bad_vertices = Vec::new();
bad_vertices.extend((0..1000).map(|i| [i as f32; 3])); // Múltiplas realocações
```

2. **Arenas alocadoras (`bumpalo`)**: Ideal para objetos temporários com ciclo de vida conhecido:

```rust
use bumpalo::Bump;

let arena = Bump::new();
let vertices: &mut [f32] = arena.alloc_slice_fill(1_000_000, 0.0);

// Preenchimento paralelo seguro
vertices.par_iter_mut().for_each(|v| *v = rand::random());
```

3. **Alocação direta na GPU (WGPU)**: O método mais eficiente para dados que permanecem na GPU:

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Dynamic Vertex Buffer"),
    size: (std::mem::size_of::<f32>() * vertex_count) as u64,
    usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
    mapped_at_creation: false,
});
```

### Padrão de Transferência para GPU

A alocação dinâmica frequentemente envolve três etapas:

1. CPU: Preparar dados em memória temporária
2. Staging: Copiar para buffer temporário na GPU
3. Final: Transferir para buffer de destino

```rust
// 1. Alocação temporária na CPU (usando bumpalo para performance)
let arena = Bump::new();
let temp_data = arena.alloc_slice_fill(vertex_count, Vertex::default());

// 2. Criar buffer de staging
let staging = device.create_buffer(&wgpu::BufferDescriptor {
    size: temp_data.len() as u64,
    usage: wgpu::BufferUsages::COPY_SRC,
    mapped_at_creation: true,
});

// 3. Copiar para staging e depois para destino
queue.write_buffer(&staging, 0, bytemuck::cast_slice(temp_data));
let cmd_buf = {
    let mut encoder = device.create_command_encoder();
    encoder.copy_buffer_to_buffer(&staging, 0, &buffer, 0, size);
    encoder.finish()
};
queue.submit(std::iter::once(cmd_buf));
```

### Gerenciamento de Lifetimes

Para recursos que referenciam buffers alocados dinamicamente, usamos parâmetros de lifetime:

```rust
struct Mesh<'a> {
    vertex_buffer: wgpu::Buffer,
    vertex_data: &'a [Vertex],  // Referência aos dados originais
}

impl<'a> Mesh<'a> {
    pub fn new(device: &wgpu::Device, data: &'a [Vertex]) -> Self {
        let buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Vertex Buffer"),
            contents: bytemuck::cast_slice(data),
            usage: wgpu::BufferUsages::VERTEX,
        });
        Self { vertex_buffer: buffer, vertex_data: data }
    }
}
```

### Exercício Prático

Implemente um sistema de partículas dinâmico onde:
1. Partículas são geradas em tempo de execução
2. Atualizadas na CPU usando Rayon para paralelismo
3. Transferidas para GPU a cada frame

**Solução comentada**:

```rust
struct ParticleSystem {
    staging: wgpu::Buffer,
    gpu_buffer: wgpu::Buffer,
    particle_count: usize,
}

impl ParticleSystem {
    fn update(&mut self, queue: &wgpu::Queue, dt: f32) {
        // 1. Mapear staging buffer temporariamente
        let slice = self.staging.slice(..);
        let (tx, rx) = futures::channel::oneshot::channel();
        slice.map_async(wgpu::MapMode::Write, |_| tx.send(()).unwrap());

        // 2. Preencher em paralelo
        let mut view = slice.get_mapped_range_mut();
        let particles: &mut [Particle] = bytemuck::cast_slice_mut(&mut view);
        particles.par_iter_mut().for_each(|p| {
            p.position += p.velocity * dt;
            p.velocity.y -= 9.81 * dt;
        });

        // 3. Desmapear e transferir
        drop(view);
        self.staging.unmap();
        let mut encoder = device.create_command_encoder();
        encoder.copy_buffer_to_buffer(
            &self.staging, 0,
            &self.gpu_buffer, 0,
            (self.particle_count * std::mem::size_of::<Particle>()) as u64
        );
        queue.submit(Some(encoder.finish()));
    }
}
```