## Segurança avançada em aplicativos Wayland

Um aplicativo bancário rodando sob Wayland precisa garantir que:
1. Nenhum keylogger capture senhas digitadas
2. Screenshots maliciosos não roubem dados sensíveis
3. Outras aplicações não injetem eventos de mouse/clique

O Wayland resolve isso através de três mecanismos centrais:

### 1. Isolamento de eventos de entrada

Quando um cliente Wayland recebe eventos do teclado (como em um campo de senha), o protocolo exige que o compositor marque tal janela como "sensitive". Veja como implementar isso com GTK4:

```c
// Exemplo: Campo de senha seguro
GtkEntry* password_entry = GTK_ENTRY(gtk_entry_new());
gtk_entry_set_visibility(password_entry, FALSE);
gtk_entry_set_input_purpose(password_entry, GTK_INPUT_PURPOSE_PASSWORD);

// Habilitando proteção contra captura
GdkSurface* surface = gtk_native_get_surface(GTK_NATIVE(gtk_widget_get_root(GTK_WIDGET(password_entry))));
gdk_wayland_surface_set_sensitive(surface, TRUE);
```

Se você esquecer `gdk_wayland_surface_set_sensitive`, o compositor exibirá este aviso:

```
Warning: sensitive input unprotected (client pid 1234)
```

### 2. Controle de captura de tela

Aplicativos podem bloquear screenshots via protocolo `xdg-desktop-portal`. Um exemplo com PipeWire:

```bash
# Tentativa de captura sem permissão (falhará)
wf-recorder -m ssl -o test.mp4 2>&1 | grep "permission denied"
# Saída esperada: "Failed to get screencopy session: GDBus.Error:org.freedesktop.DBus.Error.AccessDenied"
```

Para implementar o bloqueio programaticamente:

```c
// Em seu aplicativo
#include <gio/gio.h>

GDBusProxy* proxy = g_dbus_proxy_new_for_bus_sync(
    G_BUS_TYPE_SESSION,
    G_DBUS_PROXY_FLAGS_NONE,
    NULL,
    "org.freedesktop.portal.Desktop",
    "/org/freedesktop/portal/desktop",
    "org.freedesktop.portal.ScreenCast",
    NULL,
    NULL
);

GVariant* result = g_dbus_proxy_call_sync(
    proxy,
    "CreateSession",
    g_variant_new("(a{sv})", NULL),
    G_DBUS_CALL_FLAGS_NONE,
    -1,
    NULL,
    NULL
);
```

### 3. Sandboxing via namespaces do kernel

Wayland funciona naturalmente com containers. Veja como isolar um aplicativo financeiro:

```bash
# Cria um namespace isolado
unshare --user --map-root-user --pid --fork --mount-proc --net
# Verificando o isolamento
ps aux | grep -v "USER" # Mostrará apenas processos do namespace
```

Um erro comum é esquecer `--mount-proc`, resultando em:

```
Error: /proc must be mounted (to hide host processes)
```

### Exercício: Implementando um bloqueador de keylogger

Crie um aplicativo que:
1. Detecta tentativas não autorizadas de capturar entrada
2. Registra eventos suspeitos em `/var/log/wayland-security.log`
3. Notifica o usuário via DBus

Solução:

```c
#include <gtk/gtk.h>
#include <gdk/gdkwayland.h>

static void on_input_event(GtkWidget* widget, GdkEvent* event, gpointer data) {
    if (gdk_event_get_event_type(event) == GDK_KEY_PRESS) {
        GdkSurface* surface = gtk_native_get_surface(GTK_NATIVE(gtk_widget_get_root(widget)));
        if (!gdk_wayland_surface_get_sensitive(surface)) {
            // Log suspicious activity
            FILE* log = fopen("/var/log/wayland-security.log", "a");
            fprintf(log, "Unauthorized input capture attempt detected\n");
            fclose(log);
            
            // DBus notification
            system("notify-send 'Security Alert' 'Possible keylogger detected'");
        }
    }
}

int main(int argc, char** argv) {
    gtk_init();
    GtkWidget* window = gtk_window_new();
    g_signal_connect(window, "key-press-event", G_CALLBACK(on_input_event), NULL);
    gtk_window_present(GTK_WINDOW(window));
    gtk_main();
    return 0;
}
```