## Desafios em Servidores High-Throughput

Um servidor high-throughput precisa lidar com milhares ou milhões de requisições por segundo, onde cada microssegundo de latência e cada byte de memória alocado impactam diretamente no desempenho. Considere este cenário básico de um servidor HTTP em Rust:

```rust
use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};
use std::thread;

fn handle_client(mut stream: TcpStream) {
    let mut buffer = [0; 1024];
    stream.read(&mut buffer).unwrap();
    let response = b"HTTP/1.1 200 OK\r\n\r\nHello, World!";
    stream.write(response).unwrap();
}

fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080")?;
    for stream in listener.incoming() {
        thread::spawn(|| handle_client(stream?));
    }
    Ok(())
}
```

Ao executar este servidor e submetê-lo a um teste de carga com `wrk -t12 -c400 -d30s http://127.0.0.1:8080`, você verá rapidamente os primeiros problemas:

1. **Alocação de Threads**: Cada conexão cria uma nova thread, consumindo ~1MB de stack por thread. Com 10.000 conexões, são ~10GB apenas para stacks.

2. **Buffer por Conexão**: O array `[0; 1024]` é alocado para cada requisição, mesmo quando a mensagem tem apenas alguns bytes.

3. **Cópias Desnecessárias**: Os dados são copiados múltiplas vezes - do kernel para o buffer de usuário, depois para a resposta.

Um servidor real enfrenta desafios mais complexos:

### Gerenciamento de Conexões Efêmeras
Em um servidor HTTP, 90% das conexões podem durar menos de 10ms. Criar e destruir estruturas complexas para cada uma delas gera overhead significativo:

```rust
struct ConnectionState {
    headers: HashMap<String, String>,
    body: Vec<u8>,
    // ...20 campos adicionais
}

fn handle_client(stream: TcpStream) {
    let mut state = ConnectionState::new(); // Alocação cara
    // ...processamento...
} // Desalocação imediata
```

### Pressão no Alocador
Alocadores de memória globais (como o `jemalloc` ou `system`) sofrem com:
- Contenção em alocações concorrentes
- Fragmentação de memória
- Padrões imprevisíveis de alocação/liberação

```rust
// Padrão típico em servidores:
for _ in 0..1_000_000 {
    let buffer = Vec::with_capacity(512); // Alocação
    process(&buffer);
} // Liberação imediata
```

### Contenção no Acesso a Dados Compartilhados
Estruturas globais como caches, contadores e pools de conexão tornam-se gargalos:

```rust
lazy_static! {
    static ref CACHE: Mutex<HashMap<String, String>> = Mutex::new(HashMap::new());
}

fn get_from_cache(key: &str) -> Option<String> {
    CACHE.lock().unwrap().get(key).cloned() // Travamento global
}
```

### Problemas Específicos de Rust
1. **Ownership em Sistemas Assíncronos**: Dados compartilhados entre tasks exigem `Arc<Mutex<T>>`, adicionando overhead:
   ```rust
   let shared_data = Arc::new(Mutex::new(Vec::new()));
   tokio::spawn(async {
       shared_data.lock().await.push(1); // Overhead de locking
   });
   ```

2. **Trait Objects em Código Quente**: Dynamic dispatch em loops críticos:
   ```rust
   trait Handler {
       fn handle(&self, req: &Request) -> Response;
   }

   fn process(handlers: &[Box<dyn Handler>]) {
       for handler in handlers {
           handler.handle(&req); // Indirect call + vtable lookup
       }
   }
   ```

3. **Zero-Cost Abstractions que Não São Zero-Cost**: Abstrações seguras que geram código subótimo:
   ```rust
   let results: Vec<_> = incoming_requests
       .iter()
       .map(|r| r.parse::<f64>())
       .collect::<Result<Vec<_>, _>>()?; // Alocações intermediárias
   ```

### Exercício: Identificando Gargalos
Analise este trecho de um servidor WebSocket real:

```rust
fn broadcast_message(clients: &mut Vec<Client>, message: &str) {
    let serialized = serde_json::to_string(&message).unwrap();
    for client in clients {
        if let Err(e) = client.ws.send(Message::Text(serialized.clone())) {
            clients.retain(|c| c.id != client.id);
        }
    }
}
```

**Problemas presentes**:
1. Clone da mensagem serializada para cada cliente
2. Operação de serialização ocorrendo no loop crítico
3. Modificação da lista de clientes durante iteração
4. Alocação de string para cada mensagem

**Solução proposta** (apenas estrutura, detalhes nos próximos capítulos):
```rust
fn broadcast_message(clients: &mut ClientPool, message: &Arc<str>) {
    let serialized = CachedSerializer::new(message); // Pré-serializado
    clients.retain_mut(|client| {
        client.send(serialized.get()).is_ok() // Reutiliza buffer
    });
}
```

Estes desafios serão abordados nas técnicas específicas dos próximos capítulos, começando pela otimização de conexões TCP e gerenciamento inteligente de buffers.