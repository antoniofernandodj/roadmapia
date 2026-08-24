## Criação de Contextos Gráficos

Para renderizar gráficos em uma janela Winit, precisamos de um contexto de API gráfica. O Winit não fornece renderização diretamente - ele apenas cria a janela e gerencia eventos. A integração com OpenGL, Vulkan ou outras APIs requer configuração manual. Vejamos como criar um contexto Vulkan funcional:

```rust
use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};
use ash::{vk, Entry};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("Vulkan com Winit")
        .build(&event_loop)?;

    // Inicialização Vulkan
    let entry = unsafe { Entry::new() }?;
    let app_info = vk::ApplicationInfo::builder()
        .application_name(b"Vulkan App\0")
        .application_version(vk::make_api_version(0, 1, 0, 0))
        .engine_name(b"No Engine\0")
        .engine_version(vk::make_api_version(0, 1, 0, 0))
        .api_version(vk::API_VERSION_1_0);

    let extensions = ash_window::enumerate_required_extensions(
        window.raw_window_handle()
    )?.to_vec();

    let create_info = vk::InstanceCreateInfo::builder()
        .application_info(&app_info)
        .enabled_extension_names(&extensions);

    let instance = unsafe { entry.create_instance(&create_info, None) }?;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
```

Este código cria uma janela Winit e configura uma instância Vulkan básica. O ponto crucial é `ash_window::enumerate_required_extensions()`, que obtém as extensões Vulkan necessárias para a plataforma específica onde a janela está sendo criada.

**Erro comum**: Tentar criar o contexto gráfico antes da janela:

```rust
let entry = Entry::new()?;  // OK
let instance = entry.create_instance(...)?;  // ERRO - precisa das extensões da janela
let window = WindowBuilder::new().build(&event_loop)?;
```

Isso falhará porque precisamos do handle da janela (`raw_window_handle()`) para determinar quais extensões Vulkan são necessárias para aquela plataforma específica.

Para OpenGL, o processo é similar mas usa o crate `glutin` como ponte:

```rust
use glutin::{
    prelude::*,
    ContextBuilder,
    PossiblyCurrent,
    WindowedContext,
};

let windowed_context: WindowedContext<PossiblyCurrent> = unsafe {
    ContextBuilder::new()
        .with_hardware_acceleration(Some(true))
        .build_windowed(window, &event_loop)?
        .make_current()?
};

let gl = windowed_context.context();
```

O contexto OpenGL resultante (`gl`) pode ser usado com crates como `glow` ou `gl` para comandos de renderização.

**Diferença chave entre backends**:
1. **Vulkan**: Mais controle, melhor performance potencial, mas mais código boilerplate
2. **OpenGL**: Mais simples de configurar, mas menos controle sobre o pipeline
3. **Metal/DirectX**: Específicos de plataforma, requerem configuração adicional

Para projetos modernos, a combinação Winit + WGPU está se tornando popular por ser cross-platform e oferecer acesso a APIs modernas:

```rust
use wgpu::{Instance, Surface};
use wgpu::util::DeviceExt;

let instance = Instance::new(wgpu::Backends::all());
let surface = unsafe { instance.create_surface(&window) };
```

**DPI e coordenadas**: Ao renderizar, lembre-se que Winit trabalha com dois sistemas:
- Coordenadas físicas (pixels reais)
- Coordenadas lógicas (ajustadas pelo DPI)

Use `window.inner_size()` para obter as dimensões físicas e `window.scale_factor()` para conversão:

```rust
let physical_size = window.inner_size();
let logical_size = physical_size.to_logical(window.scale_factor());
```

**Exercício**: Modifique o exemplo Vulkan para:
1. Verificar se a extensão VK_KHR_surface está disponível
2. Criar uma superfície Vulkan usando ash_window
3. Limpar adequadamente os recursos Vulkan no encerramento

**Solução**:

```rust
// 1. Verificar extensões
let available_extensions = entry.enumerate_instance_extension_properties()?;
let has_surface = available_extensions.iter().any(|ext| {
    unsafe { std::ffi::CStr::from_ptr(ext.extension_name.as_ptr()) }
        .to_str()
        .unwrap()
        .contains("VK_KHR_surface")
});

if !has_surface {
    return Err("VK_KHR_surface não suportada".into());
}

// 2. Criar superfície
let surface = unsafe {
    ash_window::create_surface(
        &entry,
        &instance,
        window.raw_window_handle(),
        None
    )?
};

// 3. Limpeza (adicionar ao drop da struct da aplicação)
unsafe {
    instance.destroy_surface_khr(surface, None);
    instance.destroy_instance(None);
}
```