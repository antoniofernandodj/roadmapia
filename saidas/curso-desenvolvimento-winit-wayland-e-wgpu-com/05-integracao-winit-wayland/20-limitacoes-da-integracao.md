## Limitações da Integração

A integração entre Winit e Wayland oferece controle direto sobre a interface gráfica, mas traz restrições significativas que todo desenvolvedor deve entender antes de projetar aplicações complexas. Vamos explorar essas limitações através de exemplos práticos e mensagens de erro reais.

### 1. Protocolos Ausentes

Muitos recursos avançados dependem de protocolos Wayland específicos que podem não estar disponíveis em todos os compositors. Veja o que acontece ao tentar usar o protocolo `zwlr_layer_shell_v1` para criar uma janela flutuante:

```rust
use winit::platform::wayland::WindowExtWayland;

let window = WindowBuilder::new()
    .with_decorations(false)
    .build(&event_loop)?;

let layer_surface = unsafe {
    window.wayland_surface()
        .and_then(|s| s.as_ref().display().bind::<ZwlrLayerShellV1>(1))
        .expect("Protocolo não disponível");
};
```

A execução falha com:
```
thread 'main' panicked at 'Protocolo não disponível: BindError { name: "zwlr_layer_shell_v1", version: 1 }'
```

Isso ocorre porque o protocolo precisa ser explicitamente suportado pelo compositor (como Sway ou GNOME Shell). Não há fallback automático - sua aplicação deve verificar a disponibilidade:

```rust
let has_layer_shell = window.wayland_display()
    .map(|d| d.list_globals().any(|g| g == "zwlr_layer_shell_v1"))
    .unwrap_or(false);
```

### 2. Controle Limitado de Redimensionamento

Enquanto no X11 você pode forçar qualquer tamanho de janela, no Wayland o compositor tem a palavra final. Este código tenta definir um tamanho fixo:

```rust
window.set_inner_size(PhysicalSize::new(800, 600));
window.set_resizable(false);
```

Na prática, o compositor pode:
- Ignorar completamente o pedido
- Arredondar para múltiplos de 64px (dependendo do protocolo)
- Aplicar constraints de proporção

A única maneira confiável é implementar o redimensionamento client-side e lidar com o evento `Resized`:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event: WindowEvent::Resized(size), .. } => {
            // Atualize sua renderização aqui
            println!("Tamanho real concedido: {:?}", size);
        }
        _ => (),
    }
});
```

### 3. Falta de Controle de Posicionamento

Tentar posicionar uma janela com `window.set_outer_position` no Wayland resulta em comportamento inconsistente:

```rust
window.set_outer_position(PhysicalPosition::new(100, 100));
```

O compositor pode:
- Ignorar completamente
- Aplicar um offset baseado em decorações
- Posicionar em coordenadas relativas ao workspace atual

Para posicionamento preciso, você precisa usar protocolos extendidos como `xdg_positioner`:

```rust
let positioner = xdg_shell.create_positioner();
positioner.set_size(800, 600);
positioner.set_offset(100, 100);
let surface = window.wayland_surface().unwrap();
let xdg_surface = surface.as_ref().xdg_surface().unwrap();
xdg_surface.get_toplevel_with_positioner(positioner);
```

### 4. Input Global Restrito

Acessar eventos de teclado/mouse fora da sua janela é impossível no Wayland por questões de segurança:

```rust
// Isso NÃO funciona no Wayland
window.set_cursor_grab(true).expect("Falha ao capturar cursor");
```

A mensagem de erro será:
```
Error: NotSupported("Cursor grab is not supported on Wayland")
```

Soluções alternativas envolvem protocolos específicos como `wlr_input_inhibit_manager`, mas exigem permissões especiais.

### 5. Latência de Eventos

O modelo de eventos do Wayland introduz latência em operações que seriam instantâneas no X11. Considere este exemplo de movimento de janela:

```rust
window.drag_window().expect("Drag não suportado");
```

No Wayland, isso:
1. Envia uma requisição ao compositor
2. Espera por um commit
3. Recebe a nova posição via evento

O resultado é um movimento menos responsivo comparado ao X11.

### 6. DPI Dinâmico Problemático

Enquanto Winit fornece eventos `ScaleFactorChanged`, a implementação no Wayland tem peculiaridades:

```rust
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event: WindowEvent::ScaleFactorChanged { scale_factor, .. }, .. } => {
            println!("Novo scale factor: {}", scale_factor);
            // Isso pode ser chamado múltiplas vezes para o mesmo valor!
        }
        _ => (),
    }
});
```

É comum receber vários eventos idênticos devido à arquitetura assíncrona do Wayland. A solução é implementar debouncing:

```rust
let mut current_scale = window.scale_factor();
event_loop.run(move |event, _, control_flow| {
    match event {
        Event::WindowEvent { event: WindowEvent::ScaleFactorChanged { scale_factor, .. }, .. } => {
            if (scale_factor - current_scale).abs() > f64::EPSILON {
                current_scale = scale_factor;
                // Atualize sua interface aqui
            }
        }
        _ => (),
    }
});
```

### Exercício Prático

Implemente uma função que verifica se o protocolo `xdg_decoration` está disponível e, caso positivo, aplica decorações client-side. Capture o erro caso o protocolo não esteja presente.

**Solução:**

```rust
fn setup_client_side_decorations(window: &Window) -> Result<(), Box<dyn std::error::Error>> {
    let display = window.wayland_display()
        .ok_or("Não está executando no Wayland")?;
    
    if !display.list_globals().any(|g| g == "zxdg_decoration_manager_v1") {
        return Err("Protocolo xdg_decoration não disponível".into());
    }

    let decoration_manager = unsafe {
        display.bind::<ZxdgDecorationManagerV1>(1)?
    };

    let surface = window.wayland_surface()
        .ok_or("Superfície Wayland não disponível")?;
    
    let xdg_surface = surface.as_ref().xdg_surface()
        .ok_or("XDG Surface não disponível")?;

    let toplevel = xdg_surface.get_toplevel();
    let decoration = decoration_manager.get_toplevel_decoration(&toplevel);
    decoration.set_mode(ZxdgToplevelDecorationV1Mode::ClientSide);

    Ok(())
}
```