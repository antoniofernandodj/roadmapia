## Solução de problemas de arquitetura

Quando um cliente Wayland falha ao se conectar ao compositor, a mensagem de erro típica é:

```
error: failed to connect to wayland display: No such file or directory
```

Isso ocorre quando o caminho do socket Wayland padrão (`/run/user/<UID>/wayland-0`) não existe. Para diagnosticar:

1. Verifique se o compositor está em execução com `ps aux | grep compositor`
2. Confira as permissões do socket com `ls -l /run/user/$(id -u)/wayland-*`
3. Teste manualmente a conexão usando `weston-info`

Se o problema persistir, crie um cliente de teste mínimo:

```c
#include <stdio.h>
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        perror("wl_display_connect");
        return 1;
    }
    printf("Conectado ao compositor Wayland\n");
    wl_display_disconnect(display);
    return 0;
}
```

Compile com:
```bash
gcc wayland_test.c -o wayland_test -lwayland-client
```

### Problema: Falha na criação de superfície

Um erro comum ao criar superfícies é esquecer de vincular o registry ao compositor:

```c
struct wl_compositor *compositor = NULL;

static void registry_handle_global(void *data, struct wl_registry *registry,
    uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name,
            &wl_compositor_interface, 1);
    }
}
```

A mensagem de erro típica seria:
```
error: compositor not available
```

Solução: Implemente o listener completo e verifique a versão do protocolo:

```c
static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
    .global_remove = registry_handle_global_remove,
};

wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display); // Espera a resposta do compositor
```

### Problema: Vazamento de recursos

Wayland exige liberação explícita de recursos. O erro mais sutil ocorre quando superfícies não são destruídas:

```c
struct wl_surface *surface = wl_compositor_create_surface(compositor);
// ... uso da superfície ...
wl_surface_destroy(surface); // Obrigatório!
```

Para detectar vazamentos, use `WAYLAND_DEBUG=1`:
```bash
WAYLAND_DEBUG=1 ./meu_programa
```

Isso mostrará mensagens como:
```
[17123456] wl_surface@3.destroy() // OK
[17123457] wl_surface@4 leaked    // ERRO
```

### Problema: Sincronização de frames

Animações sem sincronização adequada causam tearing. O correto é usar `wl_surface_commit` com callbacks:

```c
static void frame_callback(void *data, struct wl_callback *cb, uint32_t time) {
    // Atualiza conteúdo aqui
    wl_callback_destroy(cb);
    cb = wl_surface_frame(surface);
    wl_callback_add_listener(cb, &frame_listener, NULL);
    wl_surface_commit(surface);
}

static const struct wl_callback_listener frame_listener = {
    .done = frame_callback,
};
```

### Exercício: Corrija o código com vazamento

O seguinte código vaza recursos:

```c
struct wl_display *display = wl_display_connect(NULL);
struct wl_registry *registry = wl_display_get_registry(display);
wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display);

struct wl_surface *surface = wl_compositor_create_surface(compositor);

// ... programa continua ...
```

Solução corrigida:
```c
struct wl_display *display = wl_display_connect(NULL);
struct wl_registry *registry = wl_display_get_registry(display);
wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display);

struct wl_surface *surface = wl_compositor_create_surface(compositor);

// Ao final do programa:
wl_surface_destroy(surface);
wl_registry_destroy(registry);
wl_display_disconnect(display);
```