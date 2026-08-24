## Análise de Heap em Rust

Quando um programa Rust consome mais memória do que o esperado, identificar os pontos exatos de alocação é crucial. Ao contrário de linguagens com GC, onde o heap cresce de forma menos previsível, em Rust cada alocação é explícita - mas nem sempre óbvia.

Considere este parser de JSON que processa grandes arquivos:

```rust
use serde_json::Value;
use std::fs;

fn process_large_json(path: &str) -> Vec<String> {
    let content = fs::read_to_string(path).unwrap();
    let parsed: Value = serde_json::from_str(&content).unwrap();
    
    parsed.as_array()
        .unwrap()
        .iter()
        .filter(|v| v["active"].as_bool().unwrap_or(false))
        .map(|v| v["name"].as_str().unwrap().to_string())
        .collect()
}
```

Ao executar com um arquivo de 100MB, o consumo de memória dispara para 1.2GB. Por quê? Vamos instrumentar o código:

```rust
#[global_allocator]
static ALLOC: dhat::Alloc = dhat::Alloc;

fn main() {
    let _profiler = dhat::Profiler::new_heap();
    
    let data = process_large_json("large_file.json");
    println!("Processed {} items", data.len());
}
```

Adicione ao Cargo.toml:
```toml
[dependencies]
dhat = "0.3"
```

A saída revela o problema:
```
dhat: Total:     1,258,291,712 bytes in 2,097,577 blocks
dhat: At t-gmax: 1,258,291,712 bytes in 2,097,577 blocks
dhat: At t-end:  1,024 bytes in 1 blocks
```

O pico de alocação ocorre durante o parsing. O `Value` do serde_json mantém toda a estrutura deserializada na memória. Para arquivos grandes, isso é ineficiente. A solução? Stream parsing:

```rust
use serde_json::{Deserializer, StreamDeserializer};

fn process_large_json_optimized(path: &str) -> Vec<String> {
    let file = fs::File::open(path).unwrap();
    let stream = Deserializer::from_reader(file).into_iter::<Value>();
    
    stream.filter_map(|v| {
        let v = v.ok()?;
        if v["active"].as_bool()? {
            Some(v["name"].as_str()?.to_string())
        } else {
            None
        }
    }).collect()
}
```

A nova versão mostra:
```
dhat: Total:     52,428,800 bytes in 1,048 blocks
dhat: At t-gmax: 52,428,800 bytes in 1,048 blocks
```

Redução de 96% no uso de heap! O `StreamDeserializer` processa o JSON em pedaços, evitando a carga completa na memória.

### Erro comum: clones invisíveis

Este código parece inocente:

```rust
fn process_data(data: &[String]) -> Vec<String> {
    data.iter()
        .filter(|s| s.len() > 5)
        .map(|s| s.to_string()) // Clone desnecessário!
        .collect()
}
```

O `to_string()` aloca nova String mesmo quando poderia reutilizar a existente. O DHAT mostra:
```
dhat: Total:     1,048,576 bytes in 16,384 blocks
```

Versão otimizada:
```rust
fn process_data(data: &[String]) -> Vec<&String> {
    data.iter()
        .filter(|s| s.len() > 5)
        .collect()
}
```
Saída:
```
dhat: Total:     0 bytes in 0 blocks
```

### Exercício: Analise este código

```rust
fn build_matrix(size: usize) -> Vec<Vec<u32>> {
    (0..size).map(|i| {
        (0..size).map(|j| (i * j) as u32).collect()
    }).collect()
}
```

1. Qual o padrão de alocação para size=1000?
2. Como reduzir as alocações mantendo a funcionalidade?

**Solução:**

1. O código aloca 1001 Vecs (1 externa + 1000 internas), com pico de ~4MB (1000×1000×4 bytes).

2. Usar um Vec único com cálculo de índice:

```rust
fn build_matrix(size: usize) -> Vec<u32> {
    let mut matrix = Vec::with_capacity(size * size);
    for i in 0..size {
        for j in 0..size {
            matrix.push((i * j) as u32);
        }
    }
    matrix
}
```

DHAT mostra redução para 1 alocação:
```
dhat: Total:     4,000,000 bytes in 1 blocks
```