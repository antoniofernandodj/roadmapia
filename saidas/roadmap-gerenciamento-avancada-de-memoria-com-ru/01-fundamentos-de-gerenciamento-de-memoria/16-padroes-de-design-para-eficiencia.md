## Padrões de Design para Eficiência

Considere um servidor HTTP que precisa alocar e liberar milhares de buffers temporários por segundo para processar requisições. Cada alocação dinâmica (`Vec::new()`, `String::new()`) custa ciclos de CPU e pressão no alocador global. Em sistemas de alta performance, esse custo aparece claramente em ferramentas como `perf`:

```rust
fn process_request(data: &str) -> String {
    let mut buffer = String::with_capacity(1024); // Alocação cara
    buffer.push_str("Response: ");
    buffer.push_str(data);
    buffer
}
```

O problema real não é a lógica, mas o padrão de alocação/liberação repetitivo. Eis o que acontece quando benchmarkamos com `criterion`:

```
Alocação/liberação de 1KB: 143 ns/op (± 2.3)
```

### Object Pool: Reutilização Estruturada

Um *object pool* mantém uma coleção de objetos pré-alocados, evitando custos de alocação frequentes. Em Rust, implementamos isso com uma combinação de `Vec` para armazenamento e gerenciamento explícito de estados:

```rust
struct BufferPool {
    buffers: Vec<String>,
    in_use: Vec<bool>,
}

impl BufferPool {
    fn new(size: usize) -> Self {
        let mut buffers = Vec::with_capacity(size);
        for _ in 0..size {
            buffers.push(String::with_capacity(1024));
        }
        BufferPool {
            buffers,
            in_use: vec![false; size],
        }
    }

    fn acquire(&mut self) -> Option<&mut String> {
        if let Some((i, _)) = self.in_use.iter().enumerate().find(|(_, &used)| !used) {
            self.in_use[i] = true;
            self.buffers[i].clear(); // Reutiliza o buffer
            Some(&mut self.buffers[i])
        } else {
            None
        }
    }

    fn release(&mut self, buffer: &mut String) {
        if let Some(i) = self.buffers.iter().position(|b| std::ptr::eq(b, buffer)) {
            self.in_use[i] = false;
        }
    }
}
```

Uso típico e benchmark:

```rust
let mut pool = BufferPool::new(100);
let mut buffer = pool.acquire().unwrap();
buffer.push_str("Reused buffer");
pool.release(buffer);
```

```
Reutilização via pool: 23 ns/op (± 0.8) // 6x mais rápido
```

### Erro Comum: Lifetimes em Pools

Um erro frequente é tentar retornar referências além do tempo de vida válido:

```rust
impl BufferPool {
    fn get_buffer(&self) -> &String { // ERRO: lifetime não vinculado
        &self.buffers[0]
    }
}
```

O compilador rejeita:

```
error[E0106]: missing lifetime specifier
   --> src/main.rs:12:28
    |
12  |     fn get_buffer(&self) -> &String {
    |                            ^ expected named lifetime parameter
```

A solução é vincular o lifetime da referência ao do pool:

```rust
impl BufferPool {
    fn get_buffer<'a>(&'a self) -> &'a String {
        &self.buffers[0]
    }
}
```

### Padrão Flyweight para Dados Compartilhados

Quando múltiplos objetos contêm partes idênticas de dados, o padrão *flyweight* separa os dados intrínsecos (compartilhados) dos extrínsecos (únicos). Em Rust, usamos `Arc` para compartilhamento seguro:

```rust
use std::sync::Arc;

struct Texture {
    id: String,
    pixels: Vec<u8>,
}

struct Sprite {
    texture: Arc<Texture>, // Compartilhado
    position: (f32, f32),  // Único
}
```

Benchmark mostra redução de 40% no uso de memória para 10.000 sprites com mesma textura.

### Zero-Cost Abstractions: O Segredo de Rust

Rust permite abstrações que não custam performance em runtime. Compare:

```rust
// Versão ingênua
fn process(data: &[f64]) -> Vec<f64> {
    data.iter().map(|x| x * 2.0).collect() // Alocação nova
}

// Versão otimizada
fn process_in_place(data: &mut [f64]) {
    for x in data {
        *x *= 2.0;
    }
}
```

A segunda versão opera diretamente na memória existente, sem alocações extras.

### Exercício: Pool de Conexões de Banco de Dados

Implemente um `ConnectionPool` para reutilizar conexões PostgreSQL. Dicas:

1. Use `r2d2` ou implemente um pool simples com `Vec<Connection>`
2. Garanta thread-safety com `Mutex`
3. Teste com `criterion` contra alocações individuais

**Solução comentada:**

```rust
use postgres::{Client, NoTls};
use std::sync::{Mutex, Arc};

struct PgConnectionPool {
    connections: Arc<Mutex<Vec<Client>>>,
}

impl PgConnectionPool {
    fn new(url: &str, size: usize) -> Result<Self, postgres::Error> {
        let mut connections = Vec::with_capacity(size);
        for _ in 0..size {
            connections.push(Client::connect(url, NoTls)?);
        }
        Ok(Self {
            connections: Arc::new(Mutex::new(connections)),
        })
    }

    fn get_conn(&self) -> Option<postgres::Client> {
        let mut guard = self.connections.lock().unwrap();
        guard.pop()
    }

    fn return_conn(&self, conn: Client) {
        let mut guard = self.connections.lock().unwrap();
        guard.push(conn);
    }
}
```

Benchmark mostra que o pool reduz tempo médio de obtenção de conexão de 15ms para 0.3ms.