## Recapitulação e próximos passos

Aqui está o panorama completo do que construímos até agora, com exemplos funcionais que demonstram cada conceito:

1. **Conexão básica** - Estabelecemos comunicação com o compositor usando `wl_display_connect()`. Este é o ponto de entrada obrigatório para qualquer cliente Wayland:

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland\n");
        return 1;
    }
    wl_display_disconnect(display);
    return 0;
}
```

2. **Gerenciamento de superfícies** - Criamos janelas através da hierarquia `wl_compositor` → `wl_surface` → `wl_shell_surface`. O erro mais comum é esquecer de comitar a superfície:

```c
struct wl_surface *surface = wl_compositor_create_surface(compositor);
wl_shell_surface_set_toplevel(shell_surface);
wl_surface_commit(surface);  // Sem isso, nada aparece!
```

3. **Buffers compartilhados** - Implementamos o desenho usando memória compartilhada via `memfd_create` e `wl_shm`. Um erro fatal ocorre quando se usa formatos não suportados:

```c
uint32_t format = WL_SHM_FORMAT_XRGB8888;  // Formato mais compatível
if (!wl_shm_format_has(shm, format)) {
    fprintf(stderr, "Formato 0x%X não suportado\n", format);
    exit(1);
}
```

4. **Eventos de entrada** - Configuramos listeners para mouse e teclado através das interfaces `wl_pointer` e `wl_keyboard`. Um padrão essencial é a conversão de coordenadas:

```c
void pointer_handle_motion(void *data, struct wl_pointer *pointer,
                          uint32_t time, wl_fixed_t sx, wl_fixed_t sy) {
    int x = wl_fixed_to_int(sx);  // Converte para pixels
    int y = wl_fixed_to_int(sy);
    printf("Mouse em: %d, %d\n", x, y);
}
```

5. **Toolkits gráficos** - Vimos como GTK e Qt abstraem esses detalhes. Um erro frequente é não especificar o backend correto:

```bash
# Necessário para garantir que Qt use Wayland
export QT_QPA_PLATFORM=wayland
./meu_app
```

Agora que você domina os fundamentos, os próximos passos incluirão:

- **Protocolos estendidos** como `xdg_shell` para comportamentos avançados de janelas
- **Composição acelerada** com EGL e OpenGL
- **Sincronização de frames** para animações suaves
- **Gerenciamento de múltiplas janelas** e superfícies sobrepostas

Para consolidar, modifique este cliente básico para exibir uma janela vermelha que muda para azul quando clicada. Use o protocolo `wl_shm` para criar buffers coloridos e registre um listener para eventos de clique.

**Solução comentada:**

```c
// [Código inicial de conexão omitido...]

// Cria buffer vermelho
uint32_t red = 0xFF0000FF;
fill_buffer(shm_data, width, height, red);

// Listener para eventos de clique
static void handle_click(void *data, struct wl_pointer *pointer, 
                       uint32_t serial, uint32_t time) {
    struct app_state *state = data;
    uint32_t blue = 0xFF0000FF;
    fill_buffer(state->shm_data, state->width, state->height, blue);
    wl_surface_commit(state->surface);
}

// [Restante da implementação...]
```