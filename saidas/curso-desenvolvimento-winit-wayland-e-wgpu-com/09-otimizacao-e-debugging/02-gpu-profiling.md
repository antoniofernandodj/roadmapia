## GPU Profiling

Quando seu triângulo não renderiza ou os FPS caem inexplicavelmente, o problema pode estar nos comandos enviados à GPU. Diferente do profiling de CPU, onde medimos tempo de execução, aqui precisamos rastrear:

1. Chamadas de API (quantas `draw()` estão sendo disparadas)
2. Uso de recursos (texturas, buffers)
3. Synchronization stalls (momentos onde a GPU fica ociosa)

### Ferramentas Básicas

**wgpu-profiler**: Adicione ao `Cargo.toml`:
```toml
[dependencies]
wgpu-profiler = "0.13"
```

Exemplo mínimo de instrumentação:
```rust
use wgpu_profiler::{GpuProfiler, GpuProfilerSettings};

let mut profiler = GpuProfiler::new(GpuProfilerSettings::default());

// Dentro do loop de renderização:
profiler.begin_frame();
let mut encoder = profiler.profile_scope("main_pass", &device, &mut encoder);
render_pass.draw(0..3, 0..1); // Exemplo: draw call
profiler.end_frame().unwrap();
```

Saída típica no terminal:
```
Frame 42:
  main_pass: 1.2ms
    upload_buffer: 0.4ms
    draw[0]: 0.8ms
```

### Erro Comum: Esquecer de Finalizar o Frame
Se você ver:
```
wgpu_profiler: Frame not ended before beginning new one!
```
Significa que faltou chamar `end_frame()` antes do próximo `begin_frame()`.

### Nvidia NSight para Linux
Instale via:
```bash
sudo apt install nvidia-nsight
```
Execute seu aplicativo com:
```bash
nsight-gui ./target/release/seu_app
```

Captura básica:
1. Abra "New GPU Trace Session"
2. Selecione seu binário
3. Clique em "Start"
4. Interaja com o app
5. Clique em "Stop"

Você verá uma timeline como:
```
|----------|-----------|----------|
| Draw[1]  |  Texture  |  Compute |
|  0.5ms   |  Upload   |  Dispatch|
|          |   0.2ms   |   1.1ms  |
```

### AMD Radeon GPU Profiler
Para placas AMD:
```bash
git clone https://github.com/GPUOpen-Tools/RGP
cd RGP && mkdir build && cd build
cmake .. && make -j8
sudo make install
```

Uso:
1. Execute `rgp`
2. Selecione "New Profile"
3. Aponte para seu executável
4. Clique em "Profile"

A saída mostra detalhes como:
```
Pipeline State:
  VS: /shaders/triangle.vert.spv
  PS: /shaders/triangle.frag.spv
Resource Bindings:
  Set 0:
    Buffer[0]: vertex_buffer (RO)
```

### Intel GPA
Para Intel Graphics:
```bash
wget https://downloadmirror.intel.com/738371/gpa_22.3_ubuntu-20.04_x86_64.deb
sudo dpkg -i gpa_*.deb
```

Principais métricas:
- **GPU Utilization**: % de uso real da GPU
- **EU Active**: Unidades de execução ocupadas
- **Memory Read/Write**: Largura de banda de VRAM

### Comparação de Ferramentas

| Ferramenta       | Overhead | Detalhe Shader | Suporte Multi-GPU |
|------------------|----------|----------------|-------------------|
| wgpu-profiler    | Baixo    | Não            | Sim               |
| NSight           | Médio    | Sim            | Nvidia-only       |
| RGP              | Alto     | Sim            | AMD-only          |
| GPA              | Médio    | Parcial        | Intel-only        |

### Caso Real: Draw Calls Excessivos
Sintoma: 3000 draw calls para 10 objetos.

Código problemático:
```rust
for mesh in &meshes {
    for instance in &mesh.instances {
        render_pass.draw_mesh(mesh, instance); // O(n²)
    }
}
```

Solução com instancing:
```rust
render_pass.draw_mesh_instanced(mesh, 0..mesh.instances.len()); // O(1)
```

Antes:
```
Frame time: 16ms
  draw[0..2999]: 15ms
```

Depois:
```
Frame time: 2ms
  draw_instanced: 1.5ms
```

### Exercício: Identifique o Gargalo
Dado este perfil:
```
Frame 73:
  shadow_pass: 8ms
  main_pass: 12ms
    light_culling: 2ms
    opaque: 6ms
      draw[0..149]: 5ms
    transparent: 4ms
      draw[150..199]: 3.5ms
```

Onde está o principal problema de performance e como otimizar?

**Solução:**
O gargalo está em `opaque:draw[0..149]` consumindo 5ms (41% do frame). Possíveis ações:
1. Implementar frustum culling para reduzir draw calls
2. Usar instancing para meshes idênticos
3. Verificar se os materiais podem ser batched