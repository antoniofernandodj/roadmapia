## Problemas comuns com toolkits

Um aplicativo GTK que funciona perfeitamente no X11 pode falhar silenciosamente no Wayland com apenas um log obscuro:

```bash
(gtk-example:12345): Gtk-WARNING **: 15:20:01.123: cannot open display: wayland-0
```

O problema real? O toolkit está tentando usar recursos específicos do X11. Vamos examinar três categorias de problemas que surgem quando toolkits interagem com Wayland.

### 1. Decorations e gerenciamento de janelas

No X11, os toolkits delegavam bordas e controles de janela ao gerenciador (server-side decorations). Wayland exige client-side decorations (CSD), onde o próprio aplicativo desenha seus controles. 

Um exemplo concreto no Qt:

```cpp
// Código problemático (assume X11)
MainWindow::MainWindow() {
    setWindowFlags(Qt::FramelessWindowHint);  // Funciona no X11
    // ... 
}
```

No Wayland, isso causa:
- Janela sem controles de fechar/maximizar
- Comportamento inconsistente entre compositores
- Logs como: "qt.qpa.wayland: Unsupported window flag 0x800"

Solução base:
```cpp
// Modo compatível
MainWindow::MainWindow() {
    if (QGuiApplication::platformName() == "wayland") {
        // Usar decorações nativas do toolkit
    } else {
        setWindowFlags(Qt::FramelessWindowHint);
    }
}
```

### 2. Protocolos ausentes ou incompletos

Toolkits antigos assumem a existência de extensões X11 como XDND (drag-and-drop). No Wayland, cada protocolo precisa ser explicitamente negociado via interfaces como `xdg-shell`.

Exemplo com SDL2:
```c
SDL_Init(SDL_INIT_VIDEO);
SDL_Window* window = SDL_CreateWindow("Test", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_RESIZABLE);
```

Erro típico:
```
[SDL] [wayland] Missing required xdg-shell interface
```

Solução mínima:
```bash
export SDL_VIDEODRIVER=wayland
```

Mas o problema real exige verificação de suporte:
```c
if (SDL_GetCurrentVideoDriver() != "wayland") {
    // Usar fallback ou avisar o usuário
}
```

### 3. Aceleração gráfica e renderização

Diferentes toolkits implementam buffers de forma distinta no Wayland. Um exemplo real no Clutter:

```c
ClutterActor *stage = clutter_stage_new();
clutter_actor_set_background_color(stage, CLUTTER_COLOR_Red);
```

Pode falhar com:
```
Clutter-CRITICAL **: clutter_stage_new: assertion 'CLUTTER_IS_MAIN_CONTEXT ()' failed
```

A causa? Ausência do backend Wayland configurado:
```bash
export CLUTTER_BACKEND=wayland
```

### Caso complexo: Mixagem de toolkits

Quando GTK (Wayland nativo) e Qt (via XWayland) coexistirem:

```python
# Aplicativo PyGTK que embute widget Qt
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from PyQt5.QtWidgets import QApplication, QLabel

window = Gtk.Window()
qapp = QApplication([])
label = QLabel("Qt inside GTK")
```

Resultará em:
```
QXcbConnection: Could not connect to display 
Gtk-WARNING: GTK+ module cannot be loaded
```

### Exercício prático

Crie um aplicativo GTK4 mínimo que:
1. Verifica se está rodando sob Wayland
2. Adapta seu comportamento para client-side decorations
3. Exibe um aviso se recursos essenciais estiverem ausentes

Solução comentada:
```python
import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gdk

def on_activate(app):
    win = Gtk.ApplicationWindow(application=app)
    
    # Verificação de ambiente
    display = Gdk.Display.get_default()
    if display.get_name().startswith("wayland"):
        print("Running natively on Wayland")
    else:
        print("Running on X11 or XWayland")
    
    # CSD automático no Wayland
    win.set_title("Wayland-aware App")
    win.present()

app = Gtk.Application()
app.connect('activate', on_activate)
app.run(None)
```