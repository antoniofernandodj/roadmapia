## Temas e aparência via arquivos de inicialização

Quando você inicia uma sessão gráfica no Linux, o sistema carrega configurações visuais básicas por padrão. Mas os arquivos `.xinitrc` e `.xsession` permitem personalizar isso profundamente. Vamos começar com um problema concreto: seu ambiente gráfico inicia com um tema genérico e você quer aplicar um esquema de cores específico automaticamente.

### Aplicando temas GTK e QT

Os ambientes gráficos modernos usam dois sistemas de temas principais: GTK (para GNOME, XFCE) e QT (para KDE). Para configurá-los via `.xinitrc`, usamos variáveis de ambiente:

```bash
#!/bin/sh

# Temas GTK
export GTK_THEME=Adwaita-dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc

# Temas QT
export QT_STYLE_OVERRIDE=adwaita-dark
export QT_QPA_PLATFORMTHEME=gtk2

exec startxfce4
```

Se você esquecer o `export`, o tema não será aplicado. O erro será silencioso - o ambiente iniciará com o tema padrão. Sem mensagens de erro, o que torna difícil diagnosticar.

Para verificar se as variáveis foram carregadas corretamente, execute no terminal após o login:

```bash
printenv | grep GTK
```

### Configurando temas de ícones e cursor

Além do tema principal, podemos definir ícones e cursores:

```bash
#!/bin/sh

# Tema de ícones
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
export ICON_THEME=Adwaita

# Papel de parede - requer feh ou nitrogen
feh --bg-scale /usr/share/backgrounds/gnome/adwaita-day.jpg &

exec i3
```

Um erro comum é tentar configurar o papel de parede sem ter o `feh` ou `nitrogen` instalado. Você verá a mensagem:

```
feh: command not found
```

Corrija instalando o pacote necessário (`sudo apt install feh` no Debian/Ubuntu).

### Tema específico para aplicativos QT em ambientes não-KDE

Quando rodamos aplicativos QT (como o VirtualBox) em ambientes não-KDE, eles podem parecer deslocados. A solução está no `.xsession`:

```bash
#!/bin/bash

# Forçar estilo QT5 em ambientes não-KDE
export QT_QPA_PLATFORMTHEME=qt5ct

# Configurações específicas do qt5ct
export QT5CT_DIR=/home/usuario/.config/qt5ct

/usr/bin/startplasma-x11
```

Se você configurar isso errado, aplicativos QT podem travar com:

```
qt.qpa.xcb: could not connect to display
```

Isso geralmente indica que o comando foi executado fora do contexto gráfico.

### Exemplo completo: Tema escuro para todo o sistema

Veja um `.xinitrc` completo aplicando um tema escuro em todos os componentes:

```bash
#!/bin/sh

# GTK
export GTK_THEME=Adwaita-dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc

# QT
export QT_STYLE_OVERRIDE=adwaita-dark
export QT_QPA_PLATFORMTHEME=gtk2

# Ícones e cursor
export XCURSOR_THEME=Adwaita
export ICON_THEME=Adwaita-dark

# Papel de parede
feh --bg-scale /usr/share/backgrounds/gnome/adwaita-morning.jpg &

# Iniciar ambiente
exec startxfce4
```

Depois de salvar, torne o arquivo executável:

```bash
chmod +x ~/.xinitrc
```

### Exercício: Criando um tema claro/escuro que muda com a hora

Vamos modificar o `.xinitrc` para alternar entre temas claro e escuro baseado no horário:

```bash
#!/bin/sh

HOUR=$(date +%H)

if [ $HOUR -ge 18 ] || [ $HOUR -lt 6 ]; then
  # Modo noturno
  export GTK_THEME=Adwaita-dark
  feh --bg-scale ~/wallpapers/night.jpg &
else
  # Modo diurno
  export GTK_THEME=Adwaita
  feh --bg-scale ~/wallpapers/day.jpg &
fi

exec i3
```

Problema comum: Se você esquecer o `&` após o comando `feh`, o ambiente gráfico não iniciará - o script ficará esperando o `feh` terminar. Você verá apenas uma tela preta.