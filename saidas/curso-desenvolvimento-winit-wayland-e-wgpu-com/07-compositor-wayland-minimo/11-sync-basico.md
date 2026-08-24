## Sync Básico

Um cliente Wayland envia um frame para ser exibido, mas o compositor ainda está processando o frame anterior. Sem sincronização, isso causa tearing ou frames perdidos. O protocolo Wayland resolve isso com dois mecanismos: `wl_surface.commit` e `wl_callback`.

Vamos implementar um sistema mínimo que garante que cada frame do cliente seja exibido na ordem correta, sem sobreposição. Começamos com a estrutura que armazena o estado de sincronização:

```rust
struct SurfaceSync {
    pending_buffer: Option<wl_buffer::WlBuffer>,  // Buffer aguardando commit
    current_buffer: Option<wl_buffer::WlBuffer>,  // Buffer em exibição
    frame_callbacks: Vec<wl_callback::WlCallback>, // Callbacks para notificação
}
```

Quando um cliente envia um buffer, ele fica em `pending_buffer` até o commit:

```rust
impl SurfaceSync {
    fn attach(&mut self, buffer: wl_buffer::WlBuffer) {
        self.pending_buffer = Some(buffer);
    }
}
```

O commit transfere o buffer pendente para o atual e agenda os callbacks:

```rust
fn commit(&mut self) {
    if let Some(buffer) = self.pending_buffer.take() {
        // Libera o buffer anterior se existir
        if let Some(old) = self.current_buffer.replace(buffer) {
            old.release();
        }
        
        // Dispara todos os callbacks pendentes
        for callback in self.frame_callbacks.drain(..) {
            callback.done(0 /* timestamp */);
        }
    }
}
```

O erro mais comum é esquecer de liberar buffers antigos, causando vazamento de memória. Veja o que acontece se removermos a linha `old.release()`:

```
WARNING: Client não liberou 12 buffers wl_shm
```

Para o cliente solicitar notificação quando o frame for exibido, implementamos:

```rust
fn add_frame_callback(&mut self, callback: wl_callback::WlCallback) {
    self.frame_callbacks.push(callback);
}
```

Um cliente Rust típico usaria assim:

```rust
let surface = compositor.create_surface();
let buffer = pool.create_buffer(/* ... */);
surface.attach(Some(&buffer));

let callback = surface.frame();
callback.quick_assign(|_, _, _| {
    println!("Frame exibido!");
});

surface.commit();
```

A saída esperada quando tudo funciona:
```
Frame exibido!
Frame exibido!
...
```

Mas se o compositor não processar os callbacks, o cliente ficará travado esperando a notificação. Para evitar isso, sempre libere os callbacks mesmo em caso de erro:

```rust
fn cleanup(&mut self) {
    for callback in self.frame_callbacks.drain(..) {
        callback.done(0);
    }
    if let Some(buffer) = self.current_buffer.take() {
        buffer.release();
    }
}
```

Exercício: Modifique o sistema para limitar a taxa de frames a 60 FPS, armazenando o timestamp do último frame e adiando callbacks quando necessário. Solução:

```rust
const FRAME_TIME: u32 = 16; // ms por frame (1000/60)

impl SurfaceSync {
    fn commit_with_fps(&mut self, last_frame: &mut u32) {
        let now = current_time_ms();
        if now - *last_frame >= FRAME_TIME {
            self.commit();
            *last_frame = now;
        } else {
            // Adia os callbacks
            for callback in self.frame_callbacks.drain(..) {
                callback.done(now);
            }
        }
    }
}
```