## Escopo do Projeto

Nosso projeto integrado será um editor de texto minimalista com renderização customizada, focado em demonstrar a integração Rust-Wayland-WGPU na prática. O produto final deve:

1. **Rodar nativamente no Wayland**  
   Usaremos Winit configurado com `platform::wayland()` para garantir o modo nativo. O sistema deve detectar automaticamente se o ambiente suporta Wayland e fallback para X11 apenas quando necessário:

   ```rust
   use winit::platform::wayland::EventLoopBuilderExtWayland;

   let event_loop = if std::env::var_os("WAYLAND_DISPLAY").is_some() {
       EventLoopBuilder::new().with_wayland().build()
   } else {
       EventLoopBuilder::new().build()
   };
   ```

2. **Renderizar texto com WGPU**  
   Implementaremos um pipeline de renderização de texto usando `glyph_brush` com atlas de texturas dinâmico. Cada frame deve:
   - Calcular layouts de texto com `cosmic-text`
   - Gerar vértices para glifos
   - Atualizar texturas GPU apenas para glifos modificados

   ```rust
   // Exemplo de buffer de vértices para um bloco de texto
   struct TextVertex {
       position: [f32; 2],
       tex_coords: [f32; 2],
       color: [f32; 4],
   }
   ```

3. **Gerenciar estado complexo**  
   O editor manterá:
   - Buffer de texto com undo/redo (usando `ropey`)
   - Múltiplos cursos e seleções
   - Estilos por intervalo de texto
   - Viewports independentes

   ```rust
   struct EditorState {
       text: Rope,
       selections: Vec<Selection>,
       style_spans: StyleSpans,
       viewports: HashMap<WindowId, Viewport>,
   }
   ```

4. **Suportar input básico**  
   Trataremos eventos de:
   - Teclado (composição IME incluída)
   - Mouse (seleção de texto, scroll)
   - Touch (gestos de zoom)
   - Clipboard Wayland

   A implementação deve usar `wayland-client` diretamente para operações como:

   ```rust
   let clipboard = conn.get_registry().bind::<WlClipboard>(...);
   clipboard.on_data(move |mime_type, fd| {
       // Ler dados do file descriptor Wayland
   });
   ```

5. **Otimizar para 60fps**  
   O pipeline de renderização deve:
   - Usar instancing para glifos
   - Minimizar transferências CPU-GPU
   - Implementar damage tracking parcial
   - Suportar Vsync via protocolo Wayland

   ```rust
   // Na apresentação do frame:
   surface.frame().submit(Some(Duration::from_millis(16)));
   ```

**Restrições técnicas**:
- Sem dependências de toolkit GUI (GTK/Qt)
- Renderização 100% via WGPU
- Suporte apenas a Wayland/X11 (sem Windows/macOS)
- Alvo: drivers Mesa Intel/AMD modernos

**Cenário de erro comum**: Tentar misturar renderização WGPU com widgets nativos resultará em:

```
Error: Surface does not support cross-API composition
Solução: Desativar composição nativa no Winit (with_x11_surface(false))
```

**Exercício**: Projete a struct `EditorWindow` que encapsula:
1. Conexão Wayland
2. Superfície WGPU
3. Estado do editor
4. Cache de fontes

**Solução comentada**:
```rust
struct EditorWindow {
    // 1. Conexão Wayland
    wayland_conn: wayland_client::Connection,
    wl_surface: WlSurface,

    // 2. Superfície WGPU
    surface: wgpu::Surface,
    device: wgpu::Device,
    queue: wgpu::Queue,

    // 3. Estado
    editor: EditorState,
    
    // 4. Cache
    font_system: cosmic_text::FontSystem,
    glyph_cache: HashMap<FontKey, GlyphCache>,
    
    // Controle
    damage: Option<Rectangle>,
    last_frame: Instant,
}
```