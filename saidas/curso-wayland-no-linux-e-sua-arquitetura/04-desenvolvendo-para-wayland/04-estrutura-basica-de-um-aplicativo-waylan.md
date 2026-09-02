## Estrutura básica de um aplicativo Wayland

Um aplicativo Wayland mínimo precisa de quatro componentes essenciais: uma conexão com o compositor, uma superfície para desenho, um buffer para conteúdo gráfico e um loop de eventos. Vamos dissecar cada parte com um exemplo funcional que exibe uma janela vermelha - o "Hello World" gráfico do Wayland.

Comece criando um arquivo `red_window.c` com este esqueleto:

```c
#include <wayland-client.h>
#include <wayland-client-protocol.h>
#include <stdlib.h>
#include <stdio.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct wl_surface *surface = NULL;
struct wl_shell *shell = NULL;
struct wl_shell_surface *shell_surface = NULL;

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha na conexão com o display Wayland\n");
        return EXIT_FAILURE;
    }
    
    // Restante do código será inserido aqui
    
    while (wl_display_dispatch(display) != -1) {
        // Loop principal de eventos
    }

    wl_display_disconnect(display);
    return EXIT_SUCCESS;
}
```

Compile com:
```bash
gcc -o red_window red_window.c -lwayland-client
```

Se executar agora, o programa falhará com:
```
Falha no binding global: wl_compositor (versão 4)
```

Isso ocorre porque faltam três passos cruciais:

1. **Registro de globais**: Obter interfaces do compositor
2. **Configuração de superfície**: Criar área de desenho
3. **Atribuição de papel de janela**: Definir comportamento

Vamos implementar o registro de globais primeiro. Adicione estas funções antes do main:

```c
static void registry_handle_global(void *data, struct wl_registry *registry,
        uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 4);
    } else if (strcmp(interface, "wl_shell") == 0) {
        shell = wl_registry_bind(registry, name, &wl_shell_interface, 1);
    }
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global
};
```

E atualize o main após a conexão:

```c
struct wl_registry *registry = wl_display_get_registry(display);
wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display);

if (!compositor || !shell) {
    fprintf(stderr, "Compositor ou shell não disponíveis\n");
    return EXIT_FAILURE;
}
```

Agora crie a superfície e configure como janela:

```c
surface = wl_compositor_create_surface(compositor);
shell_surface = wl_shell_get_shell_surface(shell, surface);
wl_shell_surface_set_toplevel(shell_surface);
```

Para realmente ver algo, precisamos de um buffer. Adicione:

```c
struct wl_shm *shm = NULL;
struct wl_buffer *buffer = NULL;
int width = 320, height = 240;

// Adicione wl_shm ao registry_handle_global:
else if (strcmp(interface, "wl_shm") == 0) {
    shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
}

// Crie um buffer RGBx (32bpp) compartilhado:
int stride = width * 4;
int size = stride * height;
int fd = memfd_create("buffer", MFD_CLOEXEC);
ftruncate(fd, size);
uint32_t *pixels = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

// Preencha com vermelho:
for (int i = 0; i < width * height; i++) {
    pixels[i] = 0xFF0000FF; // ARGB
}

struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
buffer = wl_shm_pool_create_buffer(pool, 0, width, height, stride, WL_SHM_FORMAT_XRGB8888);
wl_shm_pool_destroy(pool);
close(fd);

// Exiba o buffer:
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_commit(surface);
```

Execute novamente e você verá uma janela vermelha de 320x240 pixels. O loop principal (`wl_display_dispatch`) mantém a janela responsiva.

**Erro comum**: Esquecer o `wl_surface_commit`. Sem isso, as mudanças não são aplicadas, resultando em uma janela preta. A mensagem de erro não é clara - simplesmente nada aparece.

**Padrão típico**: A maioria dos aplicativos encapsula esses componentes em uma estrutura:

```c
struct app_state {
    struct wl_display *display;
    struct wl_surface *surface;
    // ... outros recursos
    bool running;
};

static void redraw(struct app_state *state) {
    // Lógica de renderização
}

int main() {
    struct app_state state = {0};
    // Inicialização...
    
    while (state.running) {
        wl_display_dispatch_pending(state.display);
        redraw(&state);
    }
}
```

**Exercício**: Modifique o exemplo para criar uma janela azul que muda para verde quando clicada. Dica: implemente o listener `wl_shell_surface_listener` com o callback `ping`.

**Solução**:

```c
static void handle_ping(void *data, struct wl_shell_surface *shell_surface,
        uint32_t serial) {
    wl_shell_surface_pong(shell_surface, serial);
}

static const struct wl_shell_surface_listener shell_surface_listener = {
    .ping = handle_ping
};

// No main, após criar shell_surface:
wl_shell_surface_add_listener(shell_surface, &shell_surface_listener, NULL);

// Variável global para cor:
uint32_t current_color = 0xFF0000FF; // Azul

// Modifique o loop de desenho:
for (int i = 0; i < width * height; i++) {
    pixels[i] = current_color;
}

// Adicione handler de click:
static void handle_click(void *data, struct wl_pointer *pointer,
        uint32_t serial, struct wl_surface *surface,
        wl_fixed_t sx, wl_fixed_t sy) {
    current_color = 0xFF00FF00; // Verde
    // Trigger redraw
}

// Registre o handler de eventos de ponteiro (implementação similar ao registry)
```