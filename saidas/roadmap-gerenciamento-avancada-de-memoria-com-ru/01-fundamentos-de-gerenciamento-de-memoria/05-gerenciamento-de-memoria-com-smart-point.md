## Gerenciamento de Memória com Smart Pointers

Quando você precisa armazenar dados no heap em Rust, o compilador exige que você seja explícito sobre o gerenciamento dessa memória. É aqui que os smart pointers entram - eles são estruturas que não apenas armazenam um ponteiro para os dados, mas também adicionam comportamentos específicos para gerenciar o ciclo de vida desses dados.

### Box<T>: Alocação Simples no Heap

O `Box` é o smart pointer mais direto. Ele permite alocar um valor no heap enquanto mantém um ponteiro para ele na stack. Veja um caso concreto onde ele é necessário:

```rust
fn main() {
    // Isso não compila - tamanho não conhecido em tempo de compilação
    // let recursive_type = List::Cons(1, List::Cons(2, List::Nil));
    
    #[derive(Debug)]
    enum List {
        Cons(i32, Box<List>),
        Nil,
    }
    
    let list = List::Cons(1, Box::new(List::Cons(2, Box::new(List::Nil))));
    println!("{:?}", list);
}
```

Saída:
```
Cons(1, Cons(2, Nil))
```

O erro que você encontraria sem o `Box` é:
```
error[E0072]: recursive type `List` has infinite size
```

O `Box` resolve isso porque tem tamanho fixo (apenas um ponteiro), permitindo que a enumeração `List` tenha um tamanho conhecido em tempo de compilação.

### Rc<T>: Contagem de Referências para Dados Compartilhados

Quando você precisa de múltiplas partes do seu código para ter acesso de leitura aos mesmos dados no heap, `Rc` (Reference Counting) é a solução. Ele mantém uma contagem de quantas referências existem para os dados e libera a memória quando a contagem chega a zero.

```rust
use std::rc::Rc;

fn main() {
    let data = Rc::new(vec![1, 2, 3]);
    
    let reader1 = Rc::clone(&data);
    let reader2 = Rc::clone(&data);
    
    println!("Reader 1: {:?}", reader1);
    println!("Reader 2: {:?}", reader2);
    println!("Original: {:?}", data);
    
    println!("Contagem de referências: {}", Rc::strong_count(&data));
}
```

Saída:
```
Reader 1: [1, 2, 3]
Reader 2: [1, 2, 3]
Original: [1, 2, 3]
Contagem de referências: 3
```

Tentativa comum (e errada) sem Rc:
```rust
let data = vec![1, 2, 3];
let reader1 = &data;
let reader2 = &data; // Ok até aqui
let moved = data; // Erro: value borrowed here after move
```

### Arc<T>: Rc Thread-Safe

Para compartilhamento entre threads, `Rc` não é suficiente. O Rust exige que você use `Arc` (Atomic Reference Counting), que incrementa e decrementa a contagem de referências de forma atômica, tornando-o seguro para threads.

```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3]);
    let mut handles = vec![];

    for i in 0..3 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            println!("Thread {}: {:?}", i, data);
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

Saída (pode variar na ordem):
```
Thread 0: [1, 2, 3]
Thread 1: [1, 2, 3]
Thread 2: [1, 2, 3]
```

Tentativa errada com Rc:
```rust
let data = Rc::new(vec![1, 2, 3]);
thread::spawn(move || { // Erro: `Rc` cannot be sent between threads safely
    println!("{:?}", data);
});
```

### Quando Usar Cada Smart Pointer

1. **Box<T>**: 
   - Quando você precisa armazenar um tipo de tamanho desconhecido (como um trait object)
   - Para tipos recursivos ou que precisam ser armazenados no heap
   - Quando você quer transferir ownership de um grande valor sem copiá-lo

2. **Rc<T>**:
   - Para dados compartilhados em um único thread
   - Quando você precisa de múltiplas partes do código para ler os mesmos dados
   - Em estruturas de dados complexas onde a ownership não é linear

3. **Arc<T>**:
   - Para todos os casos de Rc, mas quando há compartilhamento entre threads
   - Em servidores ou aplicações concorrentes onde os dados são lidos por múltiplas threads

### Exercício Prático

Implemente uma árvore binária usando smart pointers onde cada nó pode ter até dois filhos. A árvore deve ser capaz de:
1. Armazenar valores i32 em cada nó
2. Ser construída de forma segura
3. Permitir navegação (não precisa implementar algoritmos de busca, apenas a estrutura)

Solução comentada:

```rust
use std::rc::Rc;

#[derive(Debug)]
struct TreeNode {
    value: i32,
    left: Option<Rc<TreeNode>>,
    right: Option<Rc<TreeNode>>,
}

impl TreeNode {
    fn new(value: i32) -> Rc<Self> {
        Rc::new(TreeNode {
            value,
            left: None,
            right: None,
        })
    }

    fn set_left(&mut self, node: Rc<TreeNode>) {
        self.left = Some(node);
    }

    fn set_right(&mut self, node: Rc<TreeNode>) {
        self.right = Some(node);
    }
}

fn main() {
    let root = TreeNode::new(10);
    
    let mut root_mut = Rc::make_mut(&mut Rc::clone(&root));
    root_mut.set_left(TreeNode::new(5));
    root_mut.set_right(TreeNode::new(15));
    
    println!("Árvore: {:#?}", root);
}
```

Pontos-chave da solução:
1. Usamos `Rc` porque os nós filhos podem ser compartilhados (por exemplo, em uma árvore DAG)
2. `Option` permite representar a ausência de filhos
3. `Rc::make_mut` nos dá uma referência mutável quando temos ownership exclusivo
4. A estrutura permite navegação segura sem violar as regras de borrowing do Rust