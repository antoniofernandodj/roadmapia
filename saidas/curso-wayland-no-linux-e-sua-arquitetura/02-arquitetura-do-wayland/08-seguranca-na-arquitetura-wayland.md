## Segurança na arquitetura Wayland

Um terminal rodando como root no X11 pode capturar todas as suas teclas digitadas, mesmo em outras janelas. Isso acontece porque o X11 permite que qualquer aplicativo monitore eventos globais de teclado. No Wayland, esse tipo de ataque é impossível por design. Vamos entender por quê.

### Isolamento por design

O Wayland implementa um modelo de segurança baseado em princípios mínimos:

```c
// Exemplo de falha de segurança no X11
#include <X11/Xlib.h>

Display *display = XOpenDisplay(NULL);
XGrabKeyboard(display, DefaultRootWindow(display), True, 
              GrabModeAsync, GrabModeAsync, CurrentTime);
// Agora captura TODOS os eventos de teclado do sistema
```

No Wayland, cada cliente recebe apenas os eventos destinados a ele:

```c
// No Wayland, esta operação seria impossível
wl_seat_add_listener(seat, &seat_listener, NULL);
// O listener só receberá eventos quando a janela estiver em foco
```

A diferença fundamental está no protocolo: enquanto o X11 mantém um servidor central que todos os clientes acessam, o Wayland usa conexões diretas e isoladas entre cada cliente e o compositor.

### Protocolo seguro por padrão

O protocolo Wayland implementa três mecanismos de segurança essenciais:

1. **Controle de acesso baseado em sockets Unix**:
   ```bash
   $ ls -l /run/user/1000/wayland-0
   srw-rw---- 1 user user 0 Jul 10 10:00 /run/user/1000/wayland-0
   ```
   Apenas processos do mesmo usuário podem se conectar ao socket do compositor.

2. **Capacidades granulares**:
   ```c
   // Um cliente precisa explicitamente requisitar capacidades
   static void seat_handle_capabilities(void *data, struct wl_seat *seat,
                                       uint32_t capabilities) {
       // Verifica se o teclado está disponível
       if (capabilities & WL_SEAT_CAPABILITY_KEYBOARD) {
           // Configura o teclado
       }
   }
   ```

3. **Input isolation**: O compositor decide quais eventos enviar para cada cliente baseado no foco atual e nas permissões.

### Erros comuns e suas soluções

**Problema**: Um aplicativo não consegue capturar teclas globais para um atalho personalizado.

**Mensagem de erro**:
```
Warning: Keyboard grab failed - access denied by compositor
```

**Solução**: Solicitar a capacidade através do protocolo `xdg_keyboard_shortcuts`:
```c
struct xdg_keyboard_shortcuts *shortcuts = 
    wl_registry_bind(registry, id, &xdg_keyboard_shortcuts_interface, 1);
xdg_keyboard_shortcuts_add_listener(shortcuts, &shortcuts_listener);
```

### Comparação prática de segurança

| Ataque                | X11      | Wayland |
|-----------------------|----------|---------|
| Keylogging            | Possível | Bloqueado |
| Screen capture        | Possível | Requer permissão explícita |
| Window spoofing       | Possível | Bloqueado |
| Input injection       | Possível | Bloqueado |

### Exercício prático

Tente criar um keylogger simples em Wayland. O código abaixo tenta capturar todas as teclas pressionadas:

```c
#include <wayland-client.h>

struct wl_seat *seat;

static void keyboard_keymap(void *data, struct wl_keyboard *keyboard,
                          uint32_t format, int fd, uint32_t size) {
    // Setup do keymap
}

static void keyboard_enter(void *data, struct wl_keyboard *keyboard,
                          uint32_t serial, struct wl_surface *surface,
                          struct wl_array *keys) {
    printf("Foco na janela\n");
}

static void keyboard_leave(void *data, struct wl_keyboard *keyboard,
                          uint32_t serial, struct wl_surface *surface) {
    printf("Janela perdeu foco\n");
}

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    // ... configuração inicial
    
    // Resultado: só receberá eventos quando a janela estiver em foco
    return 0;
}
```

**Solução comentada**: O código acima só receberá eventos quando a janela do aplicativo estiver em foco, demonstrando o isolamento de input do Wayland. Para captura global, seria necessário implementar um protocolo de compositor específico como `org.freedesktop.portal.Desktop`.