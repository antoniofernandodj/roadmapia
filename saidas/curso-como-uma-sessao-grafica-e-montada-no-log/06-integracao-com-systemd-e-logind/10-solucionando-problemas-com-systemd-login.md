## Solucionando problemas com systemd/logind

Um dos problemas mais comuns em sessões gráficas ocorre quando o systemd não consegue encerrar processos corretamente após o logout. Imagine tentar sair da sessão, mas o gerenciador de janelas continua rodando, consumindo recursos. O sintoma típico aparece ao verificar sessões ativas:

```bash
$ loginctl list-sessions
SESSION  UID USER   SEAT  TTY 
      1 1000 alice  seat0 tty2
```

Mesmo após logout, a sessão permanece como "ativo" com o status `lingering`. Isso acontece porque alguns processos filhos não foram terminados adequadamente. Para investigar:

```bash
$ loginctl session-status 1
1 - alice (1000)
           Since: Seg 2023-05-15 14:30:45 -03; 2h ago
          Leader: 1234 /usr/libexec/gnome-session-binary
            Unit: session-1.scope
                  ├─1234 /usr/libexec/gnome-session-binary
                  ├─1256 /usr/bin/gnome-shell
                  └─1289 /usr/bin/nautilus --gapplication-service
```

O comando `systemd-cgls` mostra a hierarquia completa de processos:

```bash
$ systemd-cgls --no-pager -u session-1.scope
Unit session-1.scope:
├─1234 /usr/libexec/gnome-session-binary
├─1256 /usr/bin/gnome-shell
└─1289 /usr/bin/nautilus --gapplication-service
```

**Solução 1:** Forçar o encerramento da sessão:

```bash
$ loginctl terminate-session 1
```

Isso envia SIGTERM para todos os processos na árvore. Se persistirem:

```bash
$ loginctl kill-session 1 SIGKILL
```

**Problema comum:** Serviços gráficos personalizados que não declararam corretamente suas dependências. Ao criar um serviço `/etc/systemd/system/custom-gui.service`:

```ini
[Unit]
Description=Serviço Gráfico Personalizado
After=graphical.target

[Service]
ExecStart=/usr/local/bin/my-gui-app
Restart=on-failure
```

Se esquecer de declarar `Wants=dbus.service`, o serviço pode falhar silenciosamente:

```bash
$ journalctl -u custom-gui --no-pager -n 5
mai 15 16:45:22 workstation systemd[1]: Started Serviço Gráfico Personalizado.
mai 15 16:45:22 workstation my-gui-app[2011]: ERRO: Falha ao conectar no D-Bus
mai 15 16:45:22 workstation systemd[1]: custom-gui.service: Main process exited, code=exited, status=1/FAILURE
```

**Correção:** Adicione as dependências necessárias:

```ini
[Unit]
Description=Serviço Gráfico Personalizado
After=graphical.target dbus.service
Wants=dbus.service
```

Após alterações, recarregue:

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart custom-gui
```

**Erro de permissão comum:** Ao tentar acessar dispositivos gráficos (como GPU):

```bash
$ journalctl -b | grep -i udev
mai 15 16:50:12 workstation kernel: NVRM: API mismatch: the client has the version 520.56.06, but
mai 15 16:50:12 workstation kernel: NVRM: this kernel module has the version 515.65.01.  Please...
```

Isso frequentemente ocorre quando o módulo do kernel e drivers userspace estão desatualizados. Verifique com:

```bash
$ lsmod | grep nvidia
nvidia              3526656  0
```

E compare com a versão do pacote:

```bash
$ nvidia-smi | grep Version
| NVIDIA-SMI 520.56.06    Driver Version: 520.56.06    CUDA Version: 11.8     |
```

**Solução:** Atualize os pacotes para versões compatíveis ou force o recarregamento:

```bash
$ sudo rmmod nvidia
$ sudo modprobe nvidia
```

**Exercício:** Você configurou um serviço personalizado que inicia um compositor Wayland, mas ele falha com a mensagem "Failed to create display". Use `journalctl` para identificar as dependências ausentes e corrija o arquivo de serviço.

**Solução comentada:**

1. Verifique os logs:

```bash
$ journalctl -u wayland-compositor -n 10
```

2. Identifique a dependência faltante (provavelmente `seatd` ou `greetd`)

3. Edite `/etc/systemd/system/wayland-compositor.service`:

```ini
[Unit]
Description=Wayland Compositor Personalizado
After=seatd.service
Requires=seatd.service

[Service]
ExecStart=/usr/local/bin/my-compositor
Restart=on-failure
```

4. Recarregue e reinicie:

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart wayland-compositor
```