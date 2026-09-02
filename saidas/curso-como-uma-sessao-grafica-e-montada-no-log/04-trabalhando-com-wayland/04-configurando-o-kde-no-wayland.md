## Configurando o KDE no Wayland

O KDE Plasma oferece uma das implementações mais maduras do Wayland entre os ambientes desktop, mas ainda exige ajustes específicos para funcionar plenamente. Vamos resolver três problemas práticos: verificação da sessão ativa, configuração de aplicativos legacy via XWayland, e personalização de variáveis de ambiente.

**Problema 1: Confirmando a Sessão Wayland**

Ao contrário do Xorg, onde `echo $DISPLAY` é suficiente, no Wayland usamos:

```bash
loginctl list-sessions | grep -A2 $(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type)
```

Isso retorna:
```
Type=wayland
Desktop=plasma
```

Se você vir `Type=x11`, seu KDE está rodando em Xorg. Para forçar o Wayland, edite `/etc/sddm.conf`:

```ini
[General]
DisplayServer=wayland
```

Reinicie o SDDM com `sudo systemctl restart sddm` e selecione "Plasma (Wayland)" na tela de login.

**Problema 2: Aplicativos Legacy e XWayland**

O KDE ativa o XWayland por padrão, mas alguns aplicativos (como o Google Chrome) podem forçar o modo X11. Para ver quais apps estão usando XWayland:

```bash
ps aux | grep Xwayland
```

Para forçar um aplicativo específico ao modo nativo do Wayland, crie um arquivo `.desktop` personalizado em `~/.local/share/applications/`:

```ini
[Desktop Entry]
Exec=env QT_QPA_PLATFORM=wayland google-chrome-stable %U
Name=Chrome (Wayland)
```

**Problema 3: Variáveis de Ambiente**

No Xorg, usávamos `~/.xprofile`. No Wayland com KDE, adicione variáveis em `~/.config/plasma-workspace/env/vars.sh`:

```bash
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
```

Depois de editar, reinicie a sessão gráfica sem logout completo:

```bash
kwin_wayland --replace &
```

**Erro Comum: Telas Virtuais**

Se você usa `nvidia-settings` e encontra:

```
ERROR: Unable to assign XScreen 0 to display device
```

Crie um script em `/etc/profile.d/wayland-nvidia.sh`:

```bash
export __GL_GSYNC_ALLOWED=0
export __GL_VRR_ALLOWED=0
```

**Exercício Prático**
1. Force o Firefox a usar Wayland nativo via variável de ambiente
2. Verifique quantos processos XWayland estão ativos
3. Desative o XWayland completamente no KDE

*Solução:*

1. Adicione ao `vars.sh`:
```bash
export MOZ_ENABLE_WAYLAND=1
```

2. Comando:
```bash
pgrep -c Xwayland
```

3. Edite `/usr/share/sddm/scripts/Xsetup` comentando a linha:
```bash
#export XWAYLAND="1"
```