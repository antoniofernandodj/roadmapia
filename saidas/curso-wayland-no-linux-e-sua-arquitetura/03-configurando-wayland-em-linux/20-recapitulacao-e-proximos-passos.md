## Recapitulação e próximos passos

Ao longo deste capítulo, configuramos ambientes Wayland em sistemas Ubuntu e Debian passo a passo. Vejamos o caminho percorrido:

1. **Verificamos os pré-requisitos essenciais**:
   - Drivers gráficos atualizados (testados com `glxinfo | grep "OpenGL renderer"`)
   - Pacotes básicos instalados:
     ```bash
     # Ubuntu
     sudo apt install ubuntu-session wayland-protocols libwayland-client
     
     # Debian
     sudo apt install weston libwayland-client0 wayland-protocols
     ```

2. **Configuramos os display managers**:
   - No GDM (Ubuntu), editando `/etc/gdm3/custom.conf`:
     ```ini
     [daemon]
     WaylandEnable=true
     ```
   - No LightDM (Debian), criando arquivos `.desktop` em `/usr/share/wayland-sessions/`

3. **Validamos a sessão ativa** com o comando definitivo:
   ```bash
   echo $XDG_SESSION_TYPE  # Deve retornar "wayland"
   ```

4. **Solucionamos problemas comuns**:
   - Permissões DRM resolvidas com:
     ```bash
     sudo usermod -aG video $USER
     ```
   - Drivers NVIDIA exigindo parâmetro no GRUB:
     ```bash
     GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"
     ```

5. **Personalizamos compositors**:
   - GNOME: `gsettings set org.gnome.desktop.interface scaling-factor 2`
   - Sway: configuração declarativa em `~/.config/sway/config`
   ```sway
   output * scale 1.5
   bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'
   ```

Um erro frequente é esquecer de reiniciar serviços após alterações. Se o GDM não inicia sessões Wayland após configuração, execute:
```bash
sudo systemctl restart gdm3  # Ubuntu
sudo systemctl restart lightdm  # Debian
```

**Próximos passos**:
- No capítulo 4, desenvolveremos aplicativos nativos para Wayland
- Veremos como interoperar com X11 via XWayland
- Exploraremos protocolos Wayland como `xdg-shell` e `zwlr_layer_shell`

**Exercício prático**:
Configure um ambiente Wayland no Sway com:
1. Teclado em layout ABNT2
2. Escala 1.25 para monitor HiDPI
3. Atalho personalizado para terminal

Solução:
```bash
# ~/.config/sway/config
input * {
    xkb_layout br
    xkb_variant abnt2
}

output eDP-1 scale 1.25

bindsym $mod+Return exec kitty
```