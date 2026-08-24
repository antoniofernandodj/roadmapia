## Tratamento de Eventos de Input

Um editor de texto que não responde a teclas, ou um jogo que ignora o mouse, são inúteis. Vejamos como o Winit transforma ações físicas em eventos estruturados que seu código pode processar.

O coração do input está no `Event::WindowEvent`. Dentro dele, os eventos mais comuns são:

```rust
use winit::event::{Event, WindowEvent};
use winit::event_loop::ControlFlow;

event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Wait;

    match event {
        Event::WindowEvent { event, .. } => match event {
            WindowEvent::KeyboardInput { input, .. } => {
                println!("Tecla: {:?}", input);
            },
            WindowEvent::MouseInput { button, state, .. } => {
                println!("Botão {:?} {:?}", button, state);
            },
            _ => ()
        },
        _ => ()
    }
});
```

A saída ao pressionar 'A' e clicar com o mouse esquerdo seria:
```
Tecla: KeyboardInput { scancode: 16, state: Pressed, virtual_keycode: Some(A), modifiers: (empty) }
Botão Left Pressed
```

**VirtualKeyCode vs Scancode**: Enquanto `virtual_keycode` (como `KeyA`) é padronizado entre teclados, `scancode` é específico do hardware. Para jogos, use `VirtualKeyCode`. Para aplicações que precisam lidar com teclados internacionais, `scancode` pode ser necessário.

Um erro comum é tentar capturar teclas sem verificar o estado (Pressed/Released):
```rust
// ERRADO - dispara duas vezes (press e release)
if let Some(key) = input.virtual_keycode {
    println!("Tecla pressionada: {:?}", key);
}
```

O correto:
```rust
if input.state == ElementState::Pressed {
    if let Some(key) = input.virtual_keycode {
        match key {
            VirtualKeyCode::Escape => *control_flow = ControlFlow::Exit,
            VirtualKeyCode::A => println!("Move esquerda"),
            _ => (),
        }
    }
}
```

**Movimento do mouse** vem em dois sabores:
```rust
WindowEvent::CursorMoved { position, .. } => {
    // LogicalPosition já considera DPI
    println!("Mouse em: {:?}", position);
},
WindowEvent::MouseWheel { delta, .. } => {
    match delta {
        MouseScrollDelta::LineDelta(x, y) => {
            println!("Rolagem suave: {} linhas horizontais, {} verticais", x, y);
        },
        MouseScrollDelta::PixelDelta(pos) => {
            println!("Rolagem pixel a pixel: {:?}", pos);
        }
    }
}
```

Um gotcha importante: em algumas plataformas (especialmente Wayland), eventos de mouse podem não ser gerados quando o cursor está fora da janela. Para capturar movimento global, você precisaria de APIs específicas da plataforma.

**Modificadores** (Shift, Ctrl) são tratados separadamente:
```rust
WindowEvent::KeyboardInput { input, .. } => {
    if input.modifiers.shift() && input.virtual_keycode == Some(VirtualKeyCode::A) {
        println!("Shift+A pressionado");
    }
}
```

Para implementar arrastar-e-soltar, combine eventos:
```rust
let mut dragging = false;

match event {
    WindowEvent::MouseInput { button: MouseButton::Left, state: ElementState::Pressed, .. } => {
        dragging = true;
    },
    WindowEvent::MouseInput { button: MouseButton::Left, state: ElementState::Released, .. } => {
        dragging = false;
    },
    WindowEvent::CursorMoved { position, .. } if dragging => {
        println!("Arrastando para {:?}", position);
    },
    _ => ()
}
```

**Exercício**: Implemente um contador que:
1. Incrementa com seta para cima
2. Decrementa com seta para baixo
3. Multiplica por 2 com Shift+seta para cima
4. Zera com Escape

**Solução**:
```rust
let mut counter = 0;

match event {
    Event::WindowEvent { event, .. } => match event {
        WindowEvent::KeyboardInput { input, .. } if input.state == Pressed => {
            match input.virtual_keycode {
                Some(Up) if input.modifiers.shift() => counter *= 2,
                Some(Up) => counter += 1,
                Some(Down) => counter -= 1,
                Some(Escape) => counter = 0,
                _ => (),
            }
            println!("Contador: {}", counter);
        },
        _ => ()
    },
    _ => ()
}
```