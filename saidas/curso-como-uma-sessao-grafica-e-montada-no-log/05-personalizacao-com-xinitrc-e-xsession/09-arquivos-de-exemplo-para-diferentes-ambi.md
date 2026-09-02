## Arquivos de exemplo para diferentes ambientes

### Configuração básica para i3wm

Este é um `.xinitrc` completo para iniciar o i3wm com configurações de teclado e papel de parede:

```bash
#!/bin/sh

# Configurações de teclado (layout BR ABNT2)
setxkbmap -model abnt2 -layout br -variant abnt2 &

# Papel de parede
feh --bg-fill ~/wallpapers/linux-dark.png &

# Fixar teclas repetidas (evita problemas com teclas travadas)
xset r rate 200 40 &

# Iniciar i3
exec i3
```

Erro comum ao testar: esquecer de tornar o arquivo executável. O sistema mostrará:

```
xinit: giving up
xinit: unable to connect to X server: Connection refused
xinit: server error
```

Corrija com:
```bash
chmod +x ~/.xinitrc
```

### Ambiente GNOME via .xsession

Para gerenciadores de login que usam `.xsession`, o arquivo para iniciar GNOME com personalizações:

```bash
#!/bin/bash

# Variáveis para temas GTK/Qt
export GTK_THEME=Adwaita-dark
export QT_STYLE_OVERRIDE=adwaita-dark

# Configuração de monitor adicional
xrandr --output HDMI-1 --right-of eDP-1 --auto &

# Iniciar GNOME
exec gnome-session
```

Teste o arquivo sem reiniciar com:
```bash
startx ~/.xsession -- :1
```

### KDE Plasma com Wayland

Para sistemas usando Wayland via `.xsession`:

```bash
#!/bin/bash

# Sessão Wayland do KDE
export KDE_FULL_SESSION=1
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland

# Forçar aceleração VA-API para vídeos
export LIBVA_DRIVER_NAME=i965

exec startplasma-wayland
```

### XFCE com compositor próprio

Exemplo combinando XFCE com compositor externo (útil para máquinas mais antigas):

```bash
#!/bin/sh

# Desativar compositor interno do XFCE
xfconf-query -c xfwm4 -p /general/use_compositing -s false &

# Iniciar Picom (compositor leve)
picom --backend glx --vsync &

# Configuração de teclado alternativo
setxkbmap us -variant intl &

# Iniciar XFCE
exec startxfce4
```

### Fluxbox com múltiplos utilitários

Configuração minimalista para Fluxbox que mantém vários utilitários:

```bash
#!/bin/sh

# Gerenciador de arquivos
pcmanfm --desktop &

# Painel de sistema
tint2 &

# Ajustar brilho para 70%
xbacklight -set 70 &

exec fluxbox
```

### Hyprland (Wayland moderno)

Para compositors Wayland modernos como Hyprland:

```bash
#!/bin/bash

# Necessário para alguns aplicativos GTK
export CLUTTER_BACKEND=wayland
export GDK_BACKEND=wayland

# Configuração de escala para HiDPI
export QT_WAYLAND_FORCE_DPI=physical
export GDK_SCALE=2

exec Hyprland
```

### Erro crítico: esquecer o `exec`

Se você substituir o `exec` por um comando direto no `.xinitrc`:

```bash
...
i3  # Em vez de exec i3
```

O resultado será uma sessão que imediatamente termina com:
```
X connection to :0 broken (explicit kill or server shutdown)
```

### Dica para teste seguro

Para testar configurações sem afetar sua sessão atual:

```bash
startx /caminho/para/novo.xinitrc -- :1
```

Depois acesse com:
```bash
DISPLAY=:1 xterm
```