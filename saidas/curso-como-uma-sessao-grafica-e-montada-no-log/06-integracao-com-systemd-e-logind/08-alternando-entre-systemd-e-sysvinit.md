## Alternando entre systemd e sysvinit

Quando um gerenciador de login como LightDM ou GDM inicia uma sessão gráfica, ele precisa interagir com o sistema de inicialização. Em distribuições modernas, isso normalmente significa o systemd, mas sistemas legados ainda podem usar o sysvinit. A diferença no comportamento é significativa:

```bash
# Em systemd:
$ systemctl status display-manager
● gdm.service - GNOME Display Manager
   Loaded: loaded (/usr/lib/systemd/system/gdm.service; enabled)
   Active: active (running) since Fri 2023-05-12 09:30:45 -03; 1h ago
```

Comparado ao sysvinit tradicional:
```bash
# Em sysvinit:
$ service gdm status
gdm (pid 1234) is running...
```

O principal impacto nas sessões gráficas ocorre no gerenciamento de dependências. Enquanto o systemd resolve automaticamente a ordem de inicialização, no sysvinit você precisa configurar manualmente os scripts em `/etc/init.d/`:

```bash
# Script sysvinit básico para gerenciador de login
#!/bin/sh
### BEGIN INIT INFO
# Provides:          gdm
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     5
# Default-Stop:      0 1 2 6
### END INIT INFO

case "$1" in
  start)
    /usr/sbin/gdm
    ;;
  stop)
    killall gdm
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
```

Um erro comum ao migrar entre os sistemas é esquecer que o sysvinit não gerencia automaticamente os processos filhos. Se você matar o gerenciador de login no sysvinit, a sessão gráfica inteira será encerrada:

```bash
$ sudo killall gdm  # Em sysvinit - mata toda a sessão
```

Enquanto no systemd, os processos são organizados em cgroups:
```bash
$ systemd-cgls
├─1 /usr/lib/systemd/systemd --switched-root --system --deserialize 31
├─user-1000.slice
│ └─session-2.scope
│   ├─5678 /usr/bin/gnome-shell
│   ├─5690 /usr/bin/Xwayland :0 -rootless
```

Para converter um sistema com sysvinit para systemd mantendo a sessão gráfica, você precisa:

1. Identificar os serviços gráficos essenciais:
```bash
$ ls -l /etc/init.d/* | egrep 'gdm|lightdm|sddm|xdm'
```

2. Criar unidades systemd equivalentes (exemplo para LightDM):
```lightdm.service
[Unit]
Description=Light Display Manager
After=systemd-user-sessions.service getty@tty1.service plymouth-quit.service

[Service]
ExecStart=/usr/sbin/lightdm
Restart=always
```

3. Ativar o alvo gráfico:
```bash
$ systemctl enable lightdm.service
$ systemctl set-default graphical.target
```

A mensagem de erro típica quando há conflito entre os sistemas é:
```
Failed to start lightdm.service: Unit lightdm.service is masked.
```

Isso ocorre quando há resquícios do sysvinit. A correção é:
```bash
$ systemctl unmask lightdm
$ systemctl daemon-reload
```

**Exercício**: Um sistema com sysvinit está com o serviço `gdm` configurado para iniciar no runlevel 3 em vez do 5. Como corrigir mantendo a compatibilidade para futura migração ao systemd?

**Solução**:
```bash
# Verificar runlevel atual
$ runlevel
N 3

# Criar link simbólico para o runlevel 5
$ ln -s /etc/init.d/gdm /etc/rc5.d/S99gdm

# Testar
$ telinit 5
```
A solução mantém a compatibilidade porque o systemd ignora os runlevels quando ativo, mas o sistema continua funcional no sysvinit.