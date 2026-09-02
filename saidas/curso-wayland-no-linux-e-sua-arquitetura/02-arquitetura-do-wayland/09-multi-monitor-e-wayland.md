## Multi-monitor e Wayland

Em sistemas multi-monitor, o Wayland oferece uma abordagem moderna e eficiente para gerenciar múltiplas telas, diferindo significativamente do modelo tradicional do X11. No X11, o gerenciamento de múltiplos monitores era feito através de extensões como XRandR, que permitia configurar e redimensionar monitores dinamicamente. No entanto, essa abordagem era complexa e propensa a problemas de sincronização e latência.

No Wayland, o compositor é o responsável por gerenciar os monitores e suas configurações. Ele expõe interfaces globais que os clientes podem usar para descobrir e interagir com os monitores conectados. Vamos explorar como isso funciona na prática.

### Descobrindo monitores com `wl_output`

O protocolo Wayland fornece a interface `wl_output`, que permite aos clientes descobrir informações sobre os monitores conectados. Cada monitor é representado por um objeto `wl_output`, que fornece detalhes como resolução, taxa de atualização e posição física.

Aqui está um exemplo de como um cliente pode listar os monitores disponíveis:

```c
#include <wayland-client.h>
#include <stdio.h>

static void handle_output_geometry(void *data, struct wl_output *wl_output,
                                   int x, int y, int physical_width, int physical_height,
                                   int subpixel, const char *make, const char *model,
                                   int transform) {
    printf("Monitor: %s %s\n", make, model);
    printf("Posição: (%d, %d)\n", x, y);
    printf("Resolução física: %dx%d mm\n", physical_width, physical_height);
}

static void handle_output_mode(void *data, struct wl_output *wl_output,
                               uint32_t flags, int width, int height, int refresh) {
    if (flags & WL_OUTPUT_MODE_CURRENT) {
        printf("Resolução: %dx%d\n", width, height);
        printf("Taxa de atualização: %d Hz\n", refresh);
    }
}

static const struct wl_output_listener output_listener = {
    .geometry = handle_output_geometry,
    .mode = handle_output_mode,
};

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    wl_display_disconnect(display);
    return 0;
}
```

### Posicionamento de janelas em monitores específicos

Em um ambiente multi-monitor, é comum que um cliente deseje posicionar uma janela em um monitor específico. No Wayland, isso é feito através da superfície (`wl_surface`) e da interface `wl_output`. O cliente pode criar uma superfície e associá-la a um monitor específico usando as coordenadas fornecidas pelo `wl_output`.

Aqui está um exemplo de como posicionar uma janela em um monitor específico:

```c
struct wl_surface *surface = wl_compositor_create_surface(compositor);
struct wl_shell_surface *shell_surface = wl_shell_get_shell_surface(shell, surface);

wl_shell_surface_set_toplevel(shell_surface);

// Suponha que temos as coordenadas do monitor desejado
int monitor_x = 1920; // Segundo monitor à direita
int monitor_y = 0;

wl_shell_surface_set_fullscreen(shell_surface, WL_SHELL_SURFACE_FULLSCREEN_METHOD_DEFAULT, 0, NULL);
wl_surface_commit(surface);
```

### Erro comum: Falha ao posicionar janelas

Um erro comum ao trabalhar com multi-monitor no Wayland é não considerar as coordenadas corretas ao posicionar janelas. Se o cliente tentar posicionar uma janela fora dos limites dos monitores disponíveis, o compositor pode simplesmente ignorar a solicitação ou reposicionar a janela dentro dos limites válidos.

```c
// Tentando posicionar uma janela fora dos limites dos monitores
wl_shell_surface_set_position(shell_surface, 3000, 0);
wl_surface_commit(surface);
```

Neste caso, o compositor pode reposicionar a janela para o monitor mais próximo ou ignorar a solicitação completamente. É importante sempre verificar as coordenadas dos monitores antes de tentar posicionar janelas.

### Exercício: Descobrir e posicionar janelas em monitores específicos

Escreva um programa Wayland que lista todos os monitores conectados e posiciona uma janela no segundo monitor. Verifique se o programa funciona corretamente mesmo quando o segundo monitor está desconectado.

**Solução:**

```c
#include <wayland-client.h>
#include <stdio.h>

struct Monitor {
    int x, y;
    int width, height;
};

static struct Monitor monitors[2];
static int monitor_count = 0;

static void handle_output_geometry(void *data, struct wl_output *wl_output,
                                   int x, int y, int physical_width, int physical_height,
                                   int subpixel, const char *make, const char *model,
                                   int transform) {
    if (monitor_count < 2) {
        monitors[monitor_count].x = x;
        monitors[monitor_count].y = y;
    }
}

static void handle_output_mode(void *data, struct wl_output *wl_output,
                               uint32_t flags, int width, int height, int refresh) {
    if (flags & WL_OUTPUT_MODE_CURRENT && monitor_count < 2) {
        monitors[monitor_count].width = width;
        monitors[monitor_count].height = height;
        monitor_count++;
    }
}

static const struct wl_output_listener output_listener = {
    .geometry = handle_output_geometry,
    .mode = handle_output_mode,
};

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (monitor_count > 1) {
        printf("Posicionando janela no segundo monitor: (%d, %d)\n", monitors[1].x, monitors[1].y);
        // Código para criar e posicionar a janela no segundo monitor
    } else {
        printf("Segundo monitor não encontrado\n");
    }

    wl_display_disconnect(display);
    return 0;
}
```

Este programa descobre os monitores conectados e, se houver um segundo monitor, posiciona uma janela nele. Se o segundo monitor não estiver disponível, ele informa ao usuário.