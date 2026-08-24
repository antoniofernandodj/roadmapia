## Input Básico

O protocolo Wayland trata dispositivos de entrada através do objeto `wl_seat`, que representa um conjunto de dispositivos físicos (teclado, mouse, touch) conectados ao sistema. Vamos começar capturando eventos simples de teclado e mouse em uma aplicação Wayland básica.

### Configurando o Seat

Primeiro, precisamos obter a interface `wl_seat` do registry global. Supondo que já temos uma conexão estabelecida (como mostrado nos trechos anteriores):

```rust
let seat = registry
    .bind::<WlSeat>(seat_id, seat_version)
    .expect("Falha ao criar interface wl_seat");
```

O compositor pode anunciar múltiplos seats (em sistemas multi-usuário), mas normalmente há apenas um. A versão do protocolo (aqui como `seat_version`) determina quais eventos estão disponíveis - usaremos a versão 5 que inclui eventos básicos.

### Capturando Eventos do Teclado

Para receber eventos de teclado, criamos um objeto `wl_keyboard`:

```rust
let keyboard = seat.get_keyboard();
keyboard.quick_assign(|keyboard, event, _| {
    match event {
        wl_keyboard::Event::Key { key, state, .. } => {
            let estado = match state {
                wl_keyboard::KeyState::Pressed => "Pressionada",
                wl_keyboard::KeyState::Released => "Liberada",
            };
            println!("Tecla {} {}", key, estado);
        },
        _ => {}
    }
});
```

Ao executar, pressionando 'A' no teclado, você verá:
```
Tecla 30 Pressionada
Tecla 30 Liberada
```

Os códigos das teclas seguem a convenção Linux/input-event-codes.h. Para mapeá-los para caracteres, precisamos do evento `keymap`, que fornece o layout atual:

```rust
wl_keyboard::Event::Keymap { format, fd, size } => {
    let keymap = unsafe { 
        MmapOptions::new().map(&fd).expect("Falha ao mapear keymap") 
    };
    // Processar keymap XKB (tópico avançado)
},
```

### Movimento do Mouse

Para o mouse, usamos `wl_pointer`:

```rust
let pointer = seat.get_pointer();
pointer.quick_assign(|pointer, event, _| {
    match event {
        wl_pointer::Event::Motion { surface_x, surface_y, .. } => {
            println!("Cursor em: {:.1}x{:.1}", surface_x, surface_y);
        },
        wl_pointer::Event::Button { button, state, .. } => {
            let action = match state {
                wl_pointer::ButtonState::Pressed => "Pressionado",
                wl_pointer::ButtonState::Released => "Liberado",
            };
            println!("Botão {} {}", button, action);
        },
        _ => {}
    }
});
```

Um erro comum é esquecer de anexar a surface ao pointer:

```rust
// Necessário para receber eventos do mouse
pointer.set_surface(Some(&surface));
```

Sem isso, os eventos de movimento não serão entregues, mesmo que o cursor esteja visível na janela.

### Exercício Prático

Implemente um contador simples que:
1. Incrementa quando a tecla 'Up' (código 111) é pressionada
2. Decrementa quando 'Down' (código 116) é pressionada
3. Exibe o valor atual quando o botão esquerdo do mouse (código 272) é clicado

Solução comentada:

```rust
let mut contador = 0;

let keyboard = seat.get_keyboard();
keyboard.quick_assign(move |_, event, _| {
    if let wl_keyboard::Event::Key { key, state, .. } = event {
        if state == wl_keyboard::KeyState::Pressed {
            match key {
                111 => contador += 1,  // Up
                116 => contador -= 1,  // Down
                _ => {}
            }
        }
    }
});

let pointer = seat.get_pointer();
pointer.quick_assign(move |_, event, _| {
    if let wl_pointer::Event::Button { button, state, .. } = event {
        if button == 272 && state == wl_pointer::ButtonState::Pressed {
            println!("Contador atual: {}", contador);
        }
    }
});
```