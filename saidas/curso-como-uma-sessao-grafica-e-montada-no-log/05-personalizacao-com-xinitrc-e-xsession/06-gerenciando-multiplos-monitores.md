## Gerenciando múltiplos monitores

Quando você conecta um segundo monitor ao seu sistema Linux, ele pode se comportar de três maneiras diferentes: espelhar a tela principal, estender a área de trabalho ou permanecer desligado. O comando `xrandr` é a ferramenta principal para configurar esses comportamentos sem precisar editar arquivos de configuração manualmente.

Primeiro, execute `xrandr` sem argumentos para listar suas saídas disponíveis:

```bash
xrandr
```

A saída típica mostra algo como:

```
HDMI-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 527mm x 296mm
DP-1 disconnected (normal left inverted right x axis y axis)
eDP-1 connected 1366x768+1920+0 (normal left inverted right x axis y axis) 309mm x 173mm
```

Aqui, `HDMI-1` e `eDP-1` (tela do notebook) estão conectadas. Para desativar a tela do notebook e usar apenas o monitor externo:

```bash
xrandr --output eDP-1 --off --output HDMI-1 --auto
```

Se você tentar desativar todas as telas acidentalmente, o Xorg responderá com:

```
xrandr: cannot find an output to enable
```

Nesse caso, reative rapidamente sua tela principal especificando um modo válido:

```bash
xrandr --output eDP-1 --auto
```

Para configurar um arranjo estendido com o monitor à direita da tela principal:

```bash
xrandr --output eDP-1 --auto --output HDMI-1 --auto --right-of eDP-1
```

A posição relativa é importante. Se você inverter a ordem com `--left-of`, o ponteiro do mouse não transitará corretamente entre os monitores.

Para persistir essas configurações entre sessões, adicione os comandos ao seu `.xinitrc` ou `.xsession`. Por exemplo:

```bash
# ~/.xinitrc
xrandr --output eDP-1 --auto --output HDMI-1 --auto --right-of eDP-1 &
exec i3
```

Um erro comum é esquecer o `&` após o comando `xrandr`, o que fará com que a sessão gráfica só inicie após o comando terminar (o que nunca acontece, pois ele não bloqueia). A mensagem de erro não será clara - você simplesmente ficará com uma tela preta.

Se você precisar reverter para a configuração padrão de um único monitor:

```bash
xrandr --auto
```

Este comando reativa todas as telas detectadas com suas resoluções nativas.

**Exercício**: Configure seu sistema para espelhar as telas em 1024x768 e depois restaure o arranjo original. Verifique com `xrandr` após cada alteração.

<details>
<summary>Solução</summary>

Para espelhar as telas:

```bash
xrandr --output HDMI-1 --mode 1024x768 --same-as eDP-1
```

Para restaurar:

```bash
xrandr --auto
```

Verifique com:

```bash
xrandr | grep -E 'connected|disconnected'
```
</details>