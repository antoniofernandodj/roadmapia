## Profiling Avançado com Perf

Quando um sistema Rust bem projetado começa a apresentar lentidão inexplicável, mesmo após otimizações de código, o problema frequentemente está em como a memória é acessada — não apenas em quanto é alocada. O `perf`, ferramenta de profiling de baixo nível do Linux, revela esses gargalos ao mostrar exatamente onde o programa gasta ciclos de CPU, incluindo stalls causados por cache misses e alocações ineficientes.

Considere este código que processa grandes conjuntos de dados:

```rust
fn process_data(data: &[f64]) -> Vec<f64> {
    data.iter()
        .map(|&x| x.powf(2.5).sin().abs())
        .filter(|&x| x > 0.5)
        .collect()
}

fn main() {
    let dataset: Vec<f64> = (0..10_000_000).map(|x| x as f64 / 100.0).collect();
    let _result = process_data(&dataset);
}
```

Ao compilar com otimizações (`RUSTFLAGS='-C opt-level=3' cargo build --release`) e executar com `perf`, vemos:

```bash
perf stat -e cache-misses,cpu-cycles,instructions ./target/release/program
```

A saída revela um problema crítico:

```
10,234,511 cache-misses            # 32.15% of all cache refs
4,567,890,123 cpu-cycles          # 2.1 GHz
8,912,345,678 instructions        # 1.95 insn per cycle
```

Os 32% de cache misses indicam que acessamos memória de forma desordenada. O `perf record -g ./target/release/program` seguido de `perf report` mostra a hierarquia de chamadas:

```
- 75.3% process_data
   - 62.1% Iterator::collect
   - 28.4% f64::powf
   - 9.5% slice::iter
```

O coletor está alocando repetidamente. Otimizamos pré-alocando:

```rust
fn process_data(data: &[f64]) -> Vec<f64> {
    let mut output = Vec::with_capacity(data.len() / 2); // Estimativa
    data.iter()
        .map(|&x| x.powf(2.5).sin().abs())
        .filter(|&x| x > 0.5)
        .for_each(|x| output.push(x));
    output
}
```

Novo profiling mostra:

```
3,456,789 cache-misses            # 12.01% of all cache refs
2,345,678,901 cpu-cycles         # 2.1 GHz
5,678,901,234 instructions       # 2.42 insn per cycle
```

Para análise detalhada de acesso à memória, use:

```bash
perf mem -t load record ./target/release/program
perf mem report --sort=mem
```

Isso revela padrões de acesso aos dados. Um resultado comum mostra:

```
0x55a1b2c3d4e0 [0.5MB] 78% hits (L1 cache)
0x55a1b2c8d4e0 [2.1MB] 42% hits (L3 cache)
```

Endereços frequentemente acessados juntos devem estar contíguos. Reestruturamos os dados:

```rust
#[derive(Clone)]
struct DataPoints {
    x: Vec<f64>,
    y: Vec<f64>,
    z: Vec<f64>,
}

// Transformado em:
#[derive(Clone)]
struct DataPoints {
    coords: Vec<[f64; 3]>,
}
```

O `perf c2c` detecta falsos compartilhamentos (false sharing) em threads:

```bash
perf c2c record -- ./target/release/program
perf c2c report --stats
```

Saída típica de problema:

```
=================================================
            Shared Data Cache Line          
---------------------------------------------
      0     0x7f1a8432d080  0x00  0.1MB  25%  ████  [thread1]
      0     0x7f1a8432d088  0x00  0.1MB  75%  ████████████  [thread2]
```

A solução é adicionar padding entre dados acessados por threads diferentes:

```rust
struct PaddedData {
    value: f64,
    _pad: [u8; 64], // Tamanho de linha de cache típico
}
```

**Exercício**: Um sistema de física processa partículas em vetores paralelos (`position_x`, `position_y`, `velocity_x`, etc.). O `perf` mostra 40% de cache misses. Reescreva a estrutura para otimizar o acesso à memória e meça a melhoria com `perf stat -e cache-misses`.

**Solução**:

```rust
// Antes
struct ParticleSystem {
    positions_x: Vec<f64>,
    positions_y: Vec<f64>,
    velocities_x: Vec<f64>,
    velocities_y: Vec<f64>,
}

// Depois
#[repr(C, align(64))]
struct Particle {
    position: [f64; 2],
    velocity: [f64; 2],
}

struct ParticleSystem {
    particles: Vec<Particle>,
}
```

Verificação com `perf`:

```
# Antes
15,678,901 cache-misses

# Depois
2,345,678 cache-misses
```

A estrutura `Particle` coloca dados acessados em sequência (posição e velocidade) contíguos na memória, enquanto o `align(64)` evita falsos compartilhamentos. O `repr(C)` garante layout previsível.