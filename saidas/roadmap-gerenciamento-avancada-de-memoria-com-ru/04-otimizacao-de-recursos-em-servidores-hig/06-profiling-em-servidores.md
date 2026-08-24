## Profiling em Servidores

Um servidor HTTP em Rust pode parecer eficiente até receber carga real. Considere este handler simples que responde a requisições:

```rust
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::Filter;

#[derive(Clone)]
struct AppState {
    counter: Arc<Mutex<u32>>,
}

async fn increment_counter(state: AppState) -> String {
    let mut counter = state.counter.lock().await;
    *counter += 1;
    format!("Contagem: {}", *counter)
}

#[tokio::main]
async fn main() {
    let state = AppState {
        counter: Arc::new(Mutex::new(0)),
    };
    
    let route = warp::path!("count")
        .map(move || state.clone())
        .and_then(increment_counter);

    warp::serve(route).run(([127, 0, 0, 1], 3030)).await;
}
```

Ao testar com `wrk -t12 -c400 -d30s http://127.0.0.1:3030/count`, você pode obter apenas 8.000 requisições por segundo. Onde está o gargalo?

### Instalando e Usando o `pprof`

O `pprof` da Google integrado com `tokio-console` é essencial para diagnóstico:

1. Adicione ao `Cargo.toml`:
```toml
[dependencies]
tokio = { version = "1.0", features = ["full", "rt-multi-thread"] }
tokio-console = { version = "0.1", features = ["pprof"] }
```

2. Modifique o código para habilitar profiling:
```rust
#[tokio::main]
async fn main() {
    console_subscriber::init();
    let state = AppState { /* ... */ };
    // ... restante do código
}
```

Execute com:
```bash
RUSTFLAGS="-C force-frame-pointers=yes" cargo run --release
```

Em outro terminal:
```bash
go tool pprof -http=:8080 http://localhost:6666/debug/pprof/profile?seconds=30
```

### Analisando a Contenção de Lock

O relatório do `pprof` mostrará algo como:

```
Total samples: 4500
- 3800 samples (84.4%) em `Mutex::lock`
- 300 samples (6.7%) em `Arc::clone`
- 400 samples (8.9%) restantes
```

O problema é claro: o mutex global está serializando todas as requisições. A solução é substituir por um contador atômico:

```rust
use std::sync::atomic::{AtomicU32, Ordering};

#[derive(Clone)]
struct AppState {
    counter: Arc<AtomicU32>,
}

async fn increment_counter(state: AppState) -> String {
    let count = state.counter.fetch_add(1, Ordering::Relaxed);
    format!("Contagem: {}", count + 1)
}
```

Após a mudança, o `wrk` reportará ~45.000 req/s, um ganho de 5.6x. O novo perfil mostrará a CPU distribuída uniformemente.

### Memory Profiling com `dhat-rs`

Para vazamentos de memória em handlers assíncronos, adicione:

```toml
[dependencies]
dhat = "0.3"
```

Instrumente o código suspeito:
```rust
use dhat::{Dhat, DhatAlloc};

#[global_allocator]
static ALLOCATOR: DhatAlloc = DhatAlloc;

#[tokio::main]
async fn main() {
    let _dhat = Dhat::start_heap_profiling();
    // ... código do servidor
}
```

Execute e force um pico de carga. O relatório `dhat-heap.json` mostrará alocações por localização no código:

```json
{
  "current_bytes": 1048576,
  "current_blocks": 42,
  "has_rust_roots": true,
  "allocations": [
    {
      "size": 1024,
      "count": 10,
      "backtrace": [
        "warp::filters::log::internal::Imp::call",
        "my_server::increment_counter"
      ]
    }
  ]
}
```

### Otimizando Alocações de Strings

Um padrão comum que aparece em profiles é a alocação repetida de strings. Considere este handler:

```rust
async fn get_user(id: u32) -> Result<String, warp::Rejection> {
    let user = find_user(id).await?; // Operação I/O bound
    Ok(format!("Usuário: {} ({})", user.name, user.id))
}
```

O `format!` aloca uma nova string a cada chamada. Para endpoints high-traffic, use `Bytes` ou cache de templates:

```rust
use bytes::Bytes;
use lazy_static::lazy_static;

lazy_static! {
    static ref TEMPLATE: Bytes = Bytes::from_static(b"Usuário: {} (%)\n");
}

async fn get_user_optimized(id: u32) -> Result<Bytes, warp::Rejection> {
    let user = find_user(id).await?;
    let mut buf = Vec::with_capacity(128);
    write!(&mut buf, TEMPLATE, user.name, user.id).unwrap();
    Ok(Bytes::from(buf))
}
```

### Exercício Prático

Um servidor de arquivos estáticos apresenta este perfil de CPU:
```
60% em `std::fs::File::open`
25% em `hyper::server::accept`
15% em `tokio::sync::watch`
```

1. Qual é o principal gargalo?
2. Escreva uma versão que utilize um cache LRU em memória para os 100 arquivos mais acessados
3. Meça o ganho com `wrk` antes/depois

**Solução:**

```rust
use lru::LruCache;
use std::{sync::Arc, num::NonZeroUsize};
use tokio::sync::Mutex;

struct FileCache {
    cache: Arc<Mutex<LruCache<String, Bytes>>>,
}

impl FileCache {
    fn new(cap: usize) -> Self {
        Self {
            cache: Arc::new(Mutex::new(LruCache::new(
                NonZeroUsize::new(cap).unwrap()
            ))),
        }
    }

    async fn get(&self, path: &str) -> io::Result<Bytes> {
        {
            let mut cache = self.cache.lock().await;
            if let Some(data) = cache.get(path) {
                return Ok(data.clone());
            }
        }
        
        let data = tokio::fs::read(path).await?;
        let bytes = Bytes::from(data);
        
        let mut cache = self.cache.lock().await;
        cache.put(path.to_string(), bytes.clone());
        
        Ok(bytes)
    }
}
```

A métrica de `File::open` deve cair para <5% após a implementação, com ganho proporcional ao cache hit ratio.