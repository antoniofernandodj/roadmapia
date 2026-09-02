## O papel do systemd e logind

Quando você faz login em uma sessão gráfica no Linux, não é apenas um ambiente visual que surge - há uma orquestração complexa ocorrendo nos bastidores. O systemd, como sistema de init moderno, e o logind (parte do systemd) são os maestros dessa sinfonia, controlando desde permissões até recursos de hardware.

### A sessão como unidade organizacional

Cada login gráfico cria uma nova sessão gerenciada pelo logind. Para ver todas as sessões ativas, execute:

```bash
loginctl list-sessions
```

A saída típica mostra:

```
SESSION  UID USER   SEAT  TTY  
      1 1000 joao   seat0 tty2
      2 1001 maria  seat1 tty3
```

Cada sessão possui propriedades específicas que podem ser inspecionadas:

```bash
loginctl show-session 1 -p Type -p Class -p Active -p State
```

Resultando em:

```
Type=graphical
Class=user
Active=yes
State=active
```

### Controle de recursos por sessão

O logind gerencia os dispositivos associados a cada sessão. Um exemplo prático: quando você conecta fones de ouvido durante uma sessão gráfica, eles são automaticamente direcionados para os aplicativos dessa sessão. Isso ocorre porque o logind controla o acesso ao hardware através de políticas.

Tente desconectar um dispositivo USB enquanto está logado:

```bash
udisksctl power-off -b /dev/sdb
```

Se o dispositivo estiver em uso por sua sessão, você receberá:

```
Error powering off: GDBus.Error:org.freedesktop.UDisks2.Error.DeviceBusy: Device /dev/sdb is busy
```

### Relação com servidores gráficos

No Xorg, o logind é responsável pelo "seat management" (gerenciamento de assentos). Veja como funciona na prática:

1. O gerenciador de login (GDM, SDDM, etc.) inicia o Xorg como um serviço do systemd
2. O Xorg se registra no logind para obter acesso exclusivo aos dispositivos de entrada
3. Quando um usuário faz login, o logind cria uma nova sessão e transfere o controle dos dispositivos

Para verificar isso, examine o status do servidor Xorg:

```bash
systemctl status display-manager.service
```

### O problema do Wayland

No Wayland, a situação muda. Cada compositor (GNOME Shell, KWin, etc.) atua como seu próprio servidor gráfico e se comunica diretamente com o logind. Isso cria uma integração mais estreita, mas também mais dependente do systemd.

Um erro comum ocorre ao tentar iniciar uma sessão Wayland sem os privilégios adequados:

```
Failed to start session: Permission denied
(GDBus.Error:org.freedesktop.Accounts.Error.PermissionDenied: Not authorized)
```

A solução envolve verificar as permissões do PAM e o arquivo `/etc/systemd/logind.conf`, particularmente as opções:

```
[Login]
NAutoVTs=6
ReserveVT=6
```

### Gerenciamento de energia e sessões

O logind também controla ações de suspensão e hibernação. Quando você fecha a tampa do notebook, é o logind que recebe o evento e decide a ação. Teste este comportamento com:

```bash
systemd-inhibit --what=handle-lid-switch sleep 1000
```

Enquanto esse comando estiver em execução, fechar a tampa não suspenderá o sistema - demonstrando como o logind gerencia esses eventos.

### Exercício: Depurando uma sessão travada

1. Identifique uma sessão gráfica travada com `loginctl list-sessions`
2. Termine a sessão problemática: `loginctl terminate-session C3`
3. Verifique os serviços associados: `systemctl --user status`
4. Reinicie o serviço gráfico: `systemctl restart display-manager`

Solução comentada:
- O passo 2 força o encerramento de todos os processos da sessão
- O passo 3 mostra serviços de usuário que podem ter falhado
- O passo 4 restaura o gerenciador de login para um novo acesso