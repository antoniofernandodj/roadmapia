## Monitorando recursos em Wayland

Quando você migra do X11 para o Wayland, uma das primeiras diferenças é a ausência do `xrandr` para monitorar displays e do `xprop` para inspecionar janelas. No ecossistema Wayland, cada compositor oferece suas próprias ferramentas, mas há padrões emergentes que todo usuário deve conhecer.

### Monitorando displays com wlr-randr

Para ambientes baseados em wlroots (como Sway), o `wlr-randr` é o substituto direto do `xrandr`:

```bash
wlr-randr
```

A saída típica mostra:

```
Screen 0:
  DP-1: 1920x1080 @ 60Hz
    Physical size: 530x300mm
    Enabled: yes
    Position: 0,0
    Scale: 1.0
    Transform: normal
```

Um erro comum é tentar usar o `wlr-randr` no GNOME ou KDE, resultando em:

```
error: Failed to connect to Wayland display: Protocol error
```

A solução é usar as ferramentas específicas do compositor:
- GNOME: `gsettings` ou interface gráfica
- KDE: `kscreen-doctor`

### Inspecionando janelas com wayland-info

Enquanto no X11 usávamos `xwininfo`, no Wayland podemos usar o `wayland-info` (do pacote `wayland-utils`):

```bash
wayland-info -v
```

Isso mostra todos os globals disponíveis no protocolo Wayland:

```
interface: 'wl_compositor', version: 4
interface: 'wl_shm', version: 1
interface: 'wl_output', version: 3
[...]
```

Para detalhes específicos de uma aplicação, use o `weston-info` (mesmo fora do Weston):

```bash
WAYLAND_DEBUG=1 glxgears
```

Isso produzirá um log detalhado de todas as chamadas Wayland:

```
[123456.789]  -> wl_display@1.get_registry(new id wl_registry@2)
[123456.790]  -> wl_display@1.sync(new id wl_callback@3)
```

### Monitoramento de desempenho

O `weston-simple-egl` é uma ferramenta útil para testar a aceleração gráfica:

```bash
weston-simple-egl -f
```

Pressione `f` para alternar entre fullscreen e windowed. A saída mostra:

```
FPS: 59.92
Frame time: 16.69 ms
```

Para problemas de desempenho, verifique os drivers primeiro:

```bash
glxinfo | grep "OpenGL renderer"
```

### Monitoramento de recursos com D-Bus

Muitos compositors expõem informações via D-Bus. Para o GNOME:

```bash
gdbus introspect --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig
```

Isso revela todas as propriedades disponíveis:

```
node /org/gnome/Mutter/DisplayConfig {
  interface org.gnome.Mutter.DisplayConfig {
    methods:
      ApplyConfiguration(in  u serial,
                         in  a{sv} state);
      GetCurrentState(out u serial,
                     out a{sv} state);
    properties:
  };
};
```

### Exercício: Criando um monitor de recursos básico

Vamos criar um script que monitora displays e janelas:

```python
#!/usr/bin/env python3
import subprocess

def get_displays():
    try:
        output = subprocess.check_output(["wlr-randr"], stderr=subprocess.PIPE)
        return output.decode()
    except subprocess.CalledProcessError:
        return "Compositor não suporta wlr-randr"

print("=== Displays ===")
print(get_displays())

print("\n=== Wayland Interfaces ===")
print(subprocess.check_output(["wayland-info"]).decode())
```

Salve como `wayland-monitor.py`, torne executável (`chmod +x wayland-monitor.py`) e execute. A saída deve mostrar seus displays e interfaces Wayland disponíveis.