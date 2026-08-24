## Roadmap Futuro

Seu editor de texto minimalista está funcional, mas ainda há um abismo entre ele e um produto profissional. Veja os problemas reais que você enfrentará ao escalar o projeto:

**1. Suporte a Plugins (Extensibilidade Segura)**
O editor atual tem funcionalidade fixa. Para adicionar syntax highlighting ou LSP (Language Server Protocol), você precisará de um sistema de plugins que:
- Carrega código Rust dinamicamente com `libloading`
- Define uma interface estável usando traits (`EditorPlugin`)
- Isola falhas com boundaries explícitos (cada plugin em seu próprio thread)
- Gerencia ciclos de vida com RAII (evitar vazamentos ao recarregar)

Erro comum:
```rust
// PANIC: "Library may not be unloaded while types or instances exist"
let lib = unsafe { Library::new("syntax.dylib") }.unwrap();
let plugin: Symbol<fn() -> Box<dyn EditorPlugin>> = unsafe { lib.get(b"create_plugin") }.unwrap();
// Solução: wrapper que garante drop order
```

**2. Renderização Avançada de Texto**
Seu `wgpu_glyph` básico não resolve:
- Ligaduras tipográficas (como "fi" em fontes profissionais)
- Texto bidirecional (árabe/hebraico + latim)
- Quebra de linha complexa (Unicode Line Breaking Algorithm)

Exemplo de falha:
```text
السلام عليكم Hello World ← Renderizado invertido
```

Solução: integrar `rustybuzz` (Harfbuzz em Rust) para shaping e:
```rust
struct ShapedRun {
    glyphs: Vec<GlyphInfo>,
    text: RopeSlice,
    direction: Direction, // LTR/RTL
}
```

**3. Compositor Wayland Completo**
Seu editor roda sobre outro compositor. Para torná-lo autossuficiente:
- Implementar `wl_shell`/`xdg_shell` para gerenciar janelas filhas
- Adicionar `zwp_linux_dmabuf_v1` para hardware decoding de vídeos
- Criar protocolos customizados (ex: `editor_extension_v1`)

Código crítico:
```rust
impl GlobalDispatch<WaylandEditor, ()> for EditorCompositor {
    fn bind(_: &CompositorState, _: &DisplayHandle, _: &Client, _: WaylandEditor, _: ()) {
        // Negocia capacidades extras
    }
}
```

**4. Otimizações Extremas**
Quando seu buffer de texto atingir 1GB:
- Trocar `Rope` por `gap buffer` para edição em arquivos grandes
- Implementar `diff-based rendering` (só atualizar linhas modificadas)
- Usar `compute shaders` para busca/realce de sintaxe

Benchmark atual:
```text
Buscar "fn" em 100MB: 1200ms (CPU) → 12ms (GPU via SSBO)
```

**5. Cross-platform Profissional**
Alvos problemáticos:
- **macOS**: Sandboxing e notarização
- **Windows**: High-DPI e IME (Input Method Editor)
- **Linux**: Snap/Flatpak com sandbox Wayland

Erro típico no macOS:
```rust
// Falha silenciosa sem permissões:
let _ = std::fs::write("/tmp/backup.txt", buffer);
// Correto:
if let Some(dir) = dirs_next::document_dir() {
    let path = dir.join("backup.txt");
}
```

**6. Sistema de Documentação Integrado**
Um editor técnico precisa:
- Renderizar Markdown com LaTeX (`katex-rs`)
- Visualizar diagramas (PlantUML/Mermaid)
- Acesso rápido a docs (Rustdoc integration)

Exemplo de pipeline:
```markdown
```uml
Alice -> Bob: Request
Bob --> Alice: Response
```
→ SVG → WGPU Texture
```

**Exercício Prático: Plugin de Contagem de Palavras**
Implemente um sistema onde:
1. Um plugin (`wordcount.so`) registra um comando `/stats`
2. Ao executar, mostra na status bar:
   - Palavras: 142 | Linhas: 10 | UTF-8: 2.1KB
3. Atualiza em tempo real com delay de 200ms

Solução base:
```rust
// Plugin
pub struct WordCountPlugin;
impl EditorPlugin for WordCountPlugin {
    fn commands(&self) -> HashMap<String, Box<dyn Command>> {
        let mut cmds = HashMap::new();
        cmds.insert("/stats".into(), Box::new(StatsCommand));
        cmds
    }
}

// Editor
let plugin = unsafe { load_plugin("wordcount.so") };
editor.register_plugin(plugin);
```

Cada um desses passos exige dominar conceitos de sistemas operacionais, gráficos avançados e design de aplicações complexas em Rust. O diferencial está nos detalhes: como você lida com falhas de plugins sem travar o editor? Qual a estratégia para minimizar latência no input enquanto o GPU processa syntax highlighting? A resposta está na integração cuidadosa entre segurança de tipos, concorrência e acesso direto ao hardware.