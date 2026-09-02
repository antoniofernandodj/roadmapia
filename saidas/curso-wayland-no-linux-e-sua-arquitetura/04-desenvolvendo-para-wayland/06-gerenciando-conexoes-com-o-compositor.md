## Gerenciando conexões com o compositor

Um cliente Wayland precisa estabelecer e manter uma conexão com o compositor para enviar e receber mensagens. Vamos explorar como gerenciar essa conexão, desde a abertura até o tratamento de erros.

### Estabelecendo a conexão

A função `wl_display_connect()` inicia a comunicação com o compositor. Ela retorna um ponteiro para `wl_display`, que representa a conexão ativa:

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland\n");
        return 1;
    }
    printf("Conectado ao compositor Wayland\n");
    
    wl_display_disconnect(display);
    return 0;
}
```

Saída esperada (quando bem-sucedido):
```
Conectado ao compositor Wayland
```

O parâmetro `NULL` indica que queremos conectar ao compositor padrão. Você pode especificar um caminho alternativo (como "/run/user/1000/wayland-1") para conectar a um compositor específico.

### Tratando erros de conexão

Quando a conexão falha, `wl_display_connect` retorna NULL. O erro mais comum ocorre quando nenhum compositor Wayland está em execução:

```
Falha ao conectar ao compositor Wayland
```

Verifique se você está em uma sessão Wayland com:
```sh
echo $XDG_SESSION_TYPE
```

### Gerenciando o ciclo de vida da conexão

A conexão deve ser explicitamente fechada com `wl_display_disconnect()`. Esquecer este passo resulta em vazamento de recursos:

```c
// ERRADO: vazamento de conexão
struct wl_display *display = wl_display_connect(NULL);
// ... usar a conexão ...
// Faltou wl_display_disconnect(display);
```

### Monitorando eventos

O objeto `wl_display` também gerencia o loop de eventos. O método básico é `wl_display_dispatch()`, que processa eventos pendentes:

```c
struct wl_display *display = wl_display_connect(NULL);
while (wl_display_dispatch(display) != -1) {
    // Processar eventos
}
wl_display_disconnect(display);
```

### Tratando erros de protocolo

Quando ocorre um erro de protocolo (como uma mensagem inválida), o Wayland encerra a conexão. Você pode verificar isso com:

```c
if (wl_display_get_error(display) != 0) {
    fprintf(stderr, "Erro de protocolo detectado\n");
}
```

### Exercício: Conexão resiliente

Modifique o exemplo inicial para tentar reconectar automaticamente se a conexão falhar, com um intervalo de 1 segundo entre tentativas, até um máximo de 5 tentativas.

Solução comentada:

```c
#include <wayland-client.h>
#include <unistd.h>

int main() {
    struct wl_display *display = NULL;
    int tentativas = 0;
    
    while (tentativas < 5) {
        display = wl_display_connect(NULL);
        if (display) break;
        
        sleep(1);
        tentativas++;
    }
    
    if (!display) {
        fprintf(stderr, "Não foi possível conectar após 5 tentativas\n");
        return 1;
    }
    
    // Usar a conexão...
    wl_display_disconnect(display);
    return 0;
}
```

O código tenta reconectar automaticamente, prevenindo falhas temporárias. Em aplicações reais, você pode querer adicionar um callback para notificar o usuário sobre o estado da conexão.