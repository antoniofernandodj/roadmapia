## Ownership e Borrowing em Contextos Gráficos

Um buffer de vértices em uma aplicação gráfica é um recurso caro: alocado na GPU, ocupando memória dedicada e exigindo sincronização cuidadosa entre CPU e GPU. Em C++, você precisaria lembrar de liberar esse recurso manualmente. Em Rust, o sistema de ownership resolve isso automaticamente:

```rust
struct GpuBuffer {
    handle: u32,
    size: usize,
}

impl Drop for GpuBuffer {
    fn drop(&mut self) {
        unsafe {
            glDeleteBuffers(1, &self.handle); // Simulação de liberação de recurso GPU
        }
        println!("Buffer {} liberado", self.handle);
    }
}

fn create_buffer() -> GpuBuffer {
    let handle = unsafe { glGenBuffers(1) }; // Simulação de alocação
    GpuBuffer { handle, size: 1024 }
}

fn main() {
    let buffer = create_buffer();
    println!("Buffer criado: {}", buffer.handle);
    // Quando `buffer` sai do escopo, Drop::drop() é chamado automaticamente
}
```
Saída:
```
Buffer criado: 1
Buffer 1 liberado
```

O problema aparece quando queremos compartilhar esse recurso entre múltiplos pipelines de renderização. Tentar clonar o buffer diretamente causaria dupla liberação:

```rust
let buffer1 = create_buffer();
let buffer2 = buffer1; // Movimento de ownership
// println!("{}", buffer1.handle); // Erro! buffer1 foi movido
```

Para compartilhamento seguro, usamos `Rc` (Reference Counting) quando o recurso é imutável:

```rust
use std::rc::Rc;

let buffer_rc = Rc::new(create_buffer());
let buffer_clone1 = Rc::clone(&buffer_rc);
let buffer_clone2 = Rc::clone(&buffer_rc);

println!("Contagem de referências: {}", Rc::strong_count(&buffer_rc));
```

Mas em gráficos, frequentemente precisamos de mutabilidade compartilhada. Para isso, combinamos `Rc` com `RefCell`:

```rust
use std::cell::RefCell;

struct Texture {
    id: u32,
    label: String,
}

let texture = Rc::new(RefCell::new(Texture {
    id: 1,
    label: "Albedo".to_string(),
}));

// Em um thread de renderização:
texture.borrow_mut().label = "NormalMap".to_string();

// Em outro thread:
println!("Texture: {}", texture.borrow().label);
```

Cuidado com borrows em tempo de execução! Este código compila mas panica:

```rust
let mut borrow1 = texture.borrow_mut();
let mut borrow2 = texture.borrow_mut(); // Panic: already mutably borrowed
```

Para recursos gráficos compartilhados entre threads, substitua `Rc` por `Arc` (Atomic Reference Counting) e `RefCell` por `Mutex`:

```rust
use std::sync::{Arc, Mutex};

let shared_texture = Arc::new(Mutex::new(Texture {
    id: 2,
    label: "BaseColor".to_string(),
}));

// Thread 1:
let t = shared_texture.lock().unwrap();
println!("Thread 1: {}", t.label);

// Thread 2:
let t = shared_texture.lock().unwrap();
println!("Thread 2: {}", t.label);
```

### Exercício
Crie um struct `ShaderProgram` que encapsula um handle de shader OpenGL (simule com `u32`). Implemente:
1. RAII com `Drop` para liberar o shader
2. Método `compile()` que retorna `Result<Self, String>`
3. Uso de `Arc<Mutex<Self>>` para compartilhamento thread-safe

Solução:

```rust
use std::sync::{Arc, Mutex};

struct ShaderProgram {
    handle: u32,
    source: String,
}

impl Drop for ShaderProgram {
    fn drop(&mut self) {
        println!("Liberando shader {}", self.handle);
    }
}

impl ShaderProgram {
    fn new(source: &str) -> Result<Self, String> {
        // Simulação de compilação
        if source.contains("error") {
            return Err("Erro de sintaxe".into());
        }
        Ok(Self {
            handle: 1, // ID fictício
            source: source.to_string(),
        })
    }
}

fn main() {
    let shader = Arc::new(Mutex::new(
        ShaderProgram::new("void main() {}").unwrap()
    ));
    
    let shader_clone = Arc::clone(&shader);
    let handle = shader_clone.lock().unwrap().handle;
    println!("Shader handle: {}", handle);
}
```