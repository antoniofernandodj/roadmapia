## Comparação com Toolkits Existentes

Criar uma UI do zero com WGPU parece um esforço desproporcional quando toolkits como GTK, Qt ou incluso Iced oferecem componentes prontos. Mas há cenários onde a abordagem customizada não é apenas viável — é a única opção técnica sensata. Considere um editor de vídeo profissional:

```rust
// Exemplo: Timeline em toolkit tradicional vs. custom
use gtk::prelude::*;

let timeline = gtk::Box::new(gtk::Orientation::Horizontal, 0);
timeline.set_size_request(800, 60);

// Problema: Como adicionar 500 faixas de vídeo com preview em tempo real?
for _ in 0..500 {
    let track = gtk::Box::new(gtk::Orientation::Vertical, 0);
    timeline.add(&track); // Crash: consumo excessivo de memória
}
```

A saída real seria um travamento ou consumo de GBs de RAM. Agora a versão WGPU:

```rust
struct VideoTrack {
    texture: wgpu::Texture,
    vertices: [Vertex; 4] // 4 vértices para um quad
}

let mut tracks = Vec::with_capacity(500);
for i in 0..500 {
    tracks.push(VideoTrack {
        texture: create_blank_texture(&device),
        vertices: calculate_vertices(i) // Posição baseada no índice
    });
}

// Renderização batch: 1 draw call para todas as faixas
render_pass.set_pipeline(&pipeline);
render_pass.set_bind_group(0, &bind_group, &[]);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw(0..4, 0..500); // 500 instâncias de quads
```

**Por que custom vence aqui?**
1. **Controle de memória**: GTK aloca widgets completos, WGPU gerencia apenas vértices/texturas
2. **Renderização unificada**: 1 draw call vs. 500 operações de layout/pintura
3. **Integração GPU**: Preview direto dos frames sem cópias CPU-GPU

### Quando não usar custom UI

Para um formulário de configuração simples, o custo de desenvolvimento é proibitivo:

```rust
// Formulário em toolkit (Iced)
Column::new()
    .push(TextInput::new("Nome"))
    .push(Checkbox::new("Ativar", true))
    .push(Button::new("Salvar"))

// Equivalente custom (simplificado)
struct Form {
    name_input: TextField,
    checkbox: Checkbox,
    button: Button
}

impl Widget for Form {
    fn draw(&self, canvas: &mut Canvas) {
        self.name_input.draw(canvas); // +100 linhas de shaders/texturas
        self.checkbox.draw(canvas);   // + gerenciamento de estado
        self.button.draw(canvas);     // + hit testing
    }
}
```

A diferença de complexidade é evidente. Toolkits resolvem problemas comuns:
- Acessibilidade integrada
- Themeing consistente
- Navegação por teclado
- Suporte a IME

### Casos intermediários

Alguns componentes podem ser híbridos. Um visualizador de gráficos 3D embutido:

```rust
// Uso com GTK
let gl_area = gtk::GLArea::new();
gl_area.connect_render(|_, ctx| {
    // Custom rendering com OpenGL
    unsafe { gl::Clear(gl::COLOR_BUFFER_BIT); }
    Inhibit(false)
});

// Problema: Como usar Vulkan/WGPU aqui?
// Solução: Surface integration
let surface = unsafe {
    gtk::Window::create_surface(&window)
};
let adapter = wgpu::Adapter::new(&surface).unwrap(); // Compatibilidade limitada
```

### Critérios de decisão

1. **Complexidade visual**:
   - UIs estáticas (formulários) → Toolkits
   - Renderização dinâmica (jogos, vídeo) → WGPU

2. **Performance**:
   - 60 FPS com milhares de elementos → WGPU
   - Aplicações convencionais → Toolkits

3. **Plataforma**:
   - Necessidade de native look-and-feel → Toolkits
   - Experiência visual única (players, dashboards) → Custom

4. **Recursos de equipe**:
   - Time pequeno → Toolkits maduros
   - Equipe especializada em gráficos → WGPU

### Erro comum: Subestimar complexidade

Muitos tentam migrar gradualmente e caem no pior dos mundos:

```rust
// Anti-padrão: Mixinando toolkit + WGPU sem integração
fn draw_ui() {
    // GTK para controles
    gtk::Window::show_all();

    // WGPU para conteúdo
    renderer.draw(); // Z-fighting garantido!
}
```

A saída real seria:
```
ERROR: Surface already locked by another API (GTK vs WGPU)
```

Solução correta requer integração profunda:

```rust
// Padrão válido: Embedding controlado
let surface = wgpu::Surface::from_gtk(&window);
gtk::Box::pack_start(&container, &surface.widget(), true, true, 0);

// Renderização coordenada
gtk::GLArea::set_required_version(3, 3); // Exemplo OpenGL
```