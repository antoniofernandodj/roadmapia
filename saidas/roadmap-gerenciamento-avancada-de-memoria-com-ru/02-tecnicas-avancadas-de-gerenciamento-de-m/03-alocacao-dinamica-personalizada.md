## Alocação Dinâmica Personalizada

O alocador padrão do Rust (`std::alloc::Global`) é eficiente para a maioria dos casos, mas sistemas com padrões específicos de alocação podem se beneficiar de um gerenciamento personalizado. Considere um servidor de rede que aloca milhares de buffers pequenos e de vida curta: o overhead do alocador global pode se tornar significativo.

### O Problema do Alocador Padrão

Veja este cenário comum:

```rust
fn process_packets() {
    let mut buffers = Vec::with_capacity(1000);
    
    for _ in 0..1000 {
        // Alocação frequente de buffers pequenos
        let buffer = vec![0u8; 128]; // 128 bytes por pacote
        buffers.push(buffer);
    }
    
    // Processamento...
}
```

Cada `Vec::new` ou `vec![]` aciona o alocador global, que:
1. Verifica threadsafety
2. Busca blocos livres
3. Potencialmente invoca chamadas do sistema (como `mmap` ou `sbrk`)

Para 1.000 pacotes, são 1.000 alocações individuais. Um benchmark simples mostra o impacto:

```rust
use std::time::Instant;

fn benchmark() {
    let start = Instant::now();
    
    for _ in 0..10_000 {
        let _ = vec![0u8; 128];
    }
    
    println!("Tempo: {:?}", start.elapsed());
}
```

Saída típica:
```
Tempo: 1.342ms
```

### Implementando um Allocator Básico

Rust permite substituir o alocador global ou usar alocadores específicos para coleções. Vamos criar um alocador de arena simples:

```rust
use std::alloc::{GlobalAlloc, Layout, System};
use std::ptr::{null_mut, NonNull};

struct ArenaAllocator;

unsafe impl GlobalAlloc for ArenaAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        System.alloc(layout) // Delegação simples para demonstração
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        System.dealloc(ptr, layout)
    }
}

#[global_allocator]
static GLOBAL: ArenaAllocator = ArenaAllocator;
```

Este é um wrapper inútil (apenas delega para o sistema), mas mostra a estrutura básica. Um alocador real implementaria estratégias como:

1. **Pré-alocação**: Reservar blocos grandes antecipadamente
2. **Bump allocation**: Ponteiro que só avança, sem liberação individual
3. **Free lists**: Listas de blocos liberados para reutilização

### Alocador de Arena com Pré-alocação

Vamos melhorar com uma arena que pré-aloca um bloco grande:

```rust
use std::cell::UnsafeCell;
use std::ptr;

const ARENA_SIZE: usize = 1024 * 1024; // 1MB

struct SimpleArena {
    memory: UnsafeCell<Box<[u8; ARENA_SIZE]>>,
    current: UnsafeCell<usize>,
}

unsafe impl Sync for SimpleArena {} // Seguro para threads (para este exemplo)

impl SimpleArena {
    fn new() -> Self {
        SimpleArena {
            memory: UnsafeCell::new(Box::new([0u8; ARENA_SIZE])),
            current: UnsafeCell::new(0),
        }
    }

    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let size = layout.size();
        let align = layout.align();

        let start = *self.current.get();
        let ptr = (*self.memory.get()).as_ptr() as usize + start;
        
        // Alinhamento
        let aligned_ptr = (ptr + align - 1) & !(align - 1);
        let actual_start = aligned_ptr - ((*self.memory.get()).as_ptr() as usize);
        
        if actual_start + size > ARENA_SIZE {
            ptr::null_mut() // Sem espaço
        } else {
            *self.current.get() = actual_start + size;
            aligned_ptr as *mut u8
        }
    }
}
```

Uso:

```rust
let arena = SimpleArena::new();
let layout = Layout::from_size_align(128, 8).unwrap();

unsafe {
    let ptr = arena.alloc(layout);
    if !ptr.is_null() {
        // Usar memória...
    }
}
```

### Integrando com Coleções Padrão

Desde o Rust 1.28, coleções podem usar alocadores customizados (feature `allocator_api`):

```rust
#![feature(allocator_api)]

use std::alloc::Allocator;

let arena = SimpleArena::new();
let mut vec = Vec::new_in(&arena as &dyn Allocator);

for i in 0..100 {
    vec.push(i); // Usa a arena para alocações
}
```

### Erro Comum: Subestimando Alinhamento

Um erro frequente é ignorar o alinhamento:

```rust
// Código problemático:
let ptr = (*self.memory.get()).as_ptr() as usize + *self.current.get();
*self.current.get() += size;
return ptr as *mut u8;
```

Isso falhará com:

```
thread 'main' panicked at 'assertion failed: `(left == right)`
  left: `16`,
 right: `8`: alignment error'
```

A correção está no exemplo completo anterior, que ajusta o ponteiro para o alinhamento requerido.

### Exercício Prático

**Problema**: Implemente um alocador "bump" que:
1. Pré-aloca 2MB
2. Mantém um contador interno
3. Implementa `Allocator` (não apenas `GlobalAlloc`)
4. Ignora pedidos de desalocação (arena limpa de uma vez)

**Solução**:

```rust
use std::alloc::{AllocError, Allocator, Layout};
use std::ptr::NonNull;

struct BumpAllocator {
    memory: Box<[u8; 2 * 1024 * 1024]>,
    next: usize,
}

unsafe impl Allocator for BumpAllocator {
    fn allocate(&self, layout: Layout) -> Result<NonNull<[u8]>, AllocError> {
        let size = layout.size();
        let align = layout.align();

        let start = self.next;
        let ptr = self.memory.as_ptr() as usize + start;
        let aligned_ptr = (ptr + align - 1) & !(align - 1);
        let actual_start = aligned_ptr - (self.memory.as_ptr() as usize);

        if actual_start + size > self.memory.len() {
            Err(AllocError)
        } else {
            // Em código real, usar AtomicUsize para thread safety
            unsafe { (*(&self.next as *const _ as *mut usize)) = actual_start + size; }
            
            let slice = unsafe {
                std::slice::from_raw_parts_mut(aligned_ptr as *mut u8, size)
            };
            Ok(unsafe { NonNull::new_unchecked(slice) })
        }
    }

    unsafe fn deallocate(&self, _ptr: NonNull<u8>, _layout: Layout) {
        // Bump allocator não libera memória individualmente
    }
}

// Uso:
fn main() {
    let alloc = BumpAllocator {
        memory: Box::new([0u8; 2 * 1024 * 1024]),
        next: 0,
    };

    let layout = Layout::new::<u64>();
    let ptr = alloc.allocate(layout).unwrap();
    
    // Escreve no ponteiro
    unsafe { *(ptr.cast().as_ptr()) = 42 };
    
    // Limpeza implícita quando `alloc` sai do escopo
}
```

**Pontos-chave**:
1. `Allocator` é mais flexível que `GlobalAlloc`
2. O alinhamento é crítico para tipos como `u64` que requerem 8 bytes
3. `NonNull<[u8]>` é o tipo de retorno esperado
4. A desalocação é intencionalmente um no-op (bump allocator)