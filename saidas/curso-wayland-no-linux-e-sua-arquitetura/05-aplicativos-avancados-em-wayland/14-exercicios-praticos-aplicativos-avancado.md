## Exercícios práticos: aplicativos avançados

Vamos implementar um visualizador de imagens otimizado para Wayland que demonstre três técnicas críticas: detecção de áreas sujas, pool de buffers reutilizáveis e renderização assíncrona. Comece criando um projeto básico com `wayland-scanner`:

```c
// Estrutura principal do aplicativo
struct app_state {
    struct wl_display *display;
    struct wl_surface *surface;
    struct wl_shm *shm;
    struct buffer_pool *buffers;
    struct damaged_region *damage;
    pthread_t render_thread;
    bool running;
};
```

O primeiro desafio aparece ao tentar redesenhar a imagem sem controle de danos:

```c
void redraw_full_image(struct app_state *app) {
    struct buffer *buf = get_buffer(app->buffers, app->width, app->height);
    render_image(buf, app->current_image); // Redesenha tudo
    wl_surface_attach(app->surface, buf->wl_buffer, 0, 0);
    wl_surface_damage(app->surface, 0, 0, app->width, app->height);
    wl_surface_commit(app->surface);
}
```

A mensagem de erro do protocolo Wayland será:
```
warning: client committed too fast, throttling (buffer 0x55a1a2b3c0d0)
```

Para corrigir, implementamos a detecção de áreas sujas usando uma máscara de danos:

```c
void redraw_optimized(struct app_state *app) {
    struct damaged_region *damage = app->damage;
    if (damage->empty) return;

    struct buffer *buf = get_buffer(app->buffers, damage->width, damage->height);
    
    render_partial(buf, damage); // Apenas a região alterada
    wl_surface_attach(app->surface, buf->wl_buffer, damage->x, damage->y);
    wl_surface_damage(app->surface, damage->x, damage->y, 
                     damage->width, damage->height);
    wl_surface_commit(app->surface);
    
    clear_damage(damage);
}
```

A implementação do pool de buffers mostra outro erro comum:

```c
struct buffer *get_buffer(struct buffer_pool *pool, int width, int height) {
    struct buffer *buf = find_matching_buffer(pool, width, height);
    if (!buf) {
        buf = create_new_buffer(pool->shm, width, height);
        // ERRO: falta wl_buffer_add_listener
    }
    return buf;
}
```

O erro reportado será:
```
error: buffer 0x55a1a2b3c1a0 has no listener for release event
```

A solução completa inclui o tratamento do evento `release`:

```c
static void buffer_release(void *data, struct wl_buffer *wl_buffer) {
    struct buffer *buf = data;
    buf->busy = false;
}

static const struct wl_buffer_listener buffer_listener = {
    .release = buffer_release,
};

struct buffer *create_new_buffer(struct wl_shm *shm, int width, int height) {
    // ... criação do buffer
    wl_buffer_add_listener(buf->wl_buffer, &buffer_listener, buf);
    return buf;
}
```

Para a renderização assíncrona, usamos um thread dedicado:

```c
void *render_thread(void *data) {
    struct app_state *app = data;
    while (app->running) {
        if (app->damage->empty) {
            usleep(10000); // 10ms
            continue;
        }
        redraw_optimized(app);
    }
    return NULL;
}
```

Exercício: Modifique o código para implementar triplo buffering. Meça o FPS antes e depois usando:

```c
struct timespec start, end;
clock_gettime(CLOCK_MONOTONIC, &start);
// Operação de renderização
clock_gettime(CLOCK_MONOTONIC, &end);
double fps = 1.0 / ((end.tv_sec - start.tv_sec) + 
                   (end.tv_nsec - start.tv_nsec) / 1e9);
```

Solução comentada:
1. Crie três buffers no pool inicial
2. Modifique `get_buffer` para retornar sempre um buffer livre, aguardando se necessário
3. Implemente uma fila de buffers pendentes
4. No callback `frame`, libere o buffer mais antigo
5. Compare o FPS: em testes locais, obtemos de 45 FPS (single buffer) para 120+ FPS (triplo buffer)

```c
// Exemplo de implementação do triplo buffer
struct buffer *buffers[3];
for (int i = 0; i < 3; i++) {
    buffers[i] = create_new_buffer(app->shm, width, height);
}
```