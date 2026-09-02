## Gerenciando buffers em Wayland

O problema central no desenho de aplicativos gráficos é: como transferir eficientemente pixels da aplicação para a tela? No X11, isso era feito através do X Server, mas no Wayland, o cliente é responsável por gerenciar seus próprios buffers de pixels e entregá-los ao compositor.

### O ciclo de vida de um buffer

Um buffer em Wayland é uma região de memória contendo dados de pixels que serão exibidos na tela. O fluxo típico envolve:

1. Alocação do buffer
2. Preenchimento com conteúdo gráfico
3. Anexação a uma superfície
4. Commit para o compositor
5. Liberação quando não for mais necessário

Veja um exemplo concreto usando shared memory (SHM):

```c
#include <wayland-client.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

struct wl_shm_pool *create_shm_pool(struct wl_shm *shm, size_t size, void **data) {
    char filename[] = "/tmp/wayland-shm-XXXXXX";
    int fd = mkstemp(filename);
    ftruncate(fd, size);
    *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    close(fd);
    unlink(filename);
    
    return pool;
}

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    // ... [setup de registry listener para obter wl_shm] ...
    
    void *shm_data;
    struct wl_shm_pool *pool = create_shm_pool(shm, 640 * 480 * 4, &shm_data);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 640, 480, 640 * 4, WL_SHM_FORMAT_ARGB8888);
    
    // Preenche o buffer com um gradiente
    uint32_t *pixels = (uint32_t*)shm_data;
    for (int y = 0; y < 480; y++) {
        for (int x = 0; x < 640; x++) {
            pixels[y * 640 + x] = (0xFF << 24) | (x % 256 << 16) | (y % 256 << 8);
        }
    }
    
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
    
    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }
    
    wl_buffer_destroy(buffer);
    wl_shm_pool_destroy(pool);
    munmap(shm_data, 640 * 480 * 4);
    // ... [cleanup] ...
}
```

### Formatos de buffer suportados

Wayland suporta vários formatos de pixel através do protocolo `wl_shm`. Os mais comuns são:

- `WL_SHM_FORMAT_ARGB8888`: 32 bits por pixel (8 bits por canal)
- `WL_SHM_FORMAT_XRGB8888`: idem, mas sem canal alpha
- `WL_SHM_FORMAT_RGB565`: 16 bits por pixel (5-6-5)

O erro mais comum é tentar usar um formato não suportado:

```
Erro típico:
wl_shm@10: error 0: invalid format 0x34325258
wl_display@1: error 0: invalid object 10
```

Para resolver, sempre verifique os formatos suportados:

```c
uint32_t formats[] = {WL_SHM_FORMAT_ARGB8888, WL_SHM_FORMAT_XRGB8888};
int supported = 0;
for (size_t i = 0; i < sizeof(formats)/sizeof(formats[0]); i++) {
    if (formats[i] == WL_SHM_FORMAT_ARGB8888) {
        supported = 1;
        break;
    }
}
if (!supported) {
    fprintf(stderr, "Formato ARGB8888 não suportado!\n");
    exit(1);
}
```

### Troca de buffers e double buffering

Para animações suaves, é essencial usar pelo menos dois buffers (double buffering):

```c
struct app_state {
    struct wl_buffer *buffers[2];
    int current_buffer;
    // ... outros campos ...
};

void frame_callback(void *data, struct wl_callback *callback, uint32_t time) {
    struct app_state *state = data;
    
    // Alterna buffers
    state->current_buffer ^= 1;
    struct wl_buffer *next = state->buffers[state->current_buffer];
    
    // Atualiza o conteúdo
    update_buffer_content(next);
    
    wl_surface_attach(surface, next, 0, 0);
    wl_surface_commit(surface);
    
    // Configura novo callback
    struct wl_callback *new_cb = wl_surface_frame(surface);
    wl_callback_add_listener(new_cb, &frame_listener, state);
    wl_callback_destroy(callback);
}

struct wl_callback_listener frame_listener = {
    .done = frame_callback
};
```

### Gerenciamento de memória

Buffers grandes podem consumir recursos significativos. Um erro frequente é vazar memória:

```c
// ERRADO: esquecer de liberar buffer antigo
wl_surface_attach(surface, new_buffer, 0, 0);
wl_surface_commit(surface);

// CORRETO:
if (previous_buffer) {
    wl_buffer_destroy(previous_buffer);
}
wl_surface_attach(surface, new_buffer, 0, 0);
wl_surface_commit(surface);
previous_buffer = new_buffer;
```

### Exercício prático

Modifique o exemplo inicial para implementar:
1. Double buffering com dois buffers SHM
2. Uma animação simples (como um quadrado que se move na tela)
3. Limpeza adequada de todos os recursos

Solução comentada:

```c
struct animation_state {
    struct wl_buffer *buffers[2];
    int current_buffer;
    int x_pos;
};

void update_buffer(struct wl_buffer *buffer, int x_pos) {
    // ... similar ao exemplo inicial, mas desenhando um quadrado em x_pos
}

void frame_callback(void *data, struct wl_callback *cb, uint32_t time) {
    struct animation_state *state = data;
    state->current_buffer ^= 1;
    state->x_pos = (state->x_pos + 5) % 600;
    
    update_buffer(state->buffers[state->current_buffer], state->x_pos);
    
    wl_surface_attach(surface, state->buffers[state->current_buffer], 0, 0);
    struct wl_callback *new_cb = wl_surface_frame(surface);
    wl_callback_add_listener(new_cb, &frame_listener, state);
    wl_surface_commit(surface);
    wl_callback_destroy(cb);
}
```