## Ferramentas para desenvolvimento avançado

Quando você está desenvolvendo um aplicativo Wayland complexo, como um editor de vídeo ou uma ferramenta CAD, as ferramentas básicas não são suficientes. Vamos analisar um caso real: seu aplicativo gráfico está consumindo muita CPU quando deveria estar ocioso, e você precisa descobrir por quê.

Primeiro, vamos ativar o logging detalhado do protocolo Wayland:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

A saída mostrará cada mensagem trocada entre cliente e compositor. Um problema comum aparece assim:

```
[1234567.890]  -> wl_surface@5.frame(new id wl_callback@6)
[1234567.891]  -> wl_surface@5.commit()
[1234567.892]  -> wl_callback@6.done(1234567890)
[1234567.893]  -> wl_surface@5.frame(new id wl_callback@7)
```

Esse loop infinito mostra que o aplicativo está constantemente solicitando novos frames, mesmo sem conteúdo novo para renderizar. A solução é implementar corretamente o evento `done`:

```c
static void frame_callback(void *data, struct wl_callback *callback, uint32_t time) {
    /* Remove o callback antigo */
    wl_callback_destroy(callback);
    
    /* Só marca como sujo se houver conteúdo novo */
    if (app_needs_redraw(data)) {
        /* Configura um novo callback apenas quando necessário */
        struct wl_callback *new_cb = wl_surface_frame(surface);
        wl_callback_add_listener(new_cb, &frame_listener, data);
        wl_surface_commit(surface);
    }
}
```

Para análise de memória, o Valgrind é essencial, mas precisa de tratamento especial para buffers gráficos:

```bash
valgrind --trace-children=yes --leak-check=full --show-leak-kinds=all \
         --errors-for-leak-kinds=all --suppressions=/usr/share/gtk-4.0/valgrind/gtk.supp \
         ./meu_app
```

Um erro típico que você encontrará:

```
==12345== 1,024 bytes in 1 blocks are definitely lost in loss record 1 of 1
==12345==    at 0x4843828: malloc (vg_replace_malloc.c:381)
==12345==    by 0x123456: create_buffer (app.c:42)
==12345==    by 0x123789: render_frame (app.c:103)
```

Isso indica que você está alocando buffers sem liberá-los. A correção envolve implementar um pool de buffers:

```c
#define POOL_SIZE 3
struct wl_buffer *buffer_pool[POOL_SIZE];
int free_buffers = POOL_SIZE;

struct wl_buffer_listener buffer_listener = {
    .release = buffer_release_handler
};

static void buffer_release_handler(void *data, struct wl_buffer *wl_buffer) {
    free_buffers++;
}

struct wl_buffer *get_buffer(struct wl_shm *shm, int width, int height) {
    if (free_buffers == 0) {
        fprintf(stderr, "Erro: Pool de buffers esgotado\n");
        return NULL;
    }
    
    /* Implementação real da criação de buffer */
    struct wl_buffer *buf = create_shm_buffer(shm, width, height);
    wl_buffer_add_listener(buf, &buffer_listener, NULL);
    free_buffers--;
    return buf;
}
```

Para profiling de desempenho, o `perf` é indispensável:

```bash
perf record -g -F 999 ./meu_app
perf report -g 'graph,0.5,caller'
```

Isso revelará as funções que mais consomem CPU. Um exemplo comum de problema:

```
Overhead  Command  Shared Object      Symbol
  45.67%  meu_app  libcairo.so.2      [.] cairo_surface_flush
  22.34%  meu_app  libwayland-client  [.] wl_proxy_marshal_flags
```

Isso indica que você está realizando muitas operações de desenho desnecessárias. A solução é implementar detecção de áreas sujas:

```c
struct damage_region {
    int x, y, width, height;
    bool empty;
};

void app_redraw(struct damage_region *damage) {
    if (damage->empty) return;
    
    cairo_t *cr = cairo_create(surface);
    cairo_rectangle(cr, damage->x, damage->y, damage->width, damage->height);
    cairo_clip(cr);
    
    /* Desenha apenas a região danificada */
    draw_content(cr, damage);
    
    cairo_destroy(cr);
    damage->empty = true;
}
```

**Exercício**: Implemente um visualizador de imagens que:
1. Use um pool de 4 buffers
2. Implemente detecção de áreas sujas para zoom
3. Meça o tempo entre frames com `clock_gettime(CLOCK_MONOTONIC)`

**Solução comentada**:

```c
#define BUFFER_POOL_SIZE 4
struct buffer_pool {
    struct wl_buffer *buffers[BUFFER_POOL_SIZE];
    bool in_use[BUFFER_POOL_SIZE];
};

static void buffer_release_handler(void *data, struct wl_buffer *wl_buffer) {
    struct buffer_pool *pool = data;
    for (int i = 0; i < BUFFER_POOL_SIZE; i++) {
        if (pool->buffers[i] == wl_buffer) {
            pool->in_use[i] = false;
            break;
        }
    }
}

struct wl_buffer *get_free_buffer(struct buffer_pool *pool, struct wl_shm *shm, 
                                 int width, int height) {
    for (int i = 0; i < BUFFER_POOL_SIZE; i++) {
        if (!pool->in_use[i]) {
            if (!pool->buffers[i]) {
                pool->buffers[i] = create_shm_buffer(shm, width, height);
                wl_buffer_add_listener(pool->buffers[i], &buffer_listener, pool);
            }
            pool->in_use[i] = true;
            return pool->buffers[i];
        }
    }
    return NULL;
}

void zoom_image(struct damage_region *damage, double scale) {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    /* Calcula nova região visível */
    damage->x = center_x - (width/2)/scale;
    damage->y = center_y - (height/2)/scale;
    damage->width = width/scale;
    damage->height = height/scale;
    damage->empty = false;
    
    app_redraw(damage);
    
    clock_gettime(CLOCK_MONOTONIC, &end);
    double elapsed = (end.tv_sec - start.tv_sec) * 1000.0;
    elapsed += (end.tv_nsec - start.tv_nsec) / 1000000.0;
    printf("Frame renderizado em %.2fms\n", elapsed);
}
```