## Sway: um compositor i3-like para Wayland

Se você vem do i3wm e está migrando para Wayland, o Sway é a transição mais natural. Ele replica o comportamento do i3 (layout em mosaico, atalhos idênticos e arquivo de configuração compatível), mas com as vantagens do protocolo moderno: menor latência, segurança aprimorada e sem a complexidade do X11. Vamos começar com um exemplo prático que mostra como instalar e configurar o Sway em uma distribuição baseada Debian.

Primeiro, instale os pacotes necessários (o `wlroots` é a biblioteca que o Sway usa para gerenciar buffers de pixels no Wayland):

```bash
sudo apt install sway swaylock swayidle wlroots xwayland foot
```

Crie o diretório de configuração e copie o arquivo padrão:

```bash
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/
```

Edite `~/.config/sway/config` para definir seu teclado (substitua `br` pelo seu layout) e terminal:

```text
input * {
    xkb_layout "br"
}

set $term foot
bindsym $mod+Return exec $term
```

Inicie o Sway a partir de um terminal virtual (Ctrl+Alt+F2) executando:

```bash
sway
```

Se aparecer um erro sobre permissões (`Failed to open /dev/tty0 (permission denied)`), você precisará adicionar seu usuário ao grupo `video` ou `input`:

```bash
sudo usermod -aG video,input $(whoami)
```

Agora você verá um ambiente minimalista com um terminal (Foot, que substitui o Alacritty no Wayland). Pressione `Mod+Shift+E` para sair. O Sway usa os mesmos atalhos do i3 por padrão (`Mod` é a tecla Windows/Super).

Para quem já tem um `config` do i3, a migração é simples. Copie seu arquivo existente e faça estas adaptações:

1. Substitua chamadas a `i3-msg` por `swaymsg`
2. Troque `exec i3lock` por `exec swaylock`
3. Programas que usam X11 diretamente (como `xrandr`) precisarão de XWayland ou alternativas nativas. Por exemplo, para ajustar brilho:

```text
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
```

Um erro comum é tentar usar ferramentas de screenshot como `scrot`, que não funcionam no Wayland. Use:

```text
bindsym Print exec grim -g "$(slurp)" ~/screenshot.png
```

A saída do `swaymsg -t get_outputs` mostra como o Sway gerencia monitores (compare com o `xrandr`):

```json
[
  {
    "name": "eDP-1",
    "make": "Unknown",
    "model": "0x1234",
    "current_mode": {
      "width": 1920,
      "height": 1080
    }
  }
]
```

Para tornar o Sway seu ambiente padrão, adicione-o ao gerenciador de login. No SDDM, crie `/usr/share/wayland-sessions/sway.desktop`:

```text
[Desktop Entry]
Name=Sway
Exec=sway
Type=Application
```

**Exercício**: Configure um workspace 2 com três terminais horizontais e um workspace 3 com dois terminais verticais. Use `Mod+2` e `Mod+3` para alternar.

**Solução**:

```text
workspace 2 layout tabbed
bindsym $mod+2 workspace 2; exec $term; exec $term; exec $term

workspace 3 layout stacking
bindsym $mod+3 workspace 3; exec $term; exec $term
```