## Tipos de Dados e Alocação de Memória

Quando você declara uma variável em Rust, o compilador precisa decidir onde armazenar esse dado na memória. Essa decisão afeta diretamente o desempenho e o comportamento do seu código. Vamos dissecar o que realmente acontece quando você escreve `let x = 42;` ou `let s = String::from("hello");`.

### Stack: A Memória Rápida e Previsível

A stack é uma região de memória organizada como uma pilha de pratos - o último item a entrar é o primeiro a sair (LIFO). Ela é extremamente rápida porque aloca e desaloca memória com operações simples de mover um ponteiro.

Tipos que vão para a stack:
- Todos os tipos escalares (`i32`, `f64`, `bool`, `char`)
- Tuplas e arrays de tamanho fixo com tipos escalares
- Structs que contêm apenas os tipos acima

```rust
fn main() {
    let a = 10;          // i32 na stack
    let b = 3.14;        // f64 na stack
    let c = (a, b);      // Tupla (i32, f64) na stack
    let d = [1, 2, 3];   // Array [i32; 3] na stack
    
    println!("Endereço de a: {:p}", &a);
    println!("Endereço de b: {:p}", &b);
    println!("Endereço de c: {:p}", &c);
    println!("Endereço de d: {:p}", &d);
}
```

Saída típica (os endereços variam):
```
Endereço de a: 0x7ffee3a4a1fc
Endereço de b: 0x7ffee3a4a1f0
Endereço de c: 0x7ffee3a4a1e0
Endereço de d: 0x7ffee3a4a1d4
```

Observe como os endereços decrescem - isso mostra a stack crescendo para baixo na memória. Cada variável tem um tamanho conhecido em tempo de compilação.

### Heap: Memória Dinâmica e Flexível

O heap é uma região de memória menos organizada, usada para dados que:
- Têm tamanho desconhecido em tempo de compilação
- Precisam viver além do escopo atual
- São muito grandes para a stack

Tipos que usam o heap:
- `String`, `Vec<T>`, `Box<T>`
- Qualquer tipo que envolva alocação dinâmica

```rust
fn main() {
    let s = String::from("hello");  // Alocado no heap
    let v = vec![1, 2, 3];         // Alocado no heap
    
    println!("Endereço do ponteiro s: {:p}", &s);
    println!("Endereço do ponteiro v: {:p}", &v);
    
    // O conteúdo real está em outro lugar
    println!("Conteúdo de s: {:?}", s.as_ptr());
    println!("Conteúdo de v: {:?}", v.as_ptr());
}
```

Saída típica:
```
Endereço do ponteiro s: 0x7ffee3a4a1e0
Endereço do ponteiro v: 0x7ffee3a4a1d0
Conteúdo de s: 0x7f8a6bc02a00
Conteúdo de v: 0x7f8a6bc02b20
```

Aqui, `s` e `v` são estruturas na stack que contêm ponteiros para os dados reais no heap. A stack armazena o ponteiro, capacidade e tamanho atual.

### O Erro Clássico: Tentar Retornar Referência para Dados Locais

```rust
fn cria_string() -> &String {
    let s = String::from("erro");
    &s
} // s é destruída aqui

fn main() {
    let referencia = cria_string();
    println!("{}", referencia);
}
```

O compilador Rust impede esse erro com a mensagem:
```
error[E0106]: missing lifetime specifier
 --> src/main.rs:1:17
  |
1 | fn cria_string() -> &String {
  |                    ^ expected named lifetime parameter
  |
  = help: this function's return type contains a borrowed value, but there is no value for it to be borrowed from
```

### Structs e Alocação

Como uma struct é alocada depende de seus campos:

```rust
struct StackOnly {
    x: i32,
    y: i32,
}

struct HeapAndStack {
    name: String,      // Heap
    age: i32,          // Stack
    scores: Vec<i32>,  // Heap
}

fn main() {
    let so = StackOnly { x: 10, y: 20 };  // Toda na stack
    let hs = HeapAndStack {               // Parte na stack, parte no heap
        name: String::from("Alice"),
        age: 30,
        scores: vec![100, 95, 98],
    };
    
    println!("Tamanho StackOnly: {}", std::mem::size_of_val(&so));
    println!("Tamanho HeapAndStack: {}", std::mem::size_of_val(&hs));
}
```

Saída típica:
```
Tamanho StackOnly: 8
Tamanho HeapAndStack: 56
```

### Exercício Prático

Analise o seguinte código e determine onde cada parte dos dados é alocada (stack ou heap). Depois, compile e execute para verificar suas hipóteses:

```rust
struct Data {
    id: u64,
    tags: Vec<String>,
    metadata: Option<Box<[u8]>>,
}

fn process_data() -> Data {
    let temp = vec!["rust".to_string(), "memory".to_string()];
    Data {
        id: 42,
        tags: temp,
        metadata: Some(Box::new([1, 2, 3, 4])),
    }
}

fn main() {
    let data = process_data();
    println!("Data size: {}", std::mem::size_of_val(&data));
}
```

### Solução Comentada

```rust
struct Data {
    id: u64,                     // Stack (8 bytes)
    tags: Vec<String>,           // Stack (24 bytes: ptr, cap, len) + heap para Strings e seus conteúdos
    metadata: Option<Box<[u8]>>, // Stack (16 bytes para Option) + heap para o array [u8]
}

fn process_data() -> Data {
    let temp = vec!["rust".to_string(), "memory".to_string()];  // Vec na stack, Strings no heap
    Data {
        id: 42,  // Stack
        tags: temp,  // Vec move para stack, conteúdo permanece no heap
        metadata: Some(Box::new([1, 2, 3, 4])),  // Box na stack, array no heap
    }
}

fn main() {
    let data = process_data();  // Struct Data na stack
    println!("Data size: {}", std::mem::size_of_val(&data));  // Mostra apenas o tamanho na stack
}
```

A saída mostrará o tamanho da struct na stack (48 bytes em sistemas de 64 bits), mas lembre-se que a maior parte dos dados está no heap. O `Vec` e `Box` são tipos inteligentes que gerenciam a alocação no heap automaticamente.