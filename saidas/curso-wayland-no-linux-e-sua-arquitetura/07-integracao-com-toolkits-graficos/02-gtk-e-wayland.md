## GTK e Wayland

O GTK (GIMP Toolkit) é um dos toolkits gráficos mais populares para aplicativos Linux, e sua integração com o Wayland é essencial para garantir que aplicativos GTK funcionem corretamente em ambientes modernos. Vamos explorar como o GTK interage com o Wayland, como configurar o ambiente para usar o backend Wayland e como identificar problemas comuns.

### Configurando o GTK para usar Wayland

Por padrão, o GTK tenta detectar o backend gráfico mais apropriado para o ambiente em que está sendo executado. No entanto, você pode forçar o uso do backend Wayland definindo a variável de ambiente `GDK_BACKEND` para `wayland`. Isso é útil quando você deseja garantir que o aplicativo seja executado no Wayland, mesmo que o ambiente padrão seja X11.

```bash
GDK_BACKEND=wayland gtk4-demo
```

Se o backend Wayland não estiver disponível ou configurado corretamente, você verá uma mensagem de erro como:

```
Gtk-WARNING **: Cannot open display: wayland-0
```

Isso indica que o GTK não conseguiu encontrar um servidor Wayland em execução. Para resolver isso, certifique-se de que o ambiente gráfico esteja usando Wayland (por exemplo, GNOME no Wayland) e que o pacote `libgtk-4-wayland` esteja instalado.

### Protocolos Wayland suportados pelo GTK

O GTK implementa vários protocolos Wayland, incluindo `xdg-shell`, que é essencial para a criação e gerenciamento de janelas. Além disso, o GTK suporta protocolos como `zwp_pointer_gestures_v1` para gestos de toque e `zwp_tablet_v2` para dispositivos de mesa digitalizadora.

Para verificar quais protocolos estão sendo usados por um aplicativo GTK, você pode usar a ferramenta `wayland-debug`:

```bash
WAYLAND_DEBUG=1 GDK_BACKEND=wayland gtk4-demo
```

Isso exibirá uma lista de todas as chamadas de protocolo Wayland feitas pelo aplicativo, permitindo que você identifique problemas de compatibilidade ou implementação.

### Problemas comuns e soluções

Um problema comum ao migrar aplicativos GTK para Wayland é o uso de recursos específicos do X11, como `X11/Xlib.h` ou `X11/extensions/Xrandr.h`. Esses recursos não estão disponíveis no Wayland, e tentar usá-los resultará em erros de compilação ou execução. Para resolver isso, substitua as chamadas X11 por equivalentes Wayland ou use abstrações fornecidas pelo GTK.

Outro problema comum é a falta de suporte para decorações de janela no lado do servidor (server-side decorations). No Wayland, as decorações de janela são gerenciadas pelo cliente (client-side decorations), o que pode exigir ajustes no layout e no comportamento da janela do aplicativo.

### Exemplo prático: Criando uma janela simples com GTK e Wayland

Vamos criar uma janela simples usando GTK 4 e garantir que ela seja executada no backend Wayland. Primeiro, crie um arquivo `main.c` com o seguinte conteúdo:

```c
#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window;

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "GTK Wayland Example");
    gtk_window_set_default_size(GTK_WINDOW(window), 200, 200);
    gtk_widget_show(window);
}

int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.example.GtkWayland", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
```

Compile o programa com:

```bash
gcc `pkg-config --cflags gtk4` -o gtk-wayland-example main.c `pkg-config --libs gtk4`
```

Execute o programa no backend Wayland:

```bash
GDK_BACKEND=wayland ./gtk-wayland-example
```

Se tudo estiver configurado corretamente, você verá uma janela simples com o título "GTK Wayland Example".

### Exercício: Identificando problemas de compatibilidade

Modifique o exemplo anterior para incluir uma chamada a uma função X11, como `XOpenDisplay`, e tente compilar e executar o programa. Observe a mensagem de erro e ajuste o código para usar uma alternativa Wayland ou GTK.

**Solução:**

```c
#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window;

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "GTK Wayland Example");
    gtk_window_set_default_size(GTK_WINDOW(window), 200, 200);
    gtk_widget_show(window);
}

int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.example.GtkWayland", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
```

Ao tentar incluir `XOpenDisplay`, você verá um erro de compilação como:

```
error: ‘XOpenDisplay’ undeclared (first use in this function)
```

Isso ocorre porque `XOpenDisplay` não está disponível no Wayland. Para resolver isso, remova a chamada X11 e use apenas as funções GTK para criar e gerenciar janelas.