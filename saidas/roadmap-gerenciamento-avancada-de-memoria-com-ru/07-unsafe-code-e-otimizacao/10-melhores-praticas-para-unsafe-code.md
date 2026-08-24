## Melhores Práticas para Unsafe Code

O `unsafe` em Rust é sua ferramenta para escapar temporariamente das garantias do compilador quando você sabe, com certeza absoluta, que o código é seguro. O problema? O compilador não pode mais verificar isso por você. Veja como usar esse poder sem se autodestruir.

### 1. Isolamento Estratégico

Todo bloco `unsafe` deve ser uma ilha mínima cercada por código seguro que garanta suas invariantes. Compare:

```rust
// PERIGOSO: invariantes não verificadas
unsafe fn raw_add(a: *const i32, b: *const i32) -> i32 {
    *a + *b
}

// SEGURO: barreira de segurança
fn safe_add(a: &i32, b: &i32) -> i32 {
    unsafe {
        // Só executamos após verificar os ponteiros
        assert!(!a.is_null() && !b.is_null());
        *a + *b
    }
}
```

A versão segura valida os pré-requisitos antes de entrar no bloco inseguro. Isso é crítico quando você recebe dados externos.

### 2. Documentação como Contrato

Cada função `unsafe` deve documentar exatamente quais invariantes o chamador deve garantir:

```rust
/// # Safety
/// - `ptr` deve apontar para um buffer de pelo menos `len` bytes
/// - `len` não pode exceder `isize::MAX`
unsafe fn init_buffer(ptr: *mut u8, len: usize) {
    std::ptr::write_bytes(ptr, 0, len);
}
```

Sem essa documentação, ninguém saberá como usar sua função corretamente. Isso inclui você mesmo daqui a 6 meses.

### 3. Testes Específicos para Unsafe

Crie testes que forçam condições extremas nos seus blocos inseguros:

```rust
#[test]
fn test_buffer_overflow() {
    let mut buf = [0u8; 16];
    unsafe {
        // Teste deliberadamente no limite
        init_buffer(buf.as_mut_ptr(), buf.len());
        
        // Isso deve falhar em debug mode
        #[cfg(debug_assertions)]
        {
            std::panic::catch_unwind(|| {
                init_buffer(buf.as_mut_ptr(), buf.len() + 1);
            }).expect_err("Deve falhar com len excessivo");
        }
    }
}
```

### 4. Zero-cost Abstractions

Encapsule o `unsafe` em abstrações seguras que impõem as invariantes em tempo de compilação:

```rust
pub struct SafeBuffer {
    ptr: *mut u8,
    len: usize,
}

impl SafeBuffer {
    pub fn new(len: usize) -> Option<Self> {
        if len > isize::MAX as usize {
            return None;
        }
        
        let layout = std::alloc::Layout::array::<u8>(len).ok()?;
        let ptr = unsafe { std::alloc::alloc(layout) };
        
        if ptr.is_null() {
            None
        } else {
            Some(Self { ptr, len })
        }
    }
    
    pub fn write_byte(&mut self, index: usize, value: u8) -> Result<(), ()> {
        if index >= self.len {
            return Err(());
        }
        
        unsafe {
            *self.ptr.add(index) = value;
        }
        
        Ok(())
    }
}

// O Drop garante que não vazamos memória
impl Drop for SafeBuffer {
    fn drop(&mut self) {
        unsafe {
            let layout = std::alloc::Layout::array::<u8>(self.len).unwrap();
            std::alloc::dealloc(self.ptr, layout);
        }
    }
}
```

### 5. Ferramentas de Auditoria

Use o Miri para detectar comportamentos indefinidos em testes:

```bash
$ cargo +nightly miri test
```

Ele captura erros como:
- Acesso a memória não inicializada
- Violações de aliasing
- Vazamentos de memória

### 6. Benchmarking Real

Antes de usar `unsafe` para performance, meça:

```rust
#[bench]
fn safe_version(b: &mut test::Bencher) {
    let mut vec = vec![0; 1000];
    b.iter(|| {
        for i in 0..vec.len() {
            vec[i] = i as i32;
        }
    });
}

#[bench]
fn unsafe_version(b: &mut test::Bencher) {
    let mut vec = vec![0; 1000];
    b.iter(|| {
        unsafe {
            let ptr = vec.as_mut_ptr();
            for i in 0..vec.len() {
                *ptr.add(i) = i as i32;
            }
        }
    });
}
```

Na prática, você frequentemente descobrirá que a versão segura já é otimizada igualmente.

### Exercício Prático

Refatore este código inseguro para uma versão segura:

```rust
unsafe fn concat_strings(a: *const u8, a_len: usize, 
                         b: *const u8, b_len: usize) -> *mut u8 {
    let layout = std::alloc::Layout::array::<u8>(a_len + b_len).unwrap();
    let ptr = std::alloc::alloc(layout);
    std::ptr::copy_nonoverlapping(a, ptr, a_len);
    std::ptr::copy_nonoverlapping(b, ptr.add(a_len), b_len);
    ptr
}
```

**Solução Comentada:**

```rust
pub struct ConcatenatedString {
    ptr: *mut u8,
    len: usize,
}

impl ConcatenatedString {
    pub fn new(a: &[u8], b: &[u8]) -> Option<Self> {
        let len = a.len().checked_add(b.len())?;
        
        if len > isize::MAX as usize {
            return None;
        }
        
        let layout = std::alloc::Layout::array::<u8>(len).ok()?;
        let ptr = unsafe { std::alloc::alloc(layout) };
        
        if ptr.is_null() {
            return None;
        }
        
        unsafe {
            std::ptr::copy_nonoverlapping(a.as_ptr(), ptr, a.len());
            std::ptr::copy_nonoverlapping(b.as_ptr(), ptr.add(a.len()), b.len());
        }
        
        Some(Self { ptr, len })
    }
    
    pub fn as_slice(&self) -> &[u8] {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len) }
    }
}

impl Drop for ConcatenatedString {
    fn drop(&mut self) {
        unsafe {
            let layout = std::alloc::Layout::array::<u8>(self.len).unwrap();
            std::alloc::dealloc(self.ptr, layout);
        }
    }
}
```

As melhorias incluem:
1. Verificação de overflow aritmético
2. Tratamento de falhas de alocação
3. Conversão segura para slice
4. Liberação automática de memória
5. Interface totalmente segura para os chamadores