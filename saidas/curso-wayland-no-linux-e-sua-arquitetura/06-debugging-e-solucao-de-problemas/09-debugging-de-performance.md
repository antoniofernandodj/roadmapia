## Debugging de performance

Debugging de performance em aplicativos Wayland envolve identificar gargalos na comunicação entre cliente e compositor, bem como problemas de latência e uso de recursos. Um exemplo comum é um aplicativo que funciona corretamente, mas apresenta lentidão ou alto consumo de CPU. Para diagnosticar esses problemas, é necessário entender como o Wayland gerencia buffers, eventos e sincronização.

### Identificando gargalos com `WAYLAND_DEBUG`

A ferramenta `WAYLAND_DEBUG` é essencial para monitorar a comunicação entre cliente e compositor. Ela exibe todas as mensagens trocadas, incluindo timestamps que permitem identificar eventos demorados. Por exemplo, considere um aplicativo que desenha uma interface gráfica simples:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    // Simula uma operação demorada
    sleep(2);

    wl_display_disconnect(display);
    return 0;
}
```

Executando este código com `WAYLAND_DEBUG=1`, você verá uma saída detalhada:

```
[123456789.123456]  -> wl_display@1.get_registry(new id wl_registry@2)
[123456789.123457]  -> wl_registry@2.bind(new id wl_compositor@3, 1)
[123456789.123458]  -> wl_registry@2.bind(new id wl_shm@4, 1)
[123456789.123459]  -> wl_display@1.sync(new id wl_callback@5)
[123456790.123460]  <- wl_callback@5.done(123456790)
```

Aqui, o `sleep(2)` causa uma lacuna de 2 segundos entre o `sync` e o `done`. Isso indica que o aplicativo está bloqueando o loop de eventos, o que pode levar a uma experiência de usuário ruim.

### Analisando consumo de CPU com `strace`

Outro aspecto importante é o consumo de CPU. Ferramentas como `strace` ajudam a identificar chamadas de sistema que consomem muitos recursos. Por exemplo, se um aplicativo está fazendo chamadas repetidas a `write` ou `read`, isso pode indicar um problema de desempenho.

```bash
strace -c ./meu_app_wayland
```

A saída pode mostrar algo como:

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 75.0    0.750000        5000       150           write
 20.0    0.200000        2000       100           read
  5.0    0.050000         500       100           poll
```

Neste caso, o número excessivo de chamadas a `write` sugere que o aplicativo pode estar enviando dados de forma ineficiente para o compositor.

### Diagnóstico de latência com `weston-debug`

Para problemas específicos de latência, `weston-debug` é uma ferramenta útil. Ela permite monitorar eventos específicos, como o momento em que um buffer é anexado ou liberado. Execute o compositor Weston com `weston-debug`:

```bash
weston --debug
```

E observe a saída:

```
[123456789.123456] Compositor: Buffer anexado para janela 0x1234
[123456789.123457] Compositor: Buffer liberado para janela 0x1234
[123456789.123458] Compositor: Frame apresentado para janela 0x1234
```

Se houver uma grande diferença entre o tempo de anexação e liberação, isso pode indicar um problema de sincronização ou gerenciamento de buffers.

### Exercício prático

**Problema:** Um aplicativo Wayland está consumindo muita CPU e apresenta lentidão ao redimensionar janelas. Use `WAYLAND_DEBUG`, `strace` e `weston-debug` para identificar o gargalo.

**Solução:** Primeiro, execute o aplicativo com `WAYLAND_DEBUG=1` para verificar a comunicação com o compositor. Em seguida, use `strace` para monitorar chamadas de sistema e identificar operações repetitivas. Finalmente, use `weston-debug` para observar o gerenciamento de buffers e eventos de redimensionamento.

```bash
WAYLAND_DEBUG=1 ./meu_app_wayland
strace -c ./meu_app_wayland
weston --debug
```

Analisando os logs, você pode descobrir que o aplicativo está fazendo chamadas desnecessárias ao compositor durante o redimensionamento, como anexar buffers múltiplas vezes por frame. A correção envolve otimizar o código para evitar operações redundantes.