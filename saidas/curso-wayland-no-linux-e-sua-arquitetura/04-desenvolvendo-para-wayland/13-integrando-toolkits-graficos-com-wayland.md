## Integrando toolkits gráficos com Wayland

Desenvolver aplicativos gráficos diretamente com as APIs do Wayland pode ser complexo, especialmente quando se trata de criar interfaces completas com widgets, menus e controles interativos. É aqui que os **toolkits gráficos** entram em cena, abstraindo a complexidade do Wayland e oferecendo APIs de alto nível para criar interfaces gráficas rapidamente. Dois dos toolkits mais populares são o **GTK** e o **Qt**, ambos com suporte nativo ao Wayland. Este trecho explora como integrar esses toolkits em um projeto Wayland, desde a configuração inicial até a implementação de uma janela básica.

### GTK e Wayland

O GTK (GIMP Toolkit) é um toolkit gráfico amplamente utilizado em aplicativos Linux, como o GNOME. Ele suporta Wayland nativamente desde a versão 3.10, simplificando o desenvolvimento de aplicativos gráficos.

Para começar, vamos criar uma janela simples usando GTK e Wayland. Primeiro, instale as dependências necessárias:

```bash
sudo apt install libgtk-3-dev
```

Agora, crie um arquivo `main.c` com o seguinte conteúdo:

```c
#include <gtk/gtk.h>

static void activate(GtkApplication* app, gpointer user_data) {
    GtkWidget *window;

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Janela GTK no Wayland");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 200);
    gtk_widget_show_all(window);
}

int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.example.GtkApp", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
```

Compile o programa com:

```bash
gcc `pkg-config --cflags gtk+-3.0` -o gtk-wayland main.c `pkg-config --libs gtk+-3.0`
```

Execute o programa em um ambiente Wayland:

```bash
WAYLAND_DISPLAY=wayland-0 ./gtk-wayland
```

Você verá uma janela GTK simples aparecer. O GTK gerencia automaticamente a conexão com o compositor Wayland, a criação de superfícies e o loop de eventos.

### Qt e Wayland

O Qt é outro toolkit gráfico poderoso, usado em aplicativos como o KDE Plasma. Ele também oferece suporte nativo ao Wayland, permitindo a criação de interfaces gráficas robustas.

Para criar uma janela básica com Qt e Wayland, instale as dependências necessárias:

```bash
sudo apt install qt5-default qtwayland5
```

Agora, crie um arquivo `main.cpp` com o seguinte conteúdo:

```cpp
#include <QApplication>
#include <QMainWindow>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QMainWindow window;

    window.setWindowTitle("Janela Qt no Wayland");
    window.resize(400, 200);
    window.show();

    return app.exec();
}
```

Compile o programa com:

```bash
qmake -project
qmake
make
```

Execute o programa em um ambiente Wayland:

```bash
QT_QPA_PLATFORM=wayland ./qt-wayland
```

Assim como o GTK, o Qt gerencia automaticamente a integração com o Wayland, simplificando o desenvolvimento.

### Comparando GTK e Qt

Ambos os toolkits oferecem suporte nativo ao Wayland, mas existem diferenças significativas:

- **GTK**: Mais integrado ao GNOME, com uma abordagem mais minimalista. Ideal para aplicativos que seguem as diretrizes de design do GNOME.
- **Qt**: Mais flexível e poderoso, com suporte a uma ampla gama de funcionalidades. Ideal para aplicativos complexos e multiplataforma.

### Erros comuns e como corrigi-los

Um erro comum ao usar toolkits gráficos com Wayland é esquecer de definir a plataforma correta. Por exemplo, se você tentar executar um aplicativo Qt sem definir `QT_QPA_PLATFORM=wayland`, ele pode tentar usar o X11 por padrão, resultando em falhas ou comportamento inesperado.

Outro erro é não verificar se o toolkit está realmente usando o Wayland. Você pode verificar isso executando o aplicativo com `WAYLAND_DEBUG=1` e observando as mensagens de debug.

### Exercício: Criando uma janela com botão

Para consolidar o aprendizado, vamos criar uma janela simples com um botão que exibe uma mensagem quando clicado, usando GTK.

Crie um arquivo `button.c` com o seguinte conteúdo:

```c
#include <gtk/gtk.h>

static void print_hello(GtkWidget *widget, gpointer data) {
    g_print("Botão clicado!\n");
}

int main(int argc, char **argv) {
    GtkWidget *window;
    GtkWidget *button;

    gtk_init(&argc, &argv);

    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Janela com Botão");
    gtk_window_set_default_size(GTK_WINDOW(window), 200, 100);
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    button = gtk_button_new_with_label("Clique aqui");
    g_signal_connect(button, "clicked", G_CALLBACK(print_hello), NULL);
    gtk_container_add(GTK_CONTAINER(window), button);

    gtk_widget_show_all(window);

    gtk_main();

    return 0;
}
```

Compile e execute o programa:

```bash
gcc `pkg-config --cflags gtk+-3.0` -o button button.c `pkg-config --libs gtk+-3.0`
WAYLAND_DISPLAY=wayland-0 ./button
```

Clique no botão e veja a mensagem "Botão clicado!" aparecer no terminal.

### Conclusão

Integrar toolkits gráficos como GTK e Qt com Wayland simplifica o desenvolvimento de aplicativos gráficos, abstraindo a complexidade do protocolo Wayland. Ambos os toolkits oferecem suporte nativo ao Wayland, permitindo a criação de interfaces gráficas robustas e responsivas. Ao entender como esses toolkits funcionam em conjunto com o Wayland, você pode desenvolver aplicativos gráficos modernos e eficientes.