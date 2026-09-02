## Solução de problemas com clientes

Um cliente Wayland que congela durante a interação ou fecha sem mensagem de erro apresenta um desafio típico. Vamos resolver um caso real onde um aplicativo gráfico falha ao processar eventos de teclado, demonstrando como isolar e corrigir o problema.

Considere um cliente mínimo que abre uma janela mas não responde a entradas:

```c
#include <wayland-client.h>
#include <stdlib.h>

struct wl_display *display = NULL;
struct wl_registry *registry = NULL;
struct wl_compositor *compositor = NULL;
struct wl_surface *surface = NULL;
struct wl_seat *seat = NULL;

static void keyboard_keymap(void *data, struct wl_keyboard *keyboard,
                           uint32_t format, int fd, uint32_t size) {
    // Implementação vazia - erro intencional
}

static const struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
};

static void seat_capabilities(void *data, struct wl_seat *seat,
                             uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_KEYBOARD) {
        struct wl_keyboard *keyboard = wl_seat_get_keyboard(seat);
        wl_keyboard_add_listener(keyboard, &keyboard_listener, NULL);
    }
}

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    
    wl_display_roundtrip(display);
    return 0;
}
```

Ao executar com `WAYLAND_DEBUG=1`, observamos a sequência crítica:

```
[2952018.029]  -> wl_display@1.get_registry(new id wl_registry@2)
[2952018.029]  -> wl_display@1.sync(new id wl_callback@3)
[2952018.029] wl_display@1.error(wl_registry@2, 0, "no seat global")
```

O erro "no seat global" indica que o compositor não anunciou a interface `wl_seat`, essencial para entrada. Isso ocorre frequentemente quando:

1. O listener do registry está incompleto, não capturando todas as interfaces globais
2. O compositor está configurado sem suporte a entrada (caso de servidores headless)

A correção envolve verificar as capacidades antes de usar o teclado:

```c
static void registry_global(void *data, struct wl_registry *registry,
                           uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    } else if (strcmp(interface, "wl_seat") == 0) {
        seat = wl_registry_bind(registry, name, &wl_seat_interface, 1);
        wl_seat_add_listener(seat, &seat_listener, NULL);
    }
}
```

Outro problema comum ocorre quando o cliente tenta usar um objeto após sua destruição. Considere este erro típico:

```
[2952018.030] wl_display@1.error(wl_keyboard@4, 1, "invalid object")
```

Isso indica que o cliente tentou enviar uma mensagem para um objeto já destruído. A correção envolve:

1. Manter referências consistentes
2. Implementar handlers para eventos de destruição
3. Verificar ponteiros antes do uso

```c
static void keyboard_release(void *data, struct wl_keyboard *keyboard) {
    wl_keyboard_destroy(keyboard);
}

static const struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
    .release = keyboard_release,
};
```

Para debugar vazamentos de recursos, combine `WAYLAND_DEBUG` com `valgrind`:

```bash
WAYLAND_DEBUG=1 valgrind --leak-check=full ./client
```

Um relatório típico mostra vazamentos:

```
==12345== 32 bytes in 1 blocks are definitely lost in loss record 1 of 2
==12345==    at 0x483B7F3: malloc (vg_replace_malloc.c:307)
==12345==    by 0x48A2A5A: wl_proxy_marshal_constructor (wayland-client.c:692)
==12345==    by 0x4012AA: main (client.c:42)
```

O stacktrace aponta para a linha onde o objeto foi criado mas não destruído. A correção envolve chamar as funções `wl_*_destroy` correspondentes no final do programa.

**Exercício:** Um cliente Wayland falha com a mensagem "error wl_surface@3: error 3: invalid size for buffer". Analise o problema e proponha uma solução.

*Solução:* O erro ocorre quando as dimensões do buffer anexado à superfície não correspondem às esperadas pelo compositor. Verifique:

1. As dimensões do buffer com `wl_buffer_get_size()`
2. A escala da superfície com `wl_surface_set_buffer_scale()`
3. A transformação aplicada com `wl_surface_set_buffer_transform()`

Correção típica:
```c
wl_surface_set_buffer_scale(surface, 2); // Para displays HiDPI
wl_surface_commit(surface);
```