## Compatibilidade XWayland

Um aplicativo desenvolvido para Xorg tentando rodar no Wayland exibe erros como:

```
Error: Unable to open X display
```

Isso ocorre porque o Wayland não implementa o protocolo X11. A solução é o XWayland, um servidor X11 que opera como cliente do compositor Wayland, traduzindo chamadas X11 para o protocolo Wayland.

### Como o XWayland funciona

Quando um aplicativo X11 é iniciado em uma sessão Wayland:

1. O compositor Wayland (GNOME, KWin, etc.) inicia o XWayland como um processo separado
2. XWayland cria um display X11 virtual (geralmente `:1`)
3. O aplicativo X11 se conecta a esse display
4. XWayland converte:
   - Janelas X11 em surfaces Wayland
   - Eventos de entrada (teclado/mouse) do Wayland para eventos X11
   - Requisições de redesenho para buffers compartilhados

### Verificando o XWayland em ação

Para confirmar se o XWayland está ativo:

```bash
pgrep -a Xwayland
```

Saída típica:
```
1234 /usr/bin/Xwayland :1 -rootless -terminate -accessx -core -listen 4 -listen 5 -displayfd 6
```

Este comando mostra que o XWayland está rodando no display `:1` no modo rootless (integrado ao compositor).

### Configurando aplicativos específicos

Para forçar um aplicativo a usar o XWayland no GNOME:

1. Localize o arquivo `.desktop`:
   ```bash
   locate firefox.desktop | grep /usr
   ```

2. Edite a cópia local (não modifique os arquivos do sistema):
   ```bash
   cp /usr/share/applications/firefox.desktop ~/.local/share/applications/
   nano ~/.local/share/applications/firefox.desktop
   ```

3. Adicione esta linha no arquivo:
   ```
   Exec=env GDK_BACKEND=x11 firefox %u
   ```

No KDE Plasma, use:

```
Exec=env QT_QPA_PLATFORM=xcb firefox %u
```

### Problemas comuns e soluções

**Problema 1**: Aplicativo abre em branco ou congela
```bash
error: failed to create drawable
```

**Solução**: Forçar aceleração por software:
```bash
env LIBGL_ALWAYS_SOFTWARE=1 gambas3
```

**Problema 2**: Área de transferência não funciona
```bash
Warning: Unable to copy selection to PRIMARY
```

**Solução**: Use o `wl-clipboard` como intermediário:
```bash
sudo apt install wl-clipboard
```

### Monitorando aplicativos XWayland

Para listar todos os aplicativos usando XWayland:

```bash
xlsclients -display :1
```

Saída exemplo:
```
firefox  Firefox Web Browser
gimp     GNU Image Manipulation Program
```

### Exercício Prático

1. Inicie o GIMP (um aplicativo X11) em sua sessão Wayland
2. Identifique seu processo XWayland com `pgrep -a Xwayland`
3. Force o GIMP a usar aceleração por software
4. Verifique se ele aparece na lista do `xlsclients`

**Solução comentada**:

```bash
# 1. Iniciar o GIMP
gimp &

# 2. Identificar o XWayland
pgrep -a Xwayland  # Anote o display (e.g., :1)

# 3. Forçar aceleração por software
killall gimp
env LIBGL_ALWAYS_SOFTWARE=1 gimp &

# 4. Verificar no XWayland
xlsclients -display :1 | grep gimp
```

A saída deve mostrar o GIMP na lista de clientes XWayland, confirmando que está funcionando através da camada de compatibilidade.