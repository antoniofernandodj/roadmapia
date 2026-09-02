## Dicas para migrar de X11 para Wayland

Um terminal aberto no X11 mostra um problema clássico quando tentamos arrastar a janela rapidamente:

```bash
$ xwininfo -tree -root | grep Terminal
0x800003 "Terminal": ("gnome-terminal-server" "Gnome-terminal")  100x200+300+400
```

Ao mover a janela, o conteúdo fica borrado até o repaint completo. No Wayland, cada aplicativo controla seu próprio buffer, eliminando esse problema - mas a migração requer ajustes.

### 1. Verificando dependências do X11

Muitos aplicativos ainda usam bibliotecas específicas do X11. Identifique-os com:

```bash
$ ldd /usr/bin/firefox | grep -i xlib
libX11.so.6 => /usr/lib/x86_64-linux-gnu/libX11.so.6 (0x00007f8c3a200000)
```

Para esses casos, o XWayland entra como ponte. Ative-o no GNOME com:

```bash
$ gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
```

### 2. Configurando o ambiente Wayland

Crie um arquivo `~/.config/environment.d/wayland.conf` com:

```ini
CLUTTER_BACKEND=wayland
GDK_BACKEND=wayland,x11
QT_QPA_PLATFORM=wayland-egl
SDL_VIDEODRIVER=wayland
```

Isso força toolkits gráficos a priorizarem o backend Wayland. Um erro comum aparece quando faltam variáveis:

```
Gdk-ERROR **: 15:43:22.153: The Wayland connection experienced a fatal error: No such file or directory
```

Corrija garantindo que a sessão Wayland está ativa com `echo $XDG_SESSION_TYPE`.

### 3. Gerenciamento de janelas e atalhos

No X11, ferramentas como `wmctrl` controlam janelas diretamente:

```bash
$ wmctrl -l
0x02c00003  0 mypc Firefox
```

No Wayland, cada compositor implementa suas próprias APIs. No GNOME, use:

```bash
$ busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Main.overview.show();'
```

### 4. Aplicativos críticos que precisam de X11

Alguns ainda não migraram completamente. Para o MATLAB:

```bash
$ matlab -softwareopengl
```

Isso força o modo de compatibilidade. A mensagem típica é:

```
Warning: MATLAB is running on a Wayland server. Some graphics features may not work as expected.
```

### 5. Configuração de múltiplos monitores

Enquanto no X11 usávamos `xrandr`:

```bash
$ xrandr --output HDMI-1 --right-of eDP-1
```

No Wayland, cada ambiente tem seu controle. No KDE Plasma:

```bash
$ kscreen-doctor output.1.mode.1920x1080@60 output.2.enable output.2.position.1920,0
```

### 6. Debug e problemas comuns

Ative logs detalhados para identificar falhas:

```bash
$ WAYLAND_DEBUG=1 weston-terminal
[1746314.143]  -> wl_display@1.get_registry(new id wl_registry@2)
```

Erro comum ao misturar backends:

```
Warning: Ignoring XDG_SESSION_TYPE=wayland on Gnome. Use QT_QPA_PLATFORM=wayland to run on Wayland anyway.
```

Corrija garantindo consistência nas variáveis de ambiente.

### Exercício Prático

Migre um aplicativo GTK3 para usar Wayland nativo:

1. Crie um programa mínimo:
```c
#include <gtk/gtk.h>

int main(int argc, char **argv) {
    gtk_init(&argc, &argv);
    GtkWidget *win = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_widget_show(win);
    gtk_main();
    return 0;
}
```

2. Compile e execute com:
```bash
$ gcc `pkg-config --cflags --libs gtk+-3.0` app.c -o app
$ GDK_BACKEND=wayland ./app
```

3. Verifique o sucesso com:
```bash
$ xprop -root | grep GDK_BACKEND
(no output should appear)
```

*Solução*: O programa cria uma janela GTK usando diretamente o backend Wayland. A ausência de saída no `xprop` confirma que não estamos usando X11.