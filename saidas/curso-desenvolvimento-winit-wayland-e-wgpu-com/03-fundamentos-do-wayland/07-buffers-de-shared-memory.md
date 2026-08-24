## Buffers de Shared Memory

Quando você precisa enviar pixels para o compositor Wayland, copiar cada frame através da comunicação IPC seria proibitivamente lento. A solução é usar shared memory (memória compartilhada) via o protocolo `wl_shm`, onde cliente e servidor acessam a mesma região de memória sem cópias extras.

Começamos criando um pool de shared memory associado a um arquivo mapeado em memória (`memfd` no Linux). Esse arquivo especial existe apenas na RAM, mas pode ser tratado como um arquivo comum para fins de mapeamento:

```rust
use std::os::unix::io::FromRawFd;
use nix::sys::memfd;

let memfd = memfd::memfd_create("wl_shm_pool", memfd::MemFdCreateFlags::empty())?;
let file = unsafe { std::fs::File::from_raw_fd(memfd) };
let pool = shm.create_pool(file.as_raw_fd(), buffer_size as i32);
```

Um erro comum é esquecer de ajustar o tamanho do arquivo antes de mapeá-lo. Sem isso, você receberá um `ENOMEM` ao tentar acessar a memória:

```text
thread 'main' panicked at 'mmap failed: Cannot allocate memory'
```

Corrija isso com `ftruncate`:

```rust
use nix::unistd::ftruncate;

ftruncate(memfd, buffer_size as i64)?;
```

Com o pool criado, alocamos buffers dentro dele. Cada buffer representa uma região retangular de pixels que pode ser anexada a uma surface:

```rust
let buffer = pool.create_buffer(
    0,                      // offset
    width as i32,          // largura
    height as i32,         // altura
    stride as i32,         // bytes por linha
    wl_shm::Format::Xrgb8888, // formato dos pixels
)?;
```

O formato `Xrgb8888` é o mais comum - 32 bits por pixel (8 para vermelho, verde e azul, 8 não usados). Outros formatos como `Argb8888` (com alpha) podem não ser suportados por todos os compositors.

Para escrever pixels, mapeamos a memória e preenchemos manualmente. Este exemplo cria um gradiente simples:

```rust
use memmap2::MmapMut;

let mut mmap = unsafe { MmapMut::map_mut(&file)? };
let pixels = mmap.as_mut_ptr() as *mut u32;

for y in 0..height {
    for x in 0..width {
        let offset = y * stride / 4 + x;
        unsafe {
            pixels.add(offset).write(
                0xff000000 | // Alpha (ignorado em Xrgb8888)
                ((x * 255 / width) as u32) << 16 | // R
                ((y * 255 / height) as u32) << 8   // G
            );
        }
    }
}
```

Erro crítico: esquecer de sincronizar o acesso à memória. O compositor pode estar lendo enquanto você escreve. A solução é usar `msync` ou (mais eficiente) double buffering:

```rust
use nix::sys::mman;

mman::msync(mmap.as_mut_ptr(), mmap.len(), mman::MsFlags::MS_SYNC)?;
```

Finalmente, anexamos o buffer à surface e fazemos commit:

```rust
surface.attach(Some(&buffer), 0, 0);
surface.damage(0, 0, width as i32, height as i32);
surface.commit();
```

O compositor agora pode ler os pixels diretamente da memória compartilhada. Quando terminar, libere os recursos na ordem inversa:

```rust
buffer.destroy();
pool.destroy();
drop(mmap); // libera o mapeamento
drop(file); // fecha o memfd
```

**Exercício**: Modifique o exemplo para implementar double buffering - crie dois buffers e alterne entre eles a cada frame. Mostre um retângulo colorido que se move horizontalmente.

**Solução**:

```rust
let buffer1 = pool.create_buffer(/* ... */)?;
let buffer2 = pool.create_buffer(/* ... */)?;
let mut current_buffer = &buffer1;

// No loop de redesenho:
let next_buffer = if current_buffer == &buffer1 { &buffer2 } else { &buffer1 };

// Escreve em next_buffer
surface.attach(Some(next_buffer), 0, 0);
surface.commit();
current_buffer = next_buffer;
```