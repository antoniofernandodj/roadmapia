## Ferramentas para analisar a arquitetura Wayland

Para entender e depurar a arquitetura Wayland, é essencial conhecer as ferramentas que permitem inspecionar o comportamento do compositor, dos clientes e da comunicação entre eles. Vamos explorar algumas das principais ferramentas disponíveis para análise.

### `weston-info`

O `weston-info` é uma ferramenta simples que exibe informações básicas sobre o ambiente Wayland em execução. Ele lista as interfaces globais disponíveis, monitores conectados e outras informações úteis. Para usá-lo, basta executar o comando no terminal:

```bash
weston-info
```

A saída será algo como:

```
interface: 'wl_compositor', version: 4, name: 1
interface: 'wl_shm', version: 1, name: 2
interface: 'wl_output', version: 3, name: 3
output 0:
  name: 'HDMI-A-1'
  modes: 1920x1080@60.0Hz
```

Isso mostra as interfaces globais oferecidas pelo compositor, como `wl_compositor` e `wl_shm`, além de informações sobre os monitores conectados.

### `WAYLAND_DEBUG`

A variável de ambiente `WAYLAND_DEBUG` é uma ferramenta poderosa para depurar a comunicação entre clientes e o compositor. Quando definida como `1`, ela exibe todas as mensagens enviadas e recebidas pelo cliente Wayland.

Para usar o `WAYLAND_DEBUG`, execute o cliente com a variável definida:

```bash
WAYLAND_DEBUG=1 weston-terminal
```

A saída será detalhada, mostrando cada request e event:

```
[3012323.123]  -> wl_display@1.get_registry(new id wl_registry@2)
[3012323.124]  <- wl_registry@2.global(1, "wl_compositor", 4)
```

Isso permite inspecionar a sequência de operações e identificar possíveis problemas na comunicação.

### `wl_display_roundtrip`

O `wl_display_roundtrip` é uma função que garante que todas as mensagens pendentes sejam processadas antes de continuar. Isso é útil para garantir sincronização e evitar problemas de latência.

```c
wl_display_roundtrip(display);
```

Essa função bloqueia até que todas as mensagens enviadas pelo cliente sejam processadas pelo compositor e todas as respostas sejam recebidas.

### `weston-debug`

O `weston-debug` é uma ferramenta específica para depurar o compositor Weston. Ele permite inspecionar o estado interno do compositor, como superfícies ativas, buffers e eventos de entrada.

Para usar o `weston-debug`, execute o Weston com a opção `--debug`:

```bash
weston --debug
```

Em seguida, conecte-se ao Weston usando `weston-debug`:

```bash
weston-debug
```

Isso fornece acesso a informações detalhadas sobre o estado do compositor, útil para identificar problemas complexos.

### `wl_list`

O `wl_list` é uma estrutura de dados interna do Wayland usada para gerenciar listas de recursos. Embora não seja uma ferramenta de depuração direta, entender como o `wl_list` funciona pode ajudar a identificar problemas de gerenciamento de recursos.

```c
struct wl_list {
    struct wl_list *prev;
    struct wl_list *next;
};
```

O `wl_list` é usado para manter listas de recursos como superfícies, buffers e eventos. Verificar se os recursos estão sendo corretamente adicionados e removidos dessas listas pode evitar vazamentos de memória.

### Exercício Prático

Para consolidar o uso dessas ferramentas, vamos criar um cliente simples que se conecta ao compositor Wayland e lista as interfaces globais disponíveis. Compile e execute o seguinte código:

```c
#include <wayland-client.h>
#include <stdio.h>

static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t name, const char *interface, uint32_t version) {
    printf("Interface global: %s (versão: %d)\n", interface, version);
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
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

Compile com:

```bash
gcc -o wayland-client wayland-client.c -lwayland-client
```

Execute o cliente:

```bash
./wayland-client
```

A saída será algo como:

```
Interface global: wl_compositor (versão: 4)
Interface global: wl_shm (versão: 1)
Interface global: wl_output (versão: 3)
```

Isso demonstra o uso prático das ferramentas para analisar a arquitetura Wayland.