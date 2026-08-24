## Error Handling

Em sistemas gráficos com Wayland, erros não são exceções - são parte fundamental do fluxo de trabalho. O protocolo foi projetado para falhar cedo e de forma previsível, permitindo que os clientes se recuperem ou encerrem graciosamente. Vejamos como lidar com os casos mais comuns:

### Conexão Recusada

A primeira linha de defesa é a criação da conexão. Quando o compositor não está disponível ou rejeita a conexão:

```rust
use wayland_client::{Display, ConnectError};

let display = match Display::connect_to_env() {
    Ok(display) => display,
    Err(ConnectError::NoCompositorListening) => {
        eprintln!("Nenhum compositor Wayland está executando ou a variável DISPLAY está incorreta");
        std::process::exit(1);
    },
    Err(ConnectError::NoWaylandLib) => {
        eprintln!("Biblioteca Wayland não encontrada - verifique sua instalação");
        std::process::exit(1);
    },
    Err(e) => {
        eprintln!("Erro desconhecido ao conectar: {}", e);
        std::process::exit(1);
    }
};
```

Saída possível:
```
Nenhum compositor Wayland está executando ou a variável DISPLAY está incorreta
```

### Objetos Inválidos

Tentar usar um objeto Wayland após sua destruição gera um erro comum. O protocolo usa IDs numéricos que podem ser reutilizados:

```rust
use wayland_client::protocol::wl_surface::WlSurface;

fn draw_on_surface(surface: &WlSurface) -> Result<(), wayland_client::InvalidId> {
    if surface.as_ref().is_null() {
        return Err(wayland_client::InvalidId);
    }
    // Operações seguras com a surface...
    Ok(())
}

let surface = compositor.create_surface(&display);
surface.destroy(); // Libera o ID

match draw_on_surface(&surface) {
    Ok(_) => println("Operação bem-sucedida"),
    Err(e) => eprintln!("Erro: tentativa de usar surface destruída: {:?}", e),
}
```

Saída:
```
Erro: tentativa de usar surface destruída: InvalidId
```

### Versões Incompatíveis

Wayland é extensível via versões de protocolo. Tentar usar recursos não suportados:

```rust
use wayland_client::globals::{GlobalList, global_filter};

let globals = GlobalList::new(&display);
let _ = display.sync_roundtrip(&mut event_queue)?;

let xdg_shell = global_filter!(
    globals,
    xdg_wm_base,
    |xdg: &xdg_wm_base::XdgWmBase| xdg.ping(42) // ping() requer versão >= 3
).ok_or("Compositor não suporta xdg_wm_base")?;
```

Se o compositor suportar apenas xdg_wm_base v2, o erro será:
```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: 
wayland protocol error 0: invalid version for object 4 (wanted >=3, has 2)'
```

### Tratamento de Protocol Errors

Wayland emite erros de protocolo como respostas do servidor. Para capturá-los:

```rust
use wayland_client::{Display, event_queue::EventQueue};
use wayland_client::protocol::wl_display::WlDisplay;

let mut event_queue = display.create_event_queue();
let display_proxy = display.attach(event_queue.token());

// Configura um callback para erros globais
display_proxy.quick_assign(move |_, error_event, _| {
    eprintln!(
        "Erro de protocolo: código {}, mensagem: '{}', objeto: {}:{}",
        error_event.error_code,
        error_event.message,
        error_event.object_id,
        error_event.object_interface
    );
});
```

Exemplo de saída quando um buffer inválido é anexado:
```
Erro de protocolo: código 1, mensagem: 'invalid buffer dimensions', objeto: 7:wl_buffer
```

### Double-Buffering Faltante

Um erro silencioso comum é esquecer do double-buffering, causando flickering:

```rust
// ERRADO: Sem double-buffering
surface.attach(Some(&buffer), 0, 0);
surface.commit();

// CORRETO: Com double-buffering implementado
let next_buffer = create_buffer(width, height)?;
surface.attach(Some(&next_buffer), 0, 0);
surface.commit();
```

### Exercício: Handler Resiliente

Implemente um handler para wl_keyboard que:
1. Verifica se o teclado ainda é válido antes de cada operação
2. Captura erros de protocolo durante o processamento de eventos
3. Loga adequadamente falhas sem quebrar o loop de eventos

Solução comentada:

```rust
use wayland_client::protocol::wl_keyboard::{WlKeyboard, Event};

fn setup_keyboard(keyboard: WlKeyboard) {
    keyboard.quick_assign(move |keyboard, event, _| {
        // Verificação de validade
        if keyboard.as_ref().is_null() {
            eprintln!("Teclado inválido - ignorando evento");
            return;
        }

        match event {
            Event::Key { key, state, .. } => {
                println!("Key event: {} {}", key, state);
            },
            _ => {}
        }
    });

    // Configura callback de erro
    keyboard.quick_assign(move |_, error_event, _| {
        eprintln!(
            "Erro no teclado: código {}, mensagem: '{}'",
            error_event.error_code,
            error_event.message
        );
    });
}
```