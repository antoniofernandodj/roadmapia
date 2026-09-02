## Solução de problemas de configuração

Configurar o Wayland pode apresentar desafios, especialmente quando há incompatibilidades com drivers gráficos, permissões incorretas ou configurações mal ajustadas. Vamos explorar alguns dos problemas mais comuns e suas soluções.

### Problema 1: Sessão Wayland não inicia após configuração do GDM

Após modificar o arquivo `/etc/gdm3/custom.conf` para habilitar o Wayland, você pode encontrar a sessão ainda rodando no X11. Para verificar qual sessão está ativa, use o comando:

```bash
echo $XDG_SESSION_TYPE
```

Se o resultado for `x11`, o Wayland não foi iniciado. Um erro comum é esquecer de reiniciar o GDM após a modificação. Execute:

```bash
sudo systemctl restart gdm
```

Se o problema persistir, verifique se os drivers gráficos estão corretamente instalados e configurados. Para drivers NVIDIA, adicione `nvidia-drm.modeset=1` ao GRUB:

```bash
sudo nano /etc/default/grub
```

Modifique a linha `GRUB_CMDLINE_LINUX_DEFAULT` para incluir o parâmetro:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"
```

Após salvar, atualize o GRUB:

```bash
sudo update-grub
```

Reinicie o sistema e verifique novamente a sessão ativa.

### Problema 2: Falha de permissão no DRM

Se você encontrar erros relacionados a permissões no Direct Rendering Manager (DRM), como `Permission denied` ao tentar iniciar o Weston ou outro compositor, é provável que você não esteja no grupo `video`. Para resolver, adicione seu usuário ao grupo:

```bash
sudo usermod -aG video $USER
```

Após isso, reinicie o sistema ou faça logout e login novamente para aplicar as mudanças.

### Problema 3: Configuração de teclado incorreta

No Wayland, a configuração do teclado é gerenciada pelo compositor, não pelo X11. Se você encontrar problemas com o layout do teclado, como teclas incorretas ou layout não aplicado, precisará ajustar a configuração diretamente no compositor.

Para o GNOME, use o `gsettings`:

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'br')]"
```

Para o Sway, edite o arquivo `~/.config/sway/config`:

```bash
input * {
    xkb_layout "us,br"
    xkb_options "grp:alt_shift_toggle"
}
```

Reinicie o compositor após fazer essas alterações.

### Problema 4: Aplicativos X11 via XWayland não funcionam

Alguns aplicativos ainda dependem do X11 e são executados via XWayland. Se esses aplicativos não funcionarem corretamente, verifique se o XWayland está habilitado. No GNOME, ele é habilitado por padrão, mas você pode verificar com:

```bash
ps aux | grep Xwayland
```

Se não estiver em execução, pode ser necessário reinstalar o pacote `xwayland`:

```bash
sudo apt install xwayland
```

### Problema 5: HiDPI mal configurado

Configurações de HiDPI podem variar entre compositors. No GNOME, você pode ajustar a escala de interface usando:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
```

Para configurações mistas de HiDPI, onde diferentes monitores têm diferentes escalas, o GNOME oferece uma configuração experimental:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

No Sway, você pode configurar escalas individuais por monitor no arquivo `~/.config/sway/config`:

```bash
output eDP-1 scale 2
output HDMI-A-1 scale 1
```

### Exercício Prático

1. Verifique se sua sessão está rodando no Wayland com `echo $XDG_SESSION_TYPE`.
2. Adicione seu usuário ao grupo `video` e reinicie o sistema.
3. Configure o layout do teclado para `us` e `br` no GNOME ou Sway.
4. Ajuste a escala de HiDPI para 2 no GNOME ou configure escalas individuais no Sway.

Após realizar esses passos, sua configuração do Wayland deve estar funcionando corretamente, permitindo uma experiência gráfica estável e eficiente.