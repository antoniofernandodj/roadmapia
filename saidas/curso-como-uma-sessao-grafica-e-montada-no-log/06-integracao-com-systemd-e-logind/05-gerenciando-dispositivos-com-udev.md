## Gerenciando dispositivos com udev

Quando você conecta um teclado USB ou um mouse sem fio em uma sessão gráfica Linux, o sistema precisa fazer muito mais do que apenas "reconhecer" o dispositivo. Ele precisa:

1. Carregar os drivers corretos
2. Atribuir permissões adequadas
3. Criar nós de dispositivo em `/dev`
4. Notificar os aplicativos sobre a nova disponibilidade

O udev é o subsistema responsável por toda essa orquestração. Veja o que acontece quando você pluga um dispositivo USB simples:

```bash
# Conecte um dispositivo USB e observe em tempo real
udevadm monitor --property
```

Você verá uma saída como esta quando conectar um mouse:

```
UDEV  [489299.487356] add      /devices/pci0000:00/0000:00:14.0/usb1/1-2/1-2:1.0/input/input24/mouse1 (input)
ACTION=add
DEVNAME=/dev/input/mouse1
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb1/1-2/1-2:1.0/input/input24/mouse1
MAJOR=13
MINOR=33
SUBSYSTEM=input
USEC_INITIALIZED=489299487356
```

**O erro clássico**: Você conecta uma webcam, mas o aplicativo gráfico não consegue acessá-la. Isso acontece porque o dispositivo foi criado com permissões incorretas:

```bash
ls -l /dev/video0
# crw-rw---- 1 root video 81, 0 Jun 10 14:30 /dev/video0
```

A solução? O udev permite regras personalizadas. Crie `/etc/udev/rules.d/99-webcam.rules`:

```bash
ACTION=="add", SUBSYSTEM=="video4linux", ATTR{idVendor}=="046d", ATTR{idProduct}=="0825", GROUP="video", MODE="0666"
```

Recarregue as regras e reconecte o dispositivo:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Agora verifique as novas permissões:

```bash
ls -l /dev/video0
# crw-rw-rw- 1 root video 81, 0 Jun 10 14:32 /dev/video0
```

**Como o udev se integra com o systemd?** Quando um dispositivo é conectado:

1. O kernel detecta e envia um uevent
2. O udevd (serviço systemd) processa o evento
3. As regras são aplicadas em `/lib/udev/rules.d/` e `/etc/udev/rules.d/`
4. Dispositivos são criados em `/dev`
5. Serviços systemd podem ser acionados via `SYSTEMD_WANTS`

Para dispositivos gráficos como GPUs, o udev é especialmente crítico. Veja como listar propriedades de uma GPU:

```bash
udevadm info -a -p /sys/class/drm/card0
```

Isso revela informações essenciais para configuração do driver gráfico:

```
  looking at device '/devices/pci0000:00/0000:00:02.0/drm/card0':
    KERNEL=="card0"
    SUBSYSTEM=="drm"
    DRIVER==""
    ATTR{name}=="i915"
```

**Exercício**: Crie uma regra udev que:
1. Detecte um modelo específico de teclado (use `lsusb` para obter vendor/product)
2. Mude o grupo para `input`
3. Defina permissões 660
4. Acione um script em `/usr/local/bin/keyboard-setup.sh`

**Solução**:

```bash
# /etc/udev/rules.d/90-keyboard.rules
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c317", GROUP="input", MODE="0660", RUN+="/usr/local/bin/keyboard-setup.sh"
```

Verifique com:

```bash
udevadm test /sys/class/usb/your-keyboard-path
```