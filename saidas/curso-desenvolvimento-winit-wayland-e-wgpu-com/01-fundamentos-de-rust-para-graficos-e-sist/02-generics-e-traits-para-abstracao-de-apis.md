## Generics e Traits para Abstração de APIs Gráficas

Considere um jogo que precisa rodar tanto em Vulkan quanto em DirectX 12. Duplicar toda a lógica de renderização para cada API seria insustentável. Em Rust, resolvemos isso com generics e traits, criando uma única interface que abstrai as diferenças entre backends gráficos.

Vamos construir um sistema de buffers de vértices que funcione em múltiplas APIs. Primeiro, definimos o trait `VertexBuffer`:

```rust
pub trait VertexBuffer {
    type Handle;
    
    fn new(vertices: &[f32]) -> Self::Handle;
    fn bind(&self, handle: &Self::Handle);
    fn destroy(&self, handle: Self::Handle);
}
```

O tipo associado `Handle` permite que cada implementação defina seu próprio tipo de identificador de recurso. Vejamos uma implementação simulada para Vulkan:

```rust
pub struct VulkanBackend {
    device: vk::Device,
}

impl VertexBuffer for VulkanBackend {
    type Handle = vk::Buffer;
    
    fn new(&self, vertices: &[f32]) -> vk::Buffer {
        println!("Alocando buffer de vértices Vulkan");
        // Implementação real criaria um vk::Buffer
        vk::Buffer::new()
    }
    
    fn bind(&self, handle: &vk::Buffer) {
        println!("Vinculando buffer Vulkan {}", handle.id());
    }
    
    fn destroy(&self, handle: vk::Buffer) {
        println!("Liberando buffer Vulkan {}", handle.id());
    }
}
```

E para DirectX 12:

```rust
pub struct Dx12Backend {
    device: dx12::Device,
}

impl VertexBuffer for Dx12Backend {
    type Handle = dx12::Buffer;
    
    fn new(&self, vertices: &[f32]) -> dx12::Buffer {
        println!("Alocando buffer de vértices DX12");
        dx12::Buffer::new()
    }
    
    fn bind(&self, handle: &dx12::Buffer) {
        println!("Vinculando buffer DX12 {}", handle.id());
    }
    
    fn destroy(&self, handle: dx12::Buffer) {
        println!("Liberando buffer DX12 {}", handle.id());
    }
}
```

Agora podemos escrever código genérico que funciona com qualquer backend:

```rust
fn render_mesh<B: VertexBuffer>(backend: &B, vertices: &[f32]) {
    let buffer = backend.new(vertices);
    backend.bind(&buffer);
    // Lógica de renderização...
    backend.destroy(buffer);
}
```

Testando com ambos os backends:

```rust
let vulkan = VulkanBackend { device: vk::Device::new() };
let dx12 = Dx12Backend { device: dx12::Device::new() };

let vertices = [0.0, 0.5, 0.5, -0.5, -0.5, -0.5];

render_mesh(&vulkan, &vertices);
render_mesh(&dx12, &vertices);
```

Saída esperada:
```
Alocando buffer de vértices Vulkan
Vinculando buffer Vulkan 1
Liberando buffer Vulkan 1
Alocando buffer de vértices DX12
Vinculando buffer DX12 1
Liberando buffer DX12 1
```

Um erro comum é esquecer de tornar o handle genérico em toda a cadeia de chamadas. Veja o que acontece se tentarmos armazenar o buffer:

```rust
struct MeshRenderer<B: VertexBuffer> {
    vertex_buffer: B::Handle,  // Erro: missing lifetime specifier
}
```

O compilador reclama:
```
error[E0106]: missing lifetime specifier
  --> src/main.rs:25:21
   |
25 |     vertex_buffer: B::Handle,
   |                    ^^^^^^^^^ expected named lifetime parameter
```

A solução é propagar o parâmetro de lifetime:

```rust
struct MeshRenderer<'a, B: VertexBuffer> {
    vertex_buffer: <B as VertexBuffer>::Handle,
    _phantom: std::marker::PhantomData<&'a ()>,
}
```

**Exercício**: Crie um trait `Texture` com métodos para carregar, vincular e liberar texturas, e implemente-o para dois backends gráficos diferentes. Inclua um método `set_filter_mode` que aceite um enum `FilterMode` (Nearest, Linear).

**Solução**:

```rust
pub enum FilterMode {
    Nearest,
    Linear,
}

pub trait Texture {
    type Handle;
    
    fn load(&self, path: &str) -> Self::Handle;
    fn bind(&self, handle: &Self::Handle, slot: u32);
    fn set_filter_mode(&self, handle: &Self::Handle, mode: FilterMode);
    fn destroy(&self, handle: Self::Handle);
}

impl Texture for VulkanBackend {
    type Handle = vk::Image;
    
    fn load(&self, path: &str) -> vk::Image {
        println!("Carregando textura Vulkan: {}", path);
        vk::Image::new()
    }
    
    fn bind(&self, handle: &vk::Image, slot: u32) {
        println!("Vinculando textura Vulkan no slot {}", slot);
    }
    
    fn set_filter_mode(&self, handle: &vk::Image, mode: FilterMode) {
        println!("Definindo modo de filtro Vulkan para {:?}", mode);
    }
    
    fn destroy(&self, handle: vk::Image) {
        println!("Liberando textura Vulkan");
    }
}
```