## Problemas comuns em embarcados

Em sistemas embarcados, a implementação do Wayland frequentemente esbarra em limitações específicas de hardware que não existem em desktops convencionais. Vamos explorar os problemas mais recorrentes com exemplos reais e mensagens de erro típicas.

### 1. Falha na inicialização do backend DRM

O erro mais comum ocorre quando o Weston não consegue acessar o dispositivo gráfico:

```bash
weston-launch: Failed to open DRM device '/dev/dri/card0': Permission denied
```

Isso acontece porque:
- O usuário não está no grupo `video`
- O dispositivo `/dev/dri/card0` não existe (caso de drivers não instalados)
- Permissões incorretas no dispositivo (modo 660 em vez de 666)

Um caso real em sistemas com GPU Mali:
```bash
[07:42:31.543] failed to initialize kms output
[07:42:31.543] failed to create display
```

### 2. Touchscreen não reconhecido

Quando o touchscreen não funciona, o Weston mostra:
```bash
[08:15:22.876] No touch devices found
```

Causas típicas:
- Dispositivo não listado em `/proc/bus/input/devices`
- Problema no driver do controlador touch (frequentemente em chipsets I2C)
- Necessidade de especificação manual no `weston.ini`:
```ini
[libinput]
touchscreen_calibrator=/dev/input/event2
```

### 3. Consumo excessivo de memória

Sistemas com 512MB RAM frequentemente travam porque:
- Buffers padrão do Weston são grandes demais
- Efeitos de composição não desativados
- Aplicativos alocam buffers sem considerar limitações

Sintoma no `dmesg`:
```
[ 987.654321] Out of memory: Kill process 1234 (weston) score 789
```

### 4. Problemas de calibração de touchscreen

Touchscreens resistivos frequentemente requerem:
- Matriz de transformação personalizada
- Ajuste de eixos invertidos
- Calibração manual via `weston-touch-calibrator`

Erro típico:
```
Calibration failed: could not read calibration points
```

### 5. Taxa de atualização inadequada

Displays industriais muitas vezes:
- Não suportam 60Hz padrão
- Requerem configuração explícita no kernel:
```bash
echo 30 > /sys/class/graphics/fb0/mode
```

Efeito visível: tearing ou flickering acentuado

### 6. Problemas com múltiplos displays

Em sistemas com display principal e secundário:
```bash
[09:12:45.123] Failed to create output for connector 42
```

Causas:
- Timing incorreto nos EDIDs
- Falta de suporte a clone mode
- Configuração manual necessária no `weston.ini`:
```ini
[output]
name=HDMI-A-1
mode=1024x768
```

### 7. Tópicos de depuração

Quando as ferramentas convencionais não estão disponíveis:
- Redirecionar logs para console serial:
```bash
weston --log=/dev/ttyS0
```
- Verificar eventos de input brutos:
```bash
evtest /dev/input/event2
```

Cada um desses problemas tem soluções específicas, que serão abordadas no próximo capítulo. O importante agora é reconhecê-los pelos sintomas e mensagens de erro características.