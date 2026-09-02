## Exercícios práticos: explorando o ambiente Wayland

### 1. Inspecionando protocolos Wayland ativos

Todo aplicativo Wayland começa negociando protocolos com o compositor. Vamos usar `weston-info` para listar os protocolos disponíveis:

```bash
weston-info | grep -A5 'interface'
```

Saída típica (exemplo real do GNOME Shell):

```
interface: 'wl_compositor', version: 4
interface: 'wl_shm', version: 1
interface: 'wl_drm', version: 2
interface: 'zwp_linux_dmabuf_v1', version: 3
```

**O que deu errado?** Se você executar sem o Weston ativo, verá:

```
Failed to connect to Wayland display: No such file or directory
```

Solução: inicie uma sessão Weston temporária em outro terminal:

```bash
weston --backend=wayland-backend.so --socket=exercicio &
DISPLAY= WAYLAND_DISPLAY=exercicio weston-info
```

### 2. Criando um client Wayland mínimo

Vamos criar um programa C que apenas conecta ao compositor e lista protocolos:

```c
// wayland-test.c
#include <wayland-client.h>
#include <stdio.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha na conexão Wayland\n");
        return 1;
    }
    
    printf("Conectado ao compositor Wayland (FD %d)\n",
           wl_display_get_fd(display));
    
    wl_display_disconnect(display);
    return 0;
}
```

Compile e execute:

```bash
gcc wayland-test.c -o wayland-test -lwayland-client
./wayland-test
```

Saída esperada (o número varia):

```
Conectado ao compositor Wayland (FD 3)
```

**Erro comum:** falta do `-lwayland-client` gera:

```
/usr/bin/ld: modo de ligação não contém _start; não pode usar o formato de saída padrão
collect2: error: ld returned 1 exit status
```

### 3. Monitorando eventos Wayland

Modifique o programa anterior para registrar eventos globais:

```c
// [...] após wl_display_connect
struct wl_registry *registry = wl_display_get_registry(display);
wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display);  // Processa respostas
```

Implemente o listener:

```c
static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t id, const char *interface,
                                  uint32_t version) {
    printf("Interface: %s (v%d)\n", interface, version);
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
};
```

Saída típica listará dezenas de interfaces, incluindo:

```
Interface: wl_compositor (v4)
Interface: wl_seat (v7)
Interface: zxdg_output_manager_v1 (v3)
```

### 4. Testando compartilhamento de buffers

O protocolo `wl_shm` permite criar buffers de memória compartilhada. Execute:

```bash
WAYLAND_DEBUG=1 weston-simple-shm
```

Na saída de debug (que aparece no terminal), procure por:

```
[1947831.525] wl_shm@8.format(0)
[1947831.541] wl_shm@8.format(1)
[1947831.541] wl_shm@8.format(2)
```

Cada `format` representa um pixel format suportado (ex: ARGB8888).

**Exercício:** Modifique `wayland-test.c` para contar quantas interfaces do tipo `wl_shm` estão disponíveis. Solução:

```c
static int shm_count = 0;

static void registry_handle_global(void *data, /*...*/) {
    if (strcmp(interface, "wl_shm") == 0) {
        shm_count++;
    }
    // [...] imprima shm_count antes de sair
}
```

### 5. Comparando sessões X11 e Wayland

Execute o mesmo programa em ambos os ambientes:

```bash
# No Wayland
./wayland-test

# No X11 (force via XWayland)
env -u WAYLAND_DISPLAY ./wayland-test
```

Diferenças chave observáveis:
- No X11, `wl_display_connect` falha (retorna NULL)
- Wayland mostra interfaces específicas como `zwlr_layer_shell_v1`
- XWayland expõe menos protocolos nativos