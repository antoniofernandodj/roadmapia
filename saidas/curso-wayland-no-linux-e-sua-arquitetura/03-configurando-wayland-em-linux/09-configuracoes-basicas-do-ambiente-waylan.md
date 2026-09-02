## Configurações básicas do ambiente Wayland

Um ambiente Wayland funciona de maneira radicalmente diferente do X11. Enquanto no X11 tudo passa por um servidor central, no Wayland cada aplicativo negocia diretamente com o compositor. Isso traz implicações práticas imediatas na configuração.

### Verificando a sessão ativa

O primeiro passo é confirmar que você está realmente rodando Wayland. Um erro comum é assumir que a mudança foi efetiva sem verificação:

```bash
echo $XDG_SESSION_TYPE
```

Se o resultado for `wayland`, você está no caminho certo. Caso contrário, mesmo com todos os pacotes instalados, as aplicações continuarão usando X11. Um erro típico seria:

```bash
# Saída indesejada:
x11
```

Nesse caso, você precisa forçar o Wayland no display manager. Para o GDM3 (padrão no GNOME), edite:

```bash
sudo nano /etc/gdm3/custom.conf
```

E descomente ou adicione:

```ini
WaylandEnable=true
```

Reinicie o GDM com:

```bash
sudo systemctl restart gdm
```

### Configurando variáveis de ambiente

Wayland usa variáveis específicas para determinar o comportamento dos aplicativos. A mais crítica é `GDK_BACKEND` para aplicações GTK:

```bash
export GDK_BACKEND=wayland
```

Para aplicações Qt:

```bash
export QT_QPA_PLATFORM=wayland
```

Um erro comum é esquecer de exportar essas variáveis, resultando em aplicações falhando silenciosamente ou revertendo para XWayland. Você pode verificar o backend em uso com:

```bash
# Para aplicações GTK:
GDK_DEBUG=backend gedit
# No terminal aparecerá:
# (gedit:12345): GDK-WARNING **: 12:34:56.789: Using Wayland backend
```

### Configurando o teclado

Diferente do X11, o layout do teclado é gerenciado pelo compositor. No GNOME, isso é feito via gsettings:

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'br')]"
```

Para ambientes como o Sway, edite `~/.config/sway/config`:

```bash
input * {
    xkb_layout "br"
    xkb_variant "abnt2"
}
```

Um sintoma de configuração incorreta é o teclado responder com caracteres errados ou atalhos não funcionarem.

### Configurações de HiDPI

Wayland lida com displays de alta resolução de forma nativa. No GNOME, ajuste a escala:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
```

Para configurações mais granulares (como diferentes escalas por monitor), use:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

### Gerenciamento de energia

Configurações de suspensão e economia de energia variam por compositor. No GNOME:

```bash
# Desativar suspensão quando em AC
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
```

No Sway, crie um arquivo `~/.config/swayidle/config`:

```bash
timeout 300 'swaylock -f -c 000000'
timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"'
```

### Exercício prático

Configure um ambiente minimalista com Weston para testar as configurações básicas:

1. Instale o Weston:
```bash
sudo apt install weston
```

2. Crie um arquivo de configuração `~/.config/weston.ini`:
```ini
[core]
xwayland=true

[keyboard]
keymap_layout=br
keymap_variant=abnt2

[output]
name=HDMI-A-1
mode=1920x1080@60Hz
```

3. Inicie a sessão:
```bash
weston --backend=drm-backend.so
```

Verifique:
- O layout do teclado está correto?
- A resolução está conforme configurado?
- Variáveis de ambiente estão sendo respeitadas?