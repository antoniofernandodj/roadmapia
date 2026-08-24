## Dynamic Uniforms

Ao renderizar muitos objetos com propriedades distintas (como cores ou transformações), uma abordagem ingênua seria criar um uniform buffer separado para cada objeto. Isso rapidamente esgota os limites de bind groups e desperdiça memória. A solução eficiente está nos *dynamic uniforms*, que permitem armazenar todos os dados em um único buffer e acessá-los por offset.

Considere este cenário onde queremos renderizar 100 cubos, cada um com sua própria matriz de transformação:

```rust
// Estrutura dos dados por objeto
#[repr(C)]
#[derive(Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct ObjectUniform {
    model: [[f32; 4]; 4],
    color: [f32; 4],
}
```

O erro comum é criar um buffer por objeto:

```rust
// ❌ Ineficiente - um buffer por objeto
let mut object_buffers = Vec::new();
for _ in 0..100 {
    let buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
        label: None,
        contents: bytemuck::cast_slice(&[ObjectUniform::default()]),
        usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    });
    object_buffers.push(buffer);
}
```

Isso funciona, mas é extremamente ineficiente. A abordagem correta usa um único buffer com offsets dinâmicos:

```rust
// ✅ Eficiente - um buffer para todos os objetos
const OBJECT_SIZE: u64 = std::mem::size_of::<ObjectUniform>() as u64;
const BUFFER_SIZE: u64 = OBJECT_SIZE * 100;

let uniform_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: None,
    size: BUFFER_SIZE,
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    mapped_at_creation: false,
});
```

No pipeline layout, marcamos o binding como dinâmico:

```rust
let bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[wgpu::BindGroupLayoutEntry {
        binding: 0,
        visibility: wgpu::ShaderStages::VERTEX,
        ty: wgpu::BindingType::Buffer {
            ty: wgpu::BufferBindingType::Uniform,
            has_dynamic_offset: true,  // 🔑 Chave para dynamic uniforms
            min_binding_size: None,
        },
        count: None,
    }],
});
```

Ao renderizar, especificamos o offset para cada objeto:

```rust
render_pass.set_bind_group(0, &bind_group, &[offset as u32]);  // Offset em bytes alinhados
```

O shader acessa o uniform dinâmico como um array:

```rust
// Shader WGSL
struct ObjectData {
    model: mat4x4<f32>,
    color: vec4<f32>,
};

@group(0) @binding(0) var<uniform> objects: array<ObjectData>;

@vertex
fn vs_main(
    @location(0) pos: vec3<f32>,
    @builtin(instance_index) instance: u32
) -> @builtin(position) vec4<f32> {
    let transform = objects[instance].model;
    return transform * vec4<f32>(pos, 1.0);
}
```

Alinhamento é crucial. WGPU exige que os offsets sejam múltiplos de `min_uniform_buffer_offset_alignment` (tipicamente 256 bytes). Erros comuns incluem:

```text
Validation Error: Buffer binding offset (132) is not a multiple of the minimum uniform buffer offset alignment (256)
```

A solução é arredondar para cima:

```rust
let offset = (index * (std::mem::size_of::<ObjectUniform>() as u64)
    .next_multiple_of(device.limits().min_uniform_buffer_offset_alignment as u64);
```

**Exercício**: Modifique o exemplo para suportar 500 objetos com um buffer dinâmico e calcule os offsets corretamente. Considere que `min_uniform_buffer_offset_alignment` é 256 bytes.

**Solução**:

```rust
const ALIGNMENT: u64 = 256;
const PADDED_SIZE: u64 = ((std::mem::size_of::<ObjectUniform>() as u64) + ALIGNMENT - 1) / ALIGNMENT * ALIGNMENT;

let buffer_size = PADDED_SIZE * 500;
let uniform_buffer = device.create_buffer(&wgpu::BufferDescriptor {
    size: buffer_size,
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
    ..Default::default()
});

// Ao renderizar:
for i in 0..500 {
    let offset = i * PADDED_SIZE;
    render_pass.set_bind_group(0, &bind_group, &[offset as u32]);
}
```