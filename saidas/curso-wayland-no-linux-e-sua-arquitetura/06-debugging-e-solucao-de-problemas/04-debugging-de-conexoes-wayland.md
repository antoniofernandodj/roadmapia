## Debugging de conexões Wayland

Um cliente Wayland que falha ao se conectar ao compositor geralmente exibe mensagens enigmáticas como "Failed to connect to Wayland display" ou simplesmente fecha sem aviso. O problema real está nas negociações iniciais entre cliente e servidor - um processo que envolve autenticação, troca de capacidades e estabelecimento de canais de comunicação.

Vamos analisar um caso concreto. Crie este cliente mínimo (`client-falho.c`):

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha na conexão\n");
        return 1;
    }
    
    printf("Conectado ao Wayland!\n");
    wl_display_disconnect(display);
    return 0;
}
```

Compile com:
```bash
gcc client-falho.c -o client-falho -lwayland-client
```

Ao executar, você pode receber:
```
Falha na conexão
```

O primeiro passo é ativar o debug do protocolo:
```bash
WAYLAND_DEBUG=1 ./client-falho
```

A saída típica para uma falha de conexão mostra:
```
[1746312.234]  -> wl_display@1.get_registry(new id wl_registry@2)
[1746312.235] error: wl_display@1: error 1: failed to connect to display
```

Neste caso, o código de erro `1` corresponde a `WL_DISPLAY_ERROR_INVALID_OBJECT`, indicando que o caminho do socket Wayland não pôde ser aberto. Os locais comuns onde o Wayland procura o socket são:

1. `$WAYLAND_DISPLAY` (geralmente "wayland-0")
2. `/run/user/<UID>/$WAYLAND_DISPLAY`
3. `/tmp/$WAYLAND_DISPLAY`

Para diagnosticar, verifique se o socket existe:
```bash
ls -l /run/user/$(id -u)/wayland-0
```

Se não existir, seu ambiente provavelmente está executando no X11. Confirme com:
```bash
echo $XDG_SESSION_TYPE
```

Se precisar forçar o Wayland em um ambiente misto (como GNOME), use:
```bash
XDG_SESSION_TYPE=wayland ./client-falho
```

Caso o socket exista mas o cliente ainda falhe, verifique as permissões:
```bash
stat -c "%a %U:%G" /run/user/$(id -u)/wayland-0
```

A saída deve mostrar `600 usuario:usuario`. Se mostrar root ou permissões incorretas, corrija com:
```bash
chmod 600 /run/user/$(id -u)/wayland-0
chown $USER:$USER /run/user/$(id -u)/wayland-0
```

Para casos onde a conexão é estabelecida mas imediatamente fechada, adicione tratamento de erro ao registry:

```c
static void registry_handle_global(void *data, struct wl_registry *registry,
    uint32_t id, const char *interface, uint32_t version) {
    printf("Interface disponível: %s v%u\n", interface, version);
}

static void registry_handle_global_remove(void *data,
    struct wl_registry *registry, uint32_t name) {
    // Chamado quando um global é removido
}

int main() {
    struct wl_registry *registry;
    struct wl_registry_listener registry_listener = {
        .global = registry_handle_global,
        .global_remove = registry_handle_global_remove
    };

    struct wl_display *display = wl_display_connect(NULL);
    // ... verificação de erro anterior ...

    registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    
    // Processa eventos para receber globals
    wl_display_roundtrip(display);

    // ... limpeza ...
}
```

Erros comuns e soluções:

1. **"Permission denied" no socket**: Ocorre quando o usuário não tem acesso ao socket. Solução:
   ```bash
   sudo usermod -aG $(stat -c %G /run/user/$(id -u)/wayland-0) $USER
   ```

2. **"No such file or directory"**: O compositor Wayland não está em execução. Inicie um:
   ```bash
   weston --backend=wayland-backend.so
   ```

3. **"Connection reset by peer"**: O compositor terminou abruptamente. Verifique logs do compositor com:
   ```bash
   journalctl -u weston --since "1 hour ago"
   ```

**Exercício**: Crie um cliente que tenta se conectar a um socket Wayland personalizado. Force um erro de permissão e capture a saída de debug. Depois corrija as permissões e verifique a conexão bem-sucedida.

**Solução**:
```bash
WAYLAND_DISPLAY=custom-socket weston &
sudo chown root:root /run/user/$(id -u)/custom-socket
WAYLAND_DEBUG=1 ./client-falho 2> erro.log
sudo chown $USER:$USER /run/user/$(id -u)/custom-socket
./client-falho
```