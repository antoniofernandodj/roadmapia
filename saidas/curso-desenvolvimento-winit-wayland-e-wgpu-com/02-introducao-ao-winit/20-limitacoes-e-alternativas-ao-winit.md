## Limitações e Alternativas ao Winit

Winit é excelente para aplicações gráficas cross-platform, mas há cenários onde ele não é a melhor escolha. Quando você precisa de controle absoluto sobre o loop de eventos ou acesso a recursos específicos do sistema operacional, as limitações ficam evidentes.

### O problema do controle granular

Considere um simulador de física que precisa rodar a 1000Hz independentemente da taxa de atualização da tela. Com Winit, você teria que usar `ControlFlow::Poll`, consumindo CPU desnecessariamente:

```rust
event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Poll; // Força polling contínuo
    match event {
        Event::MainEventsCleared => {
            physics_step(); // Chamado a cada poll, não a 1000Hz
        }
        _ => (),
    }
});
```

A saída real seria:
```
CPU usage: 100% (mesmo quando ocioso)
Physics steps: irregular (depende da velocidade do loop)
```

### Acesso direto a APIs de plataforma

Winit abstrai as diferenças entre sistemas, mas isso impede o uso de recursos específicos. Por exemplo, no Windows você não pode acessar diretamente o HWND para usar com APIs Win32:

```rust
let hwnd = window.hwnd(); // ERRO: método não existe
SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
```

A mensagem de erro seria:
```
error[E0599]: no method named `hwnd` found for struct `Window` in the current scope
```

### Alternativa: winit + raw-window-handle

Para casos que exigem acesso nativo, combine Winit com `raw-window-handle`:

```rust
use raw_window_handle::{HasRawWindowHandle, RawWindowHandle};

let window = WindowBuilder::new().build(&event_loop).unwrap();

match window.raw_window_handle() {
    RawWindowHandle::Win32(handle) => {
        // Agora temos acesso ao HWND
        unsafe { win32_specific_function(handle.hwnd) };
    }
    _ => unimplemented!(),
}
```

### Quando abandonar o Winit

Casos onde outras bibliotecas são mais adequadas:

1. **Jogos AAA**: Use [SDL2](https://crates.io/crates/sdl2) ou [miniquad](https://crates.io/crates/miniquad) para controle total sobre o loop de jogo
2. **Aplicações nativas complexas**: [GTK-rs](https://gtk-rs.org/) ou [Druid](https://github.com/linebender/druid) para widgets nativos
3. **Embedded/headless**: [glutin](https://crates.io/crates/glutin) para contexto OpenGL sem janela

### Exemplo concreto: Loop de jogo com SDL2

Comparação lado a lado mostra a diferença:

```rust
// Com SDL2
sdl2::timer::set_timer_priority(high);
let mut last_tick = Instant::now();
while running {
    let now = Instant::now();
    while now - last_tick >= TICK_RATE {
        physics_update();
        last_tick += TICK_RATE;
    }
    render();
    sdl2::timer::delay_until(next_frame); // Controle preciso
}

// Com Winit (aproximação)
*control_flow = ControlFlow::WaitUntil(Instant::now() + TICK_RATE);
```

### Exercício: Adaptando para alta precisão

**Problema**: Crie um cronômetro com precisão de microssegundos que atualize a tela a 60Hz.

**Solução**:
```rust
use std::time::{Instant, Duration};

let start_time = Instant::now();
let mut last_render = Instant::now();

event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::WaitUntil(last_render + Duration::from_millis(16));
    
    match event {
        Event::RedrawRequested(_) => {
            let now = Instant::now();
            let elapsed = now - start_time;
            render_ui(elapsed.as_micros()); // Precisão de µs
            last_render = now;
        }
        _ => (),
    }
});
```