## Clientes Wayland: como se comunicam

Quando um cliente Wayland (como um aplicativo gráfico) deseja exibir sua interface na tela, ele precisa estabelecer uma comunicação com o compositor Wayland. Essa comunicação ocorre através de um **socket Unix**, onde o compositor escuta e o cliente se conecta. O cliente envia mensagens que descrevem o que ele deseja exibir (como uma janela ou gráficos) e o compositor responde com eventos ou atualizações de estado.

### Conexão inicial: `wl_display`

O primeiro passo para um cliente Wayland é estabelecer uma conexão com o compositor. Isso é feito através da função `wl_display_connect`, que tenta se conectar ao socket Unix padrão do Wayland (`$WAYLAND_DISPLAY` ou `/run/user/<UID>/wayland-0`). Se a conexão for bem-sucedida, o cliente recebe um objeto `wl_display`, que representa a conexão com o compositor.

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

Se o cliente não conseguir se conectar ao compositor, `wl_display_connect` retorna `NULL`. Isso pode acontecer se o ambiente gráfico não estiver usando Wayland ou se o cliente não tiver permissões adequadas para acessar o socket.

### Registrando globais: `wl_registry`

Após estabelecer a conexão, o cliente precisa descobrir os recursos disponíveis no compositor. Isso é feito através do `wl_registry`, que lista os "globais" — interfaces que o compositor oferece, como `wl_compositor`, `wl_shm` (para compartilhamento de memória) e `wl_seat` (para entrada de dispositivos como teclado e mouse).

O cliente registra um listener para receber eventos do `wl_registry`, que informam quais globais estão disponíveis e como acessá-los.

```c
static void registry_global(void *data, struct wl_registry *registry,
                           uint32_t name, const char *interface, uint32_t version) {
    printf("Global disponível: %s (versão %u)\n", interface, version);
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_global,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display); // Espera pelos eventos de globais
    wl_registry_destroy(registry);
    wl_display_disconnect(display);
    return 0;
}
```

A saída deste código pode variar dependendo do compositor, mas geralmente inclui interfaces como `wl_compositor`, `wl_shm` e `wl_seat`.

### Criando uma superfície: `wl_surface`

Uma vez que o cliente tenha acesso ao `wl_compositor`, ele pode criar uma superfície (`wl_surface`), que representa uma janela ou área gráfica onde o cliente pode desenhar. A superfície é a base para qualquer interface gráfica no Wayland.

```c
struct wl_compositor *compositor = NULL;

static void registry_global(void *data, struct wl_registry *registry,
                           uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
    }
}

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor) {
        fprintf(stderr, "wl_compositor não disponível.\n");
        return 1;
    }

    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    if (!surface) {
        fprintf(stderr, "Falha ao criar a superfície.\n");
        return 1;
    }
    printf("Superfície criada com sucesso.\n");

    wl_surface_destroy(surface);
    wl_compositor_destroy(compositor);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);
    return 0;
}
```

Se o `wl_compositor` não estiver disponível, o cliente não poderá criar superfícies e falhará ao tentar exibir qualquer interface gráfica.

### Erro comum: Falha na troca de mensagens

Um erro comum ocorre quando o cliente não processa os eventos do compositor adequadamente, resultando em uma interface gráfica que não atualiza ou não responde a entradas. Isso pode ser evitado chamando `wl_display_roundtrip` ou `wl_display_flush` para garantir que as mensagens sejam enviadas e recebidas corretamente.

```c
wl_display_flush(display); // Envia mensagens pendentes
wl_display_roundtrip(display); // Espera pela resposta do compositor
```

### Comparação com X11

No X11, os clientes se comunicam com o servidor X através de um protocolo complexo que inclui gerenciamento de janelas, desenho e entrada. No Wayland, essa complexidade é reduzida, com o cliente enviando apenas o conteúdo gráfico e o compositor lidando com a composição final e a entrada.