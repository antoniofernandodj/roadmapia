## SDL e Wayland

O Simple DirectMedia Layer (SDL) é uma biblioteca multiplataforma amplamente usada para desenvolvimento de jogos e aplicativos multimídia. Quando portamos um aplicativo SDL para Wayland, enfrentamos desafios específicos porque o SDL foi originalmente projetado para X11. Veja como isso funciona na prática.

### Configurando o backend Wayland no SDL

Por padrão, o SDL tenta usar o backend X11. Para forçar o uso do Wayland, definimos a variável de ambiente:

```bash
export SDL_VIDEODRIVER=wayland
```

Se tentarmos executar um aplicativo SDL sem essa configuração em um ambiente puro de Wayland, o erro será claro:

```
SDL_Init failed: No available video device
```

Vamos criar um exemplo mínimo que abre uma janela e verifica o backend em uso:

```c
#include <SDL2/SDL.h>
#include <stdio.h>

int main() {
    if(SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL could not initialize! Error: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow("SDL Wayland Test",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        800, 600, SDL_WINDOW_SHOWN);
    
    if(!window) {
        printf("Window could not be created! Error: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    const char* driver = SDL_GetCurrentVideoDriver();
    printf("SDL is using video driver: %s\n", driver);

    SDL_Delay(3000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
```

Compile com:

```bash
gcc sdl_wayland.c -o sdl_wayland $(pkg-config --cflags --libs sdl2)
```

Quando executado corretamente com `SDL_VIDEODRIVER=wayland`, a saída será:

```
SDL is using video driver: wayland
```

### Diferenças entre X11 e Wayland no SDL

A principal diferença prática é no tratamento de janelas. No X11, o SDL tem controle direto sobre o posicionamento e gerenciamento de janelas. No Wayland, essas operações são delegadas ao compositor. Isso afeta particularmente:

1. **Posicionamento absoluto**: Chamadas como `SDL_SetWindowPosition` podem ser ignoradas
2. **Modo cheio tela**: O comportamento pode variar entre compositores
3. **Decorations**: O compositor decide se mostra bordas e controles

Teste este código para ver as limitações:

```c
SDL_SetWindowPosition(window, 100, 100);  // Pode não ter efeito
SDL_SetWindowFullscreen(window, SDL_TRUE);  // Depende do compositor
```

### Input Handling

O tratamento de entrada também muda significativamente. No Wayland, os eventos de teclado e mouse passam pelo protocolo Wayland:

```c
SDL_Event e;
while(SDL_PollEvent(&e)) {
    if(e.type == SDL_QUIT) {
        break;
    }
    if(e.type == SDL_KEYDOWN) {
        printf("Key press: %s\n", SDL_GetKeyName(e.key.keysym.sym));
    }
}
```

Em alguns casos, você pode precisar habilitar features específicas:

```c
SDL_SetHint(SDL_HINT_VIDEO_WAYLAND_ALLOW_LIBDECOR, "1");
```

### Solução de problemas comuns

1. **Falha ao inicializar**:
   ```
   wayland not available
   ```
   Solução: Instale `libwayland-dev` e recompile o SDL com suporte a Wayland.

2. **Cursor invisível**:
   ```c
   SDL_ShowCursor(SDL_ENABLE);
   ```

3. **Problemas com OpenGL**:
   ```c
   SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
   ```

### Exercício: Adaptando um aplicativo SDL existente

Pegue qualquer aplicativo SDL simples que você tenha (ou use o exemplo acima) e:

1. Adicione tratamento de eventos de mouse
2. Implemente redimensionamento de janela
3. Verifique o comportamento em diferentes compositores Wayland (Weston, GNOME, KDE)

Solução comentada:

```c
// Adicione ao loop de eventos:
if(e.type == SDL_MOUSEMOTION) {
    printf("Mouse at %d,%d\n", e.motion.x, e.motion.y);
}

if(e.type == SDL_WINDOWEVENT) {
    if(e.window.event == SDL_WINDOWEVENT_RESIZED) {
        printf("Window resized to %dx%d\n", 
               e.window.data1, e.window.data2);
    }
}
```

A saída mostrará como o Wayland gerencia esses eventos de forma diferente do X11.