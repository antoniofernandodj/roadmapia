## Segurança no Wayland

O Wayland foi projetado com um modelo de segurança que evita muitos dos problemas históricos do X11. Para entender como isso funciona, vamos analisar um cenário prático: um cliente malicioso tentando capturar input de outro aplicativo.

No X11, qualquer aplicativo pode:
1. Monitorar eventos de teclado globais
2. Redirecionar janelas de outros programas
3. Modificar o conteúdo exibido por outras aplicações

Observe como isso funciona em um exemplo X11 simples (não execute isso!):

```rust
use x11rb::protocol::xproto::*;

// Código malicioso hipotético no X11
let window_ids = connection.list_windows()?; // Lista TODAS as janelas
for window in window_ids {
    connection.grab_keyboard(window, true, GrabMode::Async, GrabMode::Async, 0)?;
}
```

No Wayland, esse mesmo ataque falharia silenciosamente. Vamos ver por quê:

```rust
use wayland_client::{Display, GlobalManager};

let display = Display::connect_to_env()?;
let globals = GlobalManager::new(&display);
display.sync_roundtrip(&mut ()).unwrap();

// Tentativa de acessar o teclado de outra aplicação
if let Some(seat) = globals.instantiate_exact::<wl_seat::WlSeat>(1) {
    seat.get_keyboard(|keyboard| {
        // Isso só captura input para NOSSA própria aplicação
        keyboard.quick_assign(|_, event, _| match event {
            wl_keyboard::Event::Key { .. } => println!("Tecla pressionada"),
            _ => (),
        });
    });
}
```

A diferença crítica está na arquitetura de objetos do Wayland:

1. **Isolamento de Objetos**: Cada objeto (surface, seat, etc.) pertence exclusivamente ao cliente que o criou
2. **Capability-based**: Acesso a recursos requer aprovação explícita do compositor
3. **No Global Keys**: Input é sempre direcionado para a surface com foco

Quando você tenta violar essas regras, o compositor simplesmente ignora a requisição. Veja um erro comum e sua mensagem real:

```rust
// Tentando acessar um buffer de outra aplicação
let other_surface_id = 12345; // ID de outra surface
if let Err(e) = display.get_object::<wl_surface::WlSurface>(other_surface_id) {
    println!("Erro: {}", e); // "Invalid object ID (no such object)"
}
```

O sistema de segurança se baseia em três mecanismos principais:

1. **Gerenciamento de Objetos**:
```rust
// Cada objeto tem um ID único associado à conexão
assert_ne!(surface1.id(), surface2.id()); // IDs são únicos por conexão
```

2. **Eventos de Permissão**:
```rust
xdg_surface.configure(|_, serial| {
    // Só podemos redesenhar depois do Configure
    xdg_surface.ack_configure(serial); // Confirmação explícita
});
```

3. **Sandboxing Automático**:
```rust
// Tentando criar um buffer muito grande (potencial DoS)
if let Err(e) = create_shm_buffer(19200, 10800) { // 8K resolution
    println!("{}", e); // "wl_shm: invalid size (out of bounds)"
}
```

### Exercício Prático

Suponha que você está desenvolvendo um screen recorder para Wayland. Como garantir que:
1. O usuário precise autorizar explicitamente a gravação
2. Outras janelas não sejam capturadas acidentalmente

**Solução comentada**:

```rust
// 1. Solicitar a role de screencast explicitamente
let screencast = globals.instantiate_exact::<zwlr_screencopy_manager_v1::ZwlrScreencopyManagerV1>(1)?;

// 2. Usar o protocolo de seleção de área
let frame = screencast.capture_output_region(
    output,      // Saída específica
    region,      // Área retangular
    overlay_cursor // Opcional
)?;

// 3. Tratar o evento de permissão concedida
frame.quick_assign(|_, event, _| match event {
    zwlr_screencopy_frame_v1::Event::Ready { .. } => {
        // Só recebemos buffers após confirmação
        println!("Captura autorizada");
    },
    _ => (),
});
```