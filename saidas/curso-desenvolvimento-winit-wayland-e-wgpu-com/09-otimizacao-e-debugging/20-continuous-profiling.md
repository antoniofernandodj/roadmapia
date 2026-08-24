## Continuous Profiling

Quando sua aplicação gráfica começa a travar ou consumir recursos excessivos, adivinhar a causa é como procurar uma agulha em um palheiro. O continuous profiling resolve isso capturando métricas de desempenho em tempo real, revelando gargalos invisíveis em execuções pontuais.

Vamos implementar um sistema mínimo que coleta dados de CPU e GPU sem interromper o fluxo de renderização. Começamos com a estrutura básica:

```rust
use std::time::{Duration, Instant};

struct Profiler {
    cpu_samples: Vec<Duration>,
    gpu_samples: Vec<Duration>,
    last_frame: Instant,
}

impl Profiler {
    fn new() -> Self {
        Self {
            cpu_samples: Vec::with_capacity(60),
            gpu_samples: Vec::with_capacity(60),
            last_frame: Instant::now(),
        }
    }

    fn begin_frame(&mut self) {
        self.last_frame = Instant::now();
    }

    fn end_frame(&mut self, gpu_time: Option<Duration>) {
        let cpu_time = self.last_frame.elapsed();
        self.cpu_samples.push(cpu_time);
        
        if let Some(gpu_duration) = gpu_time {
            self.gpu_samples.push(gpu_duration);
        }
    }
}
```

O erro clássico aqui é esquecer de resetar `last_frame` em `begin_frame()`, fazendo com que cada medição acumule o tempo de todos os frames anteriores. Teste com um loop simples:

```rust
fn main() {
    let mut profiler = Profiler::new();
    
    for _ in 0..60 {
        profiler.begin_frame();
        // Simula trabalho da CPU
        std::thread::sleep(Duration::from_millis(10));
        profiler.end_frame(Some(Duration::from_millis(8))); // Simula tempo GPU
    }
    
    println!("CPU avg: {:?}", 
        profiler.cpu_samples.iter().sum::<Duration>() / 60);
    println!("GPU avg: {:?}", 
        profiler.gpu_samples.iter().sum::<Duration>() / 60);
}
```

Saída esperada:
```
CPU avg: 10.333ms
GPU avg: 8ms
```

Para medição real de GPU, o WGPU oferece `wgpu_profiler`. Configure-o junto ao dispositivo:

```rust
let mut profiler = wgpu_profiler::GpuProfiler::new(4, &device, wgpu_profiler::GpuProfilerSettings::default());

// Dentro do loop de renderização:
profiler.begin_frame();
let mut encoder = device.create_command_encoder(/* ... */);

// Marque o início/fim de operações
profiler.write_timestamp(&mut encoder, wgpu_profiler::TimestampScope::AllCommands);
// ... draw calls ...
profiler.write_timestamp(&mut encoder, wgpu_profiler::TimestampScope::AllCommands);

// Resolve os tempos no final do frame
profiler.resolve_queries(&mut encoder);
queue.submit(std::iter::once(encoder.finish()));

let gpu_results = profiler.end_frame().unwrap();
println!("GPU frame time: {:?}", gpu_results.time_between_all_commands);
```

Erro comum: esquecer de chamar `resolve_queries()` antes de submeter o command buffer, resultando em dados vazios. A mensagem de erro será:
```
wgpu error: Validation Error: Command buffer is missing query resolve calls
```

Integre ambos os profilers em uma aplicação WGPU real:

```rust
struct App {
    cpu_profiler: Profiler,
    gpu_profiler: wgpu_profiler::GpuProfiler,
    // ... outros campos da aplicação ...
}

impl App {
    fn update(&mut self) {
        self.cpu_profiler.begin_frame();
        // Lógica da aplicação
    }

    fn render(&mut self) -> Result<(), wgpu::SurfaceError> {
        self.gpu_profiler.begin_frame();
        let mut encoder = /* ... */;
        
        // Renderização normal...
        
        let gpu_time = self.end_gpu_profiling(&mut encoder)?;
        self.cpu_profiler.end_frame(gpu_time);
        Ok(())
    }
    
    fn end_gpu_profiling(&mut self, encoder: &mut wgpu::CommandEncoder) 
        -> Result<Option<Duration>, wgpu::SurfaceError> 
    {
        self.gpu_profiler.resolve_queries(encoder);
        let gpu_results = self.gpu_profiler.end_frame()
            .map_err(|e| {
                log::error!("GPU profiling failed: {}", e);
                wgpu::SurfaceError::Lost
            })?;
        
        Ok(Some(gpu_results.time_between_all_commands))
    }
}
```

Para visualização, gere um flamegraph com dados acumulados:

```rust
fn generate_flamegraph(samples: &[Duration]) {
    let mut output = String::from("flamegraph:\n");
    for (i, &duration) in samples.iter().enumerate() {
        output.push_str(&format!("frame_{} {}ms\n", i, duration.as_millis()));
    }
    std::fs::write("flamegraph.txt", output).unwrap();
}
```

Exercício: Modifique o sistema para detectar automaticamente quando o tempo de frame excede 16ms (60 FPS) e registre o stack trace nesses momentos. Solução:

```rust
use backtrace::Backtrace;

impl Profiler {
    fn end_frame(&mut self, gpu_time: Option<Duration>) -> bool {
        let cpu_time = self.last_frame.elapsed();
        let frame_time = cpu_time + gpu_time.unwrap_or_default();
        
        if frame_time > Duration::from_millis(16) {
            let trace = Backtrace::new();
            log::warn!("Frame time exceeded: {:?}\n{:?}", frame_time, trace);
        }
        
        self.cpu_samples.push(cpu_time);
        if let Some(gpu_duration) = gpu_time {
            self.gpu_samples.push(gpu_duration);
        }
        
        frame_time > Duration::from_millis(16)
    }
}
```