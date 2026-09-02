## Configurando o display manager para Wayland

Quando você inicia seu sistema Linux, o display manager (gerenciador de exibição) é o primeiro componente gráfico executado. No contexto do Wayland, sua configuração adequada determina se a sessão será iniciada nativamente no Wayland ou através do X11. Vamos resolver o problema prático de garantir que sua sessão gráfica utilize Wayland por padrão.

### Identificando e modificando o display manager atual

Primeiro, descubra qual display manager está instalado no seu sistema (GDM, LightDM ou SDDM são os mais comuns):

```bash
cat /etc/X11/default-display-manager
```

No Ubuntu 22.04 com GNOME, você verá tipicamente `/usr/sbin/gdm3`. Para configurá-lo para Wayland, edite:

```bash
sudo nano /etc/gdm3/custom.conf
```

Remova o comentário da linha (adicione se não existir):

```ini
WaylandEnable=true
```

Se você encontrar `#WaylandEnable=false`, mude para `WaylandEnable=true`. Este é o erro mais comum - a linha existe mas está comentada ou definida como falsa.

### Validando a sessão Wayland

Após reiniciar o sistema, verifique se está realmente usando Wayland:

```bash
echo $XDG_SESSION_TYPE
```

Se o comando retornar `wayland`, você conseguiu. Caso retorne `x11`, há três causas prováveis:

1. **Drivers incompatíveis**: Execute `glxinfo | grep "OpenGL renderer"` para verificar se seus drivers suportam Wayland. Drivers NVIDIA exigem configuração adicional.

2. **GDM forçando X11**: O GDM pode reverter para X11 se detectar problemas. Verifique logs com:

```bash
journalctl -u gdm -b | grep -i wayland
```

3. **Hardware antigo**: Sistemas sem suporte a modesetting (consulte `lsmod | grep kms`) podem ser incompatíveis.

### Solução para drivers NVIDIA

Se você usa drivers proprietários da NVIDIA, precisará de configuração adicional:

```bash
sudo nano /usr/lib/udev/rules.d/61-gdm.rules
```

Localize e comente a linha que contém `RUN+="/usr/libexec/gdm-disable-wayland"`.

### Configurando o LightDM

Para sistemas que usam LightDM (como Xubuntu), a configuração difere:

```bash
sudo nano /etc/lightdm/lightdm.conf
```

Adicione ou modifique:

```ini
[Seat:*]
display-setup-script=/usr/bin/true
greeter-setup-script=/usr/bin/true
session-wrapper=/etc/lightdm/Xsession
```

Crie um arquivo de sessão Wayland:

```bash
sudo nano /usr/share/wayland-sessions/gnome-wayland.desktop
```

Com conteúdo:

```ini
[Desktop Entry]
Name=GNOME on Wayland
Comment=This session logs you into GNOME on Wayland
Exec=env GNOME_SHELL_SESSION_MODE=wayland dbus-run-session gnome-session --session=gnome-wayland
TryExec=gnome-session
Type=Application
DesktopNames=GNOME
```

### Testando com Weston (backup)

Para verificar se seu hardware suporta Wayland independentemente do display manager:

```bash
weston --backend=drm-backend.so
```

Se Weston iniciar corretamente, seu problema está na configuração do display manager, não no hardware.

### Exercício prático

1. Force seu sistema a usar Wayland mesmo com drivers NVIDIA:
   - Instale `nvidia-dkms-510` (ou versão mais recente)
   - Crie o arquivo `/etc/modprobe.d/nvidia-wayland.conf` com:
     ```conf
     options nvidia-drm modeset=1
     ```
   - Atualize initramfs: `sudo update-initramfs -u`

2. Solução:
   - O modo modesetting do driver NVIDIA deve ser habilitado para Wayland
   - A opção `modeset=1` permite que o DRM do kernel gerencie a GPU
   - O update-initramfs garante que a configuração persista após boot