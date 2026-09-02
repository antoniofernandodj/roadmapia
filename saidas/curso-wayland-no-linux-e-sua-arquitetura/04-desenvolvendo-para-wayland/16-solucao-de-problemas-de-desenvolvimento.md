## Solução de problemas de desenvolvimento

Ao desenvolver aplicativos Wayland, é comum enfrentar problemas que podem ser difíceis de diagnosticar sem as ferramentas e técnicas adequadas. Este trecho aborda os problemas mais comuns e como resolvê-los, focando em erros de desenvolvimento e não em bugs de runtime.

### 1. Conexão falha com o compositor

Um dos problemas mais frequentes é a falha ao estabelecer a conexão com o compositor Wayland. Isso geralmente ocorre quando o ambiente não está configurado corretamente para usar Wayland.

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }
    printf("Conectado ao compositor Wayland.\n");
    wl_display_disconnect(display);
    return 0;
}
```

Se o código acima falhar, verifique se o ambiente está realmente usando Wayland:

```bash
echo $XDG_SESSION_TYPE
```

Se o resultado não for `wayland`, você precisará ajustar sua sessão para usar Wayland. Em sistemas GNOME, isso pode ser feito selecionando "GNOME on Wayland" na tela de login.

### 2. Superfícies sem buffer

Outro problema comum é criar uma superfície (`wl_surface`) sem associar um buffer a ela. Isso resulta em uma superfície invisível ou em erros no log do compositor.

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_compositor *compositor = NULL;
    struct wl_surface *surface = NULL;

    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    compositor = wl_display_get_compositor(display);
    surface = wl_compositor_create_surface(compositor);

    if (!surface) {
        fprintf(stderr, "Falha ao criar superfície.\n");
        wl_display_disconnect(display);
        return 1;
    }

    // Falta associar um buffer à superfície
    wl_surface_commit(surface);

    wl_display_disconnect(display);
    return 0;
}
```

Para corrigir isso, você precisa criar um buffer e associá-lo à superfície antes de chamar `wl_surface_commit`. Use `wl_shm` para criar um buffer em memória compartilhada.

### 3. Listeners não registrados

Esquecer de registrar listeners para eventos específicos é outro erro comum. Isso resulta em eventos sendo ignorados, como cliques de mouse ou pressionamentos de tecla.

```c
#include <wayland-client.h>

static void pointer_enter(void *data, struct wl_pointer *pointer, uint32_t serial,
                          struct wl_surface *surface, wl_fixed_t sx, wl_fixed_t sy) {
    printf("Mouse entrou na superfície.\n");
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_seat *seat = NULL;
    struct wl_pointer *pointer = NULL;

    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    seat = wl_display_get_seat(display);
    pointer = wl_seat_get_pointer(seat);

    // Falta registrar o listener
    wl_pointer_add_listener(pointer, &pointer_listener, NULL);

    wl_display_disconnect(display);
    return 0;
}
```

Para corrigir isso, certifique-se de registrar o listener adequado para cada interface que você deseja monitorar.

### 4. Erros de protocolo

Erros de protocolo podem ocorrer quando mensagens inválidas são enviadas ao compositor. Esses erros podem ser capturados usando `wl_display_get_error`.

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    int error = wl_display_get_error(display);
    if (error != 0) {
        fprintf(stderr, "Erro de protocolo: %d\n", error);
        wl_display_disconnect(display);
        return 1;
    }

    wl_display_disconnect(display);
    return 0;
}
```

Se você encontrar erros de protocolo, use `WAYLAND_DEBUG=1` para depurar a comunicação entre o cliente e o compositor.

### 5. Falha ao usar protocolos estendidos

Protocolos estendidos, como `xdg_shell`, podem não estar disponíveis em todos os compositores. Verificar a disponibilidade desses protocolos é essencial.

```c
#include <wayland-client.h>
#include <xdg-shell-client-protocol.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct xdg_wm_base *wm_base = NULL;

    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    wm_base = wl_display_get_xdg_wm_base(display);
    if (!wm_base) {
        fprintf(stderr, "Protocolo xdg_shell não disponível.\n");
        wl_display_disconnect(display);
        return 1;
    }

    wl_display_disconnect(display);
    return 0;
}
```

Se o protocolo `xdg_shell` não estiver disponível, você pode precisar usar uma alternativa ou garantir que o compositor suporte o protocolo.

### Exercício: Depuração de um cliente Wayland

Crie um cliente Wayland simples que abre uma janela e trata eventos de mouse. Use `WAYLAND_DEBUG=1` para depurar qualquer problema que encontrar. Certifique-se de que todos os listeners estão registrados e que os buffers estão corretamente associados às superfícies.

**Solução comentada:**

```c
#include <wayland-client.h>
#include <wayland-client-protocol.h>
#include <stdio.h>

static void pointer_enter(void *data, struct wl_pointer *pointer, uint32_t serial,
                          struct wl_surface *surface, wl_fixed_t sx, wl_fixed_t sy) {
    printf("Mouse entrou na superfície.\n");
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_compositor *compositor = NULL;
    struct wl_surface *surface = NULL;
    struct wl_seat *seat = NULL;
    struct wl_pointer *pointer = NULL;

    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }

    compositor = wl_display_get_compositor(display);
    surface = wl_compositor_create_surface(compositor);

    if (!surface) {
        fprintf(stderr, "Falha ao criar superfície.\n");
        wl_display_disconnect(display);
        return 1;
    }

    seat = wl_display_get_seat(display);
    pointer = wl_seat_get_pointer(seat);

    wl_pointer_add_listener(pointer, &pointer_listener, NULL);

    wl_display_disconnect(display);
    return 0;
}
```

Este código cria uma superfície e registra um listener para eventos de mouse. Use `WAYLAND_DEBUG=1` para depurar qualquer problema que encontrar.