## Gerenciamento de Recursos em Desktop

Aplicações desktop modernas lidam com desafios únicos de gerenciamento de memória que diferem significativamente de sistemas server-side. Enquanto servidores preocupam-se com throughput e concorrência massiva, aplicações desktop enfrentam problemas como:

1. **Ciclos de vida complexos de objetos**: UI elements podem ser criados, destruídos e recriados dinamicamente em resposta a interações do usuário
2. **Alocações temporárias frequentes**: Operações como redimensionamento de janelas ou renderização de frames exigem alocações efêmeras
3. **Dependência de frameworks gráficos**: Muitas bibliotecas de UI impõem modelos de memória específicos

Considere um editor de texto simples que permite abrir múltiplas abas. Cada aba contém:

```rust
struct TextTab {
    content: String,
    undo_stack: Vec<String>,
    syntax_highlighting: Vec<HighlightSpan>,
    line_metrics: Vec<LineMetrics>,
}
```

Quando o usuário digita, cada modificação gera:
1. Uma nova entrada no undo_stack
2. Recomputação do syntax_highlighting
3. Atualização do line_metrics

Um implementação ingênua causaria alocações excessivas:

```rust
impl TextTab {
    fn handle_keystroke(&mut self, c: char) {
        // Alocação 1: Nova string para undo
        self.undo_stack.push(self.content.clone());
        
        // Alocação 2: Modificação do conteúdo
        self.content.push(c);
        
        // Alocação 3: Recomputar highlights
        self.syntax_highlighting = compute_highlights(&self.content);
        
        // Alocação 4: Recomputar métricas
        self.line_metrics = compute_metrics(&self.content);
    }
}
```

Este código apresenta quatro problemas críticos:

1. **Clone desnecessário**: `self.content.clone()` aloca uma nova string completa para cada tecla pressionada
2. **Realocação frequente**: `String::push` pode causar múltiplas realocações conforme o buffer cresce
3. **Recálculo completo**: Toda a sintaxe e métricas são recomputadas do zero
4. **Falta de reutilização**: Vetores são alocados do zero a cada modificação

A versão otimizada utiliza técnicas específicas para aplicações desktop:

```rust
impl TextTab {
    fn handle_keystroke(&mut self, c: char) {
        // 1. Armazenamento diferencial no undo stack
        self.undo_stack.push(format!("+{}", c));
        
        // 2. Pré-alocação inteligente
        if self.content.capacity() - self.content.len() < 1 {
            self.content.reserve(1024); // Blocos grandes
        }
        self.content.push(c);
        
        // 3. Atualização incremental
        update_highlights(&mut self.syntax_highlighting, c, self.content.len());
        update_metrics(&mut self.line_metrics, c);
    }
}
```

Principais otimizações:

1. **Undo diferencial**: Armazena apenas as mudanças (1-2 bytes por tecla vs. cópia completa)
2. **Pré-alocação estratégica**: Reduz realocações reservando blocos grandes
3. **Atualização incremental**: Evita reprocessamento completo do conteúdo

Um erro comum é subestimar o custo de alocações temporárias em operações de UI. Considere este exemplo de renderização:

```rust
fn render_frame(&self) -> Vec<Vertex> {
    let mut vertices = Vec::new();
    for line in &self.lines {
        vertices.extend(generate_line_vertices(line));
    }
    vertices
}
```

O problema aparece quando medimos o desempenho:

```
Benchmark: render_frame
Time: 2.3ms, Allocations: 147KB per frame (60 FPS = 8.6MB/s)
```

A solução utiliza buffers pré-alocados:

```rust
struct Renderer {
    vertex_buffer: Vec<Vertex>,
    temp_buffer: Vec<Vertex>,
}

impl Renderer {
    fn render_frame(&mut self, lines: &[Line]) -> &[Vertex] {
        self.temp_buffer.clear();
        for line in lines {
            generate_line_vertices_into(line, &mut self.temp_buffer);
            self.vertex_buffer.extend(&self.temp_buffer);
        }
        &self.vertex_buffer
    }
}
```

Resultado:

```
Benchmark: render_frame (optimized)
Time: 0.7ms, Allocations: 0KB per frame
```

Padrões essenciais para aplicações desktop:

1. **Object pooling**: Reutilização de objetos ao invés de alocação/destruição frequente
2. **Arenas temporárias**: Zonas de memória para alocações de curta duração
3. **Differential updates**: Minimizar transferências de dados entre CPU/GPU
4. **Lazy loading**: Carregamento sob demanda de recursos pesados

Exercício: Implemente um sistema de cache para thumbnails de imagens que:
1. Mantém até 100 thumbnails em memória
2. Remove os menos recentemente usados quando o limite é atingido
3. Reutiliza buffers de imagem existentes

Solução comentada:

```rust
struct ThumbnailCache {
    entries: LinkedHashMap<PathBuf, ImageBuffer>,
    buffer_pool: Vec<ImageBuffer>,
    max_size: usize,
}

impl ThumbnailCache {
    fn new(max_size: usize) -> Self {
        Self {
            entries: LinkedHashMap::new(),
            buffer_pool: Vec::with_capacity(max_size),
            max_size,
        }
    }

    fn get(&mut self, path: &Path) -> &ImageBuffer {
        if !self.entries.contains_key(path) {
            let buffer = self.buffer_pool.pop().unwrap_or_else(|| ImageBuffer::new());
            let loaded = load_thumbnail(path, buffer);
            self.entries.insert(path.to_owned(), loaded);
            
            if self.entries.len() > self.max_size {
                if let Some((_, oldest)) = self.entries.pop_front() {
                    self.buffer_pool.push(oldest);
                }
            }
        }
        &self.entries[path]
    }
}
```

Otimizações chave:
1. **Pool de buffers**: Evita alocações repetidas reutilizando buffers
2. **LRU eviction**: Remove apenas os itens menos usados recentemente
3. **Alocação antecipada**: Pré-aloca buffers na criação do cache