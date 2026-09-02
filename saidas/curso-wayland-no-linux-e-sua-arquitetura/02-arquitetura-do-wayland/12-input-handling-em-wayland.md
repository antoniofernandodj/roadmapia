## Input handling em Wayland

Quando você move o mouse ou pressiona uma tecla no Wayland, o caminho do evento é radicalmente diferente do X11. Em vez de um servidor central que distribui eventos para todos os clientes indiscriminadamente, o compositor Wayland age como um controlador de acesso granular. Vamos dissecar o fluxo completo com um cliente que captura eventos de mouse.

Primeiro, precisamos registrar interfaces de input no registry. Este código cria um listener básico para dispositivos de entrada:

```c
#include <wayland-client.h>
#include <stdio.h>

struct wl_seat *seat = NULL;
struct wl_pointer *pointer = NULL;

void pointer_handle_enter(void *data, struct wl_pointer *wl_pointer,
                         uint32_t serial, struct wl_surface *surface,
                         wl_fixed_t sx, wl_fixed_t sy) {
    printf("Mouse entrou na superfície: %dx%d (fixed-point)\n",
           wl_fixed_to_int(sx), wl_fixed_to_int(sy));
}

void pointer_handle_motion(void *data, struct wl_pointer *wl_pointer,
                           uint32_t time, wl_fixed_t sx, wl_fixed_t sy) {
    printf("Mouse moveu para: %dx%d\n",
           wl_fixed_to_int(sx), wl_fixed_to_int(sy));
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_handle_enter,
    .leave = NULL,  // Omissão proposital para demonstrar erro
    .motion = pointer_handle_motion,
    // ... outros callbacks
};

void seat_handle_capabilities(void *data, struct wl_seat *seat,
                             uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_POINTER) {
        pointer = wl_seat_get_pointer(seat);
        wl_pointer_add_listener(pointer, &pointer_listener, NULL);
    }
}

static const struct wl_seat_listener seat_listener = {
    .capabilities = seat_handle_capabilities,
};
```

Ao executar este código incompleto, um erro comum ocorre:
```
wayland: error in client communication (protocol error)
```

O erro acontece porque omitimos o callback `leave` no listener do ponteiro, que é obrigatório no protocolo Wayland. A correção é:

```c
static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_handle_enter,
    .leave = pointer_handle_leave,  // Callback adicionado
    .motion = pointer_handle_motion,
    .button = pointer_handle_button,
    .axis = pointer_handle_axis
};

void pointer_handle_leave(void *data, struct wl_pointer *wl_pointer,
                         uint32_t serial, struct wl_surface *surface) {
    printf("Mouse saiu da superfície\n");
}
```

Agora, o fluxo completo de input funciona assim:
1. O kernel envia eventos de hardware para o compositor via evdev
2. O compositor decide qual cliente recebe o evento baseado no foco
3. O evento é serializado e enviado via socket Unix
4. O cliente desserializa e direciona para o callback apropriado

Coordenadas usam `wl_fixed_t` (ponto fixo 24.8) para precisão subpixel. Convertemos com:
```c
int x = wl_fixed_to_int(sx);  // Converte fixed-point para inteiro
double dx = wl_fixed_to_double(sy);  // Converte para double
```

Para teclado, o fluxo é similar mas usa `wl_keyboard`:

```c
void keyboard_handle_key(void *data, struct wl_keyboard *keyboard,
                        uint32_t serial, uint32_t time, uint32_t key,
                        uint32_t state) {
    const char *action = state == WL_KEYBOARD_KEY_STATE_PRESSED 
                       ? "Pressionada" : "Liberada";
    printf("Tecla %s: %d (scancode)\n", action, key);
}

static const struct wl_keyboard_listener keyboard_listener = {
    .key = keyboard_handle_key,
    // ... outros callbacks obrigatórios
};
```

**Exercício**: Modifique o código para capturar eventos de touchpad, exibindo a posição e ID de cada toque. Use `WL_SEAT_CAPABILITY_TOUCH` e `wl_touch_listener`.

**Solução**:
```c
struct wl_touch *touch = NULL;

void touch_handle_down(void *data, struct wl_touch *wl_touch,
                       uint32_t serial, uint32_t time,
                       struct wl_surface *surface,
                       int32_t id, wl_fixed_t sx, wl_fixed_t sy) {
    printf("Toque %d iniciou em %f,%f\n", id,
           wl_fixed_to_double(sx), wl_fixed_to_double(sy));
}

static const struct wl_touch_listener touch_listener = {
    .down = touch_handle_down,
    .up = touch_handle_up,
    .motion = touch_handle_motion,
    // ... outros callbacks
};

// Na seat_handle_capabilities:
if (capabilities & WL_SEAT_CAPABILITY_TOUCH) {
    touch = wl_seat_get_touch(seat);
    wl_touch_add_listener(touch, &touch_listener, NULL);
}
```