## Exercícios práticos: configurando Wayland

Neste exercício, vamos configurar o GNOME Shell para usar o Wayland como backend gráfico padrão em um sistema Ubuntu. Este processo envolve a modificação de arquivos de configuração, verificação de drivers gráficos e a confirmação da sessão ativa.

### Passo 1: Verificar drivers gráficos

Antes de iniciar a configuração, é essencial garantir que os drivers gráficos estão corretamente instalados e funcionando. Para verificar isso, execute o seguinte comando:

```bash
lsmod | grep nvidia
```

Se você usar drivers NVIDIA, o comando deve retornar algo como:

```bash
nvidia_drm             65536  3
nvidia_modeset       1146880  6 nvidia_drm
nvidia              37330944  723 nvidia_modeset
```

Se você não vir uma saída semelhante, instale os drivers NVIDIA com:

```bash
sudo apt install nvidia-driver-535
```

### Passo 2: Habilitar Wayland no GDM

O GDM (GNOME Display Manager) é o responsável por gerenciar as sessões gráficas no GNOME. Para forçar o uso do Wayland, edite o arquivo `/etc/gdm3/custom.conf`:

```bash
sudo nano /etc/gdm3/custom.conf
```

Localize a linha `#WaylandEnable=false` e modifique-a para:

```bash
WaylandEnable=true
```

Salve o arquivo e reinicie o GDM:

```bash
sudo systemctl restart gdm3
```

### Passo 3: Verificar a sessão ativa

Após reiniciar o GDM, faça login novamente e verifique se o Wayland está sendo usado com o seguinte comando:

```bash
echo $XDG_SESSION_TYPE
```

A saída esperada é:

```bash
wayland
```

Se você ainda ver `x11`, certifique-se de que os drivers gráficos estão corretamente configurados e que o GDM foi reiniciado.

### Passo 4: Configurar o GNOME para Wayland

Agora que o Wayland está ativo, vamos configurar algumas opções específicas do GNOME para melhorar a experiência. Primeiro, ajuste o comportamento de gestos do GNOME:

```bash
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
```

Em seguida, configure a escala de interface para HiDPI:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
```

Verifique se as mudanças foram aplicadas corretamente.

### Passo 5: Testar aplicativos nativos e XWayland

Para garantir que os aplicativos estão funcionando corretamente, teste um aplicativo nativo do Wayland e outro que use o XWayland. Por exemplo:

```bash
gnome-terminal
```

Este terminal deve funcionar nativamente no Wayland. Em seguida, teste um aplicativo X11:

```bash
gedit
```

O Gedit deve funcionar via XWayland. Verifique isso com:

```bash
echo $DISPLAY
```

A saída deve ser algo como `:1`, indicando que o aplicativo está rodando no XWayland.

### Passo 6: Solucionar problemas comuns

Se você encontrar problemas, como aplicativos que não abrem ou erros de permissão, verifique os logs do GDM:

```bash
journalctl -u gdm3
```

Para problemas de drivers NVIDIA, certifique-se de que o modo `nvidia-drm` está habilitado no GRUB:

```bash
sudo nano /etc/default/grub
```

Modifique a linha `GRUB_CMDLINE_LINUX_DEFAULT` para incluir `nvidia-drm.modeset=1`:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"
```

Atualize o GRUB e reinicie o sistema:

```bash
sudo update-grub
sudo reboot
```

### Exercício final

Configure o GNOME Shell para usar o Wayland em uma máquina virtual com Debian. Siga os mesmos passos, mas adapte-os para o Debian, onde o GDM pode estar localizado em `/etc/gdm3/daemon.conf`. Verifique se a sessão está ativa e teste aplicativos nativos e XWayland.

### Solução

Para configurar o GNOME Shell no Debian, siga os mesmos passos, mas edite o arquivo `/etc/gdm3/daemon.conf`. Após reiniciar o GDM, confirme a sessão ativa com `echo $XDG_SESSION_TYPE`. Teste aplicativos nativos e XWayland para garantir que tudo está funcionando corretamente.