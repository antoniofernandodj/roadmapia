## Otimização extrema de desempenho

Quando você desenvolve aplicativos Wayland, especialmente aqueles que exigem alto desempenho gráfico, como jogos ou aplicações de realidade virtual, é crucial entender como o Wayland lida com buffers, superfícies e eventos de entrada. A otimização começa com o entendimento de como o compositor gerencia esses elementos e como você pode influenciar esse processo.

### Reduzindo a latência de renderização

Um dos principais desafios em aplicações gráficas é minimizar a latência entre o momento em que um evento de entrada ocorre e o momento em que o frame correspondente é exibido na tela. No Wayland, isso pode ser alcançado através do uso eficiente de buffers e da sincronização com o compositor.

Considere o seguinte exemplo de código que cria uma superfície e desenha um quadrado preto:

```c
#include <wayland-client.h>
#include <cairo.h>
#include <stdio.h>
#include <unistd.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;

static void draw_frame(void *data) {
    struct wl_buffer *buffer = (struct wl_buffer *)data;
    cairo_surface_t *cairo_surface = cairo_image_surface_create_for_data(
        cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, 256),
        CAIRO_FORMAT_ARGB32, 256, 256, cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, 256));
    cairo_t *cr = cairo_create(cairo_surface);

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_paint(cr);

    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_damage(surface, 0, 0, 256, 256);
    wl_surface_commit(surface);

    cairo_destroy(cr);
    cairo_surface_destroy(cairo_surface);
}

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    compositor = wl_compositor_create(display);
    surface = wl_compositor_create_surface(compositor);

    struct wl_buffer *buffer = wl_shm_create_buffer(display, 256, 256, WL_SHM_FORMAT_ARGB8888);
    draw_frame(buffer);

    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }

    wl_buffer_destroy(buffer);
    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wl_display_disconnect(display);

    return 0;
}
```

Este código cria uma superfície simples e desenha um quadrado preto. No entanto, ele não é otimizado para latência. Para melhorar o desempenho, você pode usar o protocolo `wp_presentation` para sincronizar a apresentação de frames com o refresh rate do monitor.

### Uso de `wp_presentation` para sincronização de frames

O protocolo `wp_presentation` permite que você seja notificado quando um frame foi exibido na tela, o que é crucial para sincronizar a renderização com o refresh rate do monitor. Aqui está como você pode integrar esse protocolo:

```c
#include <wayland-client.h>
#include <cairo.h>
#include <stdio.h>
#include <unistd.h>
#include <wayland-presentation-timing-client-protocol.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wp_presentation *presentation;

static void handle_presented(void *data, struct wp_presentation *wp_presentation,
                            uint32_t tv_sec_hi, uint32_t tv_sec_lo, uint32_t tv_nsec,
                            uint32_t refresh, uint32_t seq_hi, uint32_t seq_lo,
                            uint32_t flags) {
    printf("Frame apresentado\n");
}

static const struct wp_presentation_listener presentation_listener = {
    .presented = handle_presented,
};

static void draw_frame(void *data) {
    struct wl_buffer *buffer = (struct wl_buffer *)data;
    cairo_surface_t *cairo_surface = cairo_image_surface_create_for_data(
        cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, 256),
        CAIRO_FORMAT_ARGB32, 256, 256, cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, 256));
    cairo_t *cr = cairo_create(cairo_surface);

    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_paint(cr);

    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_damage(surface, 0, 0, 256, 256);
    wl_surface_commit(surface);

    wp_presentation_feedback(presentation, surface, buffer, &presentation_listener, NULL);

    cairo_destroy(cr);
    cairo_surface_destroy(cairo_surface);
}

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    compositor = wl_compositor_create(display);
    surface = wl_compositor_create_surface(compositor);
    presentation = wp_presentation_create(display);

    struct wl_buffer *buffer = wl_shm_create_buffer(display, 256, 256, WL_SHM_FORMAT_ARGB8888);
    draw_frame(buffer);

    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }

    wl_buffer_destroy(buffer);
    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wp_presentation_destroy(presentation);
    wl_display_disconnect(display);

    return 0;
}
```

Este código agora usa `wp_presentation` para receber notificações quando um frame é exibido na tela, permitindo uma sincronização mais precisa e reduzindo a latência.

### Exercício

Crie um aplicativo simples que desenha um círculo vermelho na tela e utiliza `wp_presentation` para sincronizar a renderização com o refresh rate do monitor. Meça a latência antes e depois da implementação do `wp_presentation` para verificar a melhoria no desempenho.

**Solução:**

```c
#include <wayland-client.h>
#include <cairo.h>
#include <stdio.h>
#include <unistd.h>
#include <wayland-presentation-timing-client-protocol.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wp_presentation *presentation;

static void handle_presented(void *data, struct wp_presentation *wp_presentation,
                            uint32_t tv_sec_hi, uint32_t tv_sec_lo, uint32_t tv_nsec,
                            uint32_t refresh, uint32_t seq_hi, uint32_t seq_lo,
                            uint32_t flags) {
    printf("Frame apresentado\n");
}

static const struct wp_presentation_listener presentation_listener = {
    .presented = handle_presented,
};

static void draw_frame(void *data) {
    struct wl_buffer *buffer = (struct wl_buffer *)data;
    cairo_surface_t *cairo_surface = cairo_image_surface_create_for_data(
        cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, 256),
        CAIRO_FORMAT_ARGB32, 256, 256, cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, 256));
    cairo_t *cr = cairo_create(cairo_surface);

    cairo_set_source_rgb(cr, 1, 0, 0);
    cairo_arc(cr, 128, 128, 64, 0, 2 * M_PI);
    cairo_fill(cr);

    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_damage(surface, 0, 0, 256, 256);
    wl_surface_commit(surface);

    wp_presentation_feedback(presentation, surface, buffer, &presentation_listener, NULL);

    cairo_destroy(cr);
    cairo_surface_destroy(cairo_surface);
}

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    compositor = wl_compositor_create(display);
    surface = wl_compositor_create_surface(compositor);
    presentation = wp_presentation_create(display);

    struct wl_buffer *buffer = wl_shm_create_buffer(display, 256, 256, WL_SHM_FORMAT_ARGB8888);
    draw_frame(buffer);

    while (wl_display_dispatch(display) != -1) {
        // Loop de eventos
    }

    wl_buffer_destroy(buffer);
    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wp_presentation_destroy(presentation);
    wl_display_disconnect(display);

    return 0;
}
```

Este código desenha um círculo vermelho na tela e usa `wp_presentation` para sincronizar a renderização com o refresh rate do monitor, reduzindo a latência e melhorando o desempenho.