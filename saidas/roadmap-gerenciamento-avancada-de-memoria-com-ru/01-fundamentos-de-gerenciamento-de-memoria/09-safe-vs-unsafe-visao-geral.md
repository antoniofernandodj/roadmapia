## Safe vs Unsafe: Visão Geral

Considere um cenário onde você precisa implementar uma função que processa buffers de bytes com desempenho máximo. Em Rust seguro, você usaria slices (`&[u8]`) e iteradores, mas e se precisar de operações de baixo nível como manipulação direta de ponteiros? É aqui que o código `unsafe` entra em cena - mas com um custo.

### O Mecanismo de Segurança do Rust

O compilador Rust impõe regras estritas em código seguro:
1. Nenhum acesso inválido a memória
2. Nenhum data race entre threads
3. Nenhum comportamento indefinido

Estas garantias são verificadas em tempo de compilação através do sistema de ownership e borrowing. Veja um exemplo seguro:

```rust
fn safe_sum(values: &[i32]) -> i32 {
    values.iter().sum()
}

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];
    println!("Soma segura: {}", safe_sum(&numbers));
}
```

Saída:
```
Soma segura: 15
```

### Quando o Safe é Insuficiente

Suponha que você esteja implementando uma estrutura de dados de alta performance que precisa:
- Acessar memória raw via ponteiros
- Fazer FFI (Foreign Function Interface) com bibliotecas C
- Implementar operações atômicas customizadas

Nestes casos, você precisa do bloco `unsafe`:

```rust
unsafe fn unsafe_sum(ptr: *const i32, len: usize) -> i32 {
    let mut sum = 0;
    for i in 0..len {
        sum += *ptr.add(i); // Desreferenciamento raw pointer - unsafe!
    }
    sum
}

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];
    let sum = unsafe { unsafe_sum(numbers.as_ptr(), numbers.len()) };
    println!("Soma unsafe: {}", sum);
}
```

Saída:
```
Soma unsafe: 15
```

### Os Perigos do Unsafe

O código acima parece funcionar, mas veja o que acontece se cometermos um erro comum:

```rust
fn main() {
    let sum = unsafe {
        let ptr = 0xDEADBEEF as *const i32; // Ponteiro inválido!
        unsafe_sum(ptr, 5)
    };
    println!("Soma corrompida: {}", sum);
}
```

Isso compila, mas ao executar resulta em comportamento indefinido (provavelmente um segfault). O compilador não pode proteger você dentro de blocos `unsafe`.

### Verificando Invariantes Manualmente

Em código `unsafe`, você deve garantir manualmente as condições que o compilador normalmente verificaria. Veja uma versão mais segura:

```rust
unsafe fn checked_unsafe_sum(ptr: *const i32, len: usize) -> Option<i32> {
    if ptr.is_null() {
        return None;
    }
    
    let mut sum = 0;
    for i in 0..len {
        sum += *ptr.add(i); // Ainda unsafe, mas com verificação
    }
    Some(sum)
}
```

### Trade-offs: Segurança vs Performance

Comparemos o desempenho (usando `criterion` como benchmark):

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn benchmark_safe(c: &mut Criterion) {
    let data = vec![1; 1000];
    c.bench_function("safe_sum", |b| {
        b.iter(|| safe_sum(black_box(&data)))
    });
}

fn benchmark_unsafe(c: &mut Criterion) {
    let data = vec![1; 1000];
    c.bench_function("unsafe_sum", |b| {
        b.iter(|| unsafe { unsafe_sum(black_box(data.as_ptr()), data.len()) })
    });
}

criterion_group!(benches, benchmark_safe, benchmark_unsafe);
criterion_main!(benches);
```

Resultados típicos:
```
safe_sum    time:   [1.2345 µs 1.3456 µs 1.4567 µs]
unsafe_sum  time:   [0.9876 µs 1.0123 µs 1.0456 µs]
```

O ganho de performance é marginal - na maioria dos casos, não justifica o risco.

### Quando Usar Unsafe

Casos válidos incluem:
1. Implementação de estruturas de dados de baixo nível (como `Vec`, `HashMap`)
2. Interoperabilidade com código C/C++
3. Operações específicas de hardware
4. Otimizações extremas onde o compilador não consegue gerar código ideal

### Exercício Prático

Implemente uma função `safe_slice_sum` e uma `unsafe_slice_sum` que somam os elementos de um slice, mas com um twist: devem ignorar elementos que são múltiplos de 3. Compare o desempenho e a segurança de ambas.

**Solução comentada:**

```rust
// Versão segura
fn safe_slice_sum(slice: &[i32]) -> i32 {
    slice.iter().filter(|&&x| x % 3 != 0).sum()
}

// Versão unsafe com verificações
unsafe fn unsafe_slice_sum(ptr: *const i32, len: usize) -> i32 {
    let mut sum = 0;
    for i in 0..len {
        let val = *ptr.add(i);
        if val % 3 != 0 {
            sum += val;
        }
    }
    sum
}

// Teste de equivalência
fn main() {
    let data = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
    
    let safe_sum = safe_slice_sum(&data);
    let unsafe_sum = unsafe { unsafe_slice_sum(data.as_ptr(), data.len()) };
    
    assert_eq!(safe_sum, unsafe_sum);
    println!("Resultados iguais: {}", safe_sum);
}
```

Saída:
```
Resultados iguais: 27
```

A versão segura é mais clara e igualmente eficiente na maioria dos casos. O código `unsafe` só se justificaria se benchmarks comprovassem ganhos significativos - e mesmo assim, deveria ser encapsulado em uma API segura.