## Occlusion Queries

Quando renderizamos cenas 3D complexas, muitos objetos são desenhados apenas para serem totalmente ocultados por outros que estão mais próximos da câmera. Isso desperdiça ciclos preciosos da GPU processando geometria que nunca será visível no resultado final. É aqui que entram as occlusion queries.

Imagine uma cena com um prédio e centenas de carros estacionados em seu estacionamento. Se a câmera estiver posicionada de forma que o prédio oculte completamente os carros, não faz sentido renderizá-los. Uma occlusion query nos permite perguntar à GPU: "quantos pixels deste objeto realmente passaram no teste de profundidade?".

Vamos implementar um exemplo prático. Primeiro, precisamos configurar o `Device` para suportar queries:

```rust
let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
    backends: wgpu::Backends::all(),
    dx12_shader_compiler: Default::default(),
});

let adapter = instance.request_adapter(&wgpu::RequestAdapterOptions {
    power_preference: wgpu::PowerPreference::HighPerformance,
    compatible_surface: None,
    force_fallback_adapter: false,
}).await.unwrap();

let (device, queue) = adapter.request_device(
    &wgpu::DeviceDescriptor {
        features: wgpu::Features::OCCLUSION_QUERY,
        limits: wgpu::Limits::default(),
        label: None,
    },
    None,
).await.unwrap();
```

Agora criamos um `QuerySet` para armazenar nossos resultados:

```rust
let query_set = device.create_query_set(&wgpu::QuerySetDescriptor {
    count: 2,  // Uma query para o objeto ocultor e outra para o testado
    ty: wgpu::QueryType::Occlusion,
    label: Some("occlusion_query_set"),
});
```

Vamos modificar nosso `RenderPass` para incluir as queries. Observe como inserimos os comandos de início e término da query:

```rust
let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Occlusion Test Render Pass"),
    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
        view: &frame.view,
        resolve_target: None,
        ops: wgpu::Operations {
            load: wgpu::LoadOp::Clear(wgpu::Color::BLACK),
            store: wgpu::StoreOp::Store,
        },
    })],
    depth_stencil_attachment: None,
    occlusion_query_set: Some(&query_set),
    timestamp_writes: None,
});

// Primeiro renderizamos o objeto ocultor (o prédio)
render_pass.begin_occlusion_query(0);  // Índice 0 no QuerySet
render_pass.set_pipeline(&building_pipeline);
render_pass.draw(0..building_vertex_count, 0..1);
render_pass.end_occlusion_query();

// Depois renderizamos o objeto testado (os carros)
render_pass.begin_occlusion_query(1);  // Índice 1 no QuerySet
render_pass.set_pipeline(&cars_pipeline);
render_pass.draw(0..cars_vertex_count, 0..1);
render_pass.end_occlusion_query();
```

Para ler os resultados, precisamos resolver as queries em um buffer:

```rust
let query_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Occlusion Query Results"),
    size: std::mem::size_of::<u64>() as u64 * 2,  // Dois resultados
    usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
    mapped_at_creation: false,
});

encoder.resolve_query_set(
    &query_set,
    0..2,  // Resolver ambas as queries (0 e 1)
    &query_buffer,
    0,      // Offset no buffer de destino
);
```

Um erro comum é tentar ler os resultados imediatamente após o `resolve_query_set`. A GPU opera de forma assíncrona, então precisamos esperar a conclusão:

```rust
queue.submit(Some(encoder.finish()));

// Aguarda a conclusão da GPU
let buffer_slice = query_buffer.slice(..);
buffer_slice.map_async(wgpu::MapMode::Read, |result| {
    if let Err(e) = result {
        eprintln!("Failed to map buffer: {}", e);
        return;
    }

    let data = buffer_slice.get_mapped_range();
    let results: &[u64] = bytemuck::cast_slice(&data);
    
    println!("Occlusion results:");
    println!("Occluder (prédio): {} pixels visíveis", results[0]);
    println!("Test object (carros): {} pixels visíveis", results[1]);
});

device.poll(wgpu::Maintain::Wait);
```

Se o número de pixels visíveis do objeto testado (carros) for zero, podemos pular sua renderização nos próximos frames até que a câmera se mova. Um erro típico é esquecer de verificar o recurso `OCCLUSION_QUERY` no `DeviceDescriptor`, resultando no erro:

```
Error in Device::create_query_set: The device does not support the Occlusion query feature
```

Outra armadilha é tentar usar a mesma query em múltiplos frames sem resetá-la. O comportamento é indefinido nesse caso. Sempre use um novo conjunto de queries a cada frame ou reinicie-as explicitamente.

**Exercício:** Modifique o exemplo para incluir um terceiro objeto (uma cerca) que parcialmente oculte os carros. Compare os resultados quando a cerca está presente e quando é removida.

**Solução:**

```rust
// Adicione uma terceira query (índice 2)
let query_set = device.create_query_set(&wgpu::QuerySetDescriptor {
    count: 3,
    ty: wgpu::QueryType::Occlusion,
    label: Some("occlusion_query_set"),
});

// No render pass:
render_pass.begin_occlusion_query(2);  // Índice 2 para a cerca
render_pass.set_pipeline(&fence_pipeline);
render_pass.draw(0..fence_vertex_count, 0..1);
render_pass.end_occlusion_query();
```

A saída mostrará que, com a cerca, os carros terão menos pixels visíveis do que quando ela está ausente, demonstrando como a oclusão parcial funciona na prática.