## Instance e Adapter

A primeira barreira para renderizar com WGPU é escolher *como* e *onde* seu código gráfico vai executar. O WGPU abstrai diferentes backends (Vulkan, Metal, DirectX 12), mas você precisa configurar essa ponte. 

### Instance: A Porta de Entrada

Uma `Instance` em WGPU é como um hub que conhece todos os backends gráficos disponíveis no sistema. Criá-la é simples, mas crucial:

```rust
use wgpu::Instance;

let instance = Instance::new(wgpu::InstanceDescriptor {
    backends: wgpu::Backends::all(),
    ..Default::default()
});
```

O parâmetro `backends` define quais APIs você quer considerar. Por exemplo, `Backends::VULKAN` restringe ao Vulkan. O método `all()` é seguro para início, mas em produção você pode querer controle mais fino.

**Erro Comum**: esquecer que backends têm suporte variado por sistema operacional. Se você tentar criar uma instância com `Backends::METAL` no Linux:

```text
Error: No supported GPU backends available on this system.
```

### Encontrando o Adapter

Com a instância criada, precisamos de um `Adapter` - a representação física da GPU que executará seus comandos. A seleção é assíncrona:

```rust
let adapter = instance.request_adapter(
    &wgpu::RequestAdapterOptions {
        power_preference: wgpu::PowerPreference::HighPerformance,
        compatible_surface: None,
        force_fallback_adapter: false,
    },
).await.unwrap();

println!("Adapter: {:?}", adapter.get_info());
```

Saída típica (Linux com NVIDIA):
```text
Adapter: AdapterInfo { name: "NVIDIA GeForce RTX 3080", vendor: 4318, device: 7040, device_type: DiscreteGpu, backend: Vulkan }
```

Parâmetros importantes:
- `power_preference`: Escolha entre `HighPerformance` (GPUs dedicadas) ou `LowPower` (integradas)
- `compatible_surface`: Importante para renderização em janela (veremos depois)
- `force_fallback_adapter`: Usa software rendering se necessário

**Problema Comum**: esquecer o `.await`. WGPU usa operações assíncronas intensamente. O erro é claro:

```text
error[E0277]: `impl Future<Output = Option<Adapter>>` doesn't implement `std::fmt::Display`
```

### Entendendo os Limites

Cada adapter tem capacidades específicas. Antes de usá-lo, verifique se suporta os recursos que você precisa:

```rust
let features = adapter.features();
let limits = adapter.limits();

println!("Features: {:?}", features);
println!("Limits: {:?}", limits);
```

Isso mostra informações cruciais como:
- Máximo de texturas simultâneas
- Suporte a computação paralela
- Limites de tamanho de buffers

**Exercício Prático**: Modifique o código para listar todos os adapters disponíveis no sistema, ordenados por tipo (discreta vs integrada). Dica: use `instance.enumerate_adapters()`.

<details>
<summary>Solução</summary>

```rust
let adapters: Vec<_> = instance.enumerate_adapters(wgpu::Backends::all()).collect();

adapters.sort_by(|a, b| {
    a.get_info().device_type.cmp(&b.get_info().device_type)
});

for adapter in adapters {
    let info = adapter.get_info();
    println!("{:?} ({:?})", info.name, info.device_type);
}
```
</details>

### Quando Falha?

Se `request_adapter()` retornar `None`, os motivos comuns são:
1. Backend selecionado não está disponível (ex: Metal no Windows)
2. Drivers gráficos não instalados ou desatualizados
3. Restrições de sandbox em navegadores (para WebGPU)