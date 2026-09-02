## Profiling de aplicativos Wayland

Para otimizar o desempenho de um aplicativo Wayland, é essencial entender onde e como ele gasta recursos. O profiling é a técnica que permite identificar esses pontos críticos, seja em termos de CPU, memória ou operações gráficas. Vamos explorar ferramentas e métodos para realizar esse diagnóstico de forma eficaz.

### Perf: Análise de desempenho em nível de sistema

O `perf` é uma ferramenta poderosa para análise de desempenho no Linux. Ele coleta dados sobre chamadas de sistema, eventos de hardware e uso de CPU. Para começar, instale o `perf`:

```bash
sudo apt-get install linux-tools-common linux-tools-generic
```

Para analisar um aplicativo Wayland, execute-o com o `perf`:

```bash
perf record ./meu_aplicativo_wayland
```

Após encerrar o aplicativo, o `perf` gera um arquivo `perf.data`. Use o seguinte comando para visualizar os resultados:

```bash
perf report
```

Isso abre uma interface interativa mostrando as funções que mais consomem CPU. Por exemplo, se você encontrar uma função `render_frame` no topo da lista, é um indicativo de que a renderização está sendo um gargalo.

### Valgrind: Detecção de vazamentos de memória

Vazamentos de memória podem ser especialmente problemáticos em aplicativos gráficos. O `valgrind` é uma ferramenta que ajuda a identificar esses problemas. Para usá-lo, execute:

```bash
valgrind --leak-check=full ./meu_aplicativo_wayland
```

Se houver vazamentos, o `valgrind` mostrará detalhes como:

```
==12345== 100 bytes in 1 blocks are definitely lost in loss record 1 of 1
==12345==    at 0x4C2BBAF: malloc (vg_replace_malloc.c:299)
==12345==    by 0x4005E4: criar_buffer (meu_aplicativo.c:45)
```

Isso indica que `criar_buffer` alocou memória que não foi liberada. Corrija o código para evitar esse problema.

### Weston-screenshooter: Captura de frames para análise visual

O `weston-screenshooter` é uma ferramenta específica para Wayland que permite capturar frames da tela. Isso é útil para identificar problemas visuais, como flickering ou desenho incorreto. Para usá-lo, primeiro instale:

```bash
sudo apt-get install weston-screenshooter
```

Em seguida, execute o aplicativo e capture um frame:

```bash
weston-screenshooter -f captura.png
```

Analise a imagem `captura.png` para verificar se há anomalias visuais.

### GDB: Debugging avançado

O GDB é essencial para debugging avançado, especialmente em aplicativos complexos. Para usá-lo com um aplicativo Wayland, compile o código com informações de debugging:

```bash
gcc -g -o meu_aplicativo_wayland meu_aplicativo.c `pkg-config --cflags --libs wayland-client`
```

Depois, execute o aplicativo com o GDB:

```bash
gdb ./meu_aplicativo_wayland
```

Dentro do GDB, você pode definir breakpoints e inspecionar o estado do programa. Por exemplo, para pausar a execução ao chamar `wl_surface_commit`, use:

```gdb
break wl_surface_commit
```

### Exercício prático

Implemente um aplicativo simples que desenha um retângulo na tela usando Wayland. Use o `perf` para identificar a função que mais consome CPU e otimize-a. Em seguida, use o `valgrind` para garantir que não há vazamentos de memória.

**Solução comentada:**

```c
#include <wayland-client.h>
#include <stdio.h>
#include <stdlib.h>

struct wl_display *display = NULL;
struct wl_compositor *compositor = NULL;
struct wl_surface *surface = NULL;

void criar_superficie() {
    surface = wl_compositor_create_surface(compositor);
    if (!surface) {
        fprintf(stderr, "Erro ao criar superfície\n");
        exit(1);
    }
}

int main(int argc, char **argv) {
    display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao display\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);

    criar_superficie();

    while (1) {
        wl_display_dispatch(display);
    }

    wl_surface_destroy(surface);
    wl_display_disconnect(display);
    return 0;
}
```

Use o `perf` para identificar que `wl_display_dispatch` é a função que mais consome CPU. Para otimizar, considere reduzir a frequência de chamadas ou realizar operações assíncronas.