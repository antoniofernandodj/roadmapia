## Clipboard Básico

O clipboard (área de transferência) é um recurso essencial para qualquer aplicação gráfica, permitindo copiar e colar dados entre aplicações. No Wayland, essa funcionalidade é implementada através do protocolo `wl_data_device`, que opera de forma assíncrona e requer tratamento cuidadoso dos callbacks.

### Implementando o Clipboard

Começamos obtendo o `wl_data_device` a partir do seat, que já deve estar configurado para receber eventos de entrada:

```rust
let seat: wl_seat::WlSeat = /* obtido do registry */;
let data_device_manager: zwlr_data_control_manager_v1::ZwlrDataControlManagerV1 = /* obtido do registry */;

let data_device = data_device_manager.get_data_device(&seat);
```

Agora precisamos implementar os handlers para os eventos do clipboard. O Wayland usa um modelo onde o cliente "oferece" dados quando copia e "recebe" quando cola:

```rust
struct ClipboardHandler;

impl Dispatch<wl_data_device::WlDataDevice, ()> for ClipboardHandler {
    fn event(
        state: &mut (),
        data_device: &wl_data_device::WlDataDevice,
        event: wl_data_device::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<()>,
    ) {
        match event {
            wl_data_device::Event::DataOffer { id } => {
                println!("Novo offer recebido: {:?}", id);
                // Aqui configuraríamos os handlers para o offer
            }
            wl_data_device::Event::Selection { id } => {
                if let Some(id) = id {
                    println!("Clipboard atualizado com novo offer: {:?}", id);
                } else {
                    println!("Clipboard limpo");
                }
            }
            _ => (),
        }
    }
}
```

### Copiando Texto

Para colocar texto no clipboard, criamos um `wl_data_source` e oferecemos os formatos suportados:

```rust
let source = data_device_manager.create_data_source();
source.offer("text/plain");
source.offer("text/plain;charset=utf-8");

let clipboard_text = "Texto para o clipboard".to_string();
source.quick_assign(move |source, event, _| {
    match event {
        wl_data_source::Event::Send { mime_type, fd } => {
            if mime_type == "text/plain" || mime_type == "text/plain;charset=utf-8" {
                let _ = std::io::Write::write_all(&mut unsafe { std::fs::File::from_raw_fd(fd) }, clipboard_text.as_bytes());
            }
        }
        _ => (),
    }
});

data_device.set_selection(Some(&source), serial);
```

### Colando Texto

Para ler do clipboard, verificamos os offers disponíveis e solicitamos os dados:

```rust
impl Dispatch<wl_data_offer::WlDataOffer, ()> for ClipboardHandler {
    fn event(
        state: &mut (),
        offer: &wl_data_offer::WlDataOffer,
        event: wl_data_offer::Event,
        _: &(),
        conn: &Connection,
        qh: &QueueHandle<()>,
    ) {
        match event {
            wl_data_offer::Event::Offer { mime_type } => {
                println!("MIME type oferecido: {}", mime_type);
                if mime_type == "text/plain" {
                    let pipe = pipe::pipe().unwrap();
                    offer.receive(mime_type, pipe.write.as_raw_fd());
                    
                    // Leitura assíncrona dos dados
                    std::thread::spawn(move || {
                        let mut data = String::new();
                        std::io::Read::read_to_string(&mut pipe.read, &mut data).unwrap();
                        println!("Dados colados: {}", data);
                    });
                }
            }
            _ => (),
        }
    }
}
```

### Erro Comum: Serial Inválido

Um erro frequente é usar um serial inválido ao chamar `set_selection`. O serial deve vir de um evento recente de entrada:

```rust
// ERRADO: serial arbitrário
data_device.set_selection(Some(&source), 123);

// CORRETO: serial de um evento real
let mut last_serial = 0;
keyboard.quick_assign(move |_, event, _| {
    if let wl_keyboard::Event::Key { serial, .. } = event {
        last_serial = serial;
    }
});
data_device.set_selection(Some(&source), last_serial);
```

A mensagem de erro típica seria:
```
[wayland-client] Error in Wayland communication: Protocol error: invalid serial
```

### Exercício: Clipboard Bidirecional

Implemente um programa que:
1. Copia um texto para o clipboard ao pressionar Ctrl+C
2. Imprime o conteúdo do clipboard ao pressionar Ctrl+V

Solução comentada:

```rust
// Estrutura para armazenar estado
struct AppState {
    last_serial: u32,
    clipboard_text: String,
}

// Handler de teclado modificado
keyboard.quick_assign(move |_, event, state: &mut AppState| {
    if let wl_keyboard::Event::Key { serial, key, state: key_state, .. } = event {
        state.last_serial = serial;
        
        if key_state == wl_keyboard::KeyState::Pressed {
            if key == KEY_C && modifiers.ctrl {
                // Ctrl+C pressionado - copiar
                let source = data_device_manager.create_data_source();
                source.offer("text/plain");
                source.quick_assign(clone!(state => move |_, event, _| {
                    if let wl_data_source::Event::Send { mime_type, fd } = event {
                        let _ = std::io::Write::write_all(
                            &mut unsafe { std::fs::File::from_raw_fd(fd) },
                            state.clipboard_text.as_bytes()
                        );
                    }
                }));
                data_device.set_selection(Some(&source), serial);
            } else if key == KEY_V && modifiers.ctrl {
                // Ctrl+V pressionado - colar
                if let Some(offer) = current_selection {
                    let pipe = pipe::pipe().unwrap();
                    offer.receive("text/plain", pipe.write.as_raw_fd());
                    std::thread::spawn(move || {
                        let mut data = String::new();
                        std::io::Read::read_to_string(&mut pipe.read, &mut data).unwrap();
                        println!("Texto colado: {}", data);
                    });
                }
            }
        }
    }
});
```