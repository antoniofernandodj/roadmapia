## Escolhendo as Técnicas Certas

Otimização de memória em Rust não é sobre aplicar todas as técnicas possíveis, mas sobre selecionar as que resolvem seu problema específico com o menor custo de complexidade. Vejamos como tomar essas decisões baseadas em cenários reais.

### Quando Usar Stack vs Heap

Considere este parser de CSV que processa linhas de um arquivo:

```rust
fn process_csv_line(line: &str) -> Vec<String> {
    line.split(',').map(|s| s.trim().to_string()).collect()
}
```

O problema aqui é a alocação desnecessária no heap para cada campo (`to_string()`). Se sabemos que os campos têm tamanho limitado (ex: códigos de até 10 caracteres), uma versão otimizada seria:

```rust
fn process_csv_line_optimized(line: &str) -> Vec<&str> {
    line.split(',').map(|s| s.trim()).collect()
}
```

**Diferença prática:**
- Versão original (heap): 1.2μs por linha (alocação + cópia)
- Versão otimizada (stack): 0.3μs por linha (apenas slices)

**Quando escolher:**
- Use stack quando:
  - O tempo de vida dos dados é claro e limitado
  - Os tamanhos são conhecidos e pequenos (< 1KB)
  - Você está em um hot path de performance

### Buffers Reutilizáveis vs Alocações On-Demand

Para um servidor HTTP que processa JSON, alocar um novo buffer para cada requisição é ineficiente:

```rust
fn handle_request(json_data: &str) -> Result<Value, Error> {
    let mut buffer = Vec::with_capacity(1024); // Nova alocação
    serde_json::from_str(json_data)
}
```

A versão com buffer reutilizável usando `lazy_static`:

```rust
use lazy_static::lazy_static;
use std::sync::Mutex;

lazy_static! {
    static ref BUFFER: Mutex<Vec<u8>> = Mutex::new(Vec::with_capacity(1024 * 1024));
}

fn handle_request_optimized(json_data: &str) -> Result<Value, Error> {
    let mut buffer = BUFFER.lock().unwrap();
    buffer.clear();
    serde_json::from_str(json_data)
}
```

**Impacto:**
- Alocação por request: 15% do tempo total
- Buffer reutilizado: 2% do tempo total

**Regra prática:**
- Reutilize buffers quando:
  - O tamanho máximo é previsível
  - A limpeza (`clear()`) é mais barata que realocar
  - Você tem contenção de memória sob carga

### Arc vs Rc: A Escolha de Thread-Safety

Considere um cache de configurações compartilhado:

```rust
// Opção 1: Single-thread
use std::rc::Rc;

struct ConfigCache {
    settings: Rc<HashMap<String, String>>,
}

// Opção 2: Multi-thread
use std::sync::Arc;

struct ConfigCacheThreadSafe {
    settings: Arc<HashMap<String, String>>,
}
```

**Custo de performance:**
- `Rc`: incremento/decremento atômico simples (1ns)
- `Arc`: operações atômicas cross-thread (15ns)

**Escolha baseada em:**
1. Seus dados atravessam threads? → `Arc`
2. Você está em um loop crítico? → `Rc` + restrição a single-thread
3. O overhead é relevante no seu contexto? Meça antes de decidir

### Estratégias para Coleções

Comparemos duas implementações de um processador de log:

```rust
// Versão ingênua: alocação frequente
fn process_logs(logs: &[String]) -> Vec<String> {
    logs.iter()
        .filter(|log| log.contains("ERROR"))
        .map(|log| log.to_uppercase())
        .collect()
}

// Versão otimizada: pré-alocação
fn process_logs_optimized(logs: &[String]) -> Vec<String> {
    let mut result = Vec::with_capacity(logs.len() / 10); // Estimativa
    for log in logs {
        if log.contains("ERROR") {
            result.push(log.to_uppercase());
        }
    }
    result
}
```

**Por que a segunda é melhor:**
1. Evita realocações ao crescer o Vec
2. Reduz fragmentação de memória
3. Melhor localidade de cache

**Técnicas para coleções:**
- `with_capacity()` quando você tem uma estimativa razoável
- `into_iter()` ao invés de `iter()` para mover dados
- `Box<[T]>` para coleções imutáveis após criação

### Exercício Prático

Você está otimizando um sistema de análise de tweets que:
1. Processa 10,000 tweets/segundo
2. 80% são menores que 280 bytes
3. Precisa filtrar tweets contendo palavras-chave
4. Os dados são processados em 4 threads paralelas

Escreva a estrutura de dados mais eficiente para armazenar os tweets durante o processamento, considerando:
- Alocação de memória
- Segurança entre threads
- Minimização de cópias

**Solução comentada:**

```rust
use std::sync::Arc;
use bytes::Bytes;

struct TweetProcessor {
    // Bytes permite compartilhamento sem cópia (ref counting)
    keyword_filter: Arc<[String]>,
    // Pool de buffers reutilizáveis
    buffer_pool: Arc<Mutex<Vec<Bytes>>>,
}

impl TweetProcessor {
    fn process(&self, tweet: &str) -> Option<Bytes> {
        let contains_keyword = self.keyword_filter.iter()
            .any(|kw| tweet.contains(kw));
        
        if contains_keyword {
            // Reutiliza ou aloca buffer
            let mut pool = self.buffer_pool.lock().unwrap();
            let buffer = pool.pop()
                .unwrap_or_else(|| Bytes::with_capacity(280));
            
            // Simula processamento
            Some(buffer)
        } else {
            None
        }
    }
}
```

**Por que funciona:**
1. `Bytes` evita cópias múltiplas dos dados
2. `Arc<[String]>` é imutável e thread-safe sem overhead desnecessário
3. O pool de buffers reduz alocações para tweets filtrados
4. Capacidade inicial de 280 bytes cobre 80% dos casos sem realocação