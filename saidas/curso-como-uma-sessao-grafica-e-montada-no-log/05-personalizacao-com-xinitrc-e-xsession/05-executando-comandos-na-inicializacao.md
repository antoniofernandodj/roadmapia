## Executando comandos na inicialização

Quando você inicia uma sessão gráfica, frequentemente precisa rodar comandos específicos antes ou junto com seu ambiente de trabalho. O servidor X (ou Wayland) não sabe que você quer configurar seu teclado ABNT2, iniciar um gerenciador de janelas alternativo ou carregar seu wallpaper favorito - você precisa dizer isso explicitamente.

Tomemos um exemplo concreto: você instalou o i3 como gerenciador de janelas e quer que ele sempre:
1. Configure seu teclado para layout ABNT2
2. Carregue um wallpaper com feh
3. Inicie o compositor picom para efeitos visuais
4. Execute o gerenciador de rede nm-applet

O erro mais comum é tentar colocar isso no `.bashrc`, o que não funciona porque:
- Esses comandos precisam rodar no contexto gráfico
- O `.bashrc` é executado para cada novo terminal, não na inicialização
- Comandos gráficos falham quando executados em sessões não-gráficas

Veja o que acontece se tentarmos no `.bashrc`:
```bash
# ISSO NÃO FUNCIONARÁ COMO ESPERADO:
setxkbmap -model abnt2 -layout br
feh --bg-scale ~/wallpaper.jpg
picom &
nm-applet &
```

Ao logar via gerenciador gráfico (como LightDM ou GDM), esses comandos serão ignorados. A solução está nos arquivos específicos para inicialização gráfica.

### Usando .xinitrc (para startx)

Se você inicia sua sessão com `startx`, use `~/.xinitrc`. Um exemplo funcional:

```bash
#!/bin/sh

# Configuração do teclado
setxkbmap -model abnt2 -layout br &

# Wallpaper
feh --bg-scale ~/wallpaper.jpg &

# Compositor para transparências e sombras
picom &

# Applets da área de notificação
nm-applet &
blueman-applet &

# Finalmente inicia o i3
exec i3
```

Pontos cruciais:
1. O `&` após cada comando os coloca em segundo plano
2. O `exec` antes do comando principal substitui o processo atual pelo i3
3. Sem o `exec`, sua sessão terminaria assim que o i3 fosse fechado

### Usando .xsession (para gerenciadores de login)

Com gerenciadores gráficos (LightDM, GDM etc.), o arquivo é `~/.xsession`:

```bash
#!/bin/bash

# Configurações iniciais
export GTK_THEME=Adwaita-dark
setxkbmap -model abnt2 -layout br

# Iniciar utilitários
feh --bg-scale ~/wallpaper.jpg &
picom &
nm-applet &

# Ambiente Desktop (escolha UM)
exec startplasma-x11  # Para KDE
# exec gnome-session   # Para GNOME
# exec i3              # Para i3
```

Diferenças importantes em relação ao .xinitrc:
1. Não é obrigatório usar `&` (mas recomendado para evitar travamentos)
2. O `exec` é opcional mas recomendado para consistência
3. Você pode exportar variáveis de ambiente que serão herdadas

### Solução para o erro "xinit: connection to X server lost"

Se você esquecer o `exec` no .xinitrc, ao sair do gerenciador de janelas verá:
```
xinit: connection to X server lost
```

Isso acontece porque sem o `exec`, quando o i3/gnome/kde termina, o xinit também termina. Com `exec`, o gerenciador substitui o processo xinit.

### Testando suas configurações

Para testar sem afetar sua sessão atual:
```bash
startx -- :1  # Usa display :1 em vez do :0 padrão
```

Ou, para gerenciadores de login, crie um usuário teste:
```bash
sudo useradd testuser -m
sudo passwd testuser
```

### Exercício Prático

Crie um .xinitrc que:
1. Configure o teclado para US internacional
2. Defina um wallpaper da pasta /usr/share/backgrounds
3. Inicie o gerenciador de energia xfce4-power-manager
4. Execute o XFCE

Solução:
```bash
#!/bin/sh
setxkbmap -layout us -variant intl &
feh --bg-scale /usr/share/backgrounds/default.jpg &
xfce4-power-manager &
exec startxfce4
```