## Otimizando desempenho em Wayland

O Wayland é conhecido por sua eficiência em comparação ao X11, mas ainda há espaço para otimizações que podem melhorar significativamente o desempenho em diferentes cenários. Aqui, exploraremos técnicas práticas para garantir que sua configuração Wayland esteja funcionando da melhor forma possível.

### Escolha de Compositor e Drivers

A escolha do compositor e dos drivers gráficos é crucial para o desempenho. Compositors como GNOME Shell (Mutter) e KDE Plasma (KWin) oferecem diferentes níveis de otimização e suporte a recursos avançados. Além disso, garantir que você está utilizando os drivers gráficos mais recentes e compatíveis pode fazer uma grande diferença.

Por exemplo, para verificar se o driver gráfico está sendo utilizado corretamente, você pode usar o comando `glxinfo`:

```bash
glxinfo | grep "OpenGL renderer"
```

Saída esperada:

```
OpenGL renderer string: Mesa Intel(R) UHD Graphics 630 (CML GT2)
```

Se você estiver utilizando uma GPU NVIDIA, certifique-se de que o módulo `nvidia-drm` está carregado corretamente:

```bash
lsmod | grep nvidia_drm
```

Se o módulo não estiver carregado, você pode forçar sua ativação adicionando `nvidia-drm.modeset=1` às opções do kernel no GRUB.

### Configuração de HiDPI e Escala

Ambientes HiDPI podem ser particularmente desafiadores em termos de desempenho. Configurar corretamente a escala de interface pode evitar problemas de renderização e melhorar a fluidez. No GNOME, você pode ajustar a escala usando o comando `gsettings`:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 2
```

Para configurações mais avançadas, como escalas mistas, você pode usar recursos experimentais do Mutter:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

### Otimização de Compositors

Cada compositor possui suas próprias configurações e truques para otimizar o desempenho. No Sway, por exemplo, você pode ajustar o comportamento de renderização no arquivo de configuração `~/.config/sway/config`:

```bash
output * {
    scale 1.5
    adaptive_sync on
}
```

Para o KWin, você pode habilitar a renderização OpenGL ES para melhorar o desempenho em GPUs compatíveis:

```bash
kwin_x11 --replace &
```

### Gerenciamento de Energia e Sessões

O gerenciamento de energia também pode impactar o desempenho. Configurar corretamente as políticas de energia pode garantir que o sistema não reduza o desempenho da GPU ou CPU desnecessariamente. No Sway, você pode usar o `swayidle` para configurar o bloqueio de tela e suspensão:

```bash
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000'
```

### Verificação e Monitoramento

Finalmente, monitorar o desempenho do sistema pode ajudar a identificar gargalos. Ferramentas como `htop` para monitoramento de CPU e `nvidia-smi` para GPUs NVIDIA podem ser úteis:

```bash
htop
```

```bash
nvidia-smi
```

Saída esperada:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.57.02    Driver Version: 470.57.02    CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 166...  Off  | 00000000:01:00.0  On |                  N/A |
| 30%   45C    P8    10W / 130W |    230MiB /  5944MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
```

### Exercício Prático

**Exercício:** Configure o GNOME para utilizar uma escala de 1.5 em um monitor HiDPI e verifique o impacto no desempenho usando `glxgears`.

**Solução:**

1. Ajuste a escala no GNOME:

```bash
gsettings set org.gnome.desktop.interface scaling-factor 1.5
```

2. Execute `glxgears` para verificar o desempenho:

```bash
glxgears
```

Saída esperada:

```
Running synchronized to the vertical refresh.  The framerate should be
approximately the same as the monitor refresh rate.
320 frames in 5.0 seconds = 63.999 FPS
```

Observe a taxa de quadros e ajuste conforme necessário para garantir que o desempenho esteja dentro do esperado.