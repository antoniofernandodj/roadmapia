## Security Básica

Em um compositor Wayland, a segurança começa com o controle de acesso. Diferente de sistemas como X11, onde qualquer aplicação pode interferir com outra, Wayland fornece um modelo de isolamento onde o compositor atua como árbitro entre os clientes. No entanto, mesmo com essa arquitetura mais segura, é essencial implementar medidas básicas para garantir que clientes maliciosos ou bugados não comprometam o sistema.

### Controle de Acesso Simples

O primeiro passo é garantir que apenas clientes autorizados possam se conectar ao compositor. Em Wayland, isso é feito através da criação de um socket UNIX com permissões restritas. Veja como isso pode ser implementado em Rust:

```rust
use std::os::unix::net::UnixListener;
use std::os::unix::fs::PermissionsExt;
use std::fs;

fn main() -> std::io::Result<()> {
    // Cria o socket UNIX
    let socket_path = "/tmp/wayland-0";
    let listener = UnixListener::bind(socket_path)?;

    // Define permissões para o socket (apenas o usuário atual pode ler/escrever)
    let mut perms = fs::metadata(socket_path)?.permissions();
    perms.set_mode(0o600); // rw-------
    fs::set_permissions(socket_path, perms)?;

    Ok(())
}
```

Se você tentar conectar outro cliente sem as permissões adequadas, o sistema operacional negará o acesso:

```bash
$ cargo run
error: Permission denied (os error 13)
```

### Verificação de Identidade do Cliente

Além das permissões do socket, podemos verificar a identidade do cliente conectado. Em sistemas UNIX, cada processo possui um ID único (PID) que pode ser usado para autenticação. Veja como obter o PID do cliente:

```rust
use std::os::unix::net::UnixStream;
use nix::unistd::Pid;

fn handle_client(stream: UnixStream) -> std::io::Result<()> {
    let client_pid = Pid::from_raw(stream.peer_pid()?);
    println!("Cliente conectado com PID: {}", client_pid);
    
    // Aqui você pode implementar uma lista de PIDs permitidos
    Ok(())
}
```

### Limitação de Recursos por Cliente

Outra medida básica é limitar a quantidade de recursos que cada cliente pode consumir. Por exemplo, você pode restringir o número máximo de surfaces que um cliente pode criar:

```rust
struct ClientState {
    surface_count: usize,
    max_surfaces: usize,
}

impl ClientState {
    fn new(max_surfaces: usize) -> Self {
        Self {
            surface_count: 0,
            max_surfaces,
        }
    }

    fn can_create_surface(&self) -> bool {
        self.surface_count < self.max_surfaces
    }

    fn increment_surface_count(&mut self) {
        self.surface_count += 1;
    }
}

fn handle_surface_creation(client: &mut ClientState) -> Result<(), String> {
    if !client.can_create_surface() {
        return Err("Limite máximo de surfaces atingido".to_string());
    }

    client.increment_surface_count();
    Ok(())
}
```

Se um cliente tentar criar mais surfaces do que o permitido, ele receberá um erro:

```rust
let mut client = ClientState::new(3); // Limite de 3 surfaces
assert!(handle_surface_creation(&mut client).is_ok());
assert!(handle_surface_creation(&mut client).is_ok());
assert!(handle_surface_creation(&mut client).is_ok());
assert!(handle_surface_creation(&mut client).is_err()); // Erro ao criar a 4ª surface
```

### Exercício: Implementar Controle de Acesso

Implemente um sistema de controle de acesso que:
1. Restringe conexões ao socket UNIX para usuários específicos.
2. Limita o número máximo de surfaces por cliente.
3. Registra todas as conexões e desconexões com seus PIDs.

**Solução:**

```rust
use std::os::unix::net::UnixListener;
use std::os::unix::fs::PermissionsExt;
use std::fs;
use std::os::unix::net::UnixStream;
use nix::unistd::Pid;

struct ClientState {
    surface_count: usize,
    max_surfaces: usize,
}

impl ClientState {
    fn new(max_surfaces: usize) -> Self {
        Self {
            surface_count: 0,
            max_surfaces,
        }
    }

    fn can_create_surface(&self) -> bool {
        self.surface_count < self.max_surfaces
    }

    fn increment_surface_count(&mut self) {
        self.surface_count += 1;
    }
}

fn handle_client(stream: UnixStream, client: &mut ClientState) -> std::io::Result<()> {
    let client_pid = Pid::from_raw(stream.peer_pid()?);
    println!("Cliente conectado com PID: {}", client_pid);

    // Simula a criação de uma surface
    if client.can_create_surface() {
        client.increment_surface_count();
        println!("Surface criada. Total: {}", client.surface_count);
    } else {
        println!("Limite de surfaces atingido para PID {}", client_pid);
    }

    Ok(())
}

fn main() -> std::io::Result<()> {
    let socket_path = "/tmp/wayland-0";
    let listener = UnixListener::bind(socket_path)?;

    let mut perms = fs::metadata(socket_path)?.permissions();
    perms.set_mode(0o600); // rw-------
    fs::set_permissions(socket_path, perms)?;

    let mut client = ClientState::new(3); // Limite de 3 surfaces

    for stream in listener.incoming() {
        handle_client(stream?, &mut client)?;
    }

    Ok(())
}
```

Este exemplo combina todas as técnicas discutidas: controle de permissões do socket, verificação de PID do cliente e limitação de recursos por cliente. Ele serve como uma base sólida para implementar medidas de segurança mais avançadas em um compositor Wayland.