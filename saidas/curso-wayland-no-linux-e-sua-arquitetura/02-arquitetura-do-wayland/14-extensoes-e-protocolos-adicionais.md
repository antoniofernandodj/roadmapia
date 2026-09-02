## Extensões e protocolos adicionais

O protocolo base do Wayland define apenas os componentes essenciais para a comunicação entre clientes e o compositor, como a criação de superfícies (`wl_surface`) e a manipulação de eventos de entrada. No entanto, muitos recursos avançados, como suporte a múltiplos monitores, compartilhamento de buffers e sincronização de frames, são implementados através de extensões ao protocolo base. Essas extensões permitem que o Wayland seja adaptável a diferentes necessidades e cenários, sem sobrecarregar o núcleo do protocolo.

### `wl_shm`: Compartilhamento de buffers via memória compartilhada

O protocolo `wl_shm` (Shared Memory) permite que clientes compartilhem buffers gráficos com o compositor usando memória compartilhada. Isso é essencial para aplicativos que precisam desenhar diretamente em uma região de memória, como jogos ou players de vídeo. O cliente cria um buffer usando `memfd_create` e mapeia essa memória com `mmap`. O compositor pode então acessar o buffer diretamente para renderização.

```c
#include <wayland-client.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_shm *shm = NULL;
    wl_registry_add_listener(registry, &registry_listener, &shm);

    wl_display_roundtrip(display);

    if (!shm) {
        fprintf(stderr, "wl_shm não disponível\n");
        return 1;
    }

    int fd = memfd_create("buffer", 0);
    ftruncate(fd, 1024 * 768 * 4); // Exemplo: buffer 1024x768 RGBA

    void *data = mmap(NULL, 1024 * 768 * 4, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    // Desenhar no buffer aqui

    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, 1024 * 768 * 4);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 1024, 768, 1024 * 4, WL_SHM_FORMAT_ARGB8888);

    wl_shm_pool_destroy(pool);
    close(fd);

    // Usar o buffer para renderização
    wl_buffer_destroy(buffer);
    munmap(data, 1024 * 768 * 4);
    wl_display_disconnect(display);
    return 0;
}
```

**Erro comum:** Esquecer de liberar recursos, como `wl_shm_pool` ou buffers, pode levar a vazamentos de memória. Sempre destrua os recursos após o uso.

### `wl_output`: Suporte a múltiplos monitores

O protocolo `wl_output` permite que clientes descubram e interajam com monitores conectados. Isso inclui obter informações sobre resolução, taxa de atualização e posicionamento físico dos monitores. Isso é essencial para aplicativos que precisam se adaptar a diferentes configurações de tela, como editores de vídeo ou ferramentas de design gráfico.

```c
struct wl_output *output;

void output_geometry(void *data, struct wl_output *wl_output, int32_t x, int32_t y,
                     int32_t physical_width, int32_t physical_height, int32_t subpixel,
                     const char *make, const char *model, int32_t transform) {
    printf("Monitor: %s %s\n", make, model);
    printf("Posição: (%d, %d)\n", x, y);
}

void output_mode(void *data, struct wl_output *wl_output, uint32_t flags,
                 int32_t width, int32_t height, int32_t refresh) {
    printf("Resolução: %dx%d @ %d Hz\n", width, height, refresh);
}

struct wl_output_listener output_listener = {
    .geometry = output_geometry,
    .mode = output_mode,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);

    wl_display_roundtrip(display);

    if (!output) {
        fprintf(stderr, "wl_output não disponível\n");
        return 1;
    }

    wl_output_add_listener(output, &output_listener, NULL);
    wl_display_roundtrip(display);

    wl_display_disconnect(display);
    return 0;
}
```

**Erro comum:** Assumir que todos os monitores têm a mesma resolução ou taxa de atualização pode levar a problemas de layout ou desempenho.

### `wp_viewporter`: Redimensionamento de superfícies

O protocolo `wp_viewporter` permite que clientes redimensionem superfícies (`wl_surface`) sem precisar recriá-las. Isso é útil para aplicativos que precisam ajustar dinamicamente o tamanho de suas janelas, como navegadores web ou editores de texto.

```c
struct wp_viewporter *viewporter;
struct wp_viewport *viewport;

void create_viewport(struct wl_surface *surface, int32_t width, int32_t height) {
    viewport = wp_viewporter_get_viewport(viewporter, surface);
    wp_viewport_set_destination(viewport, width, height);
}

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);

    wl_display_roundtrip(display);

    if (!viewporter) {
        fprintf(stderr, "wp_viewporter não disponível\n");
        return 1;
    }

    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    create_viewport(surface, 800, 600);

    wl_display_roundtrip(display);

    wp_viewport_destroy(viewport);
    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

**Erro comum:** Não destruir o `wp_viewport` após o uso pode levar a vazamentos de memória.

### Conclusão

As extensões ao protocolo base do Wayland permitem que ele seja adaptável a diferentes necessidades, desde compartilhamento de buffers até suporte a múltiplos monitores e redimensionamento de superfícies. Esses protocolos adicionais são essenciais para aplicativos gráficos avançados, proporcionando flexibilidade e controle sobre a renderização e interação com o usuário.