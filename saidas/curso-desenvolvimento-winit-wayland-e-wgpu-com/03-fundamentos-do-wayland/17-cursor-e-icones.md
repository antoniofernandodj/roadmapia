## Cursor e Ícones

Quando você move o mouse sobre uma janela Wayland, o cursor não aparece magicamente. Ele é um recurso que seu cliente precisa configurar explicitamente, usando o protocolo `wl_pointer` e a interface `wl_cursor_theme`. Vamos implementar um cursor básico que segue o movimento do ponteiro.

Primeiro, precisamos carregar um tema de cursor padrão. O Wayland usa temas no formato Xcursor, que são coleções de imagens em vários tamanhos e estados:

```rust
use wayland_client::protocol::{wl_seat, wl_pointer};
use wayland_cursor::{CursorTheme, CursorImage};

// Carrega o tema padrão "default" com tamanho 24 pixels
let cursor_theme = CursorTheme::load("default", 24, connection.clone())
    .expect("Falha ao carregar tema do cursor");

// Obtém a imagem do cursor "left_ptr" (seta padrão)
let cursor_image = cursor_theme.get_cursor("left_ptr")
    .expect("Cursor não encontrado no tema");
```

Agora, precisamos vincular esse cursor ao nosso ponteiro. Quando recebermos eventos de movimento, atualizaremos a posição:

```rust
// Handler para eventos do ponteiro
pointer.quick_assign(move |pointer, event, _| {
    match event {
        wl_pointer::Event::Enter { surface, surface_x, surface_y, .. } => {
            // Quando o ponteiro entra na superfície, definimos o cursor
            cursor_image.set_pointer(&pointer);
            cursor_image.set_position(surface_x as i32, surface_y as i32);
        }
        wl_pointer::Event::Motion { surface_x, surface_y, .. } => {
            // Atualiza a posição do cursor quando o mouse se move
            cursor_image.set_position(surface_x as i32, surface_y as i32);
        }
        _ => {}
    }
});
```

Um erro comum é esquecer de chamar `set_pointer` após criar o cursor. Se fizer isso, o cursor não aparecerá, mas também não haverá mensagem de erro - o ponteiro simplesmente permanecerá invisível.

Para ícones de janela, usamos a interface `xdg_toplevel` do protocolo XDG Shell. Podemos definir um ícone para a janela assim:

```rust
use wayland_client::protocol::xdg_toplevel;

// Cria um buffer para o ícone (32x32 pixels ARGB8888)
let icon_buffer = create_shm_buffer(32, 32, wl_shm::Format::Argb8888, &shm, pool)
    .expect("Falha ao criar buffer do ícone");

// Preenche o buffer com dados de pixel (exemplo: ícone verde)
let icon_data = vec![0xFF00FF00u32; 32 * 32]; // ARGB: verde sólido
icon_buffer.write(&icon_data).expect("Falha ao escrever ícone");

// Define o ícone na janela
xdg_toplevel.set_app_id("meu-aplicativo");
xdg_toplevel.set_title("Aplicativo com Ícone");
```

Se você tentar usar um formato de pixel não suportado, como `Rgb565` para o ícone, receberá o erro:

```
thread 'main' panicked at 'Unsupported buffer format: Rgb565'
```

Para resolver, sempre verifique os formatos suportados pelo compositor:

```rust
let supported_formats = shm.get_formats().expect("Falha ao obter formatos");
if !supported_formats.contains(&wl_shm::Format::Argb8888) {
    panic!("Formato ARGB8888 não suportado pelo compositor");
}
```

Um recurso avançado é a personalização de cursores. Você pode criar um cursor totalmente customizado a partir de um buffer:

```rust
// Cria um buffer de cursor personalizado (16x16 pixels)
let custom_cursor_buffer = create_shm_buffer(16, 16, wl_shm::Format::Argb8888, &shm, pool)?;

// Preenche com um padrão (cruz vermelha)
let mut cursor_data = vec![0x00000000u32; 16 * 16]; // Transparente
for i in 0..16 {
    cursor_data[i * 16 + 7] = 0xFFFF0000; // Linha vertical vermelha
    cursor_data[8 * 16 + i] = 0xFFFF0000; // Linha horizontal vermelha
}
custom_cursor_buffer.write(&cursor_data)?;

// Cria o cursor personalizado
let custom_cursor = CursorImage::from_buffer(
    &custom_cursor_buffer,
    16, 16,  // Largura e altura
    7, 7,    // Hotspot (centro)
    connection.clone()
)?;

// Define como cursor ativo
custom_cursor.set_pointer(&pointer);
```

**Exercício:** Crie um cursor que muda de forma quando o botão esquerdo do mouse é pressionado. Quando pressionado, deve mostrar um círculo azul; quando liberado, volta à seta padrão.

**Solução:**

```rust
let circle_cursor = {
    let size = 16;
    let mut data = vec![0x00000000u32; size * size];
    // Desenha um círculo azul
    for y in 0..size {
        for x in 0..size {
            let dx = x as i32 - size as i32 / 2;
            let dy = y as i32 - size as i32 / 2;
            if dx*dx + dy*dy <= (size/2)*(size/2) {
                data[y * size + x] = 0xFF0000FF; // Azul sólido
            }
        }
    }
    let buffer = create_shm_buffer(size, size, wl_shm::Format::Argb8888, &shm, pool)?;
    buffer.write(&data)?;
    CursorImage::from_buffer(&buffer, size, size, size/2, size/2, connection.clone())?
};

pointer.quick_assign(move |pointer, event, _| {
    match event {
        wl_pointer::Event::Button { button, state, .. } if button == 0x110 => {
            // BTN_LEFT (0x110) pressionado/liberado
            match state {
                wl_pointer::ButtonState::Pressed => {
                    circle_cursor.set_pointer(&pointer);
                }
                wl_pointer::ButtonState::Released => {
                    cursor_image.set_pointer(&pointer);
                }
            }
        }
        _ => {}
    }
});
```