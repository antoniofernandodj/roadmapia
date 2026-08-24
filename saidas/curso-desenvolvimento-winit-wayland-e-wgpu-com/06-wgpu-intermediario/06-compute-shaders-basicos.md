## Compute Shaders Básicos

Compute shaders são programas executados na GPU que permitem realizar cálculos paralelos sem a necessidade de renderizar gráficos. Eles são especialmente úteis para tarefas como simulações físicas, processamento de imagens e manipulação de grandes volumes de dados. Vamos começar com um exemplo simples: calcular a soma de dois vetores.

Primeiro, precisamos configurar o pipeline de compute shader. Isso inclui a criação de um `BindGroupLayout` e um `PipelineLayout`, além do próprio compute shader. Vamos definir o código WGSL (WebGPU Shading Language) para nosso shader:

```wgsl
[[block]]
struct Input {
    data: array<vec4<f32>>;
};

[[block]]
struct Output {
    data: array<vec4<f32>>;
};

[[group(0), binding(0)]]
var<storage, read> input: Input;

[[group(0), binding(1)]]
var<storage, read_write> output: Output;

[[stage(compute), workgroup_size(64)]]
fn main([[builtin(global_invocation_id)]] global_id: vec3<u32>) {
    let index = global_id.x;
    output.data[index] = input.data[index] + vec4<f32>(1.0, 1.0, 1.0, 1.0);
}
```

Este shader simplesmente adiciona `1.0` a cada componente dos vetores de entrada e armazena o resultado no vetor de saída. O `workgroup_size(64)` define que cada grupo de trabalho processará 64 elementos.

Agora, vamos configurar o pipeline no código Rust:

```rust
use wgpu::{BindGroupLayout, BindGroupLayoutDescriptor, BindGroupLayoutEntry, BindingType, BufferBindingType, ComputePipeline, ComputePipelineDescriptor, Device, PipelineLayout, PipelineLayoutDescriptor, ShaderModule, ShaderSource};

let device: &Device = ...; // Obtenha o dispositivo WGPU

let shader_module = device.create_shader_module(&ShaderSource::Wgsl {
    code: include_str!("shader.wgsl").into(),
});

let bind_group_layout = device.create_bind_group_layout(&BindGroupLayoutDescriptor {
    entries: &[
        BindGroupLayoutEntry {
            binding: 0,
            visibility: wgpu::ShaderStage::COMPUTE,
            ty: BindingType::Buffer {
                ty: BufferBindingType::Storage { read_only: true },
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        },
        BindGroupLayoutEntry {
            binding: 1,
            visibility: wgpu::ShaderStage::COMPUTE,
            ty: BindingType::Buffer {
                ty: BufferBindingType::Storage { read_only: false },
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        },
    ],
    label: None,
});

let pipeline_layout = device.create_pipeline_layout(&PipelineLayoutDescriptor {
    bind_group_layouts: &[&bind_group_layout],
    push_constant_ranges: &[],
    label: None,
});

let compute_pipeline = device.create_compute_pipeline(&ComputePipelineDescriptor {
    layout: Some(&pipeline_layout),
    module: &shader_module,
    entry_point: "main",
    label: None,
});
```

Com o pipeline configurado, precisamos criar os buffers de entrada e saída:

```rust
use wgpu::{Buffer, BufferDescriptor, BufferUsage, CommandEncoder, Device, Queue};

let input_data: Vec<[f32; 4]> = vec![[1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0]];
let input_buffer = device.create_buffer_init(&BufferDescriptor {
    label: None,
    size: (input_data.len() * std::mem::size_of::<[f32; 4]>()) as u64,
    usage: BufferUsage::STORAGE | BufferUsage::COPY_DST,
    contents: bytemuck::cast_slice(&input_data),
});

let output_buffer = device.create_buffer_init(&BufferDescriptor {
    label: None,
    size: (input_data.len() * std::mem::size_of::<[f32; 4]>()) as u64,
    usage: BufferUsage::STORAGE | BufferUsage::COPY_SRC,
    contents: &[],
});
```

Finalmente, podemos executar o compute shader:

```rust
let bind_group = device.create_bind_group(&BindGroupDescriptor {
    layout: &bind_group_layout,
    entries: &[
        BindGroupEntry {
            binding: 0,
            resource: input_buffer.as_entire_binding(),
        },
        BindGroupEntry {
            binding: 1,
            resource: output_buffer.as_entire_binding(),
        },
    ],
    label: None,
});

let mut encoder = device.create_command_encoder(&CommandEncoderDescriptor { label: None });
{
    let mut cpass = encoder.begin_compute_pass(&ComputePassDescriptor { label: None });
    cpass.set_pipeline(&compute_pipeline);
    cpass.set_bind_group(0, &bind_group, &[]);
    cpass.dispatch(input_data.len() as u32, 1, 1);
}
queue.submit(Some(encoder.finish()));
```

Para verificar o resultado, precisamos mapear o buffer de saída:

```rust
let output_slice = output_buffer.slice(..);
output_slice.map_async(wgpu::MapMode::Read, |result| {
    result.unwrap();
});
device.poll(wgpu::Maintain::Wait);

let output_data: &[[f32; 4]] = bytemuck::cast_slice(&output_slice.get_mapped_range());
println!("{:?}", output_data); // Deve imprimir: [[2.0, 3.0, 4.0, 5.0], [6.0, 7.0, 8.0, 9.0]]
```

Esse exemplo básico mostra como configurar e executar um compute shader. Um erro comum é esquecer de configurar corretamente o `BindGroupLayout`, o que resulta em um erro como `PipelineError::BindGroupLayoutMismatch`. Certifique-se de que os bindings no shader correspondam aos definidos no `BindGroupLayout`.

Exercício: Modifique o shader para multiplicar os vetores de entrada por uma constante definida no código Rust, utilizando um uniform buffer.

Solução: Adicione um uniform buffer ao `BindGroupLayout` e ao `BindGroup`, e modifique o shader para ler o valor do uniform:

```wgsl
[[block]]
struct Uniforms {
    multiplier: f32;
};

[[group(0), binding(2)]]
var<uniform> uniforms: Uniforms;

fn main([[builtin(global_invocation_id)]] global_id: vec3<u32>) {
    let index = global_id.x;
    output.data[index] = input.data[index] * uniforms.multiplier;
}
```

No código Rust, crie e configure o uniform buffer:

```rust
let uniform_buffer = device.create_buffer_init(&BufferDescriptor {
    label: None,
    size: std::mem::size_of::<f32>() as u64,
    usage: BufferUsage::UNIFORM | BufferUsage::COPY_DST,
    contents: bytemuck::cast_slice(&[2.0f32]),
});

let bind_group = device.create_bind_group(&BindGroupDescriptor {
    layout: &bind_group_layout,
    entries: &[
        BindGroupEntry {
            binding: 0,
            resource: input_buffer.as_entire_binding(),
        },
        BindGroupEntry {
            binding: 1,
            resource: output_buffer.as_entire_binding(),
        },
        BindGroupEntry {
            binding: 2,
            resource: uniform_buffer.as_entire_binding(),
        },
    ],
    label: None,
});
```