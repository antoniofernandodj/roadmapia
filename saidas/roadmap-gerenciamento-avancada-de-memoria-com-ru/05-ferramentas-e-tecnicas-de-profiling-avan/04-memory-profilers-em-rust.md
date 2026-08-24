## Memory Profilers em Rust

Um servidor web em Rust pode ter desempenho exemplar nos testes iniciais, mas quando submetido a carga real, o consumo de memória dispara sem motivo aparente. O código não mostra vazamentos óbvios, mas algo está consumindo recursos. É aqui que memory profilers entram em ação - ferramentas especializadas em expor o comportamento real da memória durante a execução.

### O Problema da Alocação Oculta

Considere este manipulador de API aparentemente inocente:

```rust
async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let body_bytes = hyper::body::to_bytes(req.into_body()).await?;
    let json: serde_json::Value = serde_json::from_slice(&body_bytes)?;
    
    // Processamento complexo...
    let response = build_response(json);
    
    Ok(response)
}
```

Sob carga moderada (1.000 req/s), este código consome 2GB de RAM. Onde está o problema? Um memory profiler revelaria que `to_bytes()` aloca um novo buffer para cada requisição, enquanto `from_slice` cria alocações intermediárias durante o parsing do JSON.

### Valgrind para Rust

Valgrind, a ferramenta clássica de profiling, pode ser usada com Rust através do `valgrind --tool=massif`:

```bash
valgrind --tool=massif --massif-out-file=massif.out ./target/release/my_server
ms_print massif.out > analysis.txt
```

A saída mostra picos de alocação:

```
  n        time(i)         total(B)   useful-heap(B) extra-heap(B)    stacks(B)
--------------------------------------------------------------------------------
 10 1,234,567,890         1,048,576        1,032,576       16,000            0
 11 1,345,678,901         2,097,152        2,073,152       24,000            0
```

O problema aparece na linha de tempo: alocações que crescem linearmente com o número de requisições.

### Heaptrack: Profiling Específico para Rust

Heaptrack oferece integração direta com Rust via `heaptrack`:

```bash
heaptrack ./target/release/my_server
heaptrack --analyze heaptrack.my_server.12345.gz
```

Seu relatório gráfico mostra:
- Backtraces completos de todas as alocações
- Vazamentos por localização exata no código
- Tendências temporais de uso de heap

Para nosso exemplo, ele apontaria diretamente para as linhas com `to_bytes()` e `from_slice`.

### Integração com Cargo

Adicione ao Cargo.toml:

```toml
[dev-dependencies]
dhat = "0.3"
```

Instrumente o código:

```rust
use dhat::{Dhat, DhatAlloc};

#[global_allocator]
static ALLOCATOR: DhatAlloc = DhatAlloc;

fn main() {
    let _dhat = Dhat::start_heap_profiling();
    // Seu código aqui
}
```

Execute com:
```bash
cargo run --release
```

O relatório mostra alocações por tipo e localização:

```
Total:    1,234,567 bytes in 12,345 blocks
Max live: 456,789 bytes

Allocations by type:
serde_json::de::Deserializer: 789,123 bytes (63.9%)
hyper::body::to_bytes: 345,678 bytes (28.0%)
```

### Perf para Análise de Memória

O `perf` do Linux pode rastrear alocações:

```bash
perf record -e 'sdt_rust:*' -g ./target/release/my_server
perf script > perf.trace
```

Isso captura eventos específicos da alocação Rust, mostrando a hierarquia exata de chamadas que levam a cada alocação.

### Solução Prática

Com os dados do profiler, otimizamos o manipulador:

```rust
async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    // Reutiliza buffer existente
    let mut body_bytes = BytesMut::new();
    hyper::body::to_bytes(req.into_body())
        .await?
        .reader()
        .read_to_end(&mut body_bytes)?;
    
    // Parsing sem alocações extras
    let json: serde_json::Value = serde_json::from_reader(body_bytes.reader())?;
    
    Ok(build_response(json))
}
```

Resultado: redução de 80% no uso de memória sob a mesma carga.

### Exercício Prático

Um serviço de processamento de logs apresenta o seguinte comportamento de memória:

```
Time (s) | Heap (MB)
-------------------
0       | 10
10      | 45
20      | 80
30      | 120
```

O código principal é:

```rust
fn process_log(log: &str) -> Vec<String> {
    log.lines()
       .filter(|l| l.contains("ERROR"))
       .map(|l| l.trim().to_uppercase())
       .collect()
}
```

**Tarefa**: 
1. Instrumente o código com DHAT
2. Identifique o padrão de alocação
3. Proponha uma otimização

**Solução**:

1. Adicione o profiling:

```rust
use dhat::{Dhat, DhatAlloc};

#[global_allocator]
static ALLOCATOR: DhatAlloc = DhatAlloc;

fn main() {
    let _dhat = Dhat::start_heap_profiling();
    // Código existente
}
```

2. O relatório mostrará:
- Alocações múltiplas por `to_uppercase()`
- Redundância em `trim()` para linhas já processadas

3. Otimize com:

```rust
fn process_log(log: &str) -> Vec<&str> {
    log.lines()
       .filter(|l| l.contains("ERROR"))
       .map(|l| l.trim())
       .collect()
}
```

Poupança: Elimina 2 alocações por linha processada (string nova e cópia uppercase).