## Texturas Avançadas

Quando uma textura é visualizada em diferentes distâncias na cena, problemas de aliasing tornam-se evidentes. Um cubo distante renderizado com uma textura de alta resolução mostrará pixels tremeluzentes, enquanto zoom excessivo revelará blocos pixelados. A solução? Mipmaps - uma pirâmide de versões pré-calculadas da textura em resoluções progressivamente menores.

Vamos criar uma textura com mipmaps completos:

```rust
let texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: 1024,
        height: 1024,
        depth_or_array_layers: 1,
    },
    mip_level_count: 11, // 1024 -> 512 -> ... -> 1 (log2(1024)+1)
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Rgba8Unorm,
    usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
    label: Some("mipmapped_texture"),
});
```

Erro comum: esquecer de gerar os mipmaps reais após criar a textura. Apenas declarar `mip_level_count` não é suficiente:

```
Texture must have data for all mip levels (specified mip level count: 11)
```

Correção com a bilineal filtering entre níveis:

```rust
let mut encoder = device.create_command_encoder();
encoder.generate_mipmaps(&texture);
queue.submit(Some(encoder.finish()));
```

Para arrays de texturas, essenciais quando precisamos múltiplas variações do mesmo tipo (como diferentes texturas de terreno):

```rust
let texture_array = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: 512,
        height: 512,
        depth_or_array_layers: 6, // 6 texturas no array
    },
    mip_level_count: 1,
    sample_count: 1,
    dimension: wgpu::TextureDimension::D2,
    format: wgpu::TextureFormat::Bc1RgbaUnorm,
    usage: wgpu::TextureUsages::TEXTURE_BINDING,
    label: Some("texture_array"),
});
```

Formatos complexos como BCn (Block Compression) economizam memória mas exigem alinhamento específico. Um erro típico:

```
Texture dimensions (500, 500) must be multiples of block size (4, 4) for format Bc1RgbaUnorm
```

A correção exige redimensionar para 504x504 ou usar um formato não-comprimido. Para carregar um array de texturas:

```rust
let diffused_tiles = include_bytes!("tiles.ktx");
let texture = texture_from_ktx(device, queue, diffused_tiles, "tiles").unwrap();
```

No shader, acessamos com:

```glsl
@group(0) @binding(0) var texture_array: texture_2d_array<f32>;
@group(0) @binding(1) var sampler: sampler;

fn fragment() -> @location(0) vec4<f32> {
    return textureSample(texture_array, sampler, uv, layer_index);
}
```

Exercício: Crie uma textura array de 3 layers (512x512) com mipmaps completos, usando formato Rgba8UnormSrgb, e renderize um quad que alterna entre as layers a cada segundo.

Solução comentada:

```rust
// Criação com mip_level_count calculado
let texture = device.create_texture(&wgpu::TextureDescriptor {
    size: wgpu::Extent3d {
        width: 512,
        height: 512,
        depth_or_array_layers: 3,
    },
    mip_level_count: 10, // log2(512)+1
    // ... restante igual ao exemplo anterior
});

// No render loop:
let current_layer = (frame_number / 60) % 3; // Muda a cada segundo @ 60FPS
render_pass.set_bind_group(0, &bind_groups[current_layer as usize], &[]);
```