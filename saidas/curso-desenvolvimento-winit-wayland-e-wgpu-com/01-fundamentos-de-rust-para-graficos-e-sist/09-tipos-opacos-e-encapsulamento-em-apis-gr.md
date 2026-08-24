## Tipos Opacos e Encapsulamento em APIs Gráficas

Quando você cria uma API gráfica em Rust, frequentemente precisa esconder detalhes de implementação para garantir segurança e flexibilidade. Considere um handle para um buffer de vértices na GPU: o usuário não deve acessar diretamente o ID interno ou modificar o estado do buffer de formas inválidas. É aqui que tipos opacos entram em cena.

Um tipo opaco é uma struct que encapsula dados privados, expondo apenas operações seguras. Veja como isso funciona na prática:

```rust
mod gfx {
    #[derive(Debug)]
    pub struct VertexBuffer {
        handle: u32,  // ID interno da GPU
        size: usize,
        // Outros metadados necessários
    }

    impl VertexBuffer {
        pub fn new(data: &[f32]) -> Result<Self, String> {
            // Simulação: aloca buffer na GPU
            let handle = unsafe { gl::GenBuffers(1) };
            unsafe {
                gl::BindBuffer(gl::ARRAY_BUFFER, handle);
                gl::BufferData(
                    gl::ARRAY_BUFFER,
                    (data.len() * std::mem::size_of::<f32>()) as isize,
                    data.as_ptr() as *const _,
                    gl::STATIC_DRAW,
                );
            }
            
            Ok(Self {
                handle,
                size: data.len(),
            })
        }

        pub fn bind(&self) {
            unsafe { gl::BindBuffer(gl::ARRAY_BUFFER, self.handle) };
        }

        pub fn size(&self) -> usize {
            self.size
        }
    }

    impl Drop for VertexBuffer {
        fn drop(&mut self) {
            unsafe { gl::DeleteBuffers(1, &self.handle) };
        }
    }
}
```

O erro mais comum é tentar acessar o campo `handle` diretamente:

```rust
fn main() {
    let buffer = gfx::VertexBuffer::new(&[0.0, 1.0, 2.0]).unwrap();
    println!("Handle interno: {}", buffer.handle); // ERRO!
}
```

A mensagem de erro será:
```
error[E0616]: field `handle` of struct `gfx::VertexBuffer` is private
```

Para usar corretamente:

```rust
fn main() {
    let vertices = vec![0.0, 1.0, 2.0, 3.0];
    let buffer = gfx::VertexBuffer::new(&vertices).unwrap();
    
    println!("Buffer criado com {} elementos", buffer.size());
    buffer.bind();
    
    // Renderização ocorreria aqui
}
```

### Por que isso importa em gráficos?

1. **Segurança**: Evita que usuários modifiquem handles da GPU diretamente, o que poderia corromper o estado da renderização
2. **Flexibilidade**: Você pode mudar a implementação interna (OpenGL para Vulkan, por exemplo) sem quebrar código cliente
3. **RAII automático**: O `Drop` implementation garante que recursos da GPU sejam liberados mesmo em caso de panic

### Padrão avançado: Builder para configuração complexa

Para objetos gráficos com muitas opções de configuração, combine tipos opacos com o padrão builder:

```rust
mod gfx {
    pub struct TextureBuilder {
        width: u32,
        height: u32,
        format: TextureFormat,
        mipmaps: bool,
    }

    impl TextureBuilder {
        pub fn new(width: u32, height: u32) -> Self {
            Self {
                width,
                height,
                format: TextureFormat::RGBA8,
                mipmaps: false,
            }
        }

        pub fn format(mut self, format: TextureFormat) -> Self {
            self.format = format;
            self
        }

        pub fn with_mipmaps(mut self, enable: bool) -> Self {
            self.mipmaps = enable;
            self
        }

        pub fn build(self) -> Result<Texture, String> {
            // Implementação real criaria a textura na GPU
            Ok(Texture {
                handle: 123, // Simulado
                width: self.width,
                height: self.height,
            })
        }
    }

    pub struct Texture {
        handle: u32,
        width: u32,
        height: u32,
    }

    pub enum TextureFormat {
        RGBA8,
        RGB8,
        // Outros formatos...
    }
}
```

Uso correto:

```rust
fn create_texture() -> Result<(), String> {
    let texture = gfx::TextureBuilder::new(256, 256)
        .format(gfx::TextureFormat::RGBA8)
        .with_mipmaps(true)
        .build()?;
    
    Ok(())
}
```

### Exercício Prático

Implemente um tipo opaco `ShaderProgram` que:
1. Encapsule a compilação de vertex e fragment shaders
2. Forneça um método `uniform_location` seguro (retornando `Option`)
3. Implemente RAII para deletar o programa ao sair de escopo

Solução comentada:

```rust
mod gfx {
    pub struct ShaderProgram {
        handle: u32,
    }

    impl ShaderProgram {
        pub fn new(vertex_src: &str, fragment_src: &str) -> Result<Self, String> {
            // Implementação simplificada
            let handle = unsafe { gl::CreateProgram() };
            Ok(Self { handle })
        }

        pub fn uniform_location(&self, name: &str) -> Option<u32> {
            // Retorna None se o uniform não existir
            Some(unsafe { gl::GetUniformLocation(self.handle, name.as_ptr() as *const i8) as u32 })
        }
    }

    impl Drop for ShaderProgram {
        fn drop(&mut self) {
            unsafe { gl::DeleteProgram(self.handle) };
        }
    }
}
```