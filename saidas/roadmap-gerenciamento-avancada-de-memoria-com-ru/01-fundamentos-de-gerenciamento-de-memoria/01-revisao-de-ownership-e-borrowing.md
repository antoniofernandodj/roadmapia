## Revisão de Ownership e Borrowing

Considere este código C++ comum que causa um erro de dupla liberação de memória:

```cpp
#include <iostream>

int* create_number() {
    int* x = new int(42);
    return x;
}

void use_and_delete(int* ptr) {
    std::cout << *ptr << std::endl;
    delete ptr;
}

int main() {
    int* num = create_number();
    use_and_delete(num);
    use_and_delete(num); // Crash! Double free
    return 0;
}
```

Rust elimina esse tipo de problema em tempo de compilação através do sistema de ownership. Vejamos a versão Rust equivalente:

```rust
fn create_number() -> i32 {
    42
}

fn use_and_drop(num: i32) {
    println!("{}", num);
    // num é automaticamente descartado aqui
}

fn main() {
    let num = create_number();
    use_and_drop(num);
    use_and_drop(num); // Funciona! i32 implementa Copy
}
```

A diferença crucial é que em Rust, por padrão, valores não implementam Copy e são movidos (não copiados) quando passados para funções. Vamos modificar o exemplo para usar um tipo que não implementa Copy:

```rust
struct MyNumber {
    value: i32,
}

fn create_number() -> MyNumber {
    MyNumber { value: 42 }
}

fn use_and_drop(num: MyNumber) {
    println!("{}", num.value);
    // num é automaticamente descartado aqui
}

fn main() {
    let num = create_number();
    use_and_drop(num);
    use_and_drop(num); // Erro de compilação!
}
```

O compilador Rust nos avisa com esta mensagem:

```
error[E0382]: use of moved value: `num`
  --> src/main.rs:16:16
   |
14 |     let num = create_number();
   |         --- move occurs because `num` has type `MyNumber`, which does not implement the `Copy` trait
15 |     use_and_drop(num);
   |                  --- value moved here
16 |     use_and_drop(num); // Erro de compilação!
   |                  ^^^ value used here after move
```

### Borrowing: Acessando Dados Sem Transferir Ownership

Para acessar um valor sem consumi-lo, usamos referências (borrowing):

```rust
fn print_number(num: &MyNumber) {
    println!("{}", num.value);
}

fn main() {
    let num = create_number();
    print_number(&num);
    print_number(&num); // OK! Apenas emprestamos a referência
}
```

Rust impõe regras rígidas sobre referências:
1. Você pode ter várias referências imutáveis (&T) ao mesmo tempo
2. Ou exatamente uma referência mutável (&mut T)
3. Referências devem sempre ser válidas (não pode haver dangling pointers)

Veja o que acontece quando violamos essas regras:

```rust
fn main() {
    let mut num = create_number();
    let ref1 = &mut num;
    let ref2 = &mut num; // Erro!
    println!("{}, {}", ref1.value, ref2.value);
}
```

Mensagem de erro:

```
error[E0499]: cannot borrow `num` as mutable more than once at a time
 --> src/main.rs:5:18
  |
4 |     let ref1 = &mut num;
  |                -------- first mutable borrow occurs here
5 |     let ref2 = &mut num; // Erro!
  |                ^^^^^^^^ second mutable borrow occurs here
6 |     println!("{}, {}", ref1.value, ref2.value);
  |                        ---------- first borrow later used here
```

### Ownership em Estruturas de Dados

O ownership se torna especialmente importante com coleções. Considere este exemplo com Vec:

```rust
fn main() {
    let mut vec = vec![1, 2, 3];
    let first = &vec[0]; // Empréstimo imutável
    vec.push(4);         // Tentativa de empréstimo mutável
    println!("{}", first);
}
```

O compilador previne um potencial erro:

```
error[E0502]: cannot borrow `vec` as mutable because it is also borrowed as immutable
 --> src/main.rs:4:5
  |
3 |     let first = &vec[0];
  |                  --- immutable borrow occurs here
4 |     vec.push(4);         // Tentativa de empréstimo mutável
  |     ^^^^^^^^^^^ mutable borrow occurs here
5 |     println!("{}", first);
  |                    ----- immutable borrow later used here
```

### Exercício Prático

Transforme este código C++ problemático em Rust seguro, mantendo a mesma funcionalidade:

```cpp
#include <vector>
#include <iostream>

void process(std::vector<int>& vec) {
    for (auto& item : vec) {
        std::cout << item << " ";
    }
    std::cout << std::endl;
}

void clear(std::vector<int>& vec) {
    vec.clear();
}

int main() {
    std::vector<int> data = {1, 2, 3};
    process(data);
    clear(data);
    process(data); // Funciona, mas imprime vetor vazio
    return 0;
}
```

Solução em Rust:

```rust
fn process(vec: &[i32]) {
    for item in vec {
        print!("{} ", item);
    }
    println!();
}

fn clear(vec: &mut Vec<i32>) {
    vec.clear();
}

fn main() {
    let mut data = vec![1, 2, 3];
    process(&data);
    clear(&mut data);
    process(&data); // Seguro: mostra vetor vazio
}
```

Principais diferenças:
1. Em Rust, `process` recebe uma fatia imutável (`&[i32]`) em vez de referência mutável
2. `clear` explicitamente requer uma referência mutável
3. O compilador garante que não há acesso inválido à memória
4. A última chamada a `process` é segura - o vetor está vazio, mas não invalidado