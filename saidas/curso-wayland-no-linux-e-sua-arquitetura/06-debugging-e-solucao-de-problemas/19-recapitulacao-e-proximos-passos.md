## Recapitulação e próximos passos

Ao longo da sessão de debugging, identificamos padrões comuns que surgem quando desenvolvemos para Wayland. Vamos revisitar os principais pontos antes de avançar:

1. **Protocolo de comunicação**: Toda interação cliente-compositor ocorre através de mensagens protocolares serializadas. O fluxo típico envolve:
   ```c
   wl_display *display = wl_display_connect(NULL);
   wl_registry *registry = wl_display_get_registry(display);
   wl_registry_add_listener(registry, &registry_listener, NULL);
   wl_display_roundtrip(display); // Sincronização inicial
   ```

   Quando falha, o erro mais comum é:
   ```
   error: failed to connect to wayland server: No such file or directory
   ```
   Solução: Verifique `$XDG_RUNTIME_DIR` e permissões do socket.

2. **Gerenciamento de buffers**: Um erro frequente é tentar reutilizar um buffer já liberado:
   ```c
   wl_buffer *buffer = create_buffer(); // Primeiro uso OK
   wl_surface_attach(surface, buffer, 0, 0);
   wl_surface_commit(surface);
   
   // ERRO: Tentar reusar sem wait pelo release
   wl_surface_attach(surface, buffer, 0, 0); // Inválido!
   ```
   Saída do `WAYLAND_DEBUG=1`:
   ```
   [  1234.567]  -> wl_display@1.error(new_id 2, code 0, "invalid object")
   ```

3. **Eventos de entrada**: Listeners não registrados causam falhas silenciosas. O padrão correto:
   ```c
   static void pointer_enter(void *data, struct wl_pointer *pointer,
                            uint32_t serial, struct wl_surface *surface,
                            wl_fixed_t x, wl_fixed_t y) {
       printf("Pointer entered at %f, %f\n",
              wl_fixed_to_double(x), wl_fixed_to_double(y));
   }
   
   static const struct wl_pointer_listener pointer_listener = {
       .enter = pointer_enter,
       // ... outros handlers
   };
   
   // Na configuração inicial:
   wl_seat_add_listener(seat, &seat_listener, NULL);
   ```

4. **Sincronização**: `wl_display_roundtrip()` é crucial após operações que criam objetos:
   ```c
   wl_surface *surface = wl_compositor_create_surface(compositor);
   wl_display_roundtrip(display); // Garante criação completa
   ```

**Próximos desafios**: Ao avançar para toolkits gráficos, lembre que:

- GTK/Qt abstraem muitos desses detalhes, mas os mesmos princípios se aplicam
- Problemas de protocolo aparecem como erros genéricos na camada superior
- O conhecimento adquirido aqui será fundamental para depuração em camadas altas

Um exercício final para consolidar: Modifique um cliente simples para:
1. Capturar eventos de teclado e exibir códigos de tecla
2. Gerenciar três buffers em rotação
3. Validar destruição de objetos com `valgrind`

Solução comentada:
```c
// 1. Eventos de teclado
static void keyboard_key(void *data, struct wl_keyboard *keyboard,
                        uint32_t serial, uint32_t time, uint32_t key,
                        uint32_t state) {
    printf("Key %d %s\n", key, state ? "pressed" : "released");
}

// 2. Triple-buffering
struct state {
    struct wl_buffer *buffers[3];
    int current;
};

// 3. Destruição
void destroy_buffer(struct wl_buffer *buffer, void *data) {
    wl_buffer_destroy(buffer); // Limpeza explícita
}
```