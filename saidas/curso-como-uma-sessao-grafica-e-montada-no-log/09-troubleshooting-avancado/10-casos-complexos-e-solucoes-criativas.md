## Casos complexos e soluções criativas

Um servidor Xorg rodando em uma máquina virtual sem aceleração gráfica pode apresentar um problema peculiar: aplicações GTK3+ ficam extremamente lentas ao redimensionar janelas, enquanto aplicações Qt funcionam normalmente. O motivo está em como as toolkits gráficas lidam com a renderização sem aceleração.

Para diagnosticar, execute:

```bash
LIBGL_ALWAYS_SOFTWARE=1 QT_XCB_FORCE_SOFTWARE_OPENGL=1 glxinfo | grep "OpenGL renderer"
```

Se a saída mostrar "llvmpipe" ou "softpipe", você está em renderização por software. O problema específico ocorre quando:

1. GTK3 usa client-side decorations (CSD)
2. O compositor está desativado
3. A máquina não tem GPU dedicada

Solução criativa: force o uso de server-side decorations (SSD) no GTK3:

```bash
mkdir -p ~/.config/gtk-3.0
echo -e "[Settings]\ngtk-decoration-layout=menu:minimize,maximize,close" > ~/.config/gtk-3.0/settings.ini
```

Outro cenário complexo ocorre ao tentar rodar um ambiente Wayland dentro de um terminal multiplexer como tmux. O erro típico será:

```
Unable to create display: Wayland requires WAYLAND_DISPLAY to be set
```

Isso acontece porque o socket Wayland (/run/user/1000/wayland-0) não é herdado pelos processos filhos do tmux. Solução:

```bash
# Dentro do tmux, antes de iniciar aplicativos Wayland
export WAYLAND_DISPLAY=$(ls /run/user/$(id -u)/wayland-* | head -n1 | xargs basename)
```

Para casos onde o Xorg não reconhece corretamente um teclado ABNT2 em um laptop específico (comum em Dells mais novos), mesmo com o layout correto configurado no sistema:

```bash
# Crie um arquivo de configuração específico para o teclado
cat > /etc/X11/xorg.conf.d/90-custom-keyboard.conf << 'EOF'
Section "InputClass"
    Identifier "Dell Keyboard Fix"
    MatchIsKeyboard "on"
    MatchProduct "Dell.*Keyboard"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
    Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF
```

Um problema persistente em sistemas multihead com NVIDIA ocorre quando o Xorg não posiciona corretamente os monitores após suspensão. A solução envolve criar um script que é executado após retomar:

```bash
sudo tee /etc/systemd/system/fix-nvidia-displays.service > /dev/null << 'EOF'
[Unit]
Description=Fix NVIDIA display arrangement after suspend
After=sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/xrandr --output HDMI-0 --auto --right-of DP-0

[Install]
WantedBy=sleep.target
EOF
sudo systemctl enable fix-nvidia-displays.service
```

Para ambientes Wayland rodando GNOME com drivers NVIDIA, há um bug conhecido onde o cursor some aleatoriamente. A solução temporária é:

```bash
gsettings set org.gnome.desktop.interface cursor-size 32
```

E depois volte ao tamanho original quando o problema for corrigido.

**Exercício**: Um usuário reclama que ao conectar um projetor via HDMI, o som não é redirecionado automaticamente, mesmo que a imagem funcione. Crie uma solução que automaticamente mude o dispositivo de áudio quando o projetor for conectado.

**Solução**:

```bash
# Instale dependências
sudo apt install pavucontrol inotify-tools

# Crie o script de monitoramento
cat > ~/.config/systemd/user/hdmi-sound-switcher.service << 'EOF'
[Unit]
Description=HDMI Sound Switcher

[Service]
ExecStart=/bin/bash -c 'while inotifywait -e modify /sys/class/drm/card*-HDMI-A-1/status; do if [[ $(cat /sys/class/drm/card0-HDMI-A-1/status) == "connected" ]]; then pactl set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo-extra1; else pactl set-card-profile alsa_card.pci-0000_01_00.1 output:analog-stereo+input:analog-stereo; fi; done'
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user enable --now hdmi-sound-switcher.service
```