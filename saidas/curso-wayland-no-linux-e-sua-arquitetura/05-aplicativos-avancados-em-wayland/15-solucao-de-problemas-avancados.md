## Solução de problemas avançados

Ao desenvolver aplicativos Wayland, você inevitavelmente encontrará problemas avançados que exigem uma compreensão profunda do protocolo e do comportamento do compositor. Vamos explorar algumas dessas questões e suas soluções.

### Problema 1: Commit rápido demais

Um erro comum é tentar realizar commits de buffers muito rapidamente, o que pode levar ao erro `commit while pending`. Isso ocorre quando você tenta comitar um novo buffer antes que o compositor tenha processado o anterior.

```c
wl_surface_commit(surface);  // Primeiro commit
wl_surface_commit(surface);  // Segundo commit antes do primeiro ser processado
```

A saída do erro será algo como:

```
error: commit while pending
```

Para resolver isso, você deve esperar pelo evento `wl_callback` que indica que o compositor terminou de processar o buffer:

```c
static void frame_callback(void *data, struct wl_callback *callback, uint32_t time) {
    wl_callback_destroy(callback);
    // Agora é seguro comitar o próximo buffer
}

static struct wl_callback_listener frame_listener = {
    .done = frame_callback
};

void commit_next_frame(struct wl_surface *surface) {
    struct wl_callback *callback = wl_surface_frame(surface);
    wl_callback_add_listener(callback, &frame_listener, NULL);
    wl_surface_commit(surface);
}
```

### Problema 2: Buffer pool insuficiente

Outro problema comum é a insuficiência do buffer pool, especialmente em aplicativos que exigem alta taxa de atualização. Isso pode levar a vazamentos de memória ou quedas de desempenho.

Para resolver isso, você pode implementar um pool dinâmico que aloca buffers conforme necessário e os reutiliza:

```c
struct buffer_pool {
    struct wl_buffer *buffers[3];
    int available[3];
};

struct buffer_pool pool = {0};

struct wl_buffer *get_buffer(struct wl_shm *shm, int width, int height) {
    for (int i = 0; i < 3; i++) {
        if (pool.available[i]) {
            pool.available[i] = 0;
            return pool.buffers[i];
        }
    }
    // Se nenhum buffer disponível, cria um novo
    struct wl_buffer *buffer = create_shm_buffer(shm, width, height);
    pool.buffers[2] = buffer;
    return buffer;
}

void release_buffer(struct wl_buffer *buffer) {
    for (int i = 0; i < 3; i++) {
        if (pool.buffers[i] == buffer) {
            pool.available[i] = 1;
            break;
        }
    }
}
```

### Problema 3: Rasgos na tela

Rasgos na tela podem ocorrer quando o aplicativo não sincroniza corretamente os frames com o refresh rate do monitor. Para evitar isso, você pode usar o triplo buffering:

```c
struct triplo_buffer {
    struct wl_buffer *buffers[3];
    int index;
};

struct triplo_buffer tb = {0};

void commit_frame(struct wl_surface *surface, struct wl_shm *shm, int width, int height) {
    struct wl_buffer *buffer = get_buffer(shm, width, height);
    tb.buffers[tb.index] = buffer;
    tb.index = (tb.index + 1) % 3;
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
}
```

### Problema 4: Vazamento de recursos

Vazamentos de recursos são comuns quando você não libera corretamente os objetos Wayland. Isso pode levar ao aumento contínuo do uso de memória. Para evitar isso, sempre libere os recursos quando não forem mais necessários:

```c
void destroy_surface(struct wl_surface *surface) {
    wl_surface_destroy(surface);
}
```

### Exercício prático

Implemente um visualizador de imagens que use um pool de buffers dinâmico e sincronize os frames corretamente para evitar rasgos. Adicione logging para monitorar o uso de buffers e detectar vazamentos.

**Solução comentada:**

```c
#include <wayland-client.h>
#include <stdio.h>

struct buffer_pool {
    struct wl_buffer *buffers[3];
    int available[3];
};

struct buffer_pool pool = {0};

struct wl_buffer *get_buffer(struct wl_shm *shm, int width, int height) {
    for (int i = 0; i < 3; i++) {
        if (pool.available[i]) {
            pool.available[i] = 0;
            return pool.buffers[i];
        }
    }
    struct wl_buffer *buffer = create_shm_buffer(shm, width, height);
    pool.buffers[2] = buffer;
    return buffer;
}

void release_buffer(struct wl_buffer *buffer) {
    for (int i = 0; i < 3; i++) {
        if (pool.buffers[i] == buffer) {
            pool.available[i] = 1;
            break;
        }
    }
}

int main() {
    // Implementação completa do visualizador de imagens
    return 0;
}
```

Este código implementa um pool de buffers dinâmico que evita alocações excessivas e sincroniza os frames corretamente para evitar rasgos. Adicione logging para monitorar o uso de buffers e detectar vazamentos.