## Casos de Uso para Unsafe Code

Rust garante segurança de memória em tempo de compilação através de seu sistema de ownership e borrowing. Porém, existem situações onde o compilador não consegue verificar todas as invariantes, ou onde precisamos contornar as garantias de segurança para interoperar com outros sistemas. É aí que entram os blocos `unsafe`.

### Interoperabilidade com C (FFI)

A interface com linguagens estrangeiras (FFI - Foreign Function Interface) é o caso mais comum para uso de `unsafe`. Quando chamamos funções de bibliotecas C, Rust não pode verificar as garantias de segurança:

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    let x = -42;
    // Esta chamada é unsafe porque Rust não pode garantir
    // que a função C segue as regras de segurança de memória
    let result = unsafe { abs(x) };
    println!("O valor absoluto de {} é {}", x, result);
}
```

Saída:
```
O valor absoluto de -42 é 42
```

O bloco `unsafe` aqui é necessário porque:
1. Rust não pode verificar se a função `abs` da libc é segura
2. A função C pode acessar memória inválida ou violar outras regras
3. Não há garantias sobre thread-safety ou outros comportamentos

### Otimizações de Desempenho Crítico

Em código onde o desempenho é absolutamente crítico, podemos usar `unsafe` para evitar verificações desnecessárias. Considere este iterador sobre um slice que queremos otimizar:

```rust
fn sum_squares_safe(slice: &[i32]) -> i32 {
    slice.iter().map(|&x| x * x).sum()
}

fn sum_squares_unsafe(slice: &[i32]) -> i32 {
    let mut sum = 0;
    let len = slice.len();
    let ptr = slice.as_ptr();
    
    unsafe {
        for i in 0..len {
            sum += *ptr.add(i) * *ptr.add(i);
        }
    }
    
    sum
}

fn main() {
    let nums = [1, 2, 3, 4, 5];
    println!("Safe: {}", sum_squares_safe(&nums));
    println!("Unsafe: {}", sum_squares_unsafe(&nums));
}
```

Saída:
```
Safe: 55
Unsafe: 55
```

A versão unsafe evita:
1. Verificações de bounds em cada acesso
2. Overhead do iterador
3. Potenciais branch mispredictions

Porém, se usarmos incorretamente, teremos comportamentos indefinidos:

```rust,should_panic
fn broken_unsafe(slice: &[i32]) -> i32 {
    let mut sum = 0;
    let ptr = slice.as_ptr();
    
    unsafe {
        // Acesso fora dos bounds!
        for i in 0..100 {
            sum += *ptr.add(i);
        }
    }
    
    sum
}
```

Isso pode causar segmentation faults ou pior - corrupção silenciosa de dados.

### Implementação de Estruturas de Baixo Nível

Estruturas como `Vec`, `Box` e `Rc` usam `unsafe` internamente para gerenciar memória diretamente. Veja um esboço simplificado:

```rust
struct MyVec<T> {
    ptr: *mut T,
    cap: usize,
    len: usize,
}

impl<T> MyVec<T> {
    fn new() -> Self {
        Self {
            ptr: std::ptr::null_mut(),
            cap: 0,
            len: 0,
        }
    }
    
    fn push(&mut self, item: T) {
        if self.len == self.cap {
            self.grow();
        }
        
        unsafe {
            // Escreve no próximo slot disponível
            std::ptr::write(self.ptr.add(self.len), item);
        }
        
        self.len += 1;
    }
    
    fn grow(&mut self) {
        // Implementação omitida para brevidade
        // Envolve alocação raw de memória
    }
}
```

Aqui, `unsafe` é necessário porque:
1. Estamos gerenciando manualmente a alocação de memória
2. Fazemos aritmética de ponteiros raw
3. Implementamos lógica de ownership manualmente

### Quando Não Usar Unsafe

Evite `unsafe` quando:
1. O mesmo resultado pode ser alcançado com código seguro
2. Você não está absolutamente certo dos invariantes
3. O ganho de desempenho é marginal
4. A API será exposta para outros desenvolvedores

### Exercício Prático

Implemente uma função `split_at_mut` segura usando `unsafe` internamente, similar à da biblioteca padrão. A função deve dividir um slice mutável em dois no índice dado.

```rust
fn split_at_mut(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    // Sua implementação aqui
}

fn main() {
    let mut v = vec![1, 2, 3, 4, 5];
    let (left, right) = split_at_mut(&mut v, 2);
    println!("Left: {:?}, Right: {:?}", left, right);
}
```

Solução:

```rust
fn split_at_mut(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = slice.len();
    let ptr = slice.as_mut_ptr();
    
    assert!(mid <= len);
    
    unsafe {
        (
            std::slice::from_raw_parts_mut(ptr, mid),
            std::slice::from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}
```

Explicação:
1. Obtemos um ponteiro raw mutável para o slice
2. Verificamos que o índice está dentro dos bounds
3. Usamos `unsafe` para criar dois slices mutáveis distintos
4. `from_raw_parts_mut` é seguro desde que os invariantes sejam mantidos:
   - O ponteiro deve ser válido
   - As regiões não devem sobrepor
   - O comprimento deve estar correto