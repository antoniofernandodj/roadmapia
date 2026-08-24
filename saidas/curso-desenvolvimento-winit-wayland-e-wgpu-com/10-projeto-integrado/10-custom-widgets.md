## Custom Widgets

Criar widgets personalizados em uma aplicação gráfica Rust exige mais do que desenhar retângulos na tela. O desafio real está em integrar três sistemas distintos: a lógica de interação (input), o estado do widget e a renderização eficiente na GPU. Vamos construir um botão customizado do zero, mostrando cada armadilha no caminho.

Começamos definindo a estrutura básica do widget:

```rust
#[derive(Debug)]
pub struct Button {
    bounds: Rectangle,
    label: String,
    state: ButtonState,
    // Cache de vértices para evitar recálculos
    vertices: Option<wgpu::Buffer>,
}

#[derive(Debug, PartialEq)]
enum ButtonState {
    Normal,
    Hovered,
    Pressed,
}
```

O primeiro erro comum é esquecer de converter coordenadas físicas (pixels) para lógicas (DPI-aware). Sem isso, o botão aparecerá em tamanhos diferentes em monitores com escalas distintas:

```rust
impl Button {
    pub fn new(
        logical_position: (f32, f32),
        logical_size: (f32, f32),
        label: &str,
        dpi_factor: f64,
    ) -> Self {
        let physical_x = (logical_position.0 * dpi_factor as f32).round();
        let physical_y = (logical_position.1 * dpi_factor as f32).round();
        let physical_width = (logical_size.0 * dpi_factor as f32).round();
        let physical_height = (logical_size.1 * dpi_factor as f32).round();

        Button {
            bounds: Rectangle {
                x: physical_x,
                y: physical_y,
                width: physical_width,
                height: physical_height,
            },
            label: label.to_string(),
            state: ButtonState::Normal,
            vertices: None,
        }
    }
}
```

A renderização do botão exige um pipeline WGPU específico para UI. Este é um erro fatal que muitos cometem ao misturar pipelines:

```rust
pub fn create_ui_pipeline(device: &wgpu::Device, format: wgpu::TextureFormat) -> wgpu::RenderPipeline {
    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("UI Shader"),
        source: wgpu::ShaderSource::Wgsl(include_str!("ui.wgsl").into()),
    });

    let layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: Some("UI Pipeline Layout"),
        bind_group_layouts: &[],
        push_constant_ranges: &[],
    });

    device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("UI Pipeline"),
        layout: Some(&layout),
        vertex: wgpu::VertexState {
            module: &shader,
            entry_point: "vs_main",
            buffers: &[wgpu::VertexBufferLayout {
                array_stride: std::mem::size_of::<UiVertex>() as wgpu::BufferAddress,
                step_mode: wgpu::VertexStepMode::Vertex,
                attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
            }],
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader,
            entry_point: "fs_main",
            targets: &[Some(wgpu::ColorTargetState {
                format,
                blend: Some(wgpu::BlendState::ALPHA_BLENDING),
                write_mask: wgpu::ColorWrites::ALL,
            })],
        }),
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode: Some(wgpu::Face::Back),
            polygon_mode: wgpu::PolygonMode::Fill,
            unclipped_depth: false,
            conservative: false,
        },
        depth_stencil: None,
        multisample: wgpu::MultisampleState {
            count: 1,
            mask: !0,
            alpha_to_coverage_enabled: false,
        },
        multiview: None,
    })
}
```

O shader UI (`ui.wgsl`) precisa lidar com cores e transparência:

```wgsl
struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) color: vec4<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
};

@vertex
fn vs_main(vertex: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.clip_position = vec4<f32>(vertex.position, 0.0, 1.0);
    out.color = vertex.color;
    return out;
}

@fragment
fn fs_main(fragment: VertexOutput) -> @location(0) vec4<f32> {
    return fragment.color;
}
```

Atualizar o estado do botão requer tratamento correto de eventos de mouse:

```rust
impl Button {
    pub fn handle_event(&mut self, event: &WindowEvent) -> bool {
        let mut handled = false;
        match event {
            WindowEvent::CursorMoved { position, .. } => {
                let is_inside = self.contains(position.x, position.y);
                if is_inside && self.state != ButtonState::Pressed {
                    self.state = ButtonState::Hovered;
                    handled = true;
                } else if !is_inside && self.state != ButtonState::Pressed {
                    self.state = ButtonState::Normal;
                }
            }
            WindowEvent::MouseInput { state, button, .. } if *button == MouseButton::Left => {
                let is_inside = self.contains(position.x, position.y);
                if is_inside {
                    match state {
                        ElementState::Pressed => {
                            self.state = ButtonState::Pressed;
                            handled = true;
                        }
                        ElementState::Released if self.state == ButtonState::Pressed => {
                            self.state = ButtonState::Hovered;
                            // Aqui dispararíamos o evento de clique
                            handled = true;
                        }
                        _ => {}
                    }
                } else if *state == ElementState::Released {
                    self.state = ButtonState::Normal;
                }
            }
            _ => {}
        }
        if handled {
            self.vertices = None; // Invalida o cache
        }
        handled
    }

    fn contains(&self, x: f64, y: f64) -> bool {
        x >= self.bounds.x as f64
            && x <= (self.bounds.x + self.bounds.width) as f64
            && y >= self.bounds.y as f64
            && y <= (self.bounds.y + self.bounds.height) as f64
    }
}
```

A renderização final usa instancing para eficiência:

```rust
impl Button {
    pub fn update_vertices(&mut self, device: &wgpu::Device) {
        if self.vertices.is_some() {
            return;
        }

        let color = match self.state {
            ButtonState::Normal => [0.3, 0.3, 0.5, 1.0],
            ButtonState::Hovered => [0.4, 0.4, 0.6, 1.0],
            ButtonState::Pressed => [0.2, 0.2, 0.4, 1.0],
        };

        let vertices = [
            UiVertex {
                position: [self.bounds.x, self.bounds.y],
                color,
            },
            UiVertex {
                position: [self.bounds.x + self.bounds.width, self.bounds.y],
                color,
            },
            UiVertex {
                position: [self.bounds.x, self.bounds.y + self.bounds.height],
                color,
            },
            UiVertex {
                position: [self.bounds.x + self.bounds.width, self.bounds.y + self.bounds.height],
                color,
            },
        ];

        let vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Button Vertex Buffer"),
            contents: bytemuck::cast_slice(&vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });

        self.vertices = Some(vertex_buffer);
    }

    pub fn render<'a>(&'a self, render_pass: &mut wgpu::RenderPass<'a>) {
        if let Some(vertex_buffer) = &self.vertices {
            render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
            render_pass.draw(0..4, 0..1);
        }
    }
}
```

**Exercício**: Implemente um widget `Checkbox` que alterna entre estados marcado/não marcado ao ser clicado. Inclua:
1. Tratamento de eventos de mouse
2. Renderização de dois estados visuais distintos
3. Callback para notificar mudanças de estado

**Solução**:

```rust
#[derive(Debug)]
pub struct Checkbox {
    bounds: Rectangle,
    checked: bool,
    vertices: Option<wgpu::Buffer>,
}

impl Checkbox {
    pub fn new(logical_position: (f32, f32), size: f32, dpi_factor: f64) -> Self {
        let physical_size = (size * dpi_factor as f32).round();
        Checkbox {
            bounds: Rectangle {
                x: (logical_position.0 * dpi_factor as f32).round(),
                y: (logical_position.1 * dpi_factor as f32).round(),
                width: physical_size,
                height: physical_size,
            },
            checked: false,
            vertices: None,
        }
    }

    pub fn handle_event(&mut self, event: &WindowEvent) -> bool {
        match event {
            WindowEvent::MouseInput { state, button, .. } if *button == MouseButton::Left => {
                if *state == ElementState::Released && self.contains(position.x, position.y) {
                    self.checked = !self.checked;
                    self.vertices = None;
                    return true;
                }
            }
            _ => {}
        }
        false
    }

    pub fn update_vertices(&mut self, device: &wgpu::Device) {
        if self.vertices.is_some() {
            return;
        }

        let border_color = [0.5, 0.5, 0.5, 1.0];
        let fill_color = if self.checked {
            [0.2, 0.8, 0.2, 1.0]
        } else {
            [0.8, 0.2, 0.2, 1.0]
        };

        let mut vertices = Vec::new();
        // Borda externa
        vertices.extend(create_quad(
            self.bounds.x,
            self.bounds.y,
            self.bounds.width,
            self.bounds.height,
            border_color,
        ));
        // Preenchimento interno
        let padding = 2.0;
        vertices.extend(create_quad(
            self.bounds.x + padding,
            self.bounds.y + padding,
            self.bounds.width - 2.0 * padding,
            self.bounds.height - 2.0 * padding,
            fill_color,
        ));

        let vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Checkbox Vertex Buffer"),
            contents: bytemuck::cast_slice(&vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });

        self.vertices = Some(vertex_buffer);
    }
}
```