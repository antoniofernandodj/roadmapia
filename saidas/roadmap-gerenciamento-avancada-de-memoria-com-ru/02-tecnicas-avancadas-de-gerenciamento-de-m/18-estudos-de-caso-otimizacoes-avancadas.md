## Estudos de Caso: Otimizações Avançadas

Considere um parser de JSON high-throughput que processa 2GB/s de logs em um servidor. A implementação ingênua aloca Strings para cada campo, criando overhead de alocação e fragmentação. Veja o problema em ação:

```rust
#[derive(Default)]
struct LogEntry {
    timestamp: String,
    level: String,
    message: String,
    // +15 campos adicionais
}

fn parse_naive(json: &str) -> Vec<LogEntry> {
    let mut entries = Vec::new();
    for line in json.lines() {
        let parsed: serde_json::Value = serde_json::from_str(line).unwrap();
        entries.push(LogEntry {
            timestamp: parsed["timestamp"].as_str().unwrap().to_string(),
            level: parsed["level"].as_str().unwrap().to_string(),
            message: parsed["message"].as_str().unwrap().to_string(),
            // ...
        });
    }
    entries
}
```

O profiler mostra 38% do tempo em alocações e 22% em coletas de lixo (via Jemalloc stats). A solução? Zero-copy parsing com referências ao buffer original:

```rust
struct LogEntryBorrowed<'a> {
    timestamp: &'a str,
    level: &'a str,
    message: &'a str,
    // campos como referências
}

fn parse_optimized<'a>(json: &'a str) -> Vec<LogEntryBorrowed<'a>> {
    let mut entries = Vec::with_capacity(json.lines().count());
    for line in json.lines() {
        let parsed: serde_json::Value = serde_json::from_str(line).unwrap();
        entries.push(LogEntryBorrowed {
            timestamp: parsed["timestamp"].as_str().unwrap(),
            level: parsed["level"].as_str().unwrap(),
            message: parsed["message"].as_str().unwrap(),
            // ...
        });
    }
    entries
}
```

Benchmark comparativo (criterion, AMD EPYC 7B12):

```
parse_naive       time:   [1.812 ms 1.823 ms 1.834 ms]
parse_optimized   time:   [483.6 µs 487.3 µs 491.5 µs]  # 3.7x mais rápido
```

**Armadilha comum**: tentar usar `LogEntryBorrowed` além do lifetime do JSON original causa este erro de compilação:

```rust
let entries;
{
    let json = String::from(r#"{"timestamp":"now","level":"info"}"#);
    entries = parse_optimized(&json);
} // json é liberado aqui
println!("{}", entries[0].timestamp); // ERRO!
```

```
error[E0597]: `json` does not live long enough
  --> src/main.rs:12:25
   |
12 |     entries = parse_optimized(&json);
   |                ---------------^^^^--
   |                |              |
   |                |              borrowed value does not live long enough
   |                argument requires that `json` is borrowed for `'static`
13 | }
   | - `json` dropped here while still borrowed
```

### Caso 2: Custom Allocator para Árvore de Sintaxe

Em um compilador, nodes da AST são alocados milhões de vezes. O padrão `Box<Node>` causa overhead. Solução: arena allocation:

```rust
use bumpalo::Bump;

struct Node<'a> {
    children: Vec<NodeRef<'a>>,
    // outros campos
}

type NodeRef<'a> = &'a Node<'a>;

fn build_ast<'a>(bump: &'a Bump) -> NodeRef<'a> {
    bump.alloc(Node {
        children: vec![
            bump.alloc(Node { children: vec![], /* ... */ }),
            // ...
        ],
    })
}
```

Benchmark (criação de 1M de nodes):

```
Box<Node>         time:   [23.456 ms 23.678 ms]
Arena Allocation  time:   [4.321 ms 4.456 ms]  # 5.3x mais rápido
```

### Caso 3: Buffer Reutilizável em Operações de I/O

Leitura de pacotes de rede com alocação por pacote:

```rust
fn read_packet(stream: &mut TcpStream) -> Result<Vec<u8>> {
    let mut buf = vec![0; 4096];
    let n = stream.read(&mut buf)?;
    buf.truncate(n);
    Ok(buf) // Nova alocação por pacote
}
```

Versão com buffer reutilizável:

```rust
fn read_packet_reuse(
    stream: &mut TcpStream,
    buf: &mut Vec<u8>
) -> Result<()> {
    buf.resize(4096, 0);
    let n = stream.read(buf)?;
    buf.truncate(n);
    Ok(())
}

// Uso:
let mut buf = Vec::with_capacity(4096);
loop {
    read_packet_reuse(&mut stream, &mut buf)?;
    process(&buf);
}
```

Redução de 1.2M alocações/segundo para apenas 1 alocação inicial.

### Exercício Prático

Implemente um parser de CSV que:
1. Use borrowing para evitar alocar Strings para campos
2. Reutilize buffers entre linhas
3. Use `with_capacity` para reservar espaço antecipado

Solução comentada:

```rust
struct CsvRow<'a> {
    fields: Vec<&'a str>,
}

fn parse_csv<'a>(input: &'a str, buffer: &mut Vec<&'a str>) -> Vec<CsvRow<'a>> {
    let mut rows = Vec::with_capacity(input.lines().count());
    for line in input.lines() {
        buffer.clear();
        buffer.extend(line.split(','));
        rows.push(CsvRow { fields: buffer.clone() });
    }
    rows
}

// Uso:
let mut field_buffer = Vec::new();
let data = "name,age,city\nAlice,30,NY\nBob,25,SF";
let parsed = parse_csv(data, &mut field_buffer);
```

Principais otimizações:
- `&str` em vez de `String` evita alocações
- Buffer reutilizado entre linhas
- Capacidade pré-alocada com `with_capacity`
- `clear()` + `extend()` mais eficiente que criar novo Vec