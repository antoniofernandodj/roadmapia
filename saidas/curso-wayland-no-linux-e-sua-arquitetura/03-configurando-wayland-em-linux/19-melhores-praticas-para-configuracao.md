## Melhores práticas para configuração

Wayland exige uma abordagem diferente do X11 para configuração. O maior erro é tentar replicar os mesmos métodos - isso leva a sessões instáveis e funcionalidades quebradas. Vamos direto aos problemas reais e como resolvê-los de forma idiomática.

### 1. Gerenciamento de drivers gráficos

Ao contrário do X11, onde os drivers são carregados pelo X Server, no Wayland cada compositor gerencia seus próprios drivers. Um erro comum é esquecer de configurar corretamente os módulos do kernel. Veja o que acontece quando isso dá errado:

```bash
$ weston --backend=drm-backend.so
[09:42:31] DRM: failed to create device: Permission denied
```

A solução envolve três passos:

1. Adicionar seu usuário ao grupo `video`:
   ```bash
   sudo usermod -aG video $USER
   ```

2. Configurar o módulo `nvidia-drm` (para GPUs NVIDIA):
   ```bash
   echo 'options nvidia-drm modeset=1' | sudo tee /etc/modprobe.d/nvidia-drm.conf
   sudo update-initramfs -u
   ```

3. Verificar se os módulos estão carregados:
   ```bash
   $ lsmod | grep -E 'nvidia|drm'
   nvidia_drm             65536  0
   nvidia_modeset       1187840  1 nvidia_drm
   ```

### 2. Configuração de HiDPI

Enquanto no X11 usávamos `xrandr --scale`, no Wayland cada compositor tem sua abordagem. No GNOME:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Já no Sway, editamos `~/.config/sway/config`:
```
output eDP-1 scale 2
```

A configuração mista (diferentes escalas por monitor) é um caso especial. No GNOME 42+, use:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gdk/WindowScalingFactor': <2>}"
```

### 3. Layout de teclado

Esqueça `setxkbmap`. No Wayland, configure diretamente no compositor:

- **GNOME**:
  ```bash
  gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
  ```

- **Sway**:
  ```
  input * {
      xkb_layout "br"
      xkb_variant "abnt2"
  }
  ```

Para verificar as configurações ativas:
```bash
$ busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'imports.ui.status.keyboard.getInputSourceManager().currentSource.id'
s "xkb:br::por"
```

### 4. Gerenciamento de energia

A configuração varia radicalmente por compositor:

- **GNOME**:
  ```bash
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
  ```

- **Sway**:
  ```
  exec swayidle -w \
      timeout 300 'swaylock -f -c 000000' \
      timeout 600 'swaymsg "output * dpms off"' \
      resume 'swaymsg "output * dpms on"'
  ```

### 5. Variáveis de ambiente críticas

Estas são as variáveis mais importantes para sua `.bashrc` ou sistema de inicialização:

```bash
# Forçar toolkits a usar Wayland nativo
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

# Aplicativos que ainda precisam de X11
export XDG_SESSION_TYPE=wayland
export XWAYLAND_NO_GLAMOR=0
```

### 6. Monitoramento e troubleshooting

Substitua suas ferramentas X11 por equivalentes Wayland:

| X11               | Wayland                  |
|-------------------|--------------------------|
| `xrandr`          | `wlr-randr` (Sway)       |
| `xprop`           | `weston-info`            |
| `glxinfo`         | `weston-simple-egl`      |
| `xev`             | `wev`                    |

Para depuração avançada:
```bash
# Log detalhado do protocolo Wayland
WAYLAND_DEBUG=1 weston-info
```

Exercício: Configure um ambiente Wayland do zero com:
1. Escala 150% no monitor principal
2. Layout ABNT2
3. Tempo de suspensão de 20 minutos
4. Verificação dos drivers NVIDIA carregados

Solução comentada:
```bash
# 1. Escala (GNOME exemplo)
gsettings set org.gnome.desktop.interface scaling-factor 1
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gdk/WindowScalingFactor': <1.5>}"

# 2. Teclado
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br+abnt2')]"

# 3. Energia
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1200

# 4. Verificação NVIDIA
lsmod | grep nvidia_drm && echo "DRM ativo" || echo "Falha nos drivers"
```