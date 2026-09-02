## Configurando múltiplos monitores em Wayland

Ao conectar um segundo monitor em um sistema Wayland, você pode se deparar com comportamentos inesperados: telas espelhadas quando queria estendidas, resoluções incorretas ou até monitores não detectados. O gerenciamento de múltiplos displays no Wayland difere radicalmente do X11 - aqui o compositor é quem controla diretamente a configuração, sem ferramentas externas como `xrandr`.

### Verificando a detecção de monitores

Antes de configurar, confirme se o sistema reconhece seus monitores. Execute no terminal:

```bash
wlr-randr
```

Se o comando não estiver disponível (comum em GNOME/KDE), instale-o via:

```bash
sudo apt install wlr-randr  # Debian/Ubuntu
```

A saída típica mostra todos os displays conectados:

```
HDMI-A-1 connected 1920x1080@60Hz (position 0,0)
DP-1 connected 2560x1440@144Hz (position 1920,0)
```

Se um monitor não aparece, verifique:
1. Conexões físicas (cabo solto é a causa #1)
2. Drivers gráficos (`glxinfo | grep "OpenGL renderer"`)
3. Suporte do protocolo DRM (`ls /dev/dri/`)

### Configurando layout no GNOME/Wayland

No GNOME, o gerenciamento gráfico é feito via Settings > Displays, mas para controle preciso use:

```bash
gsettings set org.gnome.mutter check-alive-timeout 5000
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Para posicionar monitores via linha de comando (útil em scripts):

```bash
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
--method org.gnome.Shell.Eval "
  global.get_monitors().forEach((m, i) => {
    Main.layoutManager._monitors[i].set_position(i * 1920, 0);
  })
"
```

### No KDE Plasma

O KDE oferece controle detalhado via `kscreen-doctor`:

```bash
kscreen-doctor output.DP-1.enable output.DP-1.mode.2560x1440@144 output.DP-1.position.0,0 \
output.HDMI-1.enable output.HDMI-1.mode.1920x1080@60 output.HDMI-1.position.2560,0
```

### Configuração persistente no Sway

No Sway (compositor popular para i3 users), edite `~/.config/sway/config`:

```
output HDMI-A-1 pos 0 0 res 1920x1080
output DP-1 pos 1920 0 res 2560x1440 @144Hz
```

Recarregue com `swaymsg reload`. Erros comuns incluem:

```
ERROR: Unknown/invalid output 'DP-1'
```

Solução: use o nome exato do `wlr-randr` e verifique cabos/drivers.

### Resolução de problemas frequentes

**Problema**: Mudanças não persistem após reinício  
**Solução**: No GNOME, desative o "modo experimental" no Mutter:

```bash
gsettings reset org.gnome.mutter experimental-features
```

**Problema**: Interface gráfica mostra opções limitadas  
**Solução**: Forçar recarregamento do protocolo:

```bash
sudo udevadm trigger --subsystem-match=drm --action=change
```

**Problema**: Monitores com escalas DPI diferentes  
**Solução**: Configure escalas individuais (GNOME 40+):

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gdk/WindowScalingFactor': <2>}"
```

### Exercício prático

Configure dois monitores (se tiver apenas um, simule com `weston --backend=headless-backend.so`):
1. Primário: 1920x1080 no lado esquerdo
2. Secundário: 2560x1440 à direita, com escala 1.5x

**Solução para GNOME**:

```bash
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
--method org.gnome.Shell.Eval "
  let monitors = global.get_monitors();
  Main.layoutManager._monitors[0].set_position(0, 0);
  Main.layoutManager._monitors[1].set_position(1920, 0);
  Main.layoutManager._monitors[1].set_scale(1.5);
"
```

Verifique com:

```bash
gsettings get org.gnome.shell.overrides workspaces-only-on-primary  # deve ser false
```