## Introdução a Ponteiros Brutos

Você tem um vetor alocado na heap e precisa passar seu endereço de memória para uma função C através de FFI. O compilador Rust impede você de simplesmente pegar a referência e convertê-la, porque não há garantias de segurança nessa operação. Esse é o cenário onde ponteiros brutos (*raw pointers*) entram em ação.

Um ponteiro bruto em Rust é um tipo de ponteiro sem as garantias de segurança padrão da linguagem. Eles vêm em duas variantes:

```rust
let raw_const: *const i32 = &10 as *const i32;
let raw_mut: *mut i32 = &mut 20 as *mut i32;
```

A diferença crucial entre referências Rust (`&T`, `&mut T`) e ponteiros brutos (`*const T`, `*mut T`) é que os últimos:
1. Não têm garantia de validade (podem apontar para memória inválida)
2. Não impedem aliasing (múltiplos ponteiros podem acessar o mesmo local)
3. Não garantem exclusividade para escrita (`*mut T`)

Quando você tenta desreferenciar um ponteiro bruto diretamente, o compilador impede:

```rust
let x = 42;
let raw = &x as *const i32;
println!("{}", *raw); // Erro: dereference of raw pointer is unsafe
```

O erro completo será:
```
error[E0133]: dereference of raw pointer is unsafe and requires unsafe function or block
 --> src/main.rs:4:20
  |
4 |     println!("{}", *raw);
  |                    ^^^^ dereference of raw pointer
  |
  = note: raw pointers may be NULL, dangling or unaligned; they can violate aliasing rules 
  and cause data races: all of these are undefined behavior
```

Para desreferenciar, você precisa de um bloco `unsafe`:

```rust
let x = 42;
let raw = &x as *const i32;
unsafe {
    println!("Valor: {}", *raw); // Ok: 42
}
```

Um erro comum é assumir que ponteiros brutos têm o mesmo comportamento de referências Rust. Considere este exemplo problemático:

```rust
fn dangerous() -> i32 {
    let x = 5;
    let raw = &x as *const i32;
    unsafe { *raw } // Retorna um valor de uma variável que já saiu do escopo!
}

fn main() {
    let valor = dangerous();
    println!("{}", valor); // Comportamento indefinido!
}
```

A saída pode parecer correta em alguns casos, mas isso é puro acidente. O código está acessando memória inválida, um típico "use-after-free".

Para usar ponteiros brutos corretamente, você geralmente precisará:

1. Garantir que o ponteiro não seja nulo antes de desreferenciar
2. Verificar o alinhamento da memória
3. Assegurar que o tempo de vida do dado é válido

Aqui está um exemplo seguro de conversão entre referências e ponteiros brutos:

```rust
fn main() {
    let mut data = vec![1, 2, 3];
    
    // Convertendo referências em ponteiros brutos
    let ptr_const: *const i32 = data.as_ptr();
    let ptr_mut: *mut i32 = data.as_mut_ptr();
    
    unsafe {
        // Modificando através do ponteiro mutável
        *ptr_mut.add(1) = 42;
        
        // Lendo através do ponteiro constante
        println!("Segundo elemento: {}", *ptr_const.add(1));
    }
    
    println!("Vetor modificado: {:?}", data);
}
```

Saída:
```
Segundo elemento: 42
Vetor modificado: [1, 42, 3]
```

**Exercício**: Implemente uma função `unsafe` que recebe um ponteiro bruto mutável para um array de 3 floats e multiplica cada elemento por 2. Teste com um array alocado na stack.

**Solução**:

```rust
unsafe fn double_array(ptr: *mut [f32; 3]) {
    for i in 0..3 {
        *(*ptr).get_unchecked_mut(i) *= 2.0;
    }
}

fn main() {
    let mut arr = [1.0, 2.0, 3.0];
    let ptr = &mut arr as *mut [f32; 3];
    
    unsafe {
        double_array(ptr);
    }
    
    assert_eq!(arr, [2.0, 4.0, 6.0]);
}
```

A solução usa `get_unchecked_mut` para evitar verificações de limites (já que sabemos o tamanho) e opera diretamente na memória através do ponteiro. Note que toda operação potencialmente perigosa está dentro do bloco `unsafe`.