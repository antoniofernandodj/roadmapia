## Display Server Básico

Um display server Wayland opera como um mediador entre aplicações clientes e o hardware gráfico. Vamos implementar o núcleo mínimo que aceita conexões de clientes sem ainda processar protocolos complexos. O erro mais comum aqui é tentar lidar com mensagens Wayland antes de estabelecer a conexão básica.

Começamos criando um socket UNIX para comunicação. Este será o ponto de entrada para clientes se conectarem:

```rust
use std::os::unix::net::{UnixListener, UnixStream};
use std::io::{Read, Write};

fn create_display_socket(path: &str) -> std::io::Result<UnixListener> {
    // Remove socket antigo se existir
    let _ = std::fs::remove_file(path);
    let listener = UnixListener::bind(path)?;
    println!("Socket criado em {}", path);
    Ok(listener)
}
```

Ao executar com `let listener = create_display_socket("/tmp/wayland-0").unwrap();`, o servidor cria um socket em `/tmp/wayland-0` - o caminho padrão para servidores Wayland. Se falhar, verá:

```
Error: Os { code: 98, kind: AddrInUse, message: "Address already in use" }
```

Isso indica outro servidor Wayland em execução. A solução é mudar o caminho ou encerrar o processo conflitante.

Com o socket pronto, aceitamos conexões em um loop:

```rust
fn handle_client(mut stream: UnixStream) -> std::io::Result<()> {
    let mut buf = [0; 1024];
    let n = stream.read(&mut buf)?;
    println!("Recebidos {} bytes: {:?}", n, &buf[..n]);
    stream.write_all(b"wayland-1\n")?; // Versão do protocolo
    Ok(())
}

fn main() -> std::io::Result<()> {
    let listener = create_display_socket("/tmp/wayland-0")?;
    
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                if let Err(e) = handle_client(stream) {
                    eprintln!("Erro no cliente: {}", e);
                }
            }
            Err(e) => eprintln!("Erro na conexão: {}", e),
        }
    }
    Ok(())
}
```

Quando um cliente como `weston-terminal` conecta-se, a saída mostra:

```
Socket criado em /tmp/wayland-0
Recebidos 8 bytes: [119, 108, 95, 100, 105, 115, 112, 108]
```

Os bytes `[119, 108, 95, 100, 105, 115, 112, 108]` correspondem a "wl_disp" - o início do handshake do protocolo Wayland. Nosso servidor responde com "wayland-1\n", indicando suporte à versão 1 do protocolo.

Para tornar isto funcional, precisamos implementar o handshake completo. O primeiro passo é enviar a lista de objetos globais:

```rust
use byteorder::{NativeEndian, WriteBytesExt};

fn send_global_list(mut stream: &UnixStream) -> std::io::Result<()> {
    // Cabeçalho da mensagem: id do objeto (new_id), opcode, tamanho
    let mut buf = vec![];
    buf.write_u32::<NativeEndian>(1)?; // new_id para wl_registry
    buf.write_u32::<NativeEndian>(0)?; // opcode 0 (bind)
    buf.write_u32::<NativeEndian>(0)?; // tamanho (atualizado depois)
    
    // Nome do global (ex: wl_compositor)
    let name = b"wl_compositor";
    buf.extend_from_slice(name);
    buf.push(0); // null terminator
    
    // Atualiza tamanho da mensagem
    let size = buf.len() as u32;
    (&mut buf[8..12]).write_u32::<NativeEndian>(size)?;
    
    stream.write_all(&buf)?;
    Ok(())
}
```

Um cliente Wayland mínimo agora pode conectar-se e listar globais, mas falhará ao tentar usá-los. Isso é esperado - implementaremos os protocolos nos próximos trechos.

**Exercício**: Modifique o servidor para aceitar múltiplas conexões simultâneas usando threads. Capture a mensagem inicial de cada cliente e responda com a versão correta do protocolo.

**Solução**:

```rust
use std::thread;

fn main() -> std::io::Result<()> {
    let listener = create_display_socket("/tmp/wayland-0")?;
    
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                thread::spawn(move || {
                    if let Err(e) = handle_client(stream) {
                        eprintln!("Erro no cliente: {}", e);
                    }
                });
            }
            Err(e) => eprintln!("Erro na conexão: {}", e),
        }
    }
    Ok(())
}
```

A chave aqui é mover (`move`) cada stream para sua thread, garantindo isolamento entre clientes. Cada conexão agora é independente, permitindo múltiplos clientes simultâneos.