## Sessões e isolamento em Wayland

Ao executar `sway` ou outro compositor Wayland, você está iniciando uma sessão gráfica isolada. Esse isolamento é fundamental para segurança - diferente do X11 onde qualquer aplicativo poderia monitorar teclas ou redirecionar janelas de outros programas. Vejamos como isso funciona na prática:

### Isolamento por socket UNIX

Cada sessão Wayland cria seu próprio socket em `/run/user/<UID>/wayland-*`. Vamos inspecionar isso:

```bash
$ ls -l /run/user/1000/wayland*
srwxr-xr-x 1 usuario usuario 0 Jun 15 10:00 /run/user/1000/wayland-0
```

A tentativa de um cliente se conectar a uma sessão diferente falha com:

```
error: could not connect to wayland display at '/run/user/1001/wayland-0'
failed to connect to display
```

Isso ocorre porque os sockets são protegidos por permissões de usuário. Vamos tentar contornar isso:

```c
#include <wayland-client.h>
#include <stdio.h>

int main() {
    struct wl_display *display = wl_display_connect("/run/user/1001/wayland-0");
    if (!display) {
        perror("Failed to connect");
        return 1;
    }
    printf("Connected successfully!\n");
    wl_display_disconnect(display);
    return 0;
}
```

Compilando e executando como outro usuário:

```
$ ./client 
Failed to connect: Permission denied
```

### Namespaces e isolamento de recursos

Wayland utiliza namespaces do kernel Linux para isolar recursos entre sessões. Vamos verificar os namespaces de processos em diferentes sessões:

```bash
$ cat /proc/$(pidof sway)/ns/mnt
mnt:[4026531840]
$ cat /proc/$(pidof gnome-shell-wayland)/ns/mnt 
mnt:[4026532185]
```

Números diferentes indicam namespaces distintos. Isso significa que:

1. Sistemas de arquivos montados em uma sessão não são visíveis na outra
2. Dispositivos como `/dev/input` são filtrados por sessão

### Controle de acesso granular

Wayland implementa um modelo de capacidades onde clientes devem explicitamente requisitar acesso. Veja como um cliente tenta capturar eventos de teclado:

```c
struct wl_seat *seat;
static void seat_capabilities(void *data, struct wl_seat *seat,
                            uint32_t capabilities) {
    if (capabilities & WL_SEAT_CAPABILITY_KEYBOARD) {
        printf("Teclado disponível\n");
        // Solicitar teclado explicitamente
        struct wl_keyboard *keyboard = wl_seat_get_keyboard(seat);
    } else {
        printf("Sem acesso ao teclado\n");
    }
}
```

Se o compositor não conceder a capacidade, o cliente simplesmente não receberá eventos de entrada.

### Exercício: Criando sessões isoladas

1. Inicie duas sessões Wayland diferentes (ex: GNOME e Sway)
2. Em cada uma, execute `ls /run/user/$(id -u)/wayland*` e compare os sockets
3. Tente conectar um cliente de uma sessão à outra usando o código de exemplo
4. Verifique os namespaces com `ls -l /proc/$(pidof compositor)/ns/`

Solução esperada:
- Cada sessão terá seu próprio socket Wayland
- As tentativas de conexão cruzada falharão com "Permission denied"
- Os namespaces mostrarão valores diferentes para cada sessão