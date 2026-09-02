## Protocolos Wayland: comunicação entre componentes

A comunicação entre clientes e o compositor no Wayland é feita através de *protocolos*. Esses protocolos definem como as mensagens são estruturadas, quem pode enviá-las e como devem ser interpretadas. Cada protocolo é composto por *interfaces*, que são conjuntos de métodos e eventos que descrevem como os componentes interagem.

### Estrutura de um Protocolo

Um protocolo Wayland é organizado em interfaces, cada uma com métodos e eventos. Os métodos são chamados pelo cliente para solicitar ações do compositor, enquanto os eventos são enviados pelo compositor para notificar o cliente sobre mudanças ou solicitações.

Por exemplo, a interface `wl_surface` permite que o cliente crie e gerencie superfícies gráficas. Um método comum é `wl_surface_commit`, que envia as alterações feitas na superfície para o compositor renderizar. Já o evento `wl_surface_frame` é usado pelo compositor para notificar o cliente quando uma nova frame está pronta para ser renderizada.

```c
// Exemplo de uso de métodos e eventos da interface wl_surface
struct wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_commit(surface);

wl_callback *callback = wl_surface_frame(surface);
wl_callback_add_listener(callback, &frame_listener, NULL);
```

### Tipos de Mensagens

As mensagens no Wayland podem ser divididas em dois tipos principais: *requests* e *events*. 

- **Requests**: São enviados pelo cliente para o compositor, solicitando uma ação. Por exemplo, `wl_surface_commit` é um request que pede ao compositor para renderizar as alterações feitas na superfície.
  
- **Events**: São enviados pelo compositor para o cliente, notificando sobre mudanças ou solicitando ações. Por exemplo, `wl_surface_frame` é um evento que notifica o cliente que uma nova frame está pronta.

### Comunicação Assíncrona

A comunicação no Wayland é assíncrona, o que significa que o cliente pode enviar várias requests sem esperar por uma resposta imediata. Isso permite que o cliente continue executando outras tarefas enquanto aguarda a resposta do compositor.

```c
// Exemplo de comunicação assíncrona
wl_surface_commit(surface); // Envia uma request
wl_display_roundtrip(display); // Espera por todas as respostas pendentes
```

### Erro Comum: Falha na Comunicação

Um erro comum é não garantir que todas as mensagens foram processadas antes de continuar. Isso pode levar a comportamentos inesperados, como superfícies não renderizadas ou eventos perdidos. Para evitar isso, use `wl_display_roundtrip` para garantir que todas as mensagens foram processadas antes de continuar.

```c
// Exemplo de erro comum
wl_surface_commit(surface); // Envia uma request
// Falta wl_display_roundtrip(display); // Mensagens podem não ter sido processadas
```

### Comparação com X11

Em comparação com o X11, o Wayland simplifica a comunicação entre cliente e compositor. No X11, o cliente precisa lidar com várias camadas de protocolos e extensões, enquanto no Wayland, a comunicação é direta e mais eficiente.

### Exercício Prático

Escreva um cliente Wayland que cria uma superfície e usa `wl_surface_frame` para receber eventos de frame. Certifique-se de usar `wl_display_roundtrip` para garantir que todas as mensagens foram processadas.

```c
// Solução comentada
struct wl_surface *surface = wl_compositor_create_surface(compositor);
wl_surface_commit(surface);

wl_callback *callback = wl_surface_frame(surface);
wl_callback_add_listener(callback, &frame_listener, NULL);

wl_display_roundtrip(display); // Garante que todas as mensagens foram processadas
```

Este exercício reforça a importância de garantir que todas as mensagens sejam processadas antes de continuar, evitando comportamentos inesperados.