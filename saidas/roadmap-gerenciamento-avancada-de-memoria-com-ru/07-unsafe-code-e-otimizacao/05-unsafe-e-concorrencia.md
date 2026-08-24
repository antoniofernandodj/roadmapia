## Unsafe e Concorrência

Considere um sistema de processamento de pagamentos que precisa atualizar saldos de contas em paralelo com a máxima performance. Em Rust seguro, você usaria `Mutex<Account>` ou canais para sincronização, mas e se precisar cortar os 20ns de overhead do mutex em operações de alta frequência? Unsafe parece a solução, mas esconde um campo minado.

### O Problema Concreto: Atualização Não-Atomica

Este código tenta incrementar um contador compartilhado sem locks, usando raw pointers:

```rust
use std::thread;

fn main() {
    let mut counter = 0;
    let ptr = &mut counter as *mut i32;
    
    let handles: Vec<_> = (0..10).map(|_| {
        thread::spawn(move || unsafe {
            for _ in 0..1000 {
                *ptr += 1; // ⚠️ COMPORTAMENTO INDEFINIDO
            }
        })
    }).collect();

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Resultado: {}", counter); // Raramente 10000
}
```

Ao executar, você verá valores inconsistentes como `7348` ou `9512`. O motivo? O compilador e o CPU reordenam instruções quando otimizam, e threads simultâneas podem sobrescrever umas às outras. O assembly gerado pode parecer:

```asm
; Thread 1         | ; Thread 2
mov eax, [ptr]     | mov eax, [ptr]
inc eax            | inc eax
mov [ptr], eax     | mov [ptr], eax
```

### Data Races em Unsafe

Rust previne data races em tempo de compilação, mas `unsafe` desativa esses verificadores. Os erros comuns são:

1. **Não-Atomicidade**: Operações que deveriam ser indivisíveis são quebradas
2. **Reordenação**: O compilador troca a ordem de operações não-dependentes
3. **Visibilidade**: Mudanças podem ficar em cache de CPU e não ser vistas por outras threads

Veja o diagnóstico do MIRI (ferramenta de verificação de unsafe):

```
error: Data race detected between Write on Thread(id = 2) and Read on Thread(id = 1)
```

### Consertando com Atomics

Para operações thread-safe sem mutex, use tipos atômicos:

```rust
use std::sync::atomic::{AtomicI32, Ordering};

let counter = AtomicI32::new(0);
let handles: Vec<_> = (0..10).map(|_| {
    thread::spawn(move || {
        for _ in 0..1000 {
            counter.fetch_add(1, Ordering::SeqCst);
        }
    })
}).collect();
```

Isso gera instruções atômicas como `lock xadd` no x86. O `Ordering::SeqCst` garante ordem sequencial consistente.

### Quando Unsafe é Necessário em Concorrência

Há casos onde atomics não bastam, como estruturas lock-free complexas. Este deque concorrente seguro usa unsafe internamente:

```rust
struct Node<T> {
    data: T,
    next: *mut Node<T>, // Raw pointer requer unsafe
}

impl<T> Node<T> {
    unsafe fn push(&mut self, value: T) {
        let new_node = Box::into_raw(Box::new(Node {
            data: value,
            next: std::ptr::null_mut(),
        }));
        (*self.next).next = new_node;
    }
}
```

Mesmo aqui, a regra é clara: **toda interação concorrente deve ser encapsulada em uma API segura**. O módulo `std::sync::atomic` faz exatamente isso.

### Exercício: Buffer Circular Concorrente

Implemente um buffer circular concorrente com put/get usando unsafe, depois reescreva com atomics. Compare os resultados após 1M de operações.

**Solução com Unsafe (Incorreta):**
```rust
struct CircularBuffer {
    data: *mut [u8; 1024],
    head: usize,
    tail: usize,
}
// ... operações diretas nos ponteiros
```

**Solução Atômica:**
```rust
struct CircularBuffer {
    data: Box<[AtomicU8; 1024]>,
    head: AtomicUsize,
    tail: AtomicUsize,
}
// ... usando fetch_add e compare_exchange
```

A versão unsafe falhará em testes de estresse, enquanto a atômica manterá a consistência mesmo sob contenção.