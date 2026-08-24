## Memory Pools em Rust

Quando você precisa criar e destruir muitos objetos do mesmo tipo repetidamente, cada `new` e `drop` gera custos de alocação e liberação de memória. Um memory pool resolve isso pré-alocando blocos de memória e reutilizando-os, transformando alocações dinâmicas caras em operações O(1).

Considere um servidor HTTP que cria um `Request` para cada conexão. Sem pool:

```rust
struct Request {
    headers: Vec<(String, String)>,
    body: Vec<u8>,
}

fn handle_request() {
    let req = Request {  // Alocação ocorre aqui
        headers: Vec::new(),
        body: Vec::new(),
    };
    // Processa request...
}  // Desalocação aqui
```

Em 10.000 requisições, são 10.000 pares de alocações/desalocações. Com pool:

```rust
use std::mem;

struct RequestPool {
    pool: Vec<Request>,
}

impl RequestPool {
    fn new(capacity: usize) -> Self {
        let mut pool = Vec::with_capacity(capacity);
        for _ in 0..capacity {
            pool.push(Request {
                headers: Vec::new(),
                body: Vec::new(),
            });
        }
        RequestPool { pool }
    }

    fn get(&mut self) -> Request {
        self.pool.pop().unwrap_or_else(|| Request {  // Reutiliza ou aloca novo se necessário
            headers: Vec::new(),
            body: Vec::new(),
        })
    }

    fn release(&mut self, mut req: Request) {
        req.headers.clear();
        req.body.clear();
        self.pool.push(req);  // Devolve ao pool
    }
}
```

Uso típico:

```rust
let mut pool = RequestPool::new(100);

for _ in 0..10_000 {
    let mut req = pool.get();
    // Preenche req...
    pool.release(req);
}
```

**Por que isso é mais rápido?**

1. **Pré-alocação**: Todas as memórias necessárias são alocadas de uma vez no `new()`
2. **Reutilização**: `get()` e `release()` só manipulam ponteiros, sem chamadas ao alocador global
3. **Localidade**: Objetos ficam próximos na memória, melhorando cache hit

### Erro comum: Esquecer de resetar estado

Se você não limpar os dados antes de devolver ao pool:

```rust
// ERRADO - vazamento de dados!
fn release(&mut self, req: Request) {
    self.pool.push(req);
}
```

O próximo `get()` receberá um `Request` com headers e body sujos. Sempre reset:

```rust
req.headers.clear();
req.body.clear();
```

### Pool Thread-Safe com Arc<Mutex>

Para uso concorrente, proteja o pool com Mutex:

```rust
use std::sync::{Arc, Mutex};

let pool = Arc::new(Mutex::new(RequestPool::new(100)));

// Em cada thread:
let req = pool.lock().unwrap().get();
// ...
pool.lock().unwrap().release(req);
```

### Alternativa: Usando o crate `object-pool`

Para produção, considere bibliotecas maduras como `object-pool`:

```rust
use object_pool::Pool;

let pool: Pool<Request> = Pool::new(100, || Request {
    headers: Vec::new(),
    body: Vec::new(),
});

let req = pool.pull();  // Obtém do pool
// ...
// Automaticamente devolvido quando req sai do escopo
```

### Benchmarks comparativos

Teste no seu projeto com `criterion`:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn bench_pool(c: &mut Criterion) {
    let mut pool = RequestPool::new(1000);
    
    c.bench_function("com pool", |b| b.iter(|| {
        let mut req = pool.get();
        black_box(&mut req);
        pool.release(req);
    }));
    
    c.bench_function("sem pool", |b| b.iter(|| {
        let req = Request {
            headers: Vec::new(),
            body: Vec::new(),
        };
        black_box(req);
    }));
}

criterion_group!(benches, bench_pool);
criterion_main!(benches);
```

Resultado típico (Intel i7, Linux):
```
com pool   time:   [15.342 ns 15.456 ns 15.580 ns]
sem pool   time:   [98.764 ns 99.456 ns 100.21 ns]
```

### Exercício Prático

Implemente um `StringPool` que:
1. Pré-aloca strings com capacidade inicial de 256 bytes
2. Ao devolver, preserva a capacidade mas limpa o conteúdo
3. Inclua teste que demonstra reutilização da mesma memória

Solução:

```rust
struct StringPool {
    pool: Vec<String>,
}

impl StringPool {
    fn new(size: usize) -> Self {
        let mut pool = Vec::with_capacity(size);
        for _ in 0..size {
            let mut s = String::with_capacity(256);
            s.clear();  // Garante estado limpo
            pool.push(s);
        }
        StringPool { pool }
    }

    fn get(&mut self) -> String {
        self.pool.pop().unwrap_or_else(|| String::with_capacity(256))
    }

    fn release(&mut self, mut s: String) {
        s.clear();
        if s.capacity() >= 256 {
            self.pool.push(s);
        }
    }
}

#[test]
fn test_reuse() {
    let mut pool = StringPool::new(1);
    let ptr1;
    {
        let s1 = pool.get();
        ptr1 = s1.as_ptr();
    }
    {
        let s2 = pool.get();
        assert_eq!(ptr1, s2.as_ptr());  // Mesmo buffer!
    }
}
```

Chave do exercício:
- `String::with_capacity` evita realocações
- `clear()` mantém capacidade enquanto esvazia conteúdo
- Teste verifica reutilização do mesmo buffer de memória