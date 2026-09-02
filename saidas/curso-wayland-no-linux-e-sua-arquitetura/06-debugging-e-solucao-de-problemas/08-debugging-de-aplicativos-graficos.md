## Debugging de aplicativos gráficos

Quando um aplicativo Wayland falha silenciosamente - sem mensagens de erro visíveis, mas também sem renderizar conteúdo - o problema geralmente está na negociação inicial entre cliente e compositor. Vamos debugar um caso real onde uma janela abre, mas permanece vazia.

Considere este fragmento de código que deveria mostrar uma janela azul:

```c
#include <wayland-client.h>
#include <stdlib.h>

struct wl_compositor *compositor = NULL;
struct wl_surface *surface = NULL;

static void registry_handle_global(void *data, struct wl_registry *registry,
        uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name,
            &wl_compositor_interface, 1);
    }
}

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    
    static const struct wl_registry_listener registry_listener = {
        .global = registry_handle_global
    };
    
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);
    
    surface = wl_compositor_create_surface(compositor);
    // Falta: criar buffer e anexar à surface
    wl_surface_commit(surface);
    
    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }
}
```

Ao executar com `WAYLAND_DEBUG=1`, vemos esta saída crítica:

```
[1732964.234]  -> wl_display@1.get_registry(new id wl_registry@2)
[1732964.256]  -> wl_display@1.sync(new id wl_callback@3)
[1732964.289] wl_registry@2.global(1, "wl_compositor", 4)
[1732964.301]  -> wl_registry@2.bind(1, "wl_compositor", 1, new id wl_compositor@4)
[1732964.345]  -> wl_compositor@4.create_surface(new id wl_surface@5)
[1732964.367]  -> wl_surface@5.commit()
```

O erro está na ausência de dois passos críticos:
1. Criar um buffer gráfico (`wl_buffer`) com conteúdo
2. Anexar o buffer à surface antes do commit

Vamos corrigir adicionando o código para criar e gerenciar um buffer shared memory:

```c
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

// Adicionar após wl_compositor_create_surface
struct wl_shm *shm = NULL;
struct wl_shm_pool *pool = NULL;
struct wl_buffer *buffer = NULL;

// Na registry_handle_global, adicionar:
if (strcmp(interface, "wl_shm") == 0) {
    shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
}

// Criar buffer compartilhado
int stride = 256 * 4; // 256px largura, 4 bytes por pixel
int size = 256 * 256 * 4; // 256x256 RGBA
int fd = memfd_create("buffer", 0);
ftruncate(fd, size);

pool = wl_shm_create_pool(shm, fd, size);
buffer = wl_shm_pool_create_buffer(pool, 0, 256, 256, stride, WL_SHM_FORMAT_XRGB8888);
wl_shm_pool_destroy(pool);
close(fd);

// Preencher buffer com azul
uint32_t *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
for (int i = 0; i < 256 * 256; i++) {
    data[i] = 0xFF0000FF; // ARGB: Azul sólido
}
munmap(data, size);

// Anexar e commitar
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_commit(surface);
```

Agora, o debug mostra a sequência completa:

```
[1732987.423]  -> wl_shm_pool@6.create_buffer(0, 256, 256, 1024, 0)
[1732987.456]  -> wl_surface@5.attach(wl_buffer@7, 0, 0)
[1732987.478]  -> wl_surface@5.damage(0, 0, 256, 256)
[1732987.489]  -> wl_surface@5.commit()
```

### Erro comum: Listeners ausentes

Um padrão frequente é o aplicativo não responder a eventos de entrada. Considere este erro no log:

```
[1732998.123] wl_seat@8.capabilities(3)  # WL_SEAT_CAPABILITY_POINTER|KEYBOARD
[1732998.134]  -> wl_seat@8.get_pointer(new id wl_pointer@9)
```

Mas nenhum evento subsequente aparece. Isso ocorre quando falta registrar o listener:

```c
struct wl_pointer *pointer = NULL;

static void pointer_handle_enter(void *data, struct wl_pointer *pointer,
        uint32_t serial, struct wl_surface *surface,
        wl_fixed_t sx, wl_fixed_t sy) {
    printf("Pointer entered surface\n");
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_handle_enter,
    // Outros callbacks necessários
};

// Após wl_seat_get_pointer
wl_pointer_add_listener(pointer, &pointer_listener, NULL);
```

### Exercício de debugging

Dado este erro no log do cliente:

```
[1733012.567] error wl_display@1: error 3 (invalid object): invalid wl_surface@5
```

**Problema**: O código tenta usar uma surface após destruir o compositor. A sequência foi:
1. `wl_compositor_destroy(compositor)`
2. `wl_surface_commit(surface)` (usando surface criada pelo compositor destruído)

**Solução**: Reordenar a destruição de objetos na ordem inversa de criação:

```c
wl_surface_destroy(surface);  // Primeiro surfaces
wl_compositor_destroy(compositor);  // Depois globais
wl_registry_destroy(registry);
wl_display_disconnect(display);
```