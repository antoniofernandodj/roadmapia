## Multi-seat Básico

Um sistema multi-seat permite que múltiplos usuários interajam simultaneamente com o mesmo computador, cada um com seu próprio teclado, mouse e monitor. No contexto de um compositor Wayland, isso significa gerenciar dispositivos de entrada separados e direcionar seus eventos para as janelas corretas. Vamos implementar o suporte básico para dois seats independentes.

O ponto de partida é a interface `wl_seat`, que já conhecemos do capítulo sobre input básico. Agora precisamos estendê-la para lidar com múltiplas instâncias. Veja como criar um segundo seat:

```rust
use wayland_server::protocol::{wl_seat, wl_keyboard, wl_pointer};
use wayland_server::Resource;

struct Seat {
    keyboard: Option<wl_keyboard::WlKeyboard>,
    pointer: Option<wl_pointer::WlPointer>,
    // Outros dispositivos como touch podem ser adicionados aqui
}

impl Seat {
    fn new() -> Self {
        Seat {
            keyboard: None,
            pointer: None,
        }
    }
}

struct MultiSeatCompositor {
    seats: Vec<Seat>,
    next_seat_id: u32,
}

impl MultiSeatCompositor {
    pub fn add_seat(&mut self, client: &wayland_server::Client) {
        let seat = self.next_seat_id;
        self.next_seat_id += 1;
        
        let seat_resource = client.create_resource::<wl_seat::WlSeat>(
            seat,
            wl_seat::WlSeat::interface(),
            wl_seat::VERSION,
            None
        ).expect("Failed to create seat resource");

        seat_resource.quick_assign(|seat, request, _| {
            match request {
                wl_seat::Request::GetKeyboard { id } => {
                    let keyboard = seat.client().create_resource(
                        id,
                        wl_keyboard::WlKeyboard::interface(),
                        wl_keyboard::VERSION,
                        None
                    ).unwrap();
                    // Armazene o keyboard no seat correspondente
                },
                wl_seat::Request::GetPointer { id } => {
                    // Similar para o pointer
                },
                _ => {}
            }
        });

        seat_resource.name(format!("seat{}", seat));
        seat_resource.capabilities(wl_seat::Capability::Keyboard | wl_seat::Capability::Pointer);
        self.seats.push(Seat::new());
    }
}
```

Quando um cliente solicita os dispositivos de um seat, precisamos garantir que os eventos sejam roteados corretamente. Veja como enviar um evento de teclado para o seat específico:

```rust
fn send_key_event(
    seat: &Seat,
    key: u32,
    state: wl_keyboard::KeyState,
    time: u32
) {
    if let Some(ref keyboard) = seat.keyboard {
        keyboard.key(
            time,
            key,
            state,
            wl_keyboard::EventKey::new()
        );
    }
}
```

Um erro comum é esquecer de atualizar o foco da janela quando o usuário muda de seat. Isso causa eventos sendo enviados para a janela errada. A correção envolve rastrear o foco por seat:

```rust
struct SurfaceFocus {
    seat_id: u32,
    surface: Option<wl_surface::WlSurface>,
}

fn handle_pointer_enter(
    compositor: &mut MultiSeatCompositor,
    seat_id: u32,
    surface: &wl_surface::WlSurface,
    // ... outros parâmetros
) {
    // Encontre o seat correspondente
    if let Some(seat) = compositor.seats.get_mut(seat_id as usize) {
        if let Some(pointer) = &seat.pointer {
            pointer.enter(
                serial,
                surface,
                // coordenadas...
            );
            // Atualize o foco
            compositor.focus[seat_id as usize] = Some(surface.clone());
        }
    }
}
```

Para testar o setup multi-seat, podemos simular dois conjuntos de dispositivos. Execute este exemplo com dois terminais abertos, cada um rodando um cliente Wayland:

```rust
fn main() {
    let mut compositor = MultiSeatCompositor::new();
    
    // Seat 0 - Dispositivos padrão
    compositor.add_seat(&client1);
    
    // Seat 1 - Segundo conjunto de dispositivos
    compositor.add_seat(&client2);

    // Envie eventos de teclado para seat 0
    compositor.send_key_event(0, 30, wl_keyboard::KeyState::Pressed, 1000);
    
    // Envie eventos de mouse para seat 1
    compositor.send_pointer_event(1, 100, 100, wl_pointer::ButtonState::Pressed);
}
```

A saída esperada mostra que cada cliente recebe apenas os eventos do seu seat designado:

```
Client 1: Key press event received (keycode 30)
Client 2: Pointer motion to (100, 100)
```

**Exercício**: Modifique o código para suportar desconexão dinâmica de seats. Quando um dispositivo é removido (como um teclado USB desconectado), o seat correspondente deve emitir o evento `wl_seat.capabilities` atualizado e os clientes devem ser notificados.

**Solução**:

```rust
impl MultiSeatCompositor {
    pub fn remove_seat_device(&mut self, seat_id: u32, device_type: DeviceType) {
        if let Some(seat) = self.seats.get_mut(seat_id as usize) {
            match device_type {
                DeviceType::Keyboard => {
                    seat.keyboard = None;
                },
                DeviceType::Pointer => {
                    seat.pointer = None;
                },
            }
            
            // Atualize capacidades
            let mut capabilities = wl_seat::Capability::empty();
            if seat.keyboard.is_some() {
                capabilities |= wl_seat::Capability::Keyboard;
            }
            if seat.pointer.is_some() {
                capabilities |= wl_seat::Capability::Pointer;
            }
            
            // Envie evento para todos os clients deste seat
            if let Some(seat_resource) = self.get_seat_resource(seat_id) {
                seat_resource.capabilities(capabilities);
            }
        }
    }
}
```