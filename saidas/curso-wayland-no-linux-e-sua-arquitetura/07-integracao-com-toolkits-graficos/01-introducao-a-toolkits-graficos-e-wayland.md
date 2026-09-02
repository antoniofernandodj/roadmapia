## Introdução a toolkits gráficos e Wayland

Um aplicativo gráfico precisa desenhar janelas, botões e menus - mas escrever isso do zero para cada programa seria impraticável. É aí que entram os toolkits gráficos, bibliotecas que fornecem esses elementos prontos. No mundo Wayland, essa relação é mais complexa que no X11, porque o protocolo exige que os toolkits assumam responsabilidades que antes eram do servidor.

Veja o que acontece quando tentamos criar uma janela simples sem toolkit no Wayland:

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Erro ao conectar ao Wayland\n");
        return 1;
    }
    
    // E agora? Como criamos uma janela?
    // Não há funções diretas no protocolo básico
    wl_display_disconnect(display);
    return 0;
}
```

A saída mostra que o problema não é a conexão (que funciona), mas a falta de abstrações para criar interfaces gráficas. O protocolo Wayland puro fornece apenas comunicação, não widgets.

É aqui que toolkits como GTK e Qt entram em cena. Eles implementam o que chamamos de "client-side decorations" - o próprio aplicativo desenha suas bordas e controles de janela, não o compositor. Compare com o X11, onde o gerenciador de janelas cuidava disso.

Quando usamos um toolkit com Wayland, o fluxo muda:

1. O toolkit registra interfaces Wayland adicionais (como xdg-shell)
2. Implementa os protocolos necessários para desenho e interação
3. Gerencia buffers de composição diretamente
4. Cuida da comunicação assíncrona com o compositor

Vamos ver um exemplo prático com GTK4 (instalável via `sudo apt install libgtk-4-dev`):

```c
#include <gtk/gtk.h>

static void activate(GtkApplication* app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Wayland Toolkit Demo");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);
    gtk_widget_show(window);
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("com.example.wayland", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
```

Compile com:
```bash
gcc `pkg-config --cflags gtk4` gtk_wayland.c -o gtk_wayland `pkg-config --libs gtk4`
```

A saída será uma janela nativa no Wayland, mesmo que não tenhamos escrito nenhum código específico do protocolo. O toolkit abstraiu:

- Criação de surfaces Wayland
- Gerenciamento de eventos de entrada
- Sincronização com o compositor
- Desenho de client-side decorations

Um erro comum é esquecer de setar a variável `GDK_BACKEND=wayland` ao rodar aplicativos GTK em ambientes mistos (X11/Wayland). Sem isso, você pode ver:

```
(gtk_wayland:12345): Gtk-WARNING **: cannot open display: 
```

A correção é simples:

```bash
GDK_BACKEND=wayland ./gtk_wayland
```

Os toolkits modernos implementam várias extensões Wayland para melhor integração:

| Protocolo          | Função                            | Toolkit Support |
|--------------------|-----------------------------------|-----------------|
| xdg-shell         | Gerenciamento básico de janelas  | GTK, Qt, EFL    |
| idle-inhibit      | Prevenir suspensão                | Qt, GTK         |
| pointer-constraints | Limitar movimento do mouse      | GTK             |
| primary-selection | Área de transferência            | Qt              |

**Exercício**: Modifique o exemplo GTK para criar um botão que, quando clicado, exibe "Funcionou no Wayland!" no terminal. Depois verifique se está realmente usando Wayland com:

```bash
echo $XDG_SESSION_TYPE
```

**Solução**:

```c
#include <gtk/gtk.h>

static void button_clicked(GtkWidget *widget, gpointer data) {
    g_print("Funcionou no Wayland!\n");
}

static void activate(GtkApplication* app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    GtkWidget *button = gtk_button_new_with_label("Clique aqui");
    
    g_signal_connect(button, "clicked", G_CALLBACK(button_clicked), NULL);
    
    gtk_window_set_title(GTK_WINDOW(window), "Wayland Toolkit Demo");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);
    gtk_window_set_child(GTK_WINDOW(window), button);
    gtk_widget_show(window);
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("com.example.wayland", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
```