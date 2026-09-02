## Desenhando em superfícies Wayland

Para desenhar em uma superfície Wayland, você precisa primeiro entender como os pixels são transferidos do cliente para o compositor. O processo envolve a criação de buffers de pixels, associá-los a uma superfície (`wl_surface`) e finalmente enviar os dados para o compositor com um commit explícito.

Vamos começar com um exemplo simples que desenha um retângulo vermelho em uma janela Wayland. Para isso, usaremos a biblioteca `libwayland-client` e o protocolo `wl_shm` (Shared Memory), que permite compartilhar buffers de memória entre o cliente e o compositor.

```c
#include <wayland-client.h>
#include <wayland-client-protocol.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

struct wl_compositor *compositor = NULL;
struct wl_shell *shell = NULL;
struct wl_surface *surface = NULL;
struct wl_shm *shm = NULL;
struct wl_buffer *buffer = NULL;

static void draw_rectangle(uint32_t *pixels, int width, int height) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            pixels[y * width + x] = 0xFF0000FF; // RGBA: vermelho
        }
    }
}

static void create_buffer(int width, int height) {
    int stride = width * 4; // 4 bytes por pixel (RGBA)
    int size = stride * height;

    int fd = memfd_create("buffer", MFD_CLOEXEC);
    ftruncate(fd, size);

    uint32_t *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    draw_rectangle(data, width, height);

    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    buffer = wl_shm_pool_create_buffer(pool, 0, width, height, stride, WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);

    close(fd);
    munmap(data, size);
}

static void registry_handle_global(void *data, struct wl_registry *registry, uint32_t id,
                                   const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, id, &wl_compositor_interface, 1);
    } else if (strcmp(interface, "wl_shell") == 0) {
        shell = wl_registry_bind(registry, id, &wl_shell_interface, 1);
    } else if (strcmp(interface, "wl_shm") == 0) {
        shm = wl_registry_bind(registry, id, &wl_shm_interface, 1);
    }
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
};

int main(int argc, char **argv) {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !shell || !shm) {
        fprintf(stderr, "Falha ao obter interfaces globais\n");
        return 1;
    }

    surface = wl_compositor_create_surface(compositor);
    struct wl_shell_surface *shell_surface = wl_shell_get_shell_surface(shell, surface);
    wl_shell_surface_set_toplevel(shell_surface);

    create_buffer(200, 200);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);

    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }

    wl_display_disconnect(display);
    return 0;
}
```

Este código cria uma janela Wayland de 200x200 pixels e desenha um retângulo vermelho nela. Vamos detalhar o processo:

1. **Criação do buffer**: Usamos `memfd_create` para criar um arquivo em memória e `mmap` para mapeá-lo em nosso espaço de endereço. Isso permite que o cliente e o compositor compartilhem a memória eficientemente.

2. **Desenho**: A função `draw_rectangle` preenche o buffer com pixels vermelhos. Cada pixel é representado por um valor ARGB de 32 bits (0xFF0000FF para vermelho).

3. **Associação do buffer à superfície**: Criamos um `wl_shm_pool` a partir do buffer e, em seguida, um `wl_buffer` que é associado à superfície com `wl_surface_attach`.

4. **Commit**: O `wl_surface_commit` envia os dados para o compositor, que os exibe na tela.

Se você tentar executar este código sem definir corretamente o ambiente Wayland, pode receber um erro como:

```
Falha ao conectar ao display Wayland
```

Isso ocorre porque o código tenta se conectar ao compositor Wayland padrão, que pode não estar disponível se você estiver usando um ambiente X11. Para resolver isso, certifique-se de estar em uma sessão Wayland (`echo $XDG_SESSION_TYPE` deve retornar `wayland`).

### Exercício

Modifique o código para desenhar um gradiente de vermelho para azul na janela. A solução deve variar o valor dos pixels de acordo com a posição horizontal, criando um efeito de transição suave.

#### Solução

```c
static void draw_gradient(uint32_t *pixels, int width, int height) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t red = 255 - (x * 255 / width);
            uint8_t blue = x * 255 / width;
            pixels[y * width + x] = (0xFF << 24) | (red << 16) | (blue << 8);
        }
    }
}
```

Substitua a chamada `draw_rectangle` por `draw_gradient` na função `create_buffer`. Agora, ao executar o código, você verá uma janela com um gradiente que varia de vermelho à esquerda para azul à direita.