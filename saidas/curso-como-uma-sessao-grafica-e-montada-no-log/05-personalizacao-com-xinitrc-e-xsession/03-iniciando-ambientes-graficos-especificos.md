## Iniciando ambientes gráficos específicos

Quando você executa `startx` ou faz login via gerenciador gráfico, o sistema precisa saber qual ambiente gráfico deve iniciar. É aqui que `.xinitrc` e `.xsession` entram em ação, permitindo que você defina exatamente qual ambiente iniciar e com quais configurações.

Vamos começar com um exemplo prático. Suponha que você tenha instalado tanto o GNOME quanto o i3 e queira alternar entre eles. Um `.xinitrc` básico para iniciar o i3 seria:

```bash
#!/bin/sh

# Configurações pré-iniciais
setxkbmap br &
feh --bg-fill ~/wallpaper.jpg &

# Inicia o i3
exec i3
```

Se você tentar executar isso com `startx`, porém, pode receber um erro comum:

```
xinit: giving up
xinit: unable to connect to X server: Connection refused
xinit: server error
```

Isso acontece porque o Xorg não está configurado para permitir conexões do usuário atual. O correto é executar:

```bash
startx $HOME/.xinitrc -- :1
```

O `:1` especifica um display alternativo (o padrão é `:0`), permitindo testar sua configuração sem afetar sua sessão atual.

Para ambientes desktop completos como GNOME ou KDE Plasma, o comando muda. Veja como iniciar o GNOME:

```bash
#!/bin/sh

# Omita o '&' no último comando - ele deve manter o processo rodando
exec gnome-session
```

A diferença crucial está no `exec`: ele substitui o processo atual pelo ambiente gráfico, que se torna o processo principal. Se você esquecer o `exec`, o script terminará imediatamente após iniciar o ambiente, encerrando toda a sessão.

Quando usando gerenciadores de login (como LightDM ou GDM), o arquivo muda para `.xsession`. Um exemplo para o KDE Plasma:

```bash
#!/bin/sh

# Configurações específicas do usuário
export QT_STYLE_OVERRIDE=gtk2

# Inicia o Plasma
startplasma-x11
```

Note que aqui não usamos `exec` - o gerenciador de login já cuida do gerenciamento do processo. Um erro comum é copiar o `.xinitrc` para `.xsession` sem ajustar essa diferença, resultando em uma sessão que inicia e imediatamente termina.

Para ambientes leves como Openbox ou Fluxbox, você pode combinar múltiplos elementos:

```bash
#!/bin/sh

# Inicia serviços em segundo plano
compton --config ~/.config/compton.conf &
tint2 &

# Configurações de teclado
setxkbmap -layout br -variant abnt2 &

# Inicia o Openbox
exec openbox-session
```

Se você precisar testar rapidamente um ambiente sem criar arquivos de configuração, pode passar o comando diretamente:

```bash
startx /usr/bin/i3 -- :1
```

Lembre-se: cada ambiente tem seu próprio executável principal. Alguns exemplos comuns:

- GNOME: `gnome-session`
- KDE Plasma: `startplasma-x11` ou `startplasma-wayland`
- XFCE: `startxfce4`
- i3: `i3`
- Sway: `sway`

Um erro frequente é esquecer de tornar o arquivo executável:

```bash
chmod +x ~/.xinitrc
```

Sem isso, o sistema não conseguirá executar seu script, resultando em comportamento inesperado ou falha silenciosa.