## Build Systems e Feature Flags

Ao desenvolver gráficos em Rust, frequentemente precisamos suportar múltiplos backends (Vulkan, Metal, DirectX) e plataformas (Linux, Windows, macOS). O Cargo oferece dois mecanismos cruciais para isso: features condicionais e configuração de dependências.

**O problema real**: Imagine que sua biblioteca precisa suportar tanto Vulkan quanto Metal, mas:

1. Vulkan requer a crate `ash` no Linux, mas não no macOS
2. Metal requer `metal-rs` apenas no macOS
3. Alguns usuários querem apenas um backend específico para reduzir tempo de compilação

Sem features condicionais, você acabaria com todas as dependências em todas as plataformas, aumentando desnecessariamente o tamanho do binário e o tempo de build.

### Implementando Backends Condicionais

Vamos criar uma estrutura modular para renderização:

```rust
// Cargo.toml
[features]
default = ["vulkan"]
vulkan = ["dep:ash", "dep:gpu-alloc"]
metal = ["dep:metal-rs", "dep:block"]
dx12 = ["dep:d3d12", "dep:winapi"]

[target.'cfg(target_os = "linux")'.dependencies]
ash = { version = "0.37", optional = true }

[target.'cfg(target_os = "macos")'.dependencies]
metal-rs = { version = "2.5", optional = true }
```

No código principal:

```rust
#[cfg(feature = "vulkan")]
mod vulkan {
    pub struct VulkanRenderer {
        device: ash::Device,
        // ...
    }
    // Implementação específica do Vulkan
}

#[cfg(all(feature = "metal", target_os = "macos"))]
mod metal {
    use metal_rs::Device;
    pub struct MetalRenderer {
        device: Device,
        // ...
    }
    // Implementação específica do Metal
}
```

**Erro comum**: tentar usar um backend não suportado na plataforma atual gera:

```rust
error[E0433]: failed to resolve: use of undeclared crate `metal_rs`
  --> src/backend.rs:15:12
   |
15 |     use metal_rs::Device;
   |            ^^^^^^^ use of undeclared crate `metal_rs`
```

A solução é verificar as features ativas:

```rust
pub fn create_renderer() -> Result<Box<dyn Renderer>, RenderError> {
    #[cfg(feature = "vulkan")]
    {
        Ok(Box::new(vulkan::VulkanRenderer::new()?))
    }
    #[cfg(all(feature = "metal", target_os = "macos"))]
    {
        Ok(Box::new(metal::MetalRenderer::new()?))
    }
    #[cfg(not(any(feature = "vulkan", all(feature = "metal", target_os = "macos"))))]
    {
        Err(RenderError::NoBackendAvailable)
    }
}
```

### Features Nativas vs. Features Customizadas

Features podem depender de:

1. **Configuração da plataforma**:
```rust
#[cfg(target_pointer_width = "64")]
mod native_64 {
    // Código otimizado para 64 bits
}
```

2. **Features de outras crates**:
```rust
#[cfg(feature = "serde")]
impl serde::Serialize for Vertex {
    // Implementação customizada de serialização
}
```

3. **Combinações complexas**:
```rust
#[cfg(all(
    any(target_os = "linux", target_os = "windows"),
    feature = "gpu_profiling"
))]
mod profiling {
    // Código de profiling específico para Linux/Windows
}
```

### Gerenciamento de Build com Workspaces

Para projetos grandes, divida em workspaces:

```
.
├── Cargo.toml (workspace)
├── core/
│   ├── Cargo.toml
│   └── src/ (lógica compartilhada)
├── vulkan/
│   ├── Cargo.toml
│   └── src/ (backend Vulkan)
└── metal/
    ├── Cargo.toml
    └── src/ (backend Metal)
```

No Cargo.toml raiz:

```toml
[workspace]
members = ["core", "vulkan", "metal"]
resolver = "2" # Melhor para features unificadas
```

**Dica crucial**: Use `--features` e `--no-default-features` durante desenvolvimento:

```bash
# Build apenas com Vulkan no Linux
cargo build --no-default-features --features vulkan

# Build com todos os backends suportados
cargo build --all-features
```

### Exercício Prático

Crie um sistema de logging que:

1. Use `env_logger` quando a feature "std" estiver ativa
2. Use `defmt` (logging embarcado) quando a feature "embedded" estiver ativa
3. Desabilite todo logging quando nenhuma feature estiver ativa

**Solução**:

```rust
// Cargo.toml
[features]
default = ["std"]
std = ["dep:env_logger"]
embedded = ["dep:defmt"]

// src/log.rs
#[cfg(feature = "std")]
pub fn init() {
    env_logger::init();
    log::info!("Logger std inicializado");
}

#[cfg(feature = "embedded")]
pub fn init() {
    defmt::info!("Logger embarcado pronto");
}

#[cfg(not(any(feature = "std", feature = "embedded")))]
pub fn init() {
    // Nada a fazer
}
```

Teste com:
```bash
cargo test --no-default-features --features embedded
cargo test --features std
```