## Clip Rectangles

Renderizar uma interface complexa frequentemente exibe um problema: elementos filhos ultrapassam os limites do elemento pai, criando vazamentos visuais indesejados. Um botão dentro de um painel scrollável não deve aparecer fora dele, mesmo que suas coordenadas absolutas digam o contrário. A solução é o *clipping* — restringir a área de desenho a uma região retangular específica.

### O Problema Concreto

Considere um painel de 300x200 pixels com conteúdo interno de 300x400 pixels. Sem clipping, ao rolar 100 pixels para baixo, o conteúdo vaza pela borda inferior:

```rust
// Painel sem clipping (problema visível)
let panel_rect = Rect::new(0.0, 0.0, 300.0, 200.0);
let content_rect = Rect::new(0.0, -100.0, 300.0, 400.0); // Scroll aplicado

// Desenha ambos diretamente
renderer.draw_rect(panel_rect, Color::GRAY);
renderer.draw_rect(content_rect, Color::BLUE);
```

Resultado:
```
[Área cinza vazia com retângulo azul vazando por baixo]
```

### Implementação Básica

WGPU oferece clipping via `RenderPass::set_scissor_rect`. O truque está em converter coordenadas lógicas para físicas, considerando a viewport:

```rust
fn apply_clip(render_pass: &mut wgpu::RenderPass, clip_rect: Rect, viewport_size: (u32, u32)) {
    let physical_rect = Rect {
        x: clip_rect.x.max(0.0),
        y: clip_rect.y.max(0.0),
        width: clip_rect.width.min(viewport_size.0 as f32 - clip_rect.x),
        height: clip_rect.height.min(viewport_size.1 as f32 - clip_rect.y),
    };

    render_pass.set_scissor_rect(
        physical_rect.x as u32,
        physical_rect.y as u32,
        physical_rect.width as u32,
        physical_rect.height as u32,
    );
}
```

Erro comum: esquecer de resetar o scissor após usar. Isso causa clipping permanente:

```rust
// ERRADO - clipping persiste para próximos draws
apply_clip(&mut render_pass, panel_rect, (800, 600));
renderer.draw_rect(content_rect);

// Correto - restaura a área total após uso
apply_clip(&mut render_pass, panel_rect, (800, 600));
renderer.draw_rect(content_rect);
render_pass.set_scissor_rect(0, 0, 800, 600); // Reset
```

### Hierarquia de Clipping

Elementos aninhados exigem interseção progressiva de retângulos. Um botão dentro de um painel scrollável deve respeitar ambos os limites:

```rust
fn intersect_rects(a: Rect, b: Rect) -> Option<Rect> {
    let x1 = a.x.max(b.x);
    let y1 = a.y.max(b.y);
    let x2 = (a.x + a.width).min(b.x + b.width);
    let y2 = (a.y + a.height).min(b.y + b.height);

    if x2 > x1 && y2 > y1 {
        Some(Rect::new(x1, y1, x2 - x1, y2 - y1))
    } else {
        None
    }
}

// Painel principal (300x200)
let panel_clip = Rect::new(10.0, 10.0, 300.0, 200.0);

// Área scrollável interna (280x180 com offset Y=50)
let scroll_clip = intersect_rects(
    panel_clip,
    Rect::new(15.0, -40.0, 280.0, 500.0),
).unwrap();

apply_clip(&mut render_pass, scroll_clip, (800, 600));
```

### Exercício Prático

Implemente um sistema onde:
1. Um contêiner principal de 400x300 pixels tem padding de 20px
2. Dentro dele, um filho de 500x200 pixels é scrollável verticalmente
3. O scroll offset é de 35px
4. O clipping deve impedir vazamento pelo padding

Solução comentada:

```rust
let viewport = (800, 600);
let container = Rect::new(0.0, 0.0, 400.0, 300.0);
let padding = 20.0;

// Área após padding
let inner_clip = Rect::new(
    container.x + padding,
    container.y + padding,
    container.width - 2.0 * padding,
    container.height - 2.0 * padding,
);

// Conteúdo com scroll
let content = Rect::new(
    inner_clip.x,
    inner_clip.y - 35.0, // Scroll aplicado
    500.0,
    200.0,
);

// Clipping final
let final_clip = intersect_rects(inner_clip, content).unwrap();
apply_clip(&mut render_pass, final_clip, viewport);
```