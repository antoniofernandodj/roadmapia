## Ecossistema Wayland: compositors e clientes

Um problema comum em sistemas gráficos é a sincronização entre aplicativos: quando dois programas tentam desenhar na tela ao mesmo tempo, o resultado pode ser flickering ou conteúdo misturado. O X11 resolvia isso com um servidor central que coordenava tudo - mas a um custo de performance e complexidade. O Wayland aborda isso de forma radicalmente diferente:

**O compositor é o maestro.** Ele define as regras do jogo:

1. Gerencia os buffers de cada aplicativo
2. Decide quando e como mostrar o conteúdo na tela
3. Trata entradas de dispositivos (teclado, mouse)
4. Implementa efeitos visuais (animações, transições)

Veja na prática como isso funciona. Instale o compositor Weston (referência do projeto Wayland):

```bash
sudo apt install weston
```

Execute-o em uma nova sessão:

```bash
weston --backend=wayland-backend.so &
```

Agora observe os processos em execução:

```bash
ps aux | grep weston
```

Você verá algo como:

```
user   1234  0.5  1.2 987654 32100 tty2    Sl+  14:30   0:01 weston --backend=wayland-backend.so
```

**Clientes são os aplicativos** que querem mostrar conteúdo. Eles não desenham diretamente na tela - negociam com o compositor. Vamos criar um cliente mínimo que mostra uma janela vermelha:

```c
// red_window.c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

static void handle_global(void *data, struct wl_registry *registry,
                         uint32_t name, const char *interface, uint32_t version) {
    printf("Interface disponível: %s (versão %u)\n", interface, version);
}

int main(int argc, char **argv) {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    static const struct wl_registry_listener registry_listener = {
        .global = handle_global
    };
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    printf("Conectado ao compositor Wayland\n");
    while (wl_display_dispatch(display) != -1) {
        // Mantém a conexão ativa
    }

    wl_display_disconnect(display);
    return 0;
}
```

Compile com:

```bash
gcc red_window.c -o red_window -lwayland-client
```

Execute no ambiente Weston:

```bash
./red_window
```

**Erro comum:** esquecer de implementar os listeners necessários. Se você apenas conectar sem implementar as callbacks, verá:

```
Error: wl_display_dispatch() failed: No event queue
```

A correção é implementar pelo menos os listeners básicos:

```c
static const struct wl_registry_listener registry_listener = {
    .global = handle_global,
    .global_remove = NULL // Podemos ignorar neste exemplo
};
```

**Como o compositor e cliente interagem:**

1. O cliente cria buffers locais
2. Negocia com o compositor via protocolo Wayland
3. Envia atualizações quando o conteúdo muda
4. O compositor decide quando mostrar (vsync, etc.)

Principais diferenças para X11:

| Componente       | X11                  | Wayland              |
|------------------|----------------------|----------------------|
| Gerenciamento    | Servidor central     | Compositor + Clientes|
| Comunicação      | X Protocol           | Wayland Protocol     |
| Segurança        | Permissivo           | Restrito             |
| Performance      | Overhead             | Direto               |

**Exercício:** Modifique o exemplo `red_window.c` para listar todas as interfaces suportadas pelo compositor e mostrar suas versões. Ao executar contra Weston e contra GNOME Shell (executando como compositor Wayland), compare as diferenças.

**Solução comentada:**

```c
// Modifique handle_global para armazenar as interfaces
struct interface_list {
    const char *name;
    uint32_t version;
    struct interface_list *next;
};

static void handle_global(void *data, struct wl_registry *registry,
                         uint32_t name, const char *interface, uint32_t version) {
    struct interface_list **list = data;
    struct interface_list *item = malloc(sizeof(*item));
    item->name = interface;
    item->version = version;
    item->next = *list;
    *list = item;
}

// E no main, após wl_display_roundtrip:
struct interface_list *interfaces = NULL;
wl_registry_add_listener(registry, &registry_listener, &interfaces);

wl_display_roundtrip(display);

printf("Interfaces suportadas:\n");
for (struct interface_list *item = interfaces; item; item = item->next) {
    printf("- %s (v%u)\n", item->name, item->version);
}
```

Você notará que GNOME Shell oferece mais interfaces (como xdg-shell) que Weston padrão, mostrando como compositors podem estender o protocolo básico.