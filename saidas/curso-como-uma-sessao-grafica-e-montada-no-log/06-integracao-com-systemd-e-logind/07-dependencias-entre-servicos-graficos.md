## Dependências entre serviços gráficos

No Linux moderno, a inicialização de uma sessão gráfica depende de uma cadeia de serviços que precisam ser iniciados na ordem correta e com as dependências adequadas. Cada serviço gráfico depende de outros para funcionar, e entender essas relações é essencial para resolver problemas de inicialização ou personalizar o ambiente.

Vamos começar com um exemplo prático: o serviço `graphical.target`, que representa o estado final de uma sessão gráfica completa. Para alcançar esse estado, o systemd precisa iniciar vários outros serviços na ordem correta. Podemos visualizar essas dependências com o comando `systemctl list-dependencies graphical.target`:

```bash
$ systemctl list-dependencies graphical.target
graphical.target
● ├─accounts-daemon.service
● ├─apparmor.service
● ├─avahi-daemon.service
● ├─bluetooth.service
● ├─cups.service
● ├─dbus.service
● ├─display-manager.service
● ├─gdm.service
● ├─network-manager.service
● ├─plymouth-quit-wait.service
● ├─rsyslog.service
● ├─systemd-update-utmp-runlevel.service
● ├─udisks2.service
● └─wpa_supplicant.service
```

Observe como `dbus.service` aparece antes de `display-manager.service`. Isso ocorre porque o gerenciador de login depende do serviço D-Bus para comunicação entre processos. Se tentarmos iniciar o gerenciador de login sem o D-Bus, o sistema falhará silenciosamente ou exibirá uma mensagem de erro como:

```
Failed to start display-manager.service: Unit dbus.service not found.
```

Outra dependência crítica é entre o gerenciador de login e o servidor gráfico. Por exemplo, ao usar o GDM (GNOME Display Manager) com Xorg, o serviço `gdm.service` depende de `xorg.service`. Podemos inspecionar essa relação com:

```bash
$ systemctl cat gdm.service
...
[Unit]
Description=GNOME Display Manager
After=systemd-user-sessions.service plymouth-quit-wait.service
Conflicts=getty@tty1.service
Requires=xorg.service
...
```

Aqui, `Requires=xorg.service` garante que o Xorg esteja ativo antes do GDM iniciar. Se o Xorg falhar, o GDM também falhará, mesmo que o serviço em si esteja funcionando corretamente.

Um erro comum ao configurar sessões gráficas é modificar dependências sem entender as consequências. Por exemplo, se removemos a dependência de `dbus.service` do `display-manager.service` para tentar acelerar o boot, o resultado será um sistema que parece iniciar mas não exibe a tela de login:

```bash
$ sudo systemctl edit display-manager.service
# Removendo a linha After=dbus.service
$ sudo systemctl restart display-manager.service
$ journalctl -u display-manager.service
...
Failed to acquire bus name org.freedesktop.DisplayManager
```

Para corrigir, precisamos restaurar a dependência:

```bash
$ sudo systemctl edit display-manager.service
[Unit]
After=dbus.service
```

Quando trabalhamos com Wayland, as dependências mudam. O serviço `gdm.service` pode depender diretamente de `wayland.service` em vez de `xorg.service`. Podemos verificar isso com:

```bash
$ systemctl cat wayland.service
[Unit]
Description=Wayland Display Server
Before=gdm.service
```

Essa relação inversa (`Before=gdm.service` em vez de `After=gdm.service`) garante que o Wayland esteja pronto antes que o GDM tente usá-lo.

Um exemplo avançado envolve a inicialização paralela de serviços gráficos. O systemd permite que alguns serviços sejam iniciados simultaneamente quando suas dependências permitem. Podemos usar `systemd-analyze critical-chain graphical.target` para identificar os gargalos:

```bash
$ systemd-analyze critical-chain graphical.target
The time after the unit is active or started is printed after the "@" character.
The time the unit takes to start is printed after the "+" character.

graphical.target @1min 4.235s
└─multi-user.target @1min 4.235s
  └─dbus.service @1min 3.234s +1s
    └─basic.target @1min 3.234s
      └─sockets.target @1min 3.234s
        └─dbus.socket @1min 3.234s
          └─sysinit.target @1min 3.234s
            └─systemd-tmpfiles-setup.service @1min 2.234s +1s
```

Neste caso, `systemd-tmpfiles-setup.service` é o gargalo principal. Se quisermos acelerar o boot gráfico, precisamos otimizar esse serviço ou suas dependências.

Para consolidar o entendimento, vamos criar um serviço gráfico simples que depende de `dbus.service` e `network-manager.service`. Criamos o arquivo `/etc/systemd/system/custom-graphical.service`:

```ini
[Unit]
Description=Custom Graphical Service
After=dbus.service network-manager.service
Requires=dbus.service network-manager.service

[Service]
ExecStart=/usr/bin/xeyes
Restart=on-failure

[Install]
WantedBy=graphical.target
```

Depois de criar o serviço, podemos habilitá-lo e verificar suas dependências:

```bash
$ sudo systemctl enable custom-graphical.service
$ systemctl list-dependencies custom-graphical.service
custom-graphical.service
● ├─dbus.service
● └─network-manager.service
```

Se tentarmos iniciar o serviço sem o D-Bus ativo, receberemos um erro:

```bash
$ sudo systemctl stop dbus.service
$ sudo systemctl start custom-graphical.service
Job for custom-graphical.service failed because a required resource was not available.
See "systemctl status custom-graphical.service" and "journalctl -xe" for details.
```

O exercício final consiste em criar um serviço gráfico que dependa de `cups.service` e `bluetooth.service`, e inspecionar suas dependências com `systemctl list-dependencies`. A solução é criar `/etc/systemd/system/printer-bluetooth.service`:

```ini
[Unit]
Description=Printer Bluetooth Service
After=cups.service bluetooth.service
Requires=cups.service bluetooth.service

[Service]
ExecStart=/usr/bin/xcalc
Restart=on-failure

[Install]
WantedBy=graphical.target
```

Após habilitar e iniciar o serviço, podemos verificar suas dependências:

```bash
$ sudo systemctl enable printer-bluetooth.service
$ systemctl list-dependencies printer-bluetooth.service
printer-bluetooth.service
● ├─bluetooth.service
● └─cups.service
```

Este serviço garante que o CUPS e o Bluetooth estejam ativos antes de tentar iniciar a calculadora gráfica, demonstrando como as dependências entre serviços gráficos funcionam na prática.