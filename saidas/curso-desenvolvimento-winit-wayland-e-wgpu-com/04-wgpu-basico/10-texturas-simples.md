## Texturas Simples

Quando precisamos ir além de formas geométricas coloridas, texturas são o próximo passo fundamental. Imagine tentar renderizar um jogo 2D onde cada tijolo de uma parede precisasse ser desenhado manualmente como um retângulo - seria impraticável. As texturas resolvemos esse problema permitindo que imagens sejam "coladas" sobre geometria.

Vamos começar com um quadrado simples e aplicar uma textura de 2x2 pixels:

```rust
// Estrutura para nossa textura
pub struct Texture {
    pub texture: wgpu::Texture,
    pub view: wgpu::TextureView,
    pub sampler: wgpu::Sampler,
}

impl Texture {
    pub fn from_bytes(device: &wgpu::Device, queue: &wgpu::Queue, bytes: &[u8], label: Option<&str>) -> Result<Self, image::ImageError> {
        let img = image::load_from_memory(bytes)?;
        let rgba = img.to_rgba8();

        let dimensions = rgba.dimensions();
        let size = wgpu::Extent3d {
            width: dimensions.0,
            height: dimensions.1,
            depth_or_array_layers: 1,
        };

        let texture = device.create_texture(
            &wgpu::TextureDescriptor {
                label,
                size,
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format: wgpu::TextureFormat::Rgba8UnormSrgb,
                usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
                view_formats: &[],
            }
        );

        queue.write_texture(
            wgpu::ImageCopyTexture {
                texture: &texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            &rgba,
            wgpu::ImageDataLayout {
                offset: 0,
                bytes_per_row: Some(4 * dimensions.0),
                rows_per_image: Some(dimensions.1),
            },
            size,
        );

        let view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        let sampler = device.create_sampler(&wgpu::SamplerDescriptor {
            address_mode_u: wgpu::AddressMode::ClampToEdge,
            address_mode_v: wgpu::AddressMode::ClampToEdge,
            address_mode_w: wgpu::AddressMode::ClampToEdge,
            mag_filter: wgpu::FilterMode::Nearest,
            min_filter: wgpu::FilterMode::Nearest,
            mipmap_filter: wgpu::FilterMode::Nearest,
            ..Default::default()
        });

        Ok(Self { texture, view, sampler })
    }
}
```

O erro mais comum aqui é esquecer de alinhar corretamente os bytes por linha (`bytes_per_row`). Se você receber:

```
Error: Validation Error: Texture data layout does not respect the required alignment (256)
```

A solução é garantir que `bytes_per_row` seja múltiplo de 256. Podemos ajustar com:

```rust
let align_mask = 255;
let aligned_bytes_per_row = ((4 * dimensions.0 + align_mask) & !align_mask);
```

No shader, precisamos declarar a textura e o sampler:

```rust
// Vertex shader
[[stage(vertex)]]
fn vs_main(
    [[location(0)]] pos: vec3<f32>,
    [[location(1)]] tex_coord: vec2<f32>,
) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = vec4<f32>(pos, 1.0);
    out.tex_coord = tex_coord;
    return out;
}

// Fragment shader
[[stage(fragment)]]
fn fs_main(
    [[location(0)]] tex_coord: vec2<f32>,
    [[binding(0)]] texture: texture_2d<f32>,
    [[binding(1)]] sampler: sampler,
) -> [[location(0)]] vec4<f32> {
    return textureSample(texture, sampler, tex_coord);
}
```

Para usar na renderização, precisamos atualizar o pipeline e os bind groups:

```rust
let texture_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
    entries: &[
        wgpu::BindGroupLayoutEntry {
            binding: 0,
            visibility: wgpu::ShaderStages::FRAGMENT,
            ty: wgpu::BindingType::Texture {
                sample_type: wgpu::TextureSampleType::Float { filterable: true },
                view_dimension: wgpu::TextureViewDimension::D2,
                multisampled: false,
            },
            count: None,
        },
        wgpu::BindGroupLayoutEntry {
            binding: 1,
            visibility: wgpu::ShaderStages::FRAGMENT,
            ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
            count: None,
        },
    ],
    label: Some("texture_bind_group_layout"),
});

let texture_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
    layout: &texture_bind_group_layout,
    entries: &[
        wgpu::BindGroupEntry {
            binding: 0,
            resource: wgpu::BindingResource::TextureView(&texture.view),
        },
        wgpu::BindGroupEntry {
            binding: 1,
            resource: wgpu::BindingResource::Sampler(&texture.sampler),
        },
    ],
    label: Some("texture_bind_group"),
});
```

**Exercício**: Crie uma textura em memória (sem carregar arquivo) com padrão xadrez preto e branco de 4x4 pixels e aplique-a a um quadrado. Mostre como os valores de coordenada de textura (0.0 a 1.0) mapeiam para os pixels.

**Solução**:
```rust
let mut pixels = [0u8; 64]; // 4x4 RGBA
for i in 0..16 {
    pixels[i*4] = if (i + (i/4)) % 2 == 0 { 255 } else { 0 }; // R
    pixels[i*4+1] = pixels[i*4]; // G
    pixels[i*4+2] = pixels[i*4]; // B
    pixels[i*4+3] = 255; // A
}

let texture = device.create_texture_with_data(
    queue,
    &wgpu::TextureDescriptor {
        size: wgpu::Extent3d { width:4, height:4, depth_or_array_layers:1 },
        // ... restante igual ao exemplo anterior
    },
    &pixels
);
```
As coordenadas (0.0,0.0) mapeiam para o canto inferior esquerdo, (1.0,1.0) para o superior direito. Cada quadrado do xadrez cobre 0.25 unidades de textura.