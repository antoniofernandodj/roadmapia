## Introdução a Wayland em embarcados

Em sistemas embarcados, onde recursos como memória e poder de processamento são escassos, o Wayland surge como uma alternativa eficiente ao X11. A arquitetura minimalista do Wayland, com menos camadas de abstração, resulta em menor consumo de recursos e melhor desempenho em hardware limitado.

**Por que Wayland em embarcados?**  
Considere um sistema com apenas 512MB de RAM rodando um painel de controle industrial. Com X11, você enfrentaria:

1. O servidor X tradicional consome ~80MB só para operações básicas
2. A pilha de protocolos adicionais (XRender, XComposite) aumenta a complexidade
3. O modelo de segurança permissivo exige trabalho extra para isolamento

O mesmo sistema com Wayland:

```sh
# Monitorando o consumo de um compositor Wayland básico (weston)
$ ps -o pid,rss,cmd -C weston
  PID   RSS CMD
 1234 24320 /usr/bin/weston --backend=drm-backend.so
```

Saída típica: ~24MB de RAM para o compositor completo.

**Adaptando para restrições embarcadas**

O principal desafio é a ausência de dispositivos de ponteiro/tela convencionais. Veja como criar uma aplicação básica que responde a eventos de touchscreen:

```c
#include <wayland-client.h>
#include <stdio.h>

struct touch_listener {
    void (*down)(void *data, int32_t id, int32_t x, int32_t y);
    // ... outros callbacks
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha na conexão: %m\n");
        return 1;
    }

    // Implementação simplificada de listener
    struct touch_listener listener = {
        .down = [](void *data, int32_t id, int32_t x, int32_t y) {
            printf("Toque em %d,%d (ID %d)\n", x, y, id);
        }
    };

    // Loop principal simplificado
    while (wl_display_dispatch(display) != -1) {
        // Processa eventos
    }

    wl_display_disconnect(display);
    return 0;
}
```

**Erro comum e correção**

Um erro frequente é esquecer de configurar o backend correto para o hardware específico. Se você receber:

```
weston: backend 'drm-backend' falhou: No DRM device found
```

A solução é especificar o dispositivo DRM explicitamente (em sistemas com múltiplas GPUs):

```sh
$ WESTON_DRM_DEVICE=/dev/dri/card1 weston --backend=drm-backend.so
```

**Caso real: display sem mouse**

Em um terminal de autoatendimento com touchscreen, você pode desativar completamente o cursor:

```ini
# weston.ini para sistemas apenas com touch
[shell]
locking=false
cursor-theme=empty
```

**Exercício: touchscreen básica**

Crie um programa que:
1. Conecta ao display Wayland
2. Detecta eventos de toque
3. Exibe as coordenadas no console quando ocorre um toque duplo

*Solução comentada:*

```c
// Adicione ao listener original:
.down = [](void *data, int32_t id, int32_t x, int32_t y) {
    static int32_t last_x = -1, last_y = -1;
    static uint64_t last_time = 0;
    
    uint64_t now = get_current_time(); // Função hipotética
    
    if (last_x == x && last_y == y && (now - last_time) < 300) {
        printf("Toque duplo em %d,%d\n", x, y);
    }
    
    last_x = x;
    last_y = y;
    last_time = now;
}
```