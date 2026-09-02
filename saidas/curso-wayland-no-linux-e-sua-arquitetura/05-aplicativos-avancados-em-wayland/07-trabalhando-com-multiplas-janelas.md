## Trabalhando com múltiplas janelas

Quando precisamos exibir conteúdo complexo em um aplicativo Wayland - como um editor com documentos abertos lado a lado ou um navegador com abas em janelas separadas - surge o desafio de gerenciar múltiplas superfícies de forma eficiente. Vejamos como criar e controlar várias janelas independentes.

### Criando janelas adicionais

Cada nova janela no Wayland é uma instância separada de `wl_surface`. Vamos estender nosso aplicativo básico para criar duas janelas:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct wl_shell *shell = NULL;

void create_window(int x, int y, int width, int height, const char *title) {
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    struct wl_shell_surface *shell_surface = wl_shell_get_shell_surface(shell, surface);
    
    wl_shell_surface_set_title(shell_surface, title);
    wl_shell_surface_set_toplevel(shell_surface);
    
    struct wl_region *region = wl_compositor_create_region(compositor);
    wl_region_add(region, 0, 0, width, height);
    wl_surface_set_opaque_region(surface, region);
    wl_region_destroy(region);
    
    wl_surface_commit(surface);
}

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao servidor Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !shell) {
        fprintf(stderr, "Compositor ou Shell não disponíveis\n");
        return 1;
    }

    // Cria duas janelas
    create_window(100, 100, 400, 300, "Janela Principal");
    create_window(550, 100, 400, 300, "Janela Secundária");

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }

    wl_display_disconnect(display);
    return 0;
}
```

O erro mais comum aqui é esquecer de chamar `wl_surface_commit()` após configurar cada superfície. Sem isso, a janela não será exibida, sem qualquer mensagem de erro explícita.

### Gerenciando o ciclo de vida das janelas

Wayland trata cada superfície como um objeto independente. Para fechar janelas seletivamente, precisamos manter referências:

```c
struct window {
    struct wl_surface *surface;
    struct wl_shell_surface *shell_surface;
    // Outros recursos da janela...
};

struct window windows[2];

void destroy_window(struct window *win) {
    if (win->shell_surface) {
        wl_shell_surface_destroy(win->shell_surface);
    }
    if (win->surface) {
        wl_surface_destroy(win->surface);
    }
}

int main() {
    // ... inicialização anterior ...

    // Criar janelas com estrutura de controle
    windows[0].surface = wl_compositor_create_surface(compositor);
    windows[0].shell_surface = wl_shell_get_shell_surface(shell, windows[0].surface);
    // Configurar primeira janela...

    windows[1].surface = wl_compositor_create_surface(compositor);
    windows[1].shell_surface = wl_shell_get_shell_surface(shell, windows[1].surface);
    // Configurar segunda janela...

    // Fechar apenas a segunda janela após 5 segundos
    sleep(5);
    destroy_window(&windows[1]);

    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }
}
```

### Sincronização entre janelas

Para coordenar atualizações entre múltiplas janelas, utilizamos callbacks de frame:

```c
void redraw_window(struct window *win, uint32_t color) {
    struct wl_callback *callback = wl_surface_frame(win->surface);
    wl_callback_add_listener(callback, &frame_listener, win);
    
    struct wl_buffer *buffer = create_buffer(color, win->width, win->height);
    wl_surface_attach(win->surface, buffer, 0, 0);
    wl_surface_damage(win->surface, 0, 0, win->width, win->height);
    wl_surface_commit(win->surface);
}

static void frame_handle_done(void *data, struct wl_callback *callback, uint32_t time) {
    struct window *win = data;
    wl_callback_destroy(callback);
    
    // Atualiza a próxima janela na sequência
    if (win == &windows[0]) {
        redraw_window(&windows[1], 0xFF3333FF); // Vermelho
    } else {
        redraw_window(&windows[0], 0x33FF33FF); // Verde
    }
}
```

Este padrão alterna as atualizações entre as janelas, garantindo que o servidor compositor não seja sobrecarregado com atualizações simultâneas.

### Exercício: Gerenciador de Janelas Básico

Implemente um aplicativo que cria três janelas coloridas (vermelho, verde, azul) e:
1. Fecha a janela vermelha após 3 segundos
2. Move a janela verde para a posição (200,200) após 5 segundos
3. Alterna a cor da janela azul entre azul e amarelo a cada 2 segundos

Solução comentada:

```c
// [Código de inicialização igual ao exemplo anterior...]

struct window {
    struct wl_surface *surface;
    struct wl_shell_surface *shell_surface;
    int x, y, width, height;
    uint32_t color;
    struct wl_buffer *buffer;
};

struct window windows[3];
struct timespec start_time;

void update_window(struct window *win) {
    // Libera o buffer antigo se existir
    if (win->buffer) {
        wl_buffer_destroy(win->buffer);
    }
    
    // Cria novo buffer com a cor atual
    win->buffer = create_buffer(win->color, win->width, win->height);
    
    // Configura superfície
    wl_surface_attach(win->surface, win->buffer, 0, 0);
    wl_surface_damage(win->surface, 0, 0, win->width, win->height);
    wl_surface_commit(win->surface);
}

void check_timers() {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    double elapsed = (now.tv_sec - start_time.tv_sec) + 
                    (now.tv_nsec - start_time.tv_nsec) / 1e9;

    if (elapsed >= 3.0 && windows[0].surface) {
        destroy_window(&windows[0]); // Fecha vermelha
    }
    
    if (elapsed >= 5.0 && windows[1].surface) {
        windows[1].x = 200; // Move verde
        windows[1].y = 200;
        wl_shell_surface_set_position(windows[1].shell_surface, 200, 200);
    }
    
    // Alterna azul/amarelo a cada 2s
    if ((int)(elapsed / 2.0) % 2 == 1) {
        windows[2].color = 0xFFFF00FF; // Amarelo
    } else {
        windows[2].color = 0x0000FFFF; // Azul
    }
    update_window(&windows[2]);
}

int main() {
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    
    // Inicializa janelas
    windows[0] = { .color = 0xFF0000FF, .x = 100, .y = 100, .width = 200, .height = 200 };
    windows[1] = { .color = 0x00FF00FF, .x = 350, .y = 100, .width = 200, .height = 200 };
    windows[2] = { .color = 0x0000FFFF, .x = 200, .y = 350, .width = 200, .height = 200 };
    
    // [Restante da implementação...]
    
    while (wl_display_dispatch(display) != -1) {
        check_timers();
    }
}
```