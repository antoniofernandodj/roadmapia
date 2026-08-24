## Profiling Básico

Quando sua aplicação gráfica começa a travar ou não atinge o framerate desejado, você precisa descobrir onde o tempo está sendo gasto. O Rust oferece ferramentas simples mas poderosas para identificar esses gargalos sem precisar de configuração complexa.

Vamos começar com um exemplo real de uma função que processa partículas em um sistema de efeitos visuais:

```rust
use std::time::Instant;

struct Particle {
    x: f32,
    y: f32,
    velocity_x: f32,
    velocity_y: f32,
    life: f32,
}

fn update_particles(particles: &mut Vec<Particle>) {
    for p in particles.iter_mut() {
        p.x += p.velocity_x;
        p.y += p.velocity_y;
        p.life -= 0.01;
        
        // Cálculo custoso desnecessário
        let _distance = (p.x.powi(2) + p.y.powi(2)).sqrt();
    }
}

fn main() {
    let mut particles = vec![];
    for i in 0..10_000 {
        particles.push(Particle {
            x: i as f32,
            y: i as f32,
            velocity_x: 0.1,
            velocity_y: 0.1,
            life: 1.0,
        });
    }

    let start = Instant::now();
    update_particles(&mut particles);
    let duration = start.elapsed();
    
    println!("Tempo de execução: {:?}", duration);
}
```

Ao executar, você verá algo como:
```
Tempo de execução: 1.234ms
```

Mas esse número isolado não diz muito. Vamos melhorar a medição com o crate `criterion`, o padrão para benchmarks em Rust. Adicione ao Cargo.toml:

```toml
[dev-dependencies]
criterion = "0.4"
```

Crie um arquivo `benches/particles.rs`:

```rust
use criterion::{criterion_group, criterion_main, Criterion};
use your_crate::update_particles;

fn benchmark_particles(c: &mut Criterion) {
    let mut particles = vec![];
    for i in 0..10_000 {
        particles.push(Particle {
            x: i as f32,
            y: i as f32,
            velocity_x: 0.1,
            velocity_y: 0.1,
            life: 1.0,
        });
    }

    c.bench_function("update_particles", |b| {
        b.iter(|| update_particles(&mut particles))
    });
}

criterion_group!(benches, benchmark_particles);
criterion_main!(benches);
```

Execute com `cargo bench`. O output mostrará estatísticas detalhadas:

```
update_particles time:   [1.123 ms 1.134 ms 1.146 ms]
```

Agora vamos identificar o gargalo com o profiler nativo do Linux, `perf`:

```bash
perf record --call-graph dwarf cargo run --release
perf report
```

No relatório, você verá que a maior parte do tempo é gasta no cálculo da distância (`.powi(2)` e `.sqrt()`), que neste exemplo é completamente desnecessário.

Para profiling mais detalhado, instale o `flamegraph`:

```bash
cargo install flamegraph
```

Gere um flamegraph com:

```bash
cargo flamegraph
```

O gráfico mostrará visualmente onde o tempo está sendo consumido. No nosso caso, confirmará que o cálculo da distância é o vilão.

Vamos corrigir removendo o cálculo desnecessário:

```rust
fn update_particles(particles: &mut Vec<Particle>) {
    for p in particles.iter_mut() {
        p.x += p.velocity_x;
        p.y += p.velocity_y;
        p.life -= 0.01;
        // Removido: cálculo de distância inútil
    }
}
```

Após a correção, o novo benchmark mostra:

```
update_particles time:   [0.456 ms 0.459 ms 0.462 ms]
```

Ganhamos mais que 50% de performance com uma simples alteração!

**Erro comum:** esquecer de compilar com otimizações (`--release`). Sem isso, os resultados serão irreais:

```bash
cargo run   # Debug: 15.678 ms
cargo run --release  # Release: 1.134 ms
```

**Exercício:** Adicione um campo `color: [f32; 4]` à struct `Particle` e modifique `update_particles` para escurecer gradualmente as partículas conforme sua vida diminui. Meça o impacto no desempenho usando `criterion` e identifique se a nova operação se tornou um gargalo.

**Solução comentada:**

```rust
struct Particle {
    x: f32,
    y: f32,
    velocity_x: f32,
    velocity_y: f32,
    life: f32,
    color: [f32; 4],
}

fn update_particles(particles: &mut Vec<Particle>) {
    for p in particles.iter_mut() {
        p.x += p.velocity_x;
        p.y += p.velocity_y;
        p.life -= 0.01;
        p.color[3] = p.life; // Alpha proporcional à vida
    }
}

// Benchmark mostrará que a operação adicional tem impacto mínimo (~0.01ms)
// pois acessos a arrays são muito eficientes em Rust otimizado
```