## Configurando o GNOME com Wayland

O GNOME Shell é o ambiente desktop padrão em muitas distribuições Linux e um dos compositors Wayland mais maduros. Sua configuração no Wayland envolve ajustes específicos para garantir que recursos como gestos, múltiplos monitores e aceleração gráfica funcionem conforme esperado.

### Verificando a sessão atual

Antes de qualquer ajuste, confirme que sua sessão está realmente rodando sob Wayland:

```bash
echo $XDG_SESSION_TYPE
```

Se o comando retornar `wayland`, você já está no modo nativo. Caso mostre `x11`, será necessário ajustar o GDM (GNOME Display Manager).

### Forçando Wayland no GDM

Em sistemas com GNOME, edite o arquivo de configuração do GDM:

```bash
sudo nano /etc/gdm3/custom.conf
```

Localize a seção `[daemon]` e descomente ou adicione a linha:

```ini
WaylandEnable=true
```

Um erro comum é esquecer de reiniciar o serviço após a alteração:

```bash
sudo systemctl restart gdm3
```

Se você encontrar a mensagem `Failed to restart gdm3.service: Unit gdm3.service not found`, tente com `gdm` em vez de `gdm3` em distribuições mais recentes.

### Solucionando problemas com drivers proprietários

Para placas NVIDIA, é necessário habilitar o modo DRM no kernel. Edite o arquivo de configuração do GRUB:

```bash
sudo nano /etc/default/grub
```

Localize a linha `GRUB_CMDLINE_LINUX_DEFAULT` e adicione:

```bash
nvidia-drm.modeset=1
```

Atualize o GRUB e reinicie:

```bash
sudo update-grub
sudo reboot
```

Após reiniciar, verifique se o driver está carregado corretamente:

```bash
lsmod | grep nvidia
```

A saída deve mostrar vários módulos NVIDIA carregados, incluindo `nvidia_drm`.

### Configurando gestos multi-toque

O GNOME no Wayland suporta gestos naturais. Para habilitá-los:

```bash
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'default'
```

Para ver todos os gestos disponíveis:

```bash
gsettings list-recursively org.gnome.desktop.peripherals.touchpad
```

### Ajustando a escala de interface

Em monitores HiDPI, defina o fator de escala:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
```

Para configurações mistas (diferentes escalas por monitor), use:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Depois, acesse as Configurações do GNOME > Displays para ajustar individualmente.

### Verificando a aceleração gráfica

Confirme se a renderização está usando hardware:

```bash
glxinfo -B | grep "OpenGL renderer"
```

A saída deve mostrar seu driver gráfico, não `llvmpipe` (que indica renderização por software).

### Exercício prático

**Problema**: Configure o GNOME no Wayland para:
1. Usar gestos de três dedos para alternar entre workspaces
2. Definir escala 150% no monitor principal
3. Verificar se a aceleração gráfica está ativa

**Solução**:

1. Configure os gestos:
```bash
gsettings set org.gnome.desktop.peripherals.touchpad scroll-method 'two-finger-scroll'
gsettings set org.gnome.shell enable-hot-corners true
```

2. Ajuste a escala:
```bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
```

3. Verifique a aceleração:
```bash
glxgears -info | grep "GL_RENDERER"
```