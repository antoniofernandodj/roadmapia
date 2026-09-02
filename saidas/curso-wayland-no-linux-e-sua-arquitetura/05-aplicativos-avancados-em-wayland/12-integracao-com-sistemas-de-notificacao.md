## Integração com sistemas de notificação

Quando seu aplicativo Wayland precisa alertar o usuário sem roubar o foco, as notificações do sistema são o mecanismo ideal. Vamos implementar um notificador de bateria fraca que aparece quando o nível cai abaixo de 20%, usando o protocolo `org.freedesktop.Notifications` via D-Bus.

Primeiro, instale as dependências necessárias:

```bash
sudo apt install libdbus-1-dev libsystemd-dev  # Debian/Ubuntu
```

O código completo para enviar uma notificação:

```c
#include <dbus/dbus.h>
#include <stdio.h>
#include <unistd.h>

void send_notification(const char *title, const char *message) {
    DBusError err;
    DBusConnection *conn;
    
    dbus_error_init(&err);
    conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
    
    if (dbus_error_is_set(&err)) {
        fprintf(stderr, "Erro D-Bus: %s\n", err.message);
        dbus_error_free(&err);
        return;
    }

    DBusMessage *msg = dbus_message_new_method_call(
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        "Notify");
    
    DBusMessageIter args;
    dbus_message_iter_init_append(msg, &args);
    
    const char *app_name = "Battery Monitor";
    uint32_t replaces_id = 0;
    const char *app_icon = "battery-low";
    const char *actions = "";
    dbus_int32_t timeout = -1;  // Tempo infinito
    
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &app_name);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_UINT32, &replaces_id);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &app_icon);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &title);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &message);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &actions);
    dbus_message_iter_append_basic(&args, DBUS_TYPE_INT32, &timeout);
    
    dbus_connection_send(conn, msg, NULL);
    dbus_connection_flush(conn);
    
    dbus_message_unref(msg);
    dbus_connection_unref(conn);
}

int main() {
    // Simulação: nível de bateria de 15%
    int battery_level = 15;
    
    if (battery_level < 20) {
        send_notification("Bateria Fraca", 
            "Nível da bateria: 15%\nConecte o carregador.");
    }
    
    return 0;
}
```

Compile com:

```bash
gcc -o battery_notifier battery_notifier.c `pkg-config --cflags --libs dbus-1`
```

Ao executar `./battery_notifier`, você verá uma notificação aparecer no canto da tela, mantendo o padrão visual do seu ambiente desktop.

**Erro comum**: esquecer de chamar `dbus_connection_flush()`. Sem isso, a mensagem pode ficar no buffer e nunca ser enviada. O erro não será visível, a notificação simplesmente não aparecerá.

Para notificações mais complexas com ações, modifique a função:

```c
// Adicione após dbus_message_iter_append_basic(&args, DBUS_TYPE_INT32, &timeout);
const char *action_keys[] = {"0", "action1", "1", "action2", NULL};
dbus_message_iter_append_basic(&args, DBUS_TYPE_ARRAY, &action_keys);
```

Isso criará botões clicáveis na notificação. Para capturar a resposta, você precisará registrar um filtro de mensagem:

```c
DBusHandleMessageFunction filter_func = ...;
dbus_connection_add_filter(conn, filter_func, NULL, NULL);
```

**Exercício**: Crie um monitor que verifica a cada 5 minutos se há novas mensagens em `/var/mail/$USER` e mostra uma notificação quando detecta novos e-mails. A notificação deve ter um botão "Abrir Cliente de E-mail" que executa `xdg-email` quando clicado.

**Solução comentada**:

```c
#include <sys/stat.h>
#include <time.h>
#include <string.h>

time_t last_check = 0;

void check_mail() {
    struct stat st;
    char path[256];
    snprintf(path, sizeof(path), "/var/mail/%s", getenv("USER"));
    
    if (stat(path, &st) == 0 && st.st_mtime > last_check) {
        send_notification("Novo E-mail", 
            "Você tem novas mensagens na caixa postal");
        last_check = time(NULL);
    }
}

// Modifique send_notification para incluir ações:
const char *actions[] = {"mail-client", "Abrir Cliente de E-mail", NULL};
dbus_message_iter_append_basic(&args, DBUS_TYPE_ARRAY, &actions);

// E implemente o handler:
DBusMessage* filter_func(DBusConnection *conn, DBusMessage *msg, void *data) {
    if (dbus_message_is_signal(msg, 
        "org.freedesktop.Notifications", 
        "ActionInvoked")) {
        system("xdg-email");
    }
    return NULL;
}
```