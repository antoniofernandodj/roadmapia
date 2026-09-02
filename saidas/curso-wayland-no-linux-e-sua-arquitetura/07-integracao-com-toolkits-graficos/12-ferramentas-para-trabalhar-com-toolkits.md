## Ferramentas para trabalhar com toolkits

Quando você está desenvolvendo um aplicativo gráfico para Wayland usando toolkits como GTK, Qt ou SDL, precisa de ferramentas específicas para verificar se tudo está funcionando como esperado. Vamos direto aos problemas reais que surgem no desenvolvimento e como resolvê-los com as ferramentas certas.

### Verificando o backend em uso

Um erro comum é o aplicativo estar rodando no backend X11 quando deveria usar Wayland. Para verificar no GTK:

```bash
GDK_BACKEND=wayland gtk3-demo
```

Se a janela abrir normalmente, tudo certo. Mas se aparecer:

```
Gtk-WARNING **: cannot open display: :0
```

Significa que seu ambiente não suporta Wayland nativamente. Nesse caso, você pode forçar o XWayland:

```bash
GDK_BACKEND=x11 gtk3-demo
```

No Qt, a verificação é similar:

```bash
QT_QPA_PLATFORM=wayland qmake -query QT_QPA_PLATFORM_PLUGIN_PATH
```

A saída esperada deve incluir "wayland" no caminho. Se não aparecer, instale os plugins do Qt para Wayland.

### Debugando protocolos Wayland

Quando um elemento gráfico não aparece como esperado, muitas vezes o problema está na implementação dos protocolos Wayland. Ative o modo verbose:

```bash
WAYLAND_DEBUG=1 seu_app
```

Isso mostrará toda a comunicação entre seu aplicativo e o compositor Wayland. Um erro comum é:

```
[17128392.543] error: wl_display@1: error 0: invalid object 42
```

Indicando que seu toolkit tentou acessar um objeto Wayland que já foi destruído. A solução é garantir que todos os recursos sejam liberados na ordem correta.

### Comparando comportamento entre toolkits

Para entender diferenças entre toolkits, crie um exemplo mínimo em cada um:

**GTK:**
```python
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

win = Gtk.Window(title="GTK+Wayland")
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
```

**Qt:**
```python
import sys
from PyQt5.QtWidgets import QApplication, QLabel

app = QApplication(sys.argv)
label = QLabel("Qt+Wayland")
label.show()
sys.exit(app.exec_())
```

Execute cada um com:
```bash
GDK_BACKEND=wayland python3 gtk_example.py
QT_QPA_PLATFORM=wayland python3 qt_example.py
```

Observe como cada toolkit lida com:
- Redimensionamento de janela
- Foco de entrada
- Bordas da janela (client-side decorations)

### Identificando recursos X11 sendo usados

Mesmo no Wayland, toolkits podem tentar usar funções X11. Para detectar:

```bash
strace -e trace=openat seu_app 2>&1 | grep libX11
```

Se aparecerem arquivos como `libX11.so`, seu toolkit está carregando bibliotecas X11. Em GTK, substitua chamadas como `gdk_x11_display_get_xdisplay()` por alternativas Wayland.

### Exercício prático: Debug de um aplicativo GTK

1. Baixe o código de exemplo com problema:
```bash
wget https://exemplo.com/gtk-buggy-app.c
```

2. Compile:
```bash
gcc gtk-buggy-app.c -o app `pkg-config --cflags --libs gtk+-3.0`
```

3. Execute com debug:
```bash
GDK_DEBUG=backend WAYLAND_DEBUG=1 ./app
```

4. Corrija o problema (a saída mostrará que está tentando usar X11):

```c
// Substitua:
gdk_set_allowed_backends("x11");
// Por:
gdk_set_allowed_backends("wayland");
```

5. Verifique a correção:
```bash
GDK_BACKEND=wayland ./app
```

A janela deve aparecer corretamente no Wayland.