## Limitações do WGPU

O WGPU oferece uma abstração segura e multiplataforma para gráficos modernos, mas essa generalização vem com trade-offs. Vamos explorar situações onde a API mostra suas restrições práticas, começando por um exemplo que parece simples: renderizar para múltiplas janelas simultaneamente.

Considere este código que tenta criar duas superfícies de renderização:

```rust
let window1 = WindowBuilder::new().build(&event_loop).unwrap();
let window2 = WindowBuilder::new().build(&event_loop).unwrap();

let surface1 = unsafe { instance.create_surface(&window1) }.unwrap();
let surface2 = unsafe { instance.create_surface(&window2) }.unwrap();

// Configuração da swap chain para cada superfície
let config1 = SurfaceConfiguration {
    usage: TextureUsages::RENDER_ATTACHMENT,
    format: surface1.get_supported_formats(&adapter)[0],
    width: window1.inner_size().width,
    height: window1.inner_size().height,
    present_mode: PresentMode::Fifo,
    alpha_mode: CompositeAlphaMode::Auto,
};
surface1.configure(&device, &config1);

let config2 = SurfaceConfiguration { /* similar para window2 */ };
surface2.configure(&device, &config2);
```

Ao executar, você encontrará este erro no segundo `configure()`:

```
wgpu error: Validation Error

Caused by:
    In Device::configure_surface
    Surface is already configured by another swap chain
```

O problema fundamental é que o WGPU, por design, não suporta múltiplas superfícies ativas simultaneamente no mesmo dispositivo. Isso ocorre porque:

1. **Limitação de Backend**: Algumas APIs nativas (especialmente Metal) não permitem múltiplas swap chains por dispositivo
2. **Sincronização Complexa**: Coordenar apresentação em múltiplas janelas exigiria lógica adicional pesada
3. **Abstração de Plataforma**: O WGPU prioriza compatibilidade sobre casos de uso avançados

Uma solução parcial seria criar um dispositivo separado para cada janela, mas isso introduz overhead significativo:

```rust
let (device2, queue2) = adapter.request_device(
    &DeviceDescriptor::default(),
    None,
).await.unwrap();
surface2.configure(&device2, &config2);
```

Mesmo assim, você enfrentará problemas em plataformas como WebGPU onde recursos por contexto são limitados.

Outra limitação prática aparece no gerenciamento de texturas grandes. Veja este exemplo que tenta criar uma textura 16K:

```rust
let texture = device.create_texture(&TextureDescriptor {
    size: Extent3d {
        width: 16384,
        height: 16384,
        depth_or_array_layers: 1,
    },
    mip_level_count: 1,
    sample_count: 1,
    dimension: TextureDimension::D2,
    format: TextureFormat::Rgba8Unorm,
    usage: TextureUsages::TEXTURE_BINDING,
    label: None,
});
```

A mensagem de erro revela a restrição:

```
wgpu error: Validation Error

Caused by:
    In Device::create_texture
    Texture dimension 16384x16384 exceeds limit 8192
```

Os limites variam por hardware e são expostos via `adapter.limits()`:

```rust
println!("Max texture dimension: {}", adapter.limits().max_texture_dimension_2d);
// Saída típica em GPUs comuns: 8192
```

Principais limitações de recursos que você encontrará:

| Recurso | Limite Típico | Acesso via |
|---------|--------------|------------|
| Textura 2D | 8192x8192 | `adapter.limits().max_texture_dimension_2d` |
| Bind Groups | 4-8 | `limits.max_bind_groups` |
| Vertex Attributes | 16 | `limits.max_vertex_attributes` |
| Uniform Buffer | 64KB | `limits.max_uniform_buffer_binding_size` |

Na prática, isso significa que técnicas como:

- Atlas de texturas gigantes
- Cenas 3D com milhões de objetos únicos
- Computação geral em texturas muito grandes

Precisarão de soluções alternativas como divisão em tiles ou compressão.

A interoperabilidade com APIs nativas também é limitada. Considere este exemplo que tenta compartilhar uma textura Vulkan com WGPU:

```rust
#[cfg(target_os = "linux")]
fn import_vulkan_texture() {
    let vulkan_image = todo!("Obter VkImage do driver Vulkan");
    
    // Não existe no WGPU puro:
    let texture = device.import_vulkan_image(vulkan_image);
}
```

O erro de compilação é claro - esse método não existe. Para interoperabilidade, você precisaria:

1. Usar extensões específicas de backend (`wgpu-hal`)
2. Criar um sistema de cópia via buffer staging
3. Limitar-se a plataformas específicas

```rust
// Solução aproximada via cópia
let temp_buffer = device.create_buffer(&BufferDescriptor {
    size: texture_size,
    usage: BufferUsages::COPY_SRC,
    mapped_at_creation: false,
    label: None,
});

// Enviar comandos para copiar Vulkan → Buffer → WGPU Texture
```

Mesmo assim, você enfrentará problemas de sincronização e formatos incompatíveis.

Por fim, a ausência de certos recursos gráficos é notável. Tente criar um pipeline com tessellation:

```rust
let pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
    vertex: VertexState { /* ... */ },
    fragment: Some(FragmentState { /* ... */ }),
    // Tessellation não existe no WGPU:
    tessellation: Some(TessellationState {
        // ...
    }),
});
```

O erro de compilação mostra que a estrutura `TessellationState` não existe. Recursos ausentes incluem:

- Tessellation
- Ray tracing
- Shader linking dinâmico
- Certaines formas de computação dispersa

Exercício: Modifique o exemplo de textura 16K para criar um sistema de tiles que divide a textura grande em partes de 4096x4096, cada uma em seu próprio buffer. Mostre como acessar a região correta no shader.

Solução:

```rust
// Dividindo textura 16K em 4x4 tiles de 4K
let tile_size = 4096;
let tiles_x = 16384 / tile_size;
let tiles_y = 16384 / tile_size;

let mut tiles = Vec::new();
for y in 0..tiles_y {
    for x in 0..tiles_x {
        let tile = device.create_texture(&TextureDescriptor {
            size: Extent3d {
                width: tile_size,
                height: tile_size,
                depth_or_array_layers: 1,
            },
            // ... restante igual
        });
        tiles.push(tile);
    }
}
```

No shader WGSL:

```wgsl
fn get_tile_coords(global_pos: vec2<u32>) -> (vec2<u32>, vec2<u32>) {
    let tile_size = 4096u;
    let tile_idx = vec2<u32>(global_pos / tile_size);
    let local_pos = global_pos % tile_size;
    return (tile_idx, local_pos);
}
```