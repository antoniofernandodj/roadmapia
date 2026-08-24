## Iteradores e Performance Crítica

Em gráficos, processar milhões de vértices ou pixels com performance ruim significa frames perdidos e aplicações travando. Veja este código ingênuo que transforma coordenadas:

```rust
fn transform_coords(coords: &[(f32, f32)]) -> Vec<(f32, f32)> {
    let mut result = Vec::with_capacity(coords.len());
    for i in 0..coords.len() {
        let (x, y) = coords[i];
        result.push((x * 2.0 - 1.0, y * 2.0 - 1.0)); // Normaliza para [-1, 1]
    }
    result
}
```

O problema não é a lógica, mas o acesso por índice: cada `coords[i]` verifica limites, e o compilador não otimiza isso tão bem quanto poderia. A versão com iteradores:

```rust
fn transform_coords_iter(coords: &[(f32, f32)]) -> Vec<(f32, f32)> {
    coords.iter()
        .map(|&(x, y)| (x * 2.0 - 1.0, y * 2.0 - 1.0))
        .collect()
}
```

Benchmarks mostram ganhos de 15-30% em casos reais. Por quê?

1. **Zero-cost abstractions**: Iteradores em Rust compilam para código tão eficiente quanto loops manuais
2. **Pipelining**: Operações como `map` e `filter` são fundidas em um único loop
3. **Especialização**: `collect()` aloca exatamente o espaço necessário

### Erro comum: iteradores consumidos

Este código falha:

```rust
let points = vec![(0.0, 0.5), (0.5, 1.0)];
let transformed = points.iter().map(|&(x, y)| (x * 2.0, y * 2.0));
println!("Original: {:?}", points); // Ok
println!("Transformed: {:?}", transformed.collect::<Vec<_>>()); // Ok
println!("Transformed again: {:?}", transformed.collect::<Vec<_>>()); // Erro!
```

A mensagem de erro é clara:
```
error[E0382]: use of moved value: `transformed`
   | println!("Transformed again: {:?}", transformed.collect::<Vec<_>>());
   |                                    ^^^^^^^^^^^ value used here after move
```

Solução: ou chame `collect()` imediatamente, ou use `iter()` novamente:

```rust
let transformed: Vec<_> = points.iter().map(...).collect(); // Versão materializada
```

### Iteradores e dados gráficos

Para buffers GPU, evite coletar em `Vec` intermediários. WGPU espera slices:

```rust
// Ruim: alocação extra
let vertices: Vec<Vertex> = raw_data.iter().map(build_vertex).collect();
device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    contents: bytemuck::cast_slice(&vertices),
    // ...
});

// Bom: iterador direto
let vertices = raw_data.iter().map(build_vertex);
device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    contents: bytemuck::cast_slice(&vertices.collect::<Vec<_>>()), // Coleta só aqui
    // ...
});
```

### Adaptadores úteis para gráficos

1. `zip`: Combina dois iteradores para processar vértices e UVs juntos:
```rust
vertices.iter().zip(uvs.iter()).map(|(v, uv)| {
    Vertex { pos: *v, tex_coord: *uv }
})
```

2. `chunks`: Processa buffers em lotes para uploads paralelos:
```rust
data.chunks(1024).enumerate().for_each(|(i, chunk)| {
    queue.write_buffer(&buffer, i * 1024, bytemuck::cast_slice(chunk));
});
```

3. `chain`: Concatena iteradores para múltiplos meshes:
```rust
let combined = mesh1.vertices.iter().chain(mesh2.vertices.iter());
```

### Exercício: Otimizar processamento de pixels

Dado um buffer de pixels `Vec<u8>` (RGBA), escreva uma função que:
1. Aplica um filtro de brilho (multiplica cada canal por um fator)
2. Usa iteradores para máximo desempenho
3. Não aloca buffers intermediários

Solução comentada:
```rust
fn adjust_brightness(pixels: &mut [u8], factor: f32) {
    pixels.iter_mut()
        .for_each(|p| {
            *p = (*p as f32 * factor).clamp(0.0, 255.0) as u8;
        });
}

// Uso:
let mut image_data = vec![128; 1024]; // Imagem cinza 16x16 RGBA
adjust_brightness(&mut image_data, 1.5); // Aumenta brilho em 50%
```
Pontos-chave:
- `iter_mut()` permite modificar os dados in-place
- `clamp()` evita overflow nos cálculos
- Zero alocações extras durante o processamento