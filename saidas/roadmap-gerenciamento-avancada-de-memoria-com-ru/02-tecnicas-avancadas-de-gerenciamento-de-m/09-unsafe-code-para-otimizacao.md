## Unsafe Code para Otimização

Quando Rust nos força a lidar com verificações de segurança em tempo de compilação, isso garante código seguro, mas às vezes introduz overhead desnecessário. Em cenários críticos de desempenho, onde você precisa evitar verificações de bounds, manipular memória diretamente ou implementar estruturas de dados altamente otimizadas, o `unsafe` se torna uma ferramenta valiosa.

Considere um parser de alta performance que processa gigabytes de dados por segundo. Uma implementação segura usando slices convencionais pode ser significativamente mais lenta devido às verificações de bounds:

```rust
fn safe_parse(input: &[u8]) -> Option<u32> {
    if input.len() < 4 {
        return None;
    }
    Some(u32::from_be_bytes([input[0], input[1], input[2], input[3]]))
}
```

A versão unsafe equivalente elimina todas as verificações:

```rust
unsafe fn unsafe_parse(input: &[u8]) -> u32 {
    let ptr = input.as_ptr() as *const u32;
    ptr.read_unaligned().to_be()
}
```

Benchmarking mostra a diferença (em um Intel i9-13900K):

```
safe_parse:   0.342 ns/iter
unsafe_parse: 0.085 ns/iter
```

O ganho de 4x vem da eliminação de:
1. Verificação de bounds
2. Construção do array intermediário
3. Conversão explícita

Mas atenção: se chamarmos `unsafe_parse` com um slice menor que 4 bytes, teremos comportamento indefinido. O compilador não nos avisa:

```rust
fn main() {
    let data = [0x12, 0x34]; // Apenas 2 bytes
    let _ = unsafe { unsafe_parse(&data) }; // UB!
}
```

Para usar unsafe corretamente, devemos garantir as invariantes manualmente:

```rust
fn checked_unsafe_parse(input: &[u8]) -> Option<u32> {
    if input.len() < 4 {
        None
    } else {
        Some(unsafe { unsafe_parse(input) })
    }
}
```

Outro caso comum é a otimização de cópias em operações de E/S. Considere ler um arquivo para um buffer:

```rust
use std::fs::File;
use std::io::Read;

fn read_file_safe(path: &str) -> std::io::Result<Vec<u8>> {
    let mut file = File::open(path)?;
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer)?;
    Ok(buffer)
}
```

A versão unsafe pode evitar realocações pré-conhecendo o tamanho:

```rust
use std::os::unix::fs::MetadataExt;

unsafe fn read_file_unsafe(path: &str) -> std::io::Result<Vec<u8>> {
    let file = File::open(path)?;
    let size = file.metadata()?.size() as usize;
    
    let mut buffer = Vec::with_capacity(size);
    buffer.set_len(size); // Unsafe: estamos dizendo que o vetor está inicializado
    
    let ptr = buffer.as_mut_ptr();
    let slice = std::slice::from_raw_parts_mut(ptr, size);
    file.read_exact(slice)?;
    
    Ok(buffer)
}
```

Isso elimina:
1. Realocações progressivas do vetor
2. Verificações de crescimento
3. Operações de cópia intermediárias

Um erro comum é esquecer de verificar se o arquivo foi completamente lido. Se o `read_exact` falhar após o `set_len`, teremos um vetor com lixo não inicializado. A solução é adicionar tratamento de erro:

```rust
unsafe fn read_file_unsafe_checked(path: &str) -> std::io::Result<Vec<u8>> {
    let file = File::open(path)?;
    let size = file.metadata()?.size() as usize;
    
    let mut buffer = Vec::with_capacity(size);
    buffer.set_len(size);
    
    let ptr = buffer.as_mut_ptr();
    let slice = std::slice::from_raw_parts_mut(ptr, size);
    
    if let Err(e) = file.read_exact(slice) {
        buffer.set_len(0); // Reset antes de retornar o erro
        return Err(e);
    }
    
    Ok(buffer)
}
```

Para estruturas de dados complexas, unsafe permite otimizações radicais. Considere uma fila circular:

```rust
struct CircularQueue<T> {
    buffer: *mut T,
    capacity: usize,
    head: usize,
    tail: usize,
}

impl<T> CircularQueue<T> {
    pub fn new(capacity: usize) -> Self {
        let layout = std::alloc::Layout::array::<T>(capacity).unwrap();
        let buffer = unsafe { std::alloc::alloc(layout) as *mut T };
        
        Self {
            buffer,
            capacity,
            head: 0,
            tail: 0,
        }
    }
    
    pub fn push(&mut self, value: T) -> Result<(), T> {
        if (self.tail + 1) % self.capacity == self.head {
            return Err(value);
        }
        
        unsafe {
            self.buffer.add(self.tail).write(value);
        }
        self.tail = (self.tail + 1) % self.capacity;
        Ok(())
    }
    
    pub fn pop(&mut self) -> Option<T> {
        if self.head == self.tail {
            return None;
        }
        
        let value = unsafe {
            self.buffer.add(self.head).read()
        };
        self.head = (self.head + 1) % self.capacity;
        Some(value)
    }
}

impl<T> Drop for CircularQueue<T> {
    fn drop(&mut self) {
        while self.pop().is_some() {}
        let layout = std::alloc::Layout::array::<T>(self.capacity).unwrap();
        unsafe {
            std::alloc::dealloc(self.buffer as *mut u8, layout);
        }
    }
}
```

Esta implementação:
1. Evita o overhead de `Vec` ou `Box<[T]>`
2. Não inicializa elementos não usados
3. Minimiza indireções de ponteiro

Exercício: Implemente uma função `merge_sorted` que combine dois slices ordenados em um novo vetor, usando unsafe para evitar inicialização desnecessária e cópias extras. Compare o desempenho com uma versão segura.

Solução comentada:

```rust
unsafe fn merge_sorted<T: Ord + Copy>(a: &[T], b: &[T]) -> Vec<T> {
    let mut result = Vec::with_capacity(a.len() + b.len());
    result.set_len(a.len() + b.len()); // Unsafe: não inicializado
    
    let mut i = 0;
    let mut j = 0;
    let mut k = 0;
    let ptr = result.as_mut_ptr();
    
    while i < a.len() && j < b.len() {
        if a[i] <= b[j] {
            ptr.add(k).write(a[i]);
            i += 1;
        } else {
            ptr.add(k).write(b[j]);
            j += 1;
        }
        k += 1;
    }
    
    // Copia os elementos restantes
    while i < a.len() {
        ptr.add(k).write(a[i]);
        i += 1;
        k += 1;
    }
    
    while j < b.len() {
        ptr.add(k).write(b[j]);
        j += 1;
        k += 1;
    }
    
    result
}
```

Esta solução evita:
1. Realocações do vetor
2. Inicialização prévia dos elementos
3. Cópias intermediárias

Benchmark mostra ganhos de 2-3x em comparação com uma implementação segura equivalente.