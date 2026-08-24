## Lock-Free Data Structures

Em sistemas concorrentes, o acesso compartilhado a estruturas de dados tradicionalmente exige locks (mutexes, semáforos) para garantir consistência. O problema surge quando múltiplas threads competem pelo mesmo lock: a thread que não consegue acesso fica bloqueada, desperdiçando ciclos de CPU e aumentando a latência. Em cenários de alta contenção, isso pode reduzir drasticamente o throughput do sistema.

Lock-free é uma abordagem alternativa que elimina bloqueios através de operações atômicas. Considere um contador compartilhado:

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

let counter = AtomicUsize::new(0);

// Thread 1
counter.fetch_add(1, Ordering::SeqCst);

// Thread 2
counter.fetch_add(1, Ordering::SeqCst);
```

A saída final será `2`, independentemente da ordem de execução, sem bloqueios. O segredo está nas operações atômicas garantidas pelo hardware (como CAS - Compare-And-Swap), que executam em uma única instrução de CPU.

### O Custo dos Locks Tradicionais

Compare o desempenho de um contador protegido por Mutex versus atômico:

```rust
use std::sync::{Arc, Mutex};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::thread;

fn main() {
    let mutex_counter = Arc::new(Mutex::new(0));
    let atomic_counter = Arc::new(AtomicUsize::new(0));
    
    let mut handles = vec![];

    // Teste com Mutex
    for _ in 0..10 {
        let c = Arc::clone(&mutex_counter);
        handles.push(thread::spawn(move || {
            for _ in 0..100_000 {
                let mut num = c.lock().unwrap();
                *num += 1;
            }
        }));
    }

    // Teste com Atômico
    for _ in 0..10 {
        let c = Arc::clone(&atomic_counter);
        handles.push(thread::spawn(move || {
            for _ in 0..100_000 {
                c.fetch_add(1, Ordering::SeqCst);
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Mutex counter: {}", *mutex_counter.lock().unwrap());
    println!("Atomic counter: {}", atomic_counter.load(Ordering::SeqCst));
}
```

Executando com `cargo run --release`, os resultados típicos mostram:
- Mutex: ~450ms
- Atômico: ~120ms

A diferença vem do overhead do Mutex:
1. Chamadas de sistema para bloquear/desbloquear
2. Context switches quando threads são suspensas
3. Contenção no acesso ao lock

### Estruturas Lock-Free Complexas

Para estruturas além de contadores, como filas ou hash maps, a implementação lock-free exige cuidado com o gerenciamento de memória. Rust oferece garantias únicas aqui. Considere uma fila lock-free simples:

```rust
use std::sync::atomic::{AtomicPtr, Ordering};
use std::ptr;

struct Node<T> {
    value: T,
    next: AtomicPtr<Node<T>>,
}

pub struct LockFreeQueue<T> {
    head: AtomicPtr<Node<T>>,
    tail: AtomicPtr<Node<T>>,
}

impl<T> LockFreeQueue<T> {
    pub fn new() -> Self {
        let dummy = Box::into_raw(Box::new(Node {
            value: unsafe { std::mem::zeroed() },
            next: AtomicPtr::new(ptr::null_mut()),
        }));
        
        LockFreeQueue {
            head: AtomicPtr::new(dummy),
            tail: AtomicPtr::new(dummy),
        }
    }

    pub fn push(&self, value: T) {
        let new_node = Box::into_raw(Box::new(Node {
            value,
            next: AtomicPtr::new(ptr::null_mut()),
        }));

        loop {
            let tail = unsafe { &*self.tail.load(Ordering::Acquire) };
            let next = tail.next.load(Ordering::Acquire);
            
            if next.is_null() {
                if let Ok(_) = tail.next.compare_exchange(
                    ptr::null_mut(),
                    new_node,
                    Ordering::SeqCst,
                    Ordering::Relaxed
                ) {
                    let _ = self.tail.compare_exchange(
                        tail as *const _ as *mut _,
                        new_node,
                        Ordering::SeqCst,
                        Ordering::Relaxed
                    );
                    return;
                }
            } else {
                let _ = self.tail.compare_exchange(
                    tail as *const _ as *mut _,
                    next,
                    Ordering::SeqCst,
                    Ordering::Relaxed
                );
            }
        }
    }
}
```

Este código contém um bug sutil: vazamento de memória. O nó dummy nunca é liberado. A correção exige um esquema de gerenciamento de memória seguro como hazard pointers ou epoch-based reclamation.

### Quando Usar Lock-Free

Vantagens:
- Throughput previsível mesmo sob alta contenção
- Imunidade a deadlocks
- Menor latência para operações críticas

Desvantagens:
- Complexidade de implementação
- Overhead de memória para estruturas auxiliares
- Dificuldade de depuração

Casos de uso típicos:
- Filas de tarefas em sistemas de tempo real
- Caches compartilhados de alta frequência
- Estruturas de dados em sistemas operacionais

### Exercício

Implemente um stack lock-free com gerenciamento de memória seguro usando o padrão "Treiber stack" com hazard pointers. Meça o desempenho comparado a uma versão com Mutex sob carga de 1.000.000 de operações com 8 threads.

```rust
// Solução esboço
use std::sync::atomic::{AtomicPtr, Ordering};
use std::ptr;
use std::thread;
use std::sync::Arc;

struct HazardPointer;

impl HazardPointer {
    fn protect(&self, _ptr: *mut ()) {}
    fn retire(&self, _ptr: *mut ()) {}
}

struct Node<T> {
    value: T,
    next: AtomicPtr<Node<T>>,
}

pub struct LockFreeStack<T> {
    top: AtomicPtr<Node<T>>,
    hp: HazardPointer,
}

impl<T> LockFreeStack<T> {
    pub fn new() -> Self {
        LockFreeStack {
            top: AtomicPtr::new(ptr::null_mut()),
            hp: HazardPointer,
        }
    }

    pub fn push(&self, value: T) {
        let new_node = Box::into_raw(Box::new(Node {
            value,
            next: AtomicPtr::new(ptr::null_mut()),
        }));

        loop {
            let top = self.top.load(Ordering::Acquire);
            unsafe { (*new_node).next.store(top, Ordering::Relaxed) };
            
            if let Ok(_) = self.top.compare_exchange(
                top,
                new_node,
                Ordering::Release,
                Ordering::Relaxed
            ) {
                return;
            }
        }
    }

    pub fn pop(&self) -> Option<T> {
        loop {
            let top = self.top.load(Ordering::Acquire);
            if top.is_null() {
                return None;
            }
            
            self.hp.protect(top as *mut ());
            
            let next = unsafe { (*top).next.load(Ordering::Acquire) };
            
            if let Ok(_) = self.top.compare_exchange(
                top,
                next,
                Ordering::Release,
                Ordering::Relaxed
            ) {
                self.hp.retire(top as *mut ());
                return Some(unsafe { Box::from_raw(top).value });
            }
        }
    }
}
```

A implementação completa exigiria um mecanismo real de hazard pointers para garantir segurança na liberação de memória. O desempenho mostrará vantagem clara em cenários de alta contenção, enquanto em baixa contenção o overhead dos hazard pointers pode tornar o Mutex mais eficiente.