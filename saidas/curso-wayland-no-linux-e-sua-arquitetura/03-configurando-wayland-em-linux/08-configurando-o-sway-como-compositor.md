## Configurando o Sway como compositor

O Sway é um compositor Wayland compatível com i3, que substitui o X11 por um gerenciamento de janelas moderno e eficiente. Vamos configurá-lo para substituir seu ambiente gráfico atual, mantendo o fluxo de trabalho com atalhos e layouts familiares.

### Instalação básica

No Ubuntu/Debian, instale os pacotes necessários:

```bash
sudo apt install sway swaylock swayidle wl-clipboard foot alacritty
```

Isso inclui:
- `sway`: o compositor principal
- `swaylock`: bloqueio de tela
- `swayidle`: gerenciamento de inatividade
- `wl-clipboard`: manipulação de área de transferência
- `foot`/`alacritty`: emuladores de terminal Wayland-nativos

### Configuração inicial

Crie seu arquivo de configuração básico em `~/.config/sway/config`:

```bash
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/
```

Edite o arquivo para definir seu teclado (substitua `br` pelo seu layout):

```bash
input * {
    xkb_layout "br"
    xkb_variant "abnt2"
}

set $mod Mod4
bindsym $mod+Return exec alacritty
```

Erro comum: esquecer de definir o terminal. Se tentar abrir um terminal sem configurar `bindsym $mod+Return`, o Sway mostrará:

```
ERROR: No binding found for keysym 'Return' with modifiers 'Mod4'
```

### Testando a sessão

Execute diretamente no TTY (Ctrl+Alt+F2):

```bash
sway
```

Se encontrar o erro:

```
sway: No backend could be used to open the display
```

Solução: verifique se está logado em outro ambiente gráfico (saia primeiro) ou se os drivers gráficos estão corretos:

```bash
glxinfo | grep "OpenGL renderer"
```

### Configurações avançadas

Adicione estas linhas para gerenciar monitores automaticamente:

```bash
output * bg #000000 solid_color
exec_always {
    swaymsg output "*" mode 1920x1080@60Hz
}
```

Para configurar o papel de parede dinamicamente:

```bash
exec swaybg -i ~/wallpaper.jpg -m fill
```

### Gerenciamento de energia

Configure o bloqueio automático após 5 minutos de inatividade:

```bash
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000'
```

### Exercício prático

1. Configure um atalho para alternar entre layouts `splitv` e `splith`
2. Adicione um menu de aplicativos usando `wofi`
3. Configure o brilho da tela via atalhos (dica: use `brightnessctl`)

Solução comentada:

```bash
# Alternar layouts
bindsym $mod+s layout toggle split

# Menu de aplicativos
bindsym $mod+d exec wofi --show drun

# Controle de brilho
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
```