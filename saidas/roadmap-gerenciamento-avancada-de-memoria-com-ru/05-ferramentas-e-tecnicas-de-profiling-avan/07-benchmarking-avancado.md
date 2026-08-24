## Benchmarking Avançado

Suponha que você otimizou seu código Rust para reduzir alocações de heap e agora quer medir o impacto real dessas mudanças. O módulo `std::time::Instant` fornece medições básicas, mas para análises de memória precisas e comparações estatísticas, precisamos de ferramentas especializadas.

### Criterion.rs: Benchmarking Estatístico

O Criterion.rs é a ferramenta padrão para benchmarks em Rust, fornecendo:
- Medições estatísticas robustas (média, outliers, intervalos de confiança)
- Detecção automática de regressões de desempenho
- Relatórios em HTML com gráficos interativos

Um exemplo completo para testar alocação de vetores:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn allocate_vector(c: &mut Criterion) {
    c.bench_function("allocate 1KB", |b| {
        b.iter(|| {
            let mut vec = Vec::with_capacity(1024);
            for i in 0..1024 {
                vec.push(i as u8);
            }
            black_box(vec);
        });
    });
}

criterion_group!(benches, allocate_vector);
criterion_main!(benches);
```

Adicione ao `Cargo.toml`:
```toml
[dev-dependencies]
criterion = "0.4"

[[bench]]
name = "my_benchmark"
harness = false
```

Execute com:
```bash
cargo bench
```

Saída típica:
```
allocate 1KB          time:   [1.234 µs 1.456 µs 1.678 µs]
```

O Criterion executa múltiplas iterações, aquecendo o cache antes de medir. O `black_box` impede otimizações que eliminariam o código.

### Comparando Estratégias de Alocação

Vamos comparar três métodos para criar uma matriz 100x100:

```rust
fn bench_matrix(c: &mut Criterion) {
    let mut group = c.benchmark_group("Matrix Creation");
    
    // Alocação única
    group.bench_function("single_allocation", |b| b.iter(|| {
        let matrix = vec![vec![0u32; 100]; 100];
        black_box(matrix);
    }));
    
    // Alocação com capacidade pré-definida
    group.bench_function("pre_allocated", |b| b.iter(|| {
        let mut matrix = Vec::with_capacity(100);
        for _ in 0..100 {
            matrix.push(vec![0u32; 100]);
        }
        black_box(matrix);
    }));
    
    // Matriz plana
    group.bench_function("flat_matrix", |b| b.iter(|| {
        let matrix = vec![0u32; 100 * 100];
        black_box(matrix);
    }));
}
```

Resultados esperados:
```
Matrix Creation/single_allocation
                        time:   [125.45 µs 126.78 µs 128.10 µs]
Matrix Creation/pre_allocated
                        time:   [98.23 µs 99.56 µs 100.89 µs]  
Matrix Creation/flat_matrix
                        time:   [12.34 µs 12.56 µs 12.78 µs]
```

A versão plana é ~10x mais rápida por evitar alocações múltiplas e melhorar localidade de cache.

### Benchmarks de Memória com `#[global_allocator]`

Para medir alocações totais, substitua o alocador padrão:

```rust
use std::alloc::System;
#[global_allocator]
static ALLOCATOR: TrackingAllocator = TrackingAllocator(System);

struct TrackingAllocator(std::alloc::System);

unsafe impl std::alloc::GlobalAlloc for TrackingAllocator {
    unsafe fn alloc(&self, layout: std::alloc::Layout) -> *mut u8 {
        ALLOC_COUNTER.fetch_add(layout.size(), std::sync::atomic::Ordering::SeqCst);
        self.0.alloc(layout)
    }
    // Implementar outros métodos necessários
}

static ALLOC_COUNTER: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
```

Modifique o benchmark:
```rust
fn bench_memory(c: &mut Criterion) {
    c.bench_function("memory_usage", |b| {
        ALLOC_COUNTER.store(0, Ordering::SeqCst);
        b.iter(|| {
            // Código testado
        });
        let bytes = ALLOC_COUNTER.load(Ordering::SeqCst);
        println!("Alocou {} bytes por iteração", bytes);
    });
}
```

### Erro Comum: Benchmarking em Debug Mode

Um erro frequente é esquecer de usar `--release`:
```bash
cargo bench --release  # Correto
cargo bench            # INCORRETO - Debug mode é até 100x mais lento
```

Se você vir tempos absurdamente altos como:
```
allocate 1KB          time:   [450.78 µs 467.89 µs 485.00 µs]
```
Verifique imediatamente se está no modo release.

### Exercício Prático

Implemente e compare três versões de um buffer circular:
1. Usando `VecDeque`
2. Usando um `Vec` com índices manuais
3. Usando um array de tamanho fixo com `MaybeUninit`

Solução comentada:

```rust
use criterion::{black_box, Criterion};
use std::collections::VecDeque;
use std::mem::MaybeUninit;

pub fn bench_circular_buffers(c: &mut Criterion) {
    let mut group = c.benchmark_group("Circular Buffer");
    const SIZE: usize = 1024;
    
    // Versão 1: VecDeque
    group.bench_function("vec_deque", |b| b.iter(|| {
        let mut buf = VecDeque::with_capacity(SIZE);
        for i in 0..SIZE {
            buf.push_back(i);
            if buf.len() > SIZE { buf.pop_front(); }
        }
        black_box(buf);
    }));
    
    // Versão 2: Vec + índices
    group.bench_function("vec_manual", |b| b.iter(|| {
        let mut buf = Vec::with_capacity(SIZE);
        let mut pos = 0;
        for i in 0..SIZE {
            if buf.len() < SIZE {
                buf.push(i);
            } else {
                buf[pos] = i;
            }
            pos = (pos + 1) % SIZE;
        }
        black_box(buf);
    }));
    
    // Versão 3: Array estático
    group.bench_function("array_static", |b| b.iter(|| {
        let mut buf: [MaybeUninit<usize>; SIZE] = unsafe { MaybeUninit::uninit().assume_init() };
        let mut pos = 0;
        for i in 0..SIZE {
            buf[pos] = MaybeUninit::new(i);
            pos = (pos + 1) % SIZE;
        }
        black_box(buf);
    }));
}
```

Resultado esperado:
- `VecDeque`: Mais lento por verificação de limites
- `Vec` manual: 1.5-2x mais rápido que VecDeque
- Array estático: 3-5x mais rápido, zero alocações após a inicialização