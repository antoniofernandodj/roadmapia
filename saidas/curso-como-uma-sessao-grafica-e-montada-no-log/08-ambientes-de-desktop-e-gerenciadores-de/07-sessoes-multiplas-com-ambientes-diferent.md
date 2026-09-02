## Sessões múltiplas com ambientes diferentes

Você precisa testar um aplicativo no GNOME, mas trabalha normalmente no i3wm. Ou quer comparar o comportamento do mesmo programa no Xorg e no Wayland sem reiniciar o computador. Criar sessões paralelas com ambientes gráficos diferentes resolve isso - e evita a dor de reconfigurar tudo depois.

O segredo está no comando `loginctl` do systemd, que gerencia sessões de usuário. Execute este comando em um terminal já logado:

```bash
loginctl list-sessions
```

A saída mostrará algo como:
```
SESSION  UID USER   SEAT  TTY
      1 1000 alice  seat0 tty2
```

Isso indica que a sessão atual (1) está no terminal virtual tty2. Para iniciar uma nova sessão gráfica com outro ambiente, primeiro verifique quais estão disponíveis:

```bash
ls /usr/share/xsessions/
```

Supondo que você queira iniciar uma sessão GNOME ao lado do seu i3wm atual, o comando é:

```bash
systemd-run --user --scope --slice=gnome-session.slice \
    env XDG_SESSION_TYPE=x11 gnome-session
```

Este comando cria uma nova sessão no mesmo usuário, mas em um "sandbox" (o slice) separado. O problema imediato que você encontrará:

```
Failed to connect to bus: No such file or directory
```

Isso acontece porque variáveis críticas do D-Bus não foram configuradas. A solução é copiar o ambiente da sessão atual:

```bash
systemd-run --user --scope --slice=gnome-session.slice \
    $(env | grep -E 'DBUS|XAUTHORITY' | xargs) \
    env XDG_SESSION_TYPE=x11 gnome-session
```

Agora o GNOME iniciará - mas em qual display? O Xorg padrão (:0) já está em uso. Precisamos forçar um novo:

```bash
systemd-run --user --scope --slice=gnome-session.slice \
    $(env | grep -E 'DBUS|XAUTHORITY' | xargs) \
    env DISPLAY=:1 XDG_SESSION_TYPE=x11 gnome-session
```

Você verá o erro:
```
No protocol specified
gnome-session: Failed to connect to X server :1
```

Falta autorizar o novo display. Primeiro, gere uma chave de acesso:

```bash
xauth generate :1 . trusted
```

Depois exporte a autorização para a sessão:

```bash
systemd-run --user --scope --slice=gnome-session.slice \
    $(env | grep -E 'DBUS|XAUTHORITY' | xargs) \
    env DISPLAY=:1 XAUTHORITY=$HOME/.Xauthority XDG_SESSION_TYPE=x11 \
    /usr/bin/Xorg :1 -retro -keeptty vt8 &
sleep 3 # Espera o Xorg iniciar
gnome-session
```

Agora você terá duas sessões rodando simultaneamente. Para alternar entre elas, use `Ctrl+Alt+F1` a `F8` (cada sessão Xorg precisa de um terminal virtual dedicado).

No Wayland, o processo é diferente. Para iniciar uma sessão GNOME Wayland paralela:

```bash
systemd-run --user --scope --slice=gnome-wayland.slice \
    $(env | grep DBUS_SESSION_BUS_ADDRESS | xargs) \
    env XDG_SESSION_TYPE=wayland dbus-run-session -- gnome-session
```

O erro comum aqui é:
```
Failed to start GNOME session: Wayland compositor not found
```

Isso ocorre porque o compositor precisa de acesso direto ao hardware gráfico. A solução é forçar o uso do backend correto:

```bash
systemd-run --user --scope --slice=gnome-wayland.slice \
    $(env | grep DBUS_SESSION_BUS_ADDRESS | xargs) \
    env XDG_SESSION_TYPE=wayland GBM_BACKEND=nvidia-drm \
    dbus-run-session -- gnome-session
```

**Exercício**: Inicie uma sessão KDE Plasma ao lado do seu ambiente atual, usando Wayland. Verifique os processos em execução com `ps aux | grep plasma` e analise as diferenças entre as sessões.

**Solução**:
```bash
# Gerar novo arquivo de autorização X
xauth generate :2 . trusted

# Iniciar sessão KDE Wayland
systemd-run --user --scope --slice=kde-wayland.slice \
    $(env | grep -E 'DBUS|XAUTHORITY' | xargs) \
    env DISPLAY=:2 XAUTHORITY=$HOME/.Xauthority \
    XDG_SESSION_TYPE=wayland dbus-run-session -- startplasma-wayland
```

A chave aqui é:
1. Cada sessão precisa de um display X (:0, :1, etc) ou namespace Wayland único
2. As variáveis DBUS_SESSION_BUS_ADDRESS e XAUTHORITY são críticas para autenticação
3. O systemd-run --scope --slice mantém a sessão organizada e isolada