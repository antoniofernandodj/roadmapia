## Trabalhando com protocolos estendidos

Wayland é um protocolo minimalista por design, mas muitas vezes precisamos de funcionalidades específicas que não estão incluídas no protocolo base. É aí que entram os **protocolos estendidos**. Eles permitem adicionar novas interfaces e comportamentos ao Wayland, sem modificar o núcleo do protocolo.

Imagine que você está desenvolvendo um aplicativo que precisa de suporte para redimensionamento de janelas com bordas arrastáveis. O protocolo base do Wayland não oferece isso diretamente, mas podemos usar o protocolo estendido `xdg_shell` para implementar essa funcionalidade.

### Como funcionam os protocolos estendidos?

Protocolos estendidos são definidos em arquivos XML, que descrevem novas interfaces e suas mensagens. Esses arquivos são processados por ferramentas como `wayland-scanner` para gerar código C que pode ser usado em seu aplicativo.

Vamos criar um exemplo simples usando o protocolo `xdg_shell`. Primeiro, precisamos incluir os cabeçalhos gerados a partir do arquivo XML:

```c
#include <wayland-client.h>
#include <xdg-shell.h>
```

Agora, vamos criar uma janela básica com suporte para redimensionamento:

```c
#include <wayland-client.h>
#include <xdg-shell.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct xdg_wm_base *wm_base = NULL;
struct wl_surface *surface = NULL;
struct xdg_surface *xdg_surface = NULL;
struct xdg_toplevel *toplevel = NULL;

static void handle_configure(void *data, struct xdg_toplevel *toplevel,
                            int32_t width, int32_t height,
                            struct wl_array *states) {
    printf("Janela redimensionada para %dx%d\n", width, height);
}

static const struct xdg_toplevel_listener toplevel_listener = {
    .configure = handle_configure,
};

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland.\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !wm_base) {
        fprintf(stderr, "Compositor ou xdg_wm_base não disponíveis.\n");
        return 1;
    }

    surface = wl_compositor_create_surface(compositor);
    xdg_surface = xdg_wm_base_get_xdg_surface(wm_base, surface);
    toplevel = xdg_surface_get_toplevel(xdg_surface);
    xdg_toplevel_add_listener(toplevel, &toplevel_listener, NULL);
    xdg_toplevel_set_title(toplevel, "Janela Wayland com xdg_shell");
    wl_surface_commit(surface);

    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }

    xdg_toplevel_destroy(toplevel);
    xdg_surface_destroy(xdg_surface);
    wl_surface_destroy(surface);
    wl_display_disconnect(display);

    return 0;
}
```

Neste exemplo, criamos uma janela usando o protocolo `xdg_shell`. A função `handle_configure` é chamada sempre que a janela é redimensionada, permitindo que você ajuste o conteúdo da janela conforme necessário.

### Erros comuns ao usar protocolos estendidos

Um erro comum é esquecer de registrar os listeners para as novas interfaces. Se você não registrar o listener para `xdg_toplevel`, por exemplo, o callback `handle_configure` nunca será chamado, e você não receberá eventos de redimensionamento.

Outro erro comum é não verificar se o protocolo estendido está disponível no ambiente. Nem todos os compositores Wayland suportam todos os protocolos estendidos. Você pode verificar isso durante o registro de globais:

```c
static void registry_handle_global(void *data, struct wl_registry *registry,
                                   uint32_t name, const char *interface,
                                   uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    } else if (strcmp(interface, "xdg_wm_base") == 0) {
        wm_base = wl_registry_bind(registry, name, &xdg_wm_base_interface, 1);
    }
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
};
```

Se `wm_base` for `NULL` após o registro de globais, significa que o protocolo `xdg_shell` não está disponível no compositor atual.

### Exercício: Implementando um protocolo estendido

Modifique o exemplo acima para usar o protocolo `zwlr_layer_shell_v1`, que permite criar janelas em camadas (layers). Crie uma janela que permaneça sempre visível, mesmo quando outras janelas estão em tela cheia.

**Solução:**

```c
#include <wayland-client.h>
#include <wlr-layer-shell-unstable-v1-client-protocol.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct zwlr_layer_shell_v1 *layer_shell = NULL;
struct wl_surface *surface = NULL;
struct zwlr_layer_surface_v1 *layer_surface = NULL;

static void handle_configure(void *data, struct zwlr_layer_surface_v1 *layer_surface,
                            uint32_t serial, uint32_t width, uint32_t height) {
    printf("Janela de camada configurada para %dx%d\n", width, height);
    zwlr_layer_surface_v1_ack_configure(layer_surface, serial);
}

static const struct zwlr_layer_surface_v1_listener layer_surface_listener = {
    .configure = handle_configure,
};

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland.\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !layer_shell) {
        fprintf(stderr, "Compositor ou layer_shell não disponíveis.\n");
        return 1;
    }

    surface = wl_compositor_create_surface(compositor);
    layer_surface = zwlr_layer_shell_v1_get_layer_surface(layer_shell, surface, NULL, ZWLR_LAYER_SHELL_V1_LAYER_TOP, "layer-shell");
    zwlr_layer_surface_v1_add_listener(layer_surface, &layer_surface_listener, NULL);
    zwlr_layer_surface_v1_set_size(layer_surface, 200, 200);
    zwlr_layer_surface_v1_set_anchor(layer_surface, ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP | ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT);
    wl_surface_commit(surface);

    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }

    zwlr_layer_surface_v1_destroy(layer_surface);
    wl_surface_destroy(surface);
    wl_display_disconnect(display);

    return 0;
}
```

Neste exemplo, criamos uma janela de camada que permanece sempre visível, mesmo quando outras janelas estão em tela cheia. Isso é útil para aplicativos como painéis ou barras de status.