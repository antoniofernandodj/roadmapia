## DPI Handling

Monitores modernos variam drasticamente em densidade de pixels (DPI). Um monitor 4K de 27 polegadas tem um DPI muito maior que um monitor Full HD de 24 polegadas. Se sua aplicação não considerar isso, UI elements podem aparecer microscopicamente pequenos ou absurdamente grandes. O Winit abstrai essa complexidade, mas você precisa entender como interagir corretamente com suas métricas.

Vamos começar com um exemplo prático: uma janela de 800x600 pixels. Em um monitor de baixo DPI, isso pode ocupar uma área confortável na tela. No mesmo monitor 4K de 27 polegadas, essa janela será praticamente ilegível. O problema é que estamos tratando todos os monitores como se tivessem o mesmo DPI.

O Winit fornece dois valores cruciais: `physical_size` e `scale_factor`. O `physical_size` é o tamanho real em pixels físicos da janela. O `scale_factor` é um multiplicador que indica quantos pixels lógicos cabem em um pixel físico. Para nosso exemplo:

```rust
let window = WindowBuilder::new()
    .with_inner_size(LogicalSize::new(800.0, 600.0))
    .build(&event_loop)
    .unwrap();

let physical_size: PhysicalSize<u32> = window.inner_size();
let scale_factor: f64 = window.scale_factor();
println!("Physical size: {:?}", physical_size);
println!("Scale factor: {}", scale_factor);
```

Em um monitor de baixo DPI (scale_factor = 1.0), isso imprimiria:
```
Physical size: PhysicalSize { width: 800, height: 600 }
Scale factor: 1
```

No mesmo monitor 4K (scale_factor = 2.0), a saída seria:
```
Physical size: PhysicalSize { width: 1600, height: 1200 }
Scale factor: 2
```

Agora vamos implementar o desenho de texto que respeita o DPI. Primeiro, precisamos converter coordenadas lógicas para físicas:

```rust
fn logical_to_physical(position: (f64, f64), scale_factor: f64) -> (f64, f64) {
    let (x, y) = position;
    (x * scale_factor, y * scale_factor)
}

let logical_position = (100.0, 200.0);
let physical_position = logical_to_physical(logical_position, scale_factor);
println!("Logical: {:?}", logical_position);
println!("Physical: {:?}", physical_position);
```

Com scale_factor = 2.0, a saída seria:
```
Logical: (100.0, 200.0)
Physical: (200.0, 400.0)
```

O próximo passo é garantir que nosso texto seja renderizado no tamanho correto. Vamos usar `wgpu_glyph` para renderizar texto que respeita o DPI:

```rust
let mut glyph_brush = GlyphBrushBuilder::using_font_bytes(include_bytes!("font.ttf"))
    .build(&device, surface.get_capabilities().formats[0]);

let text = Text::new("Hello, DPI!")
    .with_scale(scale_factor as f32 * 24.0)
    .with_position(logical_position);

glyph_brush.queue(text);
```

Aqui, multiplicamos o tamanho da fonte (24.0) pelo scale_factor para garantir que o texto tenha o mesmo tamanho físico em todos os monitores. Um erro comum é esquecer essa conversão, resultando em texto microscópico em monitores de alta DPI.

Para finalizar, vamos tratar o evento `ScaleFactorChanged` para atualizar automaticamente nossa interface quando o usuário move a janela para um monitor com DPI diferente:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event: WindowEvent::ScaleFactorChanged { scale_factor, new_inner_size }, .. } => {
            println!("New scale factor: {}", scale_factor);
            println!("New size: {:?}", new_inner_size);
            // Recreate glyph brush with new scale factor
            glyph_brush = GlyphBrushBuilder::using_font_bytes(include_bytes!("font.ttf"))
                .build(&device, surface.get_capabilities().formats[0]);
        },
        _ => (),
    }
});
```

Agora sua aplicação manterá proporções consistentes em qualquer monitor, sem scaling dinâmico que pode causar artefatos visuais. Para exercício, implemente uma função que calcule o tamanho físico de uma área de texto dada seu tamanho lógico e o número de caracteres, considerando o scale_factor atual.

Solução comentada:

```rust
fn calculate_text_physical_size(logical_width: f64, chars: usize, scale_factor: f64) -> f64 {
    // Assume average character width of 0.6 in logical coordinates
    let average_char_width = 0.6;
    let logical_size = logical_width * chars as f64 * average_char_width;
    logical_size * scale_factor
}
```

Esta função multiplica o número de caracteres pela largura média de um caractere (0.6 unidades lógicas) e aplica o scale_factor para obter o tamanho físico correto.