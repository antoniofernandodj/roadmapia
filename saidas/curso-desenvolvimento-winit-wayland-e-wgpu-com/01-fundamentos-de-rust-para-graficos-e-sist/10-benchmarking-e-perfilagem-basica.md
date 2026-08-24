## Benchmarking e Perfilagem Básica

Quando otimizamos código gráfico, adivinhar onde estão os gargalos é receita para desperdício de tempo. Rust oferece ferramentas precisas para medir performance onde mais importa. Vamos começar com um caso real: renderizar 10.000 quadrados com transformações diferentes.

```rust
use std::time::Instant;

fn render_quads() {
    let start = Instant::now();
    
    // Simulação de renderização pesada
    for i in 0..10_000 {
        let _transform = [
            i as f32 * 0.1,
            (i as f32 * 0.2).sin(),
            (i as f32 * 0.3).cos(),
        ];
        // Operação custosa simulada
        std::thread::sleep(std::time::Duration::from_micros(10));
    }
    
    let duration = start.elapsed();
    println!("Renderizou em: {:?}", duration);
}
```

Executando, vemos:
```
Renderizou em: 1.23456789s
```

O problema? `Instant` mede o tempo total, mas não mostra onde estão os pontos quentes. Para isso, usamos o crate `criterion`, adicionando ao Cargo.toml:

```toml
[dev-dependencies]
criterion = "0.4"
```

Criamos um benchmark comparativo entre duas implementações de transformação de vértices:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn transform_naive(vertex: [f32; 3]) -> [f32; 3] {
    [
        vertex[0] * 2.0,
        vertex[1].powi(2),
        (vertex[2] + 1.0).ln(),
    ]
}

fn transform_simd(vertex: [f32; 3]) -> [f32; 3] {
    use std::simd::f32x4;
    let simd_vec = f32x4::from_array([vertex[0], vertex[1], vertex[2], 0.0]);
    let result = f32x4::from_array([2.0, 0.0, 0.0, 0.0]) * simd_vec
        + f32x4::from_array([0.0, 1.0, 1.0, 0.0]) * simd_vec.powf(f32x4::splat(2.0))
        + f32x4::from_array([0.0, 0.0, 1.0, 0.0]) * (simd_vec + f32x4::splat(1.0)).ln();
    [result[0], result[1], result[2]]
}

fn bench_transforms(c: &mut Criterion) {
    let vertex = [1.5, 2.3, 0.8];
    c.bench_function("transform_naive", |b| {
        b.iter(|| transform_naive(black_box(vertex)))
    });
    c.bench_function("transform_simd", |b| {
        b.iter(|| transform_simd(black_box(vertex)))
    });
}

criterion_group!(benches, bench_transforms);
criterion_main!(benches);
```

A saída mostra:
```
transform_naive   time:   [12.345 ns 12.456 ns 12.567 ns]
transform_simd    time:   [8.901 ns 9.012 ns 9.123 ns]
```

O erro comum é esquecer o `black_box`, que impede otimizações que distorceriam os resultados. Sem ele, o compilador pode eliminar chamadas inúteis, invalidando as medições.

Para código gráfico real, adicione perfilação com `perf` no Linux:

```sh
perf stat -d cargo run --release
```

Isso revela métricas como:
```
5,432,156,789 cycles                    # 3.678 GHz
1,234,567,890 instructions              # 0.57 insn per cycle
  987,654,321 cache-references          # 156.789 M/sec
  123,456,789 cache-misses              # 12.5% of all cache refs
```

Quando o problema está na GPU, use markers com WGPU:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Render Encoder"),
});

// Marca o início de uma seção crítica
encoder.push_debug_group("Prepare resources");
// ... código de preparação
encoder.pop_debug_group();

// Outra seção marcada
encoder.push_debug_group("Main render pass");
// ... código de renderização
encoder.pop_debug_group();
```

Estes grupos aparecem em ferramentas como RenderDoc, ajudando a correlacionar trechos de código com atividade GPU.

**Exercício**: Crie um benchmark comparando o desempenho de um cálculo de iluminação usando:
1. Iteração sobre slice com `for` convencional
2. `iter().map().collect()`
3. `par_iter()` do rayon

**Solução**:

```rust
use rayon::prelude::*;

fn illumination_for(lights: &[f32]) -> Vec<f32> {
    let mut result = vec![0.0; lights.len()];
    for (i, &light) in lights.iter().enumerate() {
        result[i] = (light * 0.5).powi(2).sqrt();
    }
    result
}

fn illumination_iter(lights: &[f32]) -> Vec<f32> {
    lights.iter().map(|&l| (l * 0.5).powi(2).sqrt()).collect()
}

fn illumination_par(lights: &[f32]) -> Vec<f32> {
    lights.par_iter().map(|&l| (l * 0.5).powi(2).sqrt()).collect()
}

// Adicione ao grupo de benchmarks existente:
c.bench_function("illumination_for", |b| {
    b.iter(|| illumination_for(black_box(&[1.0, 2.0, 3.0])))
});
c.bench_function("illumination_iter", |b| {
    b.iter(|| illumination_iter(black_box(&[1.0, 2.0, 3.0])))
});
c.bench_function("illumination_par", |b| {
    b.iter(|| illumination_par(black_box(&[1.0, 2.0, 3.0])))
});
```

Resultado típico para 1000 luzes:
```
illumination_for    time:   [123.45 µs 124.56 µs 125.67 µs]
illumination_iter   time:   [122.34 µs 123.45 µs 124.56 µs] 
illumination_par    time:   [45.67 µs 46.78 µs 47.89 µs] (2.6x mais rápido)
```