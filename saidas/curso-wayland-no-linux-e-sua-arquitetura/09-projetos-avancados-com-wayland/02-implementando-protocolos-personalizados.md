## Implementando protocolos personalizados

Um protocolo Wayland define como clientes e servidores comunicam. Quando precisamos de funcionalidades além das oferecidas pelos protocolos padrão, criamos nossos próprios. Vamos implementar um protocolo simples que permite aos clientes enviar mensagens de texto customizadas para o compositor.

### 1. Definindo a interface XML

Wayland usa arquivos XML para definir protocolos. Crie `custom-message-v1.xml`:

```xml
<protocol name="custom_message">
    <interface name="custom_message_manager" version="1">
        <request name="create_message">
            <arg name="id" type="new_id" interface="custom_message"/>
        </request>
    </interface>

    <interface name="custom_message" version="1">
        <request name="set_text">
            <arg name="text" type="string"/>
        </request>
        <event name="display">
            <arg name="text" type="string"/>
        </event>
    </interface>
</protocol>
```

Este XML define:
- `custom_message_manager`: fábrica para criar instâncias de mensagem
- `custom_message`: objeto que transporta texto do cliente para o compositor

### 2. Gerando código com wayland-scanner

O wayland-scanner gera código C a partir do XML:

```bash
wayland-scanner server-header custom-message-v1.xml custom-message-protocol.h
wayland-scanner private-code custom-message-v1.xml custom-message-protocol.c
```

Isso cria arquivos com:
- Estruturas para os objetos do protocolo
- Implementação base das interfaces
- Funções para enviar/receber mensagens

### 3. Implementando no compositor

No compositor, registramos a interface global:

```c
#include "custom-message-protocol.h"

struct custom_message_manager *manager;

void bind_custom_message(struct wl_client *client, void *data, 
                        uint32_t version, uint32_t id) {
    manager = wl_resource_create(client, &custom_message_manager_interface,
                                version, id);
    wl_resource_set_implementation(manager, NULL, NULL, NULL);
}

// No initialization:
wl_global_create(compositor->wl_display, &custom_message_manager_interface,
                1, NULL, bind_custom_message);
```

### 4. Implementando no cliente

O cliente se conecta à interface global:

```c
struct custom_message_manager *manager;
struct custom_message *message;

manager = wl_registry_bind(registry, name,
                         &custom_message_manager_interface, version);
message = custom_message_manager_create_message(manager);

custom_message_set_text(message, "Hello from client!");
```

### 5. Lidando com erros comuns

**Erro típico:** esquecer de incrementar a versão ao modificar o protocolo:
```
error: interface 'custom_message' version 1 requested, have 0
```

Solução: atualize o número de versão no XML e recompile ambos os lados.

**Erro de tempo de execução:**
```
wl_registry@2: error 0: invalid version for global custom_message_manager (1): have 0
```

Ocorre quando versões do protocolo não coincidem entre cliente e servidor.

### 6. Recebendo mensagens no compositor

Implemente o handler para exibir as mensagens recebidas:

```c
static void handle_display(struct wl_client *client, 
                         struct wl_resource *resource,
                         const char *text) {
    printf("Message received: %s\n", text);
}

static const struct custom_message_interface message_impl = {
    .set_text = handle_set_text,
    .display = handle_display
};
```

### 7. Exercício prático

**Problema:** Modifique o protocolo para incluir um campo de prioridade (número inteiro) nas mensagens, onde:
- Prioridade 1: mensagem normal (verde)
- Prioridade 2: mensagem importante (amarelo)
- Prioridade 3: mensagem crítica (vermelho)

**Solução:**

1. Modifique o XML:
```xml
<request name="set_priority">
    <arg name="level" type="int"/>
</request>
```

2. Implemente no cliente:
```c
custom_message_set_priority(message, 2);  // Mensagem importante
```

3. No compositor:
```c
static void handle_set_priority(struct wl_client *client,
                              struct wl_resource *resource,
                              int32_t level) {
    const char *color;
    switch (level) {
        case 1: color = "green"; break;
        case 2: color = "yellow"; break;
        case 3: color = "red"; break;
    }
    printf("Displaying %s priority message\n", color);
}
```