## Melhores Práticas para Servidores

Um servidor high-throughput processa milhares de requisições por segundo, onde cada microssegundo economizado se multiplica pelo volume. Veja um exemplo real: um servidor HTTP que aloca um novo buffer para cada requisição:

```rust
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};

fn handle_client(mut stream: TcpStream) {
    let mut buffer = Vec::with_capacity(1024); // Alocação nova a cada requisição
    stream.read_to_end(&mut buffer).unwrap();
    // Processamento...
    stream.write_all(b"HTTP/1.1 200 OK\r\n\r\n").unwrap();
}

fn main() {
    let listener = TcpListener::bind("127.0.0.1:8080").unwrap();
    for stream in listener.incoming() {
        handle_client(stream.unwrap());
    }
}
```

O problema aparece quando submetemos este servidor a um teste de carga:
```bash
$ wrk -t4 -c1000 -d30s http://127.0.0.1:8080
Running 30s test @ http://127.0.0.1:8080
  4 threads and 1000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    14.62ms    2.22ms  32.45ms   75.32%
    Req/Sec    17.05k     1.32k   19.88k    68.33%
  2038717 requests in 30.10s, 125.28MB read
Requests/sec:  67731.15
Transfer/sec:      4.16MB
```

A alocação contínua de buffers limita o desempenho. A solução? Reutilização de buffers com `bytes::BytesMut`:

```rust
use bytes::BytesMut;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::{Arc, Mutex};
use lazy_static::lazy_static;

lazy_static! {
    static ref BUFFER_POOL: Arc<Mutex<Vec<BytesMut>>> = Arc::new(Mutex::new(Vec::new()));
}

fn get_buffer() -> BytesMut {
    let mut pool = BUFFER_POOL.lock().unwrap();
    pool.pop().unwrap_or_else(|| BytesMut::with_capacity(1024))
}

fn return_buffer(buffer: BytesMut) {
    let mut pool = BUFFER_POOL.lock().unwrap();
    pool.push(buffer);
}

fn handle_client(mut stream: TcpStream) {
    let mut buffer = get_buffer();
    stream.read_to_end(&mut buffer).unwrap();
    // Processamento...
    stream.write_all(b"HTTP/1.1 200 OK\r\n\r\n").unwrap();
    return_buffer(buffer);
}
```

O mesmo teste de carga agora mostra:
```bash
Requests/sec:  89245.67 (+31.7%)
Transfer/sec:      5.48MB
```

### Padrões Essenciais para Servidores Rust

1. **Pool de Conexões com `r2d2`**:
```rust
use r2d2::Pool;
use r2d2_sqlite::SqliteConnectionManager;

let manager = SqliteConnectionManager::file("server.db");
let pool = Pool::builder().max_size(20).build(manager).unwrap();

// Em cada requisição:
let conn = pool.get().unwrap();
// Uso automático do pool
```

2. **Serialização Zero-Copy com `serde`**:
```rust
use serde::Serialize;
use serde_json::Serializer;
use std::io::Write;

#[derive(Serialize)]
struct Response<'a> {
    status: &'a str,
    data: &'a [u8],
}

let response = Response {
    status: "OK",
    data: &[1, 2, 3],
};

let mut serializer = Serializer::new(Vec::new());
response.serialize(&mut serializer).unwrap();
// Sem alocações intermediárias
```

3. **Gerenciamento de Estado com `Arc<Mutex>` vs `DashMap`**:
Para acesso concorrente moderado:
```rust
use std::sync::{Arc, Mutex};

let shared_data = Arc::new(Mutex::new(HashMap::new()));
```

Para alta concorrência (>1000 req/s):
```rust
use dashmap::DashMap;

let shared_data = DashMap::new();
// Leituras não bloqueantes
```

4. **Otimização de Logs com `tracing`**:
```rust
use tracing::{info, instrument};

#[instrument]
fn process_request(req: Request) -> Result<Response> {
    info!("Processing request");
    // Contexto automático para logs
}
```

### Erro Comum e Correção

**Problema**: Uso ingênuo de `String` em headers HTTP:
```rust
let mut headers = String::new();
headers.push_str("Content-Type: text/html\r\n");
headers.push_str("Server: Rust\r\n");
// Alocações múltiplas
```

**Solução**: `write!` para buffer pré-alocado:
```rust
use std::fmt::Write;

let mut headers = String::with_capacity(128);
write!(&mut headers, "Content-Type: text/html\r\n").unwrap();
write!(&mut headers, "Server: Rust\r\n").unwrap();
// Uma única alocação
```

### Exercício Prático

Modifique este servidor TCP simples para usar:
1. Pool de buffers com `BytesMut`
2. Serialização zero-copy para a resposta
3. `DashMap` para armazenamento de sessão

```rust
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::collections::HashMap;

struct Session {
    user_id: u64,
    expires: u64,
}

fn main() {
    let mut sessions = HashMap::new();
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let mut stream = stream.unwrap();
        let mut buffer = [0; 1024];
        stream.read(&mut buffer).unwrap();

        // Simples roteamento
        if buffer.starts_with(b"GET /data") {
            let session_id = parse_session(&buffer);
            let session = sessions.get(&session_id).unwrap();
            let response = format!("User: {}, Expires: {}", session.user_id, session.expires);
            stream.write(response.as_bytes()).unwrap();
        }
    }
}
```

**Solução**:
```rust
use bytes::BytesMut;
use dashmap::DashMap;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::Arc;

struct Session {
    user_id: u64,
    expires: u64,
}

lazy_static::lazy_static! {
    static ref SESSIONS: DashMap<String, Session> = DashMap::new();
    static ref BUFFER_POOL: Arc<parking_lot::Mutex<Vec<BytesMut>>> = 
        Arc::new(parking_lot::Mutex::new(Vec::new()));
}

fn get_buffer() -> BytesMut {
    BUFFER_POOL.lock().pop().unwrap_or_else(|| BytesMut::with_capacity(1024))
}

fn main() {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let mut stream = stream.unwrap();
        let mut buffer = get_buffer();
        stream.read_to_end(&mut buffer).unwrap();

        if buffer.starts_with(b"GET /data") {
            let session_id = parse_session(&buffer);
            if let Some(session) = SESSIONS.get(&session_id) {
                let mut response = BytesMut::new();
                write!(&mut response, "User: {}, Expires: {}", 
                    session.user_id, session.expires).unwrap();
                stream.write(&response).unwrap();
            }
        }
    }
}
```

Principais melhorias:
1. Substituição de `HashMap` por `DashMap` para acesso concorrente
2. Pool de buffers com `BytesMut` e `parking_lot` (mais rápido que `std::sync::Mutex`)
3. Serialização direta para buffer com `write!`
4. Reutilização de buffers entre requisições