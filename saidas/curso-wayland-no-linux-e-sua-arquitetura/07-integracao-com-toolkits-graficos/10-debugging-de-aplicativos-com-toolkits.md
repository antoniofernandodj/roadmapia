## Debugging de aplicativos com toolkits

Quando um aplicativo gráfico falha silenciosamente no Wayland, o primeiro passo é identificar se o problema está no toolkit ou na integração com o protocolo. Vamos debugar um caso real onde um aplicativo GTK4 não exibe janelas no ambiente Wayland:

```c
// gtk4_bug.c
#include <gtk/gtk.h>

static void activate(GtkApplication* app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Wayland Debug"); // Falha silenciosa aqui
    gtk_window_present(GTK_WINDOW(window)); // Nenhuma janela aparece
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("org.example.debug", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    return g_application_run(G_APPLICATION(app), argc, argv);
}
```

Compile com:
```bash
gcc gtk4_bug.c -o gtk4bug `pkg-config --cflags --libs gtk4`
```

O erro não mostra mensagens - o processo simplesmente termina. Para diagnosticar, usaremos duas ferramentas essenciais:

1. **GDK_DEBUG=backend** revela a seleção do backend gráfico:
```bash
GDK_DEBUG=backend ./gtk4bug
```
Saída esperada quando falha:
```
GTK_DEBUG_BACKEND: Using 'wayland' backend
```

2. **WAYLAND_DEBUG=1** mostra a comunicação protocolo Wayland:
```bash
WAYLAND_DEBUG=1 ./gtk4bug 2> wayland.log
```

Analisando wayland.log, encontramos:
```
[1376423.234]  -> xdg_wm_base@28: error 1: xdg_wm_base not bound
[1376423.235]  -> wl_display@1: error 0: invalid object 3
```

Isso indica que o protocolo xdg_wm_base (parte do xdg-shell) não está disponível. A solução é forçar um backend viável ou verificar o compositor:

```bash
GDK_BACKEND=x11 ./gtk4bug  # Funciona no X11 como fallback
```

Para debugar problemas de protocolo no Qt, o método é similar:

```bash
QT_LOGGING_RULES="qt.qpa.*=true" QT_QPA_PLATFORM=wayland ./qtapp
```

Isso revelará erros como:
```
qt.qpa.wayland: No shell extension named 'xdg-shell' supported
```

Cada toolkit tem variáveis específicas para debug:

| Toolkit  | Variável de Debug            | Foco                       |
|----------|-------------------------------|----------------------------|
| GTK      | GDK_DEBUG=backend,settings    | Backend e configurações    |
| Qt       | QT_LOGGING_RULES="qt.qpa.*=true" | Plugins de plataforma      |
| SDL      | SDL_VIDEODRIVER=wayland -v     | Driver de vídeo            |
| EFL      | ELM_ENGINE_LOG=1              | Mecanismo de renderização  |

**Erro comum:** esquecer que Wayland exige tratamento explícito de redimensionamento. Este código Clutter falhará:

```c
g_signal_connect(stage, "configure-event", G_CALLBACK(resize_cb), NULL);
```

A mensagem de erro será:
```
Clutter-WARNING **: Wayland backends don't support configure events
```

A correção é usar o sinal `notify::size`:
```c
g_signal_connect(stage, "notify::size", G_CALLBACK(size_changed_cb), NULL);
```

**Exercício:** Um aplicativo SDL não renderiza no Wayland. A saída de `SDL_GetCurrentVideoDriver()` retorna "wayland", mas nada é exibido. Debug usando:
1. `SDL_VIDEODRIVER=wayland -v`
2. `WAYLAND_DEBUG=1`
3. Verifique se o compositor suporta wl_shm

**Solução:** O problema comum é falta de suporte a wl_shm. Modifique a inicialização:
```c
SDL_SetHint(SDL_HINT_VIDEO_WAYLAND_PREFER_LIBDECOR, "0");
SDL_Init(SDL_INIT_VIDEO);
```