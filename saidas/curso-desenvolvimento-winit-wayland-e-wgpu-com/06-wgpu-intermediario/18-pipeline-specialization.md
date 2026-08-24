## Pipeline Specialization

Renderizar objetos diferentes com o mesmo pipeline de renderização é ineficiente. Cada material, topologia ou configuração de blend exige estados distintos na GPU, e recriar pipelines inteiros para cada variação é custoso. A solução? Pipeline specialization.

Considere um jogo com 100 tipos de materiais. Criar 100 pipelines completos consumiria memória excessiva e tempo de inicialização. O WGPU resolve isso com `PipelineSpecialization`, permitindo modificar parâmetros do pipeline em runtime usando um único pipeline base.

### O Mecanismo

Um pipeline especializado deriva de um pipeline principal, sobrescrevendo apenas parâmetros específicos. Veja como criar um pipeline base e especializações:

```rust
let base_pipeline = device.create_render_pipeline(&RenderPipelineDescriptor {
    label: Some("Base Pipeline"),
    layout: Some(&pipeline_layout),
    vertex: VertexState {
        module: &shader_module,
        entry_point: "vs_main",
        buffers: &[vertex_layout],
    },
    fragment: Some(FragmentState {
        module: &shader_module,
        entry_point: "fs_main",
        targets: &[Some(ColorTargetState {
            format: texture_format,
            blend: Some(BlendState::REPLACE), // Estado base
            write_mask: ColorWrites::ALL,
        })],
    }),
    // ... outros campos omitidos
});

// Especialização para material transparente
let transparent_pipeline = RenderPipeline {
    base: base_pipeline.clone(),
    specialization: PipelineSpecialization {
        fragment: Some(FragmentSpecialization {
            targets: vec![Some(ColorTargetState {
                blend: Some(BlendState::ALPHA_BLENDING), // Sobrescrito
                ..base_pipeline.fragment.as_ref().unwrap().targets[0].clone()
            })],
            ..Default::default()
        }),
        ..Default::default()
    },
};
```

**Erro comum**: esquecer de clonar (`..base_pipeline.fragment.unwrap().targets[0].clone()`) leva a ownership conflicts. A mensagem exata será:
```
error[E0382]: borrow of moved value: `base_pipeline.fragment`
```

### Caso Real: Materiais com Propriedades Diferentes

Suponha materiais opacos, transparentes e de wireframe. Criamos um pipeline base e três especializações:

```rust
// Pipeline base
let base = device.create_render_pipeline(&RenderPipelineDescriptor {
    fragment: Some(FragmentState {
        targets: &[Some(ColorTargetState {
            format: TextureFormat::Rgba8Unorm,
            blend: None, // Será sobrescrito
            write_mask: ColorWrites::ALL,
        })],
        // ... outros campos
    }),
    // ... outros campos
});

// Especializações
let pipelines = [
    // Opaco
    RenderPipeline { base: base.clone(), specialization: Default::default() },
    // Transparente
    RenderPipeline { 
        base: base.clone(),
        specialization: PipelineSpecialization {
            fragment: Some(FragmentSpecialization {
                targets: vec![Some(ColorTargetState {
                    blend: Some(BlendState::ALPHA_BLENDING),
                    ..base.fragment.as_ref().unwrap().targets[0].clone()
                })],
                ..Default::default()
            }),
            ..Default::default()
        },
    },
    // Wireframe
    RenderPipeline {
        base: base.clone(),
        specialization: PipelineSpecialization {
            primitive: PrimitiveSpecialization {
                polygon_mode: PolygonMode::Line,
                ..Default::default()
            },
            ..Default::default()
        },
    },
];
```

Ao renderizar, selecione o pipeline adequado:

```rust
render_pass.set_pipeline(&pipelines[material_type as usize]);
```

### Performance: Cache de Pipelines

WGPU não cacheia automaticamente pipelines especializados. Implemente um cache simples:

```rust
struct PipelineCache {
    base: RenderPipeline,
    specializations: HashMap<u64, RenderPipeline>,
}

impl PipelineCache {
    fn get(&mut self, key: u64, creator: impl FnOnce() -> PipelineSpecialization) -> &RenderPipeline {
        self.specializations.entry(key).or_insert_with(|| RenderPipeline {
            base: self.base.clone(),
            specialization: creator(),
        })
    }
}
```

Chave de cache típica inclui:
- Tipo de material
- Estado de blend
- Topologia
- Formatos de vertex

### Limitações

Nem tudo pode ser especializado. Estados fixos no pipeline base:
- Layout de vertex buffers
- Módulos de shader
- Layout de bind groups

Tentar especializar um vertex layout causará:
```
wgpu error: Pipeline specialization cannot change vertex buffer layouts
```

### Exercício

Implemente um sistema de materiais com:
1. Pipeline base para shader PBR
2. Três especializações: metálico (blend REPLACE), vidro (ALPHA_BLENDING), emissivo (ADDITIVE)
3. Cache que reutiliza pipelines por tipo de material

**Solução comentada**:

```rust
// 1. Pipeline base
let pbr_pipeline = device.create_render_pipeline(/* ... */);

// 2. Cache
let mut cache = PipelineCache { 
    base: pbr_pipeline,
    specializations: HashMap::new(),
};

// 3. Obtenção com especialização
let metallic = cache.get(0, || PipelineSpecialization {
    fragment: Some(FragmentSpecialization {
        targets: vec![Some(ColorTargetState {
            blend: Some(BlendState::REPLACE),
            /* ... */
        })],
        /* ... */
    }),
    /* ... */
});

// Uso:
render_pass.set_pipeline(metallic);
```

Chave `0` para metálico, `1` para vidro, `2` para emissivo. O cache evita recriação desnecessária.