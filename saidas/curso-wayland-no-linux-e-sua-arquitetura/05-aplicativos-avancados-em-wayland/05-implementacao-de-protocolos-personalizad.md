## Implementação de protocolos personalizados

Wayland permite extensão através de protocolos adicionais além do core. Quando um aplicativo precisa de funcionalidades específicas (como controle de brilho da tela ou notificações personalizadas), implementamos protocolos customizados. Veja como criar um protocolo `demo_extension` que adiciona um comando simples de rotação de janela:

1. **Definição do protocolo XML** (salvo como `demo-extension.xml`):
```xml
<protocol name="demo_extension">
  <interface name="demo_window" version="1">
    <request name="rotate">
      <arg name="degrees" type="int"/>
    </request>
    <event name="rotation_done"/>
  </interface>
</protocol>
```

2. **Geração do código C** (via `wayland-scanner`):
```bash
wayland-scanner client-header demo-extension.xml demo-extension-client.h
wayland-scanner private-code demo-extension.xml demo-extension-protocol.c
```

3. **Implementação no cliente**:
```c
#include "demo-extension-client.h"

struct demo_window *window;
// Durante a criação da janela:
window = wl_registry_bind(registry, id, &demo_window_interface, version);

// Rotaciona a janela em 90 graus
demo_window_rotate(window, 90);
```

O erro clássico ocorre ao esquecer de verificar a versão do protocolo. Se o compositor não suportar sua versão, você receberá:
```
error: bind error: invalid version (3) for 'demo_window' (max 1)
```

A correção é verificar a versão disponível durante a ligação:
```c
uint32_t available_version = ...; // obtido do registry
uint32_t our_version = 1;
uint32_t version = (available_version < our_version) ? available_version : our_version;
window = wl_registry_bind(registry, id, &demo_window_interface, version);
```

No lado do compositor, a implementação requer:

1. **Registro do protocolo**:
```c
static void registry_add(void *data, struct wl_registry *registry,
                        uint32_t name, const char *interface, uint32_t version) {
    if (strcmp(interface, "demo_window") == 0) {
        struct demo_window *window = ...;
        wl_global_create(registry, &demo_window_interface,
                        min(version, 1), NULL, bind_window);
    }
}
```

2. **Implementação da rotação**:
```c
static void handle_rotate(struct wl_client *client, struct wl_resource *resource,
                          int degrees) {
    // Lógica real de rotação aqui
    demo_window_send_rotation_done(resource);
}
```

Para testar, crie um cliente que usa seu protocolo e verifique com `weston-info` se o protocolo aparece listado. Um protocolo mal implementado causará erros como:
```
warning: client requested unknown interface 'demo_window' (1)
```

**Exercício**: Implemente um protocolo `screenshot` que permite ao cliente solicitar capturas de tela do compositor. O protocolo deve incluir:
- Um request `capture` com formato (png/jpg) e qualidade como parâmetros
- Um event `image_ready` com um file descriptor para a imagem
- Tratamento de erro quando o formato não é suportado

**Solução comentada**:
```xml
<!-- screenshot.xml -->
<protocol name="screenshot">
  <interface name="screenshot_manager" version="1">
    <request name="capture">
      <arg name="format" type="string"/>
      <arg name="quality" type="int"/>
    </request>
    <event name="image_ready">
      <arg name="fd" type="fd"/>
    </event>
    <event name="error">
      <arg name="message" type="string"/>
    </event>
  </interface>
</protocol>
```
No cliente:
```c
screenshot_manager_capture(manager, "png", 90);
```
No compositor:
```c
static void handle_capture(...) {
    if (strcmp(format, "png") != 0) {
        screenshot_manager_send_error(resource, "Formato não suportado");
        return;
    }
    int fd = create_screenshot_file(format, quality);
    screenshot_manager_send_image_ready(resource, fd);
    close(fd); // O fd é duplicado para o cliente automaticamente
}
```