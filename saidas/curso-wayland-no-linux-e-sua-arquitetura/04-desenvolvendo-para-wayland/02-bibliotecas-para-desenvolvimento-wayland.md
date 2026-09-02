## Bibliotecas para desenvolvimento Wayland

Ao desenvolver aplicativos para Wayland, você pode escolher entre várias bibliotecas que facilitam a comunicação com o protocolo Wayland, gerenciamento de janelas, e renderização gráfica. Essas bibliotecas abstraem a complexidade do protocolo bruto, permitindo que você se concentre na lógica do seu aplicativo. Vamos explorar algumas das mais importantes.

### **libwayland-client**

A `libwayland-client` é a biblioteca fundamental para criar clientes Wayland. Ela fornece as funções básicas para estabelecer uma conexão com o compositor, criar objetos Wayland e manipular mensagens. Por exemplo, para criar uma conexão com o compositor, você usa a função `wl_display_connect`:

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    if (!display) {
        fprintf(stderr, "Falha ao conectar ao compositor Wayland.\n");
        return 1;
    }
    printf("Conectado ao compositor Wayland.\n");
    wl_display_disconnect(display);
    return 0;
}
```

Se o compositor não estiver disponível, `wl_display_connect` retornará `NULL`, e você verá a mensagem de erro impressa no terminal.

### **libwayland-server**

Enquanto `libwayland-client` é usada para criar clientes, `libwayland-server` é usada para criar compositores Wayland. Ela permite que você implemente um compositor Wayland, gerenciando clientes, superfícies e eventos. Um exemplo básico de um compositor pode ser encontrado no código-fonte do Weston, o compositor de referência do Wayland.

### **libwayland-egl**

Para aplicativos que precisam de aceleração gráfica via OpenGL, `libwayland-egl` é essencial. Ela fornece uma ponte entre Wayland e EGL (Embedded-System Graphics Library), permitindo que você crie contextos OpenGL e renderize gráficos diretamente em superfícies Wayland. Aqui está um exemplo básico de como criar um contexto EGL em uma superfície Wayland:

```c
#include <wayland-client.h>
#include <wayland-egl.h>
#include <EGL/egl.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_compositor *compositor = ...; // Obtenha o compositor
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    struct wl_egl_window *egl_window = wl_egl_window_create(surface, 800, 600);
    EGLDisplay egl_display = eglGetDisplay((EGLNativeDisplayType)display);
    eglInitialize(egl_display, NULL, NULL);
    EGLConfig config;
    EGLContext context = eglCreateContext(egl_display, config, EGL_NO_CONTEXT, NULL);
    eglMakeCurrent(egl_display, egl_window, egl_window, context);
    printf("Contexto EGL criado com sucesso.\n");
    return 0;
}
```

### **libwayland-cursor**

Para aplicativos que precisam manipular o cursor do mouse, `libwayland-cursor` é a biblioteca certa. Ela permite carregar e exibir cursores personalizados, além de fornecer funcionalidades para manipular a aparência e o comportamento do cursor. Um exemplo simples de como carregar um cursor:

```c
#include <wayland-client.h>
#include <wayland-cursor.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_cursor_theme *theme = wl_cursor_theme_load("default", 24, NULL);
    struct wl_cursor *cursor = wl_cursor_theme_get_cursor(theme, "left_ptr");
    printf("Cursor carregado com sucesso.\n");
    wl_cursor_theme_destroy(theme);
    wl_display_disconnect(display);
    return 0;
}
```

### **wlroots**

`wlroots` é uma biblioteca mais avançada, projetada para criar compositores Wayland modernos e eficientes. Ela abstrai muitas das complexidades de gerenciamento de superfícies, buffers e eventos, permitindo que você crie compositores personalizados com relativa facilidade. A biblioteca é amplamente utilizada em projetos como o Sway, um compositor Wayland compatível com i3.

### **GTK e Qt**

Para aplicativos gráficos mais complexos, você pode integrar Wayland com toolkits gráficos como GTK e Qt. Ambos suportam Wayland nativamente e fornecem APIs de alto nível para criar interfaces gráficas. Por exemplo, um aplicativo GTK simples pode ser criado da seguinte forma:

```c
#include <gtk/gtk.h>

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Aplicativo GTK Wayland");
    gtk_widget_show_all(window);
    gtk_main();
    return 0;
}
```

Compilar e executar este código em um ambiente Wayland resultará em uma janela GTK renderizada diretamente pelo compositor Wayland.

### **Exercício**

Crie um aplicativo Wayland simples que exiba uma janela usando `libwayland-client` e `libwayland-egl`. O aplicativo deve criar um contexto EGL e desenhar um triângulo colorido na tela.

**Solução:**

```c
#include <wayland-client.h>
#include <wayland-egl.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>

const char *vertex_shader_source =
    "attribute vec4 aPosition;\n"
    "void main() {\n"
    "   gl_Position = aPosition;\n"
    "}\n";

const char *fragment_shader_source =
    "precision mediump float;\n"
    "void main() {\n"
    "   gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n"
    "}\n";

GLuint load_shader(GLenum type, const char *source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    return shader;
}

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_compositor *compositor = ...; // Obtenha o compositor
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    struct wl_egl_window *egl_window = wl_egl_window_create(surface, 800, 600);
    EGLDisplay egl_display = eglGetDisplay((EGLNativeDisplayType)display);
    eglInitialize(egl_display, NULL, NULL);
    EGLConfig config;
    EGLContext context = eglCreateContext(egl_display, config, EGL_NO_CONTEXT, NULL);
    eglMakeCurrent(egl_display, egl_window, egl_window, context);

    GLuint vertex_shader = load_shader(GL_VERTEX_SHADER, vertex_shader_source);
    GLuint fragment_shader = load_shader(GL_FRAGMENT_SHADER, fragment_shader_source);
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    glLinkProgram(program);
    glUseProgram(program);

    GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f
    };
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    GLuint aPosition = glGetAttribLocation(program, "aPosition");
    glEnableVertexAttribArray(aPosition);
    glVertexAttribPointer(aPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    eglSwapBuffers(egl_display, egl_window);

    return 0;
}
```

Este código cria uma janela Wayland, inicializa um contexto EGL, compila shaders GLSL, e desenha um triângulo vermelho na tela.