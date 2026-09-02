## Exercícios práticos: embarcados

Neste trecho, vamos praticar a configuração e otimização do Wayland em sistemas embarcados. O foco será em resolver problemas comuns e ajustar o ambiente para funcionar com eficiência em hardware limitado.

### Configuração básica do Weston para sistemas embarcados

Vamos começar configurando o Weston para rodar em um sistema embarcado com GPU Mali e touchscreen resistivo. Primeiro, crie um arquivo `weston.ini` com o seguinte conteúdo:

```ini
[core]
backend=drm-backend.so
shell=kiosk-shell.so

[drm]
device=/dev/dri/card0
mode=1920x1080@60

[input]
name=Goodix Touchscreen
device=/dev/input/event1
```

Execute o Weston com o comando:

```bash
weston --config=weston.ini
```

Se tudo estiver configurado corretamente, o Weston deve iniciar e exibir uma tela preta. Caso ocorra um erro de permissão, adicione o usuário ao grupo `video`:

```bash
sudo usermod -aG video $USER
```

### Calibração de touchscreen

Para calibrar o touchscreen, utilize o `weston-touch-calibrator`. Execute o seguinte comando:

```bash
weston-touch-calibrator /dev/input/event1
```

Siga as instruções na tela para calibrar o touchscreen. Após a calibração, o arquivo `weston.ini` será atualizado com a matriz de transformação correta.

### Detecção de toque duplo

Vamos implementar a detecção de toque duplo usando `libinput`. Primeiro, instale o `libinput`:

```bash
sudo apt-get install libinput-tools
```

Crie um script Python para detectar toques duplos:

```python
#!/usr/bin/env python3

import libinput
import time

def handle_event(event):
    if event.type == libinput.EventType.TOUCH_DOUBLE_TAP:
        print("Toque duplo detectado")

li = libinput.LibInput(udev=True)
li.path_add_device('/dev/input/event1')

while True:
    for event in li.get_event():
        handle_event(event)
    time.sleep(0.1)
```

Execute o script e teste o toque duplo no touchscreen. Se tudo estiver funcionando corretamente, o script deve imprimir "Toque duplo detectado" quando você realizar um toque duplo.

### Otimização de buffers gráficos

Para otimizar o consumo de memória, ajuste os buffers gráficos no `weston.ini`. Adicione a seguinte seção ao arquivo:

```ini
[output]
name=HDMI-A-1
transform=normal
mode=1920x1080@60
buffer-count=2
```

Reduzir o número de buffers pode economizar memória, mas pode aumentar a latência. Teste diferentes valores para encontrar o equilíbrio ideal para o seu sistema.

### Exercício: Configuração para kiosk com touchscreen

Configure o Weston para um cenário de kiosk com touchscreen. O kiosk deve exibir uma única aplicação em tela cheia e responder apenas ao touchscreen. Adicione as seguintes configurações ao `weston.ini`:

```ini
[core]
backend=drm-backend.so
shell=kiosk-shell.so

[drm]
device=/dev/dri/card0
mode=1920x1080@60

[input]
name=Goodix Touchscreen
device=/dev/input/event1

[kiosk]
app=/usr/bin/my-kiosk-app
```

Substitua `/usr/bin/my-kiosk-app` pelo caminho do seu aplicativo kiosk. Execute o Weston e verifique se o aplicativo é exibido corretamente e responde ao touchscreen.

### Solução de problemas comuns

Se o touchscreen não estiver sendo detectado, verifique se o dispositivo está correto no `weston.ini`. Use o comando `libinput list-devices` para listar os dispositivos de entrada disponíveis.

Se o Weston não iniciar devido a problemas de permissão, certifique-se de que o usuário está no grupo `video`. Use o comando `groups` para verificar.

Se o sistema apresentar problemas com múltiplas GPUs, especifique manualmente a GPU no `weston.ini`:

```ini
[drm]
device=/dev/dri/card1
mode=1920x1080@60
```

Substitua `card1` pelo dispositivo correto da GPU.