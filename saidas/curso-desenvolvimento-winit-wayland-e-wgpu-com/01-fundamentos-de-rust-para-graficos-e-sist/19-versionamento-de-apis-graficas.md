## Versionamento de APIs Gráficas

Quando você trabalha com APIs gráficas como Vulkan, Metal ou DirectX, uma constante é a evolução: novos recursos são adicionados, comportamentos mudam e extensões são promovidas a padrão. Em Rust, podemos usar o sistema de tipos para gerenciar essas variações de forma segura e explícita.

Considere um exemplo concreto: suponha que nossa aplicação precise lidar com duas versões de uma API de textura, onde a versão 2.0 introduz um novo parâmetro de compressão:

```rust
pub struct TextureSpecV1 {
    pub width: u32,
    pub height: u32,
    pub format: TextureFormat,
    pub mip_levels: u32,
}

pub struct TextureSpecV2 {
    pub width: u32,
    pub height: u32,
    pub format: TextureFormat,
    pub mip_levels: u32,
    pub compression: CompressionMode,  // Novo campo na V2
}
```

A abordagem ingênua seria criar funções separadas para cada versão, mas isso rapidamente se torna insustentável. Em vez disso, podemos usar traits para abstrair as diferenças:

```rust
pub trait TextureApi {
    type Spec;
    
    fn create_texture(&self, spec: Self::Spec) -> Result<TextureHandle, ApiError>;
    fn destroy_texture(&self, handle: TextureHandle);
}

impl TextureApi for ApiV1 {
    type Spec = TextureSpecV1;
    
    fn create_texture(&self, spec: Self::Spec) -> Result<TextureHandle, ApiError> {
        // Implementação para V1
        Ok(TextureHandle::new())
    }
    
    fn destroy_texture(&self, handle: TextureHandle) {
        // Liberação V1
    }
}

impl TextureApi for ApiV2 {
    type Spec = TextureSpecV2;
    
    fn create_texture(&self, spec: Self::Spec) -> Result<TextureHandle, ApiError> {
        // Implementação para V2 com compressão
        Ok(TextureHandle::new())
    }
    
    fn destroy_texture(&self, handle: TextureHandle) {
        // Liberação V2
    }
}
```

O erro comum aqui é tentar usar um `Spec` de versão incorreta. O compilador nos protege disso:

```rust
let api_v1 = ApiV1::new();
let spec_v2 = TextureSpecV2 { /* ... */ };

// ERRO: type mismatch
// api_v1.create_texture(spec_v2);
```

Para código que precisa trabalhar com múltiplas versões, podemos usar um enum que encapsula todas as variações:

```rust
pub enum AnyTextureSpec {
    V1(TextureSpecV1),
    V2(TextureSpecV2),
}

impl AnyTextureSpec {
    pub fn into_v1(self) -> Option<TextureSpecV1> {
        match self {
            Self::V1(spec) => Some(spec),
            _ => None,
        }
    }
    
    pub fn into_v2(self) -> Option<TextureSpecV2> {
        match self {
            Self::V2(spec) => Some(spec),
            _ => None,
        }
    }
}
```

Na prática, você frequentemente precisará converter entre versões. Aqui está um exemplo de como lidar com fallbacks quando um recurso não está disponível:

```rust
fn create_best_texture(api: &impl TextureApi, spec: AnyTextureSpec) -> Result<TextureHandle, ApiError> {
    match api {
        ApiV1 => {
            let spec_v1 = spec.into_v1()
                .ok_or(ApiError::IncompatibleVersion)?;
            api.create_texture(spec_v1)
        },
        ApiV2 => {
            if let Some(spec_v2) = spec.into_v2() {
                api.create_texture(spec_v2)
            } else if let Some(spec_v1) = spec.into_v1() {
                // Fallback: converter V1 para V2 com compressão padrão
                let spec_v2 = TextureSpecV2 {
                    width: spec_v1.width,
                    height: spec_v1.height,
                    format: spec_v1.format,
                    mip_levels: spec_v1.mip_levels,
                    compression: CompressionMode::default(),
                };
                api.create_texture(spec_v2)
            } else {
                Err(ApiError::IncompatibleVersion)
            }
        }
    }
}
```

A saída de erro quando a conversão falha é explícita:

```
Error: ApiError { kind: IncompatibleVersion, message: "Cannot convert V2 spec to V1" }
```

Para APIs mais complexas, podemos usar builders que adaptam automaticamente os parâmetros:

```rust
pub struct TextureBuilder {
    width: u32,
    height: u32,
    format: TextureFormat,
    mip_levels: Option<u32>,
    compression: Option<CompressionMode>,
}

impl TextureBuilder {
    pub fn new(width: u32, height: u32, format: TextureFormat) -> Self {
        Self {
            width,
            height,
            format,
            mip_levels: None,
            compression: None,
        }
    }
    
    pub fn build_v1(self) -> TextureSpecV1 {
        TextureSpecV1 {
            width: self.width,
            height: self.height,
            format: self.format,
            mip_levels: self.mip_levels.unwrap_or(1),
        }
    }
    
    pub fn build_v2(self) -> TextureSpecV2 {
        TextureSpecV2 {
            width: self.width,
            height: self.height,
            format: self.format,
            mip_levels: self.mip_levels.unwrap_or(1),
            compression: self.compression.unwrap_or_default(),
        }
    }
}
```

**Exercício Prático**: Implemente um sistema de versionamento para um buffer de vértices onde a V2 adiciona suporte a formatos de vértice intercalados (interleaved). Crie:
1. Structs `VertexBufferSpecV1` e `VertexBufferSpecV2`
2. Trait `VertexBufferApi` com métodos `create_buffer` e `destroy_buffer`
3. Enum `AnyVertexBufferSpec` com métodos de conversão
4. Função `create_best_buffer` com fallback automático

**Solução comentada**:

```rust
// 1. Structs para cada versão
pub struct VertexBufferSpecV1 {
    pub data: Vec<u8>,
    pub stride: usize,
    pub vertex_count: usize,
}

pub struct VertexBufferSpecV2 {
    pub data: Vec<u8>,
    pub stride: usize,
    pub vertex_count: usize,
    pub interleaved: bool,  // Novo campo na V2
}

// 2. Trait comum
pub trait VertexBufferApi {
    type Spec;
    
    fn create_buffer(&self, spec: Self::Spec) -> Result<BufferHandle, ApiError>;
    fn destroy_buffer(&self, handle: BufferHandle);
}

// 3. Enum para especificações múltiplas
pub enum AnyVertexBufferSpec {
    V1(VertexBufferSpecV1),
    V2(VertexBufferSpecV2),
}

impl AnyVertexBufferSpec {
    pub fn into_v1(self) -> Option<VertexBufferSpecV1> {
        match self {
            Self::V1(spec) => Some(spec),
            _ => None,
        }
    }
    
    pub fn into_v2(self) -> Option<VertexBufferSpecV2> {
        match self {
            Self::V2(spec) => Some(spec),
            _ => None,
        }
    }
}

// 4. Função com fallback
fn create_best_buffer(
    api: &impl VertexBufferApi,
    spec: AnyVertexBufferSpec
) -> Result<BufferHandle, ApiError> {
    match api {
        ApiV1 => {
            let spec_v1 = spec.into_v1()
                .ok_or(ApiError::IncompatibleVersion)?;
            api.create_buffer(spec_v1)
        },
        ApiV2 => {
            if let Some(spec_v2) = spec.into_v2() {
                api.create_buffer(spec_v2)
            } else if let Some(spec_v1) = spec.into_v1() {
                // Fallback: converter V1 para V2 com interleaved=false
                let spec_v2 = VertexBufferSpecV2 {
                    data: spec_v1.data,
                    stride: spec_v1.stride,
                    vertex_count: spec_v1.vertex_count,
                    interleaved: false,
                };
                api.create_buffer(spec_v2)
            } else {
                Err(ApiError::IncompatibleVersion)
            }
        }
    }
}
```