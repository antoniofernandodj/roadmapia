## Benchmarking Simples em Rust

Quando otimizamos código Rust, precisamos de dados concretos para tomar decisões. Adivinhar onde estão os gargalos de desempenho é uma receita para otimizações erradas. O crate `test` da biblioteca padrão oferece um sistema de benchmarking simples mas poderoso para comparar implementações.

Vamos começar com um problema real: você implementou uma função que processa strings e suspeita que sua versão atual faz alocações desnecessárias. Como medir isso corretamente?

### Configurando um Benchmark Básico

Primeiro, crie um novo projeto e modifique o `Cargo.toml`:

```toml
[dev-dependencies]
test = "0.0.0"
```

Agora, no arquivo `benches/string_processing.rs`:

```rust
#![feature(test)]
extern crate test;

use test::Bencher;

fn process_string_naive(s: &str) -> String {
    let mut result = String::new();
    for c in s.chars() {
        if c.is_alphabetic() {
            result.push(c.to_ascii_uppercase());
        }
    }
    result
}

#[bench]
fn bench_naive(b: &mut Bencher) {
    let sample = "a1b2c3d4e5f6g7h8i9j0";
    b.iter(|| process_string_naive(sample));
}
```

Execute com:
```bash
cargo bench
```

Você verá uma saída como:
```
running 1 test
test bench_naive ... bench:         127 ns/iter (+/- 12)
```

### Entendendo os Resultados

A saída mostra:
- `127 ns/iter`: Tempo médio por iteração em nanossegundos
- `+/- 12`: Margem de erro

Erro comum: esquecer de usar `black_box` para evitar otimizações indesejadas. Veja o que acontece se omitirmos:

```rust
#[bench]
fn bench_naive_problem(b: &mut Bencher) {
    b.iter(|| process_string_naive("a1b2c3d4e5f6g7h8i9j0"));
}
```

Resultado enganoso:
```
test bench_naive_problem ... bench:           0 ns/iter (+/- 0)
```

O compilador otimizou tudo! Corrija com:

```rust
#[bench]
fn bench_naive_correct(b: &mut Bencher) {
    let sample = test::black_box("a1b2c3d4e5f6g7h8i9j0");
    b.iter(|| process_string_naive(sample));
}
```

### Comparando Implementações

Agora vamos testar uma versão otimizada que evita alocações intermediárias:

```rust
fn process_string_optimized(s: &str) -> String {
    s.chars()
        .filter(|c| c.is_alphabetic())
        .map(|c| c.to_ascii_uppercase())
        .collect()
}

#[bench]
fn bench_optimized(b: &mut Bencher) {
    let sample = test::black_box("a1b2c3d4e5f6g7h8i9j0");
    b.iter(|| process_string_optimized(sample));
}
```

Resultados típicos:
```
test bench_naive        ... bench:         127 ns/iter (+/- 12)
test bench_optimized    ... bench:          98 ns/iter (+/- 8)
```

### Benchmarks com Estado Compartilhado

Para casos onde você precisa de estado inicial, use `bench::iter_batched`:

```rust
#[bench]
fn bench_with_setup(b: &mut Bencher) {
    b.iter_batched(
        || {
            // Setup code runs before each iteration
            let s = String::from("a1b2c3d4e5f6g7h8i9j0");
            test::black_box(s)
        },
        |s| {
            // Code being measured
            process_string_optimized(&s)
        },
        test::BatchSize::SmallInput,
    );
}
```

### Exercício Prático

Implemente e compare duas versões de uma função que soma os quadrados dos números pares em um vetor:

1. Versão com `filter` e `map`
2. Versão com loop explícito

Solução comentada:

```rust
fn sum_squares_filter(numbers: &[i32]) -> i32 {
    numbers.iter()
        .filter(|&n| n % 2 == 0)
        .map(|&n| n * n)
        .sum()
}

fn sum_squares_loop(numbers: &[i32]) -> i32 {
    let mut sum = 0;
    for &n in numbers {
        if n % 2 == 0 {
            sum += n * n;
        }
    }
    sum
}

#[bench]
fn bench_filter(b: &mut Bencher) {
    let nums = test::black_box(vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    b.iter(|| sum_squares_filter(&nums));
}

#[bench]
fn bench_loop(b: &mut Bencher) {
    let nums = test::black_box(vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    b.iter(|| sum_squares_loop(&nums));
}
```

Resultados típicos mostram que a versão com loop geralmente é mais rápida (15-20%) por evitar a sobrecarga dos iteradores, mas a diferença depende do contexto e do tamanho dos dados.