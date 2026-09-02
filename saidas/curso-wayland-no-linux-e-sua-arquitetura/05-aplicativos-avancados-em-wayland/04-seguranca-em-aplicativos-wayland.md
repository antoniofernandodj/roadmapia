## Segurança em aplicativos Wayland

Wayland foi desenhado com segurança como prioridade desde sua concepção, mas isso não significa que aplicativos estejam imunes a problemas. O protocolo implementa um modelo rigoroso de isolamento entre clientes, mas cabe ao desenvolvedor entender e aplicar corretamente esses mecanismos. Vamos explorar os principais aspectos práticos.

### Isolamento entre processos

No Wayland, cada aplicativo só pode acessar seus próprios buffers e superfícies. Vamos criar um exemplo onde dois aplicativos tentam interferir um com o outro:

```c
#include <wayland-client.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao Wayland\n");
        return 1;
    }

    // Tentativa maliciosa de acessar outra superfície
    uint32_t fake_surface_id = 12345; // ID que não pertence a este processo
    struct wl_surface *surface = (struct wl_surface*)wl_proxy_create_for_id(
        display, &wl_surface_interface, fake_surface_id);

    if (surface) {
        printf("Violação de segurança conseguida!\n");
    } else {
        printf("Wayland bloqueou acesso ilegítimo\n");
    }

    wl_display_disconnect(display);
    return 0;
}
```

Saída esperada:
```
Wayland bloqueou acesso ilegítimo
```

O código falha porque o Wayland usa verificação de propriedade baseada em IDs. Cada ID de objeto é válido apenas dentro do contexto do processo que o criou. A tentativa de acessar um objeto de outro processo resulta em erro.

### Gerenciamento seguro de buffers

O compartilhamento de buffers requer atenção especial. Considere este exemplo com `wl_shm`:

```c
#include <wayland-client.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

void create_shared_buffer(struct wl_shm *shm, int width, int height) {
    int stride = width * 4;
    int size = stride * height;
    
    char filename[] = "/tmp/wl-shm-XXXXXX";
    int fd = mkstemp(filename);
    ftruncate(fd, size);
    
    void *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        close(fd);
        unlink(filename);
        return;
    }

    // Preenche com padrão visível
    memset(data, 0x80, size); // 50% cinza
    
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, size);
    struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 
                                                       width, height, 
                                                       stride, 
                                                       WL_SHM_FORMAT_ARGB8888);
    
    // Limpeza segura
    wl_buffer_destroy(buffer);
    wl_shm_pool_destroy(pool);
    munmap(data, size);
    close(fd);
    unlink(filename);
}
```

O erro comum aqui seria esquecer de limpar os recursos (arquivo temporário e mapeamento de memória). O Wayland exige que o cliente gerencie corretamente os recursos compartilhados, caso contrário, pode haver vazamento de informações entre sessões.

### Controle de permissões

Wayland implementa um sistema de capacidades através do protocolo `zwp_linux_dmabuf_v1`. Veja como verificar suporte:

```c
struct zwp_linux_dmabuf_v1 *dmabuf = NULL;
struct wl_registry *registry = wl_display_get_registry(display);
wl_registry_add_listener(registry, &registry_listener, NULL);
wl_display_roundtrip(display);

if (!dmabuf) {
    printf("DMABUF não suportado ou permissões insuficientes\n");
    return;
}
```

A mensagem de erro típica quando faltam permissões:
```
error: XDG_RUNTIME_DIR not set in the environment.
Or: Failed to connect to /run/user/1000/wayland-0: Permission denied
```

Solução prática: configure corretamente as permissões do diretório runtime (`/run/user/<UID>`) e verifique se o aplicativo tem acesso ao socket Wayland.

### Sandboxing eficaz

Para aplicativos críticos, combine Wayland com namespaces do Linux:

```bash
# Criar sandbox básica
unshare --user --map-root-user --pid --fork
mkdir -p /tmp/sandbox
mount --bind /tmp/sandbox /tmp/sandbox
mount --make-private /tmp/sandbox
```

Este comando cria um ambiente isolado onde o aplicativo não pode acessar recursos do sistema host, mesmo que explore alguma vulnerabilidade no cliente Wayland.

### Exercício prático

Implemente um visualizador de imagens que:
1. Cria buffers compartilhados somente leitura após carregar a imagem
2. Verifica permissões antes de acessar arquivos
3. Executa em um namespace isolado

Solução comentada:

```c
#include <wayland-client.h>
#include <libpng16/png.h>
#include <linux/limits.h>

void load_image(const char *path, struct wl_shm *shm) {
    // Verificação de permissões
    if (access(path, R_OK) != 0) {
        fprintf(stderr, "Acesso negado: %s\n", path);
        return;
    }

    // Carrega PNG (código simplificado)
    png_image image;
    memset(&image, 0, sizeof(image));
    image.version = PNG_IMAGE_VERSION;
    
    if (png_image_begin_read_from_file(&image, path) != 0) {
        // Cria buffer compartilhado seguro
        int fd = memfd_create("image_buffer", MFD_CLOEXEC);
        ftruncate(fd, PNG_IMAGE_SIZE(image));
        
        void *data = mmap(NULL, PNG_IMAGE_SIZE(image), 
                         PROT_READ, MAP_SHARED, fd, 0);
        
        png_image_finish_read(&image, NULL, data, 0, NULL);
        
        // Cria buffer Wayland (código similar ao exemplo anterior)
        // ...
        
        // Configura flags de segurança
        fcntl(fd, F_SETFD, FD_CLOEXEC);
        close(fd);
        munmap(data, PNG_IMAGE_SIZE(image));
    }
}
```

Principais medidas de segurança:
1. Verificação explícita de permissões (`access()`)
2. Uso de `memfd_create` com `MFD_CLOEXEC`
3. Mapeamento somente leitura (`PROT_READ`)
4. Flags `FD_CLOEXEC` para evitar vazamento de file descriptors