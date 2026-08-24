## Arquitetura do Wayland

Imagine que você está construindo um aplicativo gráfico em Rust. Quando você usa uma biblioteca como Winit para criar uma janela, por baixo dos panos ela precisa conversar com o sistema de janelas do seu sistema operacional. No Linux moderno, essa comunicação geralmente acontece através do protocolo Wayland - mas como esse diálogo realmente funciona?

O Wayland opera em um modelo cliente-servidor radicalmente diferente do X11. No coração do sistema está o **compositor Wayland**, que desempenha três papéis fundamentais:

1. **Gerenciador de exibição**: controla quais aplicações são mostradas na tela e como
2. **Servidor de protocolo**: implementa as interfaces Wayland padrão
3. **Mediador de recursos**: gerencia acesso a dispositivos como teclado, mouse e GPUs

Os clientes (seus aplicativos) se comunicam com o compositor através de um protocolo assíncrono baseado em troca de mensagens. Vamos ver isso na prática com um exemplo mínimo usando a crate `wayland-client`:

```rust
use wayland_client::{Display, GlobalManager};

fn main() {
    // Conecta ao servidor Wayland padrão
    let display = Display::connect_to_env().unwrap();
    
    // Cria um event queue para gerenciar mensagens
    let mut event_queue = display.create_event_queue();
    
    // Obtém a lista de globals disponíveis
    let globals = GlobalManager::new(&display.attach(event_queue.token()));
    
    // Sincroniza para receber a lista atual de globals
    event_queue.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();
    
    println!("Interfaces globais disponíveis:");
    for interface in globals.list() {
        println!("- {} (versão {})", interface.interface, interface.version);
    }
}
```

A saída típica em um sistema com GNOME rodando Wayland seria algo como:

```
Interfaces globais disponíveis:
- wl_compositor (versão 4)
- wl_shm (versão 1)
- wl_seat (versão 7)
- xdg_wm_base (versão 3)
- zxdg_decoration_manager_v1 (versão 1)
```

O erro mais comum aqui é tentar usar os globals imediatamente sem esperar pela sincronização. Se você remover o `sync_roundtrip`, verá:

```
thread 'main' panicked at 'called `Option::unwrap()` on a `None` value'
```

Isso acontece porque o Wayland é assíncrono - o servidor pode levar vários frames para responder com a lista completa de interfaces disponíveis.

A comunicação acontece através de **objetos wayland**, cada um representando um recurso no servidor. Por exemplo, quando você cria uma janela:

1. Seu aplicativo pede ao compositor para criar um novo objeto `wl_surface`
2. Vincula essa surface a um objeto `xdg_toplevel` para torná-la uma janela
3. Negocia buffers de memória compartilhada para desenhar o conteúdo

Toda essa arquitetura tem três vantagens principais sobre o X11:

1. **Segurança**: aplicações só podem acessar recursos explicitamente concedidos
2. **Extensibilidade**: novos protocolos podem ser adicionados sem modificar o core
3. **Performance**: sem cópias desnecessárias de buffers gráficos

Um exercício para consolidar: modifique o exemplo acima para filtrar e mostrar apenas as interfaces globais cujos nomes começam com "wl_". Depois, verifique quantas versões diferentes do protocolo wl_seat estão disponíveis.

Solução comentada:

```rust
let wl_globals = globals.list()
    .filter(|g| g.interface.starts_with("wl_"))
    .collect::<Vec<_>>();
println!("Interfaces 'wl_' encontradas: {}", wl_globals.len());

let seat_versions = globals.list()
    .filter(|g| g.interface == "wl_seat")
    .map(|g| g.version)
    .collect::<Vec<_>>();
println!("Versões do wl_seat: {:?}", seat_versions);
```