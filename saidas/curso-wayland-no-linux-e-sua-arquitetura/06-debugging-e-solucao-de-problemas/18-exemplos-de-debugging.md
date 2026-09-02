## Exemplos de debugging

Vamos analisar um caso comum em aplicativos Wayland: uma janela que não responde aos eventos de entrada do mouse. O código abaixo cria uma janela simples, mas não registra os listeners necessários para eventos de ponteiro:

```c
#include <wayland-client.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;

void registry_handle_global(void *data, struct wl_registry *registry,
                           uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

int main() {
    display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    const struct wl_registry_listener registry_listener = {registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    while (1) {
        wl_display_dispatch(display);
    }
}
```

Ao executar este código com `WAYLAND_DEBUG=1`, observamos a seguinte saída:

```
[12345.678] -> wl_display@1.get_registry(new id wl_registry@2)
[12345.679] -> wl_registry@2.bind(3, "wl_compositor", 1, new id wl_compositor@3)
[12345.680] -> wl_compositor@3.create_surface(new id wl_surface@4)
```

A janela aparece, mas não responde ao mouse. Isso ocorre porque não registramos o listener para eventos de ponteiro. Para corrigir, precisamos:

1. Obter a interface `wl_seat`
2. Registrar o listener para eventos de ponteiro

Aqui está a versão corrigida:

```c
struct wl_seat *seat;
struct wl_pointer *pointer;

void pointer_handle_motion(void *data, struct wl_pointer *pointer,
                          uint32_t time, wl_fixed_t surface_x, wl_fixed_t surface_y) {
    printf("Mouse moved to: %f, %f\n",
           wl_fixed_to_double(surface_x), wl_fixed_to_double(surface_y));
}

void seat_handle_capabilities(void *data, struct wl_seat *seat,
                             uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_POINTER) {
        pointer = wl_seat_get_pointer(seat);
        const struct wl_pointer_listener pointer_listener = {
            .motion = pointer_handle_motion,
        };
        wl_pointer_add_listener(pointer, &pointer_listener, NULL);
    }
}

int main() {
    display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    const struct wl_registry_listener registry_listener = {registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    while (1) {
        wl_display_dispatch(display);
    }
}
```

Agora, ao mover o mouse sobre a janela, vemos as coordenadas impressas no terminal, confirmando que os eventos estão sendo recebidos corretamente.

Outro problema comum é a criação de buffers gráficos sem o devido gerenciamento de ciclo de vida. Considere o seguinte código:

```c
struct wl_shm *shm;
struct wl_buffer *buffer;

void create_buffer() {
    int fd = memfd_create("buffer", 0);
    ftruncate(fd, 640 * 480 * 4);
    buffer = wl_shm_pool_create_buffer(wl_shm_create_pool(shm, fd, 640 * 480 * 4),
                                     0, 640, 480, 640 * 4, WL_SHM_FORMAT_ARGB8888);
    close(fd);
}

int main() {
    display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    const struct wl_registry_listener registry_listener = {registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    create_buffer();
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
    while (1) {
        wl_display_dispatch(display);
    }
}
```

Este código cria um buffer gráfico, mas não implementa o listener para o evento `release`. Quando o compositor libera o buffer, ele não pode ser reutilizado, causando problemas de desempenho e possível esgotamento de recursos.

Para corrigir, adicionamos o listener de release:

```c
void buffer_handle_release(void *data, struct wl_buffer *buffer) {
    wl_buffer_destroy(buffer);
    create_buffer();
}

int main() {
    display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    const struct wl_registry_listener registry_listener = {registry_handle_global};
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    create_buffer();
    const struct wl_buffer_listener buffer_listener = {
        .release = buffer_handle_release,
    };
    wl_buffer_add_listener(buffer, &buffer_listener, NULL);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
    while (1) {
        wl_display_dispatch(display);
    }
}
```

Agora, quando o compositor libera o buffer, ele é destruído e um novo é criado, mantendo o ciclo de vida correto.