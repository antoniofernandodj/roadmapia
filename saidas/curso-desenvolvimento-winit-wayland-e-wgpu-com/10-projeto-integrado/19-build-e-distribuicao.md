## Build e Distribuição

Seu editor de texto Rust está funcional, mas como transformá-lo em um binário que outros usuários possam executar sem ter todo o ambiente de desenvolvimento instalado? O problema real aqui é que aplicações gráficas modernas dependem de:

1. Binários Rust compilados para a arquitetura correta
2. Shaders embutidos ou compilados
3. Recursos como ícones e fonts
4. Dependências do sistema (Wayland, Vulkan/Metal)

Vamos resolver isso passo a passo, começando pelo arquivo `Cargo.toml`:

```toml
[package]
name = "meu-editor"
version = "0.1.0"
edition = "2021"
authors = ["Seu Nome <email@exemplo.com>"]
license = "MIT OR Apache-2.0"
description = "Editor de texto minimalista"
repository = "https://github.com/usuario/meu-editor"
readme = "README.md"

[profile.release]
lto = true        # Otimização de link-time
codegen-units = 1 # Menos paralelismo = mais otimizações
panic = "abort"   # Reduz tamanho binário
```

O erro mais comum é esquecer de marcar os shaders como recursos a serem incluídos. Veja como corrigir:

```rust
// Antes (erro comum)
let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
    label: None,
    source: wgpu::ShaderSource::Wgsl(Cow::Borrowed(include_str!("shader.wgsl"))),
});

// Depois (correto)
const SHADER: &str = include_str!("shader.wgsl");

let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
    label: None,
    source: wgpu::ShaderSource::Wgsl(Cow::Borrowed(SHADER)),
});
```

Para distribuição cross-platform, precisamos lidar com três cenários:

**Linux (Wayland/X11):**
```bash
# Build otimizado
cargo build --release --target x86_64-unknown-linux-gnu

# Verifique dependências dinâmicas
ldd target/x86_64-unknown-linux-gnu/release/meu-editor

# Empacotamento mínimo (Debian/Ubuntu)
mkdir -p pkg/usr/bin
cp target/release/meu-editor pkg/usr/bin/
cp assets/*.png pkg/usr/share/icons/
```

**Windows:**
```powershell
cargo build --release --target x86_64-pc-windows-msvc

# Para incluir o runtime VC++
./target/release/meu-editor.exe
# Verifique erros como "VCRUNTIME140.dll missing"
```

**macOS:**
```bash
cargo build --release --target x86_64-apple-darwin

# Criar .app bundle
mkdir -p MeuEditor.app/Contents/MacOS
cp target/release/meu-editor MeuEditor.app/Contents/MacOS/
cp assets/AppIcon.icns MeuEditor.app/Contents/Resources/
```

Um problema frequente é o binário não encontrar os recursos em tempo de execução. A solução é usar caminhos relativos ao executável:

```rust
use std::path::PathBuf;
use std::env;

fn resource_path(relative_path: &str) -> PathBuf {
    let exe_path = env::current_exe()
        .expect("Falha ao obter caminho do executável");
    let base_dir = exe_path.parent()
        .expect("Executável sem diretório pai");
    base_dir.join(relative_path)
}

// Uso:
let icon_path = resource_path("assets/icon.png");
```

Para shaders pré-compilados (SPIR-V), adicione ao `build.rs`:

```rust
fn main() {
    // Recompilar se shaders mudarem
    println!("cargo:rerun-if-changed=src/shaders");

    // Compilar WGSL para SPIR-V (opcional)
    if let Err(e) = std::process::Command::new("glslangValidator")
        .args(&["-V", "shader.wgsl", "-o", "shader.spv"])
        .status()
    {
        eprintln!("Falha ao compilar shader: {}", e);
    }
}
```

A saída do build deve incluir:
```
meu-editor
├── bin/            # Executável principal
├── lib/            # Dependências dinâmicas (se aplicável)
├── assets/         # Shaders, ícones, fonts
│   ├── shader.wgsl
│   └── icon.png
└── README.md       # Instruções de instalação
```

Erro comum ao distribuir:
```
thread 'main' panicked at 'Failed to load shader: InvalidShader', src/main.rs:15:10
```

Solução: verifique se o shader está no diretório correto relativo ao binário ou use `include_str!` para embutir.

**Exercício:** Crie um script `package.sh` que:
1. Compila o release
2. Cria a estrutura de diretórios
3. Copia os recursos
4. Gera um arquivo .zip pronto para distribuição

**Solução:**
```bash
#!/bin/bash
set -e

TARGET="x86_64-unknown-linux-gnu"
BINARY="target/$TARGET/release/meu-editor"
OUT_DIR="dist/meu-editor"

# Limpar e compilar
cargo build --release --target $TARGET

# Criar estrutura
mkdir -p "$OUT_DIR"/{bin,assets}
cp "$BINARY" "$OUT_DIR/bin/"
cp -r assets/* "$OUT_DIR/assets/"

# Compactar
(cd dist && zip -r meu-editor.zip meu-editor)

echo "Pacote criado em dist/meu-editor.zip"
```