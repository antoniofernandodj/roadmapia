## Gerenciamento avançado de buffers

Em aplicações gráficas, o gerenciamento de buffers é crucial para desempenho e estabilidade. Vamos resolver um problema concreto: sua aplicação Wayland está consumindo memória excessiva ao redesenhar uma interface com animações complexas. O motivo? Alocação descontrolada de buffers.

### O ciclo de vida de um buffer

Cada frame renderizado requer um buffer (região de memória contendo pixels). Em Wayland, buffers são representados pelo protocolo `wl_buffer` e precisam ser gerenciados manualmente. Veja o que acontece quando você erra:

```c
// EXEMPLO PROBLEMÁTICO - VAZAMENTO DE BUFFERS
void render_frame(struct wl_shm_pool *pool, int width, height) {
    int stride = width * 4;
    int size = stride * height;
    
    int fd = create_anonymous_file(size); // Aloca memória
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0,
                                width, height, stride, 
                                WL_SHM_FORMAT_ARGB8888);
    
    // Renderiza conteúdo...
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
    
    // ESQUECEU DE LIBERAR! vazamento de memória
}
```

Após algumas centenas de frames, sua aplicação será morta pelo OOM killer. A mensagem de erro típica no syslog será:
```
oom-killer: Kill process 12345 (meu_app) score 987
```

### Solução: Pool de buffers

O padrão correto é reutilizar buffers através de um pool. Implementaremos um buffer pool com estas características:
- Alocação inicial de N buffers
- Reutilização circular
- Liberação segura no final

```c
#define BUFFER_POOL_SIZE 3

struct buffer_pool {
    struct wl_buffer *buffers[BUFFER_POOL_SIZE];
    int in_use[BUFFER_POOL_SIZE];
    size_t current;
};

struct buffer_pool* create_buffer_pool(struct wl_shm *shm, 
                                     int width, int height) {
    struct buffer_pool *pool = malloc(sizeof(*pool));
    int stride = width * 4;
    int size = stride * height;
    
    for (int i = 0; i < BUFFER_POOL_SIZE; i++) {
        int fd = create_anonymous_file(size);
        struct wl_shm_pool *shm_pool = wl_shm_create_pool(shm, fd, size);
        pool->buffers[i] = wl_shm_pool_create_buffer(shm_pool, 0,
                                  width, height, stride,
                                  WL_SHM_FORMAT_ARGB8888);
        wl_shm_pool_destroy(shm_pool);
        close(fd);
        pool->in_use[i] = 0;
    }
    pool->current = 0;
    return pool;
}

struct wl_buffer* get_next_buffer(struct buffer_pool *pool) {
    // Encontra próximo buffer livre
    for (size_t i = 0; i < BUFFER_POOL_SIZE; i++) {
        size_t idx = (pool->current + i) % BUFFER_POOL_SIZE;
        if (!pool->in_use[idx]) {
            pool->in_use[idx] = 1;
            pool->current = (idx + 1) % BUFFER_POOL_SIZE;
            return pool->buffers[idx];
        }
    }
    return NULL; // Todos em uso
}

void release_buffer(struct buffer_pool *pool, struct wl_buffer *buffer) {
    for (int i = 0; i < BUFFER_POOL_SIZE; i++) {
        if (pool->buffers[i] == buffer) {
            pool->in_use[i] = 0;
            break;
        }
    }
}
```

### Uso correto com callbacks

Para sincronizar a liberação, usamos `wl_buffer.release`:

```c
static void buffer_release(void *data, struct wl_buffer *buffer) {
    struct buffer_pool *pool = data;
    release_buffer(pool, buffer);
}

static const struct wl_buffer_listener buffer_listener = {
    .release = buffer_release
};

// Ao criar cada buffer:
wl_buffer_add_listener(buffer, &buffer_listener, pool);
```

### Buffer swapping eficiente

Quando o compositor termina de usar um buffer, ele emite o evento `release`. Este é o momento seguro para reutilizá-lo. Veja o fluxo completo:

1. Obter buffer disponível com `get_next_buffer()`
2. Renderizar conteúdo
3. Anexar à superfície com `wl_surface_attach()`
4. Ao receber `release`, marcar o buffer como disponível

### Exercício: Implementação de triplo buffer

Modifique o exemplo para usar triplo buffer (3 buffers) com estas melhorias:
1. Adicione contadores de estatística (buffers em uso, taxa de reutilização)
2. Implemente timeout para buffers presos (>500ms sem release)
3. Adicione fallback para alocação dinâmica quando todos estiverem em uso

Solução comentada:

```c
// [1] Estrutura estendida
struct buffer_pool {
    struct wl_buffer *buffers[3];
    int in_use[3];
    struct timespec last_used[3];
    size_t stats_total;
    size_t stats_reused;
};

// [2] Obter buffer com timeout
struct wl_buffer* get_buffer_with_timeout(struct buffer_pool *pool, 
                                         int timeout_ms) {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    
    for (int i = 0; i < 3; i++) {
        if (!pool->in_use[i]) {
            pool->stats_total++;
            pool->in_use[i] = 1;
            pool->last_used[i] = now;
            return pool->buffers[i];
        } else {
            long elapsed = (now.tv_sec - pool->last_used[i].tv_sec) * 1000 +
                          (now.tv_nsec - pool->last_used[i].tv_nsec) / 1000000;
            if (elapsed > timeout_ms) {
                pool->stats_reused++;
                pool->last_used[i] = now;
                return pool->buffers[i];
            }
        }
    }
    
    // [3] Fallback dinâmico
    pool->stats_total++;
    return create_temp_buffer(); // Implementação omitida
}
```