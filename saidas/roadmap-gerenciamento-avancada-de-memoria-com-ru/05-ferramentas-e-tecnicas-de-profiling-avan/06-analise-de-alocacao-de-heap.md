## Análise de Alocação de Heap

Um servidor web em Rust pode processar milhares de requisições por segundo, mas um padrão ruim de alocações de heap pode reduzir esse desempenho pela metade. Veja este código que parece inocente:

```rust
fn process_request(headers: &[String]) -> Vec<String> {
    headers.iter()
        .map(|h| h.to_uppercase())
        .filter(|h| h.contains("AUTH"))
        .collect()
}
```

Ao analisar com `perf` ou `dtrace`, você encontrará uma explosão de alocações temporárias - cada `to_uppercase()` cria uma nova String na heap, mesmo para headers que serão descartados pelo filtro. A saída típica do `perf stat` mostra:

```
3,542,101 allocations      # 1.153 M/sec
```

O problema real está no fluxo de transformações: primeiro alocamos todas as strings em maiúsculas, depois filtramos. Melhoramos com:

```rust
fn process_request_optimized(headers: &[String]) -> Vec<String> {
    headers.iter()
        .filter(|h| h.contains("AUTH"))
        .map(|h| h.to_uppercase())
        .collect()
}
```

O `perf` agora mostra:
```
1,204,566 allocations      # 0.402 M/sec
```

Mas ainda há alocações desnecessárias. O próximo nível é usar iteradores que trabalham com slices:

```rust
fn process_request_slice(headers: &[&str]) -> Vec<&str> {
    headers.iter()
        .copied()
        .filter(|h| h.contains("AUTH"))
        .collect()
}
```

Zero alocações na heap! O segredo está em:
1. Usar `&str` em vez de `String` quando possível
2. `copied()` para iterar sobre os valores diretamente
3. Manter tudo na stack até o `collect()` final

**Padrões comuns problemáticos:**
- `clone()` desnecessário em cadeias de métodos
- Conversões repetidas entre `String` e `&str`
- Coleções intermediárias em pipelines de processamento

**Ferramentas de análise:**

1. **Heaptrack** (Linux):
```bash
heaptrack ./meu_programa
heaptrack --analyze heaptrack.meu_programa.<pid>.gz
```

Mostra alocações por local de código:
```
0x55667788 in process_request (src/main.rs:10)
  12.5MB allocated total
  1024 allocations
```

2. **DHAT** (integrado ao Rust):
```rust
#[test]
fn test_alocacoes() {
    dhat::assert_eq!(dhat::HeapStats::get().total_blocks, 0);
}
```

Falha com:
```
thread 'test_alocacoes' panicked at '
Expected heap allocations: 0
Actual heap allocations: 17
```

3. **Valgrind Massif**:
```bash
valgrind --tool=massif --threshold=0.1 ./target/release/meu_app
ms_print massif.out.12345
```

Saída típica:
```
MB
3.125^                                                                      
   |                                                                       
   |                                                                       
   |                                                                       
   |                                                                       
 0 +----------------------------------------------------------------------->Gi
   0                                                                   1024
```

**Exercício Prático:**

Analise este código com heaptrack e reescreva para minimizar alocações:

```rust
fn process_logs(logs: Vec<String>) -> Vec<String> {
    logs.into_iter()
        .map(|log| format!("[PROCESSED] {}", log))
        .filter(|log| log.len() > 20)
        .map(|log| log.to_lowercase())
        .collect()
}
```

**Solução:**

```rust
fn process_logs_optimized(logs: Vec<&str>) -> Vec<&str> {
    logs.into_iter()
        .filter(|log| log.len() > 20 - "[PROCESSED] ".len())
        .collect()
}

// Pré-processar o prefixo se necessário
const PREFIX: &str = "[PROCESSED] ";

fn process_logs_with_prefix(logs: Vec<&str>) -> Vec<String> {
    logs.into_iter()
        .filter(|log| log.len() > 20 - PREFIX.len())
        .map(|log| format!("{}{}", PREFIX, log.to_lowercase()))
        .collect()
}
```

Principais otimizações:
1. Operações de filtro antecipadas
2. Uso de string slices (`&str`) até onde possível
3. Cálculo de tamanhos antecipado para evitar alocações intermediárias
4. Constantes para valores repetidos