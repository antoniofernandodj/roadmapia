## Arquitetura do WGPU

WGPU é uma abstração multiplataforma para gráficos 3D e computação em Rust, inspirada na WebGPU API. Seu design resolve um problema crítico: como oferecer acesso eficiente a hardware gráfico moderno (Vulkan, Metal, DirectX 12) mantendo segurança de tipos e ergonomia rustácea. 

### O Problema dos Backends Gráficos

Considere este código que tenta criar um buffer no Vulkan cru:

```rust
// Código hipotético - não compila!
let buffer_info = vk::BufferCreateInfo {
    size: 1024,
    usage: vk::BUFFER_USAGE_VERTEX_BUFFER_BIT,
    sharing_mode: vk::SHARING_MODE_EXCLUSIVE,
    // ... +10 campos obrigatórios
};
let buffer = unsafe { device.create_buffer(&buffer_info, None)? };
```

Os problemas são evidentes:
1. Verbosidade extrema
2. Insegurança com `unsafe`
3. Específico do Vulkan

WGPU resolve com:

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Vertex Buffer"),
    size: 1024,
    usage: wgpu::BufferUsages::VERTEX,
    mapped_at_creation: false,
});
```

### Componentes Principais

1. **Instance**: Ponto de entrada que abstrai o backend específico (Vulkan/Metal/DX12)
   ```rust
   let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
       backends: wgpu::Backends::all(),
       ..Default::default()
   });
   ```

2. **Adapter**: Representação física do hardware gráfico
   ```rust
   let adapter = instance.request_adapter(&wgpu::RequestAdapterOptions {
       power_preference: wgpu::PowerPreference::HighPerformance,
       compatible_surface: None,
       force_fallback_adapter: false,
   }).await?;
   ```

3. **Device & Queue**: Interface principal e fila de comandos
   ```rust
   let (device, queue) = adapter.request_device(
       &wgpu::DeviceDescriptor::default(),
       None
   ).await?;
   ```

### Fluxo de Renderização Típico

1. Criar recursos (buffers, texturas)
2. Definir pipeline de renderização
3. Gravar comandos em um CommandEncoder
4. Submeter para a Queue

Exemplo mínimo:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Render Encoder"),
});

// Iniciar render pass
{
    let _render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        label: Some("Main Pass"),
        color_attachments: &[/* ... */],
        depth_stencil_attachment: None,
    });
}

queue.submit(std::iter::once(encoder.finish()));
```

### Erro Comum: Esquecer o .await

Um erro frequente é ignorar que muitas operações no WGPU são assíncronas:

```rust
let adapter = instance.request_adapter(&options); // Erro!
//               ^^^^^^^^^^^^^^^^^^^^^^^^ precisa de .await
```

A mensagem de erro será clara:
```
error[E0728]: `await` can only be used in an async function
```

### Comparação com OpenGL

| OpenGL          | WGPU               |
|-----------------|--------------------|
| Estado global   | Estado explícito  |
| Síncrono        | Assíncrono        |
| Sem validação   | Validação forte   |

### Exercício: Criar um Buffer

Crie um buffer de índice (16-bit) com 3 elementos contendo [0, 1, 2]. Verifique se o tipo de uso está correto.

Solução:

```rust
let indices: [u16; 3] = [0, 1, 2];
let index_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Index Buffer"),
    contents: bytemuck::cast_slice(&indices),
    usage: wgpu::BufferUsages::INDEX, // Diferente de VERTEX!
});
```