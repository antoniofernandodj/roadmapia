## Criando e gerenciando janelas em Wayland

Criar uma janela em Wayland envolve a criação de uma superfície (`wl_surface`) e sua promoção para uma janela toplevel. Vamos começar com um exemplo mínimo que cria uma janela vazia e a mantém aberta até que o usuário a feche.

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

static void registry_handle_global(void *data, struct wl_registry *registry,
                                   uint32_t name, const char *interface,
                                   uint32_t version) {
    struct wl_compositor **compositor = data;
    if (strcmp(interface, "wl_compositor") == 0) {
        *compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

static const struct wl_registry_listener registry_listener = {
    registry_handle_global
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_compositor *compositor = NULL;

    wl_registry_add_listener(registry, &registry_listener, &compositor);
    wl_display_roundtrip(display);

    if (!compositor) {
        fprintf(stderr, "Interface wl_compositor não encontrada.\n");
        return 1;
    }

    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    if (!surface) {
        fprintf(stderr, "Falha ao criar superfície.\n");
        return 1;
    }

    struct wl_shell *shell = NULL;
    struct wl_shell_surface *shell_surface = NULL;

    wl_display_roundtrip(display);

    shell = wl_registry_bind(registry, 1, &wl_shell_interface, 1);
    shell_surface = wl_shell_get_shell_surface(shell, surface);
    wl_shell_surface_set_toplevel(shell_surface);

    while (wl_display_dispatch(display) != -1) {
        // Mantém a janela aberta
    }

    wl_shell_surface_destroy(shell_surface);
    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);

    return 0;
}
```

Este código segue os seguintes passos:

1. Conecta ao compositor Wayland usando `wl_display_connect`.
2. Obtém o registro global e escuta por interfaces globais, em particular `wl_compositor`.
3. Cria uma superfície usando `wl_compositor_create_surface`.
4. Promove a superfície para uma janela toplevel usando `wl_shell_surface_set_toplevel`.
5. Entra em um loop de eventos para manter a janela aberta.

Se você tentar compilar este código sem linkar contra `libwayland-client`, receberá o seguinte erro:

```
undefined reference to `wl_display_connect'
```

Para corrigir isso, certifique-se de linkar corretamente:

```bash
gcc -o wayland_window wayland_window.c -lwayland-client
```

Ao executar o programa, uma janela vazia aparecerá na tela. A janela não terá conteúdo, mas estará visível e responderá a eventos básicos como fechamento.

### Erro comum: Falha ao criar a superfície

Se você esquecer de chamar `wl_display_roundtrip` após registrar o listener, o compositor pode não ter tempo suficiente para anunciar as interfaces globais. Isso resultará em `compositor` sendo `NULL`, e o programa falhará ao tentar criar a superfície:

```
Falha ao criar superfície.
```

A correção é garantir que `wl_display_roundtrip` seja chamado após registrar o listener, como mostrado no exemplo.

### Exercício

Modifique o exemplo acima para criar uma janela com um título personalizado. Dica: Use `wl_shell_surface_set_title` para definir o título da janela.

**Solução:**

```c
wl_shell_surface_set_title(shell_surface, "Minha Janela Wayland");
```

Adicione esta linha após `wl_shell_surface_set_toplevel`. Agora, ao executar o programa, a janela exibirá o título "Minha Janela Wayland".