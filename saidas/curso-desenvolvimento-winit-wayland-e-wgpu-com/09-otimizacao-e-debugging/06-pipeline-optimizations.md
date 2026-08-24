## Pipeline Optimizations

Renderizar uma cena complexa em tempo real exige que cada estágio do pipeline gráfico opere com eficiência máxima. O problema surge quando você nota que, mesmo com hardware potente, a aplicação não atinge os FPS desejados — o gargalo pode estar em como os recursos são organizados ou como os comandos são submetidos à GPU.

### Estados de Renderização e Troca de Contexto

Considere este cenário comum: seu jogo renderiza um personagem com textura difusa, seguido por um efeito de partículas com blending alpha, e depois um objeto metálico com environment mapping. Cada uma dessas operações requer configurações diferentes de pipeline:

```rust
// Configuração INEFICIENTE (troca de estado a cada draw call)
render_pass.set_pipeline(&diffuse_pipeline);
render_pass.draw(0..3, 0..1); // Personagem

render_pass.set_pipeline(&alpha_blend_pipeline);
render_pass.draw(0..3, 0..1); // Partículas

render_pass.set_pipeline(&metal_pipeline);
render_pass.draw(0..3, 0..1); // Objeto metálico
```

Cada `set_pipeline` força a GPU a reconfigurar seu estado interno — uma operação custosa. A solução é agrupar draw calls por tipo de pipeline:

```rust
// Configuração OTIMIZADA (minimiza trocas de estado)
render_pass.set_pipeline(&diffuse_pipeline);
render_pass.draw(0..3, 0..1); // Personagem
render_pass.draw(3..6, 0..1); // Outro objeto difuso

render_pass.set_pipeline(&alpha_blend_pipeline);
render_pass.draw(6..9, 0..1); // Partículas
render_pass.draw(9..12, 0..1); // Mais partículas

render_pass.set_pipeline(&metal_pipeline);
render_pass.draw(12..15, 0..1); // Objeto metálico
```

**Erro comum**: Tentar mesclar objetos com estados incompatíveis. Se você tentar renderizar um objeto transparente sem mudar para o pipeline de blending, verá artefatos visuais:

```
Object appears solid when it should be transparent (missing alpha blending)
```

### Bind Groups e Organização de Recursos

Texturas, buffers uniformes e samplers são acessados via bind groups. Criar um bind group por recurso é ineficiente — a GPU precisa recarregar os dados constantemente. Veja a diferença:

```rust
// INEFICIENTE: bind group por textura
for model in &models {
    let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
        layout: &texture_bind_group_layout,
        entries: &[
            wgpu::BindGroupEntry {
                binding: 0,
                resource: wgpu::BindingResource::TextureView(&model.texture_view),
            },
            // ...
        ],
        label: None,
    });
    render_pass.set_bind_group(0, &bind_group, &[]);
    render_pass.draw_model(model);
}
```

A abordagem correta é agrupar recursos por frequência de atualização:

```rust
// Bind group para recursos que raramente mudam (ex: texturas de ambiente)
let static_bind_group = device.create_bind_group(/* ... */);

// Bind group para recursos que mudam por frame (ex: matrizes de view-proj)
let frame_bind_group = device.create_bind_group(/* ... */);

render_pass.set_bind_group(0, &static_bind_group, &[]);
render_pass.set_bind_group(1, &frame_bind_group, &[]);

for model in &models {
    // Apenas atualiza o bind group específico do modelo se necessário
    render_pass.draw_model(model);
}
```

### Instanced Rendering para Objetos Repetidos

Renderizar centenas de cópias do mesmo objeto com draw calls individuais é um desperdício. O instancing permite submeter várias instâncias em uma única chamada:

```rust
#[repr(C)]
#[derive(Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
struct InstanceData {
    model: [[f32; 4]; 4],
    color: [f32; 4],
}

let instances = vec![
    InstanceData { /* transformação 1 */ },
    InstanceData { /* transformação 2 */ },
    // ...
];

let instance_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
    label: Some("Instance Buffer"),
    contents: bytemuck::cast_slice(&instances),
    usage: wgpu::BufferUsages::VERTEX,
});

render_pass.set_vertex_buffer(1, instance_buffer.slice(..));
render_pass.draw(0..vertex_count, 0..instance_count); // Renderiza N instâncias
```

**Comparativo de performance**:
- 1000 objetos sem instancing: 1000 draw calls
- 1000 objetos com instancing: 1 draw call

### Pipeline Caching

Criar pipelines durante o runtime tem um custo significativo. Armazene pipelines frequentemente usados em um cache:

```rust
struct PipelineCache {
    opaque: Option<wgpu::RenderPipeline>,
    alpha_blend: Option<wgpu::RenderPipeline>,
    // ...
}

impl PipelineCache {
    fn get_or_create(&mut self, device: &wgpu::Device, layout: &wgpu::PipelineLayout, is_transparent: bool) -> &wgpu::RenderPipeline {
        match (is_transparent, &self.alpha_blend) {
            (true, Some(pipeline)) => pipeline,
            (true, None) => {
                let pipeline = create_alpha_pipeline(device, layout);
                self.alpha_blend = Some(pipeline);
                self.alpha_blend.as_ref().unwrap()
            }
            // ...
        }
    }
}
```

### Exercício Prático

**Problema**: Você tem uma cena com:
- 50 árvores (textura difusa + alpha cutout)
- 100 pedras (textura difusa)
- 1 lago (transparência com blending)
- 10 metais (environment mapping)

**Tarefa**: Organize a ordem de renderização e agrupe os draw calls para minimizar trocas de pipeline e bind groups.

**Solução comentada**:
```rust
// 1. Objetos opacos primeiro (pedras e metais)
render_pass.set_pipeline(&opaque_pipeline);
render_pass.set_bind_group(0, &shared_resources_bind_group, &[]);

for rock in &rocks {
    render_pass.set_bind_group(1, &rock.bind_group, &[]);
    render_pass.draw_model(rock);
}

render_pass.set_pipeline(&metal_pipeline); // Troca necessária
for metal in &metals {
    render_pass.set_bind_group(1, &metal.bind_group, &[]);
    render_pass.draw_model(metal);
}

// 2. Alpha cutout (árvores)
render_pass.set_pipeline(&alpha_cutout_pipeline);
for tree in &trees {
    render_pass.set_bind_group(1, &tree.bind_group, &[]);
    render_pass.draw_model(tree);
}

// 3. Transparência (lago) - renderizado por último
render_pass.set_pipeline(&alpha_blend_pipeline);
render_pass.set_bind_group(1, &lake.bind_group, &[]);
render_pass.draw_model(&lake);
```