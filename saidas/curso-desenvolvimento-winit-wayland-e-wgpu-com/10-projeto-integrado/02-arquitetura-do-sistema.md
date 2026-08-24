## Arquitetura do Sistema

Um editor de texto com renderização customizada em WGPU e integração nativa ao Wayland exige uma arquitetura que equilibre três desafios principais: 

1. **Gerenciamento de estado complexo** (texto, seleção, estilos)
2. **Pipeline gráfico eficiente** (renderização de texto em GPU)
3. **Integração low-level** (protocolo Wayland para input e composição)

Vamos decompor o sistema em componentes principais, mostrando como cada decisão afeta os outros módulos:

### Core: Estado da Aplicação

O coração do editor é uma estrutura que armazena o buffer de texto com metadata de formatação. Rust exige um design cuidadoso aqui para evitar cópias desnecessárias:

```rust
pub struct EditorState {
    // Buffer de texto com alocação eficiente
    text: ropey::Rope,
    // Estilos por intervalo (start, end, style)
    styles: Vec<TextSpan>,
    // Posição do cursor (linha, coluna)
    cursor: (usize, usize),
    // Dimensões da viewport (em pixels lógicos)
    viewport: (f32, f32),
}
```

O uso de `ropey::Rope` (em vez de `String`) é crucial para operações eficientes em textos grandes. Um erro comum seria usar `Vec<String>` para linhas:

```rust
// Ruim: alocações múltiplas e custo de inserção
let lines: Vec<String> = text.split('\n').map(String::from).collect();
```

A mensagem de erro ao tentar implementar seleção de texto sem considerar UTF-8 é típica:

```
thread 'main' panicked at 'byte index 2 is not a char boundary'
```

### Camada Gráfica: WGPU Integration

A renderização exige três estruturas interconectadas:

```rust
struct RenderSystem {
    // Dispositivo e fila da GPU
    device: Arc<wgpu::Device>,
    queue: Arc<wgpu::Queue>,
    // Pipeline para renderização de texto
    text_pipeline: TextPipeline,
    // Vertex buffers para quadrados (backgrounds, seleção)
    quad_buffers: QuadBuffers,
}

struct TextPipeline {
    pipeline: wgpu::RenderPipeline,
    glyph_atlas: TextureAtlas,
    uniform_buffer: wgpu::Buffer,
}
```

Um erro crítico ocorre ao tentar compartilhar `device` e `queue` entre threads sem `Arc`:

```
error[E0277]: `Rc<wgpu::Device>` cannot be sent between threads safely
```

### Integração Wayland

A comunicação com o compositor Wayland usa callbacks assíncronos. O design precisa lidar com:

```rust
struct WaylandHandler {
    // Conexão com o servidor Wayland
    connection: wayland_client::Connection,
    // Surface para renderização
    surface: wayland_client::Proxy<wl_surface::WlSurface>,
    // Eventos de input
    keyboard_events: mpsc::Receiver<KeyEvent>,
}
```

### Fluxo Principal

O loop de eventos coordena todas as partes:

```rust
fn run_editor() {
    let mut editor = EditorState::new();
    let renderer = RenderSystem::new();
    let wayland = WaylandHandler::new();

    event_loop.run(move |event, _, control_flow| {
        match event {
            Event::RedrawRequested(_) => {
                let frame = renderer.prepare_frame();
                editor.draw(&mut frame);
                frame.present();
            }
            Event::WaylandInput(event) => {
                editor.handle_input(event);
                window.request_redraw();
            }
        }
    });
}
```

### Exercício: Detectar Problema de Arquitetura

Dado este fragmento problemático:

```rust
struct Editor {
    state: EditorState,
    renderer: RenderSystem,
}

impl Editor {
    fn handle_input(&mut self, event: InputEvent) {
        self.state.apply_event(event);
        self.renderer.update_buffer(&self.state.text); // ERRO
    }
}
```

**Problema**: O borrow checker não permite mutabilidade compartilhada quando `state` já está emprestado.

**Solução**: Usar interior mutability ou separar as atualizações:

```rust
fn handle_input(&mut self, event: InputEvent) {
    let changes = self.state.apply_event(event);
    self.renderer.apply_changes(changes); // Recebe apenas os deltas
}
```