## Multi-threading Básico

Renderização gráfica é uma tarefa intensiva que pode bloquear sua thread principal, causando travamentos na UI. Veja o que acontece quando você tenta carregar uma textura grande enquanto renderiza:

```rust
// Thread principal
let texture = device.create_texture(&TextureDescriptor {
    size: Extent3d { width: 8192, height: 8192, .. },
    mip_level_count: 1,
    sample_count: 1,
    dimension: TextureDimension::D2,
    format: TextureFormat::Rgba8Unorm,
    usage: TextureUsage::TEXTURE_BINDING,
    label: None,
});

// Bloqueia por 120ms no meu sistema!
```

Para resolver isso, WGPU opera de forma assíncrona por padrão, mas precisamos estruturar nosso código para aproveitar múltiplas threads. O ponto de partida é a `Queue`, que é `Send + Sync` e pode ser compartilhada entre threads:

```rust
let queue = Arc::new(device.create_queue(&QueueDescriptor {
    label: Some("main_queue"),
}));

let queue_clone = Arc::clone(&queue);
thread::spawn(move || {
    // Esta thread pode submeter comandos à GPU
    queue_clone.submit(&[command_buffer]);
});
```

Cuidado comum: buffers e texturas NÃO são automaticamente thread-safe. Este código falha:

```rust
let buffer = device.create_buffer(&BufferDescriptor { /* ... */ });

thread::spawn(move || {
    queue.write_buffer(&buffer, 0, &data); // ERRO: buffer foi movido
});
```

A mensagem de erro será:
```
error[E0382]: use of moved value: `buffer`
  --> src/main.rs:42:22
   |
40 |     let buffer = device.create_buffer(/* ... */);
   |         ------ move occurs because `buffer` has type `wgpu::Buffer`, which does not implement the `Copy` trait
41 |     thread::spawn(move || {
42 |         queue.write_buffer(&buffer, 0, &data);
   |                            ^^^^^^^ value moved here, in previous iteration of loop
```

A solução é usar `Arc` para buffers compartilhados:

```rust
let buffer = Arc::new(device.create_buffer(/* ... */));
let buffer_clone = Arc::clone(&buffer);

thread::spawn(move || {
    queue.write_buffer(&buffer_clone, 0, &data); // Ok!
});
```

Para operações complexas, você pode criar um worker thread dedicado:

```rust
let (sender, receiver) = crossbeam_channel::bounded(10);
let render_thread = thread::spawn(move || {
    while let Ok((vertices, indices)) = receiver.recv() {
        let buffer = device.create_buffer_init(&BufferInitDescriptor {
            contents: bytemuck::cast_slice(vertices),
            usage: BufferUsage::VERTEX,
        });
        // Processamento continua...
    }
});

// Envia dados para a thread de renderização
sender.send((vertices_data, indices_data)).unwrap();
```

Padrão útil: pipeline de processamento com múltiplos estágios:

```rust
let (prep_sender, prep_receiver) = crossbeam_channel::bounded(5);
let (render_sender, render_receiver) = crossbeam_channel::bounded(5);

thread::spawn(move || {
    // Thread de preparação
    for mesh in prep_receiver {
        let processed = process_mesh(mesh);
        render_sender.send(processed).unwrap();
    }
});

thread::spawn(move || {
    // Thread de renderização
    for mesh in render_receiver {
        render_mesh(&device, &queue, mesh);
    }
});
```

Exercício: Modifique este código para carregar texturas em paralelo:

```rust
fn load_texture(path: &str) -> wgpu::Texture {
    let image = image::open(path).unwrap().to_rgba8();
    let texture = // ... criar textura ...
    texture
}
```

Solução:

```rust
fn load_texture_parallel(
    path: &str,
    device: Arc<wgpu::Device>,
    queue: Arc<wgpu::Queue>
) -> thread::JoinHandle<wgpu::Texture> {
    thread::spawn(move || {
        let image = image::open(path).unwrap().to_rgba8();
        let texture = device.create_texture(/* ... */);
        queue.write_texture(/* ... */);
        texture
    })
}

// Uso:
let handles: Vec<_> = textures_paths.iter()
    .map(|path| load_texture_parallel(path, Arc::clone(&device), Arc::clone(&queue)))
    .collect();

let loaded_textures: Vec<_> = handles.into_iter()
    .map(|h| h.join().unwrap())
    .collect();
```