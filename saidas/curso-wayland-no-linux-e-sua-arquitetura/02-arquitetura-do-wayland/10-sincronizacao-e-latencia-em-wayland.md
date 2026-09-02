## Sincronização e latência em Wayland

Em sistemas gráficos modernos, a sincronização entre o cliente e o compositor é crucial para garantir que a interface gráfica seja renderizada corretamente e sem atrasos perceptíveis. No Wayland, essa sincronização é alcançada através de mecanismos específicos que evitam problemas como *tearing* (quando partes de diferentes frames são exibidas simultaneamente) e alta latência.

### O problema do *tearing*

Imagine que você está desenvolvendo um aplicativo gráfico que exibe uma animação suave. Se o cliente e o compositor não estiverem sincronizados, partes de diferentes frames podem ser exibidas ao mesmo tempo, resultando em uma experiência visual ruim. Esse fenômeno é conhecido como *tearing*. No X11, isso era comum porque o protocolo permitia que os clientes desenhassem diretamente na tela sem coordenação adequada com o compositor.

No Wayland, o compositor controla completamente a renderização, evitando o *tearing*. Ele garante que apenas frames completos sejam exibidos, sincronizando a exibição com o monitor através de técnicas como *v-sync* (sincronização vertical).

### Sincronização com `wl_surface`

A sincronização em Wayland é realizada através da interface `wl_surface`. Quando um cliente deseja exibir um novo frame, ele primeiro desenha o conteúdo em um buffer e, em seguida, envia uma solicitação ao compositor para apresentar esse buffer. O compositor só exibe o buffer quando está pronto, garantindo que não haja sobreposição de frames.

Vamos ver um exemplo prático:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <unistd.h>

static void frame_callback(void *data, struct wl_callback *callback, uint32_t time) {
    printf("Frame apresentado com sucesso!\n");
    wl_callback_destroy(callback);
}

static const struct wl_callback_listener frame_listener = {
    .done = frame_callback,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_compositor *compositor = NULL;
    struct wl_surface *surface = NULL;

    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);
    struct wl_callback *callback = wl_surface_frame(surface);
    wl_callback_add_listener(callback, &frame_listener, NULL);

    wl_surface_commit(surface);
    wl_display_roundtrip(display);

    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

Neste exemplo, criamos uma superfície (`wl_surface`) e solicitamos um *callback* de frame usando `wl_surface_frame`. Quando o frame é apresentado, a função `frame_callback` é chamada, indicando que o frame foi exibido com sucesso.

### Latência e `wl_display_roundtrip`

A latência é outro aspecto crítico em sistemas gráficos. Se o cliente não esperar o compositor processar suas solicitações, pode ocorrer uma situação em que o cliente envia mais frames do que o compositor consegue processar, resultando em latência acumulada.

Para evitar isso, o Wayland fornece a função `wl_display_roundtrip`, que bloqueia o cliente até que todas as mensagens enviadas ao compositor sejam processadas. Isso garante que o cliente não envie novos frames antes que os anteriores tenham sido completamente tratados.

Vamos modificar o exemplo anterior para ilustrar isso:

```c
wl_surface_commit(surface);
wl_display_roundtrip(display); // Espera o compositor processar o frame
```

### Erro comum: Ignorar a sincronização

Um erro comum ao desenvolver para Wayland é ignorar a sincronização, resultando em frames perdidos ou *tearing*. Por exemplo, se você omitir o `wl_display_roundtrip`, o cliente pode continuar enviando frames antes que o compositor tenha tempo de processá-los, causando latência e inconsistências visuais.

```c
wl_surface_commit(surface);
// wl_display_roundtrip(display); // Comentado para simular o erro
```

Se você executar este código, notará que o aplicativo continua executando sem esperar o compositor, resultando em comportamento imprevisível.

### Exercício

Modifique o exemplo inicial para criar uma animação simples que exibe uma mensagem na tela a cada segundo. Use `wl_display_roundtrip` para garantir que cada frame seja sincronizado com o compositor.

**Solução:**

```c
#include <wayland-client.h>
#include <stdio.h>
#include <unistd.h>

static void frame_callback(void *data, struct wl_callback *callback, uint32_t time) {
    printf("Frame apresentado com sucesso!\n");
    wl_callback_destroy(callback);
}

static const struct wl_callback_listener frame_listener = {
    .done = frame_callback,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_compositor *compositor = NULL;
    struct wl_surface *surface = NULL;

    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    surface = wl_compositor_create_surface(compositor);

    for (int i = 0; i < 5; i++) {
        struct wl_callback *callback = wl_surface_frame(surface);
        wl_callback_add_listener(callback, &frame_listener, NULL);
        wl_surface_commit(surface);
        wl_display_roundtrip(display);
        sleep(1);
    }

    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

Este código exibe uma mensagem a cada segundo, garantindo que cada frame seja sincronizado com o compositor.