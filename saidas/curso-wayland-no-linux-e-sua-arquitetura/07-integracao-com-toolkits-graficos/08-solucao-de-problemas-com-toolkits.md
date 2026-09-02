## Solução de problemas com toolkits

Um aplicativo GTK que funciona perfeitamente no X11 pode falhar silenciosamente no Wayland com apenas uma mensagem enigmática no terminal:

```
GTK-WARNING **: 15:30:45.123 Cannot open display: 
```

O problema real? O toolkit está tentando se conectar ao servidor X11 por padrão, mesmo em uma sessão Wayland. A solução mais direta é forçar o backend Wayland com:

```bash
GDK_BACKEND=wayland gtk3-demo
```

Mas e quando o aplicativo simplesmente fecha sem mensagens? O problema provavelmente está na falta de suporte a algum protocolo Wayland essencial. Por exemplo, tentar criar uma janela sem implementar o protocolo `xdg-shell` resultará em:

```
(wireplumber:12054): Gtk-WARNING **: 15:32:10.456 Failed to create surface: wl_display error 1
```

O código mínimo funcional precisa incluir a inicialização explícita do protocolo:

```c
#include <gtk/gtk.h>

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);
    
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Wayland Toolkit Demo");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);
    
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    gtk_widget_show_all(window);
    
    gtk_main();
    return 0;
}
```

Compile e execute com:
```bash
gcc `pkg-config --cflags --libs gtk+-3.0` gtk_wayland.c -o gtk_wayland
GDK_BACKEND=wayland ./gtk_wayland
```

No Qt, um problema comum é a renderização incorreta quando o aplicativo assume recursos específicos do X11. O trecho abaixo falhará no Wayland:

```cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    QLabel label("Teste no Wayland");
    label.setAlignment(Qt::AlignCenter);
    label.show();
    
    return app.exec();
}
```

A mensagem de erro típica será:
```
qt.qpa.wayland: Wayland does not support QWindow::requestActivate()
```

A solução é usar `QT_QPA_PLATFORM` corretamente e evitar APIs específicas do X11:

```bash
QT_QPA_PLATFORM=wayland ./qt_wayland_app
```

Para SDL, o problema mais frequente é a detecção automática do backend. Um jogo pode tentar iniciar no X11 mesmo sob Wayland. O código de verificação essencial é:

```c
#include <SDL2/SDL.h>
#include <stdio.h>

int main() {
    SDL_Init(SDL_INIT_VIDEO);
    
    SDL_Window *window = SDL_CreateWindow("SDL Wayland",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        640, 480, 0);
        
    const char *driver = SDL_GetCurrentVideoDriver();
    printf("Driver em uso: %s\n", driver);
    
    SDL_Delay(3000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
```

Execute com:
```bash
SDL_VIDEODRIVER=wayland ./sdl_wayland_test
```

Se o output mostrar "x11" em vez de "wayland", seu ambiente não está configurado corretamente para SDL.

**Exercício**: Crie um aplicativo GTK que exiba uma mensagem de erro personalizada quando detectar execução no X11 em vez de Wayland. Use `g_getenv("GDK_BACKEND")` para verificar o backend em uso.

**Solução**:

```c
#include <gtk/gtk.h>
#include <stdlib.h>

static void show_error_dialog() {
    GtkWidget *dialog = gtk_message_dialog_new(NULL,
        GTK_DIALOG_MODAL,
        GTK_MESSAGE_ERROR,
        GTK_BUTTONS_CLOSE,
        "Este aplicativo requer Wayland. Execute com GDK_BACKEND=wayland");
    
    gtk_dialog_run(GTK_DIALOG(dialog));
    gtk_widget_destroy(dialog);
}

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);
    
    const gchar *backend = g_getenv("GDK_BACKEND");
    if (!backend || g_strcmp0(backend, "wayland") != 0) {
        show_error_dialog();
        return 1;
    }
    
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Wayland Check");
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    gtk_widget_show_all(window);
    
    gtk_main();
    return 0;
}
```

Compile e teste com:
```bash
# Teste falha no X11
GDK_BACKEND=x11 ./wayland_check

# Teste sucesso no Wayland
GDK_BACKEND=wayland ./wayland_check
```