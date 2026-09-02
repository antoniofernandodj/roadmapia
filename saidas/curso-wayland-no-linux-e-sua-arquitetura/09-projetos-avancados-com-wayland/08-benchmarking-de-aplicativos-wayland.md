## Benchmarking de aplicativos Wayland

Quando você desenvolve um aplicativo gráfico para Wayland, é crucial medir seu desempenho para garantir que ele funcione de maneira eficiente, especialmente em sistemas com recursos limitados ou em cenários onde a latência é crítica. O benchmarking permite identificar gargalos de desempenho, como redesenhos desnecessários, latência de entrada ou consumo excessivo de memória. Este trecho abordará técnicas práticas para medir o desempenho de aplicativos Wayland, utilizando ferramentas e métodos específicos para o protocolo.

### Identificando gargalos de desempenho

Um problema comum em aplicativos Wayland é o excesso de redesenhos, onde a aplicação redesenha a interface mesmo quando não há mudanças visíveis. Isso pode levar a um consumo excessivo de CPU e GPU, especialmente em dispositivos embarcados ou com hardware gráfico limitado. Para identificar esses problemas, você pode usar a ferramenta `WAYLAND_DEBUG`, que registra todas as mensagens trocadas entre o cliente e o compositor.

```bash
WAYLAND_DEBUG=1 ./meu_aplicativo
```

Isso produzirá um log detalhado que inclui informações sobre cada evento de redesenho (`wl_surface_commit`) e outras operações gráficas. Procure por chamadas repetidas de `wl_surface_commit` sem mudanças visíveis, o que indica redesenhos desnecessários.

### Medindo latência de entrada

A latência de entrada é outro fator crítico, especialmente em aplicativos interativos como jogos ou ferramentas de desenho. Para medir a latência entre um evento de entrada (como um clique de mouse) e a resposta visual correspondente, você pode usar a ferramenta `evtest` para monitorar eventos de entrada e comparar o tempo com o momento em que a mudança visual ocorre.

```bash
evtest /dev/input/event2
```

Em outro terminal, execute o aplicativo e observe o tempo dos eventos de entrada. Em seguida, compare com o momento em que a mudança visual aparece na tela. Uma latência superior a 50ms pode indicar problemas de sincronização ou buffers mal gerenciados.

### Monitorando consumo de memória

O consumo de memória é especialmente importante em sistemas embarcados ou com RAM limitada. Para monitorar o uso de memória de um aplicativo Wayland, você pode usar o `valgrind`, que rastreia todas as alocações de memória e identifica vazamentos.

```bash
valgrind --tool=memcheck --leak-check=full ./meu_aplicativo
```

Procure por blocos de memória não liberados (`definitely lost`) ou alocações excessivas (`possibly lost`). Isso pode indicar vazamentos de memória ou buffers que não são liberados corretamente.

### Utilizando `wp_presentation` para sincronização

O protocolo `wp_presentation` permite sincronizar a apresentação de frames com o refresh rate do monitor, reduzindo a latência e evitando rasgos na tela. Para usar esse protocolo, você precisa adicionar suporte a ele no seu aplicativo e medir o tempo entre a criação de um frame e sua exibição na tela.

```c
#include <wayland-client.h>
#include <wayland-presentation-timing-client-protocol.h>

struct wp_presentation *presentation;
struct wp_presentation_feedback *feedback;

void feedback_sync_output(void *data, struct wp_presentation_feedback *feedback, struct wl_output *output) {
    // Frame sincronizado com o monitor
}

void feedback_presented(void *data, struct wp_presentation_feedback *feedback, uint32_t tv_sec_hi, uint32_t tv_sec_lo, uint32_t tv_nsec, uint32_t refresh, uint32_t seq_hi, uint32_t seq_lo, uint32_t flags) {
    // Frame apresentado na tela
}

void main() {
    // Código para inicializar o cliente Wayland e obter a interface wp_presentation
    feedback = wp_presentation_feedback(presentation, surface);
    wp_presentation_feedback_add_listener(feedback, &feedback_listener, NULL);
}
```

Use `feedback_presented` para medir o tempo entre a criação do frame e sua exibição na tela, ajustando o código para minimizar a latência.

### Exercício prático: Benchmarking de um aplicativo simples

Crie um aplicativo Wayland que desenha um círculo vermelho na tela. Use as técnicas discutidas para medir o desempenho do aplicativo, identificando redesenhos desnecessários, latência de entrada e consumo de memória. Compare os resultados com e sem o uso do protocolo `wp_presentation`.

#### Solução comentada

```c
#include <wayland-client.h>
#include <wayland-presentation-timing-client-protocol.h>
#include <stdio.h>

struct wl_display *display;
struct wl_compositor *compositor;
struct wl_surface *surface;
struct wp_presentation *presentation;
struct wp_presentation_feedback *feedback;

void feedback_presented(void *data, struct wp_presentation_feedback *feedback, uint32_t tv_sec_hi, uint32_t tv_sec_lo, uint32_t tv_nsec, uint32_t refresh, uint32_t seq_hi, uint32_t seq_lo, uint32_t flags) {
    printf("Frame apresentado na tela\n");
}

const struct wp_presentation_feedback_listener feedback_listener = {
    .sync_output = NULL,
    .presented = feedback_presented,
};

int main() {
    display = wl_display_connect(NULL);
    compositor = wl_compositor_create(display);
    surface = wl_compositor_create_surface(compositor);
    presentation = wp_presentation_create(display);
    feedback = wp_presentation_feedback(presentation, surface);
    wp_presentation_feedback_add_listener(feedback, &feedback_listener, NULL);

    // Código para desenhar o círculo vermelho na superfície
    wl_surface_commit(surface);

    wl_display_roundtrip(display);
    return 0;
}
```

Este código inicializa um cliente Wayland, cria uma superfície e usa o protocolo `wp_presentation` para sincronizar a apresentação de frames. O callback `feedback_presented` é chamado quando o frame é exibido na tela, permitindo medir a latência.