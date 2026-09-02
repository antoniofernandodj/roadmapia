## Arquivos de configuração do Xorg

Quando o servidor Xorg inicia, ele busca parâmetros de configuração em locais específicos do sistema. Esses arquivos determinam desde o driver de vídeo utilizado até o mapeamento de teclado e a disposição de monitores. Ao contrário de muitos sistemas modernos que optam por configurações dinâmicas, o Xorg mantém uma abordagem explícita onde quase tudo pode ser definido em arquivos de texto.

### O arquivo xorg.conf e seus fragmentos

O arquivo principal está tradicionalmente em `/etc/X11/xorg.conf`, mas sistemas atuais raramente utilizam este arquivo monolítico. Em vez disso, adotam uma estrutura modular em `/etc/X11/xorg.conf.d/`, onde cada arquivo `.conf` contém uma seção específica da configuração. Por exemplo:

```bash
$ ls /etc/X11/xorg.conf.d/
10-evdev.conf  20-intel.conf  30-touchpad.conf  40-monitor.conf
```

Cada arquivo segue a mesma sintaxe do xorg.conf tradicional, mas aborda apenas um componente. A ordem numérica no prefixo define a prioridade de carregamento. Veja a estrutura básica de um desses arquivos:

```bash
# /etc/X11/xorg.conf.d/20-keyboard.conf
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
EndSection
```

Se você tentar criar um arquivo sem a seção correta, o Xorg rejeitará com um erro como:

```
(EE) Failed to load /etc/X11/xorg.conf.d/90-foo.conf: Invalid section header
```

### Locais alternativos de configuração

Além do diretório system-wide, o Xorg verifica locais específicos do usuário. A busca ocorre nesta ordem:

1. `/etc/X11/xorg.conf`
2. `/etc/X11/xorg.conf.d/*.conf`
3. `/usr/share/X11/xorg.conf.d/*.conf`
4. `~/.xorg.conf` (obsoleto, mas ainda verificado)

Um erro comum é editar arquivos em `/usr/share/X11/xorg.conf.d/`, que são sobrescritos em atualizações de pacotes. Sempre prefira `/etc/X11/xorg.conf.d/` para configurações persistentes.

### Estrutura típica das seções

Os arquivos de configuração dividem-se em seções principais. Veja um exemplo completo para um setup básico:

```bash
# Exemplo: /etc/X11/xorg.conf.d/10-devices.conf
Section "ServerLayout"
    Identifier     "Default Layout"
    Screen      0  "Screen0" 0 0
    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
EndSection

Section "InputDevice"
    Identifier     "Keyboard0"
    Driver         "kbd"
    Option         "XkbLayout" "us"
EndSection

Section "InputDevice"
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/input/mice"
EndSection

Section "Monitor"
    Identifier     "Monitor0"
    VendorName     "Unknown"
    ModelName      "Unknown"
    Option         "DPMS"
EndSection

Section "Device"
    Identifier     "Device0"
    Driver         "nouveau"
    VendorName     "NVIDIA"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    SubSection     "Display"
        Depth       24
        Modes      "1920x1080"
    EndSubSection
EndSection
```

Cada `Identifier` deve ser único e é referenciado em outras seções (como `Screen0` em `ServerLayout`). Se houver duplicatas, o Xorg avisará:

```
(WW) Multiple Device sections for driver "nouveau" (GPU0, GPU1)
(EE) No screens found
```

### Verificando configurações ativas

Para entender como o Xorg interpretou suas configurações, consulte o log em `/var/log/Xorg.0.log`. As linhas marcadas com `(==)` indicam configurações aplicadas:

```bash
$ grep "(==" /var/log/Xorg.0.log
(==) Log file: "/var/log/Xorg.0.log"
(==) Using config directory: "/etc/X11/xorg.conf.d"
(==) Using system config directory "/usr/share/X11/xorg.conf.d"
```

Para uma visão completa de todas as opções ativas, incluindo as detectadas automaticamente, use:

```bash
$ Xorg -showopts 2>&1 | less
```

### Exercício: Criando um fragmento de configuração

Problema: Configure o touchpad para desativar o tapping (toque como click) e habilitar o scrolling com dois dedos.

Solução (crie como `/etc/X11/xorg.conf.d/30-touchpad.conf`):

```bash
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "off"
    Option "NaturalScrolling" "true"
    Option "TappingButtonMap" "lrm"
EndSection
```

Após reiniciar a sessão gráfica, verifique no log do Xorg (`/var/log/Xorg.0.log`) se as opções foram aplicadas corretamente.