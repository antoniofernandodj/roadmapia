## Gerenciamento de sessões em aplicativos

Quando um aplicativo Wayland precisa persistir configurações ou estado entre execuções, surge o desafio: como manter dados consistentes quando múltiplas instâncias do mesmo aplicativo podem estar rodando simultaneamente? O Wayland não oferece um sistema de sessão nativo - cabe ao desenvolvedor implementá-lo.

### O problema da concorrência

Considere um editor de texto que salva automaticamente o estado da sessão. Se o usuário abrir o mesmo arquivo em duas janelas:

```c
// Exemplo problemático - estado conflitante
void save_session_state(const char *filename) {
    FILE *f = fopen("~/.config/editor_session", "w");
    fprintf(f, "%s\n", filename); // Sobrescreve o estado anterior
    fclose(f);
}
```

Isso causaria uma condição de corrida. O último processo a executar `save_session_state()` sobrescreveria as alterações do primeiro. A saída real seria imprevisível.

### Lock files para controle de acesso

A solução padrão no Unix é usar lock files. Veja a implementação correta:

```c
#include <fcntl.h>
#include <unistd.h>

int create_session_lock(const char *app_name) {
    char lock_path[256];
    snprintf(lock_path, sizeof(lock_path), "/tmp/%s.lock", app_name);
    
    int fd = open(lock_path, O_WRONLY | O_CREAT | O_EXCL, 0644);
    if (fd == -1 && errno == EEXIST) {
        fprintf(stderr, "Error: Another instance is already running\n");
        return -1;
    }
    
    // Escreve o PID do processo para referência
    char pid_str[16];
    snprintf(pid_str, sizeof(pid_str), "%d", getpid());
    write(fd, pid_str, strlen(pid_str));
    
    return fd; // Mantém o arquivo aberto para manter o lock
}
```

A chamada `O_EXCL` garante atomicidade na criação do arquivo. Se executarmos dois processos simultâneos, o segundo falhará com:

```
Error: Another instance is already running
```

### Gerenciamento de estado compartilhado

Para dados de sessão compartilhados entre instâncias, use um servidor D-Bus dedicado. Primeiro, declare a interface XML:

```xml
<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-Bus Object Introspection 1.0//EN"
  "http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
<node>
  <interface name="com.example.EditorSession">
    <method name="GetOpenFiles">
      <arg name="files" type="as" direction="out"/>
    </method>
    <method name="AddFile">
      <arg name="file" type="s" direction="in"/>
    </method>
  </interface>
</node>
```

Implemente o serviço:

```c
#include <dbus/dbus.h>

DBusHandlerResult handle_method_call(DBusConnection *conn, 
                                   DBusMessage *msg, 
                                   void *user_data) {
    if (dbus_message_is_method_call(msg, 
            "com.example.EditorSession", "AddFile")) {
        const char *filename;
        dbus_message_get_args(msg, NULL, 
                            DBUS_TYPE_STRING, &filename,
                            DBUS_TYPE_INVALID);
        
        // Adiciona à lista compartilhada
        add_to_global_list(filename);
        
        DBusMessage *reply = dbus_message_new_method_return(msg);
        dbus_connection_send(conn, reply, NULL);
        return DBUS_HANDLER_RESULT_HANDLED;
    }
    // ... outros métodos
}
```

### Sincronização com protocolos Wayland

Integre o gerenciamento de sessão com os eventos do Wayland:

```c
static void handle_global(void *data, struct wl_registry *registry,
                        uint32_t name, const char *interface,
                        uint32_t version) {
    if (strcmp(interface, "wl_compositor") == 0) {
        // Inicializa a sessão quando o compositor estiver pronto
        init_session_manager();
    }
}
```

### Exercício: Sistema de recuperação de sessão

Implemente um sistema que:
1. Registre todas as janelas abertas
2. Mantenha suas posições e tamanhos
3. Permita restaurar após reinício

**Solução comentada:**

```c
// Estrutura para armazenar estado da janela
typedef struct {
    uint32_t id;
    int x, y, width, height;
    char *title;
} WindowState;

// Salva o estado no final da sessão
void save_windows_state(GList *windows) {
    int fd = create_session_lock("myapp");
    if (fd == -1) return;
    
    FILE *f = fdopen(fd, "w");
    for (GList *l = windows; l; l = l->next) {
        WindowState *ws = (WindowState*)l->data;
        fprintf(f, "%d,%d,%d,%d,%d,%s\n", 
               ws->id, ws->x, ws->y, 
               ws->width, ws->height, ws->title);
    }
    fclose(f); // Libera o lock automaticamente
}

// Carrega o estado ao iniciar
GList* load_windows_state() {
    GList *windows = NULL;
    FILE *f = fopen("~/.config/myapp_session", "r");
    if (!f) return NULL;
    
    WindowState ws;
    char line[256];
    while (fgets(line, sizeof(line), f)) {
        sscanf(line, "%d,%d,%d,%d,%d,%[^\n]",
              &ws.id, &ws.x, &ws.y,
              &ws.width, &ws.height, ws.title);
        windows = g_list_append(windows, g_memdup(&ws, sizeof(ws)));
    }
    fclose(f);
    return windows;
}
```