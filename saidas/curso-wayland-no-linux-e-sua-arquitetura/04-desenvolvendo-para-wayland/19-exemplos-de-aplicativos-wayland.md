## Exemplos de aplicativos Wayland

Um cliente Wayland mínimo que exibe uma janela vermelha demonstra os conceitos fundamentais na prática. Este exemplo usa diretamente a API C do Wayland, sem toolkits como GTK ou Qt:

```c
#include <wayland-client.h>
#include <wayland-client-protocol.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct wl_surface *surface = NULL;
struct wl_shell_surface *shell_surface = NULL;
struct wl_shm *shm = NULL;

void create_window() {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland\n");
        exit(1);
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);
    
    surface = wl_compositor_create_surface(compositor);
    shell_surface = wl_shell_get_shell_surface(shell, surface);
    wl_shell_surface_set_toplevel(shell_surface);
}

void create_buffer(int width, int height) {
    int stride = width * 4;
    int size = stride * height;
    
    int fd = memfd_create("buffer", MFD_CLOEXEC);
    ftruncate(fd, size);
    
    uint32_t *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    memset(data, 0xff0000ff, size); // Preenche com vermelho ARGB
    
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 
        width, height, stride, WL_SHM_FORMAT_ARGB8888);
    
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);
    
    wl_shm_pool_destroy(pool);
    close(fd);
    munmap(data, size);
}

int main() {
    create_window();
    create_buffer(400, 300);
    
    while (wl_display_dispatch(display) != -1) {
        // Loop principal
    }
    
    wl_shell_surface_destroy(shell_surface);
    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

Saída esperada: Uma janela vermelha 400x300 pixels aparece na tela. O código:

1. Estabelece conexão com o compositor Wayland padrão
2. Obtém interfaces necessárias (compositor, shell)
3. Cria uma superfície e a promove para janela toplevel
4. Aloca e preenche um buffer de pixels compartilhado
5. Associa o buffer à superfície e envia para exibição

Um erro comum é esquecer de chamar `wl_surface_commit()`, resultando em uma janela preta. A mensagem de erro não é explícita - o compositor simplesmente não exibe nada.

Para compilar e executar:
```bash
gcc -o wayland-example wayland-example.c -lwayland-client
./wayland-example
```

Aplicativos reais como o Weston Terminal usam os mesmos princípios, mas com otimizações adicionais. Vejamos como ele difere:

1. **Double Buffering**: Alterna entre dois buffers para atualizações suaves
2. **Input Handling**: Registra listeners para teclado/mouse
3. **Text Rendering**: Usa bibliotecas como Pango para renderização de texto
4. **Resize Handling**: Implementa lógica para redimensionamento dinâmico

Um exemplo mínimo com entrada de teclado adicionaria:

```c
struct wl_seat *seat = NULL;
struct wl_keyboard *keyboard = NULL;

static void keyboard_keymap(void *data, struct wl_keyboard *keyboard,
    uint32_t format, int fd, uint32_t size) {
    close(fd);
}

static void keyboard_enter(void *data, struct wl_keyboard *keyboard,
    uint32_t serial, struct wl_surface *surface, struct wl_array *keys) {
    printf("Teclado ativo\n");
}

static void keyboard_key(void *data, struct wl_keyboard *keyboard,
    uint32_t serial, uint32_t time, uint32_t key, uint32_t state) {
    printf("Tecla %d %s\n", key, state ? "pressionada" : "liberada");
    if (key == 1 && state) { // ESC
        exit(0);
    }
}

const struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
    .enter = keyboard_enter,
    .key = keyboard_key,
};

void setup_input() {
    if (seat) {
        keyboard = wl_seat_get_keyboard(seat);
        wl_keyboard_add_listener(keyboard, &keyboard_listener, NULL);
    }
}
```

Exercício: Modifique o exemplo inicial para exibir um gradiente azul-verde em vez de um fundo vermelho sólido. A solução deve usar o mesmo buffer compartilhado, mas calcular os valores de pixel linha por linha.

Solução comentada:
```c
void create_buffer(int width, int height) {
    // ... (parte inicial igual ao exemplo)
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t blue = (255 * x) / width;
            uint8_t green = (255 * y) / height;
            data[y * width + x] = (0xff << 24) | (green << 16) | (blue << 8);
        }
    }
    
    // ... (parte final igual ao exemplo)
}
```