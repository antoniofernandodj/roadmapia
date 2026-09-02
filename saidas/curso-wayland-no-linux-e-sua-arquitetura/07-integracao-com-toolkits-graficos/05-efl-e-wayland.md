## EFL e Wayland

O Enlightenment Foundation Libraries (EFL) oferecem uma abordagem única para desenvolvimento gráfico no Wayland, combinando performance com flexibilidade. Ao contrário de GTK e Qt que adotam modelos mais tradicionais, o EFL foi projetado desde o início para sistemas embarcados e mobile, tornando-o especialmente adequado para ambientes Wayland onde eficiência é crítica.

**Problema prático:** Um aplicativo EFL rodando sobre X11 exibe artefatos visuais quando migrado para Wayland, com mensagens de erro como:
```
wl_display@1: error 0: invalid object 42"
```

Este erro ocorre porque o EFL precisa ser explicitamente configurado para usar seu backend Wayland. Veja como corrigir:

1. Primeiro, instale os requisitos no Ubuntu/Debian:
```bash
sudo apt install libefl-all-dev wayland-protocols
```

2. Crie um aplicativo mínimo que demonstra a integração:

```c
#define EFL_BETA_API_SUPPORT
#include <Ecore.h>
#include <Ecore_Wayland.h>
#include <Evas.h>
#include <Elementary.h>

EAPI_MAIN int elm_main(int argc, char **argv)
{
    Evas_Object *win, *bg;
    
    // Configuração explícita para Wayland
    setenv("ELM_ACCEL", "gl", 1);
    setenv("ELM_ENGINE", "wayland_egl", 1);
    
    win = elm_win_util_standard_add("EFL-Wayland", "Demonstração");
    bg = elm_bg_add(win);
    elm_bg_color_set(bg, 100, 100, 200);
    evas_object_size_hint_weight_set(bg, EVAS_HINT_EXPAND, EVAS_HINT_EXPAND);
    elm_win_resize_object_add(win, bg);
    evas_object_show(bg);
    
    evas_object_resize(win, 400, 300);
    evas_object_show(win);
    
    elm_run();
    return 0;
}
ELM_MAIN()
```

Compile com:
```bash
gcc efl_wayland.c -o efl_wayland `pkg-config --cflags --libs elementary ecore-wayland`
```

**Saída esperada:** Uma janela azul (RGB 100,100,200) de 400x300 pixels, sem erros no terminal.

**Erro comum:** Ao esquecer de exportar as variáveis de ambiente necessárias, você pode encontrar:
```
ERR<17400>:ecore_evas wayland_engine.c:125 _ecore_evas_wayland_engine_init() 
Could not connect to Wayland display
```

A solução é garantir que o display Wayland está ativo antes de executar:
```bash
export ELM_DISPLAY=wl
./efl_wayland
```

**Diferencial EFL:** Comparado a outros toolkits, o EFL no Wayland oferece:
1. Composição direta via Evas (canvas vetorial)
2. Controle fino sobre buffers gráficos
3. Suporte nativo a multiplas superfícies Wayland

**Exercício:** Modifique o exemplo para criar uma janela com:
- Cor de fundo vermelha (RGB 200,100,100)
- Título "Exercício EFL"
- Tamanho 500x400 pixels

**Solução comentada:**

```c
// [...] (mantenha includes e declarações)

    win = elm_win_util_standard_add("Exercício EFL", "Demonstração");
    bg = elm_bg_add(win);
    elm_bg_color_set(bg, 200, 100, 100); // Vermelho modificado
    // [...] (mantenha configurações de peso)
    evas_object_resize(win, 500, 400); // Novo tamanho
    // [...] (mantenha o resto)
```

Key points para depuração:
1. Verifique sempre `echo $WAYLAND_DISPLAY` - deve mostrar "wayland-0"
2. Use `EFL_LOG=3 ./seu_app` para logs detalhados
3. Para problemas de renderização, teste com `ELM_ENGINE=wayland_shm`