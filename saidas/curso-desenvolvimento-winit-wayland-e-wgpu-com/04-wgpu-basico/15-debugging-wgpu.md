## Debugging WGPU

Quando um triângulo não aparece na tela ou uma textura fica toda preta, como descobrir o que deu errado? WGPU oferece várias ferramentas integradas para diagnóstico, mas elas exigem configuração específica. Vamos começar com o caso mais comum: um pipeline que compila mas não renderiza nada.

### Ativando Logs Detalhados

O primeiro passo é habilitar os logs do WGPU. Adicione ao seu `main.rs`:

```rust
use wgpu::util::logger::init_once;

fn main() {
    // Antes de qualquer chamada WGPU
    init_once(log::LevelFilter::Warn, false);
    // ...
}
```

Agora execute com `RUST_LOG=wgpu=debug cargo run`. Você verá mensagens como:

```
[DEBUG wgpu_core::device] Creating shader module
[WARN wgpu_core::device] Pipeline layout is not compatible with bind group layout
```

### Validação de Pipeline

Um erro comum é esquecer de declarar um binding no shader WGSL. Considere este fragmento:

```rust
// No Rust
let bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[wgpu::BindGroupLayoutEntry {
        binding: 0,
        visibility: wgpu::ShaderStages::FRAGMENT,
        ty: wgpu::BindingType::Buffer {
            ty: wgpu::BufferBindingType::Uniform,
            has_dynamic_offset: false,
            min_binding_size: None,
        },
        count: None,
    }],
});
```

```wgsl
// No shader - ESQUECEMOS o binding!
struct Uniforms {
    color: vec4<f32>,
};

@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
}
```

O erro aparecerá como:

```
Validation Error: [BindGroup] Binding 0 is invalid in the bind group
```

### Debug de Texturas

Para inspecionar texturas, crie uma visualização temporária:

```rust
// Adicione ao seu módulo de textura
pub fn debug_texture(texture: &wgpu::Texture, device: &wgpu::Device) {
    let buffer = device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("Debug texture buffer"),
        size: texture.width() * texture.height() * 4,
        usage: wgpu::BufferUsages::MAP_READ | wgpu::BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });

    let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
        label: Some("Debug texture encoder"),
    });

    encoder.copy_texture_to_buffer(
        wgpu::ImageCopyTexture {
            texture,
            mip_level: 0,
            origin: wgpu::Origin3d::ZERO,
            aspect: wgpu::TextureAspect::All,
        },
        wgpu::ImageCopyBuffer {
            buffer: &buffer,
            layout: wgpu::ImageDataLayout {
                offset: 0,
                bytes_per_row: Some(texture.width() * 4),
                rows_per_image: Some(texture.height()),
            },
        },
        texture.size(),
    );

    queue.submit(std::iter::once(encoder.finish()));

    buffer.slice(..).map_async(wgpu::MapMode::Read, |_| {});
    device.poll(wgpu::Maintain::Wait);

    let data = buffer.slice(..).get_mapped_range();
    println!("Primeiros 4 pixels: {:?}", &data[..16]);
}
```

### Marcadores de Renderização

Para identificar passes no RenderDoc ou NSight, use labels:

```rust
let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Meu Render Pass Principal"), // ← Isso aparece nas ferramentas
    color_attachments: &[/* ... */],
    depth_stencil_attachment: None,
});
```

### Exercício: Diagnóstico de Pipeline Quebrado

Dado este shader com erro:

```wgsl
@vertex
fn vs_main(@location(0) position: vec3<f32>) -> @builtin(position) vec4<f32> {
    return vec4<f32>(position, 1.0);
}

@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
}
```

E este código Rust:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    vertex: wgpu::VertexState {
        module: &shader,
        entry_point: "vs_main",
        buffers: &[Vertex::desc()], // Vertex tem position: [f32; 3]
    },
    fragment: Some(wgpu::FragmentState {
        module: &shader,
        entry_point: "fs_main",
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: None,
            write_mask: wgpu::ColorWrites::ALL,
        })],
    }),
    // ... outros campos padrão
});
```

**Problema**: O pipeline compila mas nada é renderizado. Use as técnicas deste capítulo para diagnosticar.

**Solução**:
1. Ative os logs com `RUST_LOG=wgpu=debug`
2. Verifique a mensagem: "Vertex shader expects input at location 0 but none provided"
3. O erro ocorre porque o vertex buffer não foi vinculado ao pipeline. Adicione:

```rust
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
```