## Aplicativos Wayland em containers

Executar aplicativos gráficos Wayland dentro de containers Linux apresenta desafios únicos devido à natureza isolada dos containers e à arquitetura cliente-servidor do Wayland. Vamos resolver o problema concreto de exibir um aplicativo GTK4 simples em um container Podman, com acesso completo à aceleração gráfica.

**O problema fundamental**: Containers não têm acesso direto ao socket Wayland (`$XDG_RUNTIME_DIR/wayland-0`) nem aos dispositivos DRM/DRI necessários para renderização acelerada. Tentar executar um aplicativo Wayland em um container comum resulta em:

```bash
Error: Failed to connect to Wayland display: No such file or directory
```

A solução envolve três componentes essenciais:
1. Compartilhamento do socket Wayland
2. Acesso aos dispositivos de vídeo
3. Configuração correta de variáveis de ambiente

### Configuração básica do container

Crie um Dockerfile para nosso aplicativo de exemplo:

```dockerfile
FROM docker.io/fedora:latest
RUN dnf install -y gtk4-devel mesa-dri-drivers
COPY wayland-app /usr/local/bin/
CMD ["wayland-app"]
```

O segredo está na execução do container. Use este comando Podman:

```bash
podman run --rm -it \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
  --volume=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY \
  --device=/dev/dri \
  --env=WAYLAND_DISPLAY \
  --env=XDG_RUNTIME_DIR \
  localhost/wayland-container
```

**O que cada opção faz**:
- `--volume` para o socket Wayland: Mapeia o socket do host para o container
- `--device=/dev/dri`: Dá acesso aos dispositivos de renderização
- Variáveis de ambiente: Garantem que o aplicativo encontre o display correto

### Aplicativo de teste

Crie um simples visualizador GTK4 para validar a configuração (`wayland-app.c`):

```c
#include <gtk/gtk.h>

static void activate(GtkApplication* app, gpointer user_data) {
  GtkWidget *window = gtk_application_window_new(app);
  gtk_window_set_title(GTK_WINDOW(window), "Wayland Container App");
  gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);
  
  GtkWidget *label = gtk_label_new("Running in Wayland container!");
  gtk_window_set_child(GTK_WINDOW(window), label);
  
  gtk_widget_show(window);
}

int main(int argc, char **argv) {
  GtkApplication *app = gtk_application_new("com.example.WaylandContainer", G_APPLICATION_DEFAULT_FLAGS);
  g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
  
  int status = g_application_run(G_APPLICATION(app), argc, argv);
  g_object_unref(app);
  
  return status;
}
```

Compile com:
```bash
gcc wayland-app.c -o wayland-app `pkg-config --cflags --libs gtk4`
```

### Verificação do ambiente

Dentro do container, confirme que tudo está funcionando:

```bash
# Verificar suporte a Wayland
echo $WAYLAND_DISPLAY

# Verificar dispositivos gráficos
ls -l /dev/dri/

# Verificar renderização (execute no container)
glxinfo -B | grep -E "OpenGL|renderer"
```

A saída deve mostrar:
```
OpenGL renderer string: Mesa Intel HD Graphics (TGL GT2)
```

### Erro comum e solução

Se encontrar o erro:
```
GLX: No GLXFBConfig for default depth
```

Significa que o container não tem acesso aos dispositivos DRI. Corrija adicionando:
```bash
--security-opt=label=disable \
--group-add=video
```

### Exercício: Visualizador de imagens em container

Modifique o aplicativo GTK4 para:
1. Aceitar um caminho de imagem como argumento
2. Exibir a imagem centralizada na janela
3. Ajustar o tamanho da janela à imagem (com máximo de 800x600)

**Solução comentada**:

```c
#include <gtk/gtk.h>

static void activate(GtkApplication* app, gpointer user_data) {
  const char *image_path = (char*)user_data;
  
  GtkWidget *window = gtk_application_window_new(app);
  gtk_window_set_title(GTK_WINDOW(window), "Wayland Image Viewer");
  
  GtkWidget *picture = gtk_picture_new_for_filename(image_path);
  
  // Obter dimensões da imagem
  int width, height;
  GdkPixbuf *pixbuf = gdk_pixbuf_new_from_file(image_path, NULL);
  if(pixbuf) {
    width = gdk_pixbuf_get_width(pixbuf);
    height = gdk_pixbuf_get_height(pixbuf);
    g_object_unref(pixbuf);
    
    // Limitar tamanho máximo
    if(width > 800) width = 800;
    if(height > 600) height = 600;
    
    gtk_window_set_default_size(GTK_WINDOW(window), width, height);
  }
  
  gtk_window_set_child(GTK_WINDOW(window), picture);
  gtk_widget_show(window);
}

int main(int argc, char **argv) {
  if(argc < 2) {
    g_printerr("Usage: %s <image-path>\n", argv[0]);
    return 1;
  }
  
  GtkApplication *app = gtk_application_new("com.example.ImageViewer", G_APPLICATION_DEFAULT_FLAGS);
  g_signal_connect_data(app, "activate", G_CALLBACK(activate), argv[1], NULL, 0);
  
  int status = g_application_run(G_APPLICATION(app), argc, argv);
  g_object_unref(app);
  
  return status;
}
```

Para testar:
```bash
podman run --rm -it \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
  --volume=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY \
  --device=/dev/dri \
  --env=WAYLAND_DISPLAY \
  --env=XDG_RUNTIME_DIR \
  --volume=$(pwd)/test-image.jpg:/image.jpg:ro \
  localhost/wayland-container /image.jpg
```