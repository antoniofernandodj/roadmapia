## Segurança avançada em sessões gráficas

Um servidor gráfico exposto é como uma janela aberta no seu sistema - qualquer aplicação pode capturar teclas digitadas, fazer screenshots sem permissão ou até injeção de comandos. O problema fica evidente quando você executa:

```bash
xinput list
```

E vê todos os dispositivos de entrada disponíveis para qualquer processo. Pior: se seu `~/.Xauthority` tiver permissões erradas, qualquer usuário no sistema pode se passar por você na sessão X:

```bash
ls -la ~/.Xauthority
# -rw------- 1 user user 62 Nov 20 10:00 /home/user/.Xauthority
```

Se essas permissões forem `-rw-rw-r--`, você está vulnerável a ataques de sessão.

### Hardening do Xorg

Para travar o servidor X, edite `/etc/X11/xorg.conf.d/10-security.conf`:

```conf
Section "ServerFlags"
    Option "AllowMouseOpenFail" "true"
    Option "DisableVTSwitch" "true"
    Option "BlankTime" "5"
EndSection

Section "Security"
    Option "DisallowTCP" "true"
EndSection
```

Isso desativa:
- A troca para terminal virtual (Ctrl+Alt+F1)
- Conexões TCP remotas
- Define tempo de blank screen para 5 minutos

Verifique com:

```bash
ps aux | grep Xorg
# Não deve mostrar a flag -listen tcp
```

### Wayland: Segurança por Design

No Wayland, a segurança é inerente. Teste como aplicações não podem acessar outras janelas:

```bash
weston-terminal &
sleep 2
xdotool getwindowfocus # Falha com: "Can't open display"
```

Para configurar permissões explícitas no Sway (compositor Wayland), use:

```conf
# ~/.config/sway/config
assign [app_id="firefox"] $workspace 1
seat seat0 xcursor_theme Adwaita 24
```

### PAM e Limites de Sessão

Edite `/etc/security/limits.conf` para restringir recursos por usuário:

```conf
user1 hard cpu 2
user1 hard nproc 100
user2 hard mem 4G
```

Isso previne ataques de negação de serviço dentro da sessão gráfica.

### Erro Comum e Correção

Se você configurar:

```conf
# /etc/X11/Xwrapper.config
allowed_users=console
```

E tentar iniciar via gerenciador de login, verá:

```
X: user not authorized to run the X server, aborting.
```

Corrija com:

```bash
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
```

### Exercício Prático

Proteja uma sessão Xorg existente para:

1. Desativar o CTRL+ALT+BACKSPACE
2. Restringir um usuário a 50% de CPU
3. Impedir acesso ao sistema de arquivos via X11

Solução:

1. `/etc/X11/xorg.conf.d/10-security.conf`:
```conf
Section "ServerFlags"
    Option "DontZap" "true"
EndSection
```

2. `/etc/security/limits.conf`:
```conf
user hard cpu 50%
```

3. `/etc/X11/Xwrapper.config`:
```conf
needs_root_rights=yes
allowed_users=anybody
```