## Debugging de gerenciamento de buffers

Um dos problemas mais comuns em aplicativos Wayland ocorre quando um buffer gráfico não é exibido corretamente - a janela aparece em branco, pisca ou mostra conteúdo corrompido. O cerne do problema está no ciclo de vida dos buffers, que seguem um modelo strict de ownership entre cliente e compositor.

Vamos debugar um caso real onde um buffer não é renderizado. Considere este código simples que desenha um retângulo vermelho:

```c
#include <wayland-client.h>
#include <wayland-client-protocol.h>
#include <stdlib.h>

struct wl_buffer *create_buffer(struct wl_shm *shm, int width, int height) {
    int stride = width * 4;
    int size = stride * height;
    int fd = create_anonymous_file(size);
    
    void *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    memset(data, 0xFF, size); // RGBA vermelho
    
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 
                                                         width, height,
                                                         stride, 
                                                         WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);
    
    return buffer;
}
```

Ao executar com `WAYLAND_DEBUG=1`, vemos o erro crítico:

```
[2154321.234]  -> wl_surface@14.attach(wl_buffer@18, 0, 0)
[2154321.245]  -> wl_surface@14.damage(0, 0, 320, 240)
[2154321.256]  -> wl_surface@14.commit()
[2154321.267] error wl_display@1: error 3 (invalid object) - invalid buffer 18
```

O erro `invalid object` indica que o buffer foi destruído prematuramente. No Wayland, os buffers são destruídos automaticamente quando o compositor os libera, e o código acima não mantém uma referência ativa. A correção requer registrar um listener de release:

```c
static void buffer_release(void *data, struct wl_buffer *buffer) {
    // Buffer liberado pelo compositor
    wl_buffer_destroy(buffer);
}

static const struct wl_buffer_listener buffer_listener = {
    .release = buffer_release
};

// Após criar o buffer:
wl_buffer_add_listener(buffer, &buffer_listener, NULL);
```

Outro cenário comum é o double-buffering incorreto, onde o aplicativo apresenta artefatos visuais. O padrão correto exige dois buffers alternados:

```c
struct app_state {
    struct wl_buffer *buffers[2];
    int current_buffer;
};

void redraw(struct app_state *state) {
    struct wl_buffer *buffer = state->buffers[state->current_buffer];
    
    // Preenche o buffer...
    draw_content(buffer);
    
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_damage(surface, 0, 0, width, height);
    wl_surface_commit(surface);
    
    state->current_buffer = !state->current_buffer; // Alterna buffers
}
```

Quando o gerenciamento de buffers falha, os sintomas incluem:

1. **Janela em branco**: Buffer não anexado ou destruído
2. **Conteúdo congelado**: Falta de novo commit após mudanças
3. **Artefatos gráficos**: Race condition no acesso ao buffer

Para diagnosticar, combine `WAYLAND_DEBUG` com inspeção direta:

```bash
WAYLAND_DEBUG=1 ./app 2>&1 | grep -E 'buffer|attach|commit'
```

Uma mensagem como `wl_buffer@18.destroy` sem um `wl_buffer@18.release` indica que o cliente destruiu o buffer enquanto o compositor ainda o usava - violação fatal do protocolo.

**Exercício**: Modifique o código inicial para implementar triple-buffering e exiba um contador de frames. Capture a saída de debug mostrando os ciclos de create/release.

**Solução**:

```c
#define NUM_BUFFERS 3

struct frame_data {
    uint32_t counter;
};

struct app_state {
    struct wl_buffer *buffers[NUM_BUFFERS];
    struct frame_data frames[NUM_BUFFERS];
    int current_buffer;
};

static void buffer_release(void *data, struct wl_buffer *buffer) {
    struct frame_data *fd = data;
    printf("Buffer released (frame %u)\n", fd->counter);
}

void redraw(struct app_state *state) {
    int next = (state->current_buffer + 1) % NUM_BUFFERS;
    draw_content(state->buffers[next], &state->frames[next]);
    
    wl_surface_attach(surface, state->buffers[next], 0, 0);
    wl_surface_commit(surface);
    
    state->current_buffer = next;
}
```

A saída de debug deve mostrar o padrão cíclico de buffers:

```
[2154321.345]  -> wl_buffer@19.attach
[2154321.356]  -> wl_surface@14.commit
[2154321.367] Buffer released (frame 42)
```