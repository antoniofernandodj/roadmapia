## Sockets e comunicação em Wayland

No Wayland, a comunicação entre clientes e o compositor ocorre através de **sockets Unix**, um mecanismo eficiente para troca de dados entre processos em sistemas Unix-like, como Linux. Esses sockets são criados pelo compositor e permitem que os clientes se conectem para enviar requests e receber eventos.

### Como os sockets funcionam no Wayland

Quando o compositor Wayland é iniciado, ele cria um socket Unix em um caminho específico no sistema de arquivos, geralmente em `/run/user/<UID>/wayland-0`. Esse socket é o ponto de entrada para todos os clientes que desejam se comunicar com o compositor. Um cliente Wayland, ao iniciar, conecta-se a esse socket para estabelecer uma comunicação bidirecional.

Para ilustrar, vamos observar como o cliente Wayland se conecta ao socket:

```c
#include <stdio.h>
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }
    printf("Conectado ao compositor Wayland.\n");
    wl_display_disconnect(display);
    return 0;
}
```

Neste exemplo, `wl_display_connect(NULL)` tenta se conectar ao socket padrão do Wayland. Se a conexão for bem-sucedida, o cliente pode prosseguir com a comunicação. Caso contrário, ele falha com uma mensagem de erro.

### Erro comum: Falha na conexão ao socket

Um erro comum ocorre quando o cliente não consegue se conectar ao socket. Isso pode acontecer por vários motivos, como o compositor não estar em execução ou o caminho do socket estar incorreto. Veja o erro abaixo:

```bash
$ ./cliente
Falha ao conectar ao compositor Wayland.
```

Para resolver isso, certifique-se de que o compositor Wayland está em execução e que o ambiente gráfico está configurado corretamente. Em sistemas onde múltiplos compositors podem estar disponíveis, o cliente pode precisar especificar o caminho do socket manualmente.

### Especificando o caminho do socket

Se o cliente precisar se conectar a um socket específico, ele pode passar o caminho como argumento para `wl_display_connect`:

```c
struct wl_display *display = wl_display_connect("/run/user/1000/wayland-1");
```

Isso permite que o cliente se conecte a um compositor específico, útil em cenários onde múltiplos compositors estão em execução.

### Comunicação assíncrona através do socket

Uma vez conectado, o cliente e o compositor trocam mensagens através do socket. Essas mensagens são organizadas em requests e events, conforme definido pelo protocolo Wayland. A comunicação é assíncrona, permitindo que o cliente envie múltiplas requests sem esperar por respostas imediatas.

Por exemplo, quando um cliente cria uma superfície (`wl_surface`), ele envia uma request ao compositor através do socket. O compositor, por sua vez, responde com events que notificam o cliente sobre mudanças de estado ou outras informações relevantes.

### Exercício: Verificando a conexão ao socket

Escreva um programa que tenta se conectar ao socket Wayland padrão e, em caso de falha, tenta se conectar a um socket alternativo em `/tmp/wayland-custom`. Se ambas as tentativas falharem, o programa deve exibir uma mensagem de erro.

**Solução:**

```c
#include <stdio.h>
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        display = wl_display_connect("/tmp/wayland-custom");
        if (!display) {
            fprintf(stderr, "Falha ao conectar a ambos os sockets Wayland.\n");
            return 1;
        }
        printf("Conectado ao socket alternativo.\n");
    } else {
        printf("Conectado ao socket padrão.\n");
    }
    wl_display_disconnect(display);
    return 0;
}
```

Este programa tenta primeiro se conectar ao socket padrão. Se falhar, tenta se conectar ao socket alternativo em `/tmp/wayland-custom`. Se ambas as tentativas falharem, ele exibe uma mensagem de erro.