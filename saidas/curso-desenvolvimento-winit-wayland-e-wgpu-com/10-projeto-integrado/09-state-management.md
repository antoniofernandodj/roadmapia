## State Management

Um editor de texto precisa gerenciar três estados principais simultaneamente: o conteúdo do texto, a interface gráfica e os recursos da GPU. O desafio é sincronizá-los sem bloquear a thread principal ou causar race conditions. Vejamos como estruturar isso em Rust.

### O Problema Central

Quando você digita em um editor:

1. O input handler captura a tecla pressionada
2. O buffer de texto é atualizado
3. A UI recalcula layouts
4. A GPU renderiza os novos caracteres

Tudo isso deve acontecer em menos de 16ms para 60 FPS. Um estado mal estruturado causa:

```rust
// Exemplo do que NÃO fazer
struct Editor {
    text: String,
    cursor_pos: usize,
    gpu_buffer: wgpu::Buffer, // !!! Problema: GPU resources não são Send
}
```

O erro ocorre porque `wgpu::Buffer` não implementa `Send`, impossibilitando o compartilhamento entre threads. A mensagem de erro seria:

```
error[E0277]: `wgpu::Buffer` cannot be sent between threads safely
   --> src/editor.rs:12:5
    |
12  |     gpu_buffer: wgpu::Buffer,
    |     ^^^^^^^^^^ `wgpu::Buffer` cannot be sent between threads safely
```

### Solução: Separação de Responsabilidades

Dividimos o estado em três partes:

```rust
#[derive(Default)]
struct TextState {
    buffer: ropey::Rope,  // Eficiente para textos grandes
    cursor: (usize, usize), // (linha, coluna)
}

struct UiState {
    layout: UiLayout,
    scroll_offset: f32,
    dpi_factor: f64,
}

struct GpuResources {
    pipeline: wgpu::RenderPipeline,
    vertex_buffers: Vec<wgpu::Buffer>,
    // Todos os campos aqui são Send + Sync
}
```

### Compartilhamento Seguro

Para sincronizar o acesso:

```rust
struct AppState {
    text: Arc<Mutex<TextState>>,       // Mutex para escrita no texto
    ui: Arc<RwLock<UiState>>,         // RwLock para leitura frequente
    gpu: Arc<GpuResources>,           // Já é thread-safe
    event_sender: Sender<EditorEvent>, // Canal para eventos
}
```

Exemplo de atualização concorrente:

```rust
// Thread de input
let text = Arc::clone(&app_state.text);
thread::spawn(move || {
    if let Ok(mut guard) = text.lock() {
        guard.buffer.insert_char(cursor_pos, 'a');
    }
});

// Thread de renderização
let ui = Arc::clone(&app_state.ui);
let gpu = Arc::clone(&app_state.gpu);
thread::spawn(move || {
    if let Ok(guard) = ui.read() {
        render_frame(&gpu, &guard);
    }
});
```

### Atualizações Incrementais

Evite travar o estado por muito tempo:

```rust
fn handle_keypress(state: &AppState, key: Key) {
    // Bloqueia apenas o necessário
    let mut text = state.text.lock().unwrap();
    let mut ui = state.ui.write().unwrap();
    
    // Atualização rápida
    match key {
        Key::Char(c) => text.buffer.insert_char(text.cursor.0, c),
        Key::Enter => text.buffer.insert_line(text.cursor.0 + 1),
        _ => {}
    }
    
    // Libera o lock antes de operações lentas
    drop(text);
    
    // Recalcula layout (pode ser custoso)
    ui.layout = calculate_layout(&state.text.lock().unwrap());
}
```

### Mensuração de Performance

Adicione métricas para identificar gargalos:

```rust
struct FrameMetrics {
    input_time: Duration,
    render_time: Duration,
    layout_time: Duration,
}

impl AppState {
    fn update_and_measure(&self) -> FrameMetrics {
        let start = Instant::now();
        self.process_input();
        let input_time = start.elapsed();
        
        let layout_start = Instant::now();
        self.update_layout();
        let layout_time = layout_start.elapsed();
        
        let render_start = Instant::now();
        self.render();
        let render_time = render_start.elapsed();
        
        FrameMetrics { input_time, render_time, layout_time }
    }
}
```

### Padrão de Inicialização

A ordem de criação é crítica:

```rust
fn init_state(window: &Window) -> Result<AppState> {
    // 1. Cria recursos GPU (mais demorado)
    let gpu = GpuResources::new(window)?;
    
    // 2. Estado inicial
    let text = TextState::default();
    let ui = UiState::new(gpu.dpi_factor);
    
    // 3. Canais para eventos
    let (sender, receiver) = mpsc::channel();
    
    Ok(AppState {
        text: Arc::new(Mutex::new(text)),
        ui: Arc::new(RwLock::new(ui)),
        gpu: Arc::new(gpu),
        event_sender: sender,
    })
}
```

### Exercício Prático

Implemente um contador de palavras que atualize em tempo real:

1. Crie um `WordCounter` separado com seu próprio `Mutex`
2. Conecte ao `TextState` via observer pattern
3. Atualize a UI sem travar o thread principal

Solução:

```rust
struct WordCounter {
    count: usize,
    version: u64, // Para detecção de mudanças
}

impl WordCounter {
    fn update(&mut self, text: &ropey::Rope) {
        let new_count = text.len_chars(); // Simplificado
        if new_count != self.count {
            self.count = new_count;
            self.version += 1;
        }
    }
}

// No AppState:
let counter = Arc::new(Mutex::new(WordCounter::default()));
let counter_clone = Arc::clone(&counter);
let text_clone = Arc::clone(&app_state.text);

thread::spawn(move || {
    let mut last_version = 0;
    loop {
        let text = text_clone.lock().unwrap();
        let mut counter = counter_clone.lock().unwrap();
        counter.update(&text.buffer);
        
        if counter.version != last_version {
            last_version = counter.version;
            println!("Words: {}", counter.count); // Na prática, atualizaria a UI
        }
        
        thread::sleep(Duration::from_millis(100)); // Polling simplificado
    }
});
```