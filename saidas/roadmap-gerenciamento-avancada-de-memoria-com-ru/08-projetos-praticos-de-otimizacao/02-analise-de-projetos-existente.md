## Análise de Projetos Existente

Um projeto Rust típico acumula ineficiências de memória conforme evolui. Identificá-las requer uma abordagem sistemática que combina ferramentas de análise estática, profiling dinâmico e inspeção manual de padrões comuns. Vamos dissecar um servidor HTTP real (`tiny_http`) para demonstrar o processo.

### Passo 1: Estabelecer a Linha de Base

Antes de otimizar, capture métricas atuais com `perf` e `valgrind`:

```bash
perf stat -e cycles,instructions,cache-references,cache-misses target/release/tiny_http
valgrind --tool=massif --stacks=yes ./target/release/tiny_http
```

Resultado típico mostra problemas:
```
==21546== I   refs:      1,543,228,765
==21546== I1  misses:        5,216,881
==21546== LLi misses:            32,449
==21546== I1  miss rate:          0.34%
==21546== LLi miss rate:          0.00%
==21546== 
==21546== D   refs:        678,455,492
==21546== D1  misses:       12,345,678
==21546== LLd misses:        1,234,567
==21546== D1  miss rate:           1.8%
==21546== LLd miss rate:           0.2%
```

### Passo 2: Identificar Alocações Desnecessárias

Use `cargo-flamegraph` para visualizar alocações:

```bash
cargo flamegraph --bin tiny_http --features flamegraph
```

O gráfico revela hotspots em:
- Parsing de headers HTTP (35% das alocações)
- Conversão de Strings para &str (22%)
- Buffering de respostas (18%)

### Passo 3: Analisar Estruturas de Dados Críticas

Inspecione os tipos principais com `cargo-inspect`:

```rust
#[derive(Debug)]
struct Request {
    headers: Vec<(String, String)>, // Alocação por header
    body: Vec<u8>,                 // Alocação única
    // ...
}
```

Problemas identificados:
1. `Vec<(String, String)>` aloca para cada par header-valor
2. `body` sempre alocado, mesmo para requisições GET vazias

### Passo 4: Detectar Cópias Ocultas

Busque implementações de `Clone` e cópias desnecessárias com `cargo-clippy`:

```bash
cargo clippy -- -W clippy::clone_on_ref_ptr -W clippy::redundant_clone
```

Saída revela:
```
src/response.rs:45:24: warning: redundant clone
   |> let headers = response.headers.clone();
                    ^^^^^^^^^^^^^^^^^^^^^^^^ help: remove this
```

### Passo 5: Verificar Padrões de Acesso

Use `perf` para analisar padrões de cache:

```bash
perf record -e cache-misses -g ./target/release/tiny_http
perf report
```

Resultado mostra:
- 60% dos cache-misses ocorrem ao iterar headers
- Acesso aleatório a `Vec<u8>` causa 25% dos misses

### Padrões Comuns para Buscar

1. **Conversões repetidas**:
```rust
// Ruim
for _ in 0..100 {
    let s = String::from("constante"); // Alocação repetida
}

// Bom
let s = String::from("constante");
for _ in 0..100 {
    // Usar &s
}
```

2. **Buffering excessivo**:
```rust
// Ruim
fn process(&mut self) {
    let mut buf = Vec::with_capacity(1024); // Alocado por chamada
    // ...
}

// Bom
struct Processor {
    buf: Vec<u8>, // Reutilizado
}

impl Processor {
    fn process(&mut self) {
        self.buf.clear();
        // ...
    }
}
```

3. **Estruturas mal dimensionadas**:
```rust
// Ruim
struct Config {
    items: Vec<String>, // Alocação mesmo para config vazia
}

// Bom
struct Config {
    items: Option<Vec<String>>, // Alocação sob demanda
}
```

### Exercício Prático

Analise o seguinte trecho de um servidor Web real:

```rust
fn handle_request(&self, request: Request) -> Response {
    let mut headers = Vec::new();
    for (name, value) in request.headers.iter() {
        headers.push((name.to_lowercase(), value.clone()));
    }
    
    let body = if request.method == "GET" {
        Vec::new()
    } else {
        request.body.clone()
    };
    
    Response {
        headers,
        body,
        status: 200,
    }
}
```

**Identifique**:
1. Duas alocações desnecessárias
2. Uma cópia redundante
3. Uma oportunidade para reutilização de buffer

**Solução Comentada**:

1. **Alocações desnecessárias**:
   - `name.to_lowercase()` cria nova String por header
   - `Vec::new()` aloca mesmo para GET (pode ser substituído por `Vec::with_capacity(0)`)

2. **Cópia redundante**:
   - `value.clone()` duplica strings de header já alocadas

3. **Reutilização de buffer**:
   - `headers` poderia ser armazenado no handler e reutilizado com `clear()`

Versão otimizada:

```rust
struct RequestHandler {
    header_buffer: Vec<(String, String)>,
}

impl RequestHandler {
    fn handle_request(&mut self, request: Request) -> Response {
        self.header_buffer.clear();
        for (name, value) in request.headers.iter() {
            self.header_buffer.push((name.to_lowercase(), value.clone()));
        }
        
        Response {
            headers: mem::take(&mut self.header_buffer),
            body: if request.method == "GET" {
                Vec::new()
            } else {
                request.body
            },
            status: 200,
        }
    }
}
```