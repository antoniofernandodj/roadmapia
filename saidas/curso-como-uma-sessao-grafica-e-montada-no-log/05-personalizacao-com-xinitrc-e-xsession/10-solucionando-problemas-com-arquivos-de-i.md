## Solucionando problemas com arquivos de inicialização

Quando os arquivos `.xinitrc` ou `.xsession` falham, o resultado costuma ser uma tela preta ou um retorno imediato ao gerenciador de login. A raiz do problema geralmente está em três áreas: sintaxe incorreta, contexto de execução errado ou conflitos entre processos.

**Erro 1: Sessão que encerra imediatamente**

O erro mais crítico ocorre quando omitimos `exec` no `.xinitrc`:

```bash
# ERRADO - causará logout instantâneo
i3
```

A mensagem de erro no log (`~/.local/share/xorg/Xorg.0.log`) será:
```
(EE) Server terminated successfully (0). Closing log file.
```

A correção exige `exec` para substituir o processo atual:

```bash
# CORRETO
exec i3
```

**Erro 2: Comandos em segundo plano bloqueando a inicialização**

Esquecer `&` em comandos preliminares causa congelamento:

```bash
# ERRADO - congela até o feh terminar
feh --bg-scale ~/wallpaper.jpg
exec i3
```

A sessão só iniciará após o comando anterior completar. A versão correta:

```bash
# CORRETO - roda em background
feh --bg-scale ~/wallpaper.jpg &
exec i3
```

**Erro 3: Variáveis de ambiente não propagadas**

Este `.xsession` não aplica o tema GTK:

```bash
# ERRADO - variável só existe neste shell
GTK_THEME=Adwaita-dark
gnome-session
```

O correto usa `export`:

```bash
# CORRETO - disponível para todos os processos
export GTK_THEME=Adwaita-dark
gnome-session
```

**Teste seguro sem reiniciar a sessão**

Para depuração, use um display virtual:

```bash
startx ~/.xinitrc -- :1  # Usa display :1 em vez do principal (:0)
```

Verifique erros em tempo real com:

```bash
tail -f ~/.local/share/xorg/Xorg.1.log
```

**Exemplo completo funcional**

Este `.xinitrc` inclui tratamentos de erro:

```bash
#!/bin/sh

# Configurações preliminares (background)
feh --bg-fill ~/wallpaper.jpg &

# Teclado (com fallback)
setxkbmap br -model pc105 || notify-send "Falha no layout"

# Tema (com verificação)
[ -n "$GTK_THEME" ] || export GTK_THEME=Adwaita-dark

# Inicia ambiente com fallback para twm se falhar
exec i3 || exec twm
```

Saída esperada quando bem-sucedido:
```
xinit: X server started on display :0
i3: Starting version 4.22...
```

**Conflito comum: Múltiplas chamadas a `dbus-launch`**

Alguns ambientes iniciam seu próprio D-Bus. Duplicar a chamada causa:

```
(dbus-daemon:1435): GLib-CRITICAL **: g_strdup: assertion 'str != NULL' failed
```

Solução: Remova `dbus-launch` explícito se já estiver no `.xsessionrc` do sistema.

**Exercício: Depurar um .xinitrc com falha**

Dado este arquivo com problemas:

```bash
#!/bin/sh
nitrogen --restore
picom
export QT_STYLE_OVERRIDE=gtk2
startplasma-x11
```

1. Identifique 3 erros de sintaxe/execução
2. Corrija-os mantendo a funcionalidade
3. Teste no display :1

**Solução comentada**

```bash
#!/bin/sh
nitrogen --restore &  # Faltou &
picom &               # Faltou &
export QT_STYLE_OVERRIDE=gtk2
exec startplasma-x11  # Usar exec e corrigir comando para KDE
```