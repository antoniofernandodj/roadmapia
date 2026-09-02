## Autostart e aplicativos iniciais

Você inicia uma sessão no KDE Plasma e seu cliente de email, gestor de senhas e ferramenta de anotações já estão abertos. Minutos depois, ao trocar para o GNOME, percebe que nenhum desses programas carregou automaticamente. O problema não está nos aplicativos, mas em como cada ambiente de desktop gerencia autostart - o processo de iniciar programas automaticamente durante o login.

No XFCE, você adiciona um atalho `.desktop` em `~/.config/autostart/`, mas o mesmo método falha no GNOME. Isso acontece porque ambientes diferentes implementam autostart de formas distintas:

**1. Método .desktop (padrão Freedesktop)**
Funciona na maioria dos DEs (KDE, XFCE, LXDE), mas requer configuração adicional no GNOME. Veja como criar um autostart para o KeePassXC:

```bash
cat > ~/.config/autostart/keepassxc.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=KeePassXC
Exec=keepassxc
Comment=Password Manager
X-GNOME-Autostart-enabled=true
EOF
```

Se o arquivo não executar, verifique as permissões:
```bash
chmod +x ~/.config/autostart/keepassxc.desktop
```

**2. Método específico do GNOME**
O GNOME ignora alguns arquivos `.desktop` a menos que você os habilite manualmente:

```bash
# Para ativar um autostart existente
dbus-launch gsettings set org.gnome.desktop.session session-name "gnome-x11"
```

**3. Autostart no KDE Plasma**
Além do método `.desktop`, o KDE oferece uma interface gráfica completa:

```bash
kwriteconfig5 --file startkderc --group Scripts --key count 1
kwriteconfig5 --file startkderc --group Scripts --key script0 "/usr/bin/keepassxc"
```

**Erro comum:** Ao misturar métodos, você pode acabar com múltiplas instâncias do mesmo programa. Verifique com:

```bash
pgrep -l keepassxc
# Saída esperada: um único PID
```

**Debugando autostart que falhou**
Use o journalctl para identificar problemas:

```bash
journalctl -b --user-unit=plasma-workspace.service | grep -i autostart
```

**Exemplo avançado - Iniciar com delay**
Para programas pesados que podem atrasar a inicialização:

```bash
cat > ~/.config/autostart/slack.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Slack
Exec=bash -c 'sleep 15; /usr/bin/slack'
EOF
```

**Wayland vs Xorg**
No Wayland, alguns métodos de autostart podem falhar silenciosamente. Teste com:

```bash
systemctl --user list-timers | grep xdg
# Verifique os timers de autostart
```

**Solução para ambientes minimalistas (i3, bspwm)**
Adicione diretamente no arquivo de configuração do WM:

```bash
# ~/.config/i3/config
exec --no-startup-id keepassxc
exec --no-startup-id slack
```

**Exercício:** Configure o Element (Matrix client) para iniciar automaticamente no seu ambiente atual, com delay de 10 segundos. Verifique se o processo está rodando com `pgrep -l element`.

**Solução comentada:**

```bash
# 1. Criar o arquivo .desktop com delay
cat > ~/.config/autostart/element.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Element
Exec=bash -c 'sleep 10; /usr/bin/element-desktop --hidden'
EOF

# 2. Dar permissões
chmod +x ~/.config/autostart/element.desktop

# 3. Verificar (aguarde 15s após login)
pgrep -l element | wc -l
# Deve retornar 1
```