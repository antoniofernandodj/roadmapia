## Eventos e callbacks em Wayland

Em um sistema gráfico tradicional, os aplicativos precisam constantemente verificar se ocorreram eventos como movimentos de mouse ou pressionamentos de tecla. No X11, isso envolve polling ativo ou mecanismos complexos de seleção. O Wayland inverte esta lógica: o compositor notifica os clientes quando algo relevante acontece, através de callbacks.

Considere uma janela simples que precisa reagir a cliques do mouse. Em X11, o código ficaria assim:

```c
// Exemplo X11 (só para comparação)
while (1) {
    XEvent event;
    XNextEvent(display, &event);
    if (event.type == ButtonPress) {
        printf("Botão pressionado em (%d, %d)\n", 
               event.xbutton.x, event.xbutton.y);
    }
}
```

No Wayland, ao invés de perguntar "alguém clicou?", você registra um callback que será chamado quando o clique ocorrer:

```c
// Exemplo Wayland
#include <wayland-client.h>

static void pointer_button(void *data, 
                          struct wl_pointer *wl_pointer,
                          uint32_t serial,
                          uint32_t time,
                          uint32_t button,
                          uint32_t state) {
    if (state == WL_POINTER_BUTTON_STATE_PRESSED) {
        printf("Botão %d pressionado no tempo %u\n", button, time);
    }
}

static const struct wl_pointer_listener pointer_listener = {
    .button = pointer_button,
};

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    // ... [setup inicial omitido para foco nos eventos]
    wl_display_roundtrip(display); // Espera eventos iniciais
    while (wl_display_dispatch(display) != -1) {
        // Loop principal: processa eventos recebidos
    }
    wl_display_disconnect(display);
    return 0;
}
```

Quando você executa este código em um ambiente Wayland (como GNOME Shell ou Weston), a saída será algo como:

```
Botão 272 pressionado no tempo 15248736
```

O que acontece nos bastidores:
1. O cliente registra o `pointer_listener` durante a inicialização
2. Quando o usuário clica, o compositor serializa o evento e envia via socket Unix
3. O cliente desserializa e chama seu callback `pointer_button`
4. A função imprime os detalhes e retorna ao loop principal

Um erro comum é esquecer de implementar todos os callbacks obrigatórios de uma interface. Por exemplo, se você usar `wl_pointer` sem definir o listener completo:

```c
// Listener incompleto - causará erro
static const struct wl_pointer_listener bad_listener = {
    .button = pointer_button,
    // Faltam: .enter, .leave, .motion, etc.
};
```

O compositor encerrará a conexão com este erro no terminal:

```
wayland-client error: missing listener for wl_pointer.enter
```

Para corrigir, implemente todos os callbacks necessários, mesmo que vazios:

```c
static void pointer_enter(void *data, struct wl_pointer *wl_pointer,
                         uint32_t serial, struct wl_surface *surface,
                         wl_fixed_t x, wl_fixed_t y) {
    // Callback vazio mas obrigatório
}

static const struct wl_pointer_listener full_listener = {
    .enter = pointer_enter,
    .leave = pointer_leave, // similar ao enter
    .motion = pointer_motion,
    .button = pointer_button,
    // ... outros conforme a versão do protocolo
};
```

**Exercício**: Modifique o exemplo inicial para também capturar movimentos do mouse, exibindo as coordenadas em tempo real. Inclua tratamento para quando o ponteiro sai da janela.

**Solução**:

```c
#include <stdio.h>
#include <wayland-client.h>

static void pointer_motion(void *data, struct wl_pointer *wl_pointer,
                          uint32_t time, wl_fixed_t x, wl_fixed_t y) {
    printf("Movimento para (%f, %f)\n",
           wl_fixed_to_double(x), wl_fixed_to_double(y));
}

static void pointer_leave(void *data, struct wl_pointer *wl_pointer,
                         uint32_t serial, struct wl_surface *surface) {
    printf("Ponteiro saiu da janela\n");
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter, // implementação vazia como no exemplo anterior
    .leave = pointer_leave,
    .motion = pointer_motion,
    .button = pointer_button,
};

// Restante do código igual ao exemplo inicial
```

Quando executado, este código produzirá saídas como:

```
Movimento para (125.500000, 80.250000)
Movimento para (126.000000, 80.000000)
Botão 272 pressionado no tempo 15248736
Ponteiro saiu da janela
```