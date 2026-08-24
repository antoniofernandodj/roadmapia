## Memory Pools para Servidores

Servidores high-throughput frequentemente lidam com alocação e liberação constante de objetos semelhantes. Cada operação `new` ou `drop` tem custo, e o padrão tradicional de alocação individual no heap pode se tornar um gargalo. Veja o problema em ação:

```rust
struct Request {
    id: u64,
    headers: Vec<(String, String)>,
    body: Vec<u8>,
}

impl Request {
    fn new(id: u64) -> Self {
        Request {
            id,
            headers: Vec::new(),
            body: Vec::new(),
        }
    }
}

fn handle_request(request: Request) {
    // Processamento fictício
    println!("Processando request {}", request.id);
}

fn main() {
    for i in 0..10_000 {
        let request = Request::new(i);
        handle_request(request);
    }
}
```

Neste exemplo trivial, cada `Request` aloca seus próprios `Vec`s vazios. No mundo real, um servidor pode processar milhões de requisições por minuto, tornando essas alocações proibitivas.

A solução está nos **memory pools**: reservatórios de objetos pré-alocados que são reutilizados. Em Rust, podemos implementá-los com `Vec` e gerenciamento manual:

```rust
use std::cell::RefCell;

struct RequestPool {
    pool: RefCell<Vec<Request>>,
}

impl RequestPool {
    fn new() -> Self {
        RequestPool {
            pool: RefCell::new(Vec::with_capacity(100)),
        }
    }

    fn get(&self, id: u64) -> Request {
        let mut pool = self.pool.borrow_mut();
        if let Some(mut req) = pool.pop() {
            req.id = id;
            req.headers.clear();
            req.body.clear();
            req
        } else {
            Request::new(id)
        }
    }

    fn recycle(&self, request: Request) {
        let mut pool = self.pool.borrow_mut();
        if pool.len() < 100 {
            pool.push(request);
        }
    }
}
```

O padrão de uso mostra a melhoria:

```rust
fn main() {
    let pool = RequestPool::new();

    for i in 0..10_000 {
        let request = pool.get(i);
        handle_request(request);
        // Em um caso real, reciclaríamos após processamento completo
        // pool.recycle(request);
    }
}
```

**Por que funciona**: 
1. `Vec::with_capacity(100)` pré-aloca espaço para 100 `Request`s
2. `get()` reutiliza objetos existentes quando possível
3. `recycle()` devolve objetos ao pool sem desalocá-los

Um erro comum é esquecer de limpar os dados reutilizados, levando a vazamento de informação entre requisições:

```rust
// ERRADO: esquecer de limpar headers
req.id = id;
// req.headers.clear(); // ESQUECIDO
req.body.clear();
```

Isso causaria headers de requisições anteriores aparecendo em novas requisições - um bug de segurança grave.

**Otimizando ainda mais**: Para objetos muito utilizados como buffers, podemos usar `bytes::BytesMut` que implementa referência counting e slicing sem cópias:

```rust
use bytes::BytesMut;

struct BufferPool {
    pools: RefCell<Vec<BytesMut>>,
}

impl BufferPool {
    fn get(&self, size: usize) -> BytesMut {
        let mut pools = self.pools.borrow_mut();
        if let Some(buf) = pools.pop() {
            if buf.capacity() >= size {
                buf
            } else {
                BytesMut::with_capacity(size)
            }
        } else {
            BytesMut::with_capacity(size)
        }
    }
}
```

**Exercício**: Implemente um `ConnectionPool` para reutilizar estruturas que encapsulam conexões TCP. Dica: use `Option<T>` para marcar conexões como disponíveis/inativas.

```rust
struct Connection {
    stream: Option<TcpStream>, // None quando no pool
    // outros campos...
}

struct ConnectionPool {
    connections: RefCell<Vec<Connection>>,
}

impl ConnectionPool {
    fn get(&self) -> Option<Connection> {
        // Implemente
    }

    fn put(&self, conn: Connection) {
        // Implemente
    }
}
```

**Solução**:

```rust
use std::net::TcpStream;
use std::cell::RefCell;

struct Connection {
    stream: Option<TcpStream>,
    // outros campos...
}

struct ConnectionPool {
    connections: RefCell<Vec<Connection>>,
}

impl ConnectionPool {
    fn get(&self) -> Option<Connection> {
        let mut conns = self.connections.borrow_mut();
        if let Some(mut conn) = conns.pop() {
            if let Some(stream) = conn.stream.take() {
                // Verifica se a conexão ainda é válida
                if stream.peer_addr().is_ok() {
                    conn.stream = Some(stream);
                    Some(conn)
                } else {
                    None
                }
            } else {
                None
            }
        } else {
            None
        }
    }

    fn put(&self, mut conn: Connection) {
        if let Some(stream) = conn.stream.take() {
            let mut conns = self.connections.borrow_mut();
            conns.push(Connection {
                stream: Some(stream),
                // resetar outros campos
            });
        }
    }
}
```

Key points:
1. `take()` move o stream para fora temporariamente para verificação
2. `peer_addr()` testa se a conexão ainda está ativa
3. O pool mantém as conexões vivas mas marcadas como "não em uso"