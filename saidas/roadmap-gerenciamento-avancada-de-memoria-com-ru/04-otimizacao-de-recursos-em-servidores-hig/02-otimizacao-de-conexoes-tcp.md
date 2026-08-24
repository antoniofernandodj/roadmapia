## Otimização de Conexões TCP

Um servidor TCP high-throughput recebe milhares de conexões por segundo, cada uma exigindo alocação de memória para buffers e estruturas de controle. Quando mal gerenciado, esse fluxo causa:

1. Alocações excessivas (via `Box` ou `Vec::new`)
2. Fragmentação de memória
3. Pressão no garbage collector (em linguagens com GC)
4. Overhead de inicialização por conexão

Em Rust, você pode reduzir esses problemas drasticamente reutilizando recursos entre conexões. Veja o problema típico:

```rust
use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};

fn handle_client(mut stream: TcpStream) -> std::io::Result<()> {
    let mut buf = vec![0; 1024]; // Alocação nova a cada conexão
    stream.read(&mut buf)?;
    stream.write_all(&buf)?;
    Ok(())
}

fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080")?;
    for stream in listener.incoming() {
        std::thread::spawn(|| {
            handle_client(stream?).unwrap();
        });
    }
    Ok(())
}
```

**Problema**: Cada conexão aloca um novo buffer de 1KB. Com 10.000 conexões/segundo, são 10MB alocados por segundo apenas para buffers.

### Técnica 1: Buffer Reutilizável com Thread Local Storage

Substitua a alocação por conexão por um buffer armazenado localmente na thread:

```rust
use std::cell::RefCell;

thread_local! {
    static BUFFER: RefCell<Vec<u8>> = RefCell::new(vec![0; 1024]);
}

fn handle_client(mut stream: TcpStream) -> std::io::Result<()> {
    BUFFER.with(|buf| {
        let mut buf = buf.borrow_mut();
        let n = stream.read(&mut buf)?;
        stream.write_all(&buf[..n])?;
        Ok(())
    })
}
```

**Resultado**: O mesmo buffer é reutilizado para todas as conexões na mesma thread, reduzindo alocações para O(N_threads) em vez de O(N_connections).

### Técnica 2: Pool de Conexões com `mio`

Para sistemas ainda mais exigentes, combine reutilização de buffers com gerenciamento eficiente de sockets usando `mio`:

```rust
use mio::{Events, Interest, Poll, Token};
use mio::net::TcpListener;
use std::io;

const BUFFER_SIZE: usize = 1024;
const SERVER: Token = Token(0);

fn main() -> io::Result<()> {
    let mut poll = Poll::new()?;
    let mut events = Events::with_capacity(128);
    let mut listener = TcpListener::bind("127.0.0.1:8080".parse().unwrap())?;
    
    poll.registry().register(&mut listener, SERVER, Interest::READABLE)?;
    
    let mut connections = Vec::new();
    let mut buffers = Vec::new();
    
    loop {
        poll.poll(&mut events, None)?;
        
        for event in events.iter() {
            if event.token() == SERVER {
                let (mut stream, _) = listener.accept()?;
                let token = Token(connections.len() + 1);
                
                poll.registry().register(&mut stream, token, Interest::READABLE)?;
                
                connections.push(stream);
                buffers.push(vec![0; BUFFER_SIZE]);
            } else {
                let idx = event.token().0 - 1;
                let n = connections[idx].read(&mut buffers[idx])?;
                connections[idx].write_all(&buffers[idx][..n])?;
            }
        }
    }
}
```

**Vantagens**:
1. Um único poll para todas as conexões
2. Buffers pré-alocados (um por conexão ativa, não por conexão total)
3. Controle fino sobre quando ocorrem operações de I/O

### Erro Comum: Esquecer de Limpar Buffers

Ao reutilizar buffers, dados residuais podem causar vazamento de informações:

```rust
// ERRADO: envia dados da conexão anterior junto com os novos
stream.write_all(&buf)?;

// CORRETO: limita ao realmente lido
let n = stream.read(&mut buf)?;
stream.write_all(&buf[..n])?;
```

### Exercício Prático

Modifique o exemplo com `mio` para:
1. Limitar o pool a 100 conexões ativas
2. Reutilizar buffers de conexões desconectadas
3. Adicionar timeout de 30s para conexões inativas

**Solução**:

```rust
use std::time::{Duration, Instant};

struct Connection {
    stream: mio::net::TcpStream,
    last_active: Instant,
    buffer: Vec<u8>,
}

fn main() -> io::Result<()> {
    // ... inicialização igual ...
    
    let mut connections = Vec::with_capacity(100);
    let mut free_buffers = Vec::new();
    
    loop {
        poll.poll(&mut events, Some(Duration::from_secs(1)))?;
        
        // Limpa conexões inativas
        connections.retain(|conn| {
            if conn.last_active.elapsed() > Duration::from_secs(30) {
                free_buffers.push(conn.buffer.clone());
                false
            } else {
                true
            }
        });
        
        for event in events.iter() {
            if event.token() == SERVER {
                if connections.len() >= 100 { continue; }
                
                let mut stream = listener.accept()?.0;
                let buffer = free_buffers.pop().unwrap_or(vec![0; BUFFER_SIZE]);
                
                let token = Token(connections.len() + 1);
                poll.registry().register(&mut stream, token, Interest::READABLE)?;
                
                connections.push(Connection {
                    stream,
                    last_active: Instant::now(),
                    buffer,
                });
            } else {
                let idx = event.token().0 - 1;
                let conn = &mut connections[idx];
                
                match conn.stream.read(&mut conn.buffer) {
                    Ok(n) if n > 0 => {
                        conn.stream.write_all(&conn.buffer[..n])?;
                        conn.last_active = Instant::now();
                    },
                    _ => { // Conexão fechada
                        free_buffers.push(conn.buffer.clone());
                        connections.remove(idx);
                    }
                }
            }
        }
    }
}
```

**Otimizações aplicadas**:
1. Pool limitado evita esgotamento de memória
2. Buffers de conexões encerradas são reaproveitados
3. Conexões inativas são automaticamente limpas