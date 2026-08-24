## Batch Optimization

Quando você precisa renderizar milhares de objetos em uma cena, cada chamada de desenho (`draw call`) tem um custo. Imagine que você está desenhando 10.000 árvores em um jogo. Se cada árvore for desenhada individualmente, você precisará de 10.000 `draw calls`, o que pode levar a um gargalo de performance. A solução é agrupar objetos semelhantes em um único `draw call`, reduzindo significativamente o overhead.

### O Problema dos Draw Calls Repetidos

Vamos começar com um exemplo básico onde cada objeto é desenhado individualmente:

```rust
for tree in &trees {
    renderer.draw(&tree);
}
```

Se você executar isso, o desempenho será terrível, especialmente em cenas complexas. Cada `draw call` força a GPU a configurar estados, vincular recursos e enviar comandos, o que é custoso.

### Agrupando Draw Calls

Para otimizar, você pode agrupar objetos que compartilham o mesmo material e geometria. Isso é conhecido como **batching**. Veja como fazer isso:

```rust
let mut batch = Vec::new();
for tree in &trees {
    batch.push(tree);
}

renderer.draw_batch(&batch);
```

Aqui, `draw_batch` envia todos os objetos em um único `draw call`, reduzindo drasticamente o overhead.

### Exemplo Prático com WGPU

Vamos implementar isso em WGPU. Suponha que você tenha uma estrutura `Tree` que define a geometria e o material de uma árvore:

```rust
struct Tree {
    mesh: wgpu::Buffer,
    material: wgpu::BindGroup,
}
```

Aqui está como você pode agrupar e desenhar várias árvores:

```rust
let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
    // Configurações do render pass
});

let mut batch = Vec::new();
for tree in &trees {
    batch.push(tree);
}

for tree in batch {
    render_pass.set_bind_group(0, &tree.material, &[]);
    render_pass.set_vertex_buffer(0, tree.mesh.slice(..));
    render_pass.draw(0..tree.vertex_count, 0..1);
}
```

### Erro Comum e Correção

Um erro comum é tentar agrupar objetos que não compartilham o mesmo material ou geometria. Isso resulta em uma mensagem de erro como:

```
wgpu error: Bind group layout mismatch.
```

Para corrigir, certifique-se de que todos os objetos em um batch compartilham o mesmo material e geometria:

```rust
let mut batches = HashMap::new();
for tree in &trees {
    batches.entry(tree.material).or_insert_with(Vec::new).push(tree);
}

for (material, batch) in batches {
    render_pass.set_bind_group(0, &material, &[]);
    for tree in batch {
        render_pass.set_vertex_buffer(0, tree.mesh.slice(..));
        render_pass.draw(0..tree.vertex_count, 0..1);
    }
}
```

### Conclusão

Agrupar `draw calls` é uma técnica essencial para otimizar aplicações gráficas. Ao reduzir o número de chamadas de desenho, você minimiza o overhead de comunicação entre CPU e GPU, resultando em uma performance significativamente melhor. Isso é especialmente útil em cenas com muitos objetos repetidos, como árvores, personagens ou itens em um jogo.