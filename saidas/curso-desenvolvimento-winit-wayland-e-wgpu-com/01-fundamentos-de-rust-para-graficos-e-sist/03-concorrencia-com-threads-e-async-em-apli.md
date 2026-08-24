## Concorrência com Threads e Async em Aplicações Gráficas

Uma aplicação gráfica bloqueando na thread principal é imediatamente perceptível: a interface congela, os FPS despencam, e a experiência fica inutilizável. O desafio é mover trabalho pesado para segundo plano sem criar race conditions ou travamentos.

Considere este cenário real: carregar uma textura de 4K do disco enquanto mantém a interface responsiva. A abordagem ingênua falha dramaticamente:

```rust
// ERRADO: Congela a UI durante o carregamento
fn load_texture(path: &Path) -> Texture {
    let pixels = image::open(path).unwrap(); // Bloqueia aqui!
    Texture::from_pixels(pixels)
}
```

A solução envolve threads, mas com cuidado especial aos recursos gráficos. WGPU exige que recursos como texturas sejam criados na thread principal (a "thread gráfica"), mas podemos preparar os dados em background:

```rust
struct TextureLoader {
    sender: mpsc::Sender<TextureData>,
    handle: thread::JoinHandle<()>,
}

impl TextureLoader {
    pub fn new(device: Arc<Mutex<Device>>) -> Self {
        let (sender, receiver) = mpsc::channel();
        
        let handle = thread::spawn(move || {
            while let Ok(data) = receiver.recv() {
                let mut device = device.lock().unwrap();
                // Criação real na thread gráfica
                let texture = device.create_texture(&data.descriptor);
                texture.write_data(&data.bytes);
            }
        });

        Self { sender, handle }
    }
}
```

O erro clássico aparece quando tentamos usar um `Texture` entre threads sem sincronização:

```
error[E0277]: `dyn wgpu::Device` cannot be shared between threads safely
   --> src/renderer.rs:42:23
    |
42  |     thread::spawn(move || {
    |                       ^^ `dyn wgpu::Device` cannot be shared between threads
    |
    = help: the trait `Sync` is not implemented for `dyn wgpu::Device`
```

A correção envolve o padrão de "enfileiramento de comandos". Este exemplo completo mostra como delegar trabalho pesado mantendo a UI responsiva:

```rust
// Thread principal (gráfica)
let (cmd_sender, cmd_receiver) = mpsc::channel::<RenderCommand>();
let render_thread = RenderThread::new(cmd_receiver);

// Thread de background
thread::spawn(move || {
    let heavy_mesh = load_complex_mesh("asset.obj"); // 500ms
    cmd_sender.send(RenderCommand::UploadMesh(heavy_mesh)).unwrap();
});

// Na thread gráfica:
for cmd in cmd_receiver.try_iter() {
    match cmd {
        RenderCommand::UploadMesh(mesh) => upload_to_gpu(mesh),
        // Outros comandos...
    }
}
```

Para operações de E/S assíncronas, combinamos async/await com a thread principal gráfica. Este snippet demonstra carregamento assíncrono sem bloquear:

```rust
async fn load_shader(name: &str) -> Shader {
    let bytes = tokio::fs::read(format!("shaders/{}.spv", name)).await.unwrap();
    Shader::from_bytes(&bytes)
}

// Na thread principal:
let shader = load_shader("standard").await;
```

O pulo do gato está em integrar o runtime async com o loop de eventos gráfico. Com Winit e Tokio:

```rust
let rt = tokio::runtime::Runtime::new().unwrap();
rt.spawn(async {
    let texture = load_texture_async("background.png").await;
    window.queue_texture(texture);
});

event_loop.run(move |event, _, control_flow| {
    rt.block_on(async {
        // Processa eventos async junto com os gráficos
    });
});
```

**Erro comum:** esquecer que callbacks de UI devem ser rápidos. Este código causa microtravamentos:

```rust
button.on_click(|| {
    let _ = heavy_computation(); // 50ms - perceptível!
});
```

A versão correta delega:

```rust
button.on_click(|| {
    thread::spawn(|| {
        let result = heavy_computation();
        window.post_event(ComputationDone(result));
    });
});
```

**Exercício:** Implemente um sistema de carregamento assíncrono de cena que:
1. Carrega 3 texturas em paralelo
2. Atualiza uma barra de progresso na UI durante o carregamento
3. Sinaliza conclusão sem bloquear a thread principal

**Solução comentada:**

```rust
struct Loader {
    progress: Arc<AtomicU32>,
    textures: Vec<String>,
}

impl Loader {
    async fn load_all(window: WindowRef) {
        let progress = Arc::new(AtomicU32::new(0));
        let handles = textures.iter().map(|name| {
            let prog = progress.clone();
            tokio::spawn(async move {
                let tex = load_texture(name).await;
                prog.fetch_add(1, Ordering::Relaxed);
                tex
            })
        }).collect::<Vec<_>>();

        while progress.load(Ordering::Relaxed) < 3 {
            window.update_progress(progress.load(Ordering::Relaxed));
            tokio::task::yield_now().await;
        }

        let textures = join_all(handles).await;
        window.complete_loading(textures);
    }
}
```