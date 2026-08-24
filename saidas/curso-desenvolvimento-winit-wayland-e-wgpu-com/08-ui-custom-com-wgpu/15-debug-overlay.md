## Debug Overlay

Quando você está desenvolvendo uma interface gráfica complexa, nada é mais frustrante do que elementos que desaparecem, layouts que quebram sem motivo aparente ou performance que despenca sem explicação. Um debug overlay resolve isso mostrando informações críticas em tempo real, diretamente sobre sua UI, sem precisar depender de logs ou ferramentas externas.

Vamos implementar um overlay que mostra:
1. FPS atual e tempo por frame
2. Memória GPU em uso
3. Número de draw calls
4. Posição do mouse e elemento sob o cursor

Começamos com a estrutura básica que armazenará as métricas:

```rust
#[derive(Debug)]
pub struct DebugMetrics {
    pub fps: f64,
    pub frame_time: f64, // ms
    pub gpu_memory: u64, // MB
    pub draw_calls: u32,
    pub mouse_pos: (f32, f32),
    pub hovered_element: Option<String>,
}

impl Default for DebugMetrics {
    fn default() -> Self {
        Self {
            fps: 0.0,
            frame_time: 0.0,
            gpu_memory: 0,
            draw_calls: 0,
            mouse_pos: (0.0, 0.0),
            hovered_element: None,
        }
    }
}
```

Para calcular os FPS, usamos um buffer circular de tempos de frame:

```rust
use std::collections::VecDeque;

const FPS_WINDOW: usize = 60;

pub struct FrameTimer {
    frame_times: VecDeque<f64>,
    last_frame: std::time::Instant,
}

impl FrameTimer {
    pub fn new() -> Self {
        Self {
            frame_times: VecDeque::with_capacity(FPS_WINDOW),
            last_frame: std::time::Instant::now(),
        }
    }

    pub fn tick(&mut self) -> f64 {
        let now = std::time::Instant::now();
        let elapsed = now.duration_since(self.last_frame).as_secs_f64() * 1000.0; // ms
        self.last_frame = now;

        if self.frame_times.len() >= FPS_WINDOW {
            self.frame_times.pop_front();
        }
        self.frame_times.push_back(elapsed);

        self.frame_times.iter().sum::<f64>() / self.frame_times.len() as f64
    }

    pub fn fps(&self) -> f64 {
        if self.frame_times.is_empty() {
            0.0
        } else {
            1000.0 / (self.frame_times.iter().sum::<f64>() / self.frame_times.len() as f64)
        }
    }
}
```

Agora integramos com o loop principal:

```rust
fn main() {
    let mut frame_timer = FrameTimer::new();
    let mut debug_metrics = DebugMetrics::default();

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Poll;

        match event {
            Event::MainEventsCleared => {
                let frame_time = frame_timer.tick();
                debug_metrics.frame_time = frame_time;
                debug_metrics.fps = frame_timer.fps();

                // Atualize outras métricas aqui...
                
                window.request_redraw();
            }
            Event::RedrawRequested(_) => {
                render(&debug_metrics); // Sua função de renderização principal
                render_debug_overlay(&debug_metrics); // Nova função para o overlay
            }
            _ => (),
        }
    });
}
```

A renderização do overlay usa um sistema de texto simples:

```rust
fn render_debug_overlay(metrics: &DebugMetrics, device: &wgpu::Device, queue: &wgpu::Queue) {
    let mut text = String::new();
    text.push_str(&format!("FPS: {:.1}\n", metrics.fps));
    text.push_str(&format!("Frame: {:.2}ms\n", metrics.frame_time));
    text.push_str(&format!("GPU Mem: {}MB\n", metrics.gpu_memory));
    text.push_str(&format!("Draw Calls: {}\n", metrics.draw_calls));
    text.push_str(&format!("Mouse: ({:.1}, {:.1})\n", 
        metrics.mouse_pos.0, metrics.mouse_pos.1));
    
    if let Some(element) = &metrics.hovered_element {
        text.push_str(&format!("Hover: {}\n", element));
    }

    // Aqui você usaria sua biblioteca de renderização de texto
    // Exemplo com wgpu_glyph:
    let section = wgpu_glyph::Section {
        screen_position: (10.0, 10.0),
        bounds: (200.0, 200.0),
        text: vec![wgpu_glyph::Text::new(&text)
            .with_color([1.0, 1.0, 1.0, 1.0])
            .with_scale(16.0)],
        ..Default::default()
    };

    glyph_brush.queue(section);
}
```

Erro comum: esquecer de resetar as métricas a cada frame. Se você não zerar `draw_calls`, o número vai acumular indefinidamente. A solução é adicionar um método `reset_frame_stats`:

```rust
impl DebugMetrics {
    pub fn reset_frame_stats(&mut self) {
        self.draw_calls = 0;
        // Mantemos mouse_pos e hovered_element entre frames
    }
}

// No loop principal:
debug_metrics.reset_frame_stats();
```

Para métricas avançadas como memória GPU, você pode usar extensões como `wgpu::Instance::enumerate_adapters`:

```rust
fn update_gpu_metrics(metrics: &mut DebugMetrics, instance: &wgpu::Instance) {
    let mut total_memory = 0;
    for adapter in instance.enumerate_adapters(wgpu::Backends::all()) {
        if let Some(info) = adapter.get_info().memory {
            total_memory += info.used;
        }
    }
    metrics.gpu_memory = total_memory / (1024 * 1024); // Convert to MB
}
```

**Exercício**: Implemente um toggle para mostrar/ocultar o overlay com a tecla F3. A solução deve:
1. Armazenar o estado de visibilidade (ex.: `show_debug: bool`)
2. Capturar eventos de teclado no loop principal
3. Alternar o estado quando F3 for pressionado
4. Condicionalmente chamar `render_debug_overlay`

```rust
// Solução:
struct AppState {
    debug_metrics: DebugMetrics,
    show_debug: bool,
    // ... outros campos
}

// No tratamento de eventos:
Event::WindowEvent { event: WindowEvent::KeyboardInput { input, .. }, .. } => {
    if input.virtual_keycode == Some(VirtualKeyCode::F3) && input.state == ElementState::Pressed {
        app_state.show_debug = !app_state.show_debug;
    }
}

// Na renderização:
if app_state.show_debug {
    render_debug_overlay(&app_state.debug_metrics, &device, &queue);
}
```