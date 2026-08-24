## Otimização de Cache Line

Considere este cenário: você tem uma estrutura `Particle` que representa partículas em uma simulação física. Cada partícula tem posição, velocidade e massa:

```rust
struct Particle {
    x: f64,
    y: f64,
    z: f64,
    vx: f64,
    vy: f64,
    vz: f64,
    mass: f64,
    charge: f64,
    id: u64,
    metadata: String, // Descrição textual
}
```

Ao iterar sobre um vetor de partículas para atualizar posições (usando apenas `x`, `y`, `z`, `vx`, `vy`, `vz`), o código carrega todos os campos na cache line, mesmo os não utilizados. Isso é desperdício de banda de memória e espaço no cache.

### O Problema do False Sharing

Em CPUs modernas, o cache é organizado em linhas de tipicamente 64 bytes. Quando dois núcleos acessam variáveis diferentes na mesma cache line, ocorre o "false sharing" - a CPU é forçada a sincronizar o acesso mesmo quando as variáveis são independentes.

Veja este exemplo com contadores paralelos:

```rust
use std::sync::atomic::{AtomicU64, Ordering};
use std::thread;

struct Counters {
    a: AtomicU64,
    b: AtomicU64,
}

let counters = Counters {
    a: AtomicU64::new(0),
    b: AtomicU64::new(0),
};

thread::scope(|s| {
    s.spawn(|| {
        for _ in 0..1_000_000 {
            counters.a.fetch_add(1, Ordering::Relaxed);
        }
    });
    s.spawn(|| {
        for _ in 0..1_000_000 {
            counters.b.fetch_add(1, Ordering::Relaxed);
        }
    });
});
```

Os contadores `a` e `b` estão na mesma cache line, causando contenção desnecessária. Um benchmark mostra:

```
Atomic counters (compactos): 12.4ms
Atomic counters (alinhados): 6.2ms
```

### Solução: Padding e Alinhamento

Em Rust, usamos `#[repr(C)]` com `align` para controlar o layout:

```rust
#[repr(C, align(64))]
struct AlignedCounters {
    a: AtomicU64,
    _pad1: [u8; 56],
    b: AtomicU64,
    _pad2: [u8; 56],
}
```

Isso força cada contador para uma cache line separada. O padding é calculado como:
- Tamanho da cache line (64) - tamanho do tipo (8) = 56 bytes

### Hot/Cold Splitting

Para estruturas com campos frequentemente acessados ("hot") e raramente usados ("cold"), separamos em estruturas distintas:

```rust
struct ParticleHot {
    x: f64,
    y: f64,
    z: f64,
    vx: f64,
    vy: f64,
    vz: f64,
}

struct ParticleCold {
    mass: f64,
    charge: f64,
    id: u64,
    metadata: String,
}

struct ParticleSystem {
    hot: Vec<ParticleHot>,
    cold: Vec<ParticleCold>,
}
```

Isso melhora a localidade espacial para operações comuns. Um benchmark de atualização de posição mostra:

```
Estrutura original: 145ns/partícula
Hot/cold split: 89ns/partícula
```

### Verificação do Layout

Use `std::mem::size_of` e `align_of` para validar:

```rust
println!("Size: {}, Align: {}", 
    std::mem::size_of::<AlignedCounters>(),
    std::mem::align_of::<AlignedCounters>());
// Saída: Size: 128, Align: 64
```

### Arrays de Estruturas vs. Estruturas de Arrays

Em simulações, prefira "Structure of Arrays" (SoA) sobre "Array of Structures" (AoS):

```rust
// AoS (pior para SIMD/cache)
struct Particle { x: f64, y: f64, z: f64 }
struct System { particles: Vec<Particle> }

// SoA (melhor)
struct System {
    x: Vec<f64>,
    y: Vec<f64>,
    z: Vec<f64>,
}
```

SoA permite:
- Acessos sequenciais eficientes
- Melhor vetorização (SIMD)
- Prefetching previsível

### Exercício Prático

Converta esta estrutura para otimizar o uso de cache lines:

```rust
struct Customer {
    id: u64,
    active: bool,
    last_purchase: f64,
    history: Vec<Transaction>,
    name: String,
    discount: f64,
}
```

**Solução comentada:**

```rust
#[repr(C, align(64))]
struct CustomerHot {
    id: u64,
    active: bool,
    last_purchase: f64,
    discount: f64,
    // Padding para 64 bytes
    _pad: [u8; 64 - 8 - 1 - 8 - 8],
}

struct CustomerCold {
    history: Vec<Transaction>,
    name: String,
}

struct CustomerSystem {
    hot: Vec<CustomerHot>,
    cold: Vec<CustomerCold>,
}
```

Princípios aplicados:
1. Separação hot/cold (dados frequentemente acessados vs. metadata)
2. Alinhamento para evitar false sharing
3. Padding explícito para preencher cache lines
4. Agrupamento de campos acessados em conjunto

Esta organização reduz as cache misses em operações como processamento de descontos ou busca por clientes ativos, onde apenas os campos "hot" são necessários.