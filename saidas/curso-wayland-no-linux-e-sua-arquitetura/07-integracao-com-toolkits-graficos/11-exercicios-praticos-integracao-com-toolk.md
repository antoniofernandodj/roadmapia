## Exercícios práticos: integração com toolkits

Neste trecho, vamos praticar a integração de diferentes toolkits gráficos com o Wayland, focando em problemas comuns e soluções eficazes. Cada exercício aborda um toolkit específico, incluindo GTK, Qt, SDL e EFL, e simula cenários reais de migração e otimização de aplicativos.

### Exercício 1: Migrando uma aplicação GTK para Wayland

Suponha que você tem um aplicativo GTK que foi desenvolvido para X11 e deseja migrar para Wayland. Primeiro, vamos criar uma janela simples com GTK e garantir que ela funcione corretamente no Wayland.

```c
#include <gtk/gtk.h>

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);

    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "GTK Wayland Example");
    gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);

    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    gtk_widget_show_all(window);

    gtk_main();

    return 0;
}
```

Compile e execute o código acima com o backend Wayland:

```bash
export GDK_BACKEND=wayland
gcc `pkg-config --cflags gtk+-3.0` -o gtk_wayland_example gtk_wayland_example.c `pkg-config --libs gtk+-3.0`
./gtk_wayland_example
```

Se tudo estiver configurado corretamente, você verá uma janela GTK renderizada no Wayland. Caso contrário, verifique se o compositor Wayland está em execução e se a variável `GDK_BACKEND` está definida corretamente.

**Problema comum:** Se você tentar usar funções específicas do X11, como `gdk_x11_display_get_xdisplay`, o aplicativo falhará.

**Solução:** Substitua todas as chamadas X11 por alternativas Wayland ou GTK. Por exemplo, use `gdk_display_get_default` em vez de `gdk_x11_display_get_xdisplay`.

### Exercício 2: Criando uma interface Qt com Wayland

Agora, vamos criar uma janela simples com Qt e garantir que ela use o backend Wayland.

```cpp
#include <QApplication>
#include <QWidget>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QWidget window;
    window.setWindowTitle("Qt Wayland Example");
    window.resize(300, 200);
    window.show();

    return app.exec();
}
```

Compile e execute o código acima com o backend Wayland:

```bash
export QT_QPA_PLATFORM=wayland
qmake -project
qmake
make
./qt_wayland_example
```

**Problema comum:** Se o Qt não encontrar o backend Wayland, ele pode tentar usar o X11 por padrão, o que pode causar problemas de compatibilidade.

**Solução:** Verifique se o backend Wayland está disponível com `qmake -query QT_QPA_PLATFORM_PLUGIN_PATH` e certifique-se de que a variável `QT_QPA_PLATFORM` está definida como `wayland`.

### Exercício 3: Integrando SDL com Wayland

SDL é amplamente utilizado em aplicações gráficas e jogos. Vamos criar uma janela simples com SDL e garantir que ela use o backend Wayland.

```c
#include <SDL.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Window *window = SDL_CreateWindow("SDL Wayland Example",
                                          SDL_WINDOWPOS_UNDEFINED,
                                          SDL_WINDOWPOS_UNDEFINED,
                                          300, 200,
                                          SDL_WINDOW_SHOWN);
    if (window == NULL) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    SDL_Event e;
    int quit = 0;
    while (!quit) {
        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_QUIT) {
                quit = 1;
            }
        }
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
```

Compile e execute o código acima com o backend Wayland:

```bash
export SDL_VIDEODRIVER=wayland
gcc `sdl2-config --cflags --libs` -o sdl_wayland_example sdl_wayland_example.c
./sdl_wayland_example
```

**Problema comum:** Se o SDL não encontrar o backend Wayland, ele pode tentar usar o X11 por padrão, o que pode causar problemas de compatibilidade.

**Solução:** Verifique se o backend Wayland está disponível com `SDL_GetCurrentVideoDriver()` e certifique-se de que a variável `SDL_VIDEODRIVER` está definida como `wayland`.

### Exercício 4: Desenvolvendo com EFL e Wayland

EFL (Enlightenment Foundation Libraries) é outro toolkit gráfico que suporta Wayland. Vamos criar uma janela simples com EFL.

```c
#include <Elementary.h>

int main(int argc, char *argv[]) {
    elm_init(argc, argv);

    Evas_Object *win = elm_win_util_standard_add("EFL Wayland Example", "EFL Wayland Example");
    elm_win_autodel_set(win, EINA_TRUE);

    evas_object_resize(win, 300, 200);
    evas_object_show(win);

    elm_run();

    elm_shutdown();

    return 0;
}
```

Compile e execute o código acima com o backend Wayland:

```bash
export ELM_DISPLAY=wayland
gcc `pkg-config --cflags elementary` -o efl_wayland_example efl_wayland_example.c `pkg-config --libs elementary`
./efl_wayland_example
```

**Problema comum:** Se o EFL não encontrar o backend Wayland, ele pode tentar usar o X11 por padrão, o que pode causar problemas de compatibilidade.

**Solução:** Verifique se o backend Wayland está disponível com `ELM_DISPLAY` e certifique-se de que a variável `ELM_DISPLAY` está definida como `wayland`.

### Conclusão

Estes exercícios práticos demonstram como integrar diferentes toolkits gráficos com o Wayland, abordando problemas comuns e soluções eficazes. A migração de aplicativos para Wayland requer atenção especial às diferenças entre X11 e Wayland, especialmente em relação aos protocolos e backends gráficos.