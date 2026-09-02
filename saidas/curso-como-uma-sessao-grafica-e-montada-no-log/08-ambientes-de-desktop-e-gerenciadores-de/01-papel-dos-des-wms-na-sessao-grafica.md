## Papel dos DEs/WMs na sessão gráfica

Quando você seleciona um ambiente gráfico no gerenciador de login, está acionando uma cadeia de componentes que transformam seu terminal em uma experiência visual completa. Vamos dissecar o que realmente acontece quando o `gnome-session` ou `startxfce4` é executado.

**O ciclo de vida de uma sessão gráfica:**

1. O display manager (GDM, SDDM, LightDM) autentica o usuário
2. Executa o script de sessão correspondente (normalmente em `/usr/share/xsessions/`)
3. O ambiente assume o controle da saída gráfica

Veja na prática como o Xorg registra uma sessão GNOME:

```bash
# Execute isto em um terminal virtual (Ctrl+Alt+F2) após sair da sessão gráfica
startx /usr/bin/gnome-session -- vt1 2> ~/xorg.log
```

A saída no arquivo `xorg.log` mostrará:

```
(**) ServerLayout "GNOME"
(==) Using system config directory "/usr/share/X11/xorg.conf.d"
(++) Using config directory "/home/user/.config/xorg.conf.d"
```

**O que diferencia um DE completo de um WM básico?**

Um Desktop Environment (GNOME, KDE Plasma) é um pacote integrado que inclui:

- Gerenciador de janelas (mutter, kwin)
- Barra de tarefas/painel
- Gerenciador de arquivos
- Suite de aplicativos nativos
- Serviços de background (notificações, bluetooth)

Já um Window Manager (i3, Openbox) só controla:

- Posicionamento de janelas
- Decoração de bordas
- Foco e atalhos

Experimente substituir seu DE por um WM puro. Crie `~/.xinitrc` com:

```bash
#!/bin/sh
exec openbox-session
```

Você verá apenas um cursor funcional em uma tela vazia - sem menus, ícones ou gerenciamento de energia. Para ter funcionalidades básicas, precisaria adicionar manualmente:

```bash
#!/bin/sh
tint2 &      # Painel
pcmanfm &    # Gerenciador de arquivos
exec openbox-session
```

**Erro comum: conflito de compositors**

Ao tentar usar um compositor externo com um DE que já inclui um, você pode encontrar:

```
(EE) Failed to initialize composite extension
(EE) glamor initialization failed
```

Solução: desative o compositor nativo primeiro. No GNOME:

```bash
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
```

**Como os componentes se comunicam?**

A maioria dos DEs modernos usa D-Bus para coordenação. Liste os serviços ativos com:

```bash
dbus-send --session --dest=org.freedesktop.DBus --type=method_call \
--print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames
```

Isso revelará dezenas de serviços como `org.gnome.SessionManager` e `org.kde.KWin`.

**Exercício prático:**

1. Inicie uma sessão XFCE normalmente
2. Mate o painel principal: `pkill xfce4-panel`
3. Observe como outras componentes (gerenciador de janelas, applets) reagem
4. Restaure com `xfce4-panel &`

**Solução comentada:**

Ao remover o painel, você notará que:

- O gerenciador de janelas (xfwm4) continua funcionando
- Os applets morrem junto com o painel
- A sessão mantém-se estável porque o XFCE usa um modelo modular
- O comando `&` no final executa em background, permitindo continuar usando o terminal