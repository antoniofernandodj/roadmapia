## Erros e Logging em Aplicações Gráficas

Em aplicações gráficas, o tratamento de erros e o logging são críticos para identificar problemas durante a renderização, especialmente quando se trabalha com APIs de baixo nível como WGPU. A falta de logs adequados pode tornar difícil rastrear problemas como falhas na criação de buffers, shaders inválidos ou sincronização inadequada entre threads.

### Estratégias de Tratamento de Erros

Um padrão comum em Rust é o uso do tipo `Result<T, E>` para lidar com operações que podem falhar. Em contextos gráficos, isso é especialmente útil para capturar erros relacionados à GPU. Vamos considerar um exemplo simples onde tentamos criar um buffer de vértices:

```rust
use wgpu::{Device, BufferDescriptor, BufferUsage, Buffer};

fn create_vertex_buffer(device: &Device, data: &[f32]) -> Result<Buffer, String> {
    let descriptor = BufferDescriptor {
        size: (data.len() * std::mem::size_of::<f32>()) as u64,
        usage: BufferUsage::VERTEX,
        mapped_at_creation: false,
    };

    let buffer = device.create_buffer(&descriptor);
    Ok(buffer)
}
```

Se a criação do buffer falhar, podemos capturar o erro e fornecer informações úteis para debug:

```rust
let device: Device = ...; // Suponha que temos um dispositivo GPU válido
let vertex_data = vec![0.0, 1.0, 2.0];

match create_vertex_buffer(&device, &vertex_data) {
    Ok(buffer) => println!("Buffer criado com sucesso!"),
    Err(e) => eprintln!("Falha ao criar buffer: {}", e),
}
```

### Logging Customizado

Em muitos casos, bibliotecas de logging como `log` ou `tracing` podem ser excessivas para aplicações gráficas leves. Uma abordagem simples é criar uma função de logging customizada que escreve diretamente para o terminal ou para um arquivo:

```rust
use std::fs::OpenOptions;
use std::io::Write;

fn log_message(message: &str) {
    let mut file = OpenOptions::new()
        .append(true)
        .create(true)
        .open("graphics.log")
        .expect("Falha ao abrir arquivo de log");

    writeln!(file, "{}", message).expect("Falha ao escrever no arquivo de log");
}
```

Podemos integrar essa função de logging com nosso tratamento de erros:

```rust
match create_vertex_buffer(&device, &vertex_data) {
    Ok(buffer) => log_message("Buffer criado com sucesso!"),
    Err(e) => log_message(&format!("Falha ao criar buffer: {}", e)),
}
```

### Erros Comuns e Como Evitá-los

Um erro comum em aplicações gráficas é tentar acessar recursos GPU após eles terem sido liberados. Isso pode resultar em crashes ou comportamento indefinido. Para evitar isso, podemos usar RAII para garantir que os recursos sejam liberados corretamente:

```rust
struct VertexBuffer {
    buffer: Buffer,
    device: Arc<Device>,
}

impl Drop for VertexBuffer {
    fn drop(&mut self) {
        self.device.destroy_buffer(&self.buffer);
        log_message("Buffer liberado com sucesso.");
    }
}
```

Outro erro comum é a sincronização inadequada entre threads, especialmente quando múltiplas threads tentam acessar recursos gráficos simultaneamente. Usar `Arc<Mutex<T>>` pode ajudar a garantir acesso seguro:

```rust
use std::sync::{Arc, Mutex};

let shared_buffer = Arc::new(Mutex::new(VertexBuffer { buffer, device }));

// Em outra thread:
let buffer = shared_buffer.lock().unwrap();
log_message("Buffer acessado com sucesso.");
```

### Exercício Prático

**Exercício:** Crie uma função `create_texture` que tenta criar uma textura a partir de um conjunto de dados de pixel. Capture qualquer erro que ocorra durante a criação da textura e registre-o usando a função `log_message`.

**Solução:**

```rust
use wgpu::{Device, TextureDescriptor, TextureDimension, TextureFormat, TextureUsage, Texture};

fn create_texture(device: &Device, width: u32, height: u32, data: &[u8]) -> Result<Texture, String> {
    let descriptor = TextureDescriptor {
        size: wgpu::Extent3d {
            width,
            height,
            depth: 1,
        },
        dimension: TextureDimension::D2,
        format: TextureFormat::Rgba8Unorm,
        usage: TextureUsage::SAMPLED,
        mip_level_count: 1,
        sample_count: 1,
    };

    let texture = device.create_texture(&descriptor);
    Ok(texture)
}

// Uso:
match create_texture(&device, 256, 256, &pixel_data) {
    Ok(texture) => log_message("Textura criada com sucesso!"),
    Err(e) => log_message(&format!("Falha ao criar textura: {}", e)),
}
```

Este exercício reforça a importância do tratamento de erros e logging em aplicações gráficas, garantindo que problemas possam ser identificados e resolvidos rapidamente.