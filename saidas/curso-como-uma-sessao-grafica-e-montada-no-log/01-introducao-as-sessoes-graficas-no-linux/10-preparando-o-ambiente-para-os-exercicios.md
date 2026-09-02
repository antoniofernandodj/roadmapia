## Preparando o ambiente para os exercícios

Antes de modificar qualquer componente da sessão gráfica, é crucial criar um ambiente seguro para testes. Um erro comum é realizar alterações diretas na sessão principal, o que pode levar a um sistema inacessível, exigindo recuperação via terminal (Ctrl+Alt+F2) ou modo de emergência.

**Solução: Crie uma conta de usuário dedicada para testes:**

```bash
sudo adduser teste-sessao
sudo usermod -aG video,audio teste-sessao
```

O grupo `video` garante acesso aos dispositivos gráficos, enquanto `audio` permite testes com multimídia. Verifique os grupos com:

```bash
groups teste-sessao
```

**Ambiente de recuperação:** Mantenha um terminal virtual acessível. No GNOME, pressione Ctrl+Alt+F2 para alternar para TTY2. Instale um gerenciador de janelas mínimo como fallback:

```bash
sudo apt install xterm twm  # Debian/Ubuntu
# ou
sudo pacman -S xterm twm   # Arch
```

**Backup de arquivos críticos:** Os principais arquivos de configuração que você modificará incluem:

```bash
cp ~/.xinitrc ~/.xinitrc.bak
cp ~/.xsession ~/.xsession.bak
sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak
```

**Testando a infraestrutura básica:** Verifique se o servidor gráfico responde com:

```bash
xdpyinfo | head -n 5
# Saída esperada:
name of display:    :0
version number:    11.0
vendor string:    The X.Org Foundation
vendor release number:    12011000
```

**Erro comum e correção:**
Ao tentar iniciar uma sessão manualmente, você pode encontrar:

```bash
startx
# Erro: 
xinit: unable to connect to X server: Connection refused
```

Isso ocorre quando o servidor X já está em execução. Corrija especificando um display diferente:

```bash
startx -- :1
```

**Monitoramento em tempo real:** Em outro terminal, execute:

```bash
journalctl -f -u gdm  # Para GDM
# ou
journalctl -f -u sddm # Para SDDM
```

**Exemplo de ambiente mínimo funcional:** Crie um `~/.xinitrc` de teste:

```bash
#!/bin/sh
xterm &
exec twm
```

Torne-o executável e teste:

```bash
chmod +x ~/.xinitrc
startx -- :1
```

**Dica avançada:** Para testar Wayland sem afetar a sessão principal:

```bash
sudo systemctl stop gdm
sudo -u teste-sessao XDG_RUNTIME_DIR=/run/user/$(id -u teste-sessao) dbus-run-session -- gnome-shell --display-server --wayland
```

**Exercício:** Configure um ambiente mínimo com:
1. Um terminal (xterm)
2. Um gerenciador de janelas (twm)
3. Um relógio digital (xclock)

**Solução comentada:**

```bash
#!/bin/sh
xclock -digital -update 1 &
xterm -e top &
exec twm
```