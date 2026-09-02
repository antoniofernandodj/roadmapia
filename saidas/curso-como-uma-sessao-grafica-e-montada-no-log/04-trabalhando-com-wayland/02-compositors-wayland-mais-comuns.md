## Compositors Wayland mais comuns

No ecossistema Wayland, o compositor assume um papel central que combina três funções: gerenciamento de janelas, composição gráfica e protocolo de comunicação. Diferente do Xorg onde essas camadas são separadas, no Wayland o compositor é o "orquestrador" único da sessão gráfica. Vamos examinar os principais, começando pelos que já fazem parte de ambientes desktop completos:

**1. Mutter (GNOME)**
O compositor padrão do GNOME demonstra como um ambiente desktop tradicional se adapta ao Wayland. Para verificar se sua sessão GNOME está usando Wayland:

```bash
echo $XDG_SESSION_TYPE
# Saída esperada no Wayland: 'wayland'
```

Mutter prioriza estabilidade sobre customização, recusando-se a implementar protocolos como `wlr-layer-shell` (usado por bars como o Waybar). Um erro comum é tentar usar extensões do Xorg:

```
Gtk-WARNING **: 15:20:43.123: X11/Wayland mismatch: Running GNOME Shell under Wayland but GTK+ is using X11
```

**2. KWin (KDE Plasma)**
O KWin oferece a transição mais suave para usuários vindos do Xorg, mantendo quase todas as funcionalidades. Teste recursos específicos do Wayland com:

```bash
qdbus org.kde.KWin /Compositor org.kde.kwin.Compositor.supportedPlatforms
# Saída típica: ['x11', 'wayland']
```

A principal vantagem é o suporte robusto ao XWayland, permitindo que aplicativos legados como o Firefox (em modo X11) funcionem perfeitamente.

**3. Weston (Referência)**
Desenvolvido pelos criadores do protocolo Wayland, Weston serve como compositor de referência e ferramenta de desenvolvimento. Instale e execute temporariamente para testes:

```bash
weston --backend=wayland-backend.so --socket=wayland-1 &
```

Weston é minimalista por design - seu arquivo de configuração (`~/.config/weston.ini`) controla até o cursor do mouse:

```ini
[shell]
background-image=/usr/share/backgrounds/default.png
```

**4. Sway (i3-compatível)**
Para usuários de gerenciadores de janela dinâmicos, Sway replica o i3 no Wayland. Um erro frequente ao migrar configurações:

```
ERROR: Your config contains i3-specific configuration options
```

A correção requer substituir comandos como `bindsym $mod+Shift+q kill` por `bindsym $mod+Shift+q kill current`.

**5. wlroots (Biblioteca Base)**
Diferente dos anteriores, wlroots não é um compositor pronto, mas a base para projetos como Hyprland e Wayfire. Um exemplo mínimo usando wlroots em C:

```c
struct wlr_backend *backend = wlr_backend_autocreate(display);
if (!backend) {
    wlr_log(WLR_ERROR, "Falha ao criar backend");
    return 1;
}
```

**6. Outros compositors notáveis:**
- **Hyprland**: Foco em efeitos visuais com configuração declarativa
- **River**: Gerenciamento manual de layouts via tags
- **Wayfire**: Modular com plugins para efeitos como Expo

**Exercício Prático:**
1. Identifique qual compositor sua sessão atual está usando com:
   ```bash
   ls -l /proc/$(pgrep -o compositor)/exe
   ```
2. Crie uma sessão temporária com Weston e capture seu log de eventos:
   ```bash
   weston --log=/tmp/weston.log
   ```

**Solução Comentada:**
1. O caminho do executável revelará algo como `/usr/bin/mutter` ou `/usr/bin/kwin_wayland`
2. O log em `/tmp/weston.log` mostrará detalhes como:
   ```
   [09:14:33.123] Evento: nova superfície (wl_surface@42)
   ```