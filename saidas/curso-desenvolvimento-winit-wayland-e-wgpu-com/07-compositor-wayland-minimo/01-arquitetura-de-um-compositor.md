## Arquitetura de um Compositor

Um compositor Wayland não é um bloco monolítico, mas um sistema modular que coordena quatro subsistemas principais. Vamos dissecar cada um com exemplos concretos do que acontece quando você move uma janela no GNOME:

1. **Display Server (wayland-server)**
   - O núcleo que implementa o protocolo Wayland
   - Gerencia conexões de clientes via socket UNIX (`/run/user/1000/wayland-0`)
   - Exemplo real: Quando o Firefox se conecta, o servidor cria um `wl_client` e atribui um ID único

```rust
// Trecho simplificado do wayland-server
let display = wayland_server::Display::new();
let socket = display.add_socket_auto().unwrap(); // Cria socket automático
```

2. **Gerenciador de Composição**
   - Responsável pela árvore de superfícies
   - Decide a ordem Z das janelas
   - Implementa lógica de redimensionamento/movimento
   - Exemplo: Quando você arrasta uma janela, o compositor:
     1. Recebe eventos de ponteiro via `wl_pointer`
     2. Atualiza as coordenadas da `wl_surface`
     3. Notifica os clientes sobre a nova posição

3. **Render Backend (WGPU/Vulkan/OpenGL)**
   - Transforma superfícies em pixels
   - Implementa efeitos como sombras e blur
   - Exemplo de pipeline típico:
     1. Renderiza cada superfície em textura separada
     2. Aplica shaders de composição
     3. Faz o blend final considerando transparências

```rust
// Pseudocódigo de composição com WGPU
let surface_texture = render_surface(&surface);
let shadow_texture = apply_shadow_effect(&surface_texture);
compositor.draw(&shadow_texture, position, z_index);
```

4. **Input Stack**
   - Multiplexa eventos de teclado/mouse/touch
   - Implementa focus stealing prevention
   - Exemplo de caminho de um clique:
     1. `libinput` detecta evento físico
     2. Compositor mapeia coordenadas para superfície
     3. Evento é serializado e enviado ao cliente correto

**Erro comum**: Tentar implementar o render antes de entender o protocolo. O compilador não vai te ajudar aqui - você só verá janelas pretas sem mensagens de erro. A ordem correta é:

1. Implementar `wl_display` e conexões básicas
2. Adicionar suporte a `wl_surface`
3. Só então integrar o renderizador

**Exercício Prático**: 
Monte um diagrama de sequência para o cenário onde um cliente:
1. Cria uma nova janela
2. Recebe foco de entrada
3. É movido pelo usuário
4. É redimensionado

**Solução comentada**:
```
Cliente               Compositor               Renderer
   |-----CreateSurface---->|                       |
   |<-----ID#42--------|   |                       |
   |-----Commit-------->|  |--CreateTexture------>|
   |                   |<--Render------------------|
   |<-----Frame-------|    |                       |
   |-----KeyFocus----->|   |--SetInputFocus------>|
   |                   |   |                       |
   |<--PointerEnter---|    |                       |
```