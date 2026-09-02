## Configurando monitores e resoluções

Ajustar a resolução de tela e configurações de vídeo é uma tarefa comum ao usar o servidor Xorg. Por padrão, o Xorg tenta detectar automaticamente as configurações ideais, mas nem sempre acerta — especialmente em monitores mais antigos ou com conexões específicas como VGA. Vamos explorar como definir manualmente essas configurações.

### Identificando monitores e modos de vídeo

O primeiro passo é identificar quais modos de vídeo seu monitor suporta. Para isso, use o comando `xrandr`:

```bash
xrandr
```

A saída será algo como:

```
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 8192 x 8192
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 510mm x 290mm
   1920x1080     60.00*+  50.00    59.94  
   1680x1050     59.95  
   1280x1024     75.02    60.02  
   1440x900      59.89  
   1280x720      60.00    50.00    59.94
```

Aqui, `HDMI-1` é o identificador do monitor, e os valores abaixo dele são as resoluções suportadas, com a atual marcada por `*`. O Xorg usa essas informações para oferecer opções ao usuário.

### Alterando a resolução manualmente

Para mudar a resolução temporariamente, use `xrandr` novamente:

```bash
xrandr --output HDMI-1 --mode 1280x720
```

Se a resolução não estiver na lista de suportadas, você receberá um erro:

```
xrandr: cannot find mode 800x600
```

Para adicionar um modo de vídeo, primeiro gere um modelo com `gtf` ou `cvt`:

```bash
cvt 800 600 60
```

A saída será algo como:

```
# 800x600 59.86 Hz (CVT 0.48M3) hsync: 37.35 kHz; pclk: 38.25 MHz
Modeline "800x600_60.00"   38.25  800 832 912 1024  600 603 607 624 -hsync +vsync
```

Copie o `Modeline` e adicione-o ao Xrandr:

```bash
xrandr --newmode "800x600_60.00" 38.25 800 832 912 1024 600 603 607 624 -hsync +vsync
xrandr --addmode HDMI-1 800x600_60.00
xrandr --output HDMI-1 --mode 800x600_60.00
```

Agora, a resolução 800x600 estará disponível temporariamente. Para torná-la permanente, adicione essas linhas ao seu arquivo `.xprofile`:

```bash
xrandr --newmode "800x600_60.00" 38.25 800 832 912 1024 600 603 607 624 -hsync +vsync
xrandr --addmode HDMI-1 800x600_60.00
```

### Configurações permanentes via Xorg.conf

Para definir configurações que persistam após reinicializações, edite ou crie um arquivo em `/etc/X11/xorg.conf.d/`. Um exemplo comum é definir a taxa de atualização:

```bash
# /etc/X11/xorg.conf.d/10-monitor.conf
Section "Monitor"
    Identifier "HDMI-1"
    Modeline "800x600_60.00" 38.25 800 832 912 1024 600 603 607 624 -hsync +vsync
    Option "PreferredMode" "800x600_60.00"
EndSection
```

Reinicie o servidor Xorg para aplicar as mudanças:

```bash
systemctl restart display-manager
```

Se algo der errado, consulte o log em `/var/log/Xorg.0.log` para diagnósticos.

### Exercício

Adicione uma nova resolução de 1024x768 ao seu monitor principal usando `xrandr` e torne-a permanente via arquivo de configuração do Xorg.

**Solução:**

```bash
cvt 1024 768 60
xrandr --newmode "1024x768_60.00" 63.50 1024 1072 1176 1328 768 771 775 798 -hsync +vsync
xrandr --addmode HDMI-1 1024x768_60.00
echo 'xrandr --newmode "1024x768_60.00" 63.50 1024 1072 1176 1328 768 771 775 798 -hsync +vsync' >> ~/.xprofile
echo 'xrandr --addmode HDMI-1 1024x768_60.00' >> ~/.xprofile
```

Para configurar permanentemente:

```bash
# /etc/X11/xorg.conf.d/10-monitor.conf
Section "Monitor"
    Identifier "HDMI-1"
    Modeline "1024x768_60.00" 63.50 1024 1072 1176 1328 768 771 775 798 -hsync +vsync
    Option "PreferredMode" "1024x768_60.00"
EndSection
```

Reinicie o servidor Xorg para aplicar:

```bash
systemctl restart display-manager
```