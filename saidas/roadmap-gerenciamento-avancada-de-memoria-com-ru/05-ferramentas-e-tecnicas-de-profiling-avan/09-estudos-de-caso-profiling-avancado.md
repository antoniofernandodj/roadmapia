## Estudos de Caso: Profiling Avançado

### Identificando Alocações Desnecessárias em um Servidor HTTP

Considere um servidor HTTP em Rust que processa requisições JSON. Durante o profiling com `perf`, você nota um pico incomum de alocações durante o deserialização:

```rust
use serde_json::Value;

fn handle_request(json_data: &str) -> Result<(), serde_json::Error> {
    let parsed: Value = serde_json::from_str(json_data)?; // Alocação suspeita
    process_data(&parsed);
    Ok(())
}
```

Ao executar com `perf record -g -- cargo run --release` e analisar com `perf report`, vemos:

```
- 73.2% serde_json::from_str
  - 61.8% alloc::alloc::box_free
  - 11.4% hashbrown::map::HashMap::insert
```

O problema está na alocação dinâmica do `Value`. A solução? Usar um tipo estático com `serde::Deserialize`:

```rust
#[derive(serde::Deserialize)]
struct RequestData {
    user_id: u64,
    action: String,
}

fn handle_request(json_data: &str) -> Result<(), serde_json::Error> {
    let parsed: RequestData = serde_json::from_str(json_data)?; // Zero alocações para campos conhecidos
    process_data(&parsed);
    Ok(())
}
```

Após a mudança, o `perf report` mostra:
```
- 12.1% serde_json::from_str
  - 0.3% alloc::alloc::box_free
```

### Memory Leak em Cache LRU

Um cache LRU usando `std::collections::HashMap` e listas vinculadas apresentava crescimento contínuo de memória. O `valgrind --leak-check=full` não detectava vazamentos, mas o `heaptrack` mostrava:

```
Allocation heatmap:
0x5587d1d45a00 - 128MB (repeated 47 times)
```

O código problemático:

```rust
struct LruCache {
    map: HashMap<String, Arc<Node>>,
    head: Option<Arc<Node>>,
    tail: Option<Arc<Node>>,
}

impl LruCache {
    fn insert(&mut self, key: String, value: String) {
        let node = Arc::new(Node { /* ... */ });
        self.map.insert(key, node.clone());
        // Ciclo de referência: node.next e node.prev nunca são limpos
    }
}
```

A solução foi substituir `Arc` por `Weak` para as referências anteriores:

```rust
struct Node {
    next: Option<Arc<Node>>,
    prev: Option<Weak<Node>>, // Quebra o ciclo
}
```

### Otimizando Iteradores em Processamento Batch

Um pipeline de dados mostrava lentidão no estágio de transformação. O `flamegraph` revelou:

```
- 42% core::iter::traits::iterator::Iterator::collect
  - 38% alloc::vec::Vec::extend
```

O código original:

```rust
data.into_iter()
    .map(transform_step_1)
    .collect::<Vec<_>>() // Alocação intermediária
    .into_iter()
    .map(transform_step_2)
    .collect()
```

Foi reescrito usando `Iterator::fold` para processamento lazy:

```rust
data.into_iter()
    .map(|x| transform_step_2(transform_step_1(x)))
    .collect()
```

Resultado no flamegraph:
```
- 15% core::iter::traits::iterator::Iterator::collect
```

### Exercício Prático

Um serviço de análise de logs apresenta alto consumo de CPU. O `perf` mostra:

```
- 65% regex::exec::ExecNoSync::exec
- 22% alloc::string::String::from_utf8
```

O código atual:

```rust
fn process_log(line: &str) -> Option<LogEntry> {
    let re = Regex::new(r"(\d{4}-\d{2}-\d{2}) (\w+): (.+)").unwrap();
    let caps = re.captures(line)?;
    
    Some(LogEntry {
        date: String::from(&caps[1]), // Alocação 1
        level: String::from(&caps[2]), // Alocação 2
        message: String::from(&caps[3]), // Alocação 3
    })
}
```

**Tarefa**: Reescreva a função para eliminar as alocações desnecessárias, mantendo a mesma interface.

**Solução**:

```rust
fn process_log(line: &str) -> Option<LogEntry> {
    static RE: Lazy<Regex> = Lazy::new(|| 
        Regex::new(r"(\d{4}-\d{2}-\d{2}) (\w+): (.+)").unwrap()
    );
    
    let caps = RE.captures(line)?;
    
    Some(LogEntry {
        date: caps[1].to_string(),    // Alocação necessária
        level: caps[2].to_string(),   // Alocação necessária
        message: caps[3].to_string(), // Alocação necessária
    })
}
```

Melhorias implementadas:
1. Compilação única da regex com `Lazy`
2. Uso de `to_string()` mais idiomático
3. Manutenção da semântica de ownership (strings precisam ser alocadas)

Para otimização adicional, poderia-se usar `&str` com lifetimes, mas isso exigiria mudar a interface da função.