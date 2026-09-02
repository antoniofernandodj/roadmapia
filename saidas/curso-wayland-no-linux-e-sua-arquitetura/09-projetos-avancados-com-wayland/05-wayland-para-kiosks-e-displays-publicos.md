## Wayland para kiosks e displays públicos

Um quiosque digital ou display público precisa operar sem intervenção, resistir a reinícios bruscos e impedir que usuários acessem o sistema subjacente. Veja como implementar isso com Wayland:

### Bloqueando acesso ao sistema

O protocolo `xdg-shell` permite restringir interações. Crie um compositor dedicado que:

1. Desabilita atalhos como `Alt+Tab`
2. Ignora eventos de teclado/mouse fora da aplicação
3. Força modo tela cheia sem bordas

```c
// No compositor (usando wlroots):
static void handle_xdg_toplevel_request_fullscreen(
    struct wl_listener *listener, void *data) {
    struct xdg_toplevel *toplevel = data;
    xdg_toplevel_set_fullscreen(toplevel, NULL);
}
```

Para travar em uma única aplicação, monitore os processos com:

```bash
# Script de inicialização (systemd unit)
ExecStart=/usr/bin/cage -- /usr/bin/kiosk-app
```

O Cage é um compositor Wayland especializado para quiosques. Se tentar abrir outro aplicativo:

```
(cage:10287): Cage-WARNING **: Attempted to launch unauthorized process: gnome-terminal
```

### Gerenciamento de sessão persistente

Em locais públicos, quedas de energia são comuns. Configure o sistema para:

1. Reiniciar automaticamente
2. Restaurar o estado anterior
3. Ignorar login gráfico

Adicione ao `/etc/systemd/logind.conf`:
```ini
HandlePowerKey=reboot
```

Para persistência de estado, use `waypipe` para serializar a sessão:

```bash
waypipe -s /tmp/kiosk-state server ./kiosk-app
```

### Segurança contra interações indesejadas

Proteja contra:
- Toques simultâneos
- Teclas de emergência (Ctrl+Alt+Del)
- Acesso a TTYs virtuais

Monte um sistema de arquivos somente leitura:
```bash
mount -o remount,ro /
```

Configure o compositor para filtrar eventos:

```c
static void handle_pointer_button(
    struct wl_listener *listener, void *data) {
    struct wlr_event_pointer_button *event = data;
    if (event->state == WL_POINTER_BUTTON_STATE_PRESSED) {
        wlr_seat_pointer_notify_button(seat, event->time_msec,
            event->button, WL_POINTER_BUTTON_STATE_RELEASED);
    }
}
```

### Exercício: Quiosque de Aeroporto

Crie um sistema que:
1. Exibe informações de voos (simuladas)
2. Bloqueia após 30s sem interação
3. Reinicia ao detectar toque prolongado (3s) na tela

Solução com `wlroots`:

```c
// No handler de eventos do touch:
static void handle_touch_down(
    struct wl_listener *listener, void *data) {
    static struct timespec last_touch;
    clock_gettime(CLOCK_MONOTONIC, &now);
    if ((now.tv_sec - last_touch.tv_sec) > 3) {
        execv("/usr/bin/kiosk-app", NULL);
    }
    last_touch = now;
}
```

Saída esperada após toque prolongado:
```
[restart] Sessão reiniciada por toque de emergência
```