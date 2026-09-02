## Integração com hardware específico

Um sistema embarcado com Wayland pode ter hardware gráfico variado - desde GPUs dedicadas até chipsets simples sem aceleração. Vamos resolver um problema real: configurar um sistema com GPU Mali-T720 e touchscreen resistivo usando o compositor Weston.

### Configurando o backend DRM para GPU Mali

Primeiro, instale os drivers necessários no Debian:

```bash
sudo apt install libdrm2 libegl-mesa0 libgbm1
```

O erro mais comum ocorre ao tentar iniciar o Weston sem permissões adequadas:

```
failed to initialize drm backend
Permission denied (13) - /dev/dri/card0
```

Corrija adicionando seu usuário ao grupo 'video':

```bash
sudo usermod -aG video $USER
```

Crie um arquivo `/etc/xdg/weston/weston.ini` com a configuração mínima:

```ini
[core]
backend=drm-backend.so
gbm-format=argb8888
```

Para verificar se a GPU está funcionando, execute:

```bash
weston --backend=drm-backend.so --tty=1 --log=/tmp/weston.log
```

A saída esperada no log deve incluir:

```
Mali-T720 detected
DRM backend initialized
```

### Integração com touchscreen resistivo

Touchscreens resistivos frequentemente requerem configuração manual. Primeiro identifique o dispositivo:

```bash
ls /dev/input/event*
```

Crie uma seção no `weston.ini` para o dispositivo de toque:

```ini
[libinput]
touchscreen_calibrator=true
touch_device=/dev/input/event2
```

Um erro comum é o desalinhamento entre toque e exibição. Calibre com:

```bash
weston-touch-calibrator /dev/input/event2
```

### Controlando a taxa de atualização

Em sistemas com restrição energética, ajuste a taxa de atualização:

```ini
[drm]
mode=1024x768@60
```

Para forçar modo de baixo consumo:

```bash
weston --use-pixman --drm-mode=1024x768@30
```

### Exemplo completo: Kiosk com touch

Veja uma configuração real para um terminal de autoatendimento:

```ini
[core]
idle-time=0
shell=kiosk-shell.so

[libinput]
touchscreen_calibrator=true
touch_device=/dev/input/event2
disable_touchpad=true

[drm]
mode=800x480@60
```

### Exercício: Configuração para display industrial

Um display industrial 7" (800x480) com touchscreen capacitivo está conectado via HDMI mas não responde ao toque. O arquivo de configuração atual é:

```ini
[core]
shell=desktop-shell.so
```

**Problemas identificáveis:**
1. Shell inadequado para kiosk
2. Dispositivo de toque não configurado
3. Resolução não especificada

**Solução proposta:**

```ini
[core]
idle-time=0
shell=kiosk-shell.so

[libinput]
touchscreen_calibrator=true
touch_device=/dev/input/event3

[drm]
mode=800x480@60
```

Para verificar a solução:

```bash
weston --config=/etc/xdg/weston/weston-kiosk.ini
```