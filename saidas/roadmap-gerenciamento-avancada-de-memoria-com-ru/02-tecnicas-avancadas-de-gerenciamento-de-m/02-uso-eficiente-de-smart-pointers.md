## Uso Eficiente de Smart Pointers

Considere um sistema de gerenciamento de inventário onde múltiplas partes do código precisam acessar os mesmos itens. Usar referências simples (`&`) rapidamente se torna inviável devido aos requisitos de lifetime, e clonar os dados inteiros a cada acesso é proibitivamente caro em memória. É aqui que os smart pointers mostram seu valor.

### Rc: Contagem de Referências para Dono Único

O `Rc<T>` (Reference Counting) permite compartilhamento de dados em cenários single-threaded. Veja um caso real:

```rust
use std::rc::Rc;

struct ItemInventario {
    id: u32,
    nome: String,
    estoque: i32,
}

fn main() {
    let item_original = ItemInventario {
        id: 42,
        nome: "Poção de Cura".into(),
        estoque: 100,
    };

    let item_shared = Rc::new(item_original);
    
    let registro_vendas = item_shared.clone();
    let sistema_relatorio = item_shared.clone();

    println!("ID via vendas: {}", registro_vendas.id);
    println!("Nome via relatório: {}", sistema_relatorio.nome);
    
    // Erro comum: tentar modificar
    // registro_vendas.estoque -= 10; // ERROR: cannot mutate through an `Rc`
}
```

Saída:
```
ID via vendas: 42
Nome via relatório: Poção de Cura
```

O erro acima revela uma característica crucial: `Rc` só permite compartilhamento imutável. Para mutabilidade, precisamos do `RefCell`.

### RefCell: Mutabilidade Interior em Tempo de Execução

Combine `Rc<RefCell<T>>` quando precisar de múltiplos "donos" com mutabilidade controlada:

```rust
use std::rc::Rc;
use std::cell::RefCell;

let item_celular = Rc::new(RefCell::new(ItemInventario {
    id: 101,
    nome: "Smartphone X".into(),
    estoque: 50,
}));

{
    let mut emprestimo = item_celular.borrow_mut();
    emprestimo.estoque -= 5; // Modificação permitida
} // Empréstimo é liberado aqui

println!("Estoque atual: {}", item_celular.borrow().estoque);
```

Saída:
```
Estoque atual: 45
```

Tente este erro comum para entender as proteções:

```rust
let emprestimo1 = item_celular.borrow_mut();
let emprestimo2 = item_celular.borrow_mut(); // PANIC: already mutably borrowed
```

### Arc: Contagem Atômica para Threads

Em ambientes multithread, substitua `Rc` por `Arc` (Atomic Reference Counting):

```rust
use std::sync::Arc;
use std::thread;

let item_global = Arc::new(ItemInventario {
    id: 200,
    nome: "Livro Raro".into(),
    estoque: 10,
});

let mut handles = vec![];

for _ in 0..3 {
    let item_thread = Arc::clone(&item_global);
    handles.push(thread::spawn(move || {
        println!("Thread acessou: {}", item_thread.nome);
    }));
}

for handle in handles {
    handle.join().unwrap();
}
```

Para mutabilidade entre threads, combine `Arc` com `Mutex`:

```rust
use std::sync::{Arc, Mutex};

let item_compartilhado = Arc::new(Mutex::new(ItemInventario {
    id: 300,
    nome: "Componente Eletrônico".into(),
    estoque: 25,
}));

let item_thread = Arc::clone(&item_compartilhado);
thread::spawn(move || {
    let mut item = item_thread.lock().unwrap();
    item.estoque -= 3;
}).join().unwrap();

println!("Estoque final: {}", item_compartilhado.lock().unwrap().estoque);
```

### Box: Alocação no Heap com Semântica de Dono Único

Use `Box` quando precisar:
- Alocar grandes estruturas no heap
- Definir tipos recursivos
- Transferir ownership de dados grandes sem cópia

Exemplo de árvore binária:

```rust
struct Node {
    value: i32,
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
}

let root = Box::new(Node {
    value: 10,
    left: Some(Box::new(Node {
        value: 5,
        left: None,
        right: None,
    })),
    right: Some(Box::new(Node {
        value: 15,
        left: None,
        right: None,
    })),
});
```

### Exercício Prático

Implemente um sistema de cache compartilhado entre threads onde:
1. Uma `Arc<Mutex<HashMap<String, String>>>` armazena os dados
2. Três threads adicionam itens diferentes ao cache
3. A thread principal imprime o estado final

Solução comentada:

```rust
use std::sync::{Arc, Mutex};
use std::collections::HashMap;
use std::thread;

fn main() {
    let cache = Arc::new(Mutex::new(HashMap::new()));
    
    let mut handles = vec![];
    
    for i in 0..3 {
        let cache_clone = Arc::clone(&cache);
        handles.push(thread::spawn(move || {
            let mut cache = cache_clone.lock().unwrap();
            cache.insert(format!("chave-{}", i), format!("valor-{}", i));
        }));
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Cache final: {:?}", cache.lock().unwrap());
}
```

Chave do aprendizado: `Arc` gerencia a propriedade compartilhada entre threads, enquanto `Mutex` serializa o acesso aos dados mutáveis. A combinação dos dois é padrão para estado mutável compartilhado em Rust.