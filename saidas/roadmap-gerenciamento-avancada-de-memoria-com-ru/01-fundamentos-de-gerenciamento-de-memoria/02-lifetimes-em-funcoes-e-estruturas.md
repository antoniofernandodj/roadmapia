## Lifetimes em Funções e Estruturas

Considere uma função que recebe duas strings e retorna a mais longa. Sem lifetimes, você poderia tentar escrever assim:

```rust
fn maior_string(s1: &str, s2: &str) -> &str {
    if s1.len() > s2.len() {
        s1
    } else {
        s2
    }
}
```

O compilador rejeita com um erro claro:

```
error[E0106]: missing lifetime specifier
 --> src/main.rs:1:33
  |
1 | fn maior_string(s1: &str, s2: &str) -> &str {
  |                    ----      ----     ^ expected named lifetime parameter
  |
  = help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `s1` or `s2`
```

O problema é fundamental: Rust precisa garantir que a referência retornada será válida enquanto for usada. Como o compilador não sabe se o retorno vem de `s1` ou `s2`, ele exige que você especifique a relação entre os lifetimes.

A solução é anotar os lifetimes explicitamente:

```rust
fn maior_string<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() {
        s1
    } else {
        s2
    }
}

fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";
    
    let resultado = maior_string(&string1, string2);
    println!("A string mais longa é {}", resultado);
}
```

A saída será:
```
A string mais longa é abcd
```

A sintaxe `<'a>` declara um parâmetro de lifetime. Aqui, dizemos que tanto `s1` quanto `s2` têm o mesmo lifetime `'a`, e o retorno também compartilha esse mesmo lifetime. Isso não altera quanto tempo qualquer das variáveis vive - apenas informa ao borrow checker que o retorno é válido enquanto ambos os parâmetros forem válidos.

### Lifetimes em Estruturas

Quando uma estrutura armazena referências, você deve anotar os lifetimes:

```rust
struct Extrato<'a> {
    parte: &'a str,
}

impl<'a> Extrato<'a> {
    fn novo(texto: &'a str) -> Extrato<'a> {
        Extrato {
            parte: &texto[0..4]
        }
    }
}

fn main() {
    let texto = String::from("Rust é incrível!");
    let extrato = Extrato::novo(&texto);
    
    println!("Extrato: {}", extrato.parte);  // "Rust"
}
```

Se você tentar usar a estrutura após o dado original ser liberado:

```rust
let extrato;
{
    let texto = String::from("Rust é incrível!");
    extrato = Extrato::novo(&texto);
}  // `texto` é liberado aqui
println!("Extrato: {}", extrato.parte);  // Erro!
```

O compilador previne o erro:

```
error[E0597]: `texto` does not live long enough
  --> src/main.rs:14:28
   |
14 |     extrato = Extrato::novo(&texto);
   |                            ^^^^^^ borrowed value does not live long enough
15 | }  // `texto` é liberado aqui
   | - `texto` dropped here while still borrowed
16 | println!("Extrato: {}", extrato.parte);
   |                        ------- borrow later used here
```

### Elision Rules

Em muitos casos, Rust permite omitir lifetimes graças às regras de elision:

```rust
// Com elision
fn primeira_palavra(s: &str) -> &str {
    s.split_whitespace().next().unwrap()
}

// Equivalente explícito
fn primeira_palavra<'a>(s: &'a str) -> &'a str {
    s.split_whitespace().next().unwrap()
}
```

As três regras principais são:
1. Cada parâmetro de referência recebe seu próprio lifetime.
2. Se há exatamente um parâmetro de entrada, seu lifetime é atribuído a todas as referências de saída.
3. Se há um parâmetro `&self` ou `&mut self`, o lifetime de `self` é atribuído a todas as referências de saída.

### Exercício Prático

Implemente uma estrutura `ParStrings` que armazene duas referências a strings e um método `maior` que retorne a mais longa:

```rust
// Seu código aqui

fn main() {
    let s1 = String::from("hello");
    let s2 = "world";
    
    let par = ParStrings::novo(&s1, s2);
    println!("Maior: {}", par.maior());  // Deve imprimir "hello"
}
```

Solução:

```rust
struct ParStrings<'a> {
    primeira: &'a str,
    segunda: &'a str,
}

impl<'a> ParStrings<'a> {
    fn novo(primeira: &'a str, segunda: &'a str) -> Self {
        ParStrings { primeira, segunda }
    }
    
    fn maior(&self) -> &'a str {
        if self.primeira.len() > self.segunda.len() {
            self.primeira
        } else {
            self.segunda
        }
    }
}
```

A chave aqui é que todas as referências compartilham o mesmo lifetime `'a`, garantindo que a string retornada por `maior()` será válida enquanto ambas as strings originais existirem.