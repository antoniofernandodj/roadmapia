## Casos de uso da arquitetura Wayland

Wayland é uma arquitetura moderna para sistemas gráficos que resolve problemas específicos encontrados em soluções anteriores, como o X11. Para entender melhor como Wayland funciona na prática, vamos explorar alguns casos de uso comuns e como a arquitetura lida com eles.

### 1. **Gerenciamento de Janelas em Ambientes Multi-Monitor**

Um dos desafios em sistemas gráficos é o gerenciamento eficiente de janelas em setups multi-monitor. Wayland aborda isso usando a interface `wl_output`, que permite aos clientes descobrir monitores conectados e suas propriedades, como resolução e posição.

```c
#include <wayland-client.h>
#include <stdio.h>

void handle_geometry(void *data, struct wl_output *wl_output, int x, int y,
                     int physical_width, int physical_height, int subpixel,
                     const char *make, const char *model, int transform) {
    printf("Monitor: %s %s\n", make, model);
    printf("Posição: (%d, %d)\n", x, y);
}

void handle_mode(void *data, struct wl_output *wl_output, uint32_t flags,
                 int width, int height, int refresh) {
    printf("Resolução: %dx%d @ %dHz\n", width, height, refresh);
}

static const struct wl_output_listener output_listener = {
    .geometry = handle_geometry,
    .mode = handle_mode,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_output *output = NULL;

    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (output) {
        wl_output_add_listener(output, &output_listener, NULL);
        wl_display_roundtrip(display);
    }

    wl_output_destroy(output);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);
    return 0;
}
```

**Saída esperada:**
```
Monitor: Dell U2719D
Posição: (1920, 0)
Resolução: 2560x1440 @ 60Hz
```

### 2. **Sincronização de Frames para Evitar Tearing**

Outro problema comum em sistemas gráficos é o *tearing*, que ocorre quando partes de diferentes frames são exibidas simultaneamente. Wayland resolve isso usando a interface `wl_surface` e callbacks de sincronização.

```c
#include <wayland-client.h>
#include <stdio.h>

void frame_callback(void *data, struct wl_callback *callback, uint32_t time) {
    printf("Frame sincronizado no tempo: %d\n", time);
    wl_callback_destroy(callback);
}

static const struct wl_callback_listener callback_listener = {
    .done = frame_callback,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_compositor *compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    struct wl_callback *callback = wl_surface_frame(surface);

    wl_callback_add_listener(callback, &callback_listener, NULL);
    wl_display_roundtrip(display);

    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wl_display_disconnect(display);
    return 0;
}
```

**Saída esperada:**
```
Frame sincronizado no tempo: 123456
```

### 3. **Isolamento de Sessões para Segurança**

Wayland oferece um modelo de segurança robusto através do isolamento de sessões. Cada sessão usa um socket Unix único, localizado em `/run/user/<UID>/wayland-*`, e as permissões de arquivo garantem que apenas o usuário correto possa acessá-lo.

```bash
$ ls -l /run/user/1000/wayland-0
srwxr-xr-x 1 usuario usuario 0 Jan  1 12:00 /run/user/1000/wayland-0
```

Isso impede que um cliente malicioso interfira em outras sessões ou capture eventos de entrada globalmente, como keylogging.

### 4. **Integração com Aplicativos X11 via XWayland**

Para manter a compatibilidade com aplicativos X11, Wayland oferece XWayland, um servidor X que traduz protocolos X11 para Wayland. Isso permite que aplicativos legados sejam executados em um ambiente Wayland moderno.

```bash
$ env DISPLAY=:1 xeyes
```

Apesar de útil, essa integração introduz um overhead de latência, geralmente em torno de 10-20ms por frame, devido à tradução necessária entre os protocolos.

### 5. **Compartilhamento de Buffers para Eficiência**

Wayland usa o protocolo `wl_shm` para compartilhar buffers gráficos entre clientes e o compositor. Isso é feito através de memória compartilhada, alocada com `memfd_create` e mapeada com `mmap`.

```c
#include <wayland-client.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    int fd = memfd_create("buffer", MFD_CLOEXEC);
    ftruncate(fd, 1024 * 768 * 4); // Aloca espaço para um buffer de 1024x768 em ARGB32
    void *data = mmap(NULL, 1024 * 768 * 4, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    struct wl_shm *shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, 1024 * 768 * 4);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 1024, 768, 4096, WL_SHM_FORMAT_ARGB8888);

    munmap(data, 1024 * 768 * 4);
    close(fd);
    wl_shm_pool_destroy(pool);
    wl_shm_destroy(shm);
    return 0;
}
```

Esse método é mais eficiente do que o usado no X11, onde buffers são frequentemente copiados entre processos.

### 6. **Erros Comuns e Correções**

Um erro comum ao trabalhar com Wayland é esquecer de liberar recursos, o que pode levar a vazamentos de memória. Para evitar isso, sempre destrua recursos com `_destroy()` após o uso.

```c
wl_buffer_destroy(buffer);
wl_shm_pool_destroy(pool);
wl_shm_destroy(shm);
```

Outro erro frequente é não implementar todos os callbacks obrigatórios, resultando em falhas de protocolo. Certifique-se de que todos os listeners estejam completos, mesmo para eventos não utilizados.

```c
static const struct wl_output_listener output_listener = {
    .geometry = handle_geometry,
    .mode = handle_mode,
    .done = NULL, // Callback obrigatório, mesmo que não seja usado
};
```

### Conclusão

Wayland oferece uma arquitetura moderna e eficiente para sistemas gráficos, resolvendo problemas específicos encontrados em soluções anteriores como o X11. Através de casos de uso práticos, é possível ver como Wayland lida com gerenciamento de janelas, sincronização de frames, segurança, integração com aplicativos legados, compartilhamento de buffers e erros comuns. Esses exemplos ilustram a robustez e flexibilidade da arquitetura Wayland.