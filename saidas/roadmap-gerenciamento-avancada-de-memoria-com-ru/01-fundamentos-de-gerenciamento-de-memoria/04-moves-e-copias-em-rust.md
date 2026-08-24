## Moves e Cópias em Rust

Quando você atribui um valor a outra variável em Rust, o comportamento muda radicalmente dependendo do tipo de dado envolvido. Esse mecanismo é fundamental para entender como Rust gerencia memória sem um garbage collector.

Considere este exemplo com um tipo primitivo:

```rust
let x = 42;
let y = x;
println!("x: {}, y: {}", x, y);
```

A saída será:
```
x: 42, y: 42
```

Isso funciona porque tipos como `i32` implementam o trait `Copy`. A atribuição `let y = x` cria uma cópia bit-a-bit do valor. Agora veja o que acontece com um tipo que não implementa `Copy`:

```rust
let s1 = String::from("texto");
let s2 = s1;
println!("s2: {}", s2);
// println!("s1: {}", s1); // Isso causaria erro!
```

O compilador emite o erro:
```
error[E0382]: borrow of moved value: `s1`
```

A diferença crucial é que `String` não implementa `Copy`. Quando fazemos `let s2 = s1`, ocorre um *move*: a posse (ownership) do valor é transferida para `s2` e `s1` fica inválida. Rust impede o acesso a `s1` após o move para evitar referências inválidas.

### Como Rust decide entre Copy e Move

A regra é simples: tipos que implementam o trait `Copy` são copiados, outros são movidos. Tipos primitivos (inteiros, floats, booleanos, chars) e tuplas contendo apenas tipos `Copy` implementam automaticamente:

```rust
let a = (1, 2.5, true);
let b = a; // Cópia porque (i32, f64, bool) são todos Copy
println!("a: {:?}, b: {:?}", a, b);
```

Para tipos personalizados, você pode optar por implementar `Copy` quando fizer sentido:

```rust
#[derive(Copy, Clone, Debug)]
struct Ponto {
    x: i32,
    y: i32,
}

let p1 = Ponto { x: 10, y: 20 };
let p2 = p1; // Cópia porque Ponto implementa Copy
println!("p1: {:?}, p2: {:?}", p1, p2);
```

### Moves em chamadas de função

O mesmo comportamento ocorre ao passar valores para funções:

```rust
fn consome(s: String) {
    println!("Consumindo: {}", s);
}

let s = String::from("dados");
consome(s);
// consome(s); // Erro! s foi movido
```

A primeira chamada transfere o ownership para a função. Tentar usar `s` novamente gera o erro:
```
error[E0382]: use of moved value: `s`
```

### Clonagem explícita

Quando você realmente precisa de uma cópia de um valor não-Copy, use `clone()`:

```rust
let s1 = String::from("original");
let s2 = s1.clone();
println!("s1: {}, s2: {}", s1, s2); // Ambas válidas
```

Clone realiza uma cópia profunda (deep copy), alocando nova memória. Isso é mais custoso que um move (que apenas transfere pointers), então deve ser usado conscientemente.

### Moves e estruturas de dados

Coleções como `Vec` também seguem as regras de move:

```rust
let v1 = vec![1, 2, 3];
let v2 = v1;
// println!("v1: {:?}", v1); // Erro!
```

Mas elementos dentro da coleção podem ser `Copy`:

```rust
let nums = vec![1, 2, 3];
let nums_copy = nums.clone(); // Clone explícito necessário
```

### Exercício

Analise este código e corrija os erros sem alterar a lógica principal:

```rust
struct Dados {
    valor: i32,
}

fn processa(d: Dados) -> i32 {
    d.valor * 2
}

let dados = Dados { valor: 42 };
let resultado = processa(dados);
println!("Original: {}, Resultado: {}", dados.valor, resultado);
```

Solução comentada:

```rust
#[derive(Copy, Clone)] // Implementa Copy para Dados
struct Dados {
    valor: i32,
}

fn processa(d: Dados) -> i32 {
    d.valor * 2
}

let dados = Dados { valor: 42 };
let resultado = processa(dados);
println!("Original: {}, Resultado: {}", dados.valor, resultado);
```

A solução implementa `Copy` para `Dados` já que contém apenas um `i32` (que é `Copy`). Alternativamente, poderíamos clonar explicitamente (`processa(dados.clone())`) ou usar borrowing (`fn processa(d: &Dados)`), mas implementar `Copy` é a solução mais idiomática para este caso simples.