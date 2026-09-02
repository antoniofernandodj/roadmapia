## Boas práticas para desenvolvimento Wayland

Desenvolver para Wayland exige atenção a detalhes e práticas específicas que garantem aplicativos robustos e eficientes. Aqui estão algumas recomendações essenciais:

### 1. **Gerenciamento correto de buffers**

Buffers são fundamentais para renderização gráfica em Wayland. Um erro comum é esquecer de liberar buffers após o uso, o que pode levar a vazamentos de memória. Sempre libere buffers explicitamente após o commit:

```c
wl_buffer_destroy(buffer); // Libera o buffer após o uso
```

Outro ponto crítico é garantir que o buffer esteja associado à superfície antes de chamar `wl_surface_commit`. Caso contrário, o compositor emitirá um aviso:

```
warning: no buffer attached to surface
```

### 2. **Registro explícito de listeners**

Wayland depende de listeners para capturar eventos. Esquecer de registrar um listener resulta em eventos ignorados. Certifique-se de registrar listeners para todas as interfaces necessárias:

```c
static const struct wl_keyboard_listener keyboard_listener = {
    .key = keyboard_key,
    .modifiers = keyboard_modifiers,
};

wl_keyboard_add_listener(keyboard, &keyboard_listener);
```

### 3. **Uso de double buffering**

Double buffering é essencial para animações suaves. A técnica envolve alternar entre dois buffers: enquanto um é exibido, o outro é preenchido com novos dados. Wayland facilita isso com `wl_surface_commit`:

```c
wl_surface_commit(surface); // Alterna buffers após atualizar o conteúdo
```

### 4. **Tratamento de erros de protocolo**

Wayland é rigoroso em relação a erros de protocolo. Use `wl_display_get_error` para capturar erros e implemente lógica de reconexão se necessário:

```c
int error = wl_display_get_error(display);
if (error) {
    fprintf(stderr, "Erro de protocolo: %s\n", strerror(error));
    // Lógica de reconexão aqui
}
```

### 5. **Verificação de protocolos estendidos**

Protocolos estendidos como `xdg_shell` são comuns, mas não garantidos. Sempre verifique se o protocolo está disponível antes de usá-lo:

```c
struct xdg_wm_base *wm_base = wl_registry_bind(registry, id, &xdg_wm_base_interface, 1);
if (!wm_base) {
    fprintf(stderr, "Protocolo xdg_shell não suportado\n");
    return;
}
```

### 6. **Depuração com `WAYLAND_DEBUG`**

Ativar `WAYLAND_DEBUG=1` revela a comunicação bruta entre cliente e compositor, facilitando a identificação de problemas:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

Isso exibe mensagens detalhadas sobre cada comunicação, ajudando a depurar eventos ignorados ou malformados.

### 7. **Limpeza adequada de recursos**

Wayland não gerencia automaticamente recursos como superfícies e buffers. Certifique-se de liberar todos os recursos ao encerrar o aplicativo:

```c
wl_surface_destroy(surface); // Libera a superfície
wl_display_disconnect(display); // Fecha a conexão com o compositor
```

### Exercício Prático

Implemente um cliente Wayland que exiba uma janela com um gradiente azul e responda a cliques do mouse. Certifique-se de:

1. Criar e gerenciar buffers corretamente.
2. Registrar listeners para eventos de mouse.
3. Implementar double buffering para uma transição suave.
4. Liberar todos os recursos ao encerrar.

**Solução:**

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wl_shell *shell;
struct wl_shell_surface *shell_surface;
struct wl_shm *shm;
struct wl_buffer *buffer;

void create_buffer(int width, int height) {
    int stride = width * 4;
    int size = stride * height;
    int fd = memfd_create("buffer", MFD_CLOEXEC);
    ftruncate(fd, size);
    void *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    buffer = wl_shm_pool_create_buffer(pool, 0, width, height, stride, WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);

    // Preenche o buffer com um gradiente azul
    uint32_t *pixels = data;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t blue = 255 * y / height;
            pixels[y * width + x] = (0xFF << 24) | (blue << 16);
        }
    }

    munmap(data, size);
}

void handle_ping(void *data, struct wl_shell_surface *shell_surface, uint32_t serial) {
    wl_shell_surface_pong(shell_surface, serial);
}

void handle_configure(void *data, struct wl_shell_surface *shell_surface, uint32_t edges, int32_t width, int32_t height) {
    create_buffer(width, height);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
}

static const struct wl_shell_surface_listener shell_surface_listener = {
    .ping = handle_ping,
    .configure = handle_configure,
};

void handle_registry_global(void *data, struct wl_registry *registry, uint32_t id, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, id, &wl_compositor_interface, version);
    } else if (strcmp(interface, "wl_shell") == 0) {
        shell = wl_registry_bind(registry, id, &wl_shell_interface, version);
    } else if (strcmp(interface, "wl_shm") == 0) {
        shm = wl_registry_bind(registry, id, &wl_shm_interface, version);
    }
}

static const struct wl_registry_listener registry_listener = {
    .global = handle_registry_global,
};

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    shell_surface = wl_shell_get_shell_surface(shell, surface);
    wl_shell_surface_add_listener(shell_surface, &shell_surface_listener, NULL);
    wl_shell_surface_set_toplevel(shell_surface);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    wl_buffer_destroy(buffer);
    wl_shell_surface_destroy(shell_surface);
    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

Este código cria uma janela Wayland com um gradiente azul e responde a eventos de configuração para redimensionar o buffer adequadamente. A limpeza de recursos é realizada ao encerrar o aplicativo.