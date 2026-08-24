## Estudos de Caso: Desktop Apps

Um editor de texto Rust consome 300MB de RAM ao carregar um arquivo de 5MB. O problema não está no conteúdo do arquivo, mas em como a aplicação gerencia buffers, caches e estruturas de dados auxiliares. Vamos dissecar três problemas reais e suas soluções.

### 1. Alocação Agressiva em Buffers de Texto

O editor `TextRust` usava `String::with_capacity(1024)` para cada linha do arquivo, mesmo quando 80% das linhas tinham menos de 100 caracteres. O código original:

```rust
let mut lines = Vec::new();
for line_content in file_contents.lines() {
    let mut line = String::with_capacity(1024); // Alocação fixa
    line.push_str(line_content);
    lines.push(line);
}
```

O problema aparece ao carregar um arquivo com 50.000 linhas:
```
Memory usage: 51.2MB (50k * 1024 bytes)
```

A solução veio com alocação adaptativa, usando estatísticas de tamanho de linha:

```rust
let mut lines = Vec::with_capacity(file_contents.lines().count());
let mut avg_len = running_average_initializer(); // Implementado separadamente

for line_content in file_contents.lines() {
    let ideal_capacity = avg_len.predict(line_content.len());
    let mut line = String::with_capacity(ideal_capacity);
    line.push_str(line_content);
    lines.push(line);
    avg_len.update(line_content.len());
}
```

Resultado:
```
Memory usage: 6.4MB (redução de 87.5%)
```

### 2. Vazamento em Cache de Syntax Highlighting

O editor `CodeLight` mantinha um cache de tokens de syntax highlighting indefinidamente, mesmo após fechar abas. O tipo `SyntaxCache` continha:

```rust
struct SyntaxCache {
    tokens: HashMap<PathBuf, Vec<Token>>, // Path do arquivo → tokens
    #[allow(dead_code)]
    theme: ThemeData,
}
```

Ao abrir/fechar repetidamente arquivos grandes (10MB+), a memória crescia sem retornar ao baseline. O diagnóstico veio com `dhat-rs`:

```rust
fn main() {
    dhat::Dhat::start_heap_profiling(); // Inicia profiling
    let _cache = SyntaxCache::new();
    // ... operações com arquivos
}
```

Saída do profiler:
```
Total allocations: 1.45GB
Peak RSS: 1.53GB
```

A correção implementou LRU (Least Recently Used) cache com tamanho máximo:

```rust
struct SyntaxCache {
    tokens: LruCache<PathBuf, Vec<Token>>, // LRU com capacidade fixa
    theme: ThemeData,
}

impl SyntaxCache {
    pub fn new(max_items: usize) -> Self {
        SyntaxCache {
            tokens: LruCache::new(max_items),
            theme: ThemeData::default(),
        }
    }
}
```

Após a mudança:
```
Peak RSS stabilizes at ~120MB after 100 file operations
```

### 3. Duplicação de Dados em Widgets de UI

O framework `RustUI` (fictício) renderizava widgets com clones completos dos dados:

```rust
struct TextEditor {
    content: String,       // Dados reais
    rendered_content: String, // Cópia para renderização
    cursor_pos: (u32, u32),
    rendered_cursor: (u32, u32),
}
```

Isso causava duplicação em todos os widgets. A solução usou referências com lifetime explícito:

```rust
struct TextEditor<'a> {
    content: &'a str,                // Referência aos dados
    cursor_pos: (u32, u32),
    render_state: RenderState,       // Estado visual apenas
}

struct AppModel {
    document: String,                // Dono dos dados
    editors: Vec<TextEditor<'_>>,    // Visualizações
}
```

Antes:
```
Memory for 3 views: 3x document size + overhead
```

Depois:
```
Memory for N views: 1x document size + N×(view metadata)
```

### Exercício Prático

Um visualizador de imagens em Rust (`ImageViewer`) está consumindo 2GB para exibir uma imagem de 50MB. Analise este trecho do código de decodificação:

```rust
struct ImageViewer {
    original_pixels: Vec<u8>,      // Dados brutos do arquivo
    decoded_image: Vec<u32>,       // Pixels decodificados (RGBA)
    display_texture: Vec<u32>,     // Cópia para a GPU
    thumbnail: Vec<u32>,           // Miniatura 256x256
}
```

**Problema**: Identifique os desperdícios de memória e proponha uma reestruturação.

**Solução**:

1. **Duplicação desnecessária**:
   - `decoded_image` e `display_texture` contêm os mesmos dados
   - `thumbnail` pode ser gerado sob demanda

2. **Melhoria proposta**:
```rust
struct ImageViewer {
    original_data: Vec<u8>,               // Mantém os dados compactos
    decoded_rgba: Option<Arc<[u32]>>,     // Compartilhável entre threads
    gpu_texture: Option<TextureHandle>,   // Referência à GPU (evita cópia)
}

impl ImageViewer {
    fn get_thumbnail(&self) -> Option<Vec<u32>> {
        // Gera miniatura apenas quando necessário
        self.decoded_rgba.as_ref().map(|pixels| {
            generate_thumbnail(pixels, 256, 256)
        })
    }
}
```

3. **Economia**:
   - De 2GB para ~60MB (50MB originais + 10MB overhead)
   - `Arc` permite compartilhamento seguro entre threads
   - `TextureHandle` elimina a cópia CPU→GPU redundante