## Gerenciamento de recursos em Wayland

Em Wayland, o gerenciamento de recursos é uma parte crítica da comunicação entre clientes e o compositor. Ao contrário do X11, onde o servidor gerencia diretamente os recursos gráficos, no Wayland os clientes são responsáveis por criar, modificar e destruir seus próprios recursos. O compositor apenas gerencia como esses recursos são apresentados na tela.

### Alocação e Liberação de Recursos

No Wayland, recursos como superfícies (`wl_surface`), buffers e fontes são criados pelos clientes usando interfaces globais oferecidas pelo compositor. Cada recurso é identificado por um ID único e deve ser explicitamente destruído quando não for mais necessário. A falha em liberar recursos adequadamente pode levar a vazamentos de memória e crashes do cliente.

Considere o exemplo abaixo, onde um cliente cria uma superfície e um buffer de memória compartilhada (`wl_shm`):

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_shm *shm;
struct wl_surface *surface;

void create_surface() {
    surface = wl_compositor_create_surface(compositor);
    if (!surface) {
        fprintf(stderr, "Falha ao criar superfície\n");
        exit(1);
    }
}

void create_buffer() {
    struct wl_shm_pool *pool;
    int fd = shm_create_anonymous(1024); // Função fictícia para criar memória compartilhada
    pool = wl_shm_create_pool(shm, fd, 1024);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 100, 100, 400, WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_surface();
    create_buffer();

    // Limpeza
    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

Neste exemplo, a superfície e o buffer são criados e posteriormente destruídos explicitamente. A função `wl_surface_destroy` libera a superfície, e `wl_display_disconnect` fecha a conexão com o compositor.

### Erros Comuns no Gerenciamento de Recursos

Um erro comum é esquecer de liberar recursos após o uso. Por exemplo, se você criar uma superfície e não destruí-la, o compositor pode manter referências a essa superfície indefinidamente, causando vazamentos de memória. Veja o que acontece se você omitir a chamada `wl_surface_destroy`:

```c
create_surface();
// Esqueceu de chamar wl_surface_destroy(surface);
```

Embora o programa possa funcionar corretamente durante a execução, o vazamento será detectado ao desconectar do display:

```
Erro: Falha ao destruir superfície: recurso não liberado
```

Outro erro comum é tentar usar um recurso após destruí-lo. Por exemplo, tentar desenhar em um buffer após destruí-lo resultará em um erro:

```c
wl_buffer_destroy(buffer);
wl_surface_attach(surface, buffer, 0, 0); // Erro: buffer já destruído
```

O Wayland emitirá uma mensagem de erro:

```
Erro: Tentativa de usar buffer destruído
```

### Comparação com X11

No X11, o servidor gerencia diretamente todos os recursos gráficos, incluindo janelas, pixmaps e fontes. Isso simplifica o desenvolvimento do cliente, mas aumenta a complexidade do servidor e pode levar a problemas de escalabilidade e segurança. No Wayland, a responsabilidade pelo gerenciamento de recursos é transferida para os clientes, o que permite maior controle e eficiência.

### Exercício Prático

Escreva um programa Wayland que cria duas superfícies e um buffer compartilhado. Certifique-se de que todos os recursos sejam liberados corretamente após o uso. Verifique se há vazamentos de memória usando uma ferramenta como `valgrind`.

**Solução:**

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_shm *shm;
struct wl_surface *surface1, *surface2;

void create_surface(struct wl_surface **surface) {
    *surface = wl_compositor_create_surface(compositor);
    if (!*surface) {
        fprintf(stderr, "Falha ao criar superfície\n");
        exit(1);
    }
}

void create_buffer() {
    int fd = shm_open("/example", O_RDWR | O_CREAT, 0666);
    ftruncate(fd, 1024);
    void *data = mmap(NULL, 1024, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, 1024);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 100, 100, 400, WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);
}

int main() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    create_surface(&surface1);
    create_surface(&surface2);
    create_buffer();

    // Limpeza
    wl_surface_destroy(surface1);
    wl_surface_destroy(surface2);
    wl_display_disconnect(display);
    return 0;
}
```

Este exercício reforça a importância de liberar recursos explicitamente em Wayland, garantindo que não haja vazamentos de memória ou uso de recursos inválidos.