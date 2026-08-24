## Eventos e Requests

No protocolo Wayland, toda comunicação entre cliente e servidor se divide em dois tipos fundamentais: **events** (eventos) e **requests** (requisições). A diferença essencial está na direção do fluxo e no controle da comunicação.

### O Problema da Bidirecionalidade
Imagine uma aplicação gráfica onde:
1. O cliente quer mover uma janela (ação iniciada pelo usuário)
2. O servidor precisa notificar sobre novos dispositivos de entrada (como um mouse conectado)

Se ambos pudessem enviar comandos livremente, teríamos condições de corrida. O Wayland resolve isso com papéis bem definidos:

```rust
// Conexão básica - você já sabe disso do capítulo anterior
let conn = wayland_client::Display::connect_to_env()?;
let mut event_queue = conn.create_event_queue();
let attached = conn.attach(event_queue.token());
```

### Requests: O Cliente Pedindo Ação
Requests são mensagens **enviadas pelo cliente** para solicitar operações ao servidor. Por exemplo, criar uma nova surface:

```rust
let compositor = attached
    .instantiate_exact::<WlCompositor>(1)
    .expect("Compositor não disponível");

let surface = compositor.create_surface();
surface.commit(); // Isso é um request!
```

Se você esquecer o `commit()`, nada será renderizado. O erro comum é criar a surface mas não enviar o commit, resultando em uma janela vazia sem mensagens de erro - o servidor simplesmente ignora surfaces não comprometidas.

### Events: O Servidor Notificando
Events são mensagens **enviadas pelo servidor** para informar o cliente sobre mudanças de estado. Por exemplo, quando o servidor conclui a configuração inicial de uma janela:

```rust
surface.assign(|surface| {
    surface.quick_assign(|surface, event, _| {
        match event {
            wl_surface::Event::Enter(output) => {
                println!("Surface entrou no output {:?}", output);
            },
            _ => {}
        }
    });
});
```

Um erro frequente é não implementar o handler para eventos obrigatórios. Algumas versões do protocolo exigem resposta a certos eventos:

```text
[wayland-client] Erro: Evento wl_surface::configure não tratado (interface wl_surface v4+)
```

### Tabela Comparativa
| Característica       | Requests                     | Events                     |
|----------------------|------------------------------|----------------------------|
| Iniciador            | Cliente                      | Servidor                   |
| Direção              | Cliente → Servidor           | Servidor → Cliente         |
| Sincronismo          | Assíncrono por padrão        | Assíncrono                 |
| Confirmação          | Via eventos (se aplicável)   | Não requer confirmação     |
| Erro comum           | Esquecer requests obrigatórios | Ignorar eventos necessários |

### Padrão de Implementação
A biblioteca `wayland-client` usa o padrão de callbacks para eventos. Veja um exemplo completo com tratamento de erro:

```rust
let seat = global_manager
    .instantiate_exact::<WlSeat>(4)
    .expect("Seat não disponível");

seat.get_pointer().quick_assign(|pointer, event, _| {
    match event {
        wl_pointer::Event::Enter { .. } => {
            println!("Cursor entrou na surface");
        },
        wl_pointer::Event::Leave { .. } => {
            println!("Cursor saiu da surface");
        },
        _ => {}
    }
});

// Request para começar a receber eventos
seat.get_keyboard()?.keymap(1, 0, 0); // Formato, fd, tamanho
```

Se faltar o request final (`keymap`), nenhum evento de teclado chegará, mas o erro só aparece em runtime quando o usuário tentar digitar.

### Exercício: Eventos de Teclado
Implemente um handler para `wl_keyboard::Event::Key` que:
1. Mostre o código da tecla pressionada
2. Só reaja a pressionamentos (state = 1)
3. Envie um request `keyboard.release()` após 5 teclas

Solução comentada:
```rust
let mut key_count = 0;
keyboard.quick_assign(|keyboard, event, _| {
    if let wl_keyboard::Event::Key { key, state, .. } = event {
        if state == 1 { // 1 = pressionado
            println!("Tecla {} pressionada", key);
            key_count += 1;
            if key_count >= 5 {
                keyboard.release(); // Request para liberar o teclado
            }
        }
    }
});
```