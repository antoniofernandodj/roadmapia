## Configurando o ambiente de desenvolvimento

O primeiro obstáculo ao desenvolver para Wayland é a falta de pacotes essenciais. Um ambiente incompleto gera erros críticos como:

```
error: wayland-client.h: No such file or directory
```

### 1. Instalando dependências básicas

No Ubuntu/Debian, execute:

```bash
sudo apt update && sudo apt install -y \
    libwayland-dev \
    libwayland-egl-backend-dev \
    libwayland-cursor-dev \
    wayland-protocols \
    libxkbcommon-dev \
    meson \
    pkg-config
```

Mesmo após instalar, um teste simples pode falhar:

```c
#include <wayland-client.h>
#include <stdio.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Failed to connect to Wayland display\n");
        return 1;
    }
    printf("Connected to Wayland display\n");
    wl_display_disconnect(display);
    return 0;
}
```

Erro comum:
```
gcc test.c -o test
/usr/bin/ld: /tmp/ccX1YHlR.o: in function `main':
test.c:(.text+0x14): undefined reference to `wl_display_connect'
```

A solução está no link correto:

```bash
gcc test.c -o test -lwayland-client
```

### 2. Configurando protocolos personalizados

Wayland utiliza protocolos XML para definir interfaces. Os padrões estão em `/usr/share/wayland-protocols/stable/`, mas projetos específicos exigem protocolos personalizados.

Crie `example-protocol.xml`:

```xml
<protocol name="example">
    <interface name="example_interface" version="1">
        <request name="do_something">
            <arg name="value" type="int"/>
        </request>
        <event name="something_done">
            <arg name="result" type="string"/>
        </event>
    </interface>
</protocol>
```

Gere código C com `wayland-scanner`:

```bash
wayland-scanner client-header example-protocol.xml example-client-protocol.h
wayland-scanner private-code example-protocol.xml example-client-protocol.c
```

### 3. Configurando o sistema de build com Meson

Um `meson.build` mínimo para projeto Wayland:

```meson
project('wayland-example', 'c',
        version: '0.1',
        default_options: ['warning_level=3'])

wayland_client = dependency('wayland-client')
wayland_protos = dependency('wayland-protocols')
xkbcommon = dependency('xkbcommon')

executable('wayland-example',
           'main.c',
           dependencies: [wayland_client, wayland_protos, xkbcommon])
```

Erro típico de nova compilação:

```
Program wayland-scanner found: NO
```

Corrija instalando:

```bash
sudo apt install -y wayland-scanner
```

### 4. Verificando o ambiente Wayland

Para confirmar que está rodando em Wayland:

```bash
echo $XDG_SESSION_TYPE
```

Se retornar "x11", mude para Wayland editando `/etc/gdm3/custom.conf`:

```ini
WaylandEnable=true
```

Reinicie o gdm:

```bash
sudo systemctl restart gdm
```

### 5. Configurando debug

Adicione estas variáveis para depuração:

```bash
export WAYLAND_DEBUG=1
export WLR_LOGS=1
```

Isso gera logs detalhados como:

```
[123456.789]  -> wl_display@1.get_registry(new id wl_registry@2)
[123456.790] wl_display@1.delete_id(2)
```

### Exercício: Ambiente completo

1. Crie um programa que:
   - Conecta ao display Wayland
   - Lista interfaces globais disponíveis
   - Desconecta corretamente

Solução comentada:

```c
#include <wayland-client.h>
#include <stdio.h>

static void registry_handle_global(void *data, struct wl_registry *registry,
                                  uint32_t name, const char *interface,
                                  uint32_t version) {
    printf("Interface: %s (version %d, name %d)\n", interface, version, name);
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
    .global_remove = NULL,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Failed to connect to display\n");
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
gcc registry.c -o registry -lwayland-client
```