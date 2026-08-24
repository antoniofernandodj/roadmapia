## FFI e Integração com Bibliotecas C

Quando trabalhamos com gráficos em Rust, muitas vezes precisamos interagir com bibliotecas escritas em C, como OpenGL, Vulkan ou até mesmo drivers de baixo nível. Rust oferece uma maneira segura e eficiente de fazer isso através da Foreign Function Interface (FFI). A FFI permite chamar funções C diretamente do Rust, mas exige cuidados especiais para garantir a segurança de memória e evitar comportamentos indefinidos.

### Chamando Funções C Básicas

Vamos começar com um exemplo simples: chamar a função `sqrt` da biblioteca matemática C. Primeiro, precisamos declarar a função externa usando o bloco `extern`:

```rust
extern "C" {
    fn sqrt(x: f64) -> f64;
}

fn main() {
    let x = 16.0;
    let result = unsafe { sqrt(x) };
    println!("A raiz quadrada de {} é {}", x, result);
}
```

Aqui, `extern "C"` diz ao Rust que a função `sqrt` segue a convenção de chamada C. A função é marcada como `unsafe` porque Rust não pode garantir sua segurança — é nossa responsabilidade garantir que os argumentos sejam válidos.

Saída:
```
A raiz quadrada de 16 é 4
```

### Tipos Compatíveis

Rust e C compartilham muitos tipos básicos, mas nem todos são diretamente compatíveis. Por exemplo, `int` em C corresponde a `i32` em Rust, e `char` corresponde a `u8`. Para tipos mais complexos, como structs, precisamos garantir que o layout na memória seja o mesmo em ambos os lados.

```rust
#[repr(C)]
struct Point {
    x: i32,
    y: i32,
}

extern "C" {
    fn print_point(p: Point);
}

fn main() {
    let p = Point { x: 10, y: 20 };
    unsafe { print_point(p) };
}
```

Aqui, `#[repr(C)]` garante que a struct `Point` tenha o mesmo layout de memória que em C. Sem isso, o compilador Rust poderia reorganizar os campos, causando problemas ao passar a struct para a função C.

### Ponteiros e Segurança

Ponteiros são comuns em APIs C, mas em Rust, eles são inseguros. Para interagir com ponteiros C, usamos `*const T` para ponteiros imutáveis e `*mut T` para mutáveis. Veja como passar uma string para uma função C:

```rust
extern "C" {
    fn print_string(s: *const u8);
}

fn main() {
    let s = "Hello, C!\0"; // Note o \0 para terminar a string
    unsafe { print_string(s.as_ptr()) };
}
```

Aqui, `as_ptr()` retorna um ponteiro para o início da string. O `\0` no final é necessário porque C espera strings terminadas em null.

### Erro Comum: Lifetime e Ponteiros

Um erro comum é esquecer que Rust não pode garantir a validade de um ponteiro após a liberação da memória. Por exemplo:

```rust
extern "C" {
    fn print_string(s: *const u8);
}

fn main() {
    let s = String::from("Hello, C!\0");
    unsafe { print_string(s.as_ptr()) };
    drop(s); // Libera a memória
    unsafe { print_string(s.as_ptr()) }; // Comportamento indefinido!
}
```

Neste exemplo, o segundo `print_string` tenta acessar uma string que já foi liberada, causando comportamento indefinido. Para evitar isso, podemos usar `Box` ou `Arc` para garantir que a memória permaneça válida enquanto o ponteiro estiver em uso.

### Exercício: Integração com uma Biblioteca C Simples

Crie uma função Rust que chama uma função C para calcular a soma de dois números. A função C deve ser declarada como:

```c
// soma.c
int soma(int a, int b) {
    return a + b;
}
```

Compile a biblioteca C com `gcc -c soma.c -o soma.o` e depois `ar rcs libsoma.a soma.o`. Em seguida, escreva o código Rust para chamar essa função.

Solução:

```rust
extern "C" {
    fn soma(a: i32, b: i32) -> i32;
}

fn main() {
    let a = 10;
    let b = 20;
    let result = unsafe { soma(a, b) };
    println!("A soma de {} e {} é {}", a, b, result);
}
```

Saída:
```
A soma de 10 e 20 é 30
```