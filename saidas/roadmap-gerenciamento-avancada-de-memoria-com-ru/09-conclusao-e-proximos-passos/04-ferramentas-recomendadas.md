## Ferramentas Recomendadas

Para diagnosticar e resolver problemas de memória em Rust, você precisará de ferramentas especializadas em três categorias: análise estática, profiling em tempo de execução e benchmark comparativo.

**Análise Estática (Compile-time)**
- `cargo clippy`: Detecta padrões ineficientes de alocação como clones desnecessários ou vetores com capacidade mal dimensionada. Execute com:
  ```bash
  cargo clippy -- -W clippy::perf
  ```
  Saída típica:
  ```
  warning: unnecessary clone
    --> src/main.rs:12:10
     |
  12 |     let data = heavy_data.clone();
     |          ^^^^^^^^^^^^^^^^ help: remove this
  ```

- `cargo-udeps`: Encontra dependências não utilizadas que aumentam o footprint de memória:
  ```bash
  cargo install cargo-udeps && cargo udeps
  ```

**Profiling em Tempo de Execução**
- `heaptrack`: Monitora alocações heap com stack traces. Instalação e uso:
  ```bash
  sudo apt install heaptrack # Linux
  heaptrack ./target/release/my_app
  heaptrack_gui heaptrack.my_app.PID.gz
  ```
  Mostra gráficos de alocações por tamanho e localização no código.

- `cargo-flamegraph`: Identifica hotspots de CPU/memória via flame graphs:
  ```bash
  cargo install flamegraph
  cargo flamegraph --bin my_app
  ```
  Saída: SVG interativo mostrando hierarquia de chamadas e consumo.

**Benchmark e Comparação**
- `criterion.rs`: Framework para medição precisa de desempenho. Exemplo:
  ```rust
  use criterion::{criterion_group, criterion_main, Criterion};

  fn bench_alloc(c: &mut Criterion) {
      c.bench_function("vec_reserve", |b| b.iter(|| Vec::<u32>::with_capacity(1024)));
  }

  criterion_group!(benches, bench_alloc);
  criterion_main!(benches);
  ```
  Execução:
  ```bash
  cargo bench
  ```
  Saída compara tempo/operação com desvio padrão.

**Erro Comum**: Ao usar `perf` em Linux sem símbolos de debug:
  ```
  [unknown] 0x123456
  ```
  Corrija compilando com símbolos:
  ```bash
  RUSTFLAGS="-g" cargo build --release
  ```

**Exercício**: Compare o consumo de memória entre `Vec::new()` e `Vec::with_capacity(1000)` usando `heaptrack` e `criterion`. Solução:
1. Execute com `heaptrack` para ver picos de alocação
2. Use `criterion` para medir diferenças no tempo médio
3. Verifique no `flamegraph` pontos de realocação

**Solução Comentada**:
```rust
// main.rs
fn main() {
    let mut v1 = Vec::new(); // Alocação incremental
    let mut v2 = Vec::with_capacity(1000); // Pré-alocação
    
    // Benchmark com criterion mostrará v2 mais rápido
    // heaptrack revelará múltiplas alocações em v1
}
```