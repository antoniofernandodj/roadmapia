## FFI e Gerenciamento de Memória

Quando Rust precisa interoperar com bibliotecas escritas em C ou outras linguagens, o Foreign Function Interface (FFI) entra em ação. O problema central é que essas linguagens não seguem as regras de ownership do Rust, criando situações onde:

1. Memória alocada em Rust pode ser liberada pelo código C
2. Ponteiros gerenciados por C podem vazar em Rust
3. Estruturas com layouts de memória diferentes causam comportamento indefinido

Vamos resolver isso na prática com um exemplo completo. Suponha que temos uma biblioteca C que gerencia buffers de áudio:

```c
// audio_buffer.h
typedef struct {
    float* data;
    size_t length;
} AudioBuffer;

AudioBuffer* create_buffer(size_t length);
void process_buffer(AudioBuffer* buffer);
void free_buffer(AudioBuffer* buffer);
```

Para usar isso em Rust, precisamos criar um wrapper seguro:

```rust
use std::os::raw::{c_float, c_size_t};
use std::mem::MaybeUninit;

// Definições FFI correspondentes ao cabeçalho C
#[repr(C)]
pub struct AudioBuffer {
    data: *mut c_float,
    length: c_size_t,
}

extern "C" {
    fn create_buffer(length: c_size_t) -> *mut AudioBuffer;
    fn process_buffer(buffer: *mut AudioBuffer);
    fn free_buffer(buffer: *mut AudioBuffer);
}

// Wrapper seguro
pub struct SafeAudioBuffer {
    inner: *mut AudioBuffer,
}

impl SafeAudioBuffer {
    pub fn new(length: usize) -> Option<Self> {
        let ptr = unsafe { create_buffer(length as c_size_t) };
        if ptr.is_null() {
            None
        } else {
            Some(Self { inner: ptr })
        }
    }

    pub fn process(&mut self) {
        unsafe { process_buffer(self.inner) }
    }
}

impl Drop for SafeAudioBuffer {
    fn drop(&mut self) {
        if !self.inner.is_null() {
            unsafe { free_buffer(self.inner) }
        }
    }
}
```

O erro mais comum aqui seria esquecer de implementar o `Drop`, causando vazamento de memória:

```rust,ignore
// ERRO COMUM: esquecer de liberar a memória
let buffer = SafeAudioBuffer::new(1024).unwrap();
// buffer é descartado aqui sem chamar free_buffer
```

A mensagem de erro não apareceria, mas o valgrind reportaria:
```
==12345== 4,096 bytes in 1 blocks are definitely lost in loss record 1 of 1
```

A versão correta com `Drop` evita isso. Agora vamos lidar com um caso mais complexo: quando o código C modifica um buffer alocado pelo Rust:

```rust
pub fn process_rust_data(data: &mut [f32]) {
    let mut buffer = AudioBuffer {
        data: data.as_mut_ptr(),
        length: data.len() as c_size_t,
    };
    
    unsafe {
        process_buffer(&mut buffer as *mut AudioBuffer);
    }
}
```

Perigo oculto: se `process_buffer` armazenar o ponteiro para uso posterior, teremos um dangling pointer. A solução é usar lifetimes para garantir que o buffer C não sobreviva aos dados Rust:

```rust
pub struct BorrowedAudioBuffer<'a> {
    inner: AudioBuffer,
    _marker: std::marker::PhantomData<&'a mut [f32]>,
}

impl<'a> BorrowedAudioBuffer<'a> {
    pub fn new(data: &'a mut [f32]) -> Self {
        Self {
            inner: AudioBuffer {
                data: data.as_mut_ptr(),
                length: data.len() as c_size_t,
            },
            _marker: std::marker::PhantomData,
        }
    }
    
    pub fn process(&mut self) {
        unsafe {
            process_buffer(&mut self.inner as *mut AudioBuffer);
        }
    }
}
```

O `PhantomData` garante que o compilador entenda a relação de lifetime entre o buffer e os dados subjacentes.

**Exercício Prático**: Crie um wrapper seguro para esta função C:

```c
// Retorna um novo buffer preenchido com valores do buffer de entrada
// Deve ser liberado com free_processed_buffer
typedef struct {
    int* data;
    size_t length;
} IntBuffer;

IntBuffer* process_int_buffer(const IntBuffer* input);
void free_processed_buffer(IntBuffer* buffer);
```

**Solução Comentada**:

```rust
use std::os::raw::{c_int, c_size_t};

#[repr(C)]
pub struct IntBuffer {
    data: *const c_int,
    length: c_size_t,
}

extern "C" {
    fn process_int_buffer(input: *const IntBuffer) -> *mut IntBuffer;
    fn free_processed_buffer(buffer: *mut IntBuffer);
}

pub struct SafeIntBuffer {
    inner: *mut IntBuffer,
}

impl SafeIntBuffer {
    pub fn process(input: &[i32]) -> Option<Self> {
        let c_buffer = IntBuffer {
            data: input.as_ptr(),
            length: input.len() as c_size_t,
        };
        
        let ptr = unsafe { process_int_buffer(&c_buffer) };
        if ptr.is_null() {
            None
        } else {
            Some(Self { inner: ptr })
        }
    }
    
    pub fn as_slice(&self) -> &[i32] {
        unsafe {
            std::slice::from_raw_parts(
                (*self.inner).data,
                (*self.inner).length as usize
            )
        }
    }
}

impl Drop for SafeIntBuffer {
    fn drop(&mut self) {
        if !self.inner.is_null() {
            unsafe { free_processed_buffer(self.inner) }
        }
    }
}
```

Pontos-chave da solução:
1. Conversão segura de slices Rust para buffers C
2. Gerenciamento automático do ciclo de vida com `Drop`
3. Método para acessar os dados processados como slice Rust
4. Tratamento de ponteiros nulos (caso a alocação falhe)