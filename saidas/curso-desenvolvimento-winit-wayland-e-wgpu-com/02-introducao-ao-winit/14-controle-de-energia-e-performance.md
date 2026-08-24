## Controle de Energia e Performance

Quando uma aplicação gráfica roda em segundo plano sem renderização ativa, consumir recursos desnecessariamente é um problema real. O Winit oferece mecanismos para equilibrar performance e eficiência energética através do `ControlFlow` e do gerenciamento de estados de suspensão.

### O Problema do Loop de Eventos

Considere este loop básico que renderiza continuamente:

```rust
event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Poll;
    
    match event {
        Event::MainEventsCleared => {
            render_frame(); // Consome CPU/GPU mesmo quando ocioso
        }
        _ => (),
    }
});
```

A saída no terminal mostra um uso constante de 15-20% da CPU, mesmo com a janela minimizada:

```
CPU usage: 18% (steady)
GPU active: 100%
```

### Controle de Fluxo Inteligente

O Winit oferece três estratégias principais através do `ControlFlow`:

1. **Poll**: Busca eventos continuamente (alto consumo)
   ```rust
   *control_flow = ControlFlow::Poll;
   ```
2. **Wait**: Dorme até o próximo evento (eficiente)
   ```rust
   *control_flow = ControlFlow::Wait;
   ```
3. **WaitUntil**: Agenda o próximo despertar
   ```rust
   *control_flow = ControlFlow::WaitUntil(Instant::now() + Duration::from_millis(16));
   ```

Um padrão comum para aplicações interativas combina os modos:

```rust
*control_flow = match event {
    Event::NewEvents(_) => {
        if window.is_visible() && !window.is_minimized() {
            ControlFlow::Poll
        } else {
            ControlFlow::Wait
        }
    }
    Event::MainEventsCleared => {
        if needs_redraw() {
            render_frame();
            ControlFlow::WaitUntil(Instant::now() + Duration::from_millis(16))
        } else {
            ControlFlow::Wait
        }
    }
    _ => ControlFlow::Wait,
};
```

### Suspensão em Plataformas Móveis

Em dispositivos móveis, o gerenciamento de energia é crítico. O Winit emite eventos específicos:

```rust
match event {
    Event::Suspended => {
        release_gpu_resources();
        *control_flow = ControlFlow::Wait;
    }
    Event::Resumed => {
        recreate_gpu_resources();
        request_redraw();
    }
    _ => (),
}
```

### Erro Comum: Vazamento de Recursos

Um erro frequente é esquecer de liberar recursos quando a janela perde foco:

```rust
// ERRADO - Continua renderizando em segundo plano
*control_flow = ControlFlow::Poll;
```

A mensagem de erro típica em sistemas Linux mostra o problema:

```
[WARN wgpu_core::device] Excesso de submissões de comandos (1000+ frames pendentes)
```

A correção envolve monitorar o estado da janela:

```rust
let mut focused = true;

match event {
    Event::WindowEvent { event: WindowEvent::Focused(f), .. } => {
        focused = f;
        *control_flow = if f { ControlFlow::Poll } else { ControlFlow::Wait };
    }
    _ => (),
}
```

### Exercício Prático: Medição de Consumo

Implemente um sistema que:
1. Reduza a taxa de atualização para 30fps quando em segundo plano
2. Desative completamente a renderização quando minimizado
3. Restaure o estado completo quando retornar ao primeiro plano

Solução comentada:

```rust
enum AppState {
    Active,
    Background,
    Suspended,
}

let mut state = AppState::Active;

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event: WindowEvent::Minimized(true), .. } => {
            state = AppState::Suspended;
            *control_flow = ControlFlow::Wait;
        }
        Event::WindowEvent { event: WindowEvent::Focused(false), .. } => {
            state = AppState::Background;
            *control_flow = ControlFlow::WaitUntil(Instant::now() + Duration::from_millis(33)); // ~30fps
        }
        Event::WindowEvent { event: WindowEvent::Focused(true), .. } => {
            state = AppState::Active;
            *control_flow = ControlFlow::Poll;
            window.request_redraw();
        }
        Event::MainEventsCleared => match state {
            AppState::Active => {
                render_frame();
                *control_flow = ControlFlow::Poll;
            }
            AppState::Background => {
                render_low_quality_frame();
                *control_flow = ControlFlow::WaitUntil(Instant::now() + Duration::from_millis(33));
            }
            AppState::Suspended => {
                *control_flow = ControlFlow::Wait;
            }
        },
        _ => (),
    }
});
```