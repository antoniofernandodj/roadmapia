## Desafios em Aplicações Desktop

Aplicações desktop modernas exigem o gerenciamento simultâneo de múltiplos recursos: memória para dados de interface, buffers para renderização gráfica, estruturas para estado da aplicação e cache para operações frequentes. O desafio central é equilibrar responsividade (16ms por frame para 60 FPS) com consumo eficiente de recursos.

Considere um editor de texto simples que precisa:

1. Manter o texto aberto em memória (String/Vec<String>)
2. Rastrear modificações (Vec<Action> para undo/redo)
3. Manter um índice para busca (HashMap<String, Position>)
4. Cache de renderização (Vec<Glyph>)

```rust
struct TextEditor {
    content: String,               // 4MB para 1 milhão de caracteres
    undo_stack: Vec<EditAction>,  // ~200 bytes por ação
    search_index: HashMap<String, Vec<usize>>, // O(n) de memória
    render_cache: Vec<u8>,        // Buffer gráfico - 8MB para FullHD 32bpp
}
```

O primeiro problema aparece no gerenciamento de memória dinâmica:

```rust
impl TextEditor {
    fn open_file(&mut self, path: &Path) -> Result<(), io::Error> {
        let content = std::fs::read_to_string(path)?; // Alocação 1
        let lines = content.lines().map(|s| s.to_string()).collect(); // Alocação N
        self.content = content; // Possível realocação
        self.update_search_index(); // Alocação para HashMap
        Ok(())
    }
}
```

**Problemas concretos:**

1. **Alocações múltiplas**: Cada `to_string()` cria nova alocação para linhas individuais
2. **Fragmentação**: Strings de tamanhos variados dificultam o alocador
3. **Overhead**: HashMap pode consumir 50-100% extra sobre os dados brutos
4. **Pressão no GC**: Sistemas de renderização (como GPU) exigem alocações contíguas

Um teste real com 100MB de texto revela:

```
Memory before: 12MB
After loading: 
  - Content: 100MB 
  - Lines: 215MB (overhead de 115%)
  - Search index: 320MB
Total: 635MB (6.35x o tamanho original)
```

**Padrões problemáticos comuns:**

```rust
// 1. Clone desnecessário em handlers de evento
button.on_click(|| {
    let current_text = editor.content.clone(); // Alocação desnecessária
    process_text(current_text);
});

// 2. Alocação temporária em renderização
fn draw(&self) {
    let formatted = format!("{}: {}", self.title, self.content); // Aloca
    renderer.draw(&formatted); // Descarta
}

// 3. Coleções redundantes
let filtered: Vec<_> = items.iter()
    .filter(|x| x.is_valid())
    .collect(); // Alocação 1
let sorted: Vec<_> = filtered.iter()
    .sorted()
    .collect(); // Alocação 2
```

**Sinais de problemas de memória:**

1. **Stutter na UI**: Picos de 30-50ms em operações simples (alocação/coleta)
2. **Memory Leak gradual**: Aplicação cresce 5-10MB/hora sem liberação
3. **GC Thrashing**: 10-15% de CPU em `jemalloc`/`malloc` em repouso

**Casos extremos em aplicações reais:**

- Editor de código: 2GB RAM para 50 arquivos abertos (VS Code Electron)
- Planilha: 800ms delay ao rolar com 10.000 células (LibreOffice)
- Navegador: 500MB extra após 2 horas (Chromium tab memory leak)

```rust
// Exemplo de vazamento em ciclo de referência
struct Node {
    children: Vec<Rc<RefCell<Node>>>, // Rc impede liberação
    parent: Option<Rc<RefCell<Node>>>
}
```

**Exercício Prático:**

Monitore uma aplicação desktop existente (como um editor Rust simples) com `heaptrack`. Identifique:

1. Quantas alocações ocorrem ao digitar 100 caracteres?
2. Qual o tamanho médio de cada alocação?
3. Existe padrão de alocação temporária em handlers de eventos?

**Solução de Análise:**

Instale `heaptrack` e execute:

```bash
heaptrack target/debug/my_editor
```

Na saída, busque por:

1. **Allocation hotspots**: Funções com mais chamadas a `alloc()`
2. **Temporary allocations**: Blocos com vida útil <1 frame (16ms)
3. **Fragmentation**: Múltiplas alocações de mesmo tamanho padrão

Exemplo de diagnóstico:

```
[100x] editor::key_handler - 8,192 allocations @ 128 bytes (1MB total)
[45x] render::text_layout - 2,560 allocations <1ms lifespan
```

Isso revela:
- Alocação desnecessária por pressionamento de tecla
- Layout sendo recalculado e descartado a cada frame