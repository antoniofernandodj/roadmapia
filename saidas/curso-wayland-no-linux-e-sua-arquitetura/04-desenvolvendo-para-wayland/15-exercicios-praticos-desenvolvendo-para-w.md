## Exercícios práticos: desenvolvendo para Wayland

Vamos implementar um aplicativo Wayland minimalista que desenha um quadrado colorido na tela e reage a cliques do mouse. O código completo abaixo demonstra os principais conceitos na prática:

```c
#include <wayland-client.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct wl_shell *shell = NULL;
struct wl_surface *surface = NULL;
struct wl_shell_surface *shell_surface = NULL;
struct wl_shm *shm = NULL;

void draw_color(uint32_t *pixels, int width, int height, uint32_t color) {
    for (int i = 0; i < width * height; i++) {
        pixels[i] = color;
    }
}

static void shell_surface_ping(void *data,
                              struct wl_shell_surface *shell_surface,
                              uint32_t serial) {
    wl_shell_surface_pong(shell_surface, serial);
}

static const struct wl_shell_surface_listener shell_surface_listener = {
    .ping = shell_surface_ping,
};

static void pointer_handle_enter(void *data, struct wl_pointer *pointer,
                                uint32_t serial, struct wl_surface *surface,
                                wl_fixed_t sx, wl_fixed_t sy) {}

static void pointer_handle_leave(void *data, struct wl_pointer *pointer,
                                 uint32_t serial, struct wl_surface *surface) {}

static void pointer_handle_motion(void *data, struct wl_pointer *pointer,
                                 uint32_t time, wl_fixed_t sx, wl_fixed_t sy) {}

static void pointer_handle_button(void *data, struct wl_pointer *pointer,
                                 uint32_t serial, uint32_t time,
                                 uint32_t button, uint32_t state) {
    if (button == BTN_LEFT && state == WL_POINTER_BUTTON_STATE_PRESSED) {
        printf("Mouse clicked at %d\n", time);
    }
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_handle_enter,
    .leave = pointer_handle_leave,
    .motion = pointer_handle_motion,
    .button = pointer_handle_button,
};

static void seat_handle_capabilities(void *data, struct wl_seat *seat,
                                    uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_POINTER) {
        struct wl_pointer *pointer = wl_seat_get_pointer(seat);
        wl_pointer_add_listener(pointer, &pointer_listener, NULL);
    }
}

static const struct wl_seat_listener seat_listener = {
    .capabilities = seat_handle_capabilities,
};

static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t name, const char *interface,
                                  uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name,
                                     &wl_compositor_interface, 1);
    } else if (strcmp(interface, "wl_shell") == 0) {
        shell = wl_registry_bind(registry, name, &wl_shell_interface, 1);
    } else if (strcmp(interface, "wl_shm") == 0) {
        shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
    } else if (strcmp(interface, "wl_seat") == 0) {
        struct wl_seat *seat = wl_registry_bind(registry, name,
                                               &wl_seat_interface, 1);
        wl_seat_add_listener(seat, &seat_listener, NULL);
    }
}

static void registry_handle_global_remove(void *data,
                                         struct wl_registry *registry,
                                         uint32_t name) {}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
    .global_remove = registry_handle_global_remove,
};

int create_shm_buffer(int width, int height, uint32_t format,
                     struct wl_buffer **buffer, void **data) {
    int stride = width * 4;
    int size = stride * height;

    int fd = memfd_create("wayland-shm", MFD_CLOEXEC);
    if (fd == -1) {
        perror("memfd_create");
        return -1;
    }

    if (ftruncate(fd, size) < 0) {
        perror("ftruncate");
        close(fd);
        return -1;
    }

    *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (*data == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return -1;
    }

    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    *buffer = wl_shm_pool_create_buffer(pool, 0, width, height,
                                       stride, format);
    wl_shm_pool_destroy(pool);
    close(fd);

    return 0;
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Failed to connect to Wayland display\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !shell || !shm) {
        fprintf(stderr, "Required Wayland interfaces not available\n");
        return 1;
    }

    surface = wl_compositor_create_surface(compositor);
    shell_surface = wl_shell_get_shell_surface(shell, surface);
    wl_shell_surface_add_listener(shell_surface, &shell_surface_listener, NULL);
    wl_shell_surface_set_toplevel(shell_surface);

    const int width = 400;
    const int height = 300;
    struct wl_buffer *buffer;
    void *data;

    if (create_shm_buffer(width, height, WL_SHM_FORMAT_XRGB8888,
                         &buffer, &data) < 0) {
        fprintf(stderr, "Failed to create buffer\n");
        return 1;
    }

    draw_color(data, width, height, 0xFF3333FF); // Vermelho
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    wl_buffer_destroy(buffer);
    wl_shell_surface_destroy(shell_surface);
    wl_surface_destroy(surface);
    if (shm) wl_shm_destroy(shm);
    if (shell) wl_shell_destroy(shell);
    if (compositor) wl_compositor_destroy(compositor);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);

    return 0;
}
```

Compile com:
```bash
gcc -o wayland-square wayland-square.c -lwayland-client
```

Executando o programa, você verá uma janela vermelha de 400x300 pixels. Ao clicar nela, o terminal exibirá a mensagem "Mouse clicked at [timestamp]".

**Erro comum**: Esquecer de chamar `wl_display_roundtrip()` após registrar o listener pode fazer com que interfaces necessárias não sejam detectadas. A mensagem de erro seria:
```
Required Wayland interfaces not available
```

**Exercício**: Modifique o programa para alternar entre vermelho e azul a cada clique do mouse. A solução está abaixo:

```c
// Dentro de pointer_handle_button, após o printf:
static uint32_t current_color = 0xFF3333FF; // Vermelho
current_color = (current_color == 0xFF3333FF) ? 0xFF0000FF : 0xFF3333FF;
draw_color(data, width, height, current_color);
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_commit(surface);
```

**Detalhes importantes**:
1. `memfd_create` cria buffers eficientes em memória compartilhada
2. `wl_surface_commit` é necessário após qualquer alteração visual
3. Listeners devem ser registrados explicitamente para cada dispositivo
4. A ordem de destruição de objetos Wayland é crítica para evitar vazamentos