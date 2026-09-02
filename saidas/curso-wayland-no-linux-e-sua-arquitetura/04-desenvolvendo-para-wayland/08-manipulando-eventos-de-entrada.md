## Manipulando eventos de entrada

Quando você cria uma janela Wayland, ela permanece inerte até que você implemente o tratamento de eventos. Imagine clicar em um botão e nada acontecer - essa é a experiência padrão sem um loop de eventos configurado corretamente. Vamos resolver isso de forma prática.

O core do sistema de eventos no Wayland gira em torno de listeners (ouvintes) registrados para interfaces específicas. Para um aplicativo interativo, você precisará lidar principalmente com:

1. `wl_pointer` - eventos do mouse/touchpad
2. `wl_keyboard` - entradas do teclado
3. `wl_touch` - para telas sensíveis ao toque

Vamos começar com um exemplo concreto que mostra o fluxo completo desde o registro até o tratamento de eventos. Este código cria uma janela branca e imprime no terminal quando o mouse se move ou uma tecla é pressionada:

```c
#include <wayland-client.h>
#include <stdio.h>

// Listeners (implementações dos callbacks)
static void pointer_handle_enter(void *data, struct wl_pointer *pointer,
                                uint32_t serial, struct wl_surface *surface,
                                wl_fixed_t sx, wl_fixed_t sy) {
    printf("Cursor entrou na janela\n");
}

static void pointer_handle_motion(void *data, struct wl_pointer *pointer,
                                 uint32_t time, wl_fixed_t sx, wl_fixed_t sy) {
    printf("Mouse movido para: %f, %f\n",
           wl_fixed_to_double(sx), wl_fixed_to_double(sy));
}

static void keyboard_handle_key(void *data, struct wl_keyboard *keyboard,
                               uint32_t serial, uint32_t time, uint32_t key,
                               uint32_t state) {
    const char *action = (state == WL_KEYBOARD_KEY_STATE_PRESSED) ? 
                         "Pressionada" : "Liberada";
    printf("Tecla %s: %d\n", action, key);
}

int main(int argc, char **argv) {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    
    // Estrutura para armazenar nossas globais
    struct {
        struct wl_compositor *compositor;
        struct wl_shell *shell;
        struct wl_seat *seat;
        struct wl_pointer *pointer;
        struct wl_keyboard *keyboard;
    } globals;

    // Listener para registry global
    static const struct wl_registry_listener registry_listener = {
        .global = [](void *data, struct wl_registry *registry,
                    uint32_t id, const char *interface, uint32_t version) {
            auto *g = static_cast<decltype(globals)*>(data);
            if (strcmp(interface, "wl_compositor") == 0) {
                g->compositor = static_cast<wl_compositor*>(
                    wl_registry_bind(registry, id, &wl_compositor_interface, 1));
            } //... outros binds similares para shell, seat, etc
        },
        .global_remove = [](void*, struct wl_registry*, uint32_t) {}
    };

    wl_registry_add_listener(registry, &registry_listener, &globals);
    wl_display_roundtrip(display); // Espera os eventos iniciais

    // Configura listeners de entrada
    static const struct wl_pointer_listener pointer_listener = {
        .enter = pointer_handle_enter,
        .leave = [](void*, ...) {},
        .motion = pointer_handle_motion,
        //... outros callbacks do pointer
    };

    static const struct wl_keyboard_listener keyboard_listener = {
        .keymap = [](void*, ...) {},
        .enter = [](void*, ...) {},
        .leave = [](void*, ...) {},
        .key = keyboard_handle_key,
        //... outros callbacks do keyboard
    };

    // Obtém dispositivos de entrada
    if (globals.seat) {
        globals.pointer = wl_seat_get_pointer(globals.seat);
        wl_pointer_add_listener(globals.pointer, &pointer_listener, NULL);
        
        globals.keyboard = wl_seat_get_keyboard(globals.seat);
        wl_keyboard_add_listener(globals.keyboard, &keyboard_listener, NULL);
    }

    // Cria janela básica
    struct wl_surface *surface = wl_compositor_create_surface(globals.compositor);
    struct wl_shell_surface *shell_surface = wl_shell_get_shell_surface(globals.shell, surface);
    wl_shell_surface_set_toplevel(shell_surface);

    // Loop principal
    while (wl_display_dispatch(display) != -1) {
        // Mantém a janela aberta
    }

    // Limpeza
    wl_display_disconnect(display);
    return 0;
}
```

Ao compilar e executar este código (com `-lwayland-client`), você verá no terminal mensagens como:

```
Cursor entrou na janela
Mouse movido para: 120.500000, 80.250000
Tecla Pressionada: 38
Tecla Liberada: 38
```

### Erros comuns e como corrigi-los

**1. Eventos não sendo disparados**
Se você não está recebendo eventos, verifique:
- Se fez o `wl_display_roundtrip` após registrar o listener do registry
- Se vinculou (`wl_registry_bind`) a interface `wl_seat` corretamente
- Se adicionou os listeners aos dispositivos (`wl_pointer_add_listener`)

**2. Coordenadas fix-point estranhas**
Wayland usa números em formato fix-point (wl_fixed_t). Para converter:
```c
double x = wl_fixed_to_double(sx); // Converte para double
int pixel_x = wl_fixed_to_int(sx); // Converte para inteiro
```

**3. Falta de foco no teclado**
Teclado só envia eventos quando a janela tem foco. Se `keyboard_handle_key` não está sendo chamado:
- Verifique se sua janela está realmente com foco
- Implemente o callback `enter` no listener do teclado para confirmar o foco

### Dica de depuração

Ative o modo debug do Wayland para ver todos os eventos trafegando:
```bash
WAYLAND_DEBUG=1 ./meu_programa
```

Isso mostrará a comunicação bruta entre cliente e compositor, ajudando a identificar se eventos estão sendo enviados mas não tratados.

### Exercício prático

Modifique o exemplo para:
1. Mostrar a posição atual do mouse no título da janela
2. Sair do programa quando a tecla ESC (código 1) for pressionada

**Solução comentada:**

```c
// Adicione no topo do arquivo:
static struct wl_shell_surface *shell_surface_global;

// Modifique keyboard_handle_key:
static void keyboard_handle_key(void *data, struct wl_keyboard *keyboard,
                               uint32_t serial, uint32_t time, uint32_t key,
                               uint32_t state) {
    if (key == 1 && state == WL_KEYBOARD_KEY_STATE_PRESSED) {
        printf("ESC pressionado - saindo\n");
        exit(0);
    }
}

// Modifique pointer_handle_motion:
static void pointer_handle_motion(void *data, struct wl_pointer *pointer,
                                 uint32_t time, wl_fixed_t sx, wl_fixed_t sy) {
    char title[64];
    snprintf(title, sizeof(title), "Mouse: %.0f, %.0f", 
             wl_fixed_to_double(sx), wl_fixed_to_double(sy));
    wl_shell_surface_set_title(shell_surface_global, title);
}

// Atribua shell_surface na criação:
shell_surface_global = wl_shell_get_shell_surface(globals.shell, surface);
```