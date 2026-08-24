## HiDPI Support

O desafio central ao renderizar interfaces em diferentes escalas de DPI está na conversão entre coordenadas físicas (pixels da tela) e lógicas (unidades da aplicação). Um erro comum é assumir que 1 pixel sempre corresponde a 1 unidade lógica — essa simplificação falha em dispositivos HiDPI onde a escala pode ser 2x ou 3x.

WGPU resolve esse problema com três componentes principais:

1. **`PhysicalPosition<T>` e `PhysicalSize<T>`**: Representam coordenadas físicas em pixels reais da tela, preservando a precisão em qualquer escala DPI.

2. **`LogicalPosition<T>` e `LogicalSize<T>`**: Trabalham em unidades lógicas da aplicação, independentes da escala física.

3. **`HiDpiFactor`**: Conversão explícita entre unidades físicas e lógicas, evitando suposições implícitas.

O código abaixo mostra como converter entre unidades físicas e lógicas:

```rust
// Coordenadas físicas (pixels reais)
let physical_pos = PhysicalPosition::new(100, 200);
let physical_size = PhysicalSize::new(300, 400);

// Fator de conversão HiDPI (2.0 para 200%)
let hidpi_factor = 2.0;

// Coordenadas lógicas (unidades da aplicação)
let logical_pos = physical_pos.to_logical(hidpi_factor);
let logical_size = physical_size.to_logical(hidpi_factor);
```

O erro mais comum é esquecer de aplicar o fator HiDPI ao renderizar elementos gráficos, resultando em elementos muito pequenos em dispositivos HiDPI. A solução é sempre converter explicitamente entre unidades físicas e lógicas:

```rust
// Renderização com conversão explícita
fn render(
    logical_size: LogicalSize<f32>,
    hidpi_factor: f32,
) {
    let physical_size = logical_size.to_physical(hidpi_factor);
    // Usar physical_size para renderizar na tela
}
```

Para elementos de texto, a conversão deve considerar o tamanho físico dos glifos no atlas de fontes. A biblioteca `wgpu_glyphs` implementa essa conversão automaticamente quando configurada com o fator HiDPI correto.

O teste abaixo verifica se a conversão entre unidades físicas e lógicas está correta:

```rust
#[test]
fn test_conversao_hidpi() {
    let tamanho_fisico = PhysicalSize::new(1000, 2000);
    let fator = 2.0;
    assert_eq!(
        tamanho_fisico.to_logical(fator),
        LogicalSize::new(500, 1000)
    );
}
```