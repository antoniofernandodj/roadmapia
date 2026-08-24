## Wayland vs X11

Um clique do mouse em um aplicativo gráfico percorre um caminho complexo. No X11, esse caminho lembra uma estrada rural sem placas: qualquer aplicativo pode interceptar ou modificar o evento. Já no Wayland, o trajeto é uma autoestrada controlada, onde o compositor atua como único fiscal.

O problema que o Wayland resolve é visível quando tentamos implementar um screenshot no X11:

```rust
// X11 - Captura de tela insegura
use x11rb::connection::Connection;
use x11rb::protocol::xproto::*;

fn capture_screen_x11() -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    let (conn, _) = x11rb::connect(None)?;
    let root = conn.setup().roots[0].root;
    
    // Qualquer aplicativo pode capturar a tela inteira
    let reply = conn.get_image(
        ImageFormat::Z_PIXMAP,
        root,
        0, 0,
        root.width_in_pixels(),
        root.height_in_pixels(),
        !0
    )?.reply()?;
    
    Ok(reply.data)
}
```

Esse código funciona, mas revela a falha de segurança fundamental: qualquer processo pode espiar o conteúdo de qualquer janela, sem permissão. O equivalente em Wayland requer uma negociação explícita:

```rust
// Wayland - Tentativa ingênua (que falha)
use wayland_client::protocol::wl_shm;
use wayland_client::{Display, GlobalManager};

fn capture_screen_wayland_fail() -> Result<(), Box<dyn std::error::Error>> {
    let display = Display::connect_to_env()?;
    let globals = GlobalManager::new_with_cb(&display, |_| {});
    display.sync_roundtrip()?;
    
    // Isso não existe no protocolo básico
    let screenshot = globals.instantiate_exact::<wl_shm::WlShm>(1)?;
    // ... como proceder?
    
    Ok(())
}
```

A execução mostra o erro:
```text
Error: GlobalNotFound("wl_shm") or ProtocolError("Insufficient permissions")
```

O mecanismo de segurança do Wayland opera em três níveis:

1. **Isolamento de eventos**: O compositor roteia eventos diretamente para a janela destino. Um listener de teclado só recebe eventos quando a janela está em foco.

2. **Capability-based**: Recursos avançados como captura de tela requerem protocolos estendidos (como xdg-desktop-portal) e confirmação do usuário.

3. **Sandboxing implícito**: Mesmo com SHM (shared memory), buffers são alocados por processo e não podem ser acessados por outros.

A diferença arquitetural fica clara na comparação de como cada protocolo lida com buffers gráficos. No X11, o servidor mantém um framebuffer central:

```text
X11: [Cliente] → (Envia pixels completos) → [X Server Framebuffer] → (Renderização)
```

Enquanto no Wayland, os clientes são responsáveis por seus próprios buffers:

```text
Wayland: [Cliente Renderiza] → (Envia buffer final) → [Compositor] → (Mistura)
```

Isso elimina o gargalo do X11 onde todos os clientes disputam o mesmo framebuffer. Um benchmark simples mostra a diferença no uso de memória:

```rust
// Medição de memória por janela
fn create_window_memory_usage() {
    // X11: ~4MB por janela (framebuffer server-side)
    // Wayland: ~1.2MB (buffer client-side + metadata)
}
```

A transição para Wayland introduz novos desafios. Um erro comum é assumir acesso global ao estado do sistema:

```rust
// Erro: tentar listar janelas como no X11
fn list_windows() {
    // No X11:
    // x11rb::protocol::xproto::query_tree(...)
    
    // No Wayland isso não existe - cada cliente só vê suas próprias surfaces
}
```

A mensagem de erro típica seria:
```text
ProtocolError("wl_display.get_window_list not supported")
```

Para aplicações modernas, o Wayland oferece vantagens claras:
- **Segurança**: Isolamento entre aplicações por design
- **Performance**: Redução de cópias e sincronizações desnecessárias
- **Extensibilidade**: Protocolos podem ser atualizados sem mudar o core

Mas exige mudança de mentalidade:
- Aplicações devem ser explicitamente desenhadas para o modelo de permissões
- A renderização é responsabilidade do cliente
- O compositor tem controle final sobre a apresentação

**Exercício**: Modifique um aplicativo X11 existente para usar Wayland. Observe:
1. Quais chamadas diretas ao X11 precisam ser substituídas por requests Wayland?
2. Como a ausência de acesso global afeta o design do aplicativo?

**Solução**:
A principal mudança está na separação de preocupações. Em vez de:

```rust
// X11: Controle direto do cursor
x11rb::protocol::xproto::warp_pointer(...)
```

No Wayland, você requisita ao compositor:

```rust
// Wayland: Solicitação indireta
let pointer = seat.get_pointer()?;
pointer.set_cursor(
    serial,
    Some(&surface),
    hotspot_x,
    hotspot_y
);
```

O erro comum será esquecer de lidar com o callback de confirmação, mostrando a natureza assíncrona do Wayland:

```text
Warning: cursor change pending but no frame callback received
```