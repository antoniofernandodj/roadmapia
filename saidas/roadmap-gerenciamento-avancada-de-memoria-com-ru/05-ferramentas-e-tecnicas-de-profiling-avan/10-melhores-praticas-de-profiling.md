## Melhores Práticas de Profiling

O profiling eficaz em Rust vai além de executar ferramentas e coletar dados. O desafio está em interpretar os resultados corretamente e tomar decisões que realmente melhorem o desempenho sem introduzir complexidade desnecessária. Veja como extrair o máximo valor das sessões de profiling.

### 1. Defina Metas Mensuráveis Antes de Começar

Profiling sem objetivo claro gera esforço desperdiçado. Em vez de "tornar o código mais rápido", estabeleça:

```rust
// Antes do profiling:
// Objetivo: Reduzir tempo de resposta do endpoint /api/data em 30% sob carga de 1000 RPS
// Métrica atual: 120ms p95
```

### 2. Hierarquize os Problemas com Flamegraphs

Um flamegraph do `perf` mostra chamadas caras, mas priorize pelo impacto potencial:

```bash
# Gere o flamegraph direcionado:
perf record -g -F 99 --call-graph dwarf ./target/release/my_app
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

Analise primeiro as "chamas" mais largas na base, que representam onde o código passa mais tempo. Por exemplo, você pode encontrar:

```
75% do tempo em: json::serialize::to_string
15% em:   crypto::hash::sha256
10% em:   network::send_packet
```

Aqui, otimizar a serialização JSON terá 5x mais impacto que melhorar o SHA-256.

### 3. Valide Suposições com Benchmarks Controlados

Ao identificar um gargalo, isole-o em um benchmark micro antes de refatorar:

```rust
#[bench]
fn bench_json_serialize(b: &mut Bencher) {
    let data = generate_large_test_data(); // 50KB de dados estruturados
    
    b.iter(|| {
        black_box(serde_json::to_string(&data).unwrap());
    });
}
```

Resultado típico antes da otimização:
```
test bench_json_serialize ... bench:   1,203,455 ns/iter (+/- 45,678)
```

### 4. Compare Alocadores em Cenários Reais

Trocar alocadores pode melhorar desempenho, mas meça em condições reais:

```toml
# Cargo.toml
[dev-dependencies]
jemallocator = { version = "0.3", features = ["profiling"] }
```

```rust
#[global_allocator]
static ALLOC: jemallocator::Jemalloc = jemallocator::Jemalloc;

fn main() {
    let _profiling_guard = jemallocator::activate_profiling();
    // Seu código aqui...
}
```

Use `jeprof` para comparar alocações:

```
jeprof ./target/release/my_app --show_bytes --pdf > alloc_report.pdf
```

### 5. Monitore Memory Leaks em Long-Running Sessions

Para servidores, use `dhat-rs` para detectar vazamentos cumulativos:

```rust
use dhat::{Dhat, DhatAlloc};

#[global_allocator]
static ALLOC: DhatAlloc = DhatAlloc;

fn process_request() {
    let _dhat = Dhat::start_heap_profiling();
    // Lógica da requisição...
}
```

Um relatório após 10.000 requisições mostrando crescimento contínuo de heap indica vazamento.

### 6. Aplique a Regra 80/20 nas Otimizações

Após identificar os 20% de código responsáveis por 80% do problema, aplique técnicas como:

- **Batch Processing**: Em vez de alocar por item:
```rust
// Ruim: 1.000 alocações individuais
let results: Vec<String> = items.iter().map(|i| process(i)).collect();

// Bom: 1 alocação pré-dimensionada
let mut results = Vec::with_capacity(items.len());
items.iter().for_each(|i| results.push(process(i)));
```

- **Reutilização de Buffers**:
```rust
let mut buffer = Vec::with_capacity(8192);
loop {
    buffer.clear();
    // Reutiliza o mesmo buffer
    fill_buffer(&mut buffer);
    process(&buffer);
}
```

### 7. Documente as Decisões de Performance

Registre as descobertas e trade-offs no código:

```rust
/// Usamos `Box<[u8]>` em vez de `Vec<u8>` para armazenamento permanente porque:
/// - Economiza 8 bytes por instância (não precisa de capacidade)
/// - Elimina realocações acidentais
/// Benchmark: 12% menos alocações em carga máxima
struct PermanentStorage(Box<[u8]>);
```

### Exercício Prático

**Problema**: Um serviço de log mostra alta CPU quando sob carga. O flamegraph indica 40% do tempo em `log::serialize_entry`.

1. Crie um benchmark que reproduza a serialização com dados reais
2. Experimente trocar `serde_json` por `simd-json` para o formato
3. Meça o impacto na alocação com `dhat-rs`
4. Documente a decisão com números concretos

**Solução comentada**:

```rust
// 1. Benchmark original
#[bench]
fn bench_log_serialize(b: &mut Bencher) {
    let entry = LogEntry::new("ERROR", "Failed to connect", ...);
    
    b.iter(|| {
        black_box(serde_json::to_vec(&entry).unwrap());
    });
}
// Resultado: 450,000 ns/iter, 2 alocações por iteração

// 2. Versão com simd-json
#[bench]
fn bench_log_serialize_simd(b: &mut Bencher) {
    let entry = LogEntry::new("ERROR", "Failed to connect", ...);
    
    b.iter(|| {
        let mut buf = Vec::new();
        simd_json::to_writer(&mut buf, &entry).unwrap();
        black_box(buf);
    });
}
// Resultado: 210,000 ns/iter (-53%), 1 alocação por iteração

// 3. Relatório dhat-rs mostrou redução de 60% nas alocações totais

/// Decisão final: Adotamos simd-json para serialização de logs porque:
/// - Reduz tempo de serialização em 53%
/// - Corta alocações pela metade
/// - Trade-off: Requer trait Serialize customizada para alguns tipos
```