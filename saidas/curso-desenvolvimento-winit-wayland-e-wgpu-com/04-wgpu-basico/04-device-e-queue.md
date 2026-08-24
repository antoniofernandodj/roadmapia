## Device e Queue

Com o `Adapter` selecionado, precisamos criar os objetos que realmente executam comandos gráficos: o `Device` (dispositivo) e a `Queue` (fila). Eles formam o coração da comunicação com a GPU, onde:

1. **Device**: Gerencia recursos como buffers e texturas
2. **Queue**: Processa comandos de renderização de forma assíncrona

Um erro comum é tentar criar múltiplas Queues sem entender as limitações do hardware. Vamos começar com um exemplo prático:

```rust
async fn create_device_queue(adapter: &wgpu::Adapter) -> (wgpu::Device, wgpu::Queue) {
    let (device, queue) = adapter
        .request_device(
            &wgpu::DeviceDescriptor {
                label: Some("Dispositivo Principal"),
                features: wgpu::Features::empty(), // Comece simples
                limits: wgpu::Limits::default(),   // Limites conservadores
            },
            None, // Trace path (para debugging avançado)
        )
        .await
        .expect("Falha ao criar dispositivo!");

    (device, queue)
}
```

O que acontece se tentarmos usar recursos não suportados? Veja o erro real:

```rust
let (device, _) = adapter
    .request_device(
        &wgpu::DeviceDescriptor {
            features: wgpu::Features::PUSH_CONSTANTS, // Não suportado em alguns hardwares
            ..Default::default()
        },
        None,
    )
    .await;
```

Saída do erro:
```
Error: Requested feature PUSH_CONSTANTS is not supported
```

Para resolver, sempre verifique os recursos disponíveis:

```rust
let supported_features = adapter.features();
let safe_features = supported_features & wgpu::Features::PUSH_CONSTANTS;
```

**Como a Queue funciona internamente?**
1. Comandos são gravados em um `CommandEncoder`
2. O encoder produz um `CommandBuffer`
3. A Queue submete o buffer para execução na GPU

Exemplo de submissão:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Encoder Básico"),
});

// [...] Aqui iriam os comandos de renderização

let command_buffer = encoder.finish();
queue.submit(std::iter::once(command_buffer));
```

**Gerenciamento de recursos:**
```rust
// Criação de buffer simples
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Buffer de Vértices"),
    size: 1024, // 1KB
    usage: wgpu::BufferUsages::VERTEX,
    mapped_at_creation: false,
});

// Upload de dados para a GPU
queue.write_buffer(&buffer, 0, &[1u8, 2, 3, 4]);
```

**Erro comum:** Tentar usar a queue após a destruição do device:
```rust
let (device, queue) = create_device_queue(&adapter).await;
drop(device);
queue.submit([]); // PANIC!
```

Mensagem de erro típica:
```
thread 'main' panicked at 'Lost device'
```

**Exercício:** Crie uma função que verifica se o adapter suporta pelo menos 3 queues simultâneas antes de criar o device.

```rust
async fn check_multi_queue_support(adapter: &wgpu::Adapter) -> bool {
    let limits = adapter.limits();
    limits.max_buffers_per_shader_stage >= 3
}
```

Solução comentada:
1. Verificamos `max_buffers_per_shader_stage` pois ele indica capacidade geral
2. O valor 3 é arbitrário para sistemas básicos
3. Em casos reais, consulte `adapter.limits()` para valores exatos