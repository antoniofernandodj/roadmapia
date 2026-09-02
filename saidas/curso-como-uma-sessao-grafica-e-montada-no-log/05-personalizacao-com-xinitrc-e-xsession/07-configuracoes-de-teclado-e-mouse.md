## Configurações de teclado e mouse

Ao iniciar uma sessão gráfica, você pode precisar ajustar dispositivos de entrada antes mesmo do ambiente desktop carregar. O Xorg oferece ferramentas específicas para isso, que devem ser chamadas nos arquivos `.xinitrc` ou `.xsession`. Veja o que acontece quando tentamos usar um teclado ABNT2 sem configuração:

```bash
# Tentativa de usar teclado brasileiro sem configuração
setxkbmap -layout br
```

Se o comando acima não for executado durante a inicialização, você enfrentará dois problemas comuns: teclas como `ç` e `~` não funcionam corretamente, e o sistema pode interpretar pressionamentos como se estivesse usando um layout US. O mesmo vale para configurações de mouse - sem os parâmetros corretos, a velocidade e aceleração do ponteiro podem ficar inadequadas.

O comando completo para configurar um teclado ABNT2 com teclas mortas funcionando corretamente é:

```bash
setxkbmap -model abnt2 -layout br -variant abnt2
```

Já para o mouse, os principais ajustes são feitos com `xinput`. Primeiro identifique seu dispositivo:

```bash
xinput list
```

A saída será algo como:
```
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ Logitech MX Master 3                    	id=9	[slave  pointer  (2)]
```

Com o ID do dispositivo (9 no exemplo), ajuste a aceleração (0-1, onde 1 é mais rápido) e sensibilidade:

```bash
xinput --set-prop 9 'libinput Accel Speed' 0.5
xinput --set-prop 9 'libinput Natural Scrolling Enabled' 1
```

Um erro comum é esquecer o `&` ao colocar esses comandos no `.xinitrc`, o que impedirá a continuação do boot gráfico. Veja a versão correta:

```bash
#!/bin/sh
# ~/.xinitrc - Configurações de entrada
setxkbmap -model abnt2 -layout br -variant abnt2 &
xinput --set-prop 9 'libinput Accel Speed' 0.5 &
xinput --set-prop 9 'libinput Natural Scrolling Enabled' 1 &
exec startxfce4
```

Se você receber o erro `Cannot open display` ao testar esses comandos, significa que está tentando executá-los fora do contexto do Xorg. A solução é garantir que:
1. Estão no arquivo correto (`.xinitrc` para `startx`, `.xsession` para gerenciadores de login)
2. O display está corretamente configurado (usar `:0` para a sessão principal)

Para laptops, é comum precisar desativar o touchpad ao conectar um mouse externo. Isso pode ser feito com:

```bash
xinput --disable 10  # Substitua 10 pelo ID do touchpad
```

**Exercício**: Configure seu teclado para layout ABNT2 com variante de teclado numérico e ajuste o mouse para sensibilidade 0.7 com rolagem natural invertida. Verifique as configurações com:

```bash
setxkbmap -query
xinput --list-props <ID-do-mouse>
```

**Solução**:
```bash
# ~/.xinitrc ou ~/.xsession
setxkbmap -model abnt2 -layout br -variant abnt2 -option numpad:pc &
xinput --set-prop 9 'libinput Accel Speed' 0.7 &
xinput --set-prop 9 'libinput Natural Scrolling Enabled' 0 &
```