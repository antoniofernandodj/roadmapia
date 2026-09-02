## Implementando callbacks em Wayland

Em Wayland, a comunicação entre o cliente e o compositor é baseada em eventos e callbacks. Callbacks são funções que são chamadas automaticamente quando um evento específico ocorre, como uma tecla pressionada ou o movimento do mouse. Vamos explorar como implementar callbacks em um cliente Wayland.

### Estrutura de um callback

Um callback em Wayland é uma função que segue uma assinatura específica, definida pelo protocolo. Essas funções são registradas em listeners, que são estruturas que contêm ponteiros para as funções de callback. Quando um evento ocorre, o compositor chama a função correspondente no listener.

Vamos criar um exemplo simples que captura eventos de teclado e exibe uma mensagem quando uma tecla é pressionada.

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

static void keyboard_keymap(void *data, struct wl_keyboard *keyboard,
                           uint32_t format, int fd, uint32_t size) {
    // Ignorado neste exemplo
}

static void keyboard_enter(void *data, struct wl_keyboard *keyboard,
                          uint32_t serial, struct wl_surface *surface,
                          struct wl_array *keys) {
    printf("Teclado entrou na superfície\n");
}

static void keyboard_leave(void *data, struct wl_keyboard *keyboard,
                          uint32_t serial, struct wl_surface *surface) {
    printf("Teclado saiu da superfície\n");
}

static void keyboard_key(void *data, struct wl_keyboard *keyboard,
                         uint32_t serial, uint32_t time, uint32_t key,
                         uint32_t state) {
    if (state == WL_KEYBOARD_KEY_STATE_PRESSED) {
        printf("Tecla pressionada: %d\n", key);
    }
}

static void keyboard_modifiers(void *data, struct wl_keyboard *keyboard,
                               uint32_t serial, uint32_t mods_depressed,
                               uint32_t mods_latched, uint32_t mods_locked,
                               uint32_t group) {
    // Ignorado neste exemplo
}

static const struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
    .enter = keyboard_enter,
    .leave = keyboard_leave,
    .key = keyboard_key,
    .modifiers = keyboard_modifiers,
};

int main(int argc, char **argv) {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_compositor *compositor = NULL;
    struct wl_seat *seat = NULL;

    static const struct wl_registry_listener registry_listener = {
        .global = [](void *data, struct wl_registry *registry, uint32_t id,
                     const char *interface, uint32_t version) {
            if (strcmp(interface, "wl_compositor") == 0) {
                compositor = (struct wl_compositor *)wl_registry_bind(
                    registry, id, &wl_compositor_interface, 1);
            } else if (strcmp(interface, "wl_seat") == 0) {
                seat = (struct wl_seat *)wl_registry_bind(
                    registry, id, &wl_seat_interface, 1);
            }
        },
        .global_remove = [](void *data, struct wl_registry *registry, uint32_t id) {
            // Ignorado neste exemplo
        },
    };

    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !seat) {
        fprintf(stderr, "Falha ao obter compositor ou seat\n");
        return 1;
    }

    struct wl_keyboard *keyboard = wl_seat_get_keyboard(seat);
    wl_keyboard_add_listener(keyboard, &keyboard_listener, NULL);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    wl_keyboard_release(keyboard);
    wl_seat_release(seat);
    wl_compositor_release(compositor);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);

    return 0;
}
```

Neste exemplo, definimos um listener para o teclado (`wl_keyboard_listener`) que contém callbacks para diferentes eventos de teclado. O callback `keyboard_key` é chamado quando uma tecla é pressionada ou liberada, e ele exibe uma mensagem no console.

### Erro comum: esquecer de registrar o listener

Um erro comum ao trabalhar com callbacks é esquecer de registrar o listener. Se você não chamar `wl_keyboard_add_listener`, o compositor não saberá quais funções chamar quando os eventos ocorrerem. Isso resulta em um comportamento silencioso, onde os eventos são ignorados.

```c
// CORRETO:
wl_keyboard_add_listener(keyboard, &keyboard_listener, NULL);

// ERRADO:
// Se você esquecer de registrar o listener, os eventos não serão processados.
```

### Comparação com outros sistemas de eventos

Se você já trabalhou com outros sistemas de eventos, como X11 ou Windows API, notará que Wayland segue um padrão semelhante. No entanto, em Wayland, os callbacks são mais explícitos e menos dependentes de máscaras de eventos ou loops de eventos complexos. Isso torna o código mais simples e direto.

### Exercício

Modifique o exemplo anterior para capturar eventos do mouse (`wl_pointer`) e exibir uma mensagem quando o botão esquerdo do mouse é pressionado. Use o seguinte esqueleto para começar:

```c
static void pointer_enter(void *data, struct wl_pointer *pointer,
                          uint32_t serial, struct wl_surface *surface,
                          wl_fixed_t sx, wl_fixed_t sy) {
    printf("Mouse entrou na superfície\n");
}

static void pointer_leave(void *data, struct wl_pointer *pointer,
                          uint32_t serial, struct wl_surface *surface) {
    printf("Mouse saiu da superfície\n");
}

static void pointer_button(void *data, struct wl_pointer *pointer,
                           uint32_t serial, uint32_t time, uint32_t button,
                           uint32_t state) {
    if (state == WL_POINTER_BUTTON_STATE_PRESSED && button == BTN_LEFT) {
        printf("Botão esquerdo do mouse pressionado\n");
    }
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter,
    .leave = pointer_leave,
    .button = pointer_button,
    // Outros callbacks podem ser ignorados neste exemplo
};

int main(int argc, char **argv) {
    // Código anterior...

    struct wl_pointer *pointer = wl_seat_get_pointer(seat);
    wl_pointer_add_listener(pointer, &pointer_listener, NULL);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    // Limpeza...
}
```

### Solução comentada

No exercício, você deve registrar um listener para o ponteiro (`wl_pointer_listener`) e implementar o callback `pointer_button` para capturar eventos de clique do mouse. O botão esquerdo é identificado por `BTN_LEFT`. Certifique-se de registrar o listener com `wl_pointer_add_listener` para que os eventos sejam processados corretamente.

```c
static void pointer_button(void *data, struct wl_pointer *pointer,
                           uint32_t serial, uint32_t time, uint32_t button,
                           uint32_t state) {
    if (state == WL_POINTER_BUTTON_STATE_PRESSED && button == BTN_LEFT) {
        printf("Botão esquerdo do mouse pressionado\n");
    }
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter,
    .leave = pointer_leave,
    .button = pointer_button,
};

int main(int argc, char **argv) {
    // Código anterior...

    struct wl_pointer *pointer = wl_seat_get_pointer(seat);
    wl_pointer_add_listener(pointer, &pointer_listener, NULL);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    // Limpeza...
}
```