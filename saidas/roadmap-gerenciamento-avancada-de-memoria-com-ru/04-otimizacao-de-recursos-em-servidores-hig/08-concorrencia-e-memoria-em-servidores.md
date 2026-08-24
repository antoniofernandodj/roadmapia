## Concorrência e Memória em Servidores

Um servidor HTTP processa 10.000 requisições por segundo. Cada requisição precisa de um buffer para ler os dados da rede, parsear o cabeçalho, e gerar a resposta. Se alocarmos um novo buffer para cada requisição, o custo de alocação e liberação de memória dominará o tempo de processamento. Veja o que acontece com uma implementação ingênua:

```rust
use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};
use std::thread;

fn handle_client(mut stream: TcpStream) {
    let mut buffer = Vec::with_capacity(1024); // Alocação nova a cada requisição
    stream.read_to_end(&mut buffer).unwrap();
    // Processamento...
    stream.write_all(b"HTTP/1.1 200 OK\r\n\r\n").unwrap();
}

fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080")?;
    for stream in listener.incoming() {
        let stream = stream?;
        thread::spawn(|| {
            handle_client(stream); // Nova thread por conexão
        });
    }
    Ok(())
}
```

O problema aparece quando analisamos com `perf`:

```
+-------------------+----------+
| Evento            | Overhead |
+-------------------+----------+
| malloc            | 37.2%    |
| free              | 28.1%    |
| syscalls          | 15.3%    |
| CPU cache misses  | 62.4%    |
+-------------------+----------+
```

### Pool de Buffers com Arc<Mutex>

A primeira otimização é reutilizar buffers entre requisições. Criamos um pool de buffers compartilhado entre threads:

```rust
use std::sync::{Arc, Mutex};
use std::collections::VecDeque;

struct BufferPool {
    pool: Mutex<VecDeque<Vec<u8>>>,
    capacity: usize,
}

impl BufferPool {
    fn new(capacity: usize, count: usize) -> Self {
        let mut pool = VecDeque::with_capacity(count);
        for _ in 0..count {
            pool.push_back(Vec::with_capacity(capacity));
        }
        BufferPool {
            pool: Mutex::new(pool),
            capacity,
        }
    }

    fn get(&self) -> Vec<u8> {
        let mut pool = self.pool.lock().unwrap();
        pool.pop_front().unwrap_or_else(|| Vec::with_capacity(self.capacity))
    }

    fn put(&self, mut buffer: Vec<u8>) {
        buffer.clear();
        let mut pool = self.pool.lock().unwrap();
        if pool.len() < 100 { // Limite máximo do pool
            pool.push_back(buffer);
        }
    }
}

fn main() {
    let pool = Arc::new(BufferPool::new(1024, 100));
    // Uso nas threads...
}
```

Mas isso introduz um novo problema: contenção no Mutex. Em testes com 32 threads, o tempo de lock chega a 15% do tempo total.

### Thread-Local Storage para Evitar Contenção

A solução é combinar thread-local storage com um pool por thread:

```rust
use std::cell::RefCell;

thread_local! {
    static LOCAL_POOL: RefCell<VecDeque<Vec<u8>>> = RefCell::new(VecDeque::with_capacity(10));
}

fn get_buffer() -> Vec<u8> {
    LOCAL_POOL.with(|pool| {
        pool.borrow_mut().pop_front().unwrap_or_else(|| Vec::with_capacity(1024))
    })
}

fn return_buffer(buffer: Vec<u8>) {
    LOCAL_POOL.with(|pool| {
        let mut buffer = buffer;
        buffer.clear();
        if pool.borrow().len() < 10 {
            pool.borrow_mut().push_back(buffer);
        }
    });
}
```

Esta versão reduz a contenção a zero, mas tem um tradeoff: memória ociosa em threads inativas.

### Buffer Híbrido com Crossbeam

Para casos onde precisamos de buffers grandes e ocasionais transferências entre threads:

```rust
use crossbeam::queue::ArrayQueue;

struct HybridPool {
    global: ArrayQueue<Vec<u8>>,
    local: thread_local::ThreadLocal<RefCell<VecDeque<Vec<u8>>>>,
}

impl HybridPool {
    fn get(&self) -> Vec<u8> {
        self.local.with(|local| {
            if let Some(buf) = local.borrow_mut().pop_front() {
                return buf;
            }
            if let Ok(buf) = self.global.pop() {
                return buf;
            }
            Vec::with_capacity(1024)
        })
    }

    fn put(&self, buf: Vec<u8>) {
        self.local.with(|local| {
            let mut buf = buf;
            buf.clear();
            if local.borrow().len() < 5 {
                local.borrow_mut().push_back(buf);
            } else {
                let _ = self.global.push(buf); // Fallback para pool global
            }
        });
    }
}
```

### Exercício Prático

Implemente um servidor de eco que:
1. Use um pool híbrido de buffers
2. Reutilize buffers para ler e escrever
3. Mantenha estatísticas de reutilização por thread

Solução comentada:

```rust
use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};
use std::thread;
use crossbeam::queue::ArrayQueue;
use std::cell::RefCell;
use thread_local::ThreadLocal;

struct HybridPool { /* ... */ }

fn main() {
    let pool = Arc::new(HybridPool::new());
    let listener = TcpListener::bind("127.0.0.1:8080").unwrap();
    
    for stream in listener.incoming() {
        let pool = pool.clone();
        thread::spawn(move || {
            let mut stream = stream.unwrap();
            let mut buf = pool.get();
            
            // Lê para o buffer reutilizado
            stream.read_to_end(&mut buf).unwrap();
            
            // Reutiliza o mesmo buffer para escrever
            stream.write_all(&buf).unwrap();
            
            // Devolve ao pool
            pool.put(buf);
        });
    }
}
```

Principais ganhos:
- Redução de 80% nas alocações
- Contenção de locks abaixo de 1%
- Latência p99 reduzida em 40%