## Debugging avançado de aplicativos

Um aplicativo Wayland rodando em modo fullscreen trava sem mensagens de erro quando o usuário tenta redimensionar a janela via atalho de teclado. Como descobrir o que está causando o problema quando não há logs aparentes?

### Ferramentas essenciais

O primeiro passo é habilitar logs detalhados do protocolo Wayland:

```bash
export WAYLAND_DEBUG=1
./meu_app 2> wayland.log
```

Isso gera um arquivo `wayland.log` com todas as mensagens trocadas entre cliente e compositor. Um trecho típico mostra o problema:

```
[1234567.890]  -> wl_surface@34.frame(new id wl_callback@35)
[1234567.891]  -> wl_surface@34.commit()
[1234567.892]  -> wl_display@1.sync(new id wl_callback@36)
[ERROR] Buffer size mismatch: expected 1920x1080, got 1366x768
```

O erro indica que o aplicativo não está tratando corretamente a mudança de resolução quando o compositor emite o evento de redimensionamento.

### Debugging com GDB

Quando o travamento não gera logs, conecte o GDB ao processo:

```bash
gdb -p $(pidof meu_app)
```

No prompt do GDB, configure para capturar sinais:

```
(gdb) handle SIGSEGV nostop noprint pass
(gdb) catch syscall 103  # SYS_futex relacionado ao Wayland
(gdb) continue
```

Ao reproduzir o travamento, GDB mostrará a pilha de chamadas:

```
Thread 1 "meu_app" received signal SIGSEGV
#0  0x00007ffff7bc7a21 in wl_proxy_marshal_flags () from /usr/lib/x86_64-linux-gnu/libwayland-client.so.0
#1  0x000055555555b2a9 in handle_configure (data=0x0, xdg_surface=0x5555555a12e0, width=1366, height=768) at src/window.c:147
```

Isso revela que a função `handle_configure` está recebendo um ponteiro nulo (`data=0x0`).

### Valgrind para vazamentos

Problemas de memória são comuns em aplicativos gráficos. Execute com:

```bash
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./meu_app
```

A saída típica mostra:

```
==12345== 32 bytes in 1 blocks are definitely lost in loss record 1 of 2
==12345==    at 0x483B7F3: malloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
==12345==    by 0x48A2A5F: ??? (in /usr/lib/x86_64-linux-gnu/libwayland-client.so.0.3.0)
==12345==    by 0x48A0C67: wl_event_loop_dispatch (in /usr/lib/x86_64-linux-gnu/libwayland-client.so.0.3.0)
==12345==    by 0x489F4FE: wl_display_dispatch (in /usr/lib/x86_64-linux-gnu/libwayland-client.so.0.3.0)
```

### Debugging de buffers gráficos

Para inspecionar buffers compartilhados, use `weston-screenshooter`:

```bash
weston-screenshooter --output=debug_frame.png
```

Combine com `WAYLAND_DEBUG` para correlacionar mensagens com o frame capturado.

### Exercício: Debugging de flickering

Um aplicativo está com flickering durante animações. A captura com `WAYLAND_DEBUG=1` mostra:

```
[1234567.900]  -> wl_surface@34.attach(wl_buffer@37, 0, 0)
[1234567.901]  -> wl_surface@34.damage(0, 0, 1920, 1080)
[1234567.902]  -> wl_surface@34.commit()
[1234567.903] wl_display@1.error(wl_buffer@37, 1, "commit while pending")
```

**Solução:**

O erro indica que há um buffer sendo commitado enquanto ainda está em uso. A correção é implementar um sistema de triplo buffer:

```c
static struct wl_buffer *buffers[3];
static int current_buffer = 0;

void redraw(void *data) {
    struct wl_buffer *buffer = buffers[current_buffer];
    current_buffer = (current_buffer + 1) % 3;
    
    // Preenche o buffer com novos dados
    draw_frame(buffer);
    
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_damage(surface, 0, 0, width, height);
    wl_surface_commit(surface);
}
```