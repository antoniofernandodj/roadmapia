## Manipulação Segura de Memória

Quando você precisa interagir com código C, otimizar estruturas de dados críticas ou implementar alocadores customizados, Rust permite a manipulação direta de memória através de blocos `unsafe`. O segredo está em isolar corretamente essas operações para manter as garantias de segurança.

Considere este cenário: você está construindo um parser de alto desempenho que precisa ler bytes brutos de um buffer e convertê-los em tipos Rust sem cópias. O código seguro tradicional exigiria verificações de limites e possíveis alocações intermediárias. Veja como fazer isso de forma controlada:

```rust
fn safe_read_u32(buffer: &[u8], offset: usize) -> Option<u32> {
    if offset + 4 > buffer.len() {
        return None;
    }
    let bytes = [
        buffer[offset],
        buffer[offset + 1],
        buffer[offset + 2],
        buffer[offset + 3],
    ];
    Some(u32::from_le_bytes(bytes))
}
```

Agora, a versão otimizada usando `unsafe`:

```rust
fn unsafe_read_u32(buffer: &[u8], offset: usize) -> Option<u32> {
    if offset + 4 > buffer.len() {
        return None;
    }
    
    unsafe {
        let ptr = buffer.as_ptr().add(offset) as *const u32;
        Some(ptr.read_unaligned())
    }
}
```

Ambas produzem o mesmo resultado, mas a versão `unsafe` evita:
1. A cópia dos bytes para um array intermediário
2. A conversão explícita de endianness (assumindo que o buffer já está no formato correto)

Testando ambas:

```rust
let data = vec![0x78, 0x56, 0x34, 0x12, 0x90, 0xAB, 0xCD, 0xEF];

assert_eq!(safe_read_u32(&data, 0), Some(0x12345678));
assert_eq!(unsafe_read_u32(&data, 0), Some(0x12345678));

assert_eq!(safe_read_u32(&data, 4), Some(0xEFCDAB90));
assert_eq!(unsafe_read_u32(&data, 4), Some(0xEFCDAB90));

assert_eq!(safe_read_u32(&data, 5), None);
assert_eq!(unsafe_read_u32(&data, 5), None);
```

O erro clássico aqui seria esquecer a verificação de limites antes do bloco `unsafe`. Veja o que acontece:

```rust
fn broken_read_u32(buffer: &[u8], offset: usize) -> u32 {
    unsafe {
        let ptr = buffer.as_ptr().add(offset) as *const u32;
        ptr.read_unaligned()
    }
}

// Isso compila, mas vai causar comportamento indefinido:
// let value = broken_read_u32(&[0x01, 0x02], 0); // CRASH!
```

A mensagem de erro que você pode ver em runtime seria algo como:
```
thread 'main' panicked at 'misaligned pointer dereference: address must be a multiple of 0x4 but is 0x7ffeefbff654'
```

Para encapsular corretamente operações `unsafe`, siga este padrão:
1. Valide todas as pré-condições antes do bloco `unsafe`
2. Isole a operação perigosa no menor escopo possível
3. Garanta que as pós-condições mantêm as invariantes de Rust

Um exemplo mais complexo: implementação segura de um buffer circular:

```rust
pub struct CircularBuffer<T> {
    data: Vec<T>,
    head: usize,
    tail: usize,
}

impl<T> CircularBuffer<T> {
    pub fn new(capacity: usize) -> Self {
        CircularBuffer {
            data: Vec::with_capacity(capacity),
            head: 0,
            tail: 0,
        }
    }

    pub fn push(&mut self, item: T) -> Result<(), T> {
        if self.is_full() {
            return Err(item);
        }
        
        unsafe {
            let ptr = self.data.as_mut_ptr();
            ptr.add(self.tail).write(item);
        }
        
        self.tail = (self.tail + 1) % self.data.capacity();
        Ok(())
    }

    pub fn pop(&mut self) -> Option<T> {
        if self.is_empty() {
            return None;
        }
        
        let item = unsafe {
            let ptr = self.data.as_ptr();
            ptr.add(self.head).read()
        };
        
        self.head = (self.head + 1) % self.data.capacity();
        Some(item)
    }

    fn is_full(&self) -> bool {
        (self.tail + 1) % self.data.capacity() == self.head
    }

    fn is_empty(&self) -> bool {
        self.head == self.tail
    }
}
```

Este buffer evita realocações e mantém a segurança através de:
- Verificação explícita de limites antes de qualquer operação `unsafe`
- Uso de `ptr::write` e `ptr::read` para evitar chamadas a `drop` desnecessárias
- Manutenção cuidadosa dos índices `head` e `tail`

Exercício: Implemente uma função `swap_nonoverlapping<T>(x: &mut [T], y: &mut [T])` que troca os conteúdos de duas fatias mutáveis sem alocação temporária, verificando que:
1. As fatias têm o mesmo comprimento
2. As regiões de memória não se sobrepõem

Solução comentada:

```rust
fn swap_nonoverlapping<T>(x: &mut [T], y: &mut [T]) {
    assert_eq!(x.len(), y.len(), "Slices must have equal length");
    
    // Verifica se os slices não se sobrepõem
    let x_ptr = x.as_ptr() as usize;
    let y_ptr = y.as_ptr() as usize;
    let len_bytes = std::mem::size_of::<T>() * x.len();
    assert!(
        x_ptr + len_bytes <= y_ptr || y_ptr + len_bytes <= x_ptr,
        "Slices must not overlap"
    );
    
    unsafe {
        let x_ptr = x.as_mut_ptr();
        let y_ptr = y.as_mut_ptr();
        
        for i in 0..x.len() {
            std::ptr::swap(x_ptr.add(i), y_ptr.add(i));
        }
    }
}

// Teste
let mut a = [1, 2, 3];
let mut b = [4, 5, 6];
swap_nonoverlapping(&mut a, &mut b);
assert_eq!(a, [4, 5, 6]);
assert_eq!(b, [1, 2, 3]);
```

Pontos-chave da solução:
1. Verificação explícita de tamanhos iguais
2. Cálculo de sobreposição de memória baseado em endereços brutos
3. Uso de `ptr::swap` para trocar elementos individualmente
4. Manutenção das invariantes de borrowing do Rust (as fatias são mutáveis exclusivas)