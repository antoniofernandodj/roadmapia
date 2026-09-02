## Protocolos Wayland: visão geral

Um protocolo Wayland é um contrato entre aplicativos e o compositor, definindo como eles trocam mensagens para criar interfaces gráficas. Diferente do X11, onde tudo passa por um servidor central, no Wayland cada funcionalidade (criar janelas, lidar com entrada, etc.) é um protocolo separado negociado dinamicamente.

### O protocolo central: `wl_display`

Toda conexão Wayland começa com o protocolo base `wl_display`. Veja como estabelecer uma conexão e listar protocolos disponíveis:

```c
#include <wayland-client.h>
#include <stdio.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland\n");
        return 1;
    }

    const struct wl_registry *registry = wl_display_get_registry(display);
    
    printf("Conectado ao compositor Wayland versão %d\n", 
           wl_display_get_version(display));
    
    wl_display_disconnect(display);
    return 0;
}
```
Compile com:
```bash
gcc -o wayland-test wayland-test.c `pkg-config --cflags --libs wayland-client`
```

Saída esperada:
```
Conectado ao compositor Wayland versão 1
```

Erro comum: esquecer de chamar `wl_display_disconnect()`, causando vazamento de recursos. O compositor pode encerrar a conexão abruptamente após algum tempo.

### Protocolos essenciais

1. **wl_compositor**: Cria superfícies básicas para desenho
   ```c
   struct wl_compositor *compositor;
   struct wl_surface *surface = wl_compositor_create_surface(compositor);
   ```

2. **wl_shm**: Compartilhamento de memória para buffers de pixels
   ```c
   struct wl_shm *shm;
   // Cria um buffer compartilhado de 320x240 pixels
   int stride = 320 * 4; // 4 bytes por pixel (RGBA)
   int size = stride * 240;
   int fd = memfd_create("buffer", 0);
   ftruncate(fd, size);
   struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
   struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 
                                                       320, 240, stride, 
                                                       WL_SHM_FORMAT_ARGB8888);
   ```

3. **xdg_shell**: Gerencia janelas (protocolo estável mais comum)
   ```c
   struct xdg_wm_base *wm_base;
   struct xdg_surface *xdg_surface = xdg_wm_base_get_xdg_surface(wm_base, surface);
   struct xdg_toplevel *toplevel = xdg_surface_get_toplevel(xdg_surface);
   ```

### Protocolos estendidos

Os compositors podem oferecer protocolos adicionais via `wl_registry`. Por exemplo, o KWin (do KDE) implementa `org_kde_kwin_idle` para detecção de inatividade:

```c
// No callback de registry.global
if (strcmp(interface, "org_kde_kwin_idle") == 0) {
    struct org_kde_kwin_idle *idle = wl_registry_bind(
        registry, id, &org_kde_kwin_idle_interface, version);
}
```

### Exercício prático

Modifique o exemplo inicial para listar todos os protocolos suportados pelo compositor. Dica: use `wl_registry_add_listener()` e implemente o callback `registry_handle_global`.

**Solução:**

```c
static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t id, const char *interface,
                                  uint32_t version) {
    printf("Protocolo disponível: %s (versão %d)\n", interface, version);
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
};

int main() {
    // ... (código anterior)
    
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display); // Processa mensagens
    
    // ... (limpeza)
}
```

Saída típica no GNOME:
```
Protocolo disponível: wl_compositor (versão 4)
Protocolo disponível: wl_shm (versão 1)
Protocolo disponível: xdg_wm_base (versão 2)
Protocolo disponível: zwp_pointer_constraints_v1 (versão 1)
```