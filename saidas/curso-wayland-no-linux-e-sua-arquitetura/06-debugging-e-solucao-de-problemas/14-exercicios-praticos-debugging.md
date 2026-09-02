## Exercícios práticos: debugging

### Debugging de uma janela que congela ao redimensionar

Um problema comum em aplicativos Wayland é o congelamento ao redimensionar janelas. Isso geralmente ocorre devido a falhas no gerenciamento de buffers ou na sincronização entre o cliente e o compositor. Vamos depurar um exemplo onde isso acontece.

Primeiro, vamos criar um aplicativo simples que congela ao redimensionar:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

void create_window() {
    surface = wl_compositor_create_surface(compositor);
    // Falta criar e anexar buffers
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_registry_listener registry_listener = {&registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_window();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```

Ao executar este código, a janela congela ao tentar redimensionar. Para depurar, vamos usar `WAYLAND_DEBUG=1`:

```bash
WAYLAND_DEBUG=1 ./a.out
```

A saída mostrará que o cliente não está criando e anexando buffers corretamente durante o redimensionamento. Para corrigir, precisamos implementar o gerenciamento de buffers:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wl_buffer *buffer;

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

void create_buffer(int width, int height) {
    // Implementar a criação de buffer aqui
}

void create_window() {
    surface = wl_compositor_create_surface(compositor);
    create_buffer(640, 480);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_registry_listener registry_listener = {&registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_window();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```

### Debugging de eventos de entrada não recebidos

Outro problema comum é a falta de eventos de entrada, como teclado e mouse. Vamos depurar um exemplo onde isso acontece.

Primeiro, vamos criar um aplicativo que não recebe eventos de entrada:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

void create_window() {
    surface = wl_compositor_create_surface(compositor);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_registry_listener registry_listener = {&registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_window();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```

Agora, vamos usar `WAYLAND_DEBUG=1` para depurar:

```bash
WAYLAND_DEBUG=1 ./a.out
```

A saída mostrará que o cliente não está registrando listeners para eventos de entrada. Para corrigir, precisamos registrar listeners para `wl_keyboard` e `wl_pointer`:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wl_seat *seat;
struct wl_keyboard *keyboard;
struct wl_pointer *pointer;

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    } else if (strcmp(interface, "wl_seat") == 0) {
        seat = wl_registry_bind(registry, name, &wl_seat_interface, 1);
        wl_seat_add_listener(seat, &seat_listener, NULL);
    }
}

void seat_capabilities(void *data, struct wl_seat *seat, uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_KEYBOARD) {
        keyboard = wl_seat_get_keyboard(seat);
        wl_keyboard_add_listener(keyboard, &keyboard_listener, NULL);
    }
    if (capabilities & WL_SEAT_CAPABILITY_POINTER) {
        pointer = wl_seat_get_pointer(seat);
        wl_pointer_add_listener(pointer, &pointer_listener, NULL);
    }
}

struct wl_seat_listener seat_listener = {
    seat_capabilities
};

void create_window() {
    surface = wl_compositor_create_surface(compositor);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_registry_listener registry_listener = {&registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_window();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```

### Exercício: Debugging de uma aplicação que não cria janelas

Crie um aplicativo Wayland que não cria janelas e use `WAYLAND_DEBUG=1` e `strace` para identificar o problema. Depois, corrija o código e verifique se a janela é criada corretamente.

**Solução:**

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

void create_window() {
    surface = wl_compositor_create_surface(compositor);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_registry_listener registry_listener = {&registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_window();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```

Usando `WAYLAND_DEBUG=1`, você verá que o cliente não está anexando buffers à superfície. Para corrigir, implemente a criação e anexação de buffers:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wl_buffer *buffer;

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

void create_buffer(int width, int height) {
    // Implementar a criação de buffer aqui
}

void create_window() {
    surface = wl_compositor_create_surface(compositor);
    create_buffer(640, 480);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_registry_listener registry_listener = {&registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_window();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```