## Memory Pools para Desktop

Aplicações desktop frequentemente criam e destroem objetos do mesmo tipo repetidamente - widgets, elementos de UI, estruturas de dados temporários. Cada alocação e liberação individual custa ciclos de CPU e fragmenta a memória. O padrão *memory pool* resolve isso pré-alocando um bloco contíguo de memória e reutilizando espaços vazios.

Considere um editor de texto que recria objetos `Glyph` para cada renderização de caractere:

```rust
struct Glyph {
    character: char,
    position: (f32, f32),
    scale: f32,
    // +20 campos adicionais de formatação
}

fn render_frame(text: &str) -> Vec<Glyph> {
    text.chars()
        .enumerate()
        .map(|(i, c)| Glyph {
            character: c,
            position: (i as f32 * 10.0, 0.0),
            scale: 1.0,
            // Inicialização custosa...
        })
        .collect()
}
```

Este código aloca um novo `Vec<Glyph>` a cada frame, e cada `Glyph` é alocado individualmente. Em um benchmark com 10.000 caracteres:

```text
test bench_render ... bench: 1,234,567 ns/iter (+/- 45,678)
```

### Implementando um Pool Básico

Criamos um `GlyphPool` que pré-aloca memória e oferece métodos `allocate()`/`deallocate()`:

```rust
use std::mem;

struct GlyphPool {
    buffer: Vec<Option<Glyph>>,
    free_list: Vec<usize>,
}

impl GlyphPool {
    fn with_capacity(capacity: usize) -> Self {
        GlyphPool {
            buffer: Vec::with_capacity(capacity),
            free_list: (0..capacity).collect(),
        }
    }

    fn allocate(&mut self, glyph: Glyph) -> usize {
        if let Some(idx) = self.free_list.pop() {
            self.buffer[idx] = Some(glyph);
            idx
        } else {
            self.buffer.push(Some(glyph));
            self.buffer.len() - 1
        }
    }

    fn deallocate(&mut self, idx: usize) {
        self.buffer[idx] = None;
        self.free_list.push(idx);
    }

    fn get(&self, idx: usize) -> Option<&Glyph> {
        self.buffer.get(idx).and_then(|g| g.as_ref())
    }
}
```

Uso típico:

```rust
let mut pool = GlyphPool::with_capacity(10_000);

// Alocação inicial
let glyph1 = pool.allocate(Glyph {
    character: 'A',
    position: (0.0, 0.0),
    scale: 1.0,
});

// Reutilização
pool.deallocate(glyph1);
let glyph2 = pool.allocate(Glyph {
    character: 'B',
    position: (10.0, 0.0),
    scale: 1.5,
});

assert_eq!(pool.get(glyph2).unwrap().character, 'B');
```

### Otimizando a Renderização

Adaptando o renderizador para usar o pool:

```rust
fn render_frame_pooled(text: &str, pool: &mut GlyphPool) -> Vec<usize> {
    text.chars()
        .enumerate()
        .map(|(i, c)| {
            pool.allocate(Glyph {
                character: c,
                position: (i as f32 * 10.0, 0.0),
                scale: 1.0,
            })
        })
        .collect()
}
```

Benchmark resultante:

```text
test bench_render_pooled ... bench: 456,789 ns/iter (+/- 12,345)  // 2.7x mais rápido
```

### Erro Comum: Lifetime Incorreto

Um erro frequente é tentar manter referências diretas aos glyphs:

```rust,compile_fail
let glyph_ref = pool.get(glyph1).unwrap();
pool.deallocate(glyph1);
println!("{}", glyph_ref.character); // Use-after-free!
```

O compilador Rust previne isso:

```text
error[E0502]: cannot borrow `pool` as mutable because it is also borrowed as immutable
```

### Pool Thread-Safe com `Arc<Mutex>`

Para uso em múltiplas threads:

```rust
use std::sync::{Arc, Mutex};

let shared_pool = Arc::new(Mutex::new(GlyphPool::with_capacity(1_000)));

let pool_clone = shared_pool.clone();
thread::spawn(move || {
    let mut pool = pool_clone.lock().unwrap();
    let id = pool.allocate(Glyph { ... });
    // ...
});
```

### Exercício Prático

Implemente um `TextLinePool` que:
1. Pré-aloca linhas de texto completas
2. Reutiliza linhas quando o texto é identico
3. Mantém um cache de últimas linhas usadas

Solução base:

```rust
struct TextLinePool {
    lines: Vec<String>,
    free_indices: Vec<usize>,
    lru_cache: VecDeque<usize>,
    max_cache_size: usize,
}

impl TextLinePool {
    fn get_or_insert(&mut self, text: &str) -> usize {
        // 1. Verifica no cache LRU
        if let Some(pos) = self.lru_cache.iter().position(|&i| self.lines[i] == text) {
            let idx = self.lru_cache.remove(pos).unwrap();
            self.lru_cache.push_front(idx);
            return idx;
        }
        
        // 2. Reutiliza slot livre ou aloca novo
        let idx = self.free_indices.pop().unwrap_or(self.lines.len());
        if idx >= self.lines.len() {
            self.lines.push(text.to_string());
        } else {
            self.lines[idx] = text.to_string();
        }
        
        // 3. Atualiza cache
        self.lru_cache.push_front(idx);
        if self.lru_cache.len() > self.max_cache_size {
            let removed = self.lru_cache.pop_back().unwrap();
            self.free_indices.push(removed);
        }
        
        idx
    }
}
```