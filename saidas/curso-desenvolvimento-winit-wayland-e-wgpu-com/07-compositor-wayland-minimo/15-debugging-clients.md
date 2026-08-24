## Debugging Clients

Quando um cliente Wayland não se comporta como esperado — janelas não aparecem, eventos de input são ignorados ou a aplicação trava silenciosamente — você precisa de ferramentas que exponham a comunicação entre cliente e compositor. O protocolo binário do Wayland não é legível por humanos, mas estas técnicas revelam o que realmente está acontecendo nos sockets UNIX.

### 1. Logging de Mensagens com `WAYLAND_DEBUG`

A variável de ambiente `WAYLAND_DEBUG=1` é seu primeiro aliado. Quando definida, tanto o cliente quanto o compositor imprimem todas as mensagens trocadas no protocolo. Veja como ativá-la para um cliente simples:

```bash
WAYLAND_DEBUG=1 weston-terminal
```

A saída mostra cada mensagem serializada, incluindo criação de objetos e chamadas de método:

```
[1732928.670]  -> wl_display@1.get_registry(new id wl_registry@2)
[1732928.689]  -> wl_registry@2.bind(4, "wl_compositor", 4, new id wl_compositor@3)
```

**Erro comum:** esquecer que o logging é por processo. Se seu cliente spawna subprocessos, cada um precisa de `WAYLAND_DEBUG=1` separadamente.

### 2. Inspeção com `wl-info`

Para listar as interfaces globais que seu compositor oferece, use `wl-info` (parte do pacote `wayland-utils`):

```rust
// Exemplo mínimo que lista globais
use wayland_client::{Display, GlobalManager};

fn main() {
    let display = Display::connect_to_env().unwrap();
    let globals = GlobalManager::new(&display);
    
    display.roundtrip().unwrap(); // Espera anúncio de globais
    
    for global in globals.list() {
        println!(
            "Interface: {}, Versão: {}, ID: {}",
            global.interface,
            global.version,
            global.id
        );
    }
}
```

Saída esperada:
```
Interface: wl_compositor, Versão: 4, ID: 2
Interface: wl_shm, Versão: 1, ID: 3
Interface: xdg_wm_base, Versão: 3, ID: 4
```

**Problema frequente:** versões incompatíveis. Se um cliente pede `wl_compositor@5` mas seu compositor só oferece versão 4, a conexão falha silenciosamente.

### 3. Dump de Estados com `weston-info`

Quando um cliente parece conectar mas não mostra janelas, `weston-info --verbose` revela detalhes críticos:

```bash
weston-info --verbose | grep -A10 "xdg_surface"
```

Isso mostra se o cliente criou surfaces mas não as preencheu com buffers, um erro comum em aplicações gráficas mal configuradas.

### 4. Protocolo de Input com `wev`

Para debugar eventos de teclado/mouse, `wev` (Wayland Event Viewer) mostra cada evento cru recebido pelo cliente:

```bash
wev -f pointer
```

Movendo o mouse sobre uma janela, você verá:

```
EVENT: wl_pointer@8.motion
time: 123456, surface_x: 100.0, surface_y: 50.0
```

**Armadilha:** coordenadas podem estar em espaço lógico ou físico, dependendo da escala (`wl_output.scale`).

### 5. Solução de Problemas com `strace`

Quando tudo mais falha, `strace` revela chamadas de sistema subjacentes. Filtre por socket UNIX:

```bash
strace -e trace=network,openat,write,read your_wayland_client 2>&1 | grep wayland
```

Procure por:
- `connect` falhando para `/tmp/wayland-0`
- `write`/`read` bloqueando indefinidamente (deadlock no protocolo)

### 6. Exemplo Prático: Diagnóstico de Janela Congelada

Suponha que um cliente pareça congelado após mostrar uma janela. Seu fluxo de debug:

1. **Verifique atividade no socket:**
   ```bash
   lsof -U | grep wayland
   ```
   Mostra se o cliente ainda está conectado.

2. **Capture mensagens pendentes:**
   ```rust
   // No compositor, para um client específico
   println!("Pending events: {}", client.connection.flush().unwrap());
   ```

3. **Inspecione buffers de surface:**
   ```rust
   if surface.buffer.is_none() {
       eprintln!("Surface {} has no attached buffer", surface.id);
   }
   ```

**Caso real:** Um cliente em Rust esquecia de chamar `xdg_surface.ack_configure()` após receber um evento, fazendo o compositor bloquear updates.

### Exercício: Client que Não Responde a Input

Crie um cliente mínimo que:
1. Abre uma janela via `xdg_shell`
2. Não reage a eventos de teclado

**Solução comentada:**
```rust
use wayland_client::{Display, GlobalManager, protocol::{wl_compositor, xdg_shell}};

fn main() {
    let display = Display::connect_to_env().unwrap();
    let globals = GlobalManager::new(&display);
    
    display.roundtrip().unwrap(); // Sincroniza globais
    
    let compositor = globals.instantiate_exact::<wl_compositor::WlCompositor>(4).unwrap();
    let surface = compositor.create_surface();
    let xdg_surface = globals.instantiate_exact::<xdg_shell::XdgSurface>(3)
        .unwrap()
        .get_xdg_surface(&surface);
    
    // Faltou implementar wl_keyboard handler!
    loop { display.dispatch().unwrap(); }
}
```
O erro está na falta de handler para `wl_keyboard`. O debug com `wev` mostraria eventos chegando, mas não sendo processados.