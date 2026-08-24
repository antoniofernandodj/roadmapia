## Buffer Mapping

Cenário comum: você precisa atualizar dados na GPU frequentemente, como matrizes de transformação para objetos animados. Criar um novo buffer a cada frame é ineficiente - a solução é mapear um buffer existente para acesso da CPU.

WGPU oferece buffers mapeáveis através da flag `BufferUsages::MAP_WRITE`. Veja como criar e mapear um buffer uniforme para atualização constante:

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    label: Some("Dynamic Uniform Buffer"),
    size: std::mem::size_of::<MyUniform>() as u64,
    usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::MAP_WRITE,
    mapped_at_creation: false, // Mapearemos posteriormente
});
```

O erro clássico ocorre ao tentar mapear um buffer sem a flag correta:
```rust
// buffer criado sem MAP_WRITE
buffer.slice(..).map_async(wgpu::MapMode::Write); 
// ERRO: Validation Error: Buffer usage doesn't include MAP_WRITE
```

Para escrever dados, siga este fluxo completo:

```rust
// 1. Solicitar mapeamento
let buffer_slice = buffer.slice(..);
buffer_slice.map_async(wgpu::MapMode::Write, |result| {
    result.unwrap(); // Trate erros em produção!
});

// 2. Aguardar disponibilidade
device.poll(wgpu::Maintain::Wait);

// 3. Escrever dados
{
    let mut data = buffer_slice.get_mapped_range_mut();
    let my_uniform = MyUniform {
        transform: glam::Mat4::from_rotation_y(angle),
        color: [1.0, 0.5, 0.3, 1.0],
    };
    bytemuck::cast_slice_mut(&mut data).copy_from_slice(bytemuck::bytes_of(&my_uniform));
}

// 4. Liberar o mapeamento
buffer.unmap();
```

A saída deste processo é um buffer atualizado na GPU, pronto para uso no próximo frame de renderização, sem realocação de memória.

Para buffers pequenos (até 4KB), considere `mapped_at_creation`:

```rust
let buffer = device.create_buffer(&wgpu::BufferDescriptor {
    mapped_at_creation: true, // Mapeado imediatamente
    // ... outros parâmetros
});

// Escreva diretamente após criação
{
    let mut data = buffer.slice(..).get_mapped_range_mut();
    // ... preencha os dados
}
buffer.unmap();
```

Performance crítica: buffers mapeados bloqueiam a GPU durante acesso. Para minimizar stalls:

1. Use double buffering - mapeie o buffer B enquanto a GPU usa o A
2. Prefira buffers maiores com offsets dinâmicos
3. Agrupe atualizações em lotes

Exercício: Modifique um buffer de vértices existente para fazer um quad pulsar. Crie o buffer como mapeável, atualize as posições Y dos vértices com uma função seno baseada no tempo.

Solução:
```rust
// No laço de renderização:
let buffer_slice = vertex_buffer.slice(..);
buffer_slice.map_async(wgpu::MapMode::Write, |_| {});

device.poll(wgpu::Maintain::Wait);

{
    let mut data = buffer_slice.get_mapped_range_mut();
    let vertices = bytemuck::cast_slice_mut::<Vertex>(&mut data);
    
    let pulse = time.sin() * 0.1;
    vertices[0].position[1] = -0.5 + pulse;
    vertices[1].position[1] = 0.5 + pulse;
    vertices[2].position[1] = -0.5 + pulse;
    vertices[3].position[1] = 0.5 + pulse;
}

vertex_buffer.unmap();
```