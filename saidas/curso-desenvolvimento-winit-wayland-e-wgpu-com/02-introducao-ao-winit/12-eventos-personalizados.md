## Eventos Personalizados

Em aplicações gráficas complexas, frequentemente precisamos criar e despachar eventos específicos do nosso domínio, como "DownloadConcluído" ou "NívelCarregado". O Winit permite essa extensão através do tipo genérico `EventLoop<T>`, onde `T` é o tipo do seu evento personalizado.

### Definindo um Evento Customizado

Vamos criar um sistema de notificações para um editor de texto. Primeiro, definimos nosso tipo de evento:

```rust
#[derive(Debug)]
enum EditorEvent {
    SalvamentoConcluido(usize), // bytes salvos
    ErroIO(String),
    AutosaveAtivado,
    ModoEscuroToggle,
}
```

### Configurando o Event Loop

A criação do event loop agora especifica nosso tipo:

```rust
use winit::event_loop::EventLoop;

let event_loop = EventLoop::<EditorEvent>::with_user_event();
```

### Despachando Eventos

Para enviar eventos, obtemos um `EventLoopProxy`:

```rust
let proxy = event_loop.create_proxy();

// Em outra thread ou callback:
proxy.send_event(EditorEvent::SalvamentoConcluido(2048))
    .expect("Falha ao enviar evento");
```

### Tratando Eventos Personalizados

No loop principal, adicionamos um novo braço ao match:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        winit::event::Event::UserEvent(user_event) => {
            match user_event {
                EditorEvent::SalvamentoConcluido(bytes) => {
                    println!("Arquivo salvo: {} bytes", bytes);
                },
                EditorEvent::ErroIO(msg) => {
                    eprintln!("Erro: {}", msg);
                    *control_flow = winit::event_loop::ControlFlow::Exit;
                },
                // ... outros eventos
            }
        },
        // ... outros eventos do Winit
    }
});
```

### Erro Comum: Thread Safety

Um erro frequente é tentar usar o proxy entre threads sem os cuidados necessários:

```rust
std::thread::spawn(move || {
    proxy.send_event(EditorEvent::AutosaveAtivado).unwrap();
});
```

Isso funciona porque `EventLoopProxy` implementa `Send`. Porém, se capturarmos variáveis locais:

```rust
let config = load_config();
std::thread::spawn(move || {
    // ERRO: `config` não implementa Send
    proxy.send_event(EditorEvent::ModoEscuroToggle(config.dark_mode)).unwrap();
});
```

A solução é garantir que os dados enviados sejam `Send`:

```rust
let config = Arc::new(load_config());
let thread_config = config.clone();
std::thread::spawn(move || {
    proxy.send_event(EditorEvent::ModoEscuroToggle(thread_config.dark_mode)).unwrap();
});
```

### Exemplo Completo: Temporizador de Autosave

Vamos implementar um sistema de autosave periódico:

```rust
use std::time::Duration;
use std::sync::Arc;
use winit::event_loop::{EventLoop, ControlFlow};

#[derive(Debug)]
enum AutosaveEvent {
    Tick,
    SaveComplete(usize),
    SaveFailed(String),
}

fn main() {
    let event_loop = EventLoop::<AutosaveEvent>::with_user_event();
    let proxy = event_loop.create_proxy();

    // Thread de autosave
    std::thread::spawn(move || {
        loop {
            std::thread::sleep(Duration::from_secs(30));
            if let Err(e) = proxy.send_event(AutosaveEvent::Tick) {
                eprintln!("Thread de autosave encerrada: {}", e);
                break;
            }
        }
    });

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            winit::event::Event::UserEvent(event) => match event {
                AutosaveEvent::Tick => {
                    println!("Autosave iniciado...");
                    // Simula operação de salvamento
                    proxy.send_event(AutosaveEvent::SaveComplete(1024)).unwrap();
                },
                AutosaveEvent::SaveComplete(bytes) => {
                    println!("Autosave concluído: {} bytes", bytes);
                },
                AutosaveEvent::SaveFailed(msg) => {
                    eprintln!("Autosave falhou: {}", msg);
                },
            },
            _ => (),
        }
    });
}
```

Saída esperada a cada 30 segundos:
```
Autosave iniciado...
Autosave concluído: 1024 bytes
```

### Exercício: Sistema de Log

Implemente um sistema onde:
1. Uma thread secundária gera mensagens de log a cada 5 segundos
2. O loop principal exibe essas mensagens na janela
3. Inclua um tipo de evento `LogMessage` com níveis (Info, Warning, Error)

Solução comentada:

```rust
use winit::event_loop::EventLoop;

#[derive(Debug)]
enum LogEvent {
    Message { level: LogLevel, text: String },
}

#[derive(Debug)]
enum LogLevel {
    Info,
    Warning,
    Error,
}

fn main() {
    let event_loop = EventLoop::<LogEvent>::with_user_event();
    let proxy = event_loop.create_proxy();

    std::thread::spawn(move || {
        let messages = vec![
            (LogLevel::Info, "Sistema iniciado"),
            (LogLevel::Warning, "Memória abaixo do ideal"),
            (LogLevel::Error, "Disco quase cheio"),
        ];

        for (level, text) in messages {
            std::thread::sleep(Duration::from_secs(5));
            proxy.send_event(LogEvent::Message {
                level,
                text: text.to_string(),
            }).unwrap();
        }
    });

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        if let winit::event::Event::UserEvent(LogEvent::Message { level, text }) = event {
            println!("[{:?}] {}", level, text);
        }
    });
}
```