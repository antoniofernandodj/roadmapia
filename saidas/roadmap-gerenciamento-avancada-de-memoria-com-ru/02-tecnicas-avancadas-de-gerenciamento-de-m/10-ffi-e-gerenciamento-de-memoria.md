## FFI e Gerenciamento de Memória

Quando Rust precisa interoperar com bibliotecas escritas em C (como OpenSSL, SQLite ou sistemas de UI nativos), surge um desafio fundamental: quem é responsável pela alocação e liberação de memória? A ponte entre os dois mundos (FFI - Foreign Function Interface) exige atenção redobrada com o ciclo de vida dos dados.

Considere este cenário comum: você quer usar a função `getenv` da libc para ler uma variável de ambiente:

```rust
use std::ffi::CStr;
use std::os::raw::c_char;

extern "C" {
    fn getenv(name: *const c_char) -> *mut c_char;
}

fn main() {
    let var_name = std::ffi::CString::new("PATH").unwrap();
    let c_path = unsafe { getenv(var_name.as_ptr()) };
    
    if !c_path.is_null() {
        let path = unsafe { CStr::from_ptr(c_path) };
        println!("PATH: {:?}", path.to_str().unwrap());
    }
}
```

A saída mostra seu PATH atual:
```
PATH: "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

O problema central aparece quando tentamos liberar a memória:

```rust
// Código perigoso!
unsafe {
    libc::free(c_path as *mut libc::c_void); // UB se getenv retornou ponteiro para estático
}
```

Isso pode causar um crash, pois `getenv` retorna um ponteiro para dados estáticos em muitas implementações. O compilador não avisa - você só descobre em runtime.

### Estratégias de Gerenciamento

1. **Borrowing Seguro** (quando a lib externa mantém ownership):

```rust
extern "C" {
    // Função que retorna ponteiro para dados gerenciados externamente
    fn get_error_message() -> *const c_char;
}

fn safe_wrapper() -> Option<&'static str> {
    let c_msg = unsafe { get_error_message() };
    if c_msg.is_null() {
        None
    } else {
        Some(unsafe { CStr::from_ptr(c_msg) }.to_str().unwrap())
    }
}
```

2. **Transferência de Ownership** (quando Rust deve liberar):

```rust
extern "C" {
    fn create_buffer(size: usize) -> *mut c_char;
    fn free_buffer(ptr: *mut c_char);
}

struct ForeignBuffer {
    ptr: *mut c_char,
    size: usize,
}

impl Drop for ForeignBuffer {
    fn drop(&mut self) {
        unsafe { free_buffer(self.ptr) }
    }
}
```

### Erro Comum: Lifetime Mismatch

Este código parece inocente:

```rust
fn get_temp_path() -> &str {
    let c_path = unsafe { libc::getenv(b"TMPDIR\0".as_ptr() as *const _) };
    let path = unsafe { CStr::from_ptr(c_path) };
    path.to_str().unwrap() // ERRO: retornando referência a local
}
```

O compilador avisa:
```
error[E0515]: cannot return value referencing local variable `path`
```

A correção exige alocação:

```rust
fn get_temp_path() -> String {
    // ... mesmo código anterior
    path.to_str().unwrap().to_owned() // Aloca nova String
}
```

### Tipos Especiais para FFI

Para buffers mutáveis compartilhados:

```rust
use std::slice;

extern "C" {
    fn process_data(input: *const u8, output: *mut u8, len: usize);
}

fn process_wrapper(input: &[u8]) -> Vec<u8> {
    let mut output = vec![0u8; input.len()];
    unsafe {
        process_data(
            input.as_ptr(),
            output.as_mut_ptr(),
            input.len()
        );
    }
    output
}
```

### Exercício Prático

Implemente um wrapper seguro para esta API C:

```c
// api.h
char* create_user(const char* name, int age);
void free_user(char* user_str);
```

Solução comentada:

```rust
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};

pub struct UserString {
    ptr: *mut c_char,
}

impl UserString {
    pub fn new(name: &str, age: i32) -> Option<Self> {
        let c_name = CString::new(name).ok()?;
        unsafe {
            let ptr = create_user(c_name.as_ptr(), age as c_int);
            if ptr.is_null() {
                None
            } else {
                Some(Self { ptr })
            }
        }
    }

    pub fn as_str(&self) -> Option<&str> {
        unsafe { CStr::from_ptr(self.ptr) }.to_str().ok()
    }
}

impl Drop for UserString {
    fn drop(&mut self) {
        unsafe { free_user(self.ptr) }
    }
}

extern "C" {
    fn create_user(name: *const c_char, age: c_int) -> *mut c_char;
    fn free_user(ptr: *mut c_char);
}
```

Pontos-chave:
1. Encapsulamento do ponteiro bruto em um tipo seguro
2. Tratamento adequado de falhas (Option)
3. Conversão segura para &str quando necessário
4. Liberação automática via trait Drop