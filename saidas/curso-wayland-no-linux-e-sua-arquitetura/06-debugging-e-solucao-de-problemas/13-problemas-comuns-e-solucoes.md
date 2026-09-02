## Problemas comuns e soluções

**Janela não aparece ao iniciar aplicativo**

Um dos problemas mais frequentes ocorre quando o aplicativo inicia, mas a janela não é exibida. Execute o programa com `WAYLAND_DEBUG=1` e observe a saída:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

A saída típica de um problema seria:
```
[1234567.890]  -> wl_display@1.get_registry(new id wl_registry@2)
[1234567.891]  -> wl_display@1.sync(new id wl_callback@3)
error: wl_display@1: error 1 (invalid object)
```

Este erro ocorre quando o cliente tenta usar um objeto Wayland que já foi destruído. A solução é garantir que todos os objetos sejam criados e destruídos na ordem correta:

```c
wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_commit(surface); // Não esqueça do commit!
```

**Problemas com eventos de entrada**

Quando teclado ou mouse não respondem, verifique se os listeners foram registrados corretamente:

```c
static const wl_seat_listener seat_listener = {
    .capabilities = seat_handle_capabilities,
    .name = seat_handle_name,
};

wl_seat_add_listener(seat, &seat_listener, NULL);
```

Um erro comum é esquecer de verificar as capacidades do seat:
```c
void seat_handle_capabilities(void *data, struct wl_seat *seat, uint32_t caps) {
    if (caps & WL_SEAT_CAPABILITY_KEYBOARD) {
        struct wl_keyboard *keyboard = wl_seat_get_keyboard(seat);
        // Configurar listener do teclado...
    }
}
```

**Erros de buffer**

Ao trabalhar com gráficos, um problema frequente é o erro "invalid buffer":

```
error: wl_surface@4: error 3 (invalid buffer)
```

Isso acontece quando você tenta usar um buffer que já foi liberado. A solução é usar double-buffering corretamente:

```c
struct wl_buffer *buffer = create_buffer(/*...*/);
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_commit(surface);

// Somente libere o buffer após receber o evento de release
static void buffer_handle_release(void *data, struct wl_buffer *buffer) {
    wl_buffer_destroy(buffer);
}

static const wl_buffer_listener buffer_listener = {
    .release = buffer_handle_release,
};
wl_buffer_add_listener(buffer, &buffer_listener, NULL);
```

**Problemas de permissão**

Erros de conexão silenciosos frequentemente são causados por problemas de permissão no socket Wayland. Verifique com:

```bash
ls -l /run/user/$(id -u)/wayland-0
stat -c "%a %U:%G" /run/user/$(id -u)/wayland-0
```

Se as permissões estiverem incorretas (não são do seu usuário), corrija com:

```bash
sudo chown $USER:$USER /run/user/$(id -u)/wayland-0
```

**Exercício prático**

Modifique este código defeituoso que causa um erro "invalid object":

```c
wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_destroy(surface);
wl_surface_commit(surface); // ERRADO!
```

**Solução comentada**

```c
wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_commit(surface); // Commit antes de destruir
// ... usar a surface ...
wl_surface_destroy(surface); // Destruir apenas quando não for mais necessária
```

O erro ocorria porque estávamos tentando comitar uma surface já destruída. A ordem correta é: criar, usar, destruir.