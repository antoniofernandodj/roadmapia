## Debugging de aplicativos Wayland

Quando um aplicativo Wayland não se comporta como esperado - janelas que não aparecem, eventos de entrada ignorados ou travamentos inexplicáveis - precisamos de ferramentas específicas para investigar. Diferente de X11, onde ferramentas como `xwininfo` ou `xev` funcionam, no Wayland precisamos de abordagens mais próximas do protocolo.

### WAYLAND_DEBUG: O primeiro passo

A variável de ambiente `WAYLAND_DEBUG` é nossa aliada primária. Quando definida como `1`, exibe toda a comunicação entre cliente e compositor no terminal:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

A saída mostra cada mensagem trocada:

```
[17141232.456]  -> wl_display@1.get_registry(new id wl_registry@2)
[17141232.458] wl_display@1.delete_id(2)
[17141232.460]  -> wl_registry@2.bind(1, "wl_compositor", 4, new id [unknown]@3)
```

**Erro comum**: esquecer que `WAYLAND_DEBUG` exibe apenas a comunicação bruta, sem interpretação. Para entender os números mágicos (como `4` no exemplo), consulte os protocolos XML.

### wl_display_get_error: Diagnóstico programático

Quando um aplicativo falha silenciosamente, `wl_display_get_error` revela o último erro ocorrido:

```c
int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha na conexão\n");
        return 1;
    }
    
    // ... código do aplicativo ...
    
    int error = wl_display_get_error(display);
    if (error) {
        fprintf(stderr, "Erro Wayland: %d (%s)\n", error, strerror(error));
    }
    
    wl_display_disconnect(display);
    return 0;
}
```

Possíveis erros incluem:
- `EPIPE`: Conexão perdida com o compositor
- `EPROTO`: Violação do protocolo Wayland
- `ENOMEM`: Falha na alocação de recursos

### weston-terminal: Um cliente especial

O cliente `weston-terminal` (parte da referência Weston) aceita argumentos para debug:

```bash
weston-terminal --log=/tmp/wayland.log --color=never
```

Isso grava um log detalhado em `/tmp/wayland.log`, útil para:
- Verificar criação de superfícies
- Monitorar eventos de entrada
- Identificar violações de protocolo

### Debugging gráfico com GTK_DEBUG

Para aplicativos GTK, a variável `GTK_DEBUG` oferece insights:

```bash
GTK_DEBUG=interactive ./meu_app_gtk
```

Isso habilita:
- Console interativo com `Ctrl+Shift+D`
- Inspeção de hierarquia de widgets
- Log de eventos Wayland específicos

### Erro real: Superfície sem buffer

Um erro comum é criar uma superfície mas esquecer de anexar um buffer:

```c
struct wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_commit(surface);  // ERRO: surface sem buffer
```

A mensagem de erro típica no log do compositor será:
```
warning: client bug: wl_surface@4: error 1: no buffer attached
```

Solução correta:
```c
// Criar buffer via wl_shm...
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_commit(surface);
```

### Exercício: Debugging de evento de teclado

Um aplicativo não está respondendo a teclas. O código do listener é:

```c
static void keyboard_keymap(void *data, struct wl_keyboard *keyboard,
                           uint32_t format, int fd, uint32_t size) {
    // Implementação vazia
}
```

**Problema**: O listener está registrado mas não implementa `keyboard_key`. Solução:

```c
static struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
    .key = keyboard_key,  // Adicionado
    // ... outros callbacks
};

static void keyboard_key(void *data, struct wl_keyboard *keyboard,
                        uint32_t serial, uint32_t time, uint32_t key,
                        uint32_t state) {
    printf("Tecla %d %s\n", key, state ? "pressionada" : "liberada");
}
```

Com `WAYLAND_DEBUG=1`, agora vemos as mensagens `keyboard_key` sendo recebidas.

### Ferramentas externas úteis

1. **wldbg**: Depurador Wayland interativo
   ```bash
   wldbg -c ./meu_app
   ```

2. **wayland-info**: Lista interfaces disponíveis
   ```bash
   wayland-info
   ```

3. **swaymsg -t get_tree**: No Sway, mostra a árvore de janelas