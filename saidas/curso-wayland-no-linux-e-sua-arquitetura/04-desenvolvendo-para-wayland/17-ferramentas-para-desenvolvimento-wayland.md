## Ferramentas para desenvolvimento Wayland

Um problema comum ao desenvolver para Wayland surge quando sua aplicação parece funcionar, mas eventos de teclado não chegam ou janelas ficam brancas sem erro aparente. O sistema não fornece mensagens de erro claras por padrão - você precisa das ferramentas certas para enxergar o que acontece nos bastidores.

O primeiro aliado é `wayland-scanner`, que transforma protocolos XML em código C utilizável. Considere este protocolo simples (`example.xml`):

```xml
<protocol name="example">
  <interface name="example_listener" version="1">
    <request name="ping">
      <arg name="value" type="int"/>
    </request>
    <event name="pong">
      <arg name="response" type="uint"/>
    </event>
  </interface>
</protocol>
```

Para gerar o código:

```bash
wayland-scanner client-header example.xml example-client-protocol.h
wayland-scanner private-code example.xml example-client-protocol.c
```

Isso produz estruturas prontas para uso no seu código. Um erro comum é esquecer de incluir os arquivos gerados no sistema de build. O Meson deve conter:

```meson
example_protocol = files('example.xml')
wayland_scanner = find_program('wayland-scanner')
custom_target('example-client-header',
  input: example_protocol,
  output: 'example-client-protocol.h',
  command: [wayland_scanner, 'client-header', '@INPUT@', '@OUTPUT@'])
```

Quando a compilação falha com "undefined reference to `example_listener_interface`", o problema é sempre a falta de link com os arquivos gerados.

Para depuração em tempo real, `WAYLAND_DEBUG=1` é essencial. Execute seu aplicativo com:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

Isso revela a conversa bruta entre cliente e compositor. Um erro típico aparece como:

```
[1678901.234]  -> wl_display@1.get_registry(new id wl_registry@2)
[1678901.456]  -> wl_registry@2.bind(..., "wl_compositor", 4, new id wl_compositor@3)
[ERROR] unknown global 'wl_compositor': version too low (4 < 5)
```

A mensagem indica que seu código pediu a versão 4 do protocolo `wl_compositor`, mas o compositor exige no mínimo a versão 5. A correção está na chamada `wl_registry_bind`.

`weston-terminal` serve como referência e ferramenta de teste. Quando sua aplicação falha ao redimensionar, compare com:

```bash
weston-terminal --maximize
```

Observe como ele lida com buffers durante o redimensionamento. A saída de debug mostrará:

```
[1678902.123] wl_surface@4.commit()
[1678902.124] wl_surface@4.frame(new id wl_callback@5)
[1678902.125] wl_buffer@6.release()
```

O padrão `commit -> frame -> buffer release` é fundamental para animações suaves.

Para inspecionar objetos Wayland ativos, `wl-info` lista interfaces globais:

```bash
$ wl-info
interface: wl_compositor, version: 5
interface: wl_shm, version: 1
interface: xdg_wm_base, version: 3
```

Isso ajuda a diagnosticar quando um protocolo necessário não está disponível. A ausência de `xdg_wm_base` causaria falhas em aplicações modernas.

Quando precisar testar buffers gráficos, `wldbg` permite inspeção interativa:

```bash
wldbg -s /run/user/1000/wayland-0
> list-surfaces
Surface 1 (width: 800, height: 600)
> inspect-surface 1
Buffer format: WL_SHM_FORMAT_ARGB8888
```

Um erro comum aparece ao tentar usar formatos não suportados:

```
[ERROR] wl_shm@10.create_pool(format: 1) not supported
```

Verifique os formatos disponíveis com `wl_shm_format` antes de alocar buffers.

Para aplicações GTK/Qt, variáveis especiais ativam logs detalhados:

```bash
GDK_DEBUG=gl-grab,gl-flush QT_LOGGING_RULES=qt.qpa.*=true ./meu_app_gtk
```

Isso revela problemas como falhas no binding de buffers OpenGL.

**Exercício**: Crie um cliente mínimo que liste todas as interfaces globais disponíveis e suas versões, usando `wl_registry`. Compare sua saída com `wl-info`.

**Solução**:

```c
#include <wayland-client.h>
#include <stdio.h>

static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t id, const char *interface, uint32_t version) {
    printf("interface: %s, version: %u\n", interface, version);
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
};

int main(int argc, char **argv) {
    struct wl_display *display = wl_display_connect(NULL);
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
gcc -o list-globals list-globals.c -lwayland-client
```

A saída deve corresponder a `wl-info`, validando seu ambiente Wayland.