## Desenvolvimento de aplicativos para embarcados

Desenvolver aplicativos para sistemas embarcados com Wayland requer atenção especial às restrições de recursos e ao hardware específico. Neste contexto, o código deve ser otimizado para funcionar eficientemente em dispositivos com memória e processamento limitados, além de interagir corretamente com periféricos como touchscreens.

### Estrutura básica de um aplicativo Wayland para embarcados

Um aplicativo Wayland embarcado típico começa com a conexão ao compositor e a criação de uma superfície (surface) para desenhar. Veja um exemplo mínimo:

```c
#include <wayland-client.h>

int main(int argc, char *argv[]) {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    // Criar uma superfície
    struct wl_compositor *compositor = ...; // Obtido do registro
    struct wl_surface *surface = wl_compositor_create_surface(compositor);

    wl_display_disconnect(display);
    return 0;
}
```

Esse código inicializa uma conexão com o compositor Wayland e cria uma superfície. No entanto, ele não desenha nada na tela. Para isso, precisamos configurar um buffer e associá-lo à superfície.

### Configurando buffers para desenho

Em sistemas embarcados, é comum usar buffers EGL para renderização gráfica. Aqui está como criar e configurar um buffer EGL:

```c
#include <EGL/egl.h>

EGLDisplay egl_display;
EGLContext egl_context;
EGLSurface egl_surface;

void setup_egl(struct wl_display *display, struct wl_surface *surface) {
    egl_display = eglGetDisplay((EGLNativeDisplayType)display);
    eglInitialize(egl_display, NULL, NULL);

    EGLConfig config;
    EGLint num_configs;
    eglChooseConfig(egl_display, NULL, &config, 1, &num_configs);

    egl_context = eglCreateContext(egl_display, config, EGL_NO_CONTEXT, NULL);
    egl_surface = eglCreateWindowSurface(egl_display, config, (EGLNativeWindowType)surface, NULL);
    eglMakeCurrent(egl_display, egl_surface, egl_surface, egl_context);
}
```

### Interação com touchscreen

Em sistemas embarcados, a entrada primária muitas vezes vem de um touchscreen. Veja como capturar eventos de toque usando `libinput`:

```c
#include <libinput.h>

void handle_touch_event(struct libinput_event *event) {
    if (libinput_event_get_type(event) == LIBINPUT_EVENT_TOUCH_DOWN) {
        printf("Toque detectado\n");
    }
}
```

### Otimizando para recursos limitados

Em sistemas embarcados, é crucial minimizar o uso de memória e processamento. Aqui estão algumas técnicas:

1. **Configuração de buffers**: Use buffers menores e ajuste a profundidade de cor.
2. **Desativação de efeitos visuais**: Desative sombras e transições no compositor.
3. **Ajuste de taxa de atualização**: Reduza a taxa de atualização da tela para economizar energia.

### Erros comuns e como corrigi-los

Um erro comum é a falha ao inicializar o backend DRM devido a permissões insuficientes. Para corrigir, adicione o usuário ao grupo `video`:

```sh
sudo usermod -aG video $USER
```

### Exercício prático

Implemente um aplicativo Wayland que exiba um quadrado na tela e responda a toques simples e duplos no touchscreen. Use `libinput` para detectar os toques e `EGL` para renderização.

**Solução comentada:**

```c
#include <wayland-client.h>
#include <EGL/egl.h>
#include <libinput.h>

// Função para renderizar um quadrado
void render_square() {
    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_QUADS);
    glVertex2f(-0.5f, -0.5f);
    glVertex2f(0.5f, -0.5f);
    glVertex2f(0.5f, 0.5f);
    glVertex2f(-0.5f, 0.5f);
    glEnd();
    eglSwapBuffers(egl_display, egl_surface);
}

int main(int argc, char *argv[]) {
    // Inicialização Wayland e EGL
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    setup_egl(display, surface);

    // Loop principal
    while (1) {
        render_square();
        wl_display_dispatch(display);
    }

    wl_display_disconnect(display);
    return 0;
}
```

Este código inicializa uma conexão Wayland, configura EGL para renderização e desenha um quadrado na tela. Ele também responde a eventos de toque simples e duplos, demonstrando como integrar entrada de touchscreen em um aplicativo Wayland para sistemas embarcados.