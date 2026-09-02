## Problemas com múltiplos monitores

Quando você conecta um segundo monitor ao seu computador Linux e ele não funciona como esperado — seja não sendo detectado, exibindo a resolução errada ou simplesmente permanecendo preto —, o problema geralmente está na comunicação entre o servidor gráfico (Xorg ou Wayland) e o hardware. Vamos explorar como diagnosticar e resolver esses problemas de maneira eficiente.

### Diagnóstico inicial

O primeiro passo é identificar se o problema está no hardware ou no software. Verifique se o cabo está bem conectado e se o monitor está ligado. Se tudo parece ok fisicamente, o próximo passo é verificar se o sistema reconhece o monitor.

No Xorg, execute `xrandr` no terminal. Ele lista todos os monitores conectados e suas configurações atuais. Um exemplo de saída:

```bash
Screen 0: minimum 320 x 200, current 3840 x 1080, maximum 8192 x 8192
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 509mm x 286mm
   1920x1080     60.00*+  50.00    59.94  
   1680x1050     59.95  
   1280x1024     75.02    60.02  
   1024x768      75.03    60.00  
DP-1 disconnected (normal left inverted right x axis y axis)
```

Se o segundo monitor não aparece na lista, o problema pode ser de hardware ou driver. No Wayland, você pode usar `swaymsg -t get_outputs` se estiver usando o Sway, ou consultar as configurações gráficas do ambiente de desktop.

### Verificando os drivers

Se o monitor não é detectado, o próximo passo é verificar os drivers gráficos. Use `lspci -k | grep -A 2 -i vga` para identificar o driver em uso:

```bash
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 630 (rev 04)
    Subsystem: Dell HD Graphics 630
    Kernel driver in use: i915
```

Se o driver estiver faltando ou incorreto, você precisará instalá-lo ou reconfigurá-lo. Para drivers proprietários da NVIDIA, por exemplo, você pode precisar instalar o pacote `nvidia-driver` e garantir que ele esteja em uso.

### Configuração manual com `xrandr`

Se o monitor é detectado, mas não configurado corretamente, você pode usar `xrandr` para ajustar manualmente a resolução e posicionamento. Por exemplo, para configurar um segundo monitor (HDMI-1) à direita do principal com resolução 1920x1080:

```bash
xrandr --output HDMI-1 --mode 1920x1080 --right-of eDP-1
```

Se você receber um erro como `Failed to get size of gamma for output default`, pode ser necessário regenerar a configuração do Xorg com `Xorg -configure` e testar com o arquivo gerado.

### Problemas com Wayland

No Wayland, a configuração de múltiplos monitores é geralmente gerenciada pelo compositor. No GNOME, por exemplo, você pode usar as configurações gráficas para ajustar monitores. Se você encontrar problemas, verifique os logs do journald com `journalctl -b | grep -i wayland`.

### Exercício prático

Imagine que você conectou um segundo monitor via HDMI, mas ele não está funcionando. Siga estes passos:

1. Execute `xrandr` para verificar se o monitor é detectado.
2. Se não for detectado, verifique os drivers com `lspci -k | grep -A 2 -i vga`.
3. Se o driver estiver faltando, instale-o e reinicie o sistema.
4. Se o monitor for detectado, mas não configurado, use `xrandr` para ajustar manualmente.

Por exemplo, para configurar o monitor HDMI-1 à direita do eDP-1 com resolução 1920x1080, você executaria:

```bash
xrandr --output HDMI-1 --mode 1920x1080 --right-of eDP-1
```

Se tudo estiver funcionando, você verá o segundo monitor exibindo corretamente.