## Solucionando problemas comuns no Xorg

O Xorg é um servidor gráfico robusto, mas não está imune a problemas. Muitas falhas são resultado de configurações incorretas ou conflitos entre componentes. Neste trecho, abordaremos alguns dos erros mais frequentes e como resolvê-los.

### 1. Falha ao iniciar o servidor Xorg

Um dos problemas mais comuns é a falha ao iniciar o servidor Xorg, muitas vezes acompanhada de uma tela preta ou um retorno ao terminal. Isso pode ocorrer devido a uma configuração incorreta no arquivo `xorg.conf` ou em algum dos arquivos em `/etc/X11/xorg.conf.d/`.

Para diagnosticar, verifique o log do Xorg em `/var/log/Xorg.0.log`. Procure por mensagens de erro próximas ao final do arquivo. Um erro comum é:

```
(EE) No screens found(EE)
```

Isso indica que o Xorg não conseguiu detectar nenhuma tela. Uma solução rápida é criar um arquivo de configuração mínimo em `/etc/X11/xorg.conf.d/10-screen.conf`:

```bash
Section "Device"
    Identifier  "Card0"
    Driver      "modesetting"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "Card0"
    Monitor    "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth     24
        Modes     "1920x1080"
    EndSubSection
EndSection
```

Salve o arquivo e reinicie o Xorg. Se o problema persistir, experimente usar o driver `vesa`, que é mais genérico e funciona na maioria dos casos.

### 2. Problemas com drivers de vídeo

Erros relacionados a drivers de vídeo são frequentes, especialmente após a instalação de um novo driver ou atualização do kernel. Para verificar qual driver está sendo usado, execute:

```bash
grep -i "driver" /var/log/Xorg.0.log
```

Se o driver correto não estiver sendo carregado, crie um arquivo de configuração específico para o driver em `/etc/X11/xorg.conf.d/20-driver.conf`. Por exemplo, para forçar o uso do driver NVIDIA:

```bash
Section "Device"
    Identifier  "NVIDIA GPU"
    Driver      "nvidia"
    BusID       "PCI:1:0:0"
EndSection
```

Substitua `PCI:1:0:0` pelo BusID correto do seu dispositivo, que pode ser obtido com `lspci`.

### 3. Configuração incorreta de teclado ou mouse

Se o teclado ou mouse não funcionar corretamente, como teclas não produzindo os caracteres esperados ou cliques do mouse não sendo registrados, é provável que haja um problema na configuração do dispositivo.

Verifique os dispositivos disponíveis com:

```bash
ls /dev/input/by-id/
```

Em seguida, crie um arquivo de configuração específico para o teclado ou mouse em `/etc/X11/xorg.conf.d/30-input.conf`. Por exemplo, para configurar um teclado ABNT2:

```bash
Section "InputClass"
    Identifier "ABNT2 Keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbModel" "abnt2"
EndSection
```

Para um mouse, você pode ajustar a aceleração e a resolução:

```bash
Section "InputClass"
    Identifier "Mouse Settings"
    MatchIsPointer "on"
    Option "AccelerationProfile" "-1"
    Option "Resolution" "1000"
EndSection
```

### 4. Problemas com múltiplos monitores

Configurar múltiplos monitores pode ser complicado, especialmente se eles tiverem resoluções diferentes. A ferramenta `xrandr` é útil para testar configurações temporárias antes de aplicá-las permanentemente.

Para listar os monitores disponíveis:

```bash
xrandr
```

Para configurar um segundo monitor à direita do principal com uma resolução específica:

```bash
xrandr --output HDMI-1 --mode 1920x1080 --right-of eDP-1
```

Se a configuração funcionar, você pode torná-la permanente adicionando uma seção `ServerLayout` em `/etc/X11/xorg.conf.d/40-monitor.conf`:

```bash
Section "ServerLayout"
    Identifier "MultiMonitor"
    Screen 0 "Screen0" 0 0
    Screen 1 "Screen1" RightOf "Screen0"
EndSection

Section "Monitor"
    Identifier "Monitor0"
    Option "Position" "0 0"
EndSection

Section "Monitor"
    Identifier "Monitor1"
    Option "Position" "1920 0"
EndSection
```

### 5. Falhas ao alternar entre sessões gráficas

Quando várias sessões gráficas estão em execução simultaneamente, pode ocorrer falhas ao tentar alternar entre elas. Isso geralmente acontece devido a conflitos na variável `DISPLAY`.

Para garantir que cada sessão gráfica tenha um `DISPLAY` único, inicie o Xorg com um identificador específico:

```bash
startx -- :1
```

Isso iniciará uma nova sessão gráfica no display `:1`. Para verificar quais sessões estão ativas:

```bash
ps aux | grep Xorg
```

Se necessário, encerre sessões específicas com `kill`:

```bash
kill $(pgrep -f "Xorg :1")
```

### 6. Problemas com aceleração gráfica

A aceleração gráfica pode não funcionar corretamente após a instalação de novos drivers ou atualizações do sistema. Para verificar se a aceleração gráfica está ativa:

```bash
glxinfo | grep "direct rendering"
```

Se o resultado for `direct rendering: Yes`, a aceleração gráfica está funcionando. Caso contrário, pode ser necessário reinstalar os drivers ou ajustar as configurações no Xorg.

### Exercício Prático

Configure um ambiente com dois monitores, onde o segundo monitor tenha uma resolução de 1600x900 e esteja posicionado à esquerda do monitor principal. Use `xrandr` para testar a configuração e, em seguida, torne-a permanente com um arquivo de configuração em `/etc/X11/xorg.conf.d/`.

**Solução:**

Primeiro, teste a configuração com `xrandr`:

```bash
xrandr --output HDMI-1 --mode 1600x900 --left-of eDP-1
```

Se funcionar, crie o arquivo de configuração `/etc/X11/xorg.conf.d/40-monitor.conf`:

```bash
Section "ServerLayout"
    Identifier "MultiMonitor"
    Screen 0 "Screen0" 1600 0
    Screen 1 "Screen1" 0 0
EndSection

Section "Monitor"
    Identifier "Monitor0"
    Option "Position" "1600 0"
EndSection

Section "Monitor"
    Identifier "Monitor1"
    Option "Position" "0 0"
EndSection
```

Reinicie o Xorg e verifique se a configuração foi aplicada corretamente.