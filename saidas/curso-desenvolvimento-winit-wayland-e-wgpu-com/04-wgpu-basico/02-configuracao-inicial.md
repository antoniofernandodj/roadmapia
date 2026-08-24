## Configuração Inicial

Para começar a usar WGPU, precisamos configurar um projeto Rust básico com todas as dependências necessárias. Vamos criar um novo projeto e adicionar o WGPU junto com o Winit para gerenciamento de janelas:

```bash
cargo new wgpu_example
cd wgpu_example
```

Adicione estas dependências ao seu `Cargo.toml`:

```toml
[dependencies]
wgpu = "0.18"
winit = "0.28"
env_logger = "0.10"  # Para log de erros
```

O erro mais comum nesse ponto é esquecer de habilitar os backends necessários. O WGPU suporta Vulkan, Metal, DirectX 12 e WebGPU, mas por padrão só ativa os disponíveis no seu sistema. Para garantir máxima compatibilidade durante o desenvolvimento, force a ativação de vários backends:

```rust
use wgpu::Backends;

let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
    backends: Backends::all(),
    ..Default::default()
});
```

Se você tentar criar uma instância sem especificar backends em um sistema onde o backend preferencial não está disponível, receberá um erro como:

```
thread 'main' panicked at 'No valid backend adapters found!'
```

O próximo passo é criar uma janela usando Winit. Esta janela será onde nossa aplicação gráfica será exibida:

```rust
use winit::{
    event_loop::{EventLoop, ControlFlow},
    window::WindowBuilder,
};

let event_loop = EventLoop::new();
let window = WindowBuilder::new().build(&event_loop).unwrap();
```

Um problema frequente ocorre quando tentamos usar o WGPU sem uma janela válida. Se você pular esta etapa e tentar criar um surface diretamente, receberá:

```
thread 'main' panicked at 'Window is not a valid surface for this backend'
```

Agora vamos conectar o WGPU à janela criada, criando uma surface:

```rust
let surface = unsafe { instance.create_surface(&window) }.unwrap();
```

O uso de `unsafe` aqui é necessário porque a criação da surface envolve operações que o Rust não pode verificar completamente em tempo de compilação. Na prática, é seguro desde que a janela (window) continue válida enquanto a surface estiver em uso.

Para verificar se tudo está configurado corretamente, vamos criar um adaptador. O adaptador representa a placa gráfica que será usada:

```rust
let adapter = instance.request_adapter(
    &wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::HighPerformance,
        compatible_surface: Some(&surface),
        force_fallback_adapter: false,
    },
).await.unwrap();
```

Se esquecermos o `.await` aqui (lembre-se que WGPU usa operações assíncronas), o compilador nos alertará com:

```
error: cannot convert `impl Future` to `Option`
help: consider `.await`ing the future
```

Com o adaptador em mãos, podemos finalmente criar o device (representação lógica da GPU) e a queue (fila de comandos gráficos):

```rust
let (device, queue) = adapter.request_device(
    &wgpu::DeviceDescriptor {
        label: None,
        features: wgpu::Features::empty(),
        limits: wgpu::Limits::default(),
    },
    None,
).await.unwrap();
```

Agora temos todos os componentes básicos configurados:
1. `instance` - Ponto de entrada para a API WGPU
2. `surface` - Área de renderização conectada à janela
3. `adapter` - Representação do hardware gráfico
4. `device` e `queue` - Interface para enviar comandos à GPU

**Exercício:** Modifique o código para usar um adaptador de baixo consumo de energia (`PowerPreference::LowPower`) em vez de alto desempenho. O que muda no objeto `adapter` resultante?

**Solução:** A única mudança necessária é no `RequestAdapterOptions`:

```rust
let adapter = instance.request_adapter(
    &wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::LowPower,
        compatible_surface: Some(&surface),
        force_fallback_adapter: false,
    },
).await.unwrap();
```

A diferença principal será no adaptador selecionado - geralmente uma GPU integrada em vez de uma dedicada. Você pode verificar isso imprimindo o nome do adaptador:

```rust
println!("Usando adaptador: {}", adapter.get_info().name);
```