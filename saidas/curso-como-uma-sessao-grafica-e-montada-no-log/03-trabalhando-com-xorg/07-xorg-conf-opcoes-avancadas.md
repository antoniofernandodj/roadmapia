## Xorg.conf: opções avançadas

Quando o Xorg inicia, ele aplica configurações padrão que funcionam para a maioria dos casos, mas situações específicas exigem ajustes finos. Vamos explorar configurações menos comuns que resolvem problemas reais de hardware e usabilidade.

### Forçando sincronização vertical (VSync)

O tearing gráfico ocorre quando o monitor exibe partes de diferentes quadros simultaneamente. Para ativar o VSync globalmente, crie `/etc/X11/xorg.conf.d/20-vsync.conf`:

```bash
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "TearFree" "true"
EndSection
```

Após reiniciar o Xorg, verifique no log (`/var/log/Xorg.0.log`):

```
[     7.352] (II) intel(0): TearFree enabled
```

Para placas NVIDIA, use:

```bash
Section "Device"
    Identifier  "NVIDIA Card"
    Driver      "nvidia"
    Option      "Metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
EndSection
```

### Configuração multi-touch para trackpads

Dispositivos de entrada modernos suportam gestos complexos. Um arquivo `/etc/X11/xorg.conf.d/30-touchpad.conf` típico inclui:

```bash
Section "InputClass"
    Identifier      "Touchpad"
    MatchIsTouchpad "on"
    Driver          "libinput"
    Option          "Tapping" "on"
    Option          "NaturalScrolling" "true"
    Option          "ClickMethod" "clickfinger"
    Option          "MiddleEmulation" "true"
EndSection
```

Erro comum é esquecer de especificar o driver correto, resultando em:

```
[     5.421] (EE) config/udev: Could not get driver for "SynPS/2 Synaptics TouchPad"
```

### Ajuste de cores via Xorg

Calibração de monitor diretamente no servidor X evita dependências de software de usuário. Exemplo para ajuste de gama:

```bash
Section "Screen"
    Identifier     "Screen0"
    Device         "Radeon RX 580"
    DefaultDepth    24
    Option         "ColorTone" "75"
    Option         "Brightness" "0.9"
    Option         "Gamma" "1.0:0.85:0.55"
EndSection
```

### Configuração multi-GPU

Sistemas com GPUs integrada e dedicada exigem declaração explícita:

```bash
Section "ServerLayout"
    Identifier     "DualGPU"
    Screen      0  "IntelScreen" 0 0
    Screen      1  "NvidiaScreen" RightOf "IntelScreen"
    Option         "Xinerama" "1"
EndSection

Section "Device"
    Identifier  "IntelGPU"
    Driver      "intel"
    BusID       "PCI:0:2:0"
EndSection

Section "Device"
    Identifier  "NvidiaGPU"
    Driver      "nvidia"
    BusID       "PCI:1:0:0"
EndSection
```

Aqui, o erro frequente é omitir o BusID, causando:

```
[     3.112] (EE) No devices detected
```

### Exercício Prático

**Problema**: Configure um mouse Logitech MX Master 3 para usar o botão lateral como tecla "F15" e ajuste o DPI para 800.

**Solução**:

```bash
Section "InputClass"
    Identifier      "Logitech MX Master 3"
    MatchProduct    "Logitech MX Master 3"
    Driver          "libinput"
    Option          "ButtonMapping" "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
    Option          "ScrollButton" "8"
    Option          "Resolution" "800"
EndSection
```

Verifique com `xinput --list-props "Logitech MX Master 3"`:

```
libinput Resolution (309): 800
libinput Button Scrolling Button (324): 8
```