## Cursor Básico

Um cursor é a representação visual do ponteiro do mouse na tela. Em um compositor Wayland, o cursor é uma `wl_surface` especial que segue os movimentos do ponteiro e pode mudar de forma dependendo da interação do usuário. Para implementar um cursor básico, precisamos criar uma surface, associar um buffer de pixels a ela e atualizar sua posição conforme os eventos de movimento do mouse.

Começamos criando uma surface para o cursor. Em Wayland, isso é feito através da interface `wl_compositor`, que já deve estar disponível como parte do registro global:

```rust
let cursor_surface = compositor.create_surface();
```

Assumindo que `compositor` é uma instância de `wl_compositor` criada anteriormente. A surface do cursor é como qualquer outra surface, mas ela será movida automaticamente pelo compositor conforme o ponteiro do mouse se desloca.

O próximo passo é fornecer um buffer de pixels para a surface. Para um cursor básico, podemos criar um buffer simples com uma imagem de 32x32 pixels em formato ARGB8888:

```rust
let cursor_buffer = create_cursor_buffer(32, 32);
cursor_surface.attach(Some(&cursor_buffer), 0, 0);
cursor_surface.commit();
```

A função `create_cursor_buffer` gera um buffer com uma imagem simples de um cursor. Aqui está uma implementação básica:

```rust
fn create_cursor_buffer(width: u32, height: u32) -> wl_buffer::WlBuffer {
    let mut pixels = Vec::with_capacity((width * height * 4) as usize);
    for y in 0..height {
        for x in 0..width {
            let alpha = if x < 16 && y < 16 { 255 } else { 0 };
            let red = 255;
            let green = 255;
            let blue = 255;
            pixels.push(alpha);
            pixels.push(red);
            pixels.push(green);
            pixels.push(blue);
        }
    }
    // Criação do buffer com os pixels gerados
    // (implementação específica depende da biblioteca usada)
}
```

Este código cria um cursor branco simples em um quadrado de 32x32 pixels, com transparência fora da área de 16x16 pixels no canto superior esquerdo.

Para que o cursor seja exibido corretamente, precisamos associá-lo ao ponteiro do mouse. Isso é feito através da interface `wl_pointer`, que representa o dispositivo de ponteiro (mouse) no protocolo Wayland:

```rust
pointer.set_cursor(serial, &cursor_surface, 0, 0);
```

Aqui, `serial` é um número que identifica o evento de entrada atual, `cursor_surface` é a surface que criamos para o cursor, e `0, 0` são os offsets do hotspot (o ponto de interação do cursor, que geralmente é a ponta da seta).

Um erro comum é esquecer de atualizar a posição do cursor após movimentar o ponteiro. O Wayland não atualiza automaticamente a posição da surface do cursor; você precisa fazer isso manualmente com base nos eventos de movimento do ponteiro:

```rust
pointer.handle_motion(|event| {
    let (x, y) = event.position;
    cursor_surface.set_position(x as i32, y as i32);
    cursor_surface.commit();
});
```

Este código atualiza a posição da surface do cursor para seguir o ponteiro do mouse e comita as alterações para que sejam aplicadas.

**Exercício:** Modifique o código acima para criar um cursor personalizado com uma imagem diferente (por exemplo, uma seta vermelha). Teste o cursor em diferentes posições da tela e verifique se o hotspot está correto.

**Solução:** Para criar um cursor personalizado, modifique a função `create_cursor_buffer` para gerar uma imagem de seta vermelha. Aqui está uma implementação básica:

```rust
fn create_cursor_buffer(width: u32, height: u32) -> wl_buffer::WlBuffer {
    let mut pixels = Vec::with_capacity((width * height * 4) as usize);
    for y in 0..height {
        for x in 0..width {
            let alpha = if x >= 16 && y >= 16 { 255 } else { 0 };
            let red = 255;
            let green = 0;
            let blue = 0;
            pixels.push(alpha);
            pixels.push(red);
            pixels.push(green);
            pixels.push(blue);
        }
    }
    // Criação do buffer com os pixels gerados
    // (implementação específica depende da biblioteca usada)
}
```

Este código cria um cursor vermelho em um quadrado de 32x32 pixels, com transparência fora da área de 16x16 pixels no canto inferior direito. O hotspot deve ser ajustado para `16, 16` para corresponder à ponta da seta:

```rust
pointer.set_cursor(serial, &cursor_surface, 16, 16);
```