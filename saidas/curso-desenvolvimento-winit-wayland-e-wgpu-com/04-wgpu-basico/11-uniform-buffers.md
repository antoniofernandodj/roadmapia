## Uniform Buffers

Você está renderizando um cubo que gira, mas percebe que precisa atualizar a matriz de transformação a cada frame. Copiar dados do CPU para o GPU repetidamente é ineficiente. Uniform buffers resolvem isso permitindo que você armazene dados constantes (como matrizes) na memória da GPU, acessíveis por todos os shaders.

Vamos criar um buffer uniforme para armazenar uma matriz de modelo-visão-projeção (MVP). Primeiro, definimos a estrutura em Rust:

```rust
#[repr(C)]
#[derive(Debug, Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct UniformBufferObject {
    model: [[f32; 4]; 4],
    view: [[f32; 4]; 4],
    projection: [[f32; 4]; 4],
}
```

O `#[repr(C)]` garante o layout de memória compatível com a GPU, e as traits `Pod` e `Zeroable` permitem conversão segura para bytes. Agora criamos o buffer:

```rust
let uniform_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Uniform Buffer"),
    size: std::mem::size_of::<UniformBufferObject>() as u64,
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    mapped_at_creation: false,
});
```

O erro mais comum aqui é esquecer o `COPY_DST` usage, resultando em:
```
Error: Buffer usage doesn't include COPY_DST which is required for write_buffer
```

Precisamos atualizar o buffer a cada frame. No loop de renderização:

```rust
let mvp = UniformBufferObject {
    model: rotation_matrix,
    view: camera.view_matrix(),
    projection: camera.projection_matrix(),
};

queue.write_buffer(
    &uniform_buffer,
    0,
    bytemuck::cast_slice(&[mvp]),
);
```

Para usar no shader, criamos um bind group:

```rust
let bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[wgpu::BindGroupLayoutEntry {
        binding: 0,
        visibility: wgpu::ShaderStages::VERTEX,
        ty: wgpu::BindingType::Buffer {
            ty: wgpu::BufferBindingType::Uniform,
            has_dynamic_offset: false,
            min_binding_size: None,
        },
        count: None,
    }],
});

let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
    layout: &bind_group_layout,
    entries: &[wgpu::BindGroupEntry {
        binding: 0,
        resource: uniform_buffer.as_entire_binding(),
    }],
    label: Some("uniform_bind_group"),
});
```

No shader WGSL, declaramos o buffer uniform:

```rust
@group(0) @binding(0)
var<uniform> mvp: UniformBufferObject;

struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    projection: mat4x4<f32>,
};
```

Erro comum: descompasso entre o layout Rust e WGSL causa comportamento indefinido. A mensagem pode ser:
```
Shader validation error: Structure member 'model' at offset 0 doesn't match between shader and pipeline layout
```

Para testar, modifique o vertex shader para usar a matriz:

```rust
@vertex
fn vs_main(
    @location(0) position: vec3<f32>,
) -> @builtin(position) vec4<f32> {
    return mvp.projection * mvp.view * mvp.model * vec4<f32>(position, 1.0);
}
```

**Exercício**: Crie um segundo uniform buffer para armazenar uma cor base que será multiplicada pela cor do fragmento. Atualize-o a cada segundo para criar um efeito de pulsação.

Solução:
```rust
#[repr(C)]
#[derive(Debug, Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct ColorUniform {
    color: [f32; 4],
}

let color_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Color Buffer"),
    contents: bytemuck::cast_slice(&[ColorUniform {
        color: [1.0, 0.0, 0.0, 1.0],
    }]),
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
});

// No loop de renderização, quando o tempo muda:
let t = start_time.elapsed().as_secs_f32();
let pulse = (t.sin() + 1.0) / 2.0;
queue.write_buffer(
    &color_buffer,
    0,
    bytemuck::cast_slice(&[ColorUniform {
        color: [pulse, 0.5, 0.5, 1.0],
    }]),
);
```

No shader:
```rust
@group(0) @binding(1)
var<uniform> color: ColorUniform;

struct ColorUniform {
    color: vec4<f32>,
};

@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return color.color * vec4(0.8, 0.8, 0.8, 1.0);
}
```