## Configurações avançadas do ambiente Wayland

Quando você precisa ir além da configuração básica do Wayland - ajustar comportamentos específicos do compositor, otimizar o pipeline gráfico ou habilitar funcionalidades experimentais - é necessário entender como os componentes interagem. Vamos explorar configurações que exigem modificações diretas em arquivos de sistema e variáveis de ambiente.

### Ajustando protocolos Wayland

Wayland opera através de protocolos definidos em arquivos XML. Para habilitar protocolos experimentais no GNOME (como screencast ou input-method), crie o diretório de configuração e adicione os arquivos necessários:

```bash
mkdir -p ~/.local/share/wayland-sessions
cp /usr/share/wayland-sessions/gnome-wayland.desktop ~/.local/share/wayland-sessions/
```

Edite o arquivo copiado e adicione:

```ini
[Desktop Entry]
Name=GNOME on Wayland (Experimental)
Exec=env CLUTTER_BACKEND=wayland MUTTER_DEBUG_ENABLE_ATK=1 gnome-shell --wayland
```

Ao tentar iniciar esta sessão, você pode encontrar o erro:

```
Window manager error: Unable to initialize Wayland display
```

Isso ocorre porque faltam protocolos necessários. Instale-os com:

```bash
sudo apt install wayland-protocols-extra
```

### Configuração de HiDPI avançada

Ao contrário do X11, o Wayland lida com scaling de forma nativa. Para configurações mistas (monitores com DPI diferentes), use:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.mutter check-alive-timeout 10000
```

Verifique a configuração atual com:

```bash
wlr-randr | grep -A 5 "Physical size"
```

Exemplo de saída:

```
Physical size: 346x194 mm
  Make: Manufacturer Name
  Model: Monitor Model
  Serial: 123456
  Enabled: yes
  Scale: 1.5
```

### Otimização de renderização

Para forçar o modo de renderização preferencial no KDE Plasma:

```bash
kwriteconfig5 --file kwinrc --group Compositing --key Backend OpenGL
systemctl restart plasma-kwin_x11.service
```

Se você encontrar o erro:

```
kwin_core: OpenGL compositing initialization failed
```

Verifique os drivers com:

```bash
glxinfo | grep "OpenGL renderer"
```

### Gerenciamento de energia avançado

No Sway, configure o tempo de inatividade para diferentes ações:

```bash
cat > ~/.config/swayidle/config <<EOF
timeout 300 'swaylock -f -c 000000'
timeout 600 'swaymsg "output * dpms off"'
resume 'swaymsg "output * dpms on"'
EOF
```

Teste com:

```bash
swayidle -w
```

### Variáveis de ambiente críticas

Crie um arquivo de ambiente para aplicações específicas:

```bash
cat > ~/.config/environment.d/wayland.conf <<EOF
QT_QPA_PLATFORM=wayland
GDK_BACKEND=wayland,x11
SDL_VIDEODRIVER=wayland
MOZ_ENABLE_WAYLAND=1
EOF
```

Recarregue com:

```bash
systemctl --user import-environment QT_QPA_PLATFORM GDK_BACKEND
```

### Exercício: Configuração de monitor personalizado

1. Identifique seu monitor principal com `wlr-randr`
2. Crie um script em `~/.config/sway/monitor.sh` que:
   - Define escala 1.25 para o monitor principal
   - Configura taxa de atualização para 144Hz
   - Ajusta brilho para 70%

Solução:

```bash
#!/bin/sh
wlr-randr --output DP-1 --scale 1.25 --mode 2560x1440@144.000
wlr-randr --output DP-1 --brightness 0.7
```