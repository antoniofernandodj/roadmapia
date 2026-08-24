## Input Básico

O tratamento de entrada (input) em um compositor Wayland envolve a captura de eventos de hardware — como pressionamentos de teclas e movimentos do mouse — e o envio desses eventos para os clients apropriados. Esse processo começa com a configuração de um `wl_seat`, que representa um conjunto de dispositivos de entrada (teclado, mouse, touchpad, etc.). Cada `wl_seat` pode ter múltiplos dispositivos associados, e o compositor é responsável por gerenciar esses dispositivos e distribuir seus eventos.

Vamos começar criando uma estrutura básica para gerenciar o `wl_seat`:

```rust
struct Seat {
    keyboard: Option<wl_keyboard::WlKeyboard>,
    pointer: Option<wl_pointer::WlPointer>,
    // Outros dispositivos podem ser adicionados aqui
}
```

Aqui, `wl_keyboard` e `wl_pointer` são interfaces específicas para teclado e mouse, respectivamente. Essas interfaces são anunciadas pelo compositor quando um client solicita acesso a um dispositivo de entrada.

### Configurando o `wl_seat`

Para configurar o `wl_seat`, precisamos anunciar sua disponibilidade aos clients. Isso é feito durante o handshake inicial, onde o compositor lista seus objetos globais:

```rust
fn announce_globals(display: &wl_display::WlDisplay) {
    let seat = display.create_global::<wl_seat::WlSeat>(1, wl_seat::WlSeat::interface());
    seat.set_capabilities(wl_seat::Capability::Keyboard | wl_seat::Capability::Pointer);
}
```

Neste exemplo, `wl_seat::Capability` define quais dispositivos estão disponíveis. O número `1` é a versão do protocolo, que deve ser compatível com o cliente.

### Recebendo Eventos de Input

Uma vez configurado o `wl_seat`, o compositor começa a receber eventos de hardware. Esses eventos são então encaminhados para os clients. Vamos implementar a captura de eventos de teclado:

```rust
impl Seat {
    fn handle_keyboard_event(&mut self, event: KeyboardEvent) {
        if let Some(keyboard) = &self.keyboard {
            keyboard.key(event.time, event.key, event.state);
        }
    }
}

struct KeyboardEvent {
    time: u32,
    key: u32,
    state: wl_keyboard::KeyState,
}
```

Aqui, `keyboard.key` envia o evento de tecla pressionada ou liberada para o client. `event.time` é o tempo do evento, `event.key` é o código da tecla, e `event.state` indica se a tecla foi pressionada (`KeyState::Pressed`) ou liberada (`KeyState::Released`).

### Erro Comum: Falha ao Enviar Eventos

Um erro comum é tentar enviar eventos para um client que não solicitou acesso ao dispositivo. Isso resulta em uma mensagem de erro no client:

```plaintext
error: received event for unbound keyboard
```

Para evitar isso, sempre verifique se o dispositivo está associado a um client antes de enviar eventos:

```rust
fn handle_keyboard_event(&mut self, event: KeyboardEvent) {
    if let Some(keyboard) = &self.keyboard {
        if keyboard.is_bound() {
            keyboard.key(event.time, event.key, event.state);
        }
    }
}
```

### Exercício: Implementando Eventos de Mouse

Agora que você entende como enviar eventos de teclado, implemente o envio de eventos de mouse. A estrutura `MouseEvent` deve incluir as coordenadas do cursor (`x`, `y`) e o estado do botão (`state`). Use o método `pointer.motion` para enviar eventos de movimento e `pointer.button` para eventos de clique.

```rust
struct MouseEvent {
    time: u32,
    x: f64,
    y: f64,
    button: u32,
    state: wl_pointer::ButtonState,
}

impl Seat {
    fn handle_pointer_event(&mut self, event: MouseEvent) {
        // Implemente aqui
    }
}
```

### Solução

```rust
impl Seat {
    fn handle_pointer_event(&mut self, event: MouseEvent) {
        if let Some(pointer) = &self.pointer {
            if pointer.is_bound() {
                pointer.motion(event.time, event.x, event.y);
                pointer.button(event.time, event.button, event.state);
            }
        }
    }
}
```

Nesta solução, `pointer.motion` envia as coordenadas atualizadas do cursor, e `pointer.button` envia o estado do botão do mouse. Sempre verificamos se o `pointer` está associado a um client antes de enviar os eventos.