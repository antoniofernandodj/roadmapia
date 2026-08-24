## Render Pass

Um render pass em WGPU é onde a mágica acontece - é o estágio onde definimos exatamente como a GPU deve processar nossos dados gráficos. Imagine que seu pipeline de renderização é uma fábrica, o render pass é a esteira de montagem onde cada operação ocorre em sequência.

Vamos começar com um exemplo concreto. Suponha que criamos um triângulo simples com vertex buffer, mas agora queremos realmente desenhá-lo na tela:

```rust
let render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Render Pass Básica"),
    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
        view: &frame.view,
        resolve_target: None,
        ops: wgpu::Operations {
            load: wgpu::LoadOp::Clear(wgpu::Color::GREEN),
            store: wgpu::StoreOp::Store,
        },
    })],
    depth_stencil_attachment: None,
});
render_pass.set_pipeline(&render_pipeline);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw(0..3, 0..1);
```

O código acima faz três coisas essenciais:
1. Configura o alvo de renderização (color_attachments)
2. Define qual pipeline usar
3. Executa o comando de desenho

O erro mais comum aqui é esquecer de fechar o render pass. Se você tentar submeter o encoder sem terminar o render pass, o compilador Rust vai reclamar:

```text
error[E0382]: borrow of moved value: `render_pass`
  --> src/main.rs:42:5
   |
32 |     let render_pass = encoder.begin_render_pass(...);
   |         ----------- move occurs because `render_pass` has type `wgpu::RenderPass<'_>`, which does not implement the `Copy` trait
...
42 |     render_pass.finish();
   |     ^^^^^^^^^^^ value borrowed here after move
```

A correção é simples - o render pass é automaticamente finalizado quando sai do escopo devido ao sistema de ownership do Rust. Mas se você precisar finalizá-lo explicitamente, pode usar um bloco de escopo:

```rust
{
    let mut render_pass = encoder.begin_render_pass(...);
    // operações de renderização...
} // render_pass é finalizado aqui automaticamente
```

Dentro do render pass, você pode configurar múltiplos estados:

```rust
render_pass.set_blend_constant(wgpu::Color::RED);
render_pass.set_scissor_rect(100, 100, 200, 200);
render_pass.set_stencil_reference(1);
```

Cada chamada `set_*` modifica o estado atual do render pass. É importante notar que essas configurações são persistentes - elas permanecem até serem explicitamente alteradas novamente.

Um detalhe crucial é o `LoadOp` e `StoreOp` no `RenderPassColorAttachment`. Eles controlam como a GPU lida com o framebuffer:

- `LoadOp::Clear` limpa o alvo com uma cor específica (ótimo para novos frames)
- `LoadOp::Load` preserva o conteúdo anterior (útil para efeitos acumulativos)
- `StoreOp::Store` mantém o resultado para exibição
- `StoreOp::Discard` descarta o conteúdo após a pass (economiza largura de banda)

Para exercício, modifique o exemplo inicial para:
1. Usar uma cor de fundo azul em vez de verde
2. Limpar apenas metade da tela (dica: use viewport)
3. Adicione um segundo draw call para outro triângulo

Solução:

```rust
let render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    label: Some("Render Pass Exercício"),
    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
        view: &frame.view,
        resolve_target: None,
        ops: wgpu::Operations {
            load: wgpu::LoadOp::Clear(wgpu::Color::BLUE),
            store: wgpu::StoreOp::Store,
        },
    })],
    depth_stencil_attachment: None,
});

render_pass.set_pipeline(&render_pipeline);
render_pass.set_viewport(0.0, 0.0, surface_config.width as f32 / 2.0, surface_config.height as f32, 0.0, 1.0);
render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
render_pass.draw(0..3, 0..1);

// Segundo triângulo
render_pass.set_viewport(surface_config.width as f32 / 2.0, 0.0, surface_config.width as f32 / 2.0, surface_config.height as f32, 0.0, 1.0);
render_pass.draw(0..3, 0..1); 
```