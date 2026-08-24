## Manipulação Segura de Ponteiros Brutos

Quando precisamos interoperar com código C ou acessar memória de forma direta para otimizações críticas, Rust nos permite usar ponteiros brutos (*raw pointers*). Ao contrário das referências seguras (`&T`, `&mut T`), os ponteiros brutos não têm garantias de segurança em tempo de compilação. A responsabilidade de usá-los corretamente é inteiramente do programador.

### O Problema Concreto: Integração com Bibliotecas C

Suponha que você está trabalhando com uma biblioteca de processamento de imagens escrita em C, que fornece esta função:

```c
// Biblioteca C
void process_pixels(unsigned char* pixels, int width, int height);
```

Para chamá-la de Rust, precisamos passar um ponteiro para os dados dos pixels. Como Rust não permite referências mutáveis soltas, usaremos ponteiros brutos.

### Criando e Convertendo Ponteiros Brutos

Em Rust, existem dois tipos de ponteiros brutos:
- `*const T` - ponteiro imutável
- `*mut T` - ponteiro mutável

Vamos criar um buffer de pixels e obter um ponteiro bruto para ele:

```rust
fn main() {
    let mut pixels: Vec<u8> = vec![0; 1024]; // Buffer de 1024 pixels
    
    // Convertendo para ponteiro bruto
    let pixels_ptr: *mut u8 = pixels.as_mut_ptr();
    
    // Chamada segura dentro de bloco unsafe
    unsafe {
        // Simulando a chamada à função C
        process_pixels(pixels_ptr, 32, 32);
    }
    
    println!("Primeiro pixel: {}", pixels[0]);
}

// Função que simula o processamento C
unsafe fn process_pixels(pixels: *mut u8, width: i32, height: i32) {
    // Acessando o primeiro pixel
    *pixels = 255; // Modificando o valor
}
```

Saída:
```
Primeiro pixel: 255
```

### Os Perigos do Acesso Incorreto

Se tentarmos acessar o ponteiro após o vetor ser liberado, teremos comportamento indefinido:

```rust
fn main() {
    let pixels_ptr = {
        let mut pixels = vec![0; 1024];
        pixels.as_mut_ptr()
    }; // pixels é liberado aqui
    
    unsafe {
        *pixels_ptr = 255; // COMPORTAMENTO INDEFINIDO!
    }
}
```

O compilador não avisa sobre este erro. O programa pode travar, corromper memória ou parecer funcionar - resultados imprevisíveis.

### Boas Práticas para Trabalhar com Ponteiros Brutos

1. **Sempre mantenha o dono dos dados vivo**: O objeto original deve existir enquanto o ponteiro bruto estiver em uso.

2. **Limite o escopo do unsafe**: Encapsule o código unsafe em funções seguras sempre que possível.

3. **Verifique os limites manualmente**: Ponteiros brutos não fazem verificação de limites.

Exemplo de encapsulamento seguro:

```rust
struct PixelBuffer {
    data: Vec<u8>,
    width: usize,
    height: usize,
}

impl PixelBuffer {
    pub fn new(width: usize, height: usize) -> Self {
        PixelBuffer {
            data: vec![0; width * height * 3], // 3 bytes por pixel (RGB)
            width,
            height,
        }
    }
    
    pub fn process(&mut self) {
        unsafe {
            process_pixels(
                self.data.as_mut_ptr(),
                self.width as i32,
                self.height as i32
            );
        }
    }
}
```

### Convertendo entre Ponteiros e Referências

Podemos criar referências seguras a partir de ponteiros brutos, mas isso requer cuidado:

```rust
fn main() {
    let mut x = 42;
    let x_ptr: *mut i32 = &mut x;
    
    unsafe {
        let x_ref: &mut i32 = &mut *x_ptr;
        *x_ref += 1;
    }
    
    println!("x = {}", x); // x = 43
}
```

A conversão inversa (de referência para ponteiro) é sempre segura:

```rust
fn get_raw_pointer(r: &i32) -> *const i32 {
    r as *const i32
}
```

### Exercício Prático

Implemente uma função segura `split_at_mut_raw` que divide um slice em duas partes usando ponteiros brutos, sem usar a função padrão `split_at_mut`. A função deve ter esta assinatura:

```rust
fn split_at_mut_raw(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32])
```

**Solução comentada:**

```rust
fn split_at_mut_raw(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
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

fn main() {
    let mut data = vec![1, 2, 3, 4, 5];
    let (left, right) = split_at_mut_raw(&mut data, 2);
    
    println!("Left: {:?}", left);  // [1, 2]
    println!("Right: {:?}", right); // [3, 4, 5]
}
```

Pontos-chave da solução:
1. Obtemos um ponteiro bruto mutável para o início do slice
2. Verificamos que o ponto de divisão é válido
3. Usamos `from_raw_parts_mut` para criar os novos slices
4. A função é segura porque todas as verificações são feitas antes do bloco unsafe
5. O borrow checker entende que as duas partes do slice não se sobrepõem