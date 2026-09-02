## Exemplos de integração com toolkits

Um aplicativo GTK4 rodando no Wayland exibe comportamentos distintos do mesmo código no X11. Vamos criar uma janela simples que demonstra estas diferenças, começando com um problema comum: o redimensionamento inadequado no Wayland.

```c
#include <gtk/gtk.h>

static void on_activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Wayland Toolkit Demo");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);

    GtkWidget *button = gtk_button_new_with_label("Clique-me");
    gtk_window_set_child(GTK_WINDOW(window), button);
    
    gtk_window_present(GTK_WINDOW(window));
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("com.example.wayland", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);
    
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    
    return status;
}
```

Compile e execute com:

```bash
gcc `pkg-config --cflags gtk4` -o gtk-wayland gtk-wayland.c `pkg-config --libs gtk4`
GDK_BACKEND=wayland ./gtk-wayland
```

Ao executar no Wayland, você pode notar que:
1. O botão não segue imediatamente o redimensionamento da janela
2. A decoração da janela (bordas, botões) tem estilo diferente
3. O comportamento ao arrastar a janela é mais suave

O erro mais comum aparece quando esquecendo `GDK_BACKEND=wayland`:

```
GTK_DEBUG=interactive gtk-wayland
(gtk-wayland:12345): Gtk-WARNING **: 10:20:30.123: Cannot open display: 
```

Para Qt, a abordagem é similar mas requer configuração diferente. Veja um exemplo mínimo:

```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
    qputenv("QT_QPA_PLATFORM", "wayland");
    QGuiApplication app(argc, argv);
    
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    
    return app.exec();
}
```

Um erro frequente no Qt ocorre quando o compositor Wayland não está ativo:

```
qt.qpa.wayland: Wayland does not support QWindow::requestActivate()
```

Para SDL, a integração exige tratamento explícito de eventos:

```c
#include <SDL2/SDL.h>

int main() {
    SDL_SetHint(SDL_HINT_VIDEODRIVER, "wayland");
    SDL_Init(SDL_INIT_VIDEO);
    
    SDL_Window *window = SDL_CreateWindow("SDL Wayland",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        640, 480, SDL_WINDOW_SHOWN);
    
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);
    
    SDL_Delay(3000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
```

Execute com:

```bash
SDL_VIDEODRIVER=wayland ./sdl-wayland
```

Um problema típico aparece quando há conflito de backends:

```
SDL ERROR: No available video device
```

**Exercício:** Modifique o exemplo GTK para adicionar um segundo botão que altera seu texto quando clicado, demonstrando o tratamento de eventos no Wayland. Observe como os eventos são processados diferentemente no Wayland versus X11.

**Solução comentada:**

```c
static void on_button_clicked(GtkButton *btn, gpointer data) {
    static int count = 0;
    gtk_button_set_label(btn, count++ % 2 ? "Clique-me" : "Clicado!");
}

static void on_activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Eventos Wayland");
    
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6);
    GtkWidget *btn1 = gtk_button_new_with_label("Botão 1");
    GtkWidget *btn2 = gtk_button_new_with_label("Botão 2");
    
    g_signal_connect(btn1, "clicked", G_CALLBACK(on_button_clicked), NULL);
    g_signal_connect(btn2, "clicked", G_CALLBACK(on_button_clicked), NULL);
    
    gtk_box_append(GTK_BOX(box), btn1);
    gtk_box_append(GTK_BOX(box), btn2);
    gtk_window_set_child(GTK_WINDOW(window), box);
    
    gtk_window_present(GTK_WINDOW(window));
}
```

No Wayland, você notará:
1. O feedback visual do clique é mais consistente
2. Não há atrasos perceptíveis entre o clique e a atualização
3. O foco entre janelas se comporta diferentemente