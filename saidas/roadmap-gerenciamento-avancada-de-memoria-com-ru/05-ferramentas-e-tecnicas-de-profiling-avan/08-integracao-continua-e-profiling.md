## Integração Contínua e Profiling

Um pipeline de CI que apenas executa testes está perdendo a oportunidade de capturar regressões de desempenho antes que cheguem à produção. Vamos implementar um sistema que detecta automaticamente aumentos no uso de memória ou degradação no throughput, usando ferramentas que já conhecemos.

### O Problema Real

Considere este cenário comum: sua equipe adiciona um cache in-memory para melhorar os tempos de resposta. Os testes unitários passam, mas ninguém percebe que o consumo de memória agora escala linearmente com o número de requisições. Sem monitoramento contínuo de desempenho, esse problema só será descoberto em produção sob carga real.

### Configurando o Baseline

Primeiro, precisamos estabelecer métricas de referência. Crie um arquivo `benchmarks/memory_baseline.json`:

```json
{
  "max_rss_bytes": 52428800,
  "allocation_count": 1200,
  "throughput_rps": 8500
}
```

Estes valores devem ser obtidos executando seus benchmarks em condições controladas. Use o `cargo bench` com instrumentação:

```rust
// benches/memory_bench.rs
use criterion::{criterion_group, criterion_main, Criterion};
use std::process::Command;

fn memory_bench(c: &mut Criterion) {
    let server = Command::new("target/release/myapp")
        .arg("--bench-mode")
        .spawn()
        .unwrap();
    
    c.bench_function("memory_usage", |b| {
        b.iter(|| {
            // Coleta métricas usando perf/dtrace
            let stats = Command::new("scripts/collect_memory.sh")
                .arg(server.id().to_string())
                .output()
                .unwrap();
            // Valida contra o baseline
            assert!(parse_rss(&stats) < 52_428_800, "Regressão de memória detectada");
        });
    });
    
    server.kill().unwrap();
}

criterion_group!(benches, memory_bench);
criterion_main!(benches);
```

O script `collect_memory.sh` usaria ferramentas como `ps`, `perf`, ou `heaptrack` dependendo do sistema operacional.

### Gatilhos de Alerta Inteligentes

Em vez de falhar o build para qualquer variação, implemente regras progressivas:

```rust
// .github/workflows/performance_gate.rs
fn analyze_regression(current: &Metrics, baseline: &Metrics) -> GateResult {
    let threshold = if env::var("CI_MERGE_REQUEST").is_ok() {
        // PRs têm tolerância menor
        0.05 
    } else {
        // Main branch permite variação maior
        0.15
    };
    
    if current.max_rss > baseline.max_rss * (1.0 + threshold) {
        GateResult::Fail(format!(
            "RSS aumentou {:.2}% (Baseline: {} MB, Atual: {} MB)",
            (current.max_rss - baseline.max_rss) / baseline.max_rss * 100.0,
            baseline.max_rss / 1024 / 1024,
            current.max_rss / 1024 / 1024
        ))
    } else {
        GateResult::Pass
    }
}
```

### Exemplo Completo com GitHub Actions

```yaml
# .github/workflows/performance.yml
name: Performance Gate

on:
  push:
    branches: [main]
  pull_request:

jobs:
  profile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          profile: minimal
          toolchain: stable
          components: rust-src, llvm-tools-preview
      
      - name: Build with symbols
        run: |
          cargo build --release --all-features
          objcopy --only-keep-debug target/release/myapp myapp.debug
      
      - name: Run benchmarks
        run: |
          cargo bench --bench memory -- --nocapture
      
      - name: Analyze results
        id: analysis
        run: |
          python scripts/compare_metrics.py current_metrics.json benchmarks/memory_baseline.json
      
      - name: Fail on regression
        if: steps.analysis.outputs.regression == 'true'
        run: |
          echo "::error::REGRESSÃO DE DESEMPENHO: ${{ steps.analysis.outputs.message }}"
          exit 1
```

### Erro Comum e Correção

Um erro frequente é não isolar o ambiente de benchmark. Se seu teste rodar em máquina compartilhada (como runners de CI), os resultados serão inconsistentes:

```bash
# Errado - Sem isolamento
cargo bench --bench throughput

# Correto - Isolando CPUs e prioridade
taskset -c 0 chrt -f 99 cargo bench --bench throughput
```

A mensagem de erro típica seria:
```
Warning: Benchmark results unreliable (variance > 20%)
Consider isolating cores and setting process priority
```

### Exercício Prático

**Problema**: Modifique o workflow acima para:
1. Coletar flamegraphs durante a execução dos benchmarks
2. Armazená-los como artefatos quando houver regressão
3. Implementar um timeout diferenciado para benchmarks de memória vs CPU

**Solução**:

```yaml
- name: Collect profiling data
  run: |
    perf record -F 99 -g -- cargo bench --bench memory
    perf script > flamegraph.out
    grep -v '^#' flamegraph.out | inferno-collapse-perf > stacks.folded
    inferno-flamegraph < stacks.folded > flamegraph.svg
  
- name: Upload artifacts
  if: failure() && steps.analysis.outputs.regression == 'true'
  uses: actions/upload-artifact@v3
  with:
    name: profile-data
    path: |
      flamegraph.svg
      current_metrics.json
    retention-days: 7

- name: Run with timeout
  timeout-minutes: ${{ 
    contains(github.event.pull_request.labels.*.name, 'memory-intensive') 
    && 30 || 15 
  }}
```

Esta solução garante que:
1. Dados de profiling sejam gerados sem impacto significativo no tempo total
2. Artefatos críticos sejam preservados apenas quando necessário
3. Tempo de execução adapte-se ao contexto do PR