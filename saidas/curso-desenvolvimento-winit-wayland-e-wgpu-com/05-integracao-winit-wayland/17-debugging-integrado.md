## Debugging Integrado

Quando você integra Winit com Wayland, problemas podem surgir em vários níveis - desde falhas na conexão com o compositor até comportamentos inesperados na renderização. Vamos explorar as ferramentas essenciais para diagnosticar esses problemas.

### WAYLAND_DEBUG: O Seu Primeiro Aliado

A variável de ambiente `WAYLAND_DEBUG` é a ferramenta mais poderosa para entender o que está acontecendo na comunicação com o servidor Wayland. Quando definida como `1`, ela mostra todos os protocolos sendo trocados:

```bash
WAYLAND_DEBUG=1 cargo run
```

Isso produzirá um log detalhado como:

```
[1234567.890]  -> wl_display@1.get_registry(new id wl_registry@2)
[1234567.891]  -> wl_display@1.sync(new id wl_callback@3)
[1234567.892] wl_display@1.delete_id(3)
[1234567.893] wl_registry@2.global(1, "wl_compositor", 4)
```

Um erro comum aparece quando o protocolo esperado não está disponível:

```
[ERROR] [wayland_client] Interface 'wl_shell' version 1 not available
```

Neste caso, você precisará atualizar seu código para usar `xdg_shell` (o padrão moderno) em vez do antigo `wl_shell`.

### Verificando o Backend em Tempo de Execução

Para confirmar que sua aplicação está realmente usando o backend Wayland (e não um fallback para X11), adicione esta verificação:

```rust
use winit::platform::wayland::EventLoopWindowTargetExtWayland;

fn main() {
    let event_loop = EventLoop::new();
    
    if event_loop.is_wayland() {
        println!("Running on Wayland!");
        let display = event_loop.wayland_display().unwrap();
        println!("Wayland display handle: {:?}", display);
    } else {
        eprintln!("Not running on Wayland!");
    }
}
```

### Acessando Informações do Compositor

Você pode inspecionar as capacidades do compositor Wayland em execução:

```rust
use winit::platform::wayland::EventLoopBuilderExtWayland;

let event_loop = EventLoopBuilder::new()
    .with_wayland()
    .build();

if let Some(display) = event_loop.wayland_display() {
    println!("Compositor name: {}", display.compositor_name());
    println!("Compositor version: {}", display.compositor_version());
    println!("Protocolos suportados:");
    for protocol in display.supported_protocols() {
        println!("- {} (v{})", protocol.name, protocol.version);
    }
}
```

### Debug de Superfície Wayland

Quando você está trabalhando com superfícies personalizadas, é crucial verificar se elas foram configuradas corretamente:

```rust
use winit::platform::wayland::WindowExtWayland;

let window = WindowBuilder::new()
    .with_decorations(false)
    .build(&event_loop)
    .unwrap();

if let Some(surface) = window.wayland_surface() {
    println!("Surface ID: {}", surface.id());
    println!("Surface role: {:?}", surface.role());
    println!("Surface size: {:?}", surface.size());
} else {
    eprintln!("Failed to get Wayland surface!");
}
```

### Tratamento de Erros Comuns

1. **Falha na Criação da Janela**:
   ```
   [ERROR] [winit] No available backend for window creation
   ```
   Solução: Verifique se o Wayland está instalado e ativo no seu sistema.

2. **Protocolo Não Suportado**:
   ```
   [ERROR] [wayland_client] Interface 'zwlr_layer_shell_v1' version 3 not available
   ```
   Solução: Verifique os protocolos disponíveis e ajuste sua versão ou implemente um fallback.

3. **Problemas de Permissão**:
   ```
   [ERROR] [wayland_client] Permission denied when connecting to Wayland display
   ```
   Solução: Verifique as permissões do socket Wayland (geralmente em `/run/user/1000/wayland-0`).

### Exercício Prático

**Problema**: Crie uma aplicação que:
1. Verifica se está rodando no Wayland
2. Lista todos os protocolos suportados pelo compositor
3. Cria uma janela sem decorações
4. Imprime informações da superfície Wayland

**Solução**:

```rust
use winit::{
    event_loop::EventLoop,
    window::WindowBuilder,
    platform::wayland::{
        EventLoopExtWayland,
        WindowExtWayland
    }
};

fn main() {
    let event_loop = EventLoop::new();
    
    println!("Running on Wayland: {}", event_loop.is_wayland());
    
    if let Some(display) = event_loop.wayland_display() {
        println!("Supported protocols:");
        for protocol in display.supported_protocols() {
            println!("- {} v{}", protocol.name, protocol.version);
        }
    }

    let window = WindowBuilder::new()
        .with_decorations(false)
        .build(&event_loop)
        .unwrap();

    if let Some(surface) = window.wayland_surface() {
        println!("Surface created successfully:");
        println!("ID: {}", surface.id());
        println!("Size: {:?}", surface.size());
    }

    event_loop.run(move |_, _, _| {});
}
```

Saída esperada (varia por compositor):

```
Running on Wayland: true
Supported protocols:
- wl_compositor v4
- xdg_wm_base v2
- zwp_pointer_constraints_v1 v1
Surface created successfully:
ID: 42
Size: PhysicalSize { width: 800, height: 600 }
```