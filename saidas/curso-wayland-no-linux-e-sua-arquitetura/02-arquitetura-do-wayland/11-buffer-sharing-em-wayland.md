## Buffer sharing em Wayland

Em um sistema gráfico moderno, a eficiência na transferência de dados entre o cliente (aplicativo) e o compositor é crucial para o desempenho. No Wayland, isso é feito através do compartilhamento de buffers, que são regiões de memória contendo os dados gráficos que serão exibidos na tela. O mecanismo de buffer sharing no Wayland é projetado para minimizar cópias desnecessárias de memória e garantir que os frames sejam entregues ao compositor de forma rápida e segura.

### O que é um buffer?

Um buffer é uma região de memória que contém os dados gráficos que um cliente deseja exibir. Esses dados podem ser pixels, texturas ou qualquer outra informação visual que o compositor precisa renderizar. No contexto do Wayland, os buffers são tipicamente alocados em memória compartilhada (shared memory) ou através de APIs específicas de hardware, como EGL ou DRM.

### Compartilhamento de buffers via `wl_shm`

O protocolo `wl_shm` (Shared Memory) é a interface padrão para compartilhar buffers entre clientes e o compositor. Ele permite que os clientes aloquem memória compartilhada e criem buffers que podem ser usados para desenhar gráficos. O compositor então mapeia essa memória e a usa para renderizar a superfície (`wl_surface`) associada.

Aqui está um exemplo simples de como criar e compartilhar um buffer usando `wl_shm`:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao Wayland\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    struct wl_compositor *compositor = NULL;
    struct wl_shm *shm = NULL;

    // Listener para registrar interfaces globais
    static const struct wl_registry_listener registry_listener = {
        .global = [](void *data, struct wl_registry *registry, uint32_t name,
                     const char *interface, uint32_t version) {
            if (strcmp(interface, "wl_compositor") == 0) {
                compositor = (struct wl_compositor *)wl_registry_bind(
                    registry, name, &wl_compositor_interface, 1);
            } else if (strcmp(interface, "wl_shm") == 0) {
                shm = (struct wl_shm *)wl_registry_bind(
                    registry, name, &wl_shm_interface, 1);
            }
        },
        .global_remove = [](void *data, struct wl_registry *registry, uint32_t name) {},
    };

    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    if (!compositor || !shm) {
        fprintf(stderr, "Falha ao obter interfaces globais\n");
        return 1;
    }

    // Criar um buffer de 100x100 pixels
    int width = 100;
    int height = 100;
    int stride = width * 4; // 4 bytes por pixel (ARGB)
    int size = stride * height;

    int fd = memfd_create("buffer", 0);
    if (fd < 0) {
        fprintf(stderr, "Falha ao criar memfd\n");
        return 1;
    }

    ftruncate(fd, size);
    uint8_t *data = (uint8_t *)mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        fprintf(stderr, "Falha ao mapear memória\n");
        close(fd);
        return 1;
    }

    // Preencher o buffer com um padrão simples
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            data[y * stride + x * 4 + 0] = 0xFF; // Alpha
            data[y * stride + x * 4 + 1] = x % 256; // Red
            data[y * stride + x * 4 + 2] = y % 256; // Green
            data[y * stride + x * 4 + 3] = 0x00; // Blue
        }
    }

    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, width, height, stride, WL_SHM_FORMAT_ARGB8888);
    wl_shm_pool_destroy(pool);
    close(fd);

    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);

    wl_display_roundtrip(display);

    // Limpar recursos
    wl_buffer_destroy(buffer);
    wl_surface_destroy(surface);
    wl_shm_destroy(shm);
    wl_compositor_destroy(compositor);
    wl_registry_destroy(registry);
    wl_display_disconnect(display);

    return 0;
}
```

Neste exemplo, o cliente cria um buffer de 100x100 pixels usando memória compartilhada (`wl_shm`), preenche-o com um padrão simples e o anexa a uma superfície (`wl_surface`). O compositor então renderiza a superfície na tela.

### Erros comuns ao compartilhar buffers

Um erro comum é esquecer de liberar os recursos após o uso, o que pode levar a vazamentos de memória. Outro erro é tentar usar um buffer que já foi destruído, o que resulta em comportamento indefinido. É importante garantir que todos os recursos sejam liberados adequadamente e que os buffers sejam usados apenas enquanto estiverem válidos.

### Comparação com X11

No X11, o compartilhamento de buffers é mais complexo devido à arquitetura de camadas intermediárias. O Wayland simplifica esse processo ao transferir a responsabilidade de gerenciamento de buffers para os clientes, permitindo uma comunicação mais direta e eficiente com o compositor.

### Exercício: Criando um buffer personalizado

Modifique o exemplo acima para criar um buffer de 200x200 pixels e preencha-o com um gradiente de cores. Certifique-se de liberar todos os recursos após o uso.

**Solução:**

```c
// ... (código anterior)

    // Criar um buffer de 200x200 pixels
    int width = 200;
    int height = 200;
    int stride = width * 4; // 4 bytes por pixel (ARGB)
    int size = stride * height;

    int fd = memfd_create("buffer", 0);
    if (fd < 0) {
        fprintf(stderr, "Falha ao criar memfd\n");
        return 1;
    }

    ftruncate(fd, size);
    uint8_t *data = (uint8_t *)mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        fprintf(stderr, "Falha ao mapear memória\n");
        close(fd);
        return 1;
    }

    // Preencher o buffer com um gradiente de cores
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            data[y * stride + x * 4 + 0] = 0xFF; // Alpha
            data[y * stride + x * 4 + 1] = (x * 255 / width) % 256; // Red
            data[y * stride + x * 4 + 2] = (y * 255 / height) % 256; // Green
            data[y * stride + x * 4 + 3] = 0x00; // Blue
        }
    }

    // ... (restante do código)
```

Este exemplo cria um buffer maior e preenche-o com um gradiente de cores, demonstrando como manipular buffers de forma eficiente no Wayland.