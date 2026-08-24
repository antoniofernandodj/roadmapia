## Debugging Wayland

Quando sua aplicação Wayland falha silenciosamente ou se comporta de forma inesperada, o primeiro passo é entender o diálogo entre cliente e servidor. O protocolo Wayland é baseado em mensagens binárias, mas temos ferramentas para inspecioná-las de forma legível.

### wayland-debug

Instale a ferramenta `wayland-debug` (disponível em distribuições Linux via `libwayland-bin`). Vamos testá-la com um cliente simples que cria uma janela vazia:

```rust
use wayland_client::{Display, GlobalManager};

fn main() {
    let display = Display::connect_to_env().unwrap();
    let mut event_queue = display.create_event_queue();
    let attached_display = display.attach(event_queue.token());
    let globals = GlobalManager::new(&attached_display);
    
    event_queue.sync_roundtrip(&mut (), |_, _, _| {}).unwrap();
    
    // Cria uma janela básica
    let surface = globals
        .instantiate_exact::<wayland_client::protocol::wl_surface::WlSurface>(1)
        .unwrap();
    surface.commit();
    
    loop {
        event_queue.dispatch(&mut (), |_, _, _| {}).unwrap();
    }
}
```

Ao executar com `WAYLAND_DEBUG=1 cargo run`, você verá uma saída como:

```
[1711234.234]  -> wl_display@1.get_registry(new id wl_registry@2)
[1711234.245]  -> wl_display@1.sync(new id wl_callback@3)
[1711234.256] wl_display@1.delete_id(3)
[1711234.267] wl_registry@2.global(1, "wl_compositor", 4)
[1711234.278] wl_registry@2.global(2, "wl_shm", 1)
[1711234.289] wl_callback@3.done(1711234)
```

Cada linha mostra:
1. Carimbo de tempo em milissegundos
2. Direção da mensagem (`->` cliente→servidor, `<-` servidor→cliente)
3. Objeto envolvido (ex: `wl_display@1`)
4. Operação realizada

### Erro comum: Missing Commit

Um erro frequente é esquecer de comitar a surface. Veja como o debug mostra o problema:

```rust
let surface = globals.instantiate_exact::<WlSurface>(1).unwrap();
// surface.commit(); // Esquecido propositalmente
```

A saída do debug mostrará que a surface foi criada, mas nenhum buffer foi anexado:

```
[1712345.345]  -> wl_compositor@4.create_surface(new id wl_surface@5)
[1712345.356]  -> wl_display@1.sync(new id wl_callback@6)
```

Sem o `commit()`, o compositor ignora a surface. O debug não mostra erros - apenas a ausência das mensagens esperadas.

### wl-dump

Para capturar o tráfego completo, use `wl-dump`:

```bash
cargo build
WAYLAND_DEBUG=1 ./target/debug/seu_programa | wl-dump > trace.log
```

Isso cria um arquivo com todas as mensagens trocadas, útil para análise posterior. Um trecho típico:

```xml
<event name="global" time="1713456.789" object="wl_registry@2">
  <arg name="name" type="uint" value="1"/>
  <arg name="interface" type="string" value="wl_compositor"/>
  <arg name="version" type="uint" value="4"/>
</event>
```

### Debugging de Protocolos Estendidos

Ao usar protocolos como `xdg_shell`, verifique se o compositor os suporta. Um erro comum:

```rust
let xdg_shell = globals.instantiate_exact::<XdgShell>(1).unwrap(); // Pode falhar
```

O debug mostra se o global foi anunciado:

```
[1714567.890] wl_registry@2.global(3, "xdg_wm_base", 2)  // Suportado
[1714567.901] wl_registry@2.global(4, "zwp_pointer_constraints_v1", 1)  // Não usado
```

Se faltar a interface, você verá apenas os protocolos básicos.

### Exercício: Debugging de Input

Modifique o exemplo inicial para capturar eventos de teclado, mas intencionalmente esqueça de implementar o handler. Use o debug para identificar o problema:

```rust
let seat = globals.instantiate_exact::<WlSeat>(1).unwrap();
let keyboard = seat.get_keyboard();
// Falta: keyboard.quick_assign(|event, ..| match event { ... });
```

**Solução esperada:**

O debug mostrará eventos de teclado chegando, mas não sendo tratados:

```
[1715678.912] <- wl_keyboard@8.key(1715678, 45892, 30, 1)  // Tecla pressionada
[1715678.923] <- wl_keyboard@8.key(1715679, 45892, 30, 0)  // Tecla liberada
```

A correção seria implementar o handler:

```rust
keyboard.quick_assign(|event, _, _| match event {
    wayland_client::protocol::wl_keyboard::Event::Key { key, state, .. } => {
        println!("Tecla: {} Estado: {}", key, state);
    }
    _ => {}
});
```