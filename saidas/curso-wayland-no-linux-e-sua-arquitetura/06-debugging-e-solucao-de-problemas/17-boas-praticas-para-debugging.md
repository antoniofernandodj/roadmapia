## Boas práticas para debugging

Um aplicativo Wayland falha silenciosamente ao tentar redimensionar a janela. Sem mensagens de erro visíveis, o problema parece insolúvel até que você ativa o modo verboso:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

A saída revela a sequência exata de eventos:

```
[1734923.423]  -> wl_surface@12.attach(wl_buffer@13, 0, 0)
[1734923.425]  -> wl_surface@12.commit()
[1734923.427] error wl_display@1: error 1 (invalid object) wl_buffer@13
```

O erro "invalid object" ocorre quando o cliente tenta usar um buffer gráfico que já foi liberado. Este é um padrão comum em aplicações Wayland que não gerenciam corretamente o ciclo de vida dos buffers. O código correto deve:

1. Criar um novo buffer para cada redimensionamento
2. Manter uma referência até receber o evento de release
3. Só então reutilizar ou destruir o objeto

```c
// Exemplo completo de gerenciamento de buffers
static void buffer_release(void *data, struct wl_buffer *buffer) {
    // Marca o buffer como disponível para reuso
    *(bool *)data = true;
}

int main() {
    struct wl_buffer_listener buffer_listener = {
        .release = buffer_release
    };
    
    bool buffer_available = true;
    struct wl_buffer *buffer = create_buffer();
    wl_buffer_add_listener(buffer, &buffer_listener, &buffer_available);
    
    while (1) {
        if (buffer_available) {
            buffer_available = false;
            wl_surface_attach(surface, buffer, 0, 0);
            wl_surface_commit(surface);
        }
        wl_display_dispatch(display);
    }
}
```

A combinação de `WAYLAND_DEBUG` com `strace` revela problemas mais profundos:

```bash
WAYLAND_DEBUG=1 strace -f -e poll,read,write ./meu_app 2> strace.log
```

A análise conjunta mostra:
1. O cliente envia o buffer (log Wayland)
2. O compositor responde com erro (log Wayland)
3. O sistema bloqueia em `poll()` (strace) porque o cliente não trata o erro

Para eventos de entrada, um padrão comum é a falta de listeners. Este código falha silenciosamente:

```c
struct wl_seat *seat = ...; // Obtido do registry
// Faltam os listeners para keyboard e pointer
```

A correção requer registro explícito:

```c
static void seat_capabilities(void *data, struct wl_seat *seat,
                             uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_KEYBOARD) {
        struct wl_keyboard *keyboard = wl_seat_get_keyboard(seat);
        wl_keyboard_add_listener(keyboard, &keyboard_listener, NULL);
    }
    // Similar para pointer, touch...
}

struct wl_seat_listener seat_listener = {
    .capabilities = seat_capabilities
};
```

Quando o problema envolve vazamentos de memória, `valgrind` com supressões específicas é essencial:

```bash
valgrind --suppressions=/usr/share/gtk-3.0/valgrind/gtk.supp \
         --leak-check=full ./meu_app
```

A saída típica mostra:

```
==12345== 120 bytes in 3 blocks are definitely lost
==12345==    at 0x483B7F3: malloc (vg_replace_malloc.c:307)
==12345==    by 0x48A2A5B: create_buffer (client.c:123)
==12345==    by 0x48A3C21: main (client.c:456)
```

Para problemas complexos de sincronização, `gdb` com breakpoints condicionais ajuda:

```
(gdb) break client.c:456 if buffer_id == 0xdeadbeef
(gdb) watch -l buffer->resource
```

### Exercício: Debugging de renderização intermitente
Um aplicativo exibe frames apenas ocasionalmente. Com `WAYLAND_DEBUG=1`, você observa:

```
[1734923.423]  -> wl_surface@12.attach(buffer, 0, 0)
[1734923.425]  -> wl_surface@12.damage(0, 0, 320, 240)
// Falta o commit!
```

**Solução**: O problema está na falta de chamada a `wl_surface_commit()`. O código correto deve:

```c
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_damage(surface, 0, 0, width, height);
wl_surface_commit(surface); // Esta linha estava faltando
```