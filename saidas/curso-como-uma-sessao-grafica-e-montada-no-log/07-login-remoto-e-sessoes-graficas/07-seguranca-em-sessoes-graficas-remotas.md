## Segurança em sessões gráficas remotas

Acessar aplicações gráficas remotamente via X11 Forwarding é conveniente, mas abre brechas de segurança quando mal configurado. Considere este cenário comum:

```bash
ssh -X usuario@servidor
xclock
```

O relógio gráfico aparece na sua máquina local, mas todo o tráfego X11 está sendo tunelado pelo SSH. O perigo aparece quando você executa:

```bash
xhost +
```

Isso desativa a autenticação X11, permitindo que qualquer máquina na rede se conecte à sua sessão gráfica. Teste o impacto com:

```bash
# Na máquina remota:
mkdir ~/capturas
xwd -root -out ~/capturas/tela.xwd
```

Você acabou de capturar a tela inteira do servidor X local - exatamente o que um atacante faria. A saída:

```
xwd: Window id: 0x0000001 (root window)
```

Para corrigir, primeiro desative o acesso aberto:

```bash
xhost -
```

O protocolo X11 original (sem SSH) tem três vulnerabilidades principais:

1. **Tráfego não criptografado**: Pacotes podem ser capturados na rede. Solução: Sempre use `-X` ou `-Y` no SSH.

2. **Autenticação por cookies fracos**: O arquivo `~/.Xauthority` contém credenciais reutilizáveis. Teste o risco:

```bash
# Mostra os cookies ativos:
xauth list
```

Saída típica:
```
servidor/unix:10  MIT-MAGIC-COOKIE-1  a1b2c3d4e5f6...
```

Se este arquivo for roubado, o atacante pode se passar por você. Proteja-o com:

```bash
chmod 600 ~/.Xauthority
```

3. **Acesso a recursos locais**: Aplicativos remotos podem:
   - Ler teclas pressionadas (`xinput test-xi2`)
   - Capturar áudio via PulseAudio
   - Acessar arquivos locais

Para Wayland, a segurança é melhor por padrão, mas exige ferramentas específicas:

```bash
waypipe ssh usuario@servidor weston-terminal
```

Configurações essenciais no `/etc/ssh/sshd_config`:

```ini
X11Forwarding yes
X11UseLocalhost yes
XAuthLocation /usr/bin/xauth
```

Erros comuns e correções:

1. **Erro de permissão**:
```
X11 connection rejected because of wrong authentication.
```
Solução:
```bash
xauth add $(xauth list | tail -1)
```

2. **Vazamento de cookies**:
```bash
# ERRADO:
scp servidor:.Xauthority .
# CORRETO:
ssh -X servidor xterm
```

3. **Aplicativos bloqueados**:
```
Authorization required, but no authorization protocol specified
```
Adicione no seu `~/.bashrc`:
```bash
export XAUTHORITY=~/.Xauthority
```

Exercício: Configure um servidor SSH para:
1. Aceitar apenas X11 Forwarding de usuários específicos
2. Limitar o tempo de sessão para 2 horas
3. Registrar todos os comandos X11 executados

Solução comentada:

```bash
# /etc/ssh/sshd_config
Match User usuario1,usuario2
    X11Forwarding yes
    X11DisplayOffset 10
    ForceCommand echo "X11 acesso $(date)" >> /var/log/x11.log; $SSH_ORIGINAL_COMMAND
    MaxSession 2
```

```bash
# No client, teste com:
ssh -X usuario1@servidor xeyes | tee -a x11.log
```