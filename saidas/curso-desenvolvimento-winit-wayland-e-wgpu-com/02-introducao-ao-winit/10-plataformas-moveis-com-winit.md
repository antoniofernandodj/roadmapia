## Plataformas Móveis com Winit

Desenvolver para dispositivos móveis com Winit requer abordagens específicas devido às diferenças fundamentais em como Android e iOS gerenciam aplicações. Ao contrário de desktops onde seu programa controla o main loop, em móveis o sistema operacional é dono do ciclo de vida.

Um exemplo mínimo para Android precisa lidar com a Activity nativa. Veja como criar uma janela que sobrevive a pausas:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    platform::android::EventLoopExtAndroid,
    window::WindowBuilder,
};

#[no_mangle]
fn android_main(app: winit::platform::android::Activity) {
    let event_loop = EventLoop::new();
    event_loop.with_android_app(app); // Conecta ao contexto Android
    
    let window = WindowBuilder::new()
        .with_visible(false) // Inicia oculta até preparação completa
        .build(&event_loop)
        .unwrap();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::Resumed => {
                window.set_visible(true); // Mostra quando a Activity está ativa
                println!("Aplicação retomada");
            },
            Event::Suspended => {
                window.set_visible(false); // Oculta durante pausa
                println!("Aplicação pausada");
            },
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
```

A saída no logcat mostra o ciclo:
```
D/RustStdoutStderr: Aplicação retomada
D/RustStdoutStderr: Aplicação pausada
```

O erro comum é esquecer de lidar com `Resumed`/`Suspended`, causando panics quando o sistema recria a Activity. Sem `set_visible(false)`, você pode ver janelas "fantasma" após rotacionar a tela.

Para iOS, o desafio é integrar com o UIApplicationDelegate. Este exemplo mostra como iniciar dentro de um UIView:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::EventLoop,
    platform::ios::WindowExtIOS,
    window::WindowBuilder,
};

#[no_mangle]
pub extern "C" fn run_app() {
    let event_loop = EventLoop::new();
    
    let window = WindowBuilder::new()
        .with_title("Rust IOS")
        .build(&event_loop)
        .unwrap();

    // Obtém a UIView nativa para inserção na hierarquia
    let ui_view = window.ui_view();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::Touch(touch),
                ..
            } => {
                println!("Toque em {:?}", touch.location);
            },
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
```

Diferenças cruciais para mobile:
1. **DPI Dinâmico**: Dispositivos móveis têm escalas que mudam com orientação. Use `window.scale_factor()` após cada `Resized`
2. **Input Virtual**: Teclados aparecem/destroem dinamicamente. Monitore `KeyboardHeightChanged`
3. **Thread Principal**: Todo acesso à UI deve ser na main thread. Use `dispatch_queue::get_main()` no iOS

Erro típico:
```rust
std::thread::spawn(|| {
    window.set_title("Novo título"); // PANIC: `accessibilityActivate` must be called on main thread
});
```

Correção com dispatch:
```rust
use ctn::dispatch_queue;

dispatch_queue::get_main().exec_async(|| {
    window.set_title("Título seguro");
});
```

Exercício: Modifique o exemplo Android para:
1. Manter contagem de quantas vezes foi pausado
2. Alterar o título da janela ao reiniciar incluindo essa contagem

Solução:
```rust
// Dentro do Event::Resumed
let pause_count = Arc::new(Mutex::new(0)); // Compartilhado entre eventos

Event::Resumed => {
    *pause_count.lock().unwrap() += 1;
    window.set_title(&format!("Retomado {} vezes", pause_count.lock().unwrap()));
    window.set_visible(true);
},
```