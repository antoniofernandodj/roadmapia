## Sincronização Básica

Quando você envia comandos para a GPU com `queue.submit()`, eles não executam imediatamente. A GPU opera de forma assíncrona, processando comandos em sua própria linha do tempo. Isso cria um problema: como saber quando um comando terminou ou quando é seguro modificar um recurso compartilhado?

O WGPU oferece dois mecanismos primários para sincronização:

1. **Fences** (cercas): Marcadores que permitem à CPU saber quando a GPU alcançou um ponto específico
2. **Semáforos**: Sincronização entre operações na própria GPU

Vamos começar com um exemplo concreto que falha por falta de sincronização:

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Buffer de exemplo"),
    size: 1024,
    usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
    mapped_at_creation: false,
});

// Envia dados para o buffer
queue.write_buffer(&buffer, 0, &[1u8; 1024]);

// Tenta mapear o buffer para leitura imediatamente
buffer.slice(..).map_async(wgpu::MapMode::Read, |result| {
    result.unwrap();
});

// ERRO: Validation Error: Buffer mapping failed: Buffer not in mapped state
```

O erro ocorre porque `write_buffer` é assíncrono - a GPU ainda não terminou de processar o comando quando tentamos mapear o buffer. Para corrigir isso, precisamos usar uma **fence**:

```rust
let fence = device.create_fence();
queue.submit(Some(encoder.finish())); // Submete os comandos

// Espera até que a GPU alcance a fence
device.poll(wgpu::Maintain::WaitForFence(fence));

// Agora podemos mapear com segurança
buffer.slice(..).map_async(wgpu::MapMode::Read, |result| {
    result.unwrap();
    // Dados disponíveis aqui
});
```

O método `poll` bloqueia até que a GPU atinja o ponto de sincronização. Isso garante que todos os comandos anteriores foram processados.

### Semáforos Internos

WGPU também usa semáforos internamente para sincronizar operações na GPU. Quando você cria um render pass, ele automaticamente insere barreiras de memória onde necessário. Por exemplo:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Encoder com semáforos implícitos"),
});

// Primeiro render pass escreve para uma textura
{
    let _render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &texture_view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::GREEN),
                store: wgpu::StoreOp::Store,
            },
        })],
        ..Default::default()
    });
}

// Segundo render pass lê da mesma textura
{
    let _render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &output_view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::TRANSPARENT),
                store: wgpu::StoreOp::Store,
            },
        })],
        ..Default::default()
    });
}
```

O WGPU automaticamente insere uma barreira de memória entre os dois render passes, garantindo que o primeiro termine de escrever antes do segundo começar a ler.

### Exercício Prático

Modifique o exemplo abaixo para usar sincronização adequada. O código tenta ler um buffer imediatamente após escrever nele:

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    size: 1024,
    usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
    mapped_at_creation: false,
});

queue.write_buffer(&buffer, 0, &[1u8; 1024]);

buffer.slice(..).map_async(wgpu::MapMode::Read, |_| {});
```

**Solução:**

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    size: 1024,
    usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
    mapped_at_creation: false,
});

queue.write_buffer(&buffer, 0, &[1u8; 1024]);

// Cria uma fence para sincronização
let fence = device.create_fence();
device.poll(wgpu::Maintain::WaitForFence(fence));

// Agora é seguro mapear
buffer.slice(..).map_async(wgpu::MapMode::Read, |result| {
    result.unwrap();
    // Processar dados aqui
});
```

A chave é entender que a GPU opera em um pipeline assíncrono e que a sincronização explícita é necessária sempre que a CPU precisa interagir com recursos compartilhados.