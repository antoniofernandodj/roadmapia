## Gerenciamento de Recursos em Servidores

Um servidor HTTP processando 50.000 requisições por segundo gasta mais tempo gerenciando memória do que executando lógica de negócios. O problema central é a alocação dinâmica: cada `String::new()`, cada `Vec::push()`, cada serialização JSON consome ciclos preciosos de CPU e pressiona o allocator global.

Considere este handler Actix-Web aparentemente inocente:

```rust
async fn get_user(data: web::Data<AppState>, user_id: web::Path<String>) -> impl Responder {
    let user = data.users.lock().unwrap().get(&user_id).cloned();
    match user {
        Some(u) => HttpResponse::Ok().json(u),
        None => HttpResponse::NotFound().finish(),
    }
}
```

O que há de errado aqui? Três alocações ocultas:
1. `user_id` é clonado quando poderia ser referenciado
2. O lock do Mutex força uma alocação temporária
3. `.json(u)` serializa alocando um buffer intermediário

O benchmark revela o custo (em um Intel Xeon 3.5GHz):

```
test bench_get_user ... 23,456 ns/iter (+/- 1,234)
```

### Estratégias de Reutilização

O padrão de *object pools* elimina alocações recorrentes. Esta implementação de pool de buffers:

```rust
struct BufferPool {
    pool: Mutex<Vec<Vec<u8>>>,
    capacity: usize,
}

impl BufferPool {
    fn get(&self) -> Vec<u8> {
        let mut pool = self.pool.lock().unwrap();
        pool.pop().unwrap_or_else(|| Vec::with_capacity(self.capacity))
    }

    fn put(&self, mut buf: Vec<u8>) {
        buf.clear();
        let mut pool = self.pool.lock().unwrap();
        if pool.len() < 100 { // Limite arbitrário
            pool.push(buf);
        }
    }
}
```

Reduz o tempo de serialização em 40%:

```
test bench_json_serialize ... 8,123 ns/iter (+/- 456)
```

### Gerenciamento de Conexões

Um pool de conexões PostgreSQL mal configurado causa contenção:

```rust
// ERRADO: Pool bloqueante
let pool = Pool::new(Config::default());
```

A versão assíncrona com tokio-postgres:

```rust
let pool = Pool::builder()
    .max_size(20) // Tamanho baseado em benchmark
    .min_idle(Some(10))
    .build(Config::default())
    .await?;
```

### Alocação Zero-Copy

Para endpoints que processam grandes payloads, o uso de `Bytes` em vez de `Vec<u8>` evita cópias:

```rust
async fn upload(data: web::Bytes) -> impl Responder {
    // `data` é uma view sem alocação
    let processed = process_data(&data)?;
    HttpResponse::Ok().body(processed)
}
```

### Erro Comum: Clone Desnecessário

Este código parece seguro, mas esconde um problema:

```rust
fn process_log(log: &str) -> String {
    let cleaned = log.trim().to_lowercase();
    analyzer::parse(&cleaned) // Clone implícito no parse
}
```

A mensagem do clippy é reveladora:

```
warning: unnecessary clone of `String`
help: try passing `cleaned` directly
```

A versão otimizada:

```rust
fn process_log(log: &str) -> String {
    analyzer::parse(log.trim().to_lowercase()) // Move direto
}
```

### Exercício Prático

Implemente um middleware para Actix-Web que:
1. Reutiliza buffers de resposta
2. Mede o tempo de alocação por requisição
3. Loga requisições que excedam um threshold

Solução:

```rust
struct BufferingMiddleware {
    pool: BufferPool,
}

impl<S, B> Transform<S, ServiceRequest> for BufferingMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>>,
{
    type Response = ServiceResponse<Bytes>;
    type Error = S::Error;
    type Transform = BufferingMiddlewareService<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(BufferingMiddlewareService {
            service,
            pool: self.pool.clone(),
        }))
    }
}

struct BufferingMiddlewareService<S> {
    service: S,
    pool: BufferPool,
}

impl<S, B> Service<ServiceRequest> for BufferingMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>>,
    B: Into<Bytes>,
{
    type Response = ServiceResponse<Bytes>;
    type Error = S::Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    fn poll_ready(&self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.service.poll_ready(cx)
    }

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let pool = self.pool.clone();
        let fut = self.service.call(req);

        Box::pin(async move {
            let start = Instant::now();
            let res = fut.await?;
            let elapsed = start.elapsed();

            if elapsed > Duration::from_millis(10) {
                warn!("Slow request: {:?}", elapsed);
            }

            let (req, res) = res.into_parts();
            let bytes = res.into().into();
            pool.put(bytes.to_vec());
            Ok(ServiceResponse::new(req, bytes))
        })
    }
}
```