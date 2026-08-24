## DPI Scaling Avançado

Quando sua aplicação gráfica precisa rodar em monitores de alta densidade (como HiDPI 4K), simplesmente multiplicar pixels causa elementos de UI borrados ou desproporcionais. O protocolo Wayland provê mecanismos sofisticados para scaling, mas exige tratamento explícito. Vamos implementar um controle preciso sobre como sua aplicação responde a diferentes densidades de pixels.

Considere um monitor com fator de escala 2x (típico em laptops 4K). Sem tratamento adequado, sua janela aparecerá minúscula. O Winit expõe esse valor através da API:

```rust
use winit::window::Window;

let window: Window = ...; // Janela já criada
let scale_factor = window.scale_factor();
println!("Fator de escala atual: {}", scale_factor);
```

Saída típica em um MacBook Pro Retina:
```
Fator de escala atual: 2
```

O erro mais comum é assumir que `scale_factor` é constante. Na verdade, ele pode mudar ao mover a janela entre monitores com DPI diferente. Este código falha:

```rust
// ERRO: Fator pode mudar dinamicamente
let initial_scale = window.scale_factor();
window.set_inner_size(PhysicalSize::new(800 * initial_scale, 600 * initial_scale));
```

A mensagem de erro não será imediata - a janela simplesmente ficará mal dimensionada quando movida. A solução correta é ouvir eventos de mudança:

```rust
use winit::event::{Event, WindowEvent};
use winit::dpi::{LogicalSize, PhysicalSize};

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent {
            event: WindowEvent::ScaleFactorChanged { scale_factor, new_inner_size },
            ..
        } => {
            println!("Novo fator de escala: {}", scale_factor);
            // Atualize buffers/texturas aqui
            *new_inner_size = PhysicalSize::new(
                (800.0 * scale_factor) as u32,
                (600.0 * scale_factor) as u32,
            );
        }
        _ => (),
    }
});
```

Para aplicações gráficas customizadas usando WGPU, você precisa redimensionar a swapchain quando o DPI muda:

```rust
// No handler de ScaleFactorChanged
let new_size = new_inner_size.to_logical::<f32>(scale_factor);
surface.configure(
    &device,
    &wgpu::SurfaceConfiguration {
        width: new_size.width as u32,
        height: new_size.height as u32,
        // ... outras configurações
    },
);
```

Um desafio comum é coordenar entre coordenadas físicas (pixels reais) e lógicas (pontos independentes de DPI). O Winit oferece conversões:

```rust
let physical_size = PhysicalSize::new(800, 600);
let logical_size = physical_size.to_logical(scale_factor);
println!("Tamanho lógico: {:?}", logical_size);
```

Saída com scale_factor=2:
```
Tamanho lógico: LogicalSize { width: 400.0, height: 300.0 }
```

**Exercício**: Modifique um aplicativo existente para tratar corretamente:
1. Mudanças dinâmicas de DPI ao mover entre monitores
2. Redimensionamento da swapchain
3. Conversão de eventos de mouse entre coordenadas físicas e lógicas

**Solução comentada**:

```rust
// 1. Armazene o scale_factor atual
struct AppState {
    scale_factor: f64,
    // ... outros campos
}

// 2. Atualize no evento
Event::WindowEvent {
    event: WindowEvent::ScaleFactorChanged { scale_factor, new_inner_size },
    ..
} => {
    app_state.scale_factor = scale_factor;
    let new_size = new_inner_size.to_logical::<f32>(scale_factor);
    surface.configure(/* ... */);
}

// 3. Converta coordenadas do mouse
Event::WindowEvent {
    event: WindowEvent::CursorMoved { position, .. },
    ..
} => {
    let logical_pos = position.to_logical(app_state.scale_factor);
    // Use logical_pos para cálculos de UI
}
```