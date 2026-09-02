## Configurando teclado e mouse

Quando você digita em uma janela do terminal ou move o cursor pela tela, o Xorg precisa saber exatamente como interpretar os sinais vindos do seu hardware. Isso é especialmente crítico em três situações: quando seu teclado tem um layout diferente do padrão (como ABNT2), quando você usa um mouse com botões extras ou quando precisa ajustar a aceleração do ponteiro.

Primeiro, vamos identificar seus dispositivos. Execute:

```bash
ls /dev/input/by-id/
```

A saída mostrará links simbólicos como `usb-Logitech_USB_Keyboard-event-kbd` e `usb-USB_Optical_Mouse-event-mouse`, que apontam para os dispositivos reais em `/dev/input/`. Anote esses nomes – usaremos nos arquivos de configuração.

### Teclado: Mais que QWERTY

Para um teclado ABNT2 (com Ç), crie `/etc/X11/xorg.conf.d/10-keyboard.conf` com:

```bash
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbModel" "abnt2"
    Option "XkbVariant" ""
    Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
```

Se você tentar usar apenas `"br"` sem especificar o modelo, o Xorg vai reclamar no log (`/var/log/Xorg.0.log`):

```
(EE) Error loading keymap /var/lib/xkb/server-0.xkm
(EE) XKB: Couldn't compile keymap
```

A opção `terminate:ctrl_alt_bksp` permite reiniciar o Xorg com Ctrl+Alt+Backspace (útil quando ele travar). Teste as configurações sem reiniciar com:

```bash
setxkbmap -model abnt2 -layout br
```

### Mouse: Botões e Velocidade

Para um mouse com rolagem horizontal, o arquivo `/etc/X11/xorg.conf.d/20-mouse.conf` deve conter:

```bash
Section "InputClass"
    Identifier "Logitech Mouse"
    MatchIsPointer "on"
    MatchProduct "USB Optical Mouse"
    Option "AccelerationProfile" "2"
    Option "AccelerationScheme" "predictable"
    Option "Resolution" "1000"
    Option "ButtonMapping" "1 2 3 4 5 6 7 8 9 10"
EndSection
```

O número após `Resolution` é DPI (pontos por polegada). Valores comuns:
- 800 para uso geral
- 2000+ para jogos
- 400 para desenho preciso

Se configurar um DPI muito alto, o cursor vai ficar extremamente sensível. Nesse caso, reduza o valor gradualmente até achar o ideal.

Para testar os botões do mouse, use:

```bash
xev | grep button
```

Ao clicar, a saída mostrará eventos como:
```
state 0x10, button 1, same_screen YES
state 0x110, button 3, same_screen YES
```

### Disposição: Esquerda ou Direita?

Para trocar os botões primário e secundário do mouse (útil para canhotos), adicione:

```bash
Option "LeftHanded" "1"
```

Isso faz com que:
- Botão físico 1 (esquerdo) → função secundária
- Botão físico 3 (direito) → função primária

### Teclado: Atalhos Customizados

Para mapear Ctrl+Alt+T para abrir um terminal, crie `~/.Xmodmap` com:

```bash
clear control
clear mod4

keycode 37 = Control_L
keycode 105 = Control_R
keycode 133 = Super_L

! Abre terminal com Ctrl+Alt+T
add control = Control_L Control_R
add mod4 = Super_L
```

Aplique com:

```bash
xmodmap ~/.Xmodmap
```

Se você cometer um erro de sintaxe no arquivo, como esquecer o `!` antes de comentários, o erro será:

```
xmodmap:  ~/.Xmodmap:6: bad command name 'Abre'
```

### Exercício Prático

**Problema**: Configure um mouse Logitech MX Master 3 (que tem botão lateral padrão como "voltar" no navegador) para:
1. Usar DPI 1600
2. Mapear o botão lateral (normalmente btn 8) como F5 (atualizar página)

**Solução**:

```bash
Section "InputClass"
    Identifier "Logitech MX Master 3"
    MatchProduct "MX Master 3"
    Option "Resolution" "1600"
    Option "ButtonMapping" "1 2 3 4 5 6 7 2 9 10"
EndSection
```

A chave está no mapeamento `7 2` – o sétimo botão físico (lateral) aciona a função do segundo botão lógico (click direito). O F5 pode ser mapeado via `xbindkeys` em conjunto.