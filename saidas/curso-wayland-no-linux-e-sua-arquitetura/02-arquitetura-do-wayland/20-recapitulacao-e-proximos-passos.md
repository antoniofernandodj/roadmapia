## Recapitulação e próximos passos

A arquitetura do Wayland opera como um sistema cliente-servidor moderno onde o compositor gerencia exclusivamente a exibição gráfica e eventos de entrada. Ao contrário do X11, que utiliza um modelo centralizado com o X Server, o Wayland delega responsabilidades:

```c
// Exemplo mínimo de conexão Wayland
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar: verifique se o compositor está ativo\n");
        return 1;
    }
    
    struct wl_registry *registry = wl_display_get_registry(display);
    // ... bind globais como wl_compositor
    wl_display_roundtrip(display);  // Sincronização crítica
    
    wl_display_disconnect(display);
}
```

Saída esperada (quando bem-sucedido):
```
Conectado ao socket Wayland em /run/user/1000/wayland-0
```

Os componentes-chave que vimos funcionam em conjunto:

1. **Compositor** (weston, Mutter, KWin) - Responsável pela:
   - Composição gráfica final
   - Gerenciamento de superfícies (`wl_surface`)
   - Roteamento de eventos de input

2. **Clientes** - Aplicativos que:
   - Alocam buffers via `wl_shm`
   - Registram callbacks para eventos
   - Enviam requisições assíncronas

3. **Protocolo** - Define as regras de comunicação através de:
   - Interfaces (ex: `wl_output`, `wl_seat`)
   - Mensagens (events e requests)
   - Sockets Unix para isolamento

Erro típico ao migrar do X11:
```c
// TENTATIVA INCORRETA (estilo X11)
XCreateWindow(display, parent, x, y, width, height, ...);  // Não existe em Wayland

// FORMA CORRETA (Wayland)
struct wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_commit(surface);  // Sincronização explícita
```

Mensagem de erro que você encontraria:
```
error: implicit declaration of function ‘XCreateWindow’ 
   | No such protocol in Wayland architecture
```

A segurança avançada do modelo se manifesta em:
- Isolamento por socket (cada usuário tem seu `/run/user/$UID/wayland-0`)
- Capacidades granulares (teclado/mouse exigem `wl_seat` ativo)
- Sem acesso direto a framebuffers ou dispositivos RAW

Para verificar sua configuração atual:
```sh
$ weston-info
Output:
interface: 'wl_output', version: 3, name: 42
  modes:
    1920x1080@60.0Hz
```

**Exercício Prático**:  
Modifique o código de conexão inicial para:
1. Listar todas as interfaces globais disponíveis
2. Calcular o tempo de roundtrip com `wl_display_get_serial()`
3. Validar se a interface `wl_shm` está presente

Solução comentada:
```c
struct wl_registry_listener registry_listener = {
    .global = [](void *data, auto, uint32_t name, const char *interface, uint32_t) {
        printf("Interface %d: %s\n", name, interface);
    }
};

wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display);  // Garante recebimento

uint32_t serial = wl_display_get_serial(display);
printf("Roundtrip serial: %u\n", serial);
```

O próximo capítulo aplicará esses conceitos na configuração prática de ambientes Wayland, incluindo:
- Seleção de compositor
- Variáveis de ambiente críticas (`XDG_RUNTIME_DIR`)
- Debugging com `WAYLAND_DEBUG=1`