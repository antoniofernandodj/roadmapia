## Debugging de eventos de entrada

Um aplicativo Wayland que não responde a cliques do mouse ou pressionamentos de tecla parece "congelado", mas o problema geralmente está na comunicação dos eventos entre o compositor e o cliente. Vamos diagnosticar um caso real onde teclas digitadas não chegam a um aplicativo simples.

Primeiro, criamos um cliente mínimo que deveria exibir teclas pressionadas:

```c
#include <stdio.h>
#include <wayland-client.h>

static void keyboard_keymap(void *data, struct wl_keyboard *keyboard,
                           uint32_t format, int fd, uint32_t size) {
    printf("Keymap received\n");
}

static void keyboard_enter(void *data, struct wl_keyboard *keyboard,
                          uint32_t serial, struct wl_surface *surface,
                          struct wl_array *keys) {
    printf("Keyboard focus gained\n");
}

static void keyboard_key(void *data, struct wl_keyboard *keyboard,
                        uint32_t serial, uint32_t time, uint32_t key,
                        uint32_t state) {
    printf("Key %s: %d\n", state == WL_KEYBOARD_KEY_STATE_PRESSED ? "press" : "release", key);
}

static const struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
    .enter = keyboard_enter,
    .key = keyboard_key,
};

int main(int argc, char **argv) {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    
    wl_registry_add_listener(registry, &(struct wl_registry_listener){
        .global = [](void *data, wl_registry *reg, uint32_t id, const char *interface, uint32_t version) {
            if (strcmp(interface, "wl_seat") == 0) {
                struct wl_seat *seat = static_cast<wl_seat*>(wl_registry_bind(reg, id, &wl_seat_interface, 1));
                wl_seat_add_listener(seat, &(struct wl_seat_listener){
                    .capabilities = [](void *data, wl_seat *seat, uint32_t caps) {
                        if (caps & WL_SEAT_CAPABILITY_KEYBOARD) {
                            struct wl_keyboard *keyboard = wl_seat_get_keyboard(seat);
                            wl_keyboard_add_listener(keyboard, &keyboard_listener, nullptr);
                        }
                    }
                }, nullptr);
            }
        }
    }, nullptr);

    wl_display_roundtrip(display);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    wl_display_disconnect(display);
    return 0;
}
```

Compile com:
```bash
g++ -std=c++17 keyboard_events.cpp -lwayland-client -o keyboard_events
```

Ao executar com `WAYLAND_DEBUG=1 ./keyboard_events`, você pode não ver nenhum evento de teclado mesmo pressionando teclas. A saída típica mostrará:

```
[1534323.456] wl_display@1.delete_id(3)
[1534323.457] wl_seat@3.capabilities(1)
```

O problema é que o cliente não está processando os eventos de capacidade do seat corretamente. O erro comum aparece quando esquecemos de chamar `wl_display_roundtrip()` após o registro do listener, fazendo com que o compositor envie os eventos de capacidade antes do cliente estar pronto para recebê-los.

Vamos corrigir adicionando a chamada de roundtrip:

```c
wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display); // Nova linha adicionada
```

Agora, ao executar novamente com debug ativado, você verá a sequência completa:

```
[1534324.123] wl_seat@3.capabilities(3)
[1534324.124] wl_keyboard@4.keymap(1, fd 8, 1056)
Keymap received
[1534324.125] wl_keyboard@4.enter(42, wl_surface@2, [])
Keyboard focus gained
[1534324.126] wl_keyboard@4.key(43, 1534324, 28, 1)
Key press: 28
```

Para eventos de ponteiro, o processo é similar. Veja um listener para mouse:

```c
static void pointer_enter(void *data, struct wl_pointer *pointer,
                         uint32_t serial, struct wl_surface *surface,
                         wl_fixed_t sx, wl_fixed_t sy) {
    printf("Pointer entered surface at %f, %f\n",
           wl_fixed_to_double(sx), wl_fixed_to_double(sy));
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter,
    // Outros callbacks: leave, motion, button, axis
};
```

Erro comum: esquecer de verificar `WL_SEAT_CAPABILITY_POINTER` nas capacidades. Isso resulta em silêncio quando o mouse se move, sem mensagens de erro óbvias.

Para debug abrangente, combine ferramentas:

1. `WAYLAND_DEBUG=1` mostra a comunicação bruta
2. `strace -e read,write` revela operações de E/S subjacentes
3. `weston-debug -i pointer` no terminal do compositor mostra eventos processados

Quando um evento não chega, verifique:

1. Se o protocolo foi negociado (`wl_display_roundtrip`)
2. Se as capacidades foram anunciadas (`capabilities`)
3. Se os listeners estão registrados corretamente
4. Se a superfície tem input focus (`wl_surface.ack_configure`)

Exercício: Modifique o exemplo para detectar cliques do mouse e exibir suas coordenadas. Capture a saída de debug quando:
a) O listener está registrado corretamente
b) O listener está ausente

Solução:

```c
// Adicione ao callback de capabilities:
if (caps & WL_SEAT_CAPABILITY_POINTER) {
    struct wl_pointer *pointer = wl_seat_get_pointer(seat);
    wl_pointer_add_listener(pointer, &pointer_listener, NULL);
}

// Implemente os callbacks restantes:
static void pointer_button(void *data, struct wl_pointer *pointer,
                          uint32_t serial, uint32_t time, uint32_t button,
                          uint32_t state) {
    printf("Button %d %s\n", button,
           state == WL_POINTER_BUTTON_STATE_PRESSED ? "pressed" : "released");
}
```

Saída esperada com debug:
```
[1534325.001] wl_pointer@5.button(44, 1534325, 272, 1)
Button 272 pressed
```