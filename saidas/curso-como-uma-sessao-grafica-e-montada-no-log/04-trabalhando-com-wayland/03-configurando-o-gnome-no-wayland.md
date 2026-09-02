## Configurando o GNOME no Wayland

O GNOME é o ambiente desktop que mais cedo adotou o Wayland como padrão, mas essa transição trouxe desafios práticos. Vamos resolver três problemas reais: verificar se você está mesmo no Wayland, habilitar o Wayland quando ele estiver desativado e configurar aplicativos problemáticos para rodarem via XWayland.

**1. Confirmando a sessão ativa**

Execute no terminal:
```bash
echo $XDG_SESSION_TYPE
```
Se a saída for `wayland`, você já está no Wayland. Caso contrário, verá `x11`. Mas há uma pegadinha: o GNOME pode reportar falsamente "wayland" quando usa fallback para Xorg. Para confirmar de verdade:
```bash
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```
Saída esperada:
```
Type=wayland
```

**2. Ativando o Wayland quando desabilitado**

Em algumas distribuições (como Ubuntu LTS), o Wayland vem desativado por padrão. Edite:
```bash
sudo nano /etc/gdm3/custom.conf
```
Localize a linha:
```
#WaylandEnable=false
```
Descomente e altere para:
```
WaylandEnable=true
```
Reinicie o gdm:
```bash
sudo systemctl restart gdm3
```

**3. Gerenciando aplicativos problemáticos**

Quando um aplicativo não funciona no Wayland (como alguns Java Swing), force o XWayland. Crie um arquivo `.desktop` modificado:
```bash
cp /usr/share/applications/eclipse.desktop ~/.local/share/applications/
nano ~/.local/share/applications/eclipse.desktop
```
Adicione no início do arquivo:
```
[Desktop Entry]
Exec=env GDK_BACKEND=x11 eclipse
```
Agora o GNOME iniciará esse aplicativo via XWayland. Para ver quais apps estão usando XWayland:
```bash
xlsclients
```

**4. Configurações avançadas**

O GNOME no Wayland ignora alguns arquivos tradicionais como `~/.xprofile`. Use:
```bash
mkdir -p ~/.config/environment.d
nano ~/.config/environment.d/envvars.conf
```
Adicione variáveis como:
```
GDK_BACKEND=wayland
CLUTTER_BACKEND=wayland
```

**Erro comum e solução**

Ao tentar gravar a tela, você pode encontrar:
```
ERROR: Unable to retrieve framebuffer (requires CAP_SYS_ADMIN)
```
Solucione criando um arquivo `/etc/systemd/system/gdm.service.d/override.conf` com:
```
[Service]
CapabilityBoundingSet=CAP_SYS_ADMIN
AmbientCapabilities=CAP_SYS_ADMIN
```

**Exercício prático**

1. Confirme se sua sessão GNOME está realmente rodando no Wayland
2. Habilite o Wayland se estiver desativado
3. Configure o Discord para rodar via XWayland
4. Adicione uma variável de ambiente personalizada

*Solução comentada:*

Para o Discord, crie uma cópia local do `.desktop`:
```bash
cp /usr/share/applications/discord.desktop ~/.local/share/applications/
```
Edite a linha `Exec` para:
```
Exec=env GDK_BACKEND=x11 /usr/bin/discord
```
Isso resolve problemas de compartilhamento de tela em chamadas.