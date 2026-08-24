## Surfaces Básicas

Uma surface Wayland é a unidade fundamental para exibir conteúdo gráfico, mas ao contrário de sistemas como X11, ela começa como uma tela vazia e invisível. Vamos criar uma surface mínima que o compositor reconhece, mas ainda não mostra nada na tela - o equivalente gráfico de abrir um arquivo em modo `O_CREAT`.

Começamos com uma conexão já estabelecida (usando `wayland-client` e `winit` como base):

```rust
use wayland_client::{Display, GlobalManager};
use wayland_client::protocol::{wl_compositor, wl_surface};

// Conexão inicial e sync já feitos em capítulos anteriores
let display = Display::connect_to_env().unwrap();
let mut event_queue = display.create_event_queue();
let attached_display = display.attach(event_queue.token());
let globals = GlobalManager::new(&attached_display);
event_queue.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();

// Obtemos o compositor
let compositor = globals.instantiate_exact::<wl_compositor::WlCompositor>(1).unwrap();

// Criando a surface
let surface = compositor.create_surface();
```

Este código cria uma surface válida, mas se executado agora, nada acontece - nem mesmo um erro. O compositor alocou recursos internos, mas sem três elementos essenciais:
1. Um buffer anexado contendo pixels reais
2. Um commit para confirmar o estado
3. Um papel (role) que define como a surface será usada

Vamos adicionar os passos mínimos para tornar a surface ativa:

```rust
// Anexamos um buffer vazio (ainda não renderizado)
surface.attach(None, 0, 0);

// Marcamos a surface como "suja" (precisa ser redesenhada)
surface.damage(0, 0, 100, 100); // Área retangular a atualizar

// Enviamos o estado para o compositor
surface.commit();

// Processamos eventos para garantir o commit
event_queue.dispatch(&mut (), |_, _, _| {}).unwrap();
```

Agora o compositor sabe que existe uma surface de 100x100 pixels que precisa ser exibida, mas ainda não há conteúdo. Se você tentar visualizar, verá um erro típico:

```
wayland error: wl_surface@3: error 1: no buffer attached
```

Isso acontece porque commitamos sem anexar um buffer válido. Vamos corrigir criando um buffer temporário via shared memory (que será detalhado no próximo capítulo):

```rust
use wayland_client::protocol::wl_shm;

let shm = globals.instantiate_exact::<wl_shm::WlShm>(1).unwrap();
let pool = shm.create_pool(fd, size); // Detalhes omitidos para foco na surface
let buffer = pool.create_buffer(0, 100, 100, 100 * 4, wl_shm::Format::Argb8888);

surface.attach(Some(&buffer), 0, 0);
surface.commit();
```

A surface agora está pronta para exibição, mas ainda falta um detalhe crucial: sem uma "role", o compositor não sabe como gerenciá-la. Em capítulos posteriores, veremos como transformá-la em uma janela, overlay ou área de trabalho.

**Erro Comum:** Esquecer de chamar `commit()` após configurar a surface. O resultado é uma surface que nunca se torna visível, sem mensagens de erro. Sempre inclua:

```rust
surface.commit();
event_queue.dispatch(&mut (), |_, _, _| {}).unwrap(); // Processa ack do servidor
```

**Exercício:** Modifique o exemplo para criar duas surfaces de 200x200 pixels, uma vermelha e outra azul (use buffers simples com cores sólidas), posicionadas em (50,50) e (300,100) respectivamente.

**Solução Comentada:**

```rust
// Criação dos buffers (simplificado)
fn create_color_buffer(width: i32, height: i32, color: [u8; 4]) -> Vec<u8> {
    vec![color[0], color[1], color[2], color[3]].repeat((width * height) as usize)
}

let red_buffer = create_color_buffer(200, 200, [255, 0, 0, 255]);
let blue_buffer = create_color_buffer(200, 200, [0, 0, 255, 255]);

// Configuração das surfaces
let surface1 = compositor.create_surface();
let surface2 = compositor.create_surface();

// Anexa buffers e define posição (usando shell_surface que veremos depois)
surface1.attach(/* buffer vermelho */, 50, 50);
surface2.attach(/* buffer azul */, 300, 100);

// Commit final
surface1.commit();
surface2.commit();
```