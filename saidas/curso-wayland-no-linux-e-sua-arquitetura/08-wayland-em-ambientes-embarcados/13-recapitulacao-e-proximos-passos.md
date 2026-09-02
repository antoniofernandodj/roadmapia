## Recapitulação e próximos passos

Nos capítulos anteriores sobre Wayland em sistemas embarcados, implementamos uma solução completa para um display médico com touchscreen resistivo. Veja o arquivo de configuração final que reúne todos os conceitos:

```ini
# weston.ini para sistema médico embarcado
[core]
modules=xwayland.so
idle-time=0
repaint-window=60

[output]
name=DSI-1
mode=1280x800@60
transform=90

[input]
device=ft5x06
calibration_matrix=1.2 0 -0.1 0 1.15 -0.05 0 0 1

[drm]
device=/dev/dri/card1
format=XR24
```

O erro mais comum que você encontrará ao testar essa configuração é:

```
[12:34:56] No DRM-backend devices found
```

A solução requer dois passos:
1. Adicionar seu usuário ao grupo `video`:
```bash
sudo usermod -aG video $USER
```

2. Especificar manualmente o dispositivo DRM correto quando houver múltiplas GPUs:
```ini
[drm]
device=/dev/dri/card1  # Normalmente card0 para GPU primária
```

Para touchscreens resistivos, a calibração é crítica. Execute:
```bash
weston-touch-calibrator /dev/input/event3
```
E insira a matriz resultante na seção `[input]` do `weston.ini`.

### Próximas etapas no estudo de Wayland

1. **Projetos avançados**: Exploraremos como integrar Wayland com sistemas de visão computacional usando OpenCV, incluindo:
   - Compartilhamento de buffers entre processos
   - Syncronização de frames para processamento em tempo real

2. **Futuro do protocolo**: Analisaremos as novas extensões em desenvolvimento:
   - `zwp_virtual_keyboard_v1` para controles virtuais
   - `wp_viewporter` para redimensionamento dinâmico de superfícies

Exercício prático: Modifique a configuração do display médico para:
1. Reduzir a taxa de atualização para 30Hz
2. Implementar timeout após 5 minutos de inatividade
3. Adicionar um segundo touchscreen como dispositivo redundante

Solução comentada:
```ini
[core]
repaint-window=33  # 1000ms/30Hz ≈ 33ms
idle-time=300      # 5 minutos em segundos

[input]
device=ft5x06
device=backup_ts   # Dispositivo secundário
```