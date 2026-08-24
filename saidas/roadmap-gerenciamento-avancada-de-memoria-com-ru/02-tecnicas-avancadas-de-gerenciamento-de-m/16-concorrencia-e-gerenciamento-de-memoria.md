## Concorrência e Gerenciamento de Memória

Em sistemas concorrentes, o gerenciamento de memória se torna exponencialmente mais complexo. Rust oferece garantias de segurança em tempo de compilação, mas quando threads começam a compartilhar dados, surgem desafios únicos que exigem padrões específicos de acesso à memória.

Considere este exemplo aparentemente simples de compartilhamento entre threads:

```rust
use std::thread;

fn main() {
    let data = vec![1, 2, 3];
    
    thread::spawn(move || {
        println!("Dados na thread: {:?}", data);
    }).join().unwrap();
    
    // println!("Tentando acessar após move: {:?}", data); // Erro!
}
```

A tentativa de usar `data` após o `move` falha com:
```
error[E0382]: borrow of moved value: `data`
```

Este é o primeiro desafio: quando você transfere dados para uma thread, perde o acesso no thread original. Rust garante que não haverá acesso concorrente aos mesmos dados sem sincronização.

Para compartilhar dados entre threads, precisamos de mecanismos atômicos ou protegidos por mutex. Veja o que acontece quando tentamos compartilhar sem proteção:

```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3]);
    let mut handles = vec![];

    for _ in 0..3 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            data.push(4); // Erro: Arc não permite mutabilidade interior
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

O compilador rejeita com:
```
error[E0596]: cannot borrow data in an `Arc` as mutable
```

`Arc` (Atomic Reference Counting) permite compartilhamento seguro entre threads, mas não mutabilidade. Para modificar os dados, precisamos combinar com `Mutex`:

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let data = Arc::new(Mutex::new(vec![1, 2, 3]));
    let mut handles = vec![];

    for i in 0..3 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            let mut vec = data.lock().unwrap();
            vec.push(i + 4);
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Resultado: {:?}", *data.lock().unwrap());
}
```

Saída possível:
```
Resultado: [1, 2, 3, 4, 5, 6]
```

Aqui enfrentamos outro desafio: o custo de sincronização. Cada acesso aos dados protegidos por `Mutex` tem overhead de lock. Em cenários de alta concorrência, isso pode se tornar um gargalo.

Alternativas como `RwLock` (para muitos leitores e poucos escritores) ou estruturas lock-free podem ser mais eficientes, mas trazem complexidade adicional. Considere este exemplo com `RwLock`:

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn main() {
    let data = Arc::new(RwLock::new(vec![1, 2, 3]));
    let mut handles = vec![];

    // Leitores
    for _ in 0..5 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            let vec = data.read().unwrap();
            println!("Leitura: {:?}", *vec);
        }));
    }

    // Escritor
    let data_writer = Arc::clone(&data);
    handles.push(thread::spawn(move || {
        let mut vec = data_writer.write().unwrap();
        vec.push(4);
    }));

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Resultado final: {:?}", *data.read().unwrap());
}
```

Outro problema comum é o vazamento de memória em cenários concorrentes. Mesmo com `Arc`, ciclos de referência podem ocorrer:

```rust
use std::sync::{Arc, Mutex};
use std::thread;

struct Node {
    value: i32,
    next: Option<Arc<Mutex<Node>>>,
}

fn main() {
    let node1 = Arc::new(Mutex::new(Node {
        value: 1,
        next: None,
    }));

    let node2 = Arc::new(Mutex::new(Node {
        value: 2,
        next: Some(Arc::clone(&node1)),
    }));

    // Criando um ciclo
    node1.lock().unwrap().next = Some(Arc::clone(&node2));

    thread::spawn(move || {
        // Operações com os nós...
    }).join().unwrap();

    // Memória nunca será liberada devido ao ciclo
}
```

Neste caso, mesmo quando as threads terminam, a memória não é liberada porque `node1` e `node2` mantêm referências mútuas através do `Arc`. Rust não detecta ciclos de referência automaticamente - você precisaria usar `Weak` para referências não proprietárias.

**Exercício**: Implemente uma estrutura de dados concorrente segura para um contador compartilhado entre múltiplas threads. O contador deve suportar incremento atômico e leitura sem causar deadlocks ou condições de corrida.

```rust
use std::sync::{Arc, Mutex};
use std::thread;

struct ConcurrentCounter {
    count: Mutex<i32>,
}

impl ConcurrentCounter {
    fn new() -> Self {
        ConcurrentCounter {
            count: Mutex::new(0),
        }
    }

    fn increment(&self) {
        let mut count = self.count.lock().unwrap();
        *count += 1;
    }

    fn get(&self) -> i32 {
        *self.count.lock().unwrap()
    }
}

fn main() {
    let counter = Arc::new(ConcurrentCounter::new());
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        handles.push(thread::spawn(move || {
            counter.increment();
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Contador final: {}", counter.get());
}
```

Solução: A estrutura `ConcurrentCounter` usa um `Mutex` para proteger o contador interno. Cada thread incrementa o contador de forma atômica, adquirindo o lock, modificando o valor e liberando o lock quando o guard (`lock.unwrap()`) sai do escopo. O método `get` também adquire o lock para leitura, garantindo consistência. O uso de `Arc` permite compartilhamento seguro entre threads, enquanto `Mutex` garante acesso exclusivo para modificações.