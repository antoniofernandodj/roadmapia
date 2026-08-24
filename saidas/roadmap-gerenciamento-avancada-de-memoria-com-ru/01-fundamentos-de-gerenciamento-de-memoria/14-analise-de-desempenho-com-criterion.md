## Análise de Desempenho com Criterion

Quando você precisa otimizar o desempenho de um trecho de código Rust, adivinhar onde estão os gargalos é uma estratégia ruim. O Criterion.rs é uma ferramenta de benchmarking estatístico que fornece medições precisas e detecta pequenas melhorias de desempenho que outros métodos perdem.

Vamos começar com um problema concreto: você implementou uma função que processa strings e suspeita que está fazendo alocações desnecessárias. Como medir isso cientificamente?

Primeiro, adicione o Criterion ao seu `Cargo.toml`:

```toml
[dev-dependencies]
criterion = "0.4"

[[bench]]
name = "my_benchmark"
harness = false
```

Crie um arquivo `benches/my_benchmark.rs` com este conteúdo mínimo:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn process_string(input: &str) -> String {
    // Simula um processamento custoso
    input.to_uppercase().chars().rev().collect()
}

fn benchmark(c: &mut Criterion) {
    c.bench_function("process_string", |b| {
        b.iter(|| process_string(black_box("hello world")))
    });
}

criterion_group!(benches, benchmark);
criterion_main!(benches);
```

Execute com `cargo bench`. Você verá uma saída detalhada como:

```
process_string          time:   [1.2345 µs 1.3456 µs 1.4567 µs]
```

O Criterion executa o código repetidamente, medindo o tempo com precisão nanossegundo e aplicando análise estatística. O `black_box` impede que o compilador otimize o código de forma irrelevante para o benchmark.

### Entendendo a Saída

A linha `time: [1.2345 µs 1.3456 µs 1.4567 µs]` mostra:
- Valor mínimo (melhor caso)
- Média (estimativa central)
- Máximo (pior caso)

O Criterion também gera:
1. Gráficos HTML em `target/criterion/report/index.html`
2. Dados brutos para análise posterior
3. Detecção automática de regressões entre execuções

### Comparando Implementações

Suponha que você queira testar duas versões de uma função:

```rust
fn version1(input: &str) -> String {
    input.chars().filter(|c| c.is_alphabetic()).collect()
}

fn version2(input: &str) -> String {
    let mut result = String::with_capacity(input.len());
    for c in input.chars() {
        if c.is_alphabetic() {
            result.push(c);
        }
    }
    result
}

fn compare_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("Filter Compare");
    
    group.bench_function("version1", |b| {
        b.iter(|| version1(black_box("a1b2c3d4")))
    });
    
    group.bench_function("version2", |b| {
        b.iter(|| version2(black_box("a1b2c3d4")))
    });
    
    group.finish();
}
```

A saída mostrará claramente qual versão é mais rápida, com significância estatística. O `String::with_capacity` na versão 2 evita realocações, o que geralmente a torna mais eficiente.

### Erro Comum e Correção

Um erro frequente é esquecer o `black_box`, permitindo que o compilador otimize demais:

```rust
// ERRADO - otimização inválida
b.iter(|| process_string("hello world")) 

// CERTO - previne otimização
b.iter(|| process_string(black_box("hello world")))
```

Sem o `black_box`, o compilador pode substituir a chamada por um resultado pré-computado, invalidando seu benchmark.

### Benchmarking com Dados Externos

Para testar com dados mais realistas, carregue um dataset real:

```rust
fn large_input_benchmark(c: &mut Criterion) {
    let text = std::fs::read_to_string("large_text.txt").unwrap();
    
    c.bench_function("process_large_text", |b| {
        b.iter(|| process_string(black_box(&text)))
    });
}
```

Isso revela como o código se comporta com inputs maiores, onde alocações e cache locality têm maior impacto.

### Exercício Prático

Implemente e compare três versões de uma função que conta palavras em uma string:
1. Usando `split_whitespace().count()`
2. Com um loop manual e contador
3. Usando iteradores com `filter` e `fold`

Meça o desempenho com Criterion e explique os resultados. Considere strings pequenas (10 palavras) e grandes (10.000 palavras).

**Solução comentada:**

```rust
fn count_words_split(s: &str) -> usize {
    s.split_whitespace().count()
}

fn count_words_loop(s: &str) -> usize {
    let mut count = 0;
    let mut in_word = false;
    
    for c in s.chars() {
        if c.is_whitespace() {
            in_word = false;
        } else if !in_word {
            in_word = true;
            count += 1;
        }
    }
    count
}

fn count_words_fold(s: &str) -> usize {
    s.chars()
        .fold((0, false), |(count, in_word), c| {
            if c.is_whitespace() {
                (count, false)
            } else if !in_word {
                (count + 1, true)
            } else {
                (count, in_word)
            }
        })
        .0
}

fn word_count_benchmark(c: &mut Criterion) {
    let small = "a b c d e f g h i j";
    let large = "word ".repeat(10_000);
    
    let mut group = c.benchmark_group("Word Count");
    
    group.bench_function("split_small", |b| b.iter(|| count_words_split(black_box(small))));
    group.bench_function("loop_small", |b| b.iter(|| count_words_loop(black_box(small))));
    group.bench_function("fold_small", |b| b.iter(|| count_words_fold(black_box(small))));
    
    group.bench_function("split_large", |b| b.iter(|| count_words_split(black_box(&large))));
    group.bench_function("loop_large", |b| b.iter(|| count_words_loop(black_box(&large))));
    group.bench_function("fold_large", |b| b.iter(|| count_words_fold(black_box(&large))));
    
    group.finish();
}
```

Resultados típicos mostram:
- Para strings pequenas: `split_whitespace` é mais lento devido ao overhead de criação do iterator
- Para strings grandes: a versão com loop manual geralmente vence por evitar alocações intermediárias
- A versão `fold` fica no meio-termo, mostrando como diferentes abordagens têm tradeoffs distintos