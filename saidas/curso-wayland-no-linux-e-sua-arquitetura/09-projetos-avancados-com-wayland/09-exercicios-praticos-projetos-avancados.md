## Exercícios práticos: projetos avançados

Um cliente Wayland que apenas exibe um retângulo vermelho é trivial - até que você tente sincronizá-lo com o refresh rate do monitor e descubre que 60Hz não são 60 atualizações perfeitas por segundo. Vamos implementar um relógio analógico com três ponteiros que exige precisão de milissegundos, revelando os desafios reais da sincronização gráfica:

```c
#include <wayland-client.h>
#include <wayland-client-protocol.h>
#include <wp-presentation-timing-client-protocol.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

struct clock_state {
    struct wl_surface *surface;
    struct wp_presentation *presentation;
    uint32_t refresh_nsec;
    int width, height;
};

void draw_clock(struct clock_state *state) {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    uint64_t millis = (now.tv_sec * 1000) + (now.tv_nsec / 1000000);
    
    // Cálculo dos ângulos dos ponteiros
    double seconds_angle = (millis / 1000.0) * (2 * M_PI / 60);
    double minutes_angle = (millis / 60000.0) * (2 * M_PI / 60);
    double hours_angle = (millis / 3600000.0) * (2 * M_PI / 12);

    // Renderização (implementação gráfica omitida por brevidade)
    printf("Renderizando: Segundos=%.2f rad, Minutos=%.2f rad, Horas=%.2f rad\n",
           seconds_angle, minutes_angle, hours_angle);
}

static void presentation_feedback_sync_output(void *data,
    struct wp_presentation_feedback *feedback,
    struct wl_output *output) {
    printf("Sincronizado com output\n");
}

static void presentation_feedback_presented(void *data,
    struct wp_presentation_feedback *feedback,
    uint32_t tv_sec_hi, uint32_t tv_sec_lo,
    uint32_t tv_nsec, uint32_t refresh_nsec,
    uint32_t seq_hi, uint32_t seq_lo,
    uint32_t flags) {
    struct clock_state *state = data;
    state->refresh_nsec = refresh_nsec;
    printf("Apresentado em %u ns (refresh=%u ns)\n", tv_nsec, refresh_nsec);
    
    // Agenda o próximo frame
    draw_clock(state);
    struct wp_presentation_feedback *next_feedback = 
        wp_presentation_feedback(state->presentation, state->surface);
    wp_presentation_feedback_add_listener(next_feedback, &feedback_listener, state);
}

static const struct wp_presentation_feedback_listener feedback_listener = {
    .sync_output = presentation_feedback_sync_output,
    .presented = presentation_feedback_presented,
};

int main() {
    struct clock_state state = {0};
    state.width = 400; state.height = 400;
    
    // Setup Wayland (omitido por brevidade)
    // ...
    
    // Primeiro frame
    draw_clock(&state);
    struct wp_presentation_feedback *feedback = 
        wp_presentation_feedback(state.presentation, state.surface);
    wp_presentation_feedback_add_listener(feedback, &feedback_listener, &state);
    
    while (1) {
        wl_display_dispatch(state.display);
    }
}
```

Saída esperada (os valores exatos variam):
```
Renderizando: Segundos=0.00 rad, Minutos=0.00 rad, Horas=0.00 rad
Sincronizado com output
Apresentado em 123456789 ns (refresh=16666666 ns)
Renderizando: Segundos=0.10 rad, Minutos=0.00 rad, Horas=0.00 rad
```

O erro clássico aqui é esquecer de guardar o `refresh_nsec` - sem ele, você tenta adivinhar o intervalo de refresh e acumula desvios de sincronização. Após 60 segundos, o ponteiro de segundos estará claramente atrasado ou adiantado.

**Exercício:** Modifique o relógio para exibir também milissegundos, criando um quarto ponteiro que completa uma volta a cada segundo. Você notará que mesmo com `wp_presentation`, a atualização dos milissegundos não será perfeitamente suave - por quê?

**Solução comentada:**
```c
// Adicione ao cálculo dos ângulos:
double millis_angle = (millis % 1000) * (2 * M_PI / 1000);

// A não-suavidade ocorre porque:
// 1. O tempo entre frames não é constante (variações de ~1ms)
// 2. O pipeline gráfico tem latência fixa de 2-3 frames
// 3. O compositor pode atrasar frames sob carga
```

Para projetos que exigem controle absoluto sobre o timing, considere:
1. Usar `wl_surface_commit` com `wl_surface_frame` para controle manual
2. Implementar um mecanismo de "catch-up" que acelera/diminui a animação
3. Para casos críticos, usar EGL e sincronização vertical direta (se disponível)

Outro cenário comum é desenvolver um visualizador de imagens com zoom suave. O desafio aparece quando você implementa o redimensionamento dinâmico:

```c
void on_configure(void *data, struct xdg_toplevel *toplevel,
                  int32_t width, int32_t height, struct wl_array *states) {
    struct viewer_state *state = data;
    if (width == 0 || height == 0) return;
    
    state->width = width;
    state->height = height;
    
    // Algoritmo ingênuo - realoca buffer a cada redimensionamento
    state->buffer = create_buffer(state->shm, width, height);
    
    // Melhor abordagem: manter buffer maior que a superfície
    // e só realocar quando necessário:
    if (width > state->buffer_width || height > state->buffer_height) {
        state->buffer_width = MAX(width, state->buffer_width);
        state->buffer_height = MAX(height, state->buffer_height);
        state->buffer = create_buffer(state->shm, state->buffer_width, state->buffer_height);
    }
    
    render_image(state); // Redesenha a imagem com novo zoom
}
```

A mensagem de erro típica quando isso falha é:
```
warning: queueing to wl_display failed: No space left on device
```
Isso ocorre quando você envia muitos comandos de resize em sequência rápida. A solução é implementar debouncing - só processar o último evento de resize em uma série rápida.