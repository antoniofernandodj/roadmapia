## Gerenciamento de sessões com systemd

Quando você inicia uma sessão gráfica, o systemd não apenas inicia os processos — ele cria um *escopo* dedicado que controla todos os recursos da sessão. Veja o que acontece quando executamos `systemctl --user status` em uma sessão ativa:

```bash
$ systemctl --user list-units --type=scope --all
UNIT                LOAD   ACTIVE SUB    DESCRIPTION                
session-2.scope     loaded active running Session 2 of user bruno
```

Este escopo contém todos os processos gráficos como filhos diretos. Para entender o impacto, compare estes dois cenários de falha:

1. **Sem systemd**: Se o gerenciador de janelas crasha, processos órfãos continuam rodando
2. **Com systemd**: O escopo inteiro é terminado, limpando todos os recursos

Vamos criar um serviço de usuário que depende da sessão gráfica. Crie `~/.config/systemd/user/status-monitor.service`:

```ini
[Unit]
Description=Status Monitor
After=graphical-session.target
Requires=graphical-session.target

[Service]
ExecStart=/usr/bin/xfce4-terminal -e 'watch -n 1 systemctl --user status'
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```

Ative e inicie o serviço:
```bash
systemctl --user enable --now status-monitor.service
```

Agora, quando você sair da sessão gráfica, o serviço será automaticamente encerrado. Isso evita o erro comum de serviços "zumbis" que persistem após o logout.

Para depuração avançada, use o journald com filtros específicos:
```bash
journalctl --user-unit=status-monitor.service -b -f
```

Um erro frequente é esquecer de habilitar o lingering para serviços de usuário que devem persistir entre logins. Corrija com:

```bash
# SEM lingering (serviços terminam no logout)
systemctl --user enable myservice

# COM lingering (serviços persistem)
sudo loginctl enable-linger username
```

Quando precisar executar comandos no contexto da sessão gráfica (como definir variáveis de ambiente do DBus), use:

```bash
systemd-run --user --scope --property=After=graphical-session.target \
    env DISPLAY=:0 xdg-open https://exemplo.com
```

A saída do comando acima será similar a:
```
Running scope as unit: run-r12345.scope
```

Para monitorar todos os serviços de sessão em tempo real, crie este painel combinado:
```bash
watch -n 1 "systemctl --user list-units --type=service --all; echo '---'; systemctl --user list-units --type=scope --all"
```

Isso mostra tanto os serviços convencionais quanto os escopos de sessão ativos.

Exercício: Crie um serviço que:
1. Inicia quando a sessão gráfica começa
2. Monitora o uso de memória da sessão
3. Grava logs em ~/.session-metrics.log
4. Sobrevive a reinícios do gerenciador de janelas

Solução comentada:
```ini
# ~/.config/systemd/user/session-metrics.service
[Unit]
Description=Session Metrics Logger
PartOf=graphical-session.target

[Service]
ExecStart=/bin/sh -c 'while true; do date >> %h/.session-metrics.log; \
    systemd-cgtop -b -n 1 -m user.slice >> %h/.session-metrics.log; sleep 5; done'
Restart=always

[Install]
WantedBy=graphical-session.target
```

Key points:
- `PartOf=` garante que o serviço seja encerrado com a sessão
- `%h` expande para o diretório home do usuário
- `systemd-cgtop` mostra estatísticas por controle de grupo