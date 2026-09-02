## Debugging de protocolos Wayland

Quando um aplicativo Wayland falha silenciosamente ou se comporta de maneira inesperada, o problema frequentemente está nas mensagens trocadas entre cliente e compositor. Vamos debugar um caso real onde um cliente não consegue criar uma janela, usando ferramentas específicas do ecossistema Wayland.

### Monitorando o protocolo bruto

O primeiro passo é ativar o log detalhado das comunicações com a variável `WAYLAND_DEBUG`. Execute seu aplicativo com:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

Isso gera saída como:

```
[1730238.234]  -> wl_display@1.get_registry(new id wl_registry@2)
[1730238.256] wl_display@1.delete_id(2)
[1730238.267] error wl_display@1: error 1 (invalid object)
```

Cada linha mostra:
- Timestamp em microssegundos
- Direção da mensagem (`->` = cliente para servidor, `<-` = servidor para cliente)
- ID do objeto e mensagem
- Erros com código e descrição

No exemplo acima, vemos um erro `invalid object` quando o cliente tenta usar um registry já destruído.

### Entendendo a hierarquia de objetos

Wayland opera com objetos identificados por IDs numéricos. Um erro comum é referenciar objetos após sua destruição. Considere este trecho problemático:

```c
wl_registry *registry = wl_display_get_registry(display);
wl_registry_destroy(registry); // Destrói o objeto
wl_registry_add_listener(registry, &registry_listener, NULL); // ERRO!
```

A mensagem de erro correspondente seria:

```
error wl_display@1: error 1 (invalid object) for request 1 (wl_registry.add_listener)
```

### Debugging com weston-debug

Para análise mais profunda, o Weston oferece ferramentas adicionais. Inicie o compositor com:

```bash
weston --debug
```

Em outro terminal, conecte o cliente de debug:

```bash
weston-debug
```

Isso permite monitorar eventos específicos como:

```
FRAME event on surface 0x55a1b2e3f0a0
KEYBOARD_KEY event time=1234 key=57 state=1
```

### Caso prático: Janela que não aparece

Vamos debugar um aplicativo que não exibe sua janela. Primeiro, ativamos os logs:

```bash
WAYLAND_DEBUG=1 ./app_sem_janela 2> wayland.log
```

Analisando o log, encontramos:

```
[1730456.789]  -> wl_compositor@3.create_surface(new id wl_surface@4)
[1730456.812]  -> wl_shm@5.create_pool(new id wl_shm_pool@6, fd 8, 4096)
[1730456.823] error wl_shm@5: error 3 (no memory) for request 0 (wl_shm.create_pool)
```

O erro "no memory" aqui não indica falta de memória RAM, mas esgotamento de IDs de objeto. O problema ocorre porque o cliente não está gerenciando corretamente os recursos. A solução é implementar proper handling de destruição:

```c
void buffer_release(void *data, struct wl_buffer *buffer) {
    wl_buffer_destroy(buffer); // Libera o ID para reuso
}

static const struct wl_buffer_listener buffer_listener = {
    .release = buffer_release,
};
```

### Debugging de eventos de entrada

Problemas com teclado/mouse frequentemente ocorrem na negociação inicial. Um log típico de erro seria:

```
[1730567.345]  -> wl_seat@7.get_keyboard(new id wl_keyboard@8)
[1730567.356]  <- wl_seat@7.capabilities(3) (pointer, keyboard)
[1730567.367]  <- wl_keyboard@8.keymap(1, fd 9, 4096)
```

Se `capabilities` não incluir os dispositivos esperados (3 = pointer + keyboard), verifique:

1. O listener foi registrado?
2. As interfaces estão disponíveis no registry?
3. O compositor reportou suporte?

### Exercício: Debugging de surface inválida

Um aplicativo exibe o erro:

```
error wl_surface@4: error 1 (invalid object) for request 6 (wl_surface.commit)
```

**Solução:**

O problema ocorre quando tentamos comitar uma surface já destruída. O código correto deve:

1. Manter referência à surface enquanto estiver em uso
2. Destruir apenas após confirmar que todas as operações completaram
3. Verificar o ciclo de vida com `wl_display_roundtrip()`

```c
wl_surface_commit(surface);
wl_display_roundtrip(display); // Espera processamento
// Só então destruir se necessário
if (should_destroy) {
    wl_surface_destroy(surface);
}
```