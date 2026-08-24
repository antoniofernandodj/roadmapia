## Identificação de Gargalos

Um servidor HTTP em Rust processa 12.000 requisições por segundo, mas repentinamente trava após 3 minutos de operação. O problema não está na lógica de negócios, mas em como a memória é gerenciada. Identificar esses gargalos exige mais do que intuição - requer ferramentas precisas e metodologia.

### O Ciclo de Vida de um Gargalo

Considere este manipulador de requisições que parece inocente:

```rust
use std::collections::HashMap;

fn process_request(params: &[(&str, &str)]) -> String {
    let mut temp_map = HashMap::new();
    
    for (key, value) in params {
        let processed_value = value.trim().to_uppercase();
        temp_map.insert(key.to_string(), processed_value);
    }
    
    serde_json::to_string(&temp_map).unwrap()
}
```

Ao executar sob carga com `wrk -t12 -c400 -d60s http://localhost:8080`, o consumo de memória cresce linearmente até o OOM killer intervir. O problema não é visível em testes unitários - só aparece sob carga real.

### Ferramentas Essenciais

1. **Valgrind Massif** - Mapeia alocações ao longo do tempo:
```bash
valgrind --tool=massif --massif-out-file=massif.out ./servidor
ms_print massif.out > analise.txt
```

A saída revela:
```
  n        time(i)         total(B)   useful-heap(B) extra-heap(B)    stacks(B)
--------------------------------------------------------------------------------
 10 12,345,678,901      1,024,000,000    768,000,000   256,000,000            0
```

2. **heaptrack** para Rust:
```toml
[dependencies]
heaptrack = { version = "0.1", features = ["enable"] }
```

```rust
#[global_allocator]
static ALLOC: heaptrack::HeapTrack = heaptrack::HeapTrack::new();
```

Execute com:
```bash
HEAPTRACK=1 cargo run --release
```

### Padrões de Vazamento Comuns

1. **Acúmulo em Caches**:
```rust
lazy_static! {
    static ref CACHE: Mutex<HashMap<String, String>> = Mutex::new(HashMap::new());
}

fn get_data(key: &str) -> String {
    let mut cache = CACHE.lock().unwrap();
    if !cache.contains_key(key) {
        let data = fetch_expensive_data(key); // 2MB por chamada
        cache.insert(key.to_string(), data);
    }
    cache.get(key).unwrap().clone()
}
```

Sintoma: Memória sobe em degraus, nunca reduz.

2. **Alocação em Loop**:
```rust
fn process_logs(logs: &[String]) -> Vec<String> {
    logs.iter()
        .map(|log| format!("[PROCESSED] {}", log))
        .collect() // Aloca novo Vec para cada lote
}
```

Diagnóstico: 97% das alocações vêm de `Vec::reserve()` no profile.

### Análise de Estruturas de Dados

Um caso real de um servidor de chat:

```rust
struct User {
    id: u64,
    connections: Vec<Arc<TcpStream>>, // Vazamento aqui
    history: Vec<Message>, // Cresce indefinidamente
}
```

O `heaptrack` revela:
- 1.2 milhões de instâncias de `TcpStream` ativas
- 450MB em mensagens históricas por usuário

### Exercício Prático

Analise este trecho de um servidor de arquivos:

```rust
async fn handle_request(path: PathBuf) -> Result<Vec<u8>, Error> {
    let mut content = Vec::new();
    let mut file = File::open(path)?;
    file.read_to_end(&mut content)?;
    
    if content.len() > 10_000 {
        let compressed = compress(&content)?;
        Ok(compressed)
    } else {
        Ok(content)
    }
}
```

**Problema**: Identifique três potenciais gargalos de memória neste código usando as ferramentas mencionadas.

**Solução**:

1. **Buffer sem limite**: `read_to_end` carrega o arquivo inteiro na memória, perigoso para arquivos grandes. O heaptrack mostraria alocações de vários GB.

2. **Duplicação de dados**: Mesmo quando comprimido, o conteúdo original permanece em `content` até o fim da função. O Massif revelaria picos duplos de memória.

3. **Alocação temporária**: `compress` pode criar buffers internos que não são reutilizados entre chamadas. Um profile detalhado mostraria alocações frequentes do mesmo tamanho.

A correção envolveria:
- Limitar o tamanho máximo do arquivo
- Usar streams em vez de buffers completos
- Reutilizar buffers de compressão