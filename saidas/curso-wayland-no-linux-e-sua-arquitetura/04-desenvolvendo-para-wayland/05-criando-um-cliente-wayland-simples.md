## Criando um cliente Wayland simples

O desafio mais básico no desenvolvimento Wayland é criar um cliente que se conecte ao compositor e exiba uma janela vazia. Ao contrário de sistemas como X11, onde você cria janelas diretamente, no Wayland você precisa negociar cada componente através do protocolo.

Vamos construir um cliente mínimo que:
1. Conecta-se ao compositor
2. Obtém as interfaces necessárias
3. Cria uma superfície
4. Exibe uma janela simples

Comece com este código base (`simple-client.c`):

```c
#include <wayland-client.h>
#include <stdlib.h>
#include <stdio.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct wl_surface *surface = NULL;
struct wl_shell *shell = NULL;
struct wl_shell_surface *shell_surface = NULL;

static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t name, const char *interface,
                                  uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        compositor = wl_registry_bind(registry, name, 
            &wl_compositor_interface, 1);
    } else if (strcmp(interface, "wl_shell") == 0) {
        shell = wl_registry_bind(registry, name,
            &wl_shell_interface, 1);
    }
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global
};

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return EXIT_FAILURE;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !shell) {
        fprintf(stderr, "Interfaces Wayland essenciais não disponíveis\n");
        return EXIT_FAILURE;
    }

    surface = wl_compositor_create_surface(compositor);
    shell_surface = wl_shell_get_shell_surface(shell, surface);
    wl_shell_surface_set_toplevel(shell_surface);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal do aplicativo
    }

    wl_shell_surface_destroy(shell_surface);
    wl_surface_destroy(surface);
    wl_shell_destroy(shell);
    wl_compositor_destroy(compositor);
    wl_display_disconnect(display);
    return EXIT_SUCCESS;
}
```

Para compilar, use:

```bash
gcc -o simple-client simple-client.c -lwayland-client
```

O erro mais comum nessa fase é esquecer de chamar `wl_display_roundtrip()` após registrar o listener. Sem isso, as interfaces globais não são carregadas, resultando em:

```
Falha ao conectar ao display Wayland
(wl_display_connect falhou: Nenhum processo encontrado)
```

Isso geralmente significa que:
1. Você não está rodando em uma sessão Wayland (verifique com `echo $XDG_SESSION_TYPE`)
2. O caminho do socket Wayland padrão não está acessível

O código funciona em três etapas principais:

1. **Conexão inicial**: `wl_display_connect(NULL)` estabelece a conexão com o compositor Wayland em execução. O parâmetro NULL indica para usar o display padrão.

2. **Descoberta de interfaces**: O registry é como um catálogo de serviços que o compositor oferece. Registramos um listener para capturar quando as interfaces `wl_compositor` e `wl_shell` ficarem disponíveis.

3. **Criação da janela**: Com as interfaces obtidas, criamos uma superfície básica e a promovemos para uma janela toplevel usando `wl_shell_surface_set_toplevel()`.

Um detalhe crucial é que o Wayland não desenha nada por padrão - nossa janela estará completamente transparente. Isso é intencional, pois o protocolo separa claramente a gestão de janelas do conteúdo gráfico.

Para testar que está funcionando, execute o cliente e observe:

1. Uma janela vazia deve aparecer (geralmente apenas a decoração do compositor)
2. Você deve poder mover e fechar a janela normalmente
3. Verifique os logs com `WAYLAND_DEBUG=1 ./simple-client` para ver a troca de mensagens

**Exercício**: Modifique o cliente para definir um título para a janela usando `wl_shell_surface_set_title()`. A solução requer apenas uma linha adicional:

```c
wl_shell_surface_set_title(shell_surface, "Meu Primeiro Cliente Wayland");
```

Recompile e execute novamente. Agora sua janela deve mostrar o título na barra de decoração.