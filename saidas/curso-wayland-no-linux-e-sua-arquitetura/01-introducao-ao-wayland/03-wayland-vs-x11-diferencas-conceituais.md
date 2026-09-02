## Wayland vs. X11: diferenças conceituais

Wayland e X11 representam duas abordagens distintas para gerenciar gráficos em sistemas Linux. Enquanto o X11 é um servidor gráfico completo, com décadas de evolução e complexidade, o Wayland é um protocolo minimalista projetado para ser mais eficiente e moderno. Para entender essas diferenças, é essencial comparar como cada um lida com tarefas fundamentais, como renderização, comunicação entre aplicativos e composição de frames.

### Renderização e buffers

No X11, o servidor é responsável por desenhar tudo na tela. Quando um aplicativo deseja exibir algo, ele envia comandos de desenho ao servidor X, que então renderiza o conteúdo diretamente no framebuffer. Isso cria uma camada adicional de complexidade, já que o servidor X precisa gerenciar múltiplos aplicativos simultaneamente, coordenando suas operações de desenho.

Já no Wayland, cada aplicativo é responsável por renderizar seu próprio conteúdo em um buffer. O compositor Wayland apenas coleta esses buffers e os combina para formar a imagem final. Isso elimina a necessidade de um servidor centralizado para gerenciar desenhos, reduzindo a sobrecarga e melhorando o desempenho.

Por exemplo, considere um aplicativo que desenha uma janela simples. No X11, o código pode parecer assim:

```c
#include <X11/Xlib.h>

int main() {
    Display *display = XOpenDisplay(NULL);
    Window window = XCreateSimpleWindow(display, RootWindow(display, 0), 0, 0, 200, 200, 1, BlackPixel(display, 0), WhitePixel(display, 0));
    XMapWindow(display, window);
    XFlush(display);
    sleep(5);
    return 0;
}
```

No Wayland, o aplicativo cria seu próprio buffer e o envia ao compositor:

```c
#include <wayland-client.h>

int main() {
    struct wl_display *display = wl_display_connect(NULL);
    struct wl_compositor *compositor = wl_compositor_create(display);
    struct wl_surface *surface = wl_compositor_create_surface(compositor);
    // Renderiza o conteúdo no buffer
    wl_surface_commit(surface);
    wl_display_roundtrip(display);
    sleep(5);
    return 0;
}
```

A diferença é clara: no X11, o servidor lida com o desenho, enquanto no Wayland, o aplicativo é responsável por isso.

### Comunicação entre aplicativos

No X11, a comunicação entre aplicativos é feita através do próprio servidor X. Isso permite funcionalidades como copiar e colar entre janelas ou arrastar e soltar arquivos. No entanto, essa abordagem também introduz complexidade e pode levar a problemas de segurança, já que o servidor X precisa ter acesso a todas as operações gráficas.

Wayland, por outro lado, não possui um mecanismo centralizado para comunicação entre aplicativos. Em vez disso, ele depende de protocolos extras, como `wl_data_device`, para implementar funcionalidades como copiar e colar. Isso torna o sistema mais modular e seguro, mas também exige que os aplicativos sigam padrões específicos para interoperar corretamente.

### Composição de frames

No X11, o servidor X desenha diretamente no framebuffer, sem suporte nativo para composição. Para adicionar efeitos como transparência ou animações, é necessário usar um compositor externo, como Compiz ou Xfwm. Isso pode levar a problemas de sincronização e desempenho, especialmente em hardware mais antigo.

Wayland foi projetado com composição em mente. O compositor Wayland é responsável por combinar os buffers de todos os aplicativos e aplicar efeitos visuais. Isso garante que a composição seja feita de maneira eficiente e consistente, sem a necessidade de soluções externas.

Por exemplo, ao mover uma janela no X11, o servidor X precisa redesenhar toda a região afetada, o que pode ser lento e causar flickering. No Wayland, o compositor apenas reposiciona o buffer existente, resultando em uma animação suave e rápida.

### Segurança

Uma das maiores vantagens do Wayland em relação ao X11 é a segurança. No X11, qualquer aplicativo pode monitorar ou interferir nas ações de outros aplicativos. Isso ocorre porque o servidor X permite que os aplicativos acessem diretamente os recursos gráficos, sem controle granular. Um aplicativo malicioso pode capturar keystrokes, tirar screenshots ou manipular janelas de outros programas.

Wayland resolve esse problema isolando os aplicativos. Cada aplicativo só pode acessar seus próprios buffers e recursos gráficos, sem capacidade de interferir nos outros. Isso torna o sistema mais seguro, especialmente em ambientes multiusuário ou em dispositivos móveis.

### Exercício prático

Para experimentar essas diferenças, execute um aplicativo simples em ambos os ambientes e observe o comportamento. Por exemplo, abra um terminal em uma sessão X11 e em uma sessão Wayland. Tente mover a janela rapidamente ou redimensioná-la. No X11, você pode notar algum atraso ou flickering, enquanto no Wayland a experiência deve ser mais suave.

**Solução:** A diferença ocorre porque o X11 redesenha a janela a cada movimento, enquanto o Wayland apenas reposiciona o buffer existente. Isso ilustra como a arquitetura do Wayland é mais eficiente para tarefas gráficas modernas.