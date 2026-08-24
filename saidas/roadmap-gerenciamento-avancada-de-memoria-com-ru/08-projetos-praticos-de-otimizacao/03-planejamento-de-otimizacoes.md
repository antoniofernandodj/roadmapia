## Planejamento de Otimizações

Otimizar um sistema em Rust começa com um diagnóstico preciso, não com alterações aleatórias no código. Um erro comum é sair aplicando `Box::leak()` ou `unsafe` antes de entender onde estão os reais gargalos. Vamos construir um método sistemático para priorizar otimizações que realmente impactam o desempenho.

### 1. Estabelecendo Metas Mensuráveis

Antes de tocar no código, defina o que "melhor desempenho" significa para seu caso:

```rust
// Exemplo: Servidor HTTP com metas claras
#[tokio::main]
async fn main() {
    let server_metrics = ServerMetrics::new(
        Target::throughput(12_000), // 12k req/seg
        Target::latency(Duration::from_millis(95)), // P95 < 95ms
        Target::memory(1024), // < 1GB RSS
    );
    start_server(server_metrics).await;
}
```

Sem metas numéricas, você não terá como validar se as otimizações trouxeram benefício real. Ferramentas como `cargo bench` e `prometheus` ajudam a quantificar esses valores.

### 2. Perfilando Antes de Otimizar

Execute seu sistema com cargas realistas enquanto coleta dados com:

```bash
# Linux perf (baixo overhead)
perf record -g -- target/release/my_app
hotspot perf.data

# Rust específico (com símbolos)
cargo flamegraph
```

Um erro típico aparece quando não se isola o teste:

```
ERRO: Perfilando em debug mode
  → Execute com `--release` e `RUSTFLAGS="-C force-frame-pointers=y"`
```

### 3. Identificando Padrões de Acesso

Analise os dados do profiler procurando por:

1. **Alocações frequentes**: `malloc`/`free` no topo da stack trace
2. **Cópias desnecessárias**: Clones de grandes estruturas
3. **Contenção**: Lock contention em `Mutex`/`RwLock`

Exemplo de diagnóstico:

```rust
// Antes da otimização
fn process_data(data: Vec<u8>) -> Result<()> {
    let parsed = parse(&data)?;  // Alocação temporária
    let transformed = transform(parsed.clone())?; // Cópia desnecessária
    Ok(())
}
```

### 4. Priorizando por Impacto

Use uma matriz de esforço vs. benefício:

| Problema           | Impacto (%) | Esforço | Ação Prioritária |
|--------------------|------------|---------|------------------|
| Clone de 4KB Vec   | 42% CPU    | Baixo   | Refatorar com Arc |
| Lock contention    | 23% Lat    | Médio   | Shard mutexes    |
| Alocação temporária| 12% Mem    | Alto    | Arena allocator  |

### 5. Selecionando Estratégias

Para cada problema identificado, escolha a técnica adequada:

- **Dados imutáveis compartilhados**: `Arc<T>` em vez de clones
- **Buffers frequentes**: `Bytes` ou `Cow<[u8]>`
- **Parsers**: `nom` com alocação zero-copy
- **Estruturas críticas**: `#[repr(C)]` para layout previsível

Exemplo de plano de ação:

```rust
// Plano de otimização documentado
struct OptimizationPlan {
    current: MemoryProfile,
    target: MemoryProfile,
    steps: Vec<OptimizationStep>,
}

impl OptimizationPlan {
    fn add_step(&mut self, step: OptimizationStep) {
        // Valida se a step impacta nossas métricas-alvo
        if step.expected_impact > self.target.threshold {
            self.steps.push(step);
        }
    }
}
```

### 6. Validando Premissas

Antes de implementar, teste micro-benchmarks para confirmar se a abordagem terá o efeito esperado:

```rust
#[bench]
fn arc_vs_clone(b: &mut Bencher) {
    let data = vec![0u8; 1024];
    b.iter(|| {
        // Testa ambas estratégias
        black_box(Arc::new(data.clone()));
        black_box(data.clone());
    });
}
```

Saída esperada:
```
test arc_vs_clone ... bench:   1,234 ns/iter (+/- 45)
test clone_only   ... bench:   4,567 ns/iter (+/- 89)
```

### Exercício Prático

Analise o seguinte trecho e proponha um plano de otimização:

```rust
fn process_images(images: Vec<Image>) -> Vec<ProcessedImage> {
    images.into_iter()
        .map(|img| {
            let temp = img.clone();  // ①
            let processed = heavy_processing(temp);  // ②
            processed
        })
        .collect()
}
```

**Solução Comentada**:

1. **Problema ①**: Clone desnecessário - `img` já é dona dos dados.
   - Solução: Consumir `img` diretamente.

2. **Problema ②**: Processamento pesado pode ser paralelizado.
   - Solução: Usar `rayon::par_iter()` para paralelismo.

Código otimizado:
```rust
fn process_images(images: Vec<Image>) -> Vec<ProcessedImage> {
    images.into_par_iter()  // Paraleliza
        .map(|img| heavy_processing(img))  // Sem clone
        .collect()
}
```

**Métricas esperadas**:
- Redução de 50% no tempo total (paralelismo)
- Eliminação de alocações temporárias (clone)