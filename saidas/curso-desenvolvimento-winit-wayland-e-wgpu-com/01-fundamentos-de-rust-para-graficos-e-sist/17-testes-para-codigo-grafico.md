## Testes para Código Gráfico

Em aplicações gráficas, testar o resultado visual tradicionalmente exigia verificação manual - até que o teste falhasse silenciosamente. Vamos implementar um sistema que compara imagens renderizadas com referências conhecidas, detectando regressões automaticamente.

O cerne da solução é codificar a imagem renderizada em um buffer de pixels e compará-lo com uma versão pré-aprovada. Comecemos com um teste para verificar se um shader simples produz a cor esperada:

```rust
#[test]
fn test_shader_output() {
    let mut renderer = TestRenderer::new(256, 256);
    renderer.draw_test_triangle();
    
    let expected_color = [0.2, 0.4, 0.6, 1.0]; // RGBA
    let pixel = renderer.read_pixel(128, 128);
    
    assert_within_tolerance!(pixel, expected_color, 0.01);
}
```

Onde `assert_within_tolerance!` é uma macro customizada que permite pequenas variações devido a diferenças entre drivers GPU:

```rust
macro_rules! assert_within_tolerance {
    ($actual:expr, $expected:expr, $tolerance:expr) => {
        for (a, e) in $actual.iter().zip($expected.iter()) {
            if (a - e).abs() > $tolerance {
                panic!("Value {} differs from expected {} by more than {}", 
                    a, e, $tolerance);
            }
        }
    };
}
```

Um erro comum é esquecer de limpar o framebuffer entre testes, causando vazamento de estado:

```text
thread 'test_shader_output' panicked at 'Value 0.8 differs from expected 0.2 by more than 0.01'
```

A correção exige resetar o estado GPU antes de cada teste:

```rust
impl TestRenderer {
    pub fn reset(&mut self) {
        self.device.clear_frame(clear_color::BLACK);
    }
}

#[test]
fn test_consecutive_draws() {
    let mut renderer = TestRenderer::new(256, 256);
    
    renderer.draw_red_rectangle();
    renderer.reset(); // Sem isso, o próximo teste herda o estado
    
    renderer.draw_blue_circle();
    let pixel = renderer.read_pixel(64, 64);
    assert_eq!(pixel, [0.0, 0.0, 1.0, 1.0]);
}
```

Para testar renderização 3D, capturamos múltiplos ângulos e comparamos com referências. Esta técnica encontrou um bug em nosso pipeline de sombreamento:

```rust
#[test]
fn test_shadow_map_consistency() {
    let mut test_scene = TestScene::load("shadow_test");
    let reference = load_reference_image("shadow_reference.png");
    
    test_scene.render_from((0.0, 1.0, 2.0));
    let result = test_scene.capture_frame();
    
    let diff = compare_images(&result, &reference);
    assert!(diff < 0.05, "Shadow mapping differs by {}%", diff * 100.0);
}
```

A função `compare_images` usa diferença quadrática média (MSE) para quantificar variações:

```rust
fn compare_images(a: &ImageBuffer, b: &ImageBuffer) -> f32 {
    assert_eq!(a.dimensions(), b.dimensions());
    
    let mut sum = 0.0;
    for (pixel_a, pixel_b) in a.pixels().zip(b.pixels()) {
        sum += pixel_a.distance_squared(pixel_b);
    }
    
    sum / (a.width() * a.height()) as f32
}
```

Em sistemas reais, adotamos uma estratégia de "golden images" - imagens de referência armazenadas junto ao código. O CI rejeita commits que alteram a renderização sem atualizar as referências:

```text
$ cargo test
...
FAIL: Shadow mapping differs by 12.3% (allowed: 5%)
To update reference: cp target/test_output/shadow_test.png tests/references/
```

Exercício: Implemente um teste para verificar se um efeito de blur aplicado a uma textura produz o resultado esperado. A solução deve:
1. Carregar uma textura de teste
2. Aplicar blur gaussiano 5x5
3. Comparar com uma referência pré-computada
4. Permitir 2% de diferença devido a implementações diferentes

Solução:

```rust
#[test]
fn test_gaussian_blur() {
    let texture = load_test_texture("checkerboard.png");
    let blurred = apply_gaussian_blur(&texture, 5);
    let reference = load_reference("blurred_checkerboard.png");
    
    let diff = compare_images(&blurred, &reference);
    assert!(diff <= 0.02, "Blur result exceeds tolerance: {}", diff);
}

fn apply_gaussian_blur(texture: &Texture, kernel_size: u32) -> ImageBuffer {
    let mut buffer = texture.to_buffer();
    let kernel = generate_gaussian_kernel(kernel_size);
    
    // Aplicação do kernel separável
    for _ in 0..2 { // Passada horizontal e vertical
        buffer = convolve(&buffer, &kernel);
    }
    
    buffer
}
```