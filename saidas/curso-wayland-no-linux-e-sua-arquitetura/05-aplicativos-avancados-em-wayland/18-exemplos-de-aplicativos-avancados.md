## Exemplos de aplicativos avançados

### Editor de Texto com Renderização Híbrida

Um editor de texto moderno no Wayland precisa combinar renderização rápida de texto com elementos UI complexos. Veja como implementar um buffer compartilhado com Cairo para texto e GTK para widgets:

```c
#include <gtk/gtk.h>
#include <cairo.h>
#include <wayland-client.h>

struct app_state {
    GtkWidget *window;
    cairo_surface_t *text_surface;
    int width, height;
};

static gboolean on_draw(GtkWidget *widget, cairo_t *cr, gpointer data) {
    struct app_state *state = data;
    
    // Renderização de texto via Cairo
    cairo_set_source_surface(cr, state->text_surface, 0, 0);
    cairo_paint(cr);
    
    // Overlay de widgets GTK
    gtk_render_frame(gtk_widget_get_style_context(widget),
                    cr,
                    10, 10, 100, 30);
    return FALSE;
}

int main(int argc, char **argv) {
    gtk_init(&argc, &argv);
    
    struct app_state state = {0};
    state.width = 800;
    state.height = 600;
    
    // Criar superfície Cairo para texto
    state.text_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32,
                                                  state.width,
                                                  state.height);
    cairo_t *text_cr = cairo_create(state.text_surface);
    cairo_set_font_size(text_cr, 14);
    cairo_move_to(text_cr, 20, 30);
    cairo_show_text(text_cr, "Texto renderizado via Cairo");
    
    // Configurar janela GTK
    state.window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_widget_set_size_request(state.window, state.width, state.height);
    
    GtkWidget *drawing_area = gtk_drawing_area_new();
    g_signal_connect(drawing_area, "draw", G_CALLBACK(on_draw), &state);
    gtk_container_add(GTK_CONTAINER(state.window), drawing_area);
    
    gtk_widget_show_all(state.window);
    gtk_main();
    
    cairo_surface_destroy(state.text_surface);
    return 0;
}
```

Erro comum: esquecer de liberar a superfície Cairo (`cairo_surface_destroy`), causando vazamento de memória. Valgrind reportaria:

```
==1234== 4,800 bytes in 1 blocks are definitely lost in loss record 1 of 1
==1234==    at 0x483B7F3: malloc (vg_replace_malloc.c:307)
==1234==    by 0x4A3A7A7: cairo_image_surface_create (cairo-image-surface.c:521)
```

### Aplicativo de Vídeo com Aceleração por GPU

Para decodificação eficiente de vídeo, combinamos GStreamer com DMA-BUF:

```bash
# Requer os pacotes: gstreamer1.0-plugins-bad, gstreamer1.0-plugins-base
gst-launch-1.0 filesrc location=video.mp4 ! \
    qtdemux ! h264parse ! vaapih264dec ! \
    vaapisink sync=false
```

Quando o hardware não suporta VA-API, o erro típico é:

```
ERROR: from element /GstPipeline:pipeline0/GstVaapiDec:h264dec0: 
No VA display found
```

Solução: instalar drivers gráficos corretos e verificar suporte:

```bash
vainfo | grep -A5 'VAProfileH264'
```

### Terminal com Suporte a GPU

Um terminal Wayland moderno usa OpenGL para renderização. Veja um fragmento essencial usando EGL:

```c
EGLDisplay egl_dpy = eglGetDisplay((EGLNativeDisplayType)wl_display);
eglInitialize(egl_dpy, NULL, NULL);

EGLint attribs[] = {
    EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
    EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
    EGL_BLUE_SIZE, 8,
    EGL_GREEN_SIZE, 8,
    EGL_RED_SIZE, 8,
    EGL_NONE
};

EGLConfig cfg;
EGLint count;
eglChooseConfig(egl_dpy, attribs, &cfg, 1, &count);
EGLSurface surf = eglCreateWindowSurface(egl_dpy, cfg, wl_egl_window, NULL);
```

Problema frequente: configurar atributos EGL incorretamente causa falha na criação do contexto. Sempre verifique `eglGetError()` após cada chamada EGL.

### Exercício: Visualizador de PDF com Renderização Incremental

Implemente um visualizador PDF que:
1. Carrege páginas em threads separadas
2. Use um pool de buffers compartilhados
3. Atualize apenas áreas modificadas

Solução parcial (tratamento de buffers):

```c
struct pdf_page {
    cairo_surface_t *surface;
    int width, height;
    bool ready;
};

void render_thread(struct pdf_page *page) {
    // Simula renderização demorada
    sleep(1);
    page->surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32,
                                              page->width,
                                              page->height);
    page->ready = true;
    wl_surface_damage_buffer(surface, 0, 0, page->width, page->height);
}
```

Erro a evitar: modificar buffers enquanto estão commitados. Sempre aguarde o evento `wl_buffer.release`.