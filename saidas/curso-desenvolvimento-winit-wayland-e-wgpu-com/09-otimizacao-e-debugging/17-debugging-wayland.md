## Debugging Wayland

Quando sua aplicação gráfica Wayland falha silenciosamente — a janela não aparece, os eventos não chegam, ou o conteúdo não é renderizado — você precisa de ferramentas que exponham o que acontece no protocolo. O primeiro sintoma costuma ser um erro obscuro no terminal ou um comportamento inesperado da janela. Veja como diagnosticar:

### WAYLAND_DEBUG=1: O Log do Protocolo

Ativar os logs brutos do protocolo revela cada mensagem trocada entre seu cliente e o compositor Wayland. Execute sua aplicação com:

```bash
WAYLAND_DEBUG=1 cargo run
```

Isso produzirá saídas como:

```
[17123456.789]  -> wl_display@1.get_registry(new id wl_registry@2)
[17123456.790]  -> wl_display@1.sync(new id wl_callback@3)
[17123456.791] wl_display@1.delete_id(3)
[17123456.792] wl_registry@2.global(1, "wl_compositor", 4)
```

Cada linha mostra:
- Timestamp em milissegundos
- Direção (`->` = cliente para servidor, `<-` = servidor para cliente)
- Objeto Wayland (ex: `wl_display@1`)
- Mensagem e argumentos

**Erro comum**: Se você vir `error: invalid argument` após uma mensagem, provavelmente enviou um valor inválido (como um ID de objeto já utilizado). Por exemplo:

```
[17123457.123]  -> wl_surface@4.attach(wl_buffer@8, 0, 0)
[17123457.124] error: invalid argument (wl_buffer@8)
```

Isso indica que o buffer `8` não foi criado corretamente. A correção seria verificar a criação do buffer:

```rust
let buffer = Buffer::from_memory(
    &connection, 
    width, 
    height, 
    width * 4, 
    Format::Argb8888,
    &pixels // Verifique se `pixels` tem o tamanho correto
)?;
```

### weston-info: Listando Protocolos Suportados

Nem todos os compositors Wayland implementam os mesmos protocolos. Para verificar quais estão disponíveis:

```bash
weston-info
```

Saída típica:

```
interface: 'wl_compositor', version: 4
interface: 'wl_shm', version: 1
interface: 'xdg_wm_base', version: 2
interface: 'zwp_linux_dmabuf_v1', version: 3
```

Se sua aplicação requer `zwp_pointer_constraints_v1` (para travar o cursor) e esse protocolo não aparece, ela falhará silenciosamente. Você deve verificar em runtime:

```rust
let pointer_constraints = registry
    .bind::<ZwpPointerConstraintsV1, _, _>(
        name,
        version,
        qh,
    )
    .unwrap_or_else(|| {
        eprintln!("Compositor não suporta pointer constraints!");
        std::process::exit(1);
    });
```

### wlr-debug: Visualizando a Árvore de Superfícies

Para aplicações complexas com múltiplas superfícies (como players de vídeo com controles overlay), o `wlr-debug` mostra a hierarquia atual:

```bash
wlr-debug
```

Exemplo de saída:

```
xdg_surface@16 (role: xdg_toplevel)
├─ wl_surface@15
│  ├─ buffer: 1920x1080 ARGB8888
│  ├─ input region: 1920x1080
├─ xdg_popup@17
│  ├─ wl_surface@18
│  │  ├─ buffer: 300x200 ARGB8888
```

Isso revela se uma superfície filha (como um popup) está mal posicionada ou sem buffer atribuído.

### Caso Prático: Janela Congelada

Suponha que sua janela renderize o primeiro frame mas não atualize após interações. Com `WAYLAND_DEBUG=1`, você vê:

```
[17123458.456]  -> wl_surface@4.commit()
[17123458.457]  -> wl_display@1.sync(new id wl_callback@9)
[17123458.458] wl_callback@9.done(17123458)
```

Ausência de novos `commit()` indica que seu loop de eventos não está reagindo a atualizações. O problema geralmente está no tratamento do frame callback:

```rust
// ERRADO: Esqueceu de registrar novo callback após renderização
surface.frame(&qh, |_, _, _| {
    render_frame();
    // Faltou surface.commit() aqui
});

// CORRETO:
let frame_callback = surface.frame(&qh, move |callback, _, _| {
    callback.delete();
    render_frame();
    surface.commit(); // Atualiza a superfície
    queue_next_frame(surface, qh); // Agenda próximo frame
});
```

### Exercício: Diagnóstico de Input

Crie uma janela simples que não responde a cliques do mouse. Use `WAYLAND_DEBUG=1` para:
1. Verificar se os eventos `wl_pointer` estão sendo recebidos
2. Identificar em qual objeto o input está sendo atribuído
3. Corrigir o código para capturar eventos na superfície principal

Solução:

```rust
let seat = registry.bind::<wl_seat::WlSeat, _, _>(name, version, qh)?;
seat.get_pointer(&qh, ())?;

qh.instantiate::<wl_pointer::WlPointer, _>(|pointer, event, _| {
    match event {
        wl_pointer::Event::Enter { .. } => println!("Mouse entrou na superfície"),
        wl_pointer::Event::Button { button, state, .. } => {
            println!("Botão {} {}", button, match state {
                wl_pointer::ButtonState::Pressed => "pressionado",
                _ => "liberado",
            });
        },
        _ => {}
    }
});
```