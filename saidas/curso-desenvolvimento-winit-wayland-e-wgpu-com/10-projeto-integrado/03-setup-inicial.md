## Setup Inicial

Criar um editor de texto performático em Rust exige uma estrutura de projeto cuidadosa desde o início. O erro mais comum é misturar lógica de editor, renderização e manipulação de janelas no mesmo módulo - isso rapidamente vira um emaranhado de dependências circulares e conflitos de mutabilidade. Veja como evitar isso:

```rust
// Cargo.toml
[package]
name = "rust-editor"
version = "0.1.0"
edition = "2021"

[dependencies]
winit = { version = "0.28", features = ["serde"] }
wgpu = "0.15"
wayland-client = { version = "0.30", features = ["dlopen"] }
ropey = "1.6"
anyhow = "1.0"
log = "0.4"
env_logger = "0.10"
```

A estrutura de diretórios deve refletir a separação clara de responsabilidades:

```
src/
├── main.rs      # Ponto de entrada e coordenação geral
├── editor/      # Lógica do editor de texto
│   ├── mod.rs   # Estado do editor e operações
│   └── buffer.rs # Implementação do buffer de texto com Rope
├── render/      # Tudo relacionado a WGPU
│   ├── mod.rs   # Pipeline de renderização principal
│   └── text.rs  # Renderização de texto específica
└── window/      # Gerenciamento de janela e input
    ├── mod.rs   # Configuração e eventos da janela
    └── wayland.rs # Integração específica com Wayland
```

O ponto de entrada (`main.rs`) deve ser minimalista, apenas inicializando os subsistemas:

```rust
use anyhow::Result;
use editor::EditorState;
use render::Renderer;
use window::WindowManager;

fn main() -> Result<()> {
    env_logger::init();
    
    let event_loop = winit::event_loop::EventLoop::new();
    let mut window = WindowManager::new(&event_loop)?;
    let mut renderer = Renderer::new(&window)?;
    let mut editor = EditorState::new();

    event_loop.run(move |event, _, control_flow| {
        window.handle_event(&event, control_flow);
        editor.handle_event(&event);
        renderer.render(&editor, &window);
    });
}
```

Um erro frequente é tentar criar o `Renderer` antes da `WindowManager`. Isso falha porque o WGPU precisa de um surface criada pela janela:

```rust
// ERRADO - causará panic
let renderer = Renderer::new()?;
let window = WindowManager::new(&event_loop)?;

// CERTO
let window = WindowManager::new(&event_loop)?;
let renderer = Renderer::new(&window)?;
```

A mensagem de erro que você verá se fizer errado:

```
thread 'main' panicked at 'Surface must be created first', wgpu-0.15.1/src/backend/direct.rs:214:9
```

Para o `EditorState`, começamos com uma estrutura básica que usa `ropey::Rope` para manipulação eficiente de texto:

```rust
// editor/mod.rs
use ropey::Rope;

pub struct EditorState {
    buffer: Rope,
    cursor_pos: (usize, usize), // (linha, coluna)
    scroll_offset: (f32, f32),
}

impl EditorState {
    pub fn new() -> Self {
        Self {
            buffer: Rope::new(),
            cursor_pos: (0, 0),
            scroll_offset: (0.0, 0.0),
        }
    }

    pub fn insert_char(&mut self, c: char) {
        let idx = self.buffer.line_to_char(self.cursor_pos.0) + self.cursor_pos.1;
        self.buffer.insert_char(idx, c);
        self.cursor_pos.1 += 1;
    }
}
```

A vantagem do `Rope` sobre `String` fica clara em operações em arquivos grandes - inserções e deleções são O(log n) em vez de O(n). Teste com um arquivo de 10MB:

```rust
let mut editor = EditorState::new();
editor.buffer = Rope::from_reader(std::fs::File::open("large_file.txt")?)?;

// Inserção rápida mesmo em posições arbitrárias
editor.insert_char('X'); // Rápido mesmo em buffers grandes
```

Para a renderização inicial, criamos um esqueleto do `Renderer`:

```rust
// render/mod.rs
use wgpu::{Instance, Surface, Adapter, Device, Queue};

pub struct Renderer {
    surface: Surface,
    device: Device,
    queue: Queue,
    // Outros campos para pipelines e buffers...
}

impl Renderer {
    pub fn new(window: &winit::window::Window) -> Result<Self> {
        let instance = Instance::new(wgpu::InstanceDescriptor::default());
        let surface = unsafe { instance.create_surface(&window) }?;
        let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions {
            compatible_surface: Some(&surface),
            ..Default::default()
        })).unwrap();
        
        let (device, queue) = pollster::block_on(adapter.request_device(
            &wgpu::DeviceDescriptor::default(),
            None,
        ))?;

        Ok(Self { surface, device, queue })
    }

    pub fn render(&mut self, editor: &EditorState, window: &winit::window::Window) {
        // Implementação real virá depois
    }
}
```

O erro mais comum aqui é esquecer de lidar com a recreação da swap chain quando a janela é redimensionada. Um esqueleto seguro inclui:

```rust
// render/mod.rs
impl Renderer {
    // ...
    
    fn recreate_swap_chain(&mut self, width: u32, height: u32) -> wgpu::SurfaceConfiguration {
        let config = wgpu::SurfaceConfiguration {
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            format: self.surface.get_capabilities(&self.adapter).formats[0],
            width,
            height,
            present_mode: wgpu::PresentMode::Fifo,
            alpha_mode: wgpu::CompositeAlphaMode::Auto,
        };
        self.surface.configure(&self.device, &config);
        config
    }
}
```

Exercício: Implemente a estrutura inicial do `WindowManager` para:
1. Criar uma janela com título "Rust Editor"
2. Forçar o backend Wayland quando disponível
3. Armazenar o tamanho atual da janela

Solução:

```rust
// window/mod.rs
use winit::window::WindowBuilder;

pub struct WindowManager {
    pub window: winit::window::Window,
    pub size: (u32, u32),
}

impl WindowManager {
    pub fn new(event_loop: &winit::event_loop::EventLoop<()>) -> Result<Self> {
        let window = WindowBuilder::new()
            .with_title("Rust Editor")
            .build(event_loop)?;
        
        // Forçar Wayland se disponível
        if std::env::var_os("WAYLAND_DISPLAY").is_some() {
            std::env::set_var("WINIT_UNIX_BACKEND", "wayland");
        }

        let size = window.inner_size();
        Ok(Self {
            window,
            size: (size.width, size.height),
        })
    }
}
```