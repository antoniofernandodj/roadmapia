## Ferramentas de diagnóstico gráfico

Quando uma sessão gráfica falha, identificar o problema pode ser um desafio. Aqui estão algumas ferramentas essenciais para diagnóstico:

### `xrandr`
O comando `xrandr` é fundamental para verificar e configurar monitores. Ele lista todas as saídas de vídeo disponíveis e suas configurações atuais.

```bash
xrandr
```

Saída:
```
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 8192 x 8192
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 510mm x 287mm
   1920x1080     60.00*+  50.00    59.94  
   1680x1050     59.95  
   1440x900      59.89  
   1280x1024     75.02    60.02  
   1280x720      60.00    50.00    59.94  
   1024x768      75.03    60.00  
   800x600       75.00    60.32  
   640x480       75.00    60.00    59.94  
DP-1 disconnected (normal left inverted right x axis y axis)
```

### `lspci`
O `lspci` lista todos os dispositivos PCI, incluindo a placa gráfica e o driver em uso.

```bash
lspci -k | grep -A 2 -i vga
```

Saída:
```
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06)
    Subsystem: Dell HD Graphics 530
    Kernel driver in use: i915
```

### `journalctl`
Para sistemas usando `systemd`, o `journalctl` fornece logs detalhados. Use-o para verificar erros relacionados ao servidor gráfico.

```bash
journalctl -b | grep -i xorg
```

Saída:
```
jan 01 12:34:56 hostname systemd[1]: Starting X11 Server...
jan 01 12:34:56 hostname xorg[1234]: (EE) Failed to load module "nvidia" (module does not exist, 0)
```

### `ldd`
O `ldd` verifica dependências de bibliotecas para aplicativos gráficos. Útil para identificar bibliotecas faltantes.

```bash
ldd /usr/bin/xterm
```

Saída:
```
linux-vdso.so.1 (0x00007ffc12345000)
libX11.so.6 => /usr/lib/x86_64-linux-gnu/libX11.so.6 (0x00007f1234567000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1234567000)
/lib64/ld-linux-x86-64.so.2 (0x00007f1234567000)
```

### `xkill`
O `xkill` permite fechar janelas travadas. Execute-o e clique na janela problemática.

```bash
xkill
```

### `Xorg -configure`
Gera uma configuração básica para o Xorg, útil para diagnóstico.

```bash
Xorg -configure
```

Saída:
```
Your xorg.conf file is /root/xorg.conf.new
```

### `loginctl`
Gerenciador de sessões do `systemd`. Use-o para listar e encerrar sessões gráficas.

```bash
loginctl list-sessions
```

Saída:
```
SESSION  UID USER   SEAT  TTY  
1        1000 user  seat0 tty2
```

### `grep` em logs do Xorg
Filtre erros e avisos nos logs do Xorg para diagnóstico rápido.

```bash
grep -E "(EE|WW)" /var/log/Xorg.0.log
```

Saída:
```
(EE) Failed to load module "nvidia" (module does not exist, 0)
(WW) Warning, couldn't open module nvidia
```

### `DISPLAY` e `XAUTHORITY`
Verifique as variáveis de ambiente essenciais para sessões gráficas.

```bash
echo $DISPLAY
echo $XAUTHORITY
```

Saída:
```
:0
/home/user/.Xauthority
```

Essas ferramentas são essenciais para diagnosticar e resolver problemas em sessões gráficas no Linux. Familiarize-se com elas para manter seu ambiente gráfico funcionando sem problemas.