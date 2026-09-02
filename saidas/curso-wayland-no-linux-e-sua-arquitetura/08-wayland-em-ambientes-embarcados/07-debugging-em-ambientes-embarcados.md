## Debugging em ambientes embarcados

Em sistemas embarcados com Wayland, um erro de toque não registrado ou uma falha na inicialização do compositor pode paralisar todo o sistema. Diferente de desktops, você não terá um terminal conveniente para depuração. Vamos resolver três cenários reais com as técnicas que funcionam quando `gdb` não está disponível.

### 1. Logs mínimos do Weston em sistemas sem storage persistente

Quando o Weston falha ao iniciar em um dispositivo com filesystem read-only, adicione ao `weston.ini`:

```ini
[core]
log=/dev/ttyprintk
```

Isso redireciona os logs para o buffer do kernel, acessível mesmo sem disco. Para ver a saída:

```bash
dmesg | grep weston
```

Um erro comum aparece assim:
```
[ 12.456] weston 5.0.0
[ 12.457] Failed to load module: '/usr/lib/weston/drm-backend.so'
```

A solução é verificar as permissões do dispositivo DRM:
```bash
chmod 0666 /dev/dri/card0
```

### 2. Depurando eventos de toque não reconhecidos

Crie um listener minimalista em C para verificar se os eventos chegam ao Wayland:

```c
#include <stdio.h>
#include <wayland-client.h>

static void handle_touch(void *data, struct wl_touch *wl_touch,
                        uint32_t time, int32_t id, 
                        wl_fixed_t x, wl_fixed_t y) {
    printf("TOUCH: ID=%d X=%.2f Y=%.2f\n", id,
           wl_fixed_to_double(x), wl_fixed_to_double(y));
}

static const struct wl_touch_listener touch_listener = {
    .down = handle_touch,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_registry *registry = wl_display_get_registry(display);
    // ... (código padrão de binding de interfaces)
    wl_display_roundtrip(display);
    while (1) wl_display_dispatch(display);
}
```

Compile com:
```bash
gcc touch_debug.c -o touch_debug -lwayland-client
```

Se executar e tocar na tela não mostrar saída, o problema está na camada do `libinput` ou no kernel.

### 3. Verificação de alocação de buffers gráficos

Em sistemas com menos de 512MB de RAM, erros de alocação são frequentes. Use este comando para monitorar:

```bash
watch -n 1 "cat /proc/meminfo | grep -E 'MemFree|Buffers|Cached'"
```

Durante um teste de renderização, você deve ver a memória livre diminuir e depois ser recuperada. Se não recuperar, há vazamento. Insira este log no seu cliente Wayland:

```c
void buffer_release(void *data, struct wl_buffer *wl_buffer) {
    printf("Buffer released at %p\n", wl_buffer);
}

static const struct wl_buffer_listener buffer_listener = {
    .release = buffer_release,
};
```

Se `buffer_release` nunca for chamado, seu aplicativo está mantendo buffers desnecessariamente.

### Erro comum e solução: Touchscreen calibrado mas respondendo fora de posição

Sintoma: Toques registram 30% mais à direita do que o dedo. Cause: Matriz de transformação não aplicada. Corrija no `weston.ini`:

```ini
[libinput]
touchscreen_calibator=matrix -0.5 0 1.5 0 -1.0 2.0 0 0 1
```

Os valores são uma matriz 3x3 de transformação afim. Um debug rápido pode ser feito com:

```bash
weston-touch-calibrator
```

### Exercício: Diagnóstico de toque fantasma

Um dispositivo reporta toques aleatórios quando aquecido. Crie um script que:
1. Logue coordenadas a cada toque
2. Detecte toques consecutivos em posições impossíveis (>500px em 10ms)
3. Desabilite o driver de toque via sysfs se detectar padrão

Solução:

```bash
#!/bin/bash
DEVICE="/dev/input/event2"

stdbuf -oL libinput debug-events --device $DEVICE | while read -r line; do
    if [[ $line =~ ABS_MT_POSITION_X=([0-9]+).*ABS_MT_POSITION_Y=([0-9]+) ]]; then
        x=${BASH_REMATCH[1]}
        y=${BASH_REMATCH[2]}
        now=$(date +%s%3N)
        echo "$now,$x,$y" >> touch_log.csv
        
        if [[ -n $last_time ]]; then
            dist=$(( (x-last_x)**2 + (y-last_y)**2 ))
            if [[ $((now-last_time)) -lt 10 && $dist -gt 250000 ]]; then
                echo 0 > /sys/bus/i2c/drivers/goodix_ts/disable
                break
            fi
        fi
        last_time=$now
        last_x=$x
        last_y=$y
    fi
done
```