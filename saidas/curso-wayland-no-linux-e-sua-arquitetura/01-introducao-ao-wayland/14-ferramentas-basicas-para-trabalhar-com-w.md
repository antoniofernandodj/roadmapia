## Ferramentas básicas para trabalhar com Wayland

Para desenvolver e depurar aplicativos Wayland, é essencial conhecer as ferramentas disponíveis no ecossistema. Estas ferramentas ajudam a inspecionar o comportamento de aplicativos, testar protocolos e identificar problemas de compatibilidade. Vamos explorar as principais ferramentas e como utilizá-las.

### `weston` — O Compositor de Referência

O `weston` é o compositor de referência para Wayland, usado para testar aplicativos e protocolos. Ele é leve e fácil de configurar, tornando-o ideal para experimentação. Para iniciar o Weston, basta executar:

```bash
weston
```

Isso abrirá uma sessão Wayland básica, onde você pode testar aplicativos. Se você encontrar problemas com drivers gráficos, tente especificar o backend manualmente:

```bash
weston --backend=drm-backend.so
```

Saída esperada:
```
Weston 10.0.0 started.
Initializing drm backend...
```

Se você receber um erro como `Failed to initialize DRM backend`, verifique se o driver gráfico está instalado corretamente e se o hardware suporta Wayland.

### `wayland-info` — Inspecionando Protocolos Suportados

O `wayland-info` é uma ferramenta simples que lista os protocolos suportados pelo compositor atual. Execute-o em uma sessão Wayland para ver quais interfaces estão disponíveis:

```bash
wayland-info
```

Saída esperada:
```
Interface: wl_compositor, Version: 4
Interface: wl_shm, Version: 1
Interface: xdg_wm_base, Version: 2
...
```

Isso é útil para verificar se um protocolo específico está disponível antes de tentar usá-lo em um aplicativo.

### `wayland-debug` — Depurando Comunicação de Protocolos

O `wayland-debug` é uma ferramenta poderosa para depurar a comunicação entre clientes e o compositor. Ele captura todas as mensagens enviadas e recebidas, permitindo identificar problemas de negociação ou implementação. Para usá-lo, inicie o Weston com o modo de depuração:

```bash
WAYLAND_DEBUG=1 weston
```

Em outro terminal, execute um aplicativo Wayland:

```bash
WAYLAND_DEBUG=1 wayland-client-example
```

Saída esperada:
```
[12345.678]  -> wl_display@1.get_registry(new id wl_registry@2)
[12345.679] wl_display@1.delete_id(2)
...
```

Cada mensagem é registrada com um timestamp e detalhes sobre o objeto e a interface envolvidos. Isso é especialmente útil para entender como os protocolos são negociados em tempo de execução.

### `wlroots` — Biblioteca para Compositors Personalizados

O `wlroots` é uma biblioteca modular para criar compositors Wayland personalizados. Ele fornece uma base sólida para implementar funcionalidades específicas, como gerenciamento de janelas ou suporte a hardware especializado. Para testar uma implementação básica com `wlroots`, clone o repositório e compile o exemplo:

```bash
git clone https://github.com/swaywm/wlroots.git
cd wlroots
meson build
ninja -C build
./build/example/simple
```

Saída esperada:
```
Initializing wlroots...
Compositor ready.
```

Se você receber um erro como `Failed to initialize EGL`, verifique se o OpenGL ES 2.0 ou Vulkan está instalado corretamente.

### Exercício Prático: Testando um Protocolo com `weston`

1. Inicie o Weston em um terminal:
   ```bash
   weston
   ```

2. Em outro terminal, execute o `wayland-info` para listar os protocolos suportados:
   ```bash
   wayland-info
   ```

3. Verifique se o protocolo `wl_shm` está presente na lista. Caso esteja, crie um aplicativo básico que utilize esse protocolo para criar uma superfície compartilhada.

4. Compile e execute o aplicativo. Se tudo estiver correto, você verá uma janela simples renderizada no Weston.

### Solução do Exercício

Aqui está um exemplo mínimo de um aplicativo que usa `wl_shm` para criar uma superfície compartilhada:

```c
#include <wayland-client.h>
#include <stdio.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao display Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!shm) {
        fprintf(stderr, "Protocolo wl_shm não suportado\n");
        return 1;
    }

    printf("Protocolo wl_shm está disponível\n");
    wl_display_disconnect(display);
    return 0;
}
```

Compile com:
```bash
gcc -o shm-test shm-test.c -lwayland-client
```

Execute o aplicativo no Weston e verifique se ele imprime `Protocolo wl_shm está disponível` no terminal.