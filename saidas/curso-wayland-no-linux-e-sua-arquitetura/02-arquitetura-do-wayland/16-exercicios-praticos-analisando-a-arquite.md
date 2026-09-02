## Exercícios práticos: analisando a arquitetura

Neste trecho, exploraremos a arquitetura do Wayland através de exercícios práticos que envolvem a análise de componentes como o compositor, clientes, sockets Unix e protocolos de comunicação. O objetivo é consolidar o entendimento teórico apresentado anteriormente, permitindo que você visualize e interaja diretamente com os elementos que compõem o ecossistema Wayland.

### Exercício 1: Conectando-se ao compositor Wayland

O primeiro exercício consiste em conectar-se ao compositor Wayland usando um socket Unix. Para isso, utilizaremos a função `wl_display_connect`, que permite estabelecer uma conexão com o compositor. Vamos criar um cliente simples que se conecta ao compositor e verifica se a conexão foi bem-sucedida.

```c
#include <wayland-client.h>
#include <stdio.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }
    printf("Conectado ao compositor Wayland com sucesso.\n");
    wl_display_disconnect(display);
    return 0;
}
```

Compile o código acima com o comando:

```bash
gcc -o wayland_connect wayland_connect.c -lwayland-client
```

Execute o programa e observe a saída:

```bash
./wayland_connect
```

Se tudo estiver configurado corretamente, você verá a mensagem "Conectado ao compositor Wayland com sucesso.". Caso contrário, verifique se o compositor Wayland está em execução e se o caminho do socket Unix está correto.

### Exercício 2: Listando interfaces globais

Agora que sabemos como conectar-se ao compositor, vamos listar as interfaces globais disponíveis. Utilizaremos a função `wl_display_get_registry` para obter o registro de interfaces globais e, em seguida, vamos iterar sobre essas interfaces para listá-las.

```c
#include <wayland-client.h>
#include <stdio.h>

void registry_handle_global(void *data, struct wl_registry *registry, uint32_t id, const char *interface, uint32_t version) {
    printf("Interface global encontrada: %s (versão %d)\n", interface, version);
}

void registry_handle_global_remove(void *data, struct wl_registry *registry, uint32_t id) {
    // Não faz nada quando uma interface global é removida
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
    .global_remove = registry_handle_global_remove,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    wl_registry_destroy(registry);
    wl_display_disconnect(display);
    return 0;
}
```

Compile e execute o programa:

```bash
gcc -o list_interfaces list_interfaces.c -lwayland-client
./list_interfaces
```

Você verá uma lista de interfaces globais oferecidas pelo compositor, como `wl_compositor`, `wl_shm`, e outras. Esse exercício ajuda a entender como os clientes descobrem e interagem com as interfaces disponíveis no compositor.

### Exercício 3: Criando uma superfície básica

O próximo passo é criar uma superfície básica (`wl_surface`) e associá-la a uma janela. Para isso, utilizaremos a interface `wl_compositor` para criar a superfície e, em seguida, vamos solicitar ao compositor que desenhe a janela.

```c
#include <wayland-client.h>
#include <stdio.h>

void surface_configure(void *data, struct wl_surface *surface, int32_t width, int32_t height) {
    printf("Superfície configurada com dimensões %dx%d\n", width, height);
}

static const struct wl_surface_listener surface_listener = {
    .configure = surface_configure,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    struct wl_compositor *compositor = wl_registry_bind(registry, 1, &wl_compositor_interface, 1);
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    wl_surface_add_listener(surface, &surface_listener, NULL);

    wl_surface_commit(surface);
    wl_display_roundtrip(display);

    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);
    return 0;
}
```

Compile e execute o programa:

```bash
gcc -o create_surface create_surface.c -lwayland-client
./create_surface
```

Você verá uma mensagem indicando que a superfície foi configurada com as dimensões especificadas. Esse exercício demonstra como criar e gerenciar superfícies em Wayland, um componente fundamental para a exibição de janelas.

### Exercício 4: Lidando com eventos de entrada

Por fim, vamos implementar um simples manipulador de eventos de entrada, como movimentos do mouse e pressionamentos de tecla. Utilizaremos a interface `wl_seat` para registrar listeners de eventos de entrada.

```c
#include <wayland-client.h>
#include <stdio.h>

void pointer_handle_motion(void *data, struct wl_pointer *pointer, uint32_t time, wl_fixed_t sx, wl_fixed_t sy) {
    printf("Movimento do mouse: %f, %f\n", wl_fixed_to_double(sx), wl_fixed_to_double(sy));
}

void pointer_handle_button(void *data, struct wl_pointer *pointer, uint32_t serial, uint32_t time, uint32_t button, uint32_t state) {
    printf("Botão %d %s\n", button, state == WL_POINTER_BUTTON_STATE_PRESSED ? "pressionado" : "liberado");
}

static const struct wl_pointer_listener pointer_listener = {
    .motion = pointer_handle_motion,
    .button = pointer_handle_button,
};

void seat_capabilities(void *data, struct wl_seat *seat, uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_POINTER) {
        struct wl_pointer *pointer = wl_seat_get_pointer(seat);
        wl_pointer_add_listener(pointer, &pointer_listener, NULL);
    }
}

static const struct wl_seat_listener seat_listener = {
    .capabilities = seat_capabilities,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    struct wl_seat *seat = wl_registry_bind(registry, 1, &wl_seat_interface, 1);
    wl_seat_add_listener(seat, &seat_listener, NULL);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal de eventos
    }

    wl_seat_destroy(seat);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);
    return 0;
}
```

Compile e execute o programa:

```bash
gcc -o handle_input handle_input.c -lwayland-client
./handle_input
```

Agora, ao mover o mouse ou clicar, você verá as coordenadas e os eventos de botão sendo impressos no terminal. Esse exercício ilustra como Wayland gerencia eventos de entrada de forma eficiente e segura.

### Conclusão

Através desses exercícios práticos, você teve a oportunidade de interagir diretamente com os componentes fundamentais da arquitetura Wayland, desde a conexão ao compositor até o gerenciamento de superfícies e eventos de entrada. Esses exemplos fornecem uma base sólida para entender como os diferentes elementos do Wayland interagem entre si, preparando-o para desafios mais avançados no desenvolvimento de aplicativos gráficos.