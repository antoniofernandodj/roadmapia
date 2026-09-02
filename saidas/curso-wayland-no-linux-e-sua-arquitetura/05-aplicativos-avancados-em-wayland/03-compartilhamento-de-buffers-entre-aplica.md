## Compartilhamento de buffers entre aplicativos

Quando dois aplicativos Wayland precisam compartilhar conteúdo gráfico - como um editor de screenshots que precisa acessar a imagem de outro app - criar cópias dos buffers é ineficiente. O Wayland resolve isso com compartilhamento direto via memória compartilhada (SHM) e DMA-BUF.

O protocolo básico usa `wl_shm` para buffers simples. Veja como criar um buffer compartilhado que outro processo pode acessar:

```c
// Cria um arquivo temporário anônimo para memória compartilhada
int fd = memfd_create("buffer_shared", MFD_CLOEXEC);
ftruncate(fd, width * height * 4); // Tamanho para formato ARGB8888

// Mapeia a memória
uint32_t *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

// Registra no Wayland
struct wl_shm_pool *pool = wl_shm_create_pool(wl_shm, fd, size);
struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0, 
                    width, height, 
                    width * 4, 
                    WL_SHM_FORMAT_ARGB8888);

wl_shm_pool_destroy(pool);
close(fd);
```

Um erro comum é esquecer de configurar as permissões corretamente, resultando em:

```
error: wl_shm@32: error 0: invalid file descriptor (permissions?)
```

Para compartilhar este buffer com outro processo, use `wl_display` para enviar o file descriptor:

```c
// Envia o FD via socket Unix
struct msghdr msg = {0};
char buf[CMSG_SPACE(sizeof(fd))];
msg.msg_control = buf;
msg.msg_controllen = sizeof(buf);

struct cmsghdr *cmsg = CMSG_FIRSTHDR(&msg);
cmsg->cmsg_level = SOL_SOCKET;
cmsg->cmsg_type = SCM_RIGHTS;
cmsg->cmsg_len = CMSG_LEN(sizeof(fd));
memcpy(CMSG_DATA(cmsg), &fd, sizeof(fd));

sendmsg(socket_fd, &msg, 0);
```

Para gráficos acelerados por hardware (GPU), use DMA-BUF com o protocolo `zwp_linux_dmabuf_v1`:

```c
// Cria um buffer compartilhável pela GPU
struct zwp_linux_buffer_params_v1 *params = 
    zwp_linux_dmabuf_v1_create_params(linux_dmabuf);

zwp_linux_buffer_params_v1_add(params, 
    dma_buf_fd, 0, offset, 
    stride, modifier_hi, modifier_lo);

struct wl_buffer *hw_buffer = 
    zwp_linux_buffer_params_v1_create_immed(params, 
        width, height, 
        format, flags);
```

Um erro típico nesse caso ocorre ao usar modificadores não suportados:

```
zwp_linux_dmabuf_v1@19: error 2: invalid modifier (0x0, 0x0)
```

Para resolver, verifique os modificadores suportados com `zwp_linux_dmabuf_v1_get_supported_formats`.

**Exercício**: Implemente um programa que cria um buffer compartilhado, desenha um gradiente nele, e envia para outro processo que exibe o conteúdo. Compare o desempenho com e sem compartilhamento usando `gettimeofday` antes e depois da transferência.

**Solução** (trecho principal):

```c
// Processo A: cria e preenche o buffer
for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
        data[y * width + x] = (x * 255 / width) << 16 | (y * 255 / height) << 8;
    }
}

// Processo B: recebe e exibe
struct wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_attach(surface, shared_buffer, 0, 0);
wl_surface_damage(surface, 0, 0, width, height);
wl_surface_commit(surface);
```

A medição de desempenho mostrará que o compartilhamento direto (0-2ms) é ordens de magnitude mais rápido que copiar os pixels (15-50ms para 1920x1080).