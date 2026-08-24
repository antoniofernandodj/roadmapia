## Integração Contínua para Projetos Gráficos

Projetos gráficos em Rust enfrentam desafios únicos em CI: precisam de drivers GPU, lidam com assets binários grandes e exigem validação visual. Um pipeline básico precisa:

1. Compilar para múltiplos backends (Vulkan, Metal, DX12)
2. Executar testes funcionais sem display real
3. Validar saída gráfica de forma automatizada

Comece com este `.github/workflows/ci.yml` mínimo:

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions-rs/toolchain@v1
        with:
          profile: minimal
          toolchain: stable
          override: true
      - run: sudo apt-get install -y libvulkan-dev mesa-vulkan-drivers
      - uses: actions-rs/cargo@v1
        with:
          command: test
          args: --no-run
      - run: |
          xvfb-run cargo test -- --test-threads=1
          cargo test --features headless -- --test-threads=1
```

O segredo está no `xvfb-run` (X Virtual Frame Buffer) que simula um display para testes gráficos. Mesmo sem monitor físico, o WGPU pode criar contextos Vulkan/GLES.

Para validar renderização, crie testes que comparam buffers de pixels:

```rust
#[test]
fn test_triangle_rendering() {
    let expected = load_expected_pixels("tests/expected/triangle.png");
    let actual = render_test_scene();
    
    assert_pixels_match(&expected, &actual, 0.95); // 95% de similaridade
}

fn assert_pixels_match(expected: &[u8], actual: &[u8], threshold: f32) {
    let mut matches = 0;
    for (e, a) in expected.chunks_exact(4).zip(actual.chunks_exact(4)) {
        if e == a { matches += 1; }
    }
    
    let similarity = matches as f32 / (expected.len() / 4) as f32;
    assert!(
        similarity >= threshold,
        "Similaridade de pixels {:.2}% abaixo do threshold (esperado >= {:.0}%)",
        similarity * 100.0,
        threshold * 100.0
    );
}
```

Erro comum é esquecer de instalar os drivers Vulkan no runner. A mensagem de erro será clara:

```
error: failed to create instance: VkError(ERROR_INCOMPATIBLE_DRIVER)
```

A solução está no passo `sudo apt-get install` do workflow. Para Windows runners, use:

```yaml
- run: choco install vulkan --no-progress
```

Projetos complexos precisam cachear assets. Adicione:

```yaml
- uses: actions/cache@v3
  with:
    path: |
      ~/.cargo/registry
      ~/.cargo/git
      assets
    key: ${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}-${{ hashFiles('assets/**') }}
```

Para testar múltiplos backends, use matrizes:

```yaml
strategy:
  matrix:
    backend: ["vulkan", "metal", "dx12"]
    include:
      - backend: "vulkan"
        os: ubuntu-latest
        install: sudo apt-get install -y libvulkan-dev
      - backend: "metal"
        os: macos-latest
        install: true # Metal vem com macOS
      - backend: "dx12"
        os: windows-latest
        install: choco install directx --no-progress
```

E configure o teste via variável de ambiente:

```rust
#[test]
fn backend_specific_test() {
    let backend = std::env::var("WGPU_BACKEND").unwrap();
    // Testes condicionais por backend
}
```

Exercício: Crie um workflow que:
1. Compila em Linux, Windows e macOS
2. Testa com Vulkan, Metal e DX12
3. Valida um shader simples renderiza um quadrado vermelho

Solução:

```yaml
name: Cross-Platform CI
on: [push]

jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        backend: ["vulkan", "metal", "dx12"]
        exclude:
          - os: ubuntu-latest
            backend: "metal"
          - os: ubuntu-latest
            backend: "dx12"
          - os: macos-latest
            backend: "dx12"
          - os: windows-latest
            backend: "metal"
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - run: ${{ matrix.install }}
      - run: echo "WGPU_BACKEND=${{ matrix.backend }}" >> $GITHUB_ENV
      - run: cargo test --features headless --no-fail-fast
```