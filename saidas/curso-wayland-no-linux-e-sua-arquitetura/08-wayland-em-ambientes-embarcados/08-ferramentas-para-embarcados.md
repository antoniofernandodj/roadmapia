## Ferramentas para embarcados

Em sistemas embarcados com recursos limitados, escolher as ferramentas certas para trabalhar com Wayland é crucial. O problema típico surge quando tentamos usar soluções desktop em hardware com 512MB de RAM e CPU quad-core a 1GHz - o sistema simplesmente não responde ou consome toda a memória disponível.

### Weston: o compositor embarcado

Weston é o compositor de referência para sistemas embarcados. Sua principal vantagem é a modularidade - podemos desativar recursos desnecessários. Um erro comum é tentar usar a configuração padrão:

```ini
# weston.ini problemático para embarcados
[core]
modules=xwayland.so,desktop-shell.so
```

Isso causa o erro `Failed to load module: xwayland.so (cannot open shared object file)` em sistemas sem X11 e consome recursos desnecessários. A versão correta para embarcados seria:

```ini
# weston.ini otimizado para embarcados
[core]
modules=desktop-shell.so
shell=fullscreen-shell.so
```

A diferença no consumo de memória é significativa:
- Configuração padrão: ~120MB RAM
- Configuração otimizada: ~35MB RAM

### Backend DRM: controle direto do hardware

Para sistemas com GPU integrada, o backend DRM (Direct Rendering Manager) é essencial. Um erro frequente ocorre ao tentar inicializá-lo sem permissões:

```
(drm-backend.c:1234) failed to open DRM device '/dev/dri/card0': Permission denied
```

A solução envolve dois passos:
1. Adicionar o usuário ao grupo `video`:
   ```bash
   sudo usermod -a -G video $USER
   ```
2. Configurar corretamente o weston.ini:
   ```ini
   [core]
   backend=drm-backend.so
   ```

### Libinput: gerenciamento de dispositivos de entrada

Para touchscreens em embarcados, libinput é a ferramenta padrão. Um problema comum é a calibração incorreta, que faz os toques aparecerem em posições erradas. Veja como configurar manualmente:

```bash
# Listar dispositivos de entrada
libinput list-devices

# Calibrar touchscreen (exemplo para dispositivo 10)
weston-touch-calibrator /dev/input/event10
```

Isso gera uma matriz de transformação que deve ser adicionada ao weston.ini:
```ini
[libinput]
touchscreen_calibrator=0.123 -0.456 1.789 0.321 1.654 -0.987
```

### Otimização de buffers gráficos

Em sistemas com pouca RAM, configurar corretamente os buffers de framebuffer é essencial. A configuração padrão pode causar `EGL_BAD_ALLOC` quando a memória se esgota. Ajuste no weston.ini:

```ini
[output]
mode=800x480@60
transform=90

[renderer]
max_buffer_age=1
```

### weston-info: depuração de configuração

Para verificar se todas as configurações foram aplicadas corretamente, execute:

```bash
weston-info
```

Isso mostrará informações cruciais como:
- Backend em uso
- Resolução efetiva
- Formatos de pixel suportados
- Recursos EGL disponíveis

### Exercício prático

Configure um ambiente Wayland mínimo para um sistema com:
- Tela de 480x272 pixels
- Touchscreen no /dev/input/event2
- GPU Mali-400MP2
- 256MB de RAM total

Solução comentada:

```ini
# weston-embedded.ini
[core]
backend=drm-backend.so
shell=fullscreen-shell.so
modules=desktop-shell.so

[libinput]
touchscreen_calibrator=1.0 0.0 0.0 0.0 1.0 0.0

[output]
mode=480x272@60

[drm]
device=/dev/dri/card0
```