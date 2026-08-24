## Timestamp Queries

Quando você precisa medir com precisão quanto tempo uma operação na GPU está levando - seja para otimizar um shader complexo ou comparar técnicas de renderização - as timestamp queries são a ferramenta certa. Diferente de medir tempos na CPU, que podem não refletir o real trabalho na GPU devido ao pipeline assíncrono, elas capturam nanossegundos exatos do relógio interno da placa gráfica.

O mecanismo funciona através de dois comandos especiais inseridos na command queue:

```rust
// Durante a criação do dispositivo, precisamos verificar suporte
let features = wgpu::Features::TIMESTAMP_QUERY;
let device = adapter.request_device(&desc, Some((&features, &[]))).await?;

// Criando o query set para armazenar os resultados
let query_set = device.create_query_set(&wgpu::QuerySetDescriptor {
    label: Some("Timestamp queries"),
    count: 2,  // Dois timestamps: início e fim
    ty: wgpu::QueryType::Timestamp,
});
```

Um erro comum é esquecer de habilitar o feature flag `TIMESTAMP_QUERY` durante a criação do dispositivo. Sem isso, você receberá o erro:

```
Error: Validation Error: QueryType(Timestamp) requires features [TIMESTAMP_QUERY]
```

Para usar as queries, inserimos comandos de escrita no render pass:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Timestamp query encoder"),
});

// Início da medição
encoder.write_timestamp(&query_set, 0);

// Operação que queremos medir (ex: renderizar um mesh complexo)
render_heavy_mesh(&mut encoder, &render_pass);

// Fim da medição
encoder.write_timestamp(&query_set, 1);

// Resolver as queries para um buffer
let query_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Timestamp query results"),
    size: 16,  // 2 timestamps de 8 bytes cada
    usage: wgpu::BufferUsages::QUERY_RESOLVE | wgpu::BufferUsages::COPY_SRC,
});

encoder.resolve_query_set(
    &query_set,
    0..2,  // Intervalo das queries a resolver
    &query_buffer,
    0,      // Offset no buffer de destino
);
```

Os resultados ficam em um buffer que precisa ser mapeado para leitura na CPU. Aqui está como extrair os valores:

```rust
// Criar um buffer de staging para copiar os resultados
let staging_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Timestamp staging buffer"),
    size: 16,
    usage: wgpu::BufferUsages::MAP_READ | wgpu::BufferUsages::COPY_DST,
});

// Copiar do query buffer para o staging buffer
encoder.copy_buffer_to_buffer(&query_buffer, 0, &staging_buffer, 0, 16);

// Submeter os comandos
queue.submit(Some(encoder.finish()));

// Mapear e ler os resultados
let buffer_slice = staging_buffer.slice(..);
buffer_slice.map_async(wgpu::MapMode::Read, |_| {});
device.poll(wgpu::Maintain::Wait);

let data = buffer_slice.get_mapped_range();
let timestamps: &[u64; 2] = bytemuck::cast_slice(&data)[0];
let duration_ns = timestamps[1] - timestamps[0];
println!("Tempo de renderização: {} ns", duration_ns);
```

A saída mostra algo como:
```
Tempo de renderização: 125000 ns
```

Um detalhe crucial: os timestamps têm resolução limitada. Você pode consultá-la com:

```rust
let timestamp_period = queue.get_timestamp_period(); // Nanossegundos por incremento
```

Se tentar medir intervalos muito curtos, pode obter resultados inconsistentes. Uma prática comum é envolver várias execuções da mesma operação em uma única medição para aumentar a precisão.

**Exercício**: Modifique o código para medir o tempo de um compute shader que soma dois buffers. Compare com a implementação CPU equivalente.

```rust
// Solução:
// 1. Crie um compute pipeline simples para soma de buffers
// 2. Insira as timestamp queries antes e depois do dispatch
// 3. Compare com:
let start = std::time::Instant::now();
// Implementação CPU da soma...
let cpu_duration = start.elapsed();
```