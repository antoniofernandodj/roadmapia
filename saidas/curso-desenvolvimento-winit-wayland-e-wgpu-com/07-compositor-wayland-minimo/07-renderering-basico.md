## Renderering Básico

Um compositor Wayland precisa transformar surfaces (áreas retangulares que os clientes desejam exibir) em pixels no framebuffer. Sem aceleração gráfica, isso significa copiar manualmente regiões de memória, lidando com formatos de pixel, transparência e sobreposição.

Vamos implementar um renderizador que compõe surfaces em um buffer de 32 bits por pixel (ARGB8888), o formato mais comum para software rendering. Começamos definindo nosso framebuffer:

```rust
pub struct Framebuffer {
    width: u32,
    height: u32,
    pixels: Vec<u32>, // ARGB8888, linha principal (row-major)
}

impl Framebuffer {
    pub fn new(width: u32, height: u32) -> Self {
        Self {
            width,
            height,
            pixels: vec![0xFF_00_00_00; (width * height) as usize], // Preto opaco
        }
    }

    pub fn clear(&mut self, argb: u32) {
        self.pixels.fill(argb);
    }
}
```

Para testar, criamos um framebuffer 800x600 e o preenchemos com vermelho semitransparente:

```rust
let mut fb = Framebuffer::new(800, 600);
fb.clear(0x80_FF_00_00); // Vermelho com alpha=0x80 (50%)
```

Agora precisamos copiar surfaces para o framebuffer. Uma surface Wayland pode ter um buffer anexado via `wl_surface.attach()`. Vamos definir uma representação simplificada:

```rust
pub struct Surface {
    buffer: Option<Vec<u32>>,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
}

impl Surface {
    pub fn new(buffer: Vec<u32>, width: u32, height: u32) -> Self {
        Self {
            buffer: Some(buffer),
            x: 0,
            y: 0,
            width,
            height,
        }
    }
}
```

O método central é `Framebuffer::blit_surface()`, que copia pixels com blending alpha:

```rust
impl Framebuffer {
    pub fn blit_surface(&mut self, surface: &Surface) {
        let Some(src) = &surface.buffer else { return };
        
        for y in 0..surface.height {
            for x in 0..surface.width {
                let dst_x = surface.x + x as i32;
                let dst_y = surface.y + y as i32;
                
                if dst_x < 0 || dst_y < 0 
                    || dst_x >= self.width as i32 
                    || dst_y >= self.height as i32 {
                    continue;
                }

                let src_idx = (y * surface.width + x) as usize;
                let dst_idx = (dst_y as u32 * self.width + dst_x as u32) as usize;
                
                let src_pixel = src[src_idx];
                let dst_pixel = self.pixels[dst_idx];
                
                // Blending alpha simples (over operator)
                let src_a = ((src_pixel >> 24) & 0xFF) as u32;
                let dst_a = ((dst_pixel >> 24) & 0xFF) as u32;
                
                let out_a = src_a + dst_a * (255 - src_a) / 255;
                
                let blend = |src_c, dst_c| {
                    (src_c * src_a + dst_c * (255 - src_a) * dst_a / 255) / out_a
                };
                
                let r = blend((src_pixel >> 16) & 0xFF, (dst_pixel >> 16) & 0xFF);
                let g = blend((src_pixel >> 8) & 0xFF, (dst_pixel >> 8) & 0xFF);
                let b = blend(src_pixel & 0xFF, dst_pixel & 0xFF);
                
                self.pixels[dst_idx] = (out_a << 24) | (r << 16) | (g << 8) | b;
            }
        }
    }
}
```

Testando com duas surfaces sobrepostas:

```rust
let mut fb = Framebuffer::new(800, 600);
fb.clear(0xFF_00_00_00); // Fundo preto

// Surface azul (200x200)
let blue_surface = Surface {
    buffer: Some(vec![0x80_00_00_FF; 200 * 200]), // Azul semitransparente
    x: 100,
    y: 100,
    width: 200,
    height: 200,
};

// Surface verde (150x150)
let green_surface = Surface {
    buffer: Some(vec![0x80_00_FF_00; 150 * 150]), // Verde semitransparente
    x: 150,
    y: 150,
    width: 150,
    height: 150,
};

fb.blit_surface(&blue_surface);
fb.blit_surface(&green_surface);
```

O resultado mostra a sobreposição com blending correto - onde as surfaces se cruzam, as cores se misturam proporcionalmente aos valores alpha.

**Erro comum**: esquecer de verificar os limites do framebuffer. Se removermos as verificações de `dst_x` e `dst_y`, tentaremos acessar índices inválidos quando uma surface estiver parcialmente fora da tela:

```
thread 'main' panicked at 'index out of bounds: the len is 480000 but the index is 483200'
```

**Otimização**: O código atual percorre todos os pixels, mesmo quando a surface está totalmente fora da tela. Podemos adicionar uma verificação inicial:

```rust
if surface.x + surface.width as i32 <= 0 
    || surface.y + surface.height as i32 <= 0
    || surface.x >= self.width as i32
    || surface.y >= self.height as i32 {
    return; // Surface totalmente fora da tela
}
```

**Exercício**: Implemente `Framebuffer::to_rgba()` que converte o buffer interno (ARGB) para RGBA, formato esperado por muitas APIs de exibição. A solução deve lidar com endianness (bytes mais significativos primeiro).

```rust
impl Framebuffer {
    pub fn to_rgba(&self) -> Vec<u8> {
        let mut output = vec![0; (self.width * self.height * 4) as usize];
        for (i, &pixel) in self.pixels.iter().enumerate() {
            output[i * 4] = ((pixel >> 16) & 0xFF) as u8; // R
            output[i * 4 + 1] = ((pixel >> 8) & 0xFF) as u8; // G
            output[i * 4 + 2] = (pixel & 0xFF) as u8; // B
            output[i * 4 + 3] = ((pixel >> 24) & 0xFF) as u8; // A
        }
        output
    }
}
```