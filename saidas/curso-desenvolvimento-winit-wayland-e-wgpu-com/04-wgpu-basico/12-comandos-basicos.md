## Comandos Básicos

Renderizar um triângulo colorido em WGPU parece simples até você tentar submeter os comandos para a GPU e nada acontecer. O problema real é que todas as operações gráficas precisam ser registradas em um command buffer antes da execução, mas esse buffer tem um ciclo de vida preciso que, se violado, faz a GPU ignorar seus comandos silenciosamente.

Vamos começar com um exemplo concreto que falha da maneira típica:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Command Encoder"),
});

{
    let _render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        // Configurações omitidas para brevidade...
        label: Some("Render Pass"),
    });
    // Comandos de desenho iriam aqui
}

// Esquecemos de criar o command buffer!
// queue.submit(std::iter::empty()); // Nada será renderizado
```

Este código cria um encoder e uma render pass, mas nunca finaliza o command buffer nem o submete à queue. A GPU não tem como saber que esses comandos existem.

O fluxo correto envolve três etapas:

1. **Encoder** - Grava comandos brutos
2. **Buffer** - Finaliza os comandos em um pacote imutável
3. **Queue** - Submete para execução assíncrona

Veja o mesmo código corrigido:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Command Encoder"),
});

{
    let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        // Configurações completas agora
        label: Some("Render Pass"),
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &frame_view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::GREEN),
                store: wgpu::StoreOp::Store,
            },
        })],
        depth_stencil_attachment: None,
    });
    render_pass.draw(0..3, 0..1); // Desenha 3 vértices (um triângulo)
}

let command_buffer = encoder.finish(); // Etapa crítica!
queue.submit(std::iter::once(command_buffer));
```

A diferença crucial está nas duas últimas linhas. `encoder.finish()` consolida todos os comandos gravados em um `CommandBuffer`, que então pode ser submetido via `queue.submit()`. Sem o `finish()`, você receberá este erro:

```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Validation Error

Caused by:
    In Queue::submit
    Command buffer 0 is invalid
    Object 0: handle does not exist
```

Um detalhe importante: command buffers são imutáveis após criação. Se precisar modificar comandos, você deve criar um novo encoder. Essa restrição existe porque a GPU pode estar executando o buffer antigo enquanto você tenta modificá-lo.

Para operações mais complexas, você pode gravar múltiplos command buffers e submetê-los juntos:

```rust
let buffer1 = encoder1.finish();
let buffer2 = encoder2.finish();
queue.submit([buffer1, buffer2]); // Execução em ordem
```

WGPU garante que os buffers serão executados na ordem de submissão, mas não faz sincronização automática entre eles. Se o buffer2 depende de resultados do buffer1, você precisa inserir uma barreira explícita:

```rust
encoder1.insert_debug_marker("Preparação de dados");
// ... comandos do buffer1 ...
encoder2.insert_debug_marker("Renderização dependente");
encoder2.write_buffer(&buffer, 0, &data); // Espera buffer1 terminar
```

Um erro comum é assumir que command buffers são baratos. Na verdade, cada um tem overhead significativo. Para cenas dinâmicas, a abordagem ideal é:

1. Criar buffers estáticos uma vez (como vertex buffers)
2. Gravar command buffers por frame com apenas os comandos variáveis
3. Reutilizar pipelines sempre que possível

**Exercício**: Modifique o exemplo inicial para desenhar dois triângulos em posições diferentes usando um único command buffer. Cada triângulo deve ter uma cor de clear diferente.

**Solução**:

```rust
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Double Triangle Encoder"),
});

// Primeiro triângulo (vermelho)
{
    let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        label: Some("First Pass"),
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &frame_view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::RED),
                store: wgpu::StoreOp::Store,
            },
        })],
        depth_stencil_attachment: None,
    });
    pass.draw(0..3, 0..1);
}

// Segundo triângulo (azul) - usa viewport diferente
{
    let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
        label: Some("Second Pass"),
        color_attachments: &[Some(wgpu::RenderPassColorAttachment {
            view: &frame_view,
            resolve_target: None,
            ops: wgpu::Operations {
                load: wgpu::LoadOp::Clear(wgpu::Color::BLUE),
                store: wgpu::StoreOp::Store,
            },
        })],
        depth_stencil_attachment: None,
    });
    pass.set_viewport(0.5, 0.5, 0.5, 0.5, 0.0, 1.0);
    pass.draw(0..3, 0..1);
}

queue.submit(std::iter::once(encoder.finish()));
```

Este exemplo mostra como:
- Um encoder pode conter múltiplas render passes
- Cada pass tem seu próprio estado (cores, viewports)
- Tudo é consolidado em um único command buffer para eficiência