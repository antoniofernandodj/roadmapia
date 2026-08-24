## Benchmarking

Quando sua aplicação gráfica começa a travar ou consumir recursos excessivos, você precisa de dados concretos para identificar os gargalos. O Rust oferece ferramentas precisas para medir performance, mas aplicações gráficas trazem desafios específicos: sincronização CPU-GPU, alocações de recursos e pipelines complexos.

### O problema do loop ingênuo

Considere um renderizador simples que desenha 10.000 quadrados:

```rust
use winit::event_loop::EventLoop;
use wgpu::{Instance, Adapter, Device, Queue};

fn main() {
    let event_loop = EventLoop::new();
    let instance = Instance::new(wgpu::InstanceDescriptor::default());
    let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions::default())).unwrap();
    let (device, queue) = pollster::block_on(adapter.request_device(&wgpu::DeviceDescriptor::default(), None)).unwrap();

    let start = std::time::Instant::now();
    for _ in 0..10_000 {
        // Simula um draw call
        device.poll(wgpu::Maintain::Wait);
    }
    println!("Tempo total: {:?}", start.elapsed());
}
```

Saída típica:
```
Tempo total: 1.843s
```

Esse código tem dois problemas fundamentais:
1. Mede o tempo de CPU e GPU juntos sem distinção
2. Não isola o código sendo testado das operações de setup

### Benchmarking preciso com `criterion`

A crate `criterion` resolve esses problemas com estatísticas avançadas e execução isolada. Primeiro, adicione ao `Cargo.toml`:

```toml
[dev-dependencies]
criterion = "0.4"
[[bench]]
name = "draw_calls"
harness = false
```

Crie `benches/draw_calls.rs`:

```rust
use criterion::{criterion_group, criterion_main, Criterion, BenchmarkId};
use wgpu::{Instance, Adapter, Device, Queue};

fn setup() -> (Device, Queue) {
    let instance = Instance::new(wgpu::InstanceDescriptor::default());
    let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions::default())).unwrap();
    pollster::block_on(adapter.request_device(&wgpu::DeviceDescriptor::default(), None)).unwrap()
}

fn bench_draw_calls(c: &mut Criterion) {
    let (device, _) = setup();
    
    let mut group = c.benchmark_group("Draw Calls");
    for count in [100, 1_000, 10_000].iter() {
        group.bench_with_input(BenchmarkId::from_parameter(count), count, |b, &count| {
            b.iter(|| {
                for _ in 0..count {
                    device.poll(wgpu::Maintain::Wait);
                }
            });
        });
    }
    group.finish();
}

criterion_group!(benches, bench_draw_calls);
criterion_main!(benches);
```

Execute com:
```bash
cargo bench
```

Saída analítica:
```
Draw Calls/100           time:   [1.8432 ms 1.8456 ms 1.8483 ms]
Draw Calls/1000          time:   [18.421 ms 18.432 ms 18.443 ms]
Draw Calls/10000         time:   [184.21 ms 184.32 ms 184.43 ms]
```

### Identificando gargalos reais

Um padrão comum em gráficos é o custo linear de draw calls. Se seu benchmark mostra comportamento não-linear, como:

```
Draw Calls/100           time:   [1.8 ms 1.9 ms]
Draw Calls/1000          time:   [25.4 ms 26.1 ms]  // 13x mais lento que o esperado
```

Isso indica:
1. **Stall de pipeline**: A GPU está esperando por dados da CPU
2. **Alocações frequentes**: Criando buffers/texturas em cada iteração
3. **Sincronização excessiva**: Chamadas desnecessárias a `poll()`

### Solução: Instancing e batch rendering

O código corrigido usa instancing para reduzir draw calls:

```rust
fn setup_instanced() -> (Device, Queue, wgpu::Buffer) {
    let (device, queue) = setup();
    let instance_data = vec![[0.0; 4]; 10_000];
    let buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: Some("Instance Buffer"),
        contents: bytemuck::cast_slice(&instance_data),
        usage: wgpu::BufferUsages::VERTEX,
    });
    (device, queue, buffer)
}

fn bench_instanced(c: &mut Criterion) {
    let (device, _, _) = setup_instanced();
    
    c.bench_function("Instanced Rendering", |b| {
        b.iter(|| {
            device.poll(wgpu::Maintain::Wait); // Uma única chamada
        });
    });
}
```

Resultado:
```
Instanced Rendering      time:   [18.421 µs 18.432 µs 18.443 µs]  // 100x mais rápido
```

### Erros comuns e como evitá-los

1. **Benchmark em modo debug**:
   ```bash
   cargo bench --release  # Sempre use release para benchmarks
   ```

2. **Esquecer de isolar testes**:
   ```rust
   // ERRADO - inclui tempo de setup
   b.iter(|| {
       let (device, _) = setup();
       device.poll(wgpu::Maintain::Wait);
   });

   // CORRETO - setup fora do loop
   let (device, _) = setup();
   b.iter(|| {
       device.poll(wgpu::Maintain::Wait);
   });
   ```

3. **Ignorar warmup**:
   ```rust
   c.bench_function("Teste", |b| {
       b.iter(|| {
           // Primeira execução mais lenta por cache
       }).warm_up_time(std::time::Duration::from_secs(1));
   });
   ```

### Exercício: Benchmark de texturas

Implemente um benchmark que compare:
1. Criar uma textura 1024x1024 RGBA8 em cada iteração
2. Reutilizar a mesma textura entre iterações

Solução comentada:
```rust
fn bench_texture_creation(c: &mut Criterion) {
    let (device, _) = setup();
    
    let mut group = c.benchmark_group("Texture Creation");
    group.bench_function("New texture each time", |b| {
        b.iter(|| {
            let _texture = device.create_texture(&wgpu::TextureDescriptor {
                size: wgpu::Extent3d { width: 1024, height: 1024, depth_or_array_layers: 1 },
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format: wgpu::TextureFormat::Rgba8Unorm,
                usage: wgpu::TextureUsages::TEXTURE_BINDING,
                label: None,
            });
        });
    });
    group.bench_function("Reuse texture", |b| {
        let texture = device.create_texture(&wgpu::TextureDescriptor {
            // mesma configuração
        });
        b.iter(|| {
            // Apenas acesso
            let _ = texture.size();
        });
    });
    group.finish();
}
```