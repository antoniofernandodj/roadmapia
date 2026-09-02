## Desenvolvendo um compositor simples

Um compositor Wayland é o componente central que gerencia a exibição de janelas e superfícies gráficas. Ele coordena como os aplicativos desenham seus conteúdos e como esses conteúdos são apresentados na tela. Para criar um compositor simples, precisamos entender como o Wayland lida com superfícies, buffers e eventos de entrada.

### Estrutura básica de um compositor

Um compositor Wayland precisa lidar com três elementos principais: **superfícies**, **buffers** e **eventos de entrada**. As superfícies são áreas onde os aplicativos desenham seu conteúdo. Os buffers são onde esse conteúdo é armazenado antes de ser exibido. E os eventos de entrada são as interações do usuário, como cliques e movimentos do mouse.

Vamos começar criando um compositor mínimo que exibe uma janela simples. Para isso, utilizaremos a biblioteca `wlroots`, que fornece uma abstração de baixo nível para criar compositores Wayland.

```c
#include <wlr/backend.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_output.h>

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_create();
    struct wlr_backend *backend = wlr_backend_autocreate(display, NULL);
    struct wlr_renderer *renderer = wlr_renderer_autocreate(backend);
    struct wlr_compositor *compositor = wlr_compositor_create(display, renderer);

    if (!backend) {
        fprintf(stderr, "Falha ao criar o backend.\n");
        return 1;
    }

    if (!wlr_backend_start(backend)) {
        fprintf(stderr, "Falha ao iniciar o backend.\n");
        return 1;
    }

    wl_display_run(display);
    wl_display_destroy(display);
    return 0;
}
```

Este código cria um display Wayland, inicializa um backend automático e um renderizador, e finalmente cria um compositor. O backend é responsável por gerenciar os dispositivos gráficos, enquanto o renderizador desenha as superfícies.

### Adicionando uma saída gráfica

Para que nosso compositor funcione, precisamos adicionar uma saída gráfica. Uma saída representa um monitor ou tela onde o conteúdo será exibido. Vamos modificar nosso código para adicionar uma saída e configurá-la para exibir uma cor de fundo.

```c
#include <wlr/types/wlr_output.h>

static void output_frame(struct wlr_output *output) {
    struct wlr_renderer *renderer = output->renderer;
    wlr_output_make_current(output, NULL);
    wlr_renderer_begin(renderer, output->width, output->height);

    float color[4] = {0.2, 0.2, 0.2, 1.0};
    wlr_renderer_clear(renderer, color);

    wlr_renderer_end(renderer);
    wlr_output_swap_buffers(output, NULL, NULL);
}

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_create();
    struct wlr_backend *backend = wlr_backend_autocreate(display, NULL);
    struct wlr_renderer *renderer = wlr_renderer_autocreate(backend);
    struct wlr_compositor *compositor = wlr_compositor_create(display, renderer);

    struct wlr_output *output = wlr_output_create(backend);
    wlr_output_init_render(output, renderer);
    wlr_output_set_mode(output, wlr_output_preferred_mode(output));
    wlr_output_create_global(output);

    output->frame.notify = output_frame;
    wlr_output_enable(output, true);

    if (!wlr_backend_start(backend)) {
        fprintf(stderr, "Falha ao iniciar o backend.\n");
        return 1;
    }

    wl_display_run(display);
    wl_display_destroy(display);
    return 0;
}
```

Aqui, criamos uma saída gráfica e configuramos uma função de callback `output_frame` que será chamada sempre que a saída precisar renderizar um novo quadro. Essa função define uma cor de fundo e desenha na tela.

### Lidando com eventos de entrada

Para tornar nosso compositor interativo, precisamos lidar com eventos de entrada, como movimentos do mouse e pressionamentos de tecla. Vamos adicionar um listener para eventos de entrada e imprimir uma mensagem quando o mouse se mover.

```c
#include <wlr/types/wlr_input_device.h>

static void handle_pointer_motion(struct wl_listener *listener, void *data) {
    struct wlr_event_pointer_motion *event = data;
    printf("Mouse movido para (%f, %f)\n", event->delta_x, event->delta_y);
}

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_create();
    struct wlr_backend *backend = wlr_backend_autocreate(display, NULL);
    struct wlr_renderer *renderer = wlr_renderer_autocreate(backend);
    struct wlr_compositor *compositor = wlr_compositor_create(display, renderer);

    struct wlr_output *output = wlr_output_create(backend);
    wlr_output_init_render(output, renderer);
    wlr_output_set_mode(output, wlr_output_preferred_mode(output));
    wlr_output_create_global(output);

    output->frame.notify = output_frame;
    wlr_output_enable(output, true);

    struct wl_listener pointer_motion_listener = {.notify = handle_pointer_motion};
    wlr_signal_add(&backend->events.new_input, &pointer_motion_listener);

    if (!wlr_backend_start(backend)) {
        fprintf(stderr, "Falha ao iniciar o backend.\n");
        return 1;
    }

    wl_display_run(display);
    wl_display_destroy(display);
    return 0;
}
```

Neste código, adicionamos um listener para eventos de movimento do mouse. Quando o mouse se move, a função `handle_pointer_motion` é chamada, e as coordenadas do movimento são impressas no terminal.

### Exercício: Adicionando uma janela simples

Modifique o compositor para exibir uma janela simples que pode ser movida pelo mouse. Dica: você precisará criar uma superfície e lidar com eventos de clique e arrastar.

**Solução:**

```c
#include <wlr/types/wlr_xdg_shell.h>

static void handle_new_surface(struct wl_listener *listener, void *data) {
    struct wlr_xdg_surface *xdg_surface = data;
    printf("Nova superfície criada\n");
}

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_create();
    struct wlr_backend *backend = wlr_backend_autocreate(display, NULL);
    struct wlr_renderer *renderer = wlr_renderer_autocreate(backend);
    struct wlr_compositor *compositor = wlr_compositor_create(display, renderer);

    struct wlr_output *output = wlr_output_create(backend);
    wlr_output_init_render(output, renderer);
    wlr_output_set_mode(output, wlr_output_preferred_mode(output));
    wlr_output_create_global(output);

    output->frame.notify = output_frame;
    wlr_output_enable(output, true);

    struct wl_listener pointer_motion_listener = {.notify = handle_pointer_motion};
    wlr_signal_add(&backend->events.new_input, &pointer_motion_listener);

    struct wlr_xdg_shell *xdg_shell = wlr_xdg_shell_create(display);
    struct wl_listener new_surface_listener = {.notify = handle_new_surface};
    wlr_signal_add(&xdg_shell->events.new_surface, &new_surface_listener);

    if (!wlr_backend_start(backend)) {
        fprintf(stderr, "Falha ao iniciar o backend.\n");
        return 1;
    }

    wl_display_run(display);
    wl_display_destroy(display);
    return 0;
}
```

Nesta solução, adicionamos um listener para novas superfícies criadas pelos aplicativos. Quando uma nova superfície é criada, uma mensagem é impressa no terminal. Isso é o primeiro passo para exibir janelas em nosso compositor.