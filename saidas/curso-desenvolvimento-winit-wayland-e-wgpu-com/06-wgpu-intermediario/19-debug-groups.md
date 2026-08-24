## Debug Groups

Quando você está depurando um pipeline de renderização complexo, identificar qual parte do código gerou um erro ou problema de performance pode ser como encontrar uma agulha em um palheiro. Debug groups são marcadores que você insere no command buffer para organizar e rotular seções do seu código de renderização, tornando os logs e ferramentas de profiling mais legíveis.

Considere este cenário comum: seu jogo está rodando a 15 FPS e você não sabe por quê. Sem debug groups, a ferramenta de profiling mostra apenas uma lista genérica de operações:

```
draw: 12ms
draw: 14ms
dispatch: 8ms
```

Com debug groups, você pode estruturar a informação:

```
[Main Pass]
  draw character: 12ms
  draw environment: 14ms
[Shadow Pass]
  dispatch shadows: 8ms
```

### Implementação Básica

Em WGPU, você insere debug groups usando `RenderPassEncoder` ou `ComputePassEncoder`. Veja como adicionar marcações a um render pass:

```rust
let mut render_pass = command_encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Main Render Pass"),
    color_attachments: &[/* ... */],
    depth_stencil_attachment: None,
});

// Inicia um grupo de debug
render_pass.push_debug_group("Prepare Scene Data");

// Configurações de renderização
render_pass.set_pipeline(&render_pipeline);
render_pass.set_bind_group(0, &scene_bind_group, &[]);

// Termina o grupo atual e inicia outro
render_pass.pop_debug_group();
render_pass.push_debug_group("Render Opaque Objects");

// Desenha objetos
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw(0..vertices.len() as u32, 0..1);

render_pass.pop_debug_group(); // Fecha "Render Opaque Objects"
```

Se você esquecer de fechar um grupo com `pop_debug_group()`, o WGPU vai avisar:

```
wgpu error: Unclosed debug group at the end of a pass. Groups must be closed before the pass is finished.
```

### Hierarquia de Grupos

Debug groups podem ser aninhados para criar uma hierarquia lógica. Isso é especialmente útil em cenas complexas:

```rust
render_pass.push_debug_group("Frame 42");
    render_pass.push_debug_group("Main Camera");
        render_pass.push_debug_group("Opaque Geometry");
        // ... draw calls ...
        render_pass.pop_debug_group();
        
        render_pass.push_debug_group("Transparent Objects");
        // ... draw calls ...
        render_pass.pop_debug_group();
    render_pass.pop_debug_group();
    
    render_pass.push_debug_group("UI Layer");
    // ... UI rendering ...
    render_pass.pop_debug_group();
render_pass.pop_debug_group();
```

### Visualizando no RenderDoc

Quando você captura um frame no RenderDoc, os debug groups aparecem como uma árvore navegável:

```
Frame 42
├── Main Camera
│   ├── Opaque Geometry
│   └── Transparent Objects
└── UI Layer
```

### Performance Considerations

Debug groups têm custo quase zero quando não há ferramenta de debug conectada. O WGPU automaticamente otimiza essas chamadas em builds de release. No entanto, evite:

```rust
// Ruim: muitos grupos pequenos e inúteis
for mesh in &meshes {
    render_pass.push_debug_group(&format!("Rendering {}", mesh.name));
    render_pass.draw_mesh(mesh);
    render_pass.pop_debug_group();
}
```

Prefira agrupar operações lógicas:

```rust
// Bom: grupos significativos
render_pass.push_debug_group("Render Static Meshes");
for mesh in &static_meshes {
    render_pass.draw_mesh(mesh);
}
render_pass.pop_debug_group();
```

### Exercício Prático

Modifique este código para incluir debug groups que ajudem a identificar três fases distintas: configuração, renderização de objetos opacos e renderização de objetos transparentes.

```rust
let mut render_pass = command_encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: None,
    color_attachments: &[/* ... */],
    depth_stencil_attachment: None,
});

// Configuração
render_pass.set_pipeline(&opaque_pipeline);
render_pass.set_bind_group(0, &scene_bind_group, &[]);

// Objetos opacos
for object in &opaque_objects {
    render_pass.set_vertex_buffer(0, object.vertex_buffer.slice(..));
    render_pass.draw(0..object.vertex_count, 0..1);
}

// Objetos transparentes
render_pass.set_pipeline(&transparent_pipeline);
for object in &transparent_objects {
    render_pass.set_vertex_buffer(0, object.vertex_buffer.slice(..));
    render_pass.draw(0..object.vertex_count, 0..1);
}
```

**Solução:**

```rust
let mut render_pass = command_encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Main Render Pass"),
    color_attachments: &[/* ... */],
    depth_stencil_attachment: None,
});

// Configuração
render_pass.push_debug_group("Pipeline Setup");
render_pass.set_pipeline(&opaque_pipeline);
render_pass.set_bind_group(0, &scene_bind_group, &[]);
render_pass.pop_debug_group();

// Objetos opacos
render_pass.push_debug_group("Opaque Objects");
for object in &opaque_objects {
    render_pass.set_vertex_buffer(0, object.vertex_buffer.slice(..));
    render_pass.draw(0..object.vertex_count, 0..1);
}
render_pass.pop_debug_group();

// Objetos transparentes
render_pass.push_debug_group("Transparent Objects");
render_pass.set_pipeline(&transparent_pipeline);
for object in &transparent_objects {
    render_pass.set_vertex_buffer(0, object.vertex_buffer.slice(..));
    render_pass.draw(0..object.vertex_count, 0..1);
}
render_pass.pop_debug_group();
```