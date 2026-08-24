## Conexão Básica com o Compositor

Toda aplicação gráfica Wayland começa estabelecendo uma conexão com o compositor. Essa conexão é o canal de comunicação onde sua aplicação (cliente) envia requisições e recebe eventos do servidor. Vamos criar uma conexão mínima que mostra como inicializar e finalizar corretamente essa ligação.

```rust
use wayland_client::{Display, GlobalManager};

fn main() {
    // Conecta ao compositor padrão (WAYLAND_DISPLAY ou padrão do sistema)
    let display = Display::connect_to_env().unwrap();
    
    // Cria um gerenciador de globals para descobrir capacidades do servidor
    let mut globals = GlobalManager::new(&display);

    // Sincroniza com o servidor para receber a lista de globals
    let mut event_queue = display.create_event_queue();
    let attached_display = display.attach(event_queue.token());
    globals.instantiate_auto(&attached_display).unwrap();

    // Rodada de sincronização para garantir que temos os globals
    event_queue.sync_roundtrip(&mut globals).unwrap();

    println!("Conexão Wayland estabelecida com sucesso!");

    // Aqui normalmente entraríamos no event loop...
    // Mas para este exemplo, apenas limpamos
}
```

Saída esperada (se o compositor estiver rodando):
```
Conexão Wayland estabelecida com sucesso!
```

O erro mais comum aqui é esquecer a sincronização (`sync_roundtrip`), resultando em:
```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: 
NoGlobal("wl_compositor")', src/main.rs:10:10
```

Isso acontece porque tentamos usar interfaces antes do servidor anunciar quais estão disponíveis. A correção está na chamada `sync_roundtrip`, que aguarda essa comunicação inicial.

Para entender melhor, vamos decompor os componentes:

1. **`Display`**: Representa a conexão física com o servidor. É o objeto-raiz que permite criar todos os outros objetos Wayland. Mantém o socket de comunicação.

2. **`GlobalManager`**: Cataloga as interfaces globais que o compositor oferece (como wl_compositor, wl_shm). Faz a descoberta automática das capacidades do servidor.

3. **Event Queue**: Canaliza todos os eventos do servidor. Mesmo nesta conexão básica, precisamos de uma fila para a sincronização inicial.

A conexão Wayland é mais leve que seu equivalente X11. Enquanto no X11 você precisa inicializar dezenas de extensões manualmente, o Wayland descobre automaticamente através dos globals. Essa diferença fica clara quando comparamos o código de inicialização:

```rust
// Wayland (14 linhas limpas)
let display = Display::connect_to_env()?;
let mut globals = GlobalManager::new(&display);
let mut queue = display.create_event_queue();
let attached = display.attach(queue.token());
globals.instantiate_auto(&attached)?;
queue.sync_roundtrip(&mut globals)?;

// X11 (30+ linhas com Xlib/XCB)
let conn = xcb::Connection::connect(None)?.0;
let setup = conn.get_setup();
let screen = setup.roots().next().unwrap();
// ... mais inicialização de extensões manualmente
```

Quando a conexão é encerrada (quando `display` sai do escopo), todos os recursos são liberados automaticamente. Isso é garantido pelo sistema de ownership do Rust, evitando vazamentos comuns em implementações C.

**Exercício**: Modifique o exemplo para verificar se a interface wl_compositor versão 4 está disponível antes de prosseguir. Trate o erro adequadamente se não estiver.

```rust
// Solução
use wayland_client::protocol::wl_compositor::WlCompositor;

fn check_compositor_version(globals: &GlobalManager) -> Result<(), Box<dyn std::error::Error>> {
    if globals.instantiate_exact::<WlCompositor>(4).is_err() {
        Err("wl_compositor v4 não disponível".into())
    } else {
        Ok(())
    }
}

// Uso no main:
check_compositor_version(&globals)?;
```

Esta verificação é crucial em aplicações reais, pois diferentes compositors podem oferecer versões distintas da mesma interface. Por exemplo, o wl_compositor v4 adicionou recursos de sincronização que não existiam na v3.