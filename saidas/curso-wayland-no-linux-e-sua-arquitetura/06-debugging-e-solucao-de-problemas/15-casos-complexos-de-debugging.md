## Casos complexos de debugging

Quando um aplicativo Wayland se comporta de modo inesperado - janelas congelam, eventos de entrada desaparecem ou buffers gráficos corrompem - a depuração exige entender o fluxo completo da comunicação entre cliente e compositor. Vamos abordar três cenários complexos típicos:

### 1. Janela que congela durante redimensionamento

Um problema comum ocorre quando o usuário tenta redimensionar uma janela e a aplicação para de responder. Vamos simular esse erro propositalmente:

```c
// código problemático
void resize_window(struct window *window, int width, int height) {
    wl_surface_attach(window->surface, NULL, 0, 0); // ERRO: buffer NULL
    wl_surface_commit(window->surface);
}
```

Ao executar com `WAYLAND_DEBUG=1`, o log mostrará:

```
[17108672.234]  -> wl_surface@4.attach(NULL, 0, 0)
[17108672.245]  -> wl_surface@4.commit()
[17108672.251] error wl_display@1: error 2 (invalid argument): invalid buffer
```

A correção envolve criar um novo buffer compatível com o novo tamanho:

```c
// solução correta
void resize_window(struct window *window, int width, int height) {
    struct wl_buffer *new_buffer = create_buffer(window->shm, width, height);
    wl_surface_attach(window->surface, new_buffer, 0, 0);
    wl_surface_damage(window->surface, 0, 0, width, height);
    wl_surface_commit(window->surface);
    // Manter referência para liberar posteriormente
}
```

### 2. Eventos de teclado que desaparecem após foco

Quando eventos de teclado param de funcionar após mudanças de foco, geralmente indica um problema no gerenciamento do assento (seat). Veja um caso real:

```bash
WAYLAND_DEBUG=1 ./aplicativo 2>&1 | grep wl_keyboard
```

A saída revelará:

```
[17108675.112]  -> wl_keyboard@8.release()  # ERRO: liberado prematuramente
```

O correto é manter o listener registrado e responder aos eventos de foco:

```c
static void keyboard_handle_enter(void *data, struct wl_keyboard *keyboard,
    uint32_t serial, struct wl_surface *surface, struct wl_array *keys) {
    // Preparar para receber eventos
}

static const struct wl_keyboard_listener keyboard_listener = {
    .enter = keyboard_handle_enter,
    // outros callbacks...
};
```

### 3. Vazamento de buffers em animações

Em aplicações com atualização contínua (como players de vídeo), um erro sutil causa consumo crescente de memória:

```bash
valgrind --leak-check=full --show-leak-kinds=all ./aplicativo_animado
```

O relatório indicará:

```
==12345== 120 bytes in 3 blocks are definitely lost
==12345==    by 0x4852F1B: wl_buffer_create (wayland-client.c:1423)
```

A solução envolve implementar corretamente o listener de buffer:

```c
static void buffer_release(void *data, struct wl_buffer *buffer) {
    wl_buffer_destroy(buffer);  // Libera quando o compositor terminar
}

static const struct wl_buffer_listener buffer_listener = {
    .release = buffer_release,
};

wl_buffer_add_listener(buffer, &buffer_listener, NULL);
```

### Técnica avançada: Debugging de race conditions

Problemas de sincronização são especialmente difíceis em Wayland. Considere este padrão para detectá-los:

1. Habilite logs detalhados:
```bash
WAYLAND_DEBUG=1 weston-debug --scope=all > wayland.log 2>&1
```

2. Procure por inconsistências nos timestamps:
```
[17108678.112]  -> wl_surface@4.commit()
[17108678.115]  <- wl_callback@15.done(17108678.200)  # Timestamp futuro!
```

3. Corrija com `wl_display_roundtrip()` para sincronização explícita:
```c
wl_display_roundtrip(display);  // Aguarda processamento pelo compositor
// Operações críticas aqui
```

### Exercício: Debug de renderização intermitente

Um aplicativo exibe conteúdo apenas a cada 2-3 redraws. Com `WAYLAND_DEBUG=1`, observa-se:

```
[17108680.453]  -> wl_surface@4.attach(buffer1, 0, 0)
[17108680.455]  -> wl_surface@4.commit()
[17108680.459]  -> wl_surface@4.attach(buffer2, 0, 0)  # Sem commit
```

**Solução**: O commit é necessário após cada attach. Modifique o loop de renderização:

```c
while (1) {
    struct wl_buffer *buf = get_next_buffer();
    wl_surface_attach(surface, buf, 0, 0);
    wl_surface_damage(surface, 0, 0, width, height);
    wl_surface_commit(surface);  // Commit explícito a cada frame
    wl_display_flush(display);
}
```