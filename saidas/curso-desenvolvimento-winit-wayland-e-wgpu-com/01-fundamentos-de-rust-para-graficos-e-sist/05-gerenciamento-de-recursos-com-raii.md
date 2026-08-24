## Gerenciamento de Recursos com RAII

Em aplicações gráficas, cada textura, buffer ou shader consome memória valiosa na GPU. Vazamentos desses recursos causam crashes e degradação de performance. Veja o que acontece quando alocamos um buffer sem liberação:

```rust
struct GpuBuffer {
    handle: u32,
    size: usize,
}

impl GpuBuffer {
    fn new(size: usize) -> Self {
        println!("Alocando buffer GPU de {} bytes", size);
        GpuBuffer { handle: 1, size } // Simulação de alocação
    }
}

fn main() {
    let buffer = GpuBuffer::new(1024);
    // Esquecemos de liberar o buffer!
}
```

A saída mostra apenas a alocação, sem liberação. Em sistemas reais, isso acumularia buffers não liberados a cada execução. A solução está no RAII (Resource Acquisition Is Initialization), onde o recurso é liberado quando o objeto sai de escopo:

```rust
impl Drop for GpuBuffer {
    fn drop(&mut self) {
        println!("Liberando buffer GPU (handle: {})", self.handle);
    }
}

fn main() {
    let buffer = GpuBuffer::new(1024);
    // Buffer será liberado automaticamente aqui
}
```

Agora a saída mostra ambos os eventos:
```
Alocando buffer GPU de 1024 bytes
Liberando buffer GPU (handle: 1)
```

### Erro Comum: Movimento Prematuro

Um padrão problemático ocorre ao transferir ownership de recursos gráficos sem considerar seu ciclo de vida:

```rust
fn create_and_forget() -> u32 {
    let buffer = GpuBuffer::new(2048);
    buffer.handle // Retorna apenas o handle, perdendo o RAII
}

fn main() {
    let handle = create_and_forget();
    println!("Handle obtido: {}", handle);
    // O buffer foi liberado quando `buffer` saiu de escopo!
}
```

Isso produz:
```
Alocando buffer GPU de 2048 bytes
Liberando buffer GPU (handle: 1)
Handle obtido: 1
```

A solução é manter a estrutura inteira ou usar contagem de referências:

```rust
use std::rc::Rc;

fn main() {
    let buffer = Rc::new(GpuBuffer::new(2048));
    let handle = buffer.handle;
    println!("Handle mantido: {}", handle);
    // Buffer só será liberado quando todas as Rc forem dropadas
}
```

### RAII com Recursos Compartilhados

Para recursos usados entre threads, `Arc` substitui `Rc`:

```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let buffer = Arc::new(GpuBuffer::new(4096));
    
    let buffer_clone = Arc::clone(&buffer);
    thread::spawn(move || {
        println!("Thread acessando handle: {}", buffer_clone.handle);
    }).join().unwrap();
    
    println!("Handle principal: {}", buffer.handle);
}
```

### Exercício Prático

Crie um tipo `Texture` que implementa RAII, com um método `bind()` que simula uso (apenas imprime "Texture bound"). Garanta que a textura seja liberada após o uso, mesmo se `bind()` for chamado múltiplas vezes.

<details>
<summary>Solução</summary>

```rust
struct Texture {
    id: u32,
}

impl Texture {
    fn new(id: u32) -> Self {
        println!("Criando texture {}", id);
        Texture { id }
    }

    fn bind(&self) {
        println!("Texture {} bound", self.id);
    }
}

impl Drop for Texture {
    fn drop(&mut self) {
        println!("Liberando texture {}", self.id);
    }
}

fn main() {
    let tex = Texture::new(1);
    tex.bind();
    tex.bind();
}
```

Saída esperada:
```
Criando texture 1
Texture 1 bound
Texture 1 bound
Liberando texture 1
```
</details>