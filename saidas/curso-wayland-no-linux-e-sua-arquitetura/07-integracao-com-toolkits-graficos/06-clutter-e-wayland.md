## Clutter e Wayland

O Clutter é um toolkit gráfico baseado em OpenGL, conhecido por sua capacidade de criar interfaces animadas e fluidas. Ao contrário de GTK ou Qt, que focam em elementos tradicionais de UI, o Clutter se especializa em cenários onde você precisa controle preciso sobre animações e transformações 3D. 

**Problema concreto**: Ao executar um aplicativo Clutter em Wayland, você pode receber um erro como:

```
** (my-clutter-app:12345): CRITICAL **: clutter_init: assertion 'CLUTTER_IS_MAIN_CONTEXT (clutter_main_context)' failed
```

Isso acontece porque o Clutter precisa ser configurado explicitamente para usar o backend Wayland, diferente de quando roda sobre X11 onde muitas configurações são automáticas.

### Configurando o ambiente

Primeiro, verifique se seu sistema tem os pacotes necessários:

```bash
sudo apt install libclutter-1.0-dev libclutter-gst-3.0-dev libwayland-dev
```

Crie um arquivo `clutter-wayland.c` com o seguinte conteúdo:

```c
#include <clutter/clutter.h>

int main(int argc, char *argv[]) {
    // Configuração crítica para Wayland
    setenv("CLUTTER_BACKEND", "wayland", 1);
    
    if (clutter_init(&argc, &argv) != CLUTTER_INIT_SUCCESS) {
        g_critical("Falha ao inicializar o Clutter");
        return 1;
    }

    ClutterActor *stage = clutter_stage_new();
    clutter_actor_set_size(stage, 400, 300);
    clutter_actor_set_background_color(stage, CLUTTER_COLOR_LightSkyBlue);
    clutter_stage_set_title(CLUTTER_STAGE(stage), "Clutter + Wayland");
    
    ClutterActor *rect = clutter_actor_new();
    clutter_actor_set_size(rect, 100, 100);
    clutter_actor_set_position(rect, 150, 100);
    clutter_actor_set_background_color(rect, CLUTTER_COLOR_DarkOrange);
    
    clutter_actor_add_child(stage, rect);
    clutter_actor_show(stage);
    
    clutter_main();
    
    return 0;
}
```

Compile e execute com:

```bash
gcc `pkg-config --cflags --libs clutter-1.0` clutter-wayland.c -o clutter-wayland
./clutter-wayland
```

**Saída esperada**: Uma janela azul claro com um quadrado laranja no centro.

### Erro comum e solução

Se você esquecer de definir `CLUTTER_BACKEND=wayland`, verá:

```
Clutter-CRITICAL **: Unable to initialise Clutter: The Wayland backend requires a running Wayland compositor
```

A correção está na linha 5 do exemplo, onde forçamos o backend correto via `setenv()`. Alternativamente, você pode exportar a variável antes de executar:

```bash
export CLUTTER_BACKEND=wayland
./clutter-wayland
```

### Comparação com X11

No X11, o Clutter pode:

1. Criar múltiplos estágios independentes
2. Acessar diretamente IDs de janela X11
3. Usar extensões como XComposite

Em Wayland:

1. Só um estágio principal é permitido
2. Identificadores de janela são opacos
3. Composição é sempre ativa, mas sob controle do compositor

### Exercício: Animações Wayland

Modifique o exemplo para incluir uma animação que:

1. Gire o quadrado 360 graus em 2 segundos
2. Mude sua cor gradualmente para vermelho
3. Posicione-o no canto inferior direito ao final

**Solução**:

```c
// Adicione após clutter_actor_add_child(stage, rect)

ClutterTransition *rotate = clutter_property_transition_new("rotation-angle-z");
clutter_transition_set_from(rotate, G_TYPE_DOUBLE, 0.0);
clutter_transition_set_to(rotate, G_TYPE_DOUBLE, 360.0);
clutter_transition_set_duration(rotate, 2000);

ClutterTransition *color = clutter_property_transition_new("background-color");
clutter_transition_set_from(color, G_TYPE_BOXED, CLUTTER_COLOR_DarkOrange);
clutter_transition_set_to(color, G_TYPE_BOXED, CLUTTER_COLOR_Red);
clutter_transition_set_duration(color, 2000);

ClutterTransition *move = clutter_property_transition_new("position");
ClutterPoint final_pos = { 300, 200 };
clutter_transition_set_to(move, G_TYPE_BOXED, &final_pos);
clutter_transition_set_duration(move, 2000);

clutter_actor_add_transition(rect, "rotate", rotate);
clutter_actor_add_transition(rect, "recolor", color);
clutter_actor_add_transition(rect, "move", move);
```

Este exercício demonstra como o Clutter mantém sua API de animação consistente entre X11 e Wayland, mesmo com as diferenças arquiteturais.