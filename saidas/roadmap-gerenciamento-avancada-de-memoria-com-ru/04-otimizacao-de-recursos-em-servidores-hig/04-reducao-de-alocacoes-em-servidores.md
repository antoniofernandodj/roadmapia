## Redução de Alocações em Servidores

Um servidor HTTP recebe 10.000 requisições por segundo. Cada requisição aloca um buffer para ler os dados, processa o conteúdo, gera uma resposta e libera a memória. Se cada operação alocar 2KB dinamicamente, são 20MB alocados e liberados *por segundo*, sobrecarregando o alocador e fragmentando a memória. Como reduzir esse custo?

### O problema das alocações transitórias

Considere este manipulador de requisições ingênuo:

```rust
async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let body_bytes = hyper::body::to_bytes(req.into_body()).await?;
    let body_str = String::from_utf8(body_bytes.to_vec())?; // Alocação 1: Vec<u8>
                                                           // Alocação 2: String
    
    let response = process_body(&body_str); // Alocação 3: nova String
    
    Ok(Response::new(response.into()))
}
```

Cada requisição causa:
1. Alocação do buffer `body_bytes` (cópia dos dados da rede)
2. Conversão para `String` (nova alocação + validação UTF-8)
3. Alocação da resposta

Em benchmarks com `wrk -t12 -c400 -d30s`, isso consome 45% do tempo de CPU apenas no gerenciamento de memória.

### Técnica 1: Buffer reutilizável

Substitua alocações por um buffer pré-alocado guardado no estado do servidor:

```rust
struct AppState {
    buffer: Mutex<Vec<u8>>, // Buffer compartilhado entre requisições
}

async fn handle_request(state: Arc<AppState>, req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let mut buffer = state.buffer.lock().await;
    buffer.clear(); // Reutiliza a capacidade existente
    
    // Copia diretamente para o buffer existente
    while let Some(chunk) = req.into_body().data().await {
        buffer.extend_from_slice(&chunk?);
    }
    
    // Processa sem alocar nova String
    let response = process_body(unsafe { std::str::from_utf8_unchecked(&buffer) });
    
    Ok(Response::new(response.into()))
}
```

Diferenças críticas:
- `extend_from_slice` cresce o buffer apenas quando necessário (capacidade dobrada)
- `unsafe` evita verificação UTF-8 redundante (seguro se você controlar a entrada)
- Zero alocações por requisição após warm-up

### Técnica 2: Arena allocation para respostas curtas

Para respostas pequenas (<4KB), use um allocator baseado em arena:

```rust
use bumpalo::Bump;

#[derive(Default)]
struct ResponseArena(Bump);

impl ResponseArena {
    fn allocate_response<'a>(&'a self, content: &str) -> &'a str {
        self.0.alloc_str(content)
    }
}

async fn handle_request(arena: &ResponseArena, req: Request<Body>) -> Result<Response<Body>, Infallible> {
    // Processamento normal...
    let response = arena.allocate_response("resposta rápida");
    Ok(Response::new(response.into()))
}
```

A arena:
- Aloca blocos grandes de memória de uma vez (ex: 16KB)
- Libera tudo quando o `ResponseArena` é descartado
- Elimina desalocações individuais

### Técnica 3: Zero-copy parsing com serde

Ao processar JSON, evite alocar para campos string:

```rust
#[derive(Deserialize)]
struct RequestData<'a> {
    #[serde(borrow)]
    user: &'a str,  // Referência direta ao buffer de entrada
    action: &'a str,
}

async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let body_bytes = /* ... */;
    let request_data: RequestData = serde_json::from_slice(&body_bytes)?;
    // `user` e `action` são slices do body_bytes, sem alocação
}
```

### Erro comum: esquecer de reutilizar conexões TCP

```rust
// ERRADO: Nova conexão por requisição
let client = reqwest::Client::new();
let response = client.get("http://backend/").send().await?;

// CERTO: Cliente compartilhado
// (Adicione ao estado do servidor)
struct AppState {
    http_client: reqwest::Client,
}
```

Cada nova conexão TCP aloca:
- Buffers de leitura/escrita (8KB+ cada)
- Estruturas de TLS (≈16KB)
- Estado da máquina de estados HTTP

### Exercício: Otimizar um manipulador JSON

Dado:
```rust
async fn handle_json(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let full_body = hyper::body::to_bytes(req.into_body()).await?;
    let parsed: Value = serde_json::from_slice(&full_body)?;
    
    let user = parsed["user"].as_str().unwrap();
    let response = format!("Hello, {}!", user);
    
    Ok(Response::new(response.into()))
}
```

Modifique para:
1. Evitar alocar `full_body`
2. Usar referências diretas ao JSON parseado
3. Reutilizar buffers entre chamadas

#### Solução

```rust
struct JsonHandler {
    buffer: Vec<u8>,
}

impl JsonHandler {
    async fn handle(&mut self, req: Request<Body>) -> Result<Response<Body>, Infallible> {
        self.buffer.clear();
        let mut body = req.into_body();
        while let Some(chunk) = body.data().await {
            self.buffer.extend_from_slice(&chunk?);
        }
        
        let parsed: Value = serde_json::from_slice(&self.buffer)?;
        let user = parsed["user"].as_str().unwrap();
        
        // Resposta minimalista sem alocação adicional
        Ok(Response::new(Body::from(format!("Hello, {}!", user))))
    }
}
```

Melhorias:
- Buffer persistente evita realocações
- `Body::from` evita cópia extra da string
- Parsing direto do buffer compartilhado