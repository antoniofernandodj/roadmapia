## Casos de uso em embarcados

Em sistemas embarcados, o Wayland substitui soluções gráficas pesadas como o X11, especialmente em dispositivos com restrições severas de recursos. Vejamos três cenários reais onde o Wayland brilha:

**1. Terminais de Autoatendimento (Kiosks)**
Um terminal de aeroporto rodando Weston consome 80% menos memória que uma solução X11 equivalente. O arquivo `weston.ini` típico inclui:

```ini
[core]
modules=xwayland.so
shell=kiosk-shell.so

[shell]
locking=false
background-color=0x00000000

[drm]
device=/dev/dri/card0
mode=1920x1080@60
```

Problema comum: o touchscreen não responde após inicialização. O log mostra:
```
libinput error: event1 - ELAN Touchscreen: kernel bug: Touch jump detected and discarded
```

Solução: adicionar regras de filtro no `weston.ini`:
```ini
[libinput]
touchscreen_calibration=1.02 -0.05 -0.12 1.1
```

**2. Displays Automotivos**
Um painel de navegação veicular exige baixa latência e suporte a múltiplas taxas de atualização. Esta configuração no Weston otimiza para GPUs Mali:

```ini
[drm]
format=XR24
seat=seat0
renderer=gl
```

Quando mal configurado, o erro aparece no `weston.log`:
```
failed to create renderer: No EGLDisplay found for this GPU
```

A correção envolve forçar o backend EGL:
```bash
export WESTON_DRM_PRIMARY=1
weston --backend=drm-backend.so --renderer=gl
```

**3. Equipamentos Industriais**
Em uma linha de produção, um display resistivo precisa de calibração precisa. O comando abaixo gera a matriz de transformação:

```bash
weston-touch-calibrator /dev/input/event5
```

Saída esperada:
```
Calibration matrix: 1.75 -0.15 0.12 1.82
```

Para implementar gestos personalizados (como toque duplo para emergência), use este trecho em C:

```c
struct libinput_event_touch *tev = libinput_event_get_touch_event(event);
if (libinput_event_touch_get_seat_slot(tev) == 0) {
    if (libinput_event_touch_get_time(tev) - last_touch < 300) {
        system("shutdown -h now");
    }
    last_touch = libinput_event_touch_get_time(tev);
}
```

**Erro crítico em embarcados**: GPUs integradas frequentemente falham com:
```
drmModeGetConnector failed: No such file or directory
```

A solução requer especificar o connector HDMI explicitamente:
```ini
[drm]
connector=HDMI-A-1
```

**Exercício**: Configure um kiosk médico com estas especificações:
- Touchscreen 10" (800x480)
- Sem teclado/mouse
- Tempo de inatividade: 2 minutos para tela de bloqueio
- Fundo verde (#00FF00)

*Solução*:
```ini
[core]
idle-time=120
shell=kiosk-shell.so

[shell]
background-color=0x00FF00FF
locking=true

[drm]
mode=800x480
connector=DSI-1

[libinput]
touchscreen_calibration=1.0 0.0 0.0 1.0
```