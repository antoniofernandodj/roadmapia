## Swap Chain Básica

Quando você começa a renderizar gráficos, encontra um problema fundamental: a tela só pode mostrar uma imagem completa de cada vez, enquanto sua aplicação quer desenhar novos quadros continuamente. A swap chain resolve isso com um sistema de buffers duplos (ou triplos) que evita "tela rasgada" (screen tearing) e sincroniza com a taxa de atualização do monitor.

Vamos criar uma swap chain funcional em WGPU. Primeiro, precisamos configurá-la com os parâmetros adequados para nossa janela:

```rust
let surface = unsafe { instance.create_surface(&window) }.unwrap();
let adapter = instance.request_adapter(&wgpu::RequestAdapterOptions {
    power_preference: wgpu::PowerPreference::HighPerformance,
    compatible_surface: Some(&surface),
    ..Default::default()
}).await.unwrap();

let (device, queue) = adapter.request_device(
    &wgpu::DeviceDescriptor {
        features: wgpu::Features::empty(),
        limits: wgpu::Limits::default(),
        label: None,
    },
    None
).await.unwrap();

let swap_chain_desc = wgpu::SurfaceConfiguration {
    usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
    format: surface.get_preferred_format(&adapter).unwrap(),
    width: window.inner_size().width,
    height: window.inner_size().height,
    present_mode: wgpu::PresentMode::Fifo, // VSync habilitado
    alpha_mode: wgpu::CompositeAlphaMode::Auto,
};
let swap_chain = surface.configure(&device, &swap_chain_desc);
```

O erro mais comum aqui é esquecer de reconfigurar a swap chain quando a janela é redimensionada. Se você tentar renderizar sem fazer isso, receberá o erro:

```
wgpu error: Surface is not configured
```

A correção é envolver a configuração da swap chain em uma função que pode ser chamada no redimensionamento:

```rust
fn configure_swap_chain(
    surface: &wgpu::Surface,
    device: &wgpu::Device,
    width: u32,
    height: u32,
    format: wgpu::TextureFormat,
) -> wgpu::SurfaceConfiguration {
    let config = wgpu::SurfaceConfiguration {
        usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
        format,
        width,
        height,
        present_mode: wgpu::PresentMode::Fifo,
        alpha_mode: wgpu::CompositeAlphaMode::Auto,
    };
    surface.configure(device, &config);
    config
}
```

Agora podemos usar a swap chain no loop principal de renderização. Cada quadro segue este fluxo:

1. Obter o próximo frame da swap chain
2. Criar um command encoder
3. Executar comandos de renderização
4. Submeter os comandos
5. Apresentar o frame

Veja a implementação básica:

```rust
let frame = swap_chain.get_current_frame()?.output;
let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
    label: Some("Render Encoder"),
});

// ... comandos de renderização vão aqui ...

queue.submit(std::iter::once(encoder.finish()));
frame.present();
```

Se você esquecer de chamar `present()`, nada será exibido na tela, mas também não haverá mensagem de erro - apenas um comportamento silencioso que pode confundir iniciantes.

O modo de apresentação (`PresentMode`) é crucial para o comportamento da swap chain. WGPU oferece várias opções:

- `Fifo` (VSync): Suportado universalmente, evita tearing
- `Mailbox` (Low-latency VSync): Melhor para jogos
- `Immediate` (No VSync): Máximo FPS, pode causar tearing

```rust
// Exemplo de alteração dinâmica do modo de apresentação
fn set_present_mode(
    surface: &wgpu::Surface,
    device: &wgpu::Device,
    config: &mut wgpu::SurfaceConfiguration,
    mode: wgpu::PresentMode,
) {
    config.present_mode = mode;
    surface.configure(device, config);
}
```

**Exercício Prático:** Modifique o exemplo para alternar entre `Fifo` e `Immediate` quando a tecla 'V' for pressionada. Mostre o FPS atual na janela para comparar os modos.

**Solução:**

```rust
let mut present_mode = wgpu::PresentMode::Fifo;
let mut fps_counter = FPSCounter::new();

// No loop de eventos:
if input.key_pressed(VirtualKeyCode::V) {
    present_mode = match present_mode {
        wgpu::PresentMode::Fifo => wgpu::PresentMode::Immediate,
        _ => wgpu::PresentMode::Fifo,
    };
    configure_swap_chain(&surface, &device, width, height, format, present_mode);
}

let fps = fps_counter.tick();
// Renderize o texto do FPS usando sua biblioteca de texto preferida
```

A diferença de performance será visível imediatamente, com `Immediate` mostrando FPS muito mais alto, mas potencialmente com tearing, enquanto `Fifo` mantém a sincronização com o monitor.