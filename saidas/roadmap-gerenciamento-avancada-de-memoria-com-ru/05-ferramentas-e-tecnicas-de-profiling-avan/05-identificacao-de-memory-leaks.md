## Identificação de Memory Leaks

Memory leaks em Rust são mais raros que em linguagens sem sistema de ownership, mas ainda ocorrem quando mantemos referências a dados que nunca serão usados novamente. O problema aparece frequentemente em estruturas cíclicas usando `Rc`/`Weak` ou quando vazamos memória intencionalmente com `Box::leak`.

Vamos criar um vazamento proposital para demonstrar o diagnóstico:

```rust
use std::rc::Rc;

struct Node {
    value: i32,
    next: Option<Rc<Node>>,
}

fn create_cycle() -> Rc<Node> {
    let node1 = Rc::new(Node {
        value: 1,
        next: None,
    });
    
    let node2 = Rc::new(Node {
        value: 2,
        next: Some(Rc::clone(&node1)),
    });
    
    // Cria o ciclo - node1 aponta para node2
    let node1_mut = Rc::get_mut(&mut node1.clone()).unwrap();
    node1_mut.next = Some(Rc::clone(&node2));
    
    node1
}

fn main() {
    let _ = create_cycle();
    println!("Ciclo criado, memória vazando!");
}
```

Ao executar, o programa termina normalmente, mas a memória alocada para os nós nunca é liberada. Usando o Valgrind com Massif para detectar:

```bash
valgrind --tool=massif ./target/debug/nosso_programa
ms_print massif.out.12345 | less
```

A saída mostrará picos de memória alocada que nunca são liberados:

```
--------------------------------------------------------------------------------
  n        time(i)         total(B)   useful-heap(B) extra-heap(B)    stacks(B)
--------------------------------------------------------------------------------
  0              0                0                0             0            0
  1      1,000,000        1,048,576        1,048,576             0            0
  2      2,000,000        1,048,576        1,048,576             0            0
```

Para Rust nativo, instale e use o `dhat-rs` para profiling de heap:

```toml
[dependencies]
dhat = "0.3"
```

Modifique o código para incluir a instrumentação:

```rust
use dhat::{Dhat, DhatAlloc};

#[global_allocator]
static ALLOCATOR: DhatAlloc = DhatAlloc;

fn main() {
    let _dhat = Dhat::start_heap_profiling();
    let _ = create_cycle();
    println!("Verifique o arquivo dhat-heap.json");
}
```

Execute e examine o relatório:

```json
{
  "dhatFileVersion": 2,
  "mode": "heap",
  "verb": "allocated",
  "bklt": false,
  "bu": 1024,
  "bs": [
    {
      "ds": "1×alloc",
      "acc": 32,
      "re': 0,
      "ins': 0,
      "allocs': 1
    }
  ]
}
```

O relatório mostra alocações que não foram liberadas. Para detectar vazamentos em tempo de execução, adicione o `#[cfg(debug_assertions)]` com verificações:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    #[cfg(debug_assertions)]
    fn test_no_leaks() {
        let tracker = MemoryTracker::new();
        let _ = create_cycle();
        assert!(tracker.no_leaks(), "Memory leak detected!");
    }
}
```

Erros comuns incluem:
1. Esquecer de chamar `drop` em tipos customizados com recursos externos
2. Ciclos em estruturas `Rc` sem `Weak` para quebrar a referência
3. Vazamento de traits objects quando não usados corretamente

Para estruturas complexas, o `std::mem::forget` pode inibir o drop:

```rust
let data = vec![0u8; 1024 * 1024]; // 1MB
std::mem::forget(data); // Vazamento intencional
```

**Exercício**: Modifique o exemplo de ciclo para quebrar a referência usando `Weak` e verifique com `dhat-rs` que o vazamento foi resolvido.

**Solução**:

```rust
use std::rc::{Rc, Weak};

struct Node {
    value: i32,
    next: Option<Weak<Node>>,
}

fn create_repaired_cycle() -> Rc<Node> {
    let node1 = Rc::new(Node {
        value: 1,
        next: None,
    });
    
    let node2 = Rc::new(Node {
        value: 2,
        next: Some(Rc::downgrade(&node1)),
    });
    
    let node1_mut = Rc::get_mut(&mut node1.clone()).unwrap();
    node1_mut.next = Some(Rc::downgrade(&node2));
    
    node1
}
```

A chave está em substituir `Rc` por `Weak` nas referências cíclicas, permitindo que a contagem de referências chegue a zero quando as instâncias principais saem de escopo. O `dhat-rs` agora mostrará alocações sendo devidamente liberadas.