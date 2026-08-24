## Gerenciamento de Clients

Um compositor Wayland precisa lidar com múltiplos clientes conectados simultaneamente, cada um exigindo seu próprio estado isolado. Vamos implementar um gerenciador que aceita conexões e mantém os clients organizados, sem ainda entrar em detalhes de segurança ou autenticação.

O ponto de partida é um socket UNIX ouvindo em `/tmp/wayland-0`, que já deve estar configurado (como visto no capítulo anterior). Quando um cliente se conecta, precisamos:

1. Aceitar a conexão
2. Criar um objeto `Client` para armazenar seu estado
3. Iniciar o handshake do protocolo Wayland

Começamos definindo a estrutura do cliente:

```rust
use std::os::unix::io::{RawFd, AsRawFd};
use std::collections::HashMap;

struct Client {
    fd: RawFd,
    objects: HashMap<u32, WaylandObject>,
    next_id: u32,
}

impl Client {
    fn new(fd: RawFd) -> Self {
        Client {
            fd,
            objects: HashMap::new(),
            next_id: 1, // IDs começam em 1 no Wayland
        }
    }

    fn allocate_id(&mut self) -> u32 {
        let id = self.next_id;
        self.next_id += 1;
        id
    }
}
```

O erro mais comum aqui é esquecer que os IDs de objeto no Wayland começam em 1, não em 0. Se você tentar usar 0 como ID, o cliente receberá um erro de protocolo:

```
[wayland-client] Error in dispatcher: invalid object ID 0
```

Agora, o loop principal do servidor que aceita novas conexões:

```rust
use std::os::unix::net::{UnixListener, UnixStream};
use std::io::{Read, Write};

fn main() -> std::io::Result<()> {
    let socket_path = "/tmp/wayland-0";
    std::fs::remove_file(socket_path).ok(); // Limpa socket anterior
    
    let listener = UnixListener::bind(socket_path)?;
    println!("Servidor ouvindo em {}", socket_path);

    let mut clients = Vec::new();

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                println!("Nova conexão aceita");
                let client = Client::new(stream.as_raw_fd());
                clients.push(client);
                handshake(&stream)?;
            }
            Err(e) => eprintln!("Erro ao aceitar conexão: {}", e),
        }
    }

    Ok(())
}
```

O handshake inicial envia a versão do protocolo Wayland:

```rust
fn handshake(stream: &UnixStream) -> std::io::Result<()> {
    let response = b"wayland-1\n";
    stream.write_all(response)?;
    Ok(())
}
```

Se você esquecer de enviar o handshake, o cliente falhará imediatamente com:

```
[wayland-client] Fatal protocol error: handshake failed
```

Para gerenciar múltiplos clients eficientemente, precisamos monitorar seus sockets para eventos. Usamos `poll` para isso:

```rust
use nix::poll::{poll, PollFd, PollFlags};

fn poll_clients(clients: &[Client]) -> std::io::Result<()> {
    let mut fds: Vec<PollFd> = clients
        .iter()
        .map(|c| PollFd::new(c.fd, PollFlags::POLLIN))
        .collect();

    poll(&mut fds, -1)?;

    for (i, fd) in fds.iter().enumerate() {
        if let Some(revents) = fd.revents() {
            if revents.contains(PollFlags::POLLIN) {
                println!("Dados disponíveis no client {}", i);
                // Processar mensagens aqui
            }
        }
    }

    Ok(())
}
```

Um erro frequente é não lidar com desconexões abruptas. Vamos adicionar tratamento para isso:

```rust
fn handle_client_disconnect(client: &mut Client) -> std::io::Result<()> {
    // Fechar recursos associados ao client
    nix::unistd::close(client.fd)?;
    println!("Client desconectado");
    Ok(())
}
```

Exercício: Modifique o loop principal para usar `poll` e lidar com desconexões. Quando um client envia dados, imprima quantos bytes foram recebidos.

Solução:

```rust
fn main() -> std::io::Result<()> {
    let socket_path = "/tmp/wayland-0";
    std::fs::remove_file(socket_path).ok();
    
    let listener = UnixListener::bind(socket_path)?;
    println!("Servidor ouvindo em {}", socket_path);

    let mut clients = Vec::new();

    loop {
        let mut fds = vec![PollFd::new(listener.as_raw_fd(), PollFlags::POLLIN)];
        
        for client in &clients {
            fds.push(PollFd::new(client.fd, PollFlags::POLLIN | PollFlags::POLLHUP));
        }

        poll(&mut fds, -1)?;

        if fds[0].revents().unwrap().contains(PollFlags::POLLIN) {
            match listener.accept() {
                Ok((stream, _)) => {
                    println!("Nova conexão aceita");
                    let client = Client::new(stream.as_raw_fd());
                    clients.push(client);
                    handshake(&stream)?;
                }
                Err(e) => eprintln!("Erro ao aceitar conexão: {}", e),
            }
        }

        let mut i = 0;
        while i < clients.len() {
            let revents = fds[i+1].revents().unwrap();
            
            if revents.contains(PollFlags::POLLHUP) {
                handle_client_disconnect(&mut clients[i])?;
                clients.remove(i);
            } else if revents.contains(PollFlags::POLLIN) {
                let mut buf = [0; 1024];
                match nix::unistd::read(clients[i].fd, &mut buf) {
                    Ok(n) => println!("Recebidos {} bytes do client {}", n, i),
                    Err(_) => {
                        handle_client_disconnect(&mut clients[i])?;
                        clients.remove(i);
                        continue;
                    }
                }
            }
            i += 1;
        }
    }
}
```