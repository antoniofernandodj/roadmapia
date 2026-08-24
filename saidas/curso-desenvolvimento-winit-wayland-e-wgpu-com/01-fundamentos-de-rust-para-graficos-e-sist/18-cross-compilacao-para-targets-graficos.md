## Cross-compilação para Targets Gráficos

Quando desenvolvemos aplicações gráficas em Rust, frequentemente precisamos compilar para plataformas diferentes da nossa máquina de desenvolvimento. Isso é especialmente crítico quando lidamos com aceleradores gráficos, onde cada plataforma tem drivers e ABIs específicas.

O primeiro passo é configurar o Rust para cross-compilação. Vamos começar instalando o target desejado:

```bash
rustup target add x86_64-unknown-linux-gnu
```

Agora, precisamos informar ao Cargo sobre o linker correto. Crie um arquivo `.cargo/config.toml` no seu projeto:

```toml
[target.x86_64-unknown-linux-gnu]
linker = "x86_64-linux-gnu-gcc"
```

Para aplicações gráficas, um erro comum é esquecer de incluir as bibliotecas do sistema necessárias. Vamos criar um exemplo mínimo que usa WGPU:

```rust
// main.rs
use wgpu::Instance;

fn main() {
    let instance = Instance::new(wgpu::Backends::PRIMARY);
    let adapter = instance.request_adapter(&wgpu::RequestAdapterOptions::default());
    println!("Adapter: {:?}", adapter);
}
```

Se tentarmos compilar apenas com `cargo build --target=x86_64-unknown-linux-gnu`, receberemos erros como:

```
error: linking with `x86_64-linux-gnu-gcc` failed: exit status: 1
  = note: /usr/bin/ld: cannot find -lwayland-client
```

A solução é instalar as dependências de desenvolvimento para o target. No Ubuntu/Debian:

```bash
sudo apt-get install gcc-x86_64-linux-gnu libwayland-dev:x86_64
```

Agora podemos compilar corretamente:

```bash
cargo build --target=x86_64-unknown-linux-gnu
```

Para Windows, o processo é similar mas requer o toolchain do MSVC:

```bash
rustup target add x86_64-pc-windows-msvc
```

E no `.cargo/config.tomn`:

```toml
[target.x86_64-pc-windows-msvc]
linker = "x86_64-w64-mingw32-gcc"
```

Um problema específico de aplicações gráficas é a necessidade de assets (shaders, texturas) no caminho correto. Podemos usar o crate `include_dir` para embutí-los no binário:

```rust
use include_dir::{include_dir, Dir};

static SHADERS: Dir = include_dir!("$CARGO_MANIFEST_DIR/shaders");

fn main() {
    let vertex_shader = SHADERS.get_file("shader.vert").unwrap();
    println!("Shader size: {} bytes", vertex_shader.contents().len());
}
```

Quando cross-compilando para Android, precisamos lidar com o NDK. Primeiro, adicione o target:

```bash
rustup target add aarch64-linux-android
```

Depois configure o linker no `.cargo/config.toml`:

```toml
[target.aarch64-linux-android]
linker = "/path/to/ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang"
```

Para macOS/iOS, o processo envolve os frameworks específicos:

```toml
[target.x86_64-apple-darwin]
rustflags = [
    "-C", "link-arg=-framework", 
    "-C", "link-arg=Metal",
    "-C", "link-arg=-framework",
    "-C", "link-arg=CoreGraphics"
]
```

Um erro comum é esquecer de especificar o backend gráfico correto. WGPU permite selecionar backends via variável de ambiente:

```bash
WGPU_BACKEND=vulkan cargo build --target=x86_64-unknown-linux-gnu
```

Para testar a cross-compilação sem ter o hardware alvo, podemos usar QEMU:

```bash
sudo apt-get install qemu-user-static
cargo build --target=arm-unknown-linux-gnueabihf
qemu-arm-static target/arm-unknown-linux-gnueabihf/debug/myapp
```

Exercício: Crie um projeto simples que exibe o backend gráfico disponível e compile para três plataformas diferentes (Linux, Windows, Android). Inclua um shader embutido no binário.

Solução comentada:

```rust
// main.rs
use wgpu::{Instance, Backends};

static SHADER: &str = include_str!("shader.wgsl");

fn main() {
    let instance = Instance::new(Backends::all());
    println!("Available backends: {:?}", instance.enumerate_adapters(Backends::all()));
    println!("Shader contents:\n{}", SHADER);
}
```

Compile com:
```bash
# Linux
cargo build --target=x86_64-unknown-linux-gnu

# Windows
cargo build --target=x86_64-pc-windows-msvc

# Android
cargo build --target=aarch64-linux-android
```

Este exemplo demonstra os conceitos essenciais: configuração de target, inclusão de assets e seleção de backend gráfico.