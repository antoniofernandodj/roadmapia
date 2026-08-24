## Documentação de APIs Gráficas

Em APIs gráficas, documentação ruim causa erros que só aparecem na GPU. Considere este exemplo real de um buffer de vértices mal documentado:

```rust
/// Cria um vertex buffer
pub fn create_vertex_buffer(data: &[f32]) -> BufferHandle {
    // Implementação omitida...
}
```

O que falta aqui? Tudo:
- O formato dos dados (XYZ, XYZRGB, etc.)
- O alinhamento de memória requerido
- Se os dados são copiados ou referenciados
- A validade do handle após a chamada

Resultado típico quando o usuário erra:

```
thread 'main' panicked at 'Validation Error: [Buffer] Alignment mismatch for 
vertex buffer at index 0, expected 16, got 4', src/gfx/validation.rs:45:12
```

Uma documentação eficaz em gráficos precisa incluir:

1. **Layout de memória exato** com exemplos hexadecimais:

```rust
/// Cria um buffer de vértices para posições XYZ (12 bytes por vértice)
/// 
/// # Layout
/// ```hex
/// [x: f32][y: f32][z: f32]  
/// 0x0000  0x0004  0x0008
/// ```
/// # Alinhamento
/// - Offset deve ser múltiplo de 16 bytes
/// - Stride deve ser >= 12 bytes
pub fn create_xyz_buffer(data: &[[f32; 3]]) -> BufferHandle { ... }
```

2. **Estados válidos/inválidos** explicitamente:

```rust
/// Textura 2D RGBA8 (32 bits por pixel)
///
/// # Estados válidos
/// - Imutável após criação (upload via staging buffer)
/// - Pode ser vinculada como SRV ou UAV, mas não simultaneamente
///
/// # Comportamento indefinido
/// - Ler de uma textura não inicializada
/// - Escrever após criar a view final
pub struct Texture2D { ... }
```

3. **Exemplos executáveis** mostrando o fluxo completo:

```rust
/// Pipeline de renderização básico
///
/// # Exemplo
/// ```
/// let shader = device.create_shader(include_bytes!("shader.hlsl"))?;
/// let pipeline = PipelineBuilder::new()
///     .with_vertex_shader(&shader, "VS")
///     .with_pixel_shader(&shader, "PS")
///     .with_vertex_format(Vertex::FORMAT)
///     .build(&device)?;
///
/// // Uso obrigatório dentro de um command list
/// command_list.set_pipeline(&pipeline);
/// ```
pub struct PipelineBuilder { ... }
```

4. **Limitações de threading** claramente marcadas:

```rust
/// Fence para sincronização CPU-GPU
///
/// # Segurança Thread
/// - `wait()` pode ser chamado de qualquer thread
/// - `signal()` deve ser chamado da thread gráfica
/// - Clone é `Send + Sync` mas representa o mesmo recurso GPU
#[derive(Clone)]
pub struct Fence { ... }
```

Erro comum é documentar apenas a assinatura sem os contratos:

```rust
/// Define os dados do buffer (RUIM)
pub fn set_buffer_data(&self, data: &[u8]) { ... }
```

Versão corrigida:

```rust
/// Define os dados do buffer
///
/// # Segurança
/// - `data` deve estar alinhado a 256 bytes
/// - Tamanho não pode exceder alocação original
/// - Buffer não pode estar mapeado
/// - Chamada deve ser sincronizada externamente se usada em múltiplas threads
///
/// # Panics
/// - Se o buffer foi criado como imutável
/// - Se o alinhamento não for satisfeito
pub unsafe fn set_buffer_data(&self, data: &[u8]) { ... }
```

Exercício: Documente esta função de criação de textura incluindo:
1. Formatos de pixel suportados
2. Valores válidos para width/height
3. Comportamento com mipmaps

```rust
pub fn create_texture(device: &Device, width: u32, height: u32, format: TextureFormat) -> Texture { ... }
```

Solução comentada:

```rust
/// Cria uma textura 2D vazia
///
/// # Parâmetros
/// - `width`: Largura em pixels (1..16384, deve ser potência de 2 se mipmaps)
/// - `height`: Altura em pixels (mesmas restrições)
/// - `format`: Formato de pixel (ver `TextureFormat`)
///
/// # Formatos suportados
/// - `R8Unorm`, `RGBA8UnormSrgb`
/// - `BGRA8Unorm` (apenas em Windows)
/// - `Depth32Float` para texturas de profundidade
///
/// # Mipmaps
/// - Automáticos se dimensões forem potências de 2
/// - Desativados para texturas não color (profundidade/stencil)
///
/// # Erros comuns
/// ```compile_fail
/// let tex = create_texture(device, 100, 100, TextureFormat::R8Unorm);
/// // ^ PANIC: width/height must be power of two for mipmapped textures
/// ```
pub fn create_texture(device: &Device, width: u32, height: u32, format: TextureFormat) -> Texture {
    assert!(width.is_power_of_two() && height.is_power_of_two(),
        "width/height must be power of two for mipmapped textures");
    // ...
}
```