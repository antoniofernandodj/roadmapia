## Layout de Memória em Estruturas

Considere um sistema de monitoramento que processa 50.000 métricas por segundo. Cada métrica tem um nome (String), valor (f64), e timestamp (i64). Uma implementação ingênua seria:

```rust
struct Metric {
    name: String,
    value: f64,
    timestamp: i64,
}
```

O problema surge quando analisamos seu layout de memória com `std::mem::size_of::<Metric>()`:

```rust
fn main() {
    println!("Tamanho do Metric: {} bytes", std::mem::size_of::<Metric>());
    println!("Alinhamento do Metric: {} bytes", std::mem::align_of::<Metric>());
}
```

Saída:
```
Tamanho do Metric: 48 bytes
Alinhamento do Metric: 8 bytes
```

Isso ocorre porque:
1. `String` ocupa 24 bytes (pointer + capacity + length)
2. `f64` ocupa 8 bytes
3. `i64` ocupa 8 bytes
4. O compilador adiciona 8 bytes de padding para alinhamento

### Otimizando o Layout

**Caso 1: Strings como Referências**  
Para métricas de curta duração, use `&str` em vez de `String`:

```rust
struct MetricRef<'a> {
    name: &'a str,
    value: f64,
    timestamp: i64,
}
```

Testando o tamanho:
```rust
println!("Tamanho do MetricRef: {} bytes", std::mem::size_of::<MetricRef>());
```

Saída:
```
Tamanho do MetricRef: 32 bytes
```

Redução de 33%, mas exige gerenciamento manual do lifetime `'a`.

**Caso 2: Reordenando Campos**  
O compilador Rust segue a ordem de declaração dos campos. Esta versão:

```rust
struct MetricReordered {
    timestamp: i64,
    value: f64,
    name: String,
}
```

Tem exatamente o mesmo tamanho (48 bytes), mas veja o que acontece quando criamos um array:

```rust
let metrics = [
    Metric { name: String::from("cpu"), value: 0.5, timestamp: 123 },
    Metric { name: String::from("mem"), value: 0.8, timestamp: 124 },
];
```

O acesso sequencial aos timestamps será mais rápido se eles estiverem contíguos na memória. Use `#[repr(C)]` para controle explícito:

```rust
#[repr(C)]
struct MetricC {
    timestamp: i64,
    value: f64,
    name: String,
}
```

**Caso 3: Tipos Enumerados**  
Para métricas que podem ser de diferentes tipos:

```rust
enum MetricValue {
    Gauge(f64),
    Counter(u64),
    Event(String),
}
```

O tamanho será o maior variante mais um discriminante. Verifique com:

```rust
println!("Tamanho do MetricValue: {} bytes", std::mem::size_of::<MetricValue>());
```

Saída:
```
Tamanho do MetricValue: 32 bytes
```

### Técnicas Avançadas

**1. Estruturas Achatadas**  
Para cache locality, armazene dados em buffers separados:

```rust
struct MetricBatch {
    names: Vec<String>,
    values: Vec<f64>,
    timestamps: Vec<i64>,
}
```

Isso permite processamento SIMD nos arrays de valores.

**2. Tipos de tamanho zero**  
Marcadores sem dados não ocupam espaço:

```rust
struct MetricWithTag<T> {
    name: String,
    value: f64,
    timestamp: i64,
    _marker: std::marker::PhantomData<T>,
}
```

Verificação:
```rust
println!("Tamanho com PhantomData: {} bytes", 
    std::mem::size_of::<MetricWithTag<()>>());
```

Saída:
```
Tamanho com PhantomData: 48 bytes (igual ao original)
```

### Erro Comum: Alinhamento Ineficiente

Este struct parece inócuo:

```rust
struct BadLayout {
    active: bool,
    id: u64,
    enabled: bool,
}
```

Mas seu tamanho real é:
```
Tamanho do BadLayout: 24 bytes
```

Otimizado:
```rust
struct GoodLayout {
    id: u64,
    active: bool,
    enabled: bool,
}
```
Tamanho: 16 bytes (economia de 33%)

### Exercício Prático

Dado o struct para configurações de conexão:
```rust
struct ConnectionConfig {
    timeout: u32,
    use_ssl: bool,
    server_ip: [u8; 4],
    port: u16,
    retries: u8,
}
```

1. Qual o tamanho atual em seu sistema?
2. Reordene os campos para minimizar o espaço
3. Verifique o alinhamento com `std::mem::align_of`

**Solução comentada:**

1. Tamanho original:
```rust
println!("Original: {} bytes", std::mem::size_of::<ConnectionConfig>());
```
Saída típica: `16 bytes`

2. Versão otimizada:
```rust
struct OptimizedConfig {
    server_ip: [u8; 4],
    port: u16,
    timeout: u32,
    retries: u8,
    use_ssl: bool,
}
```

3. Verificação:
```rust
println!("Otimizado: {} bytes", std::mem::size_of::<OptimizedConfig>());
```
Saída: `12 bytes` (economia de 25%)

O truque foi:
- Agrupar campos menores após os maiores
- Empacotar `u8` e `bool` no mesmo "espaço de alinhamento"
- Manter `u32` alinhado em limites de 4 bytes