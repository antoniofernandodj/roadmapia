## Error Handling

Renderização gráfica é um ambiente onde falhas são comuns - hardware incompatível, drivers problemáticos, recursos insuficientes. WGPU, sendo uma abstração segura sobre APIs gráficas nativas, transforma esses problemas em erros Rust gerenciáveis. Vamos abordar os padrões mais úteis.

### Erros de Criação de Recursos

Ao criar um adapter, você pode se deparar com:

```rust
let adapter = instance
    .request_adapter(&wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::HighPerformance,
        compatible_surface: Some(&surface),
        force_fallback_adapter: false,
    })
    .await
    .expect("Failed to find an appropriate adapter");
```

Se nenhum adapter for encontrado, o programa falhará com:
```
thread 'main' panicked at 'Failed to find an appropriate adapter'
```

Para tratar isso graciosamente:

```rust
let adapter = match instance.request_adapter(&options).await {
    Some(adapter) => adapter,
    None => {
        eprintln!("No compatible GPU found. Trying fallback adapter...");
        instance.request_adapter(&wgpu::RequestAdapterOptions {
            power_preference: wgpu::PowerPreference::LowPower,
            compatible_surface: Some(&surface),
            force_fallback_adapter: true,
        })
        .await
        .expect("No GPU adapters available")
    }
};
```

### Validação de Recursos

Ao criar um pipeline de renderização, omissões resultam em erros específicos:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    label: None,
    layout: None, // Omitido intencionalmente
    vertex: wgpu::VertexState {
        module: &shader,
        entry_point: "vs_main",
        buffers: &[Vertex::desc()],
    },
    fragment: None, // Erro deliberado
    primitive: wgpu::PrimitiveState::default(),
    depth_stencil: None,
    multisample: wgpu::MultisampleState::default(),
});
```

Isso produzirá:
```
thread 'main' panicked at 'Error in RenderPipeline::create: required fragment stage is missing'
```

A correção envolve fornecer todos os estágios obrigatórios:

```rust
let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    fragment: Some(wgpu::FragmentState {
        module: &shader,
        entry_point: "fs_main",
        targets: &[Some(wgpu::ColorTargetState {
            format: config.format,
            blend: Some(wgpu::BlendState::REPLACE),
            write_mask: wgpu::ColorWrites::ALL,
        })],
    }),
    // ... resto da configuração
});
```

### Tratamento de Erros Assíncronos

Operações como `queue.submit()` são assíncronas. Erros podem surgir depois da chamada:

```rust
device.push_error_scope(wgpu::ErrorFilter::Validation);
let commands = encoder.finish();
queue.submit(std::iter::once(commands));

let error = device.pop_error_scope().await;
match error {
    Some(wgpu::Error::Validation { description, .. }) => {
        eprintln!("Validation error: {}", description);
    }
    _ => {}
}
```

### Erros Comuns e Soluções

1. **Surface não compatível**:
```
thread 'main' panicked at 'Surface does not support the adapter's queue family'
```
Solução: verifique `adapter.is_surface_supported(&surface)` antes de criar a swap chain.

2. **Formato de textura inválido**:
```
thread 'main' panicked at 'Invalid texture format requested'
```
Solução: liste formatos suportados com `surface.get_supported_formats(&adapter)`.

3. **Limite de buffers excedido**:
```
thread 'main' panicked at 'Limit max_buffers exceeded'
```
Solução: verifique `adapter.limits()` e ajuste `DeviceDescriptor` correspondente.

### Exercício: Tratamento de Erros em Pipeline

Crie um pipeline de renderização que falha intencionalmente ao omitir o vertex shader, capture o erro e forneça uma mensagem útil. Depois implemente a correção.

**Solução:**

```rust
// Configuração errada
let bad_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
    vertex: wgpu::VertexState {
        module: &shader,
        entry_point: "non_existent_entry", // Erro aqui
        buffers: &[],
    },
    // ... outros campos
});

match bad_pipeline {
    Ok(_) => println!("Pipeline criado com sucesso"),
    Err(e) => {
        eprintln!("Falha ao criar pipeline: {}", e);
        // Configuração correta
        let good_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            vertex: wgpu::VertexState {
                module: &shader,
                entry_point: "vs_main", // Nome correto
                buffers: &[Vertex::desc()],
            },
            // ... outros campos corretos
        });
    }
}
```