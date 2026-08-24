## UI Básica

Criar uma interface de usuário do zero em Rust exige um equilíbrio entre controle absoluto sobre a renderização e a ergonomia de widgets pré-fabricados. Vamos construir um sistema de UI mínimo que renderiza retângulos coloridos interativos, demonstrando os princípios fundamentais que você usará para componentes mais complexos.

O problema central é coordenar três sistemas:
1. **Input**: capturar eventos de mouse e traduzi-los para coordenadas lógicas
2. **Layout**: posicionar elementos na tela com um sistema de constraints
3. **Renderização**: desenhar os elementos usando WGPU

Começamos definindo o tipo mais básico de elemento de UI:

```rust
#[derive(Debug)]
pub struct UiRect {
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
    pub color: [f32; 4],
    pub hovered: bool,
}

impl UiRect {
    pub fn contains(&self, x: f32, y: f32) -> bool {
        x >= self.x && x <= self.x + self.width &&
        y >= self.y && y <= self.y + self.height
    }
}
```

Agora, criamos um sistema de UI que mantém o estado dos elementos:

```rust
pub struct UiSystem {
    elements: Vec<UiRect>,
    vertex_buffer: wgpu::Buffer,
    vertex_count: u32,
    pipeline: wgpu::RenderPipeline,
}

impl UiSystem {
    pub fn new(device: &wgpu::Device, config: &wgpu::SurfaceConfiguration) -> Self {
        // Código de inicialização do pipeline omitido por brevidade
        // (será mostrado adiante com os erros comuns)
        todo!()
    }

    pub fn add_rect(&mut self, rect: UiRect) {
        self.elements.push(rect);
        self.update_buffers = true;
    }

    pub fn handle_mouse(&mut self, x: f32, y: f32) {
        for element in &mut self.elements {
            element.hovered = element.contains(x, y);
        }
    }
}
```

O erro mais comum aqui é esquecer de marcar `update_buffers` quando o estado muda. Se você não atualizar os buffers da GPU, a UI ficará congelada. Veja como deve ser a implementação real do pipeline:

```rust
pub fn new(device: &wgpu::Device, config: &wgpu::SurfaceConfiguration) -> Self {
    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("UI Shader"),
        source: wgpu::ShaderSource::Wgsl(include_str!("ui.wgsl").into()),
    });

    let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: Some("UI Pipeline Layout"),
        bind_group_layouts: &[],
        push_constant_ranges: &[],
    });

    let pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("UI Pipeline"),
        layout: Some(&pipeline_layout),
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
                format: config.format,
                blend: Some(wgpu::BlendState::ALPHA_BLENDING),
                write_mask: wgpu::ColorWrites::ALL,
            })],
        }),
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode: None,
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
    });

    let vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("UI Vertex Buffer"),
        size: (std::mem::size_of::<UiVertex>() * 6 * MAX_ELEMENTS) as wgpu::BufferAddress,
        usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });

    Self {
        elements: Vec::new(),
        vertex_buffer,
        vertex_count: 0,
        pipeline,
    }
}
```

O shader UI básico (`ui.wgsl`):

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
fn fs_main(frag: VertexOutput) -> @location(0) vec4<f32> {
    return frag.color;
}
```

Para integrar com o loop principal, adicione isto ao seu `main.rs`:

```rust
let mut ui = UiSystem::new(&device, &config);

// Adiciona um retângulo vermelho que fica verde quando hover
ui.add_rect(UiRect {
    x: 100.0,
    y: 100.0,
    width: 200.0,
    height: 100.0,
    color: [1.0, 0.0, 0.0, 1.0],
    hovered: false,
});

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::RedrawRequested(window_id) if window_id == window.id() => {
            let output = surface.get_current_texture()?;
            let view = output.texture.create_view(&wgpu::TextureViewDescriptor::default());
            
            let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
                label: Some("UI Render Encoder"),
            });
            
            {
                let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("UI Render Pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(wgpu::Color::WHITE),
                            store: true,
                        },
                    })],
                    depth_stencil_attachment: None,
                });
                
                render_pass.set_pipeline(&ui.pipeline);
                render_pass.set_vertex_buffer(0, ui.vertex_buffer.slice(..));
                render_pass.draw(0..ui.vertex_count, 0..1);
            }
            
            queue.submit(std::iter::once(encoder.finish()));
            output.present();
        }
        Event::MainEventsCleared => {
            window.request_redraw();
        }
        Event::DeviceEvent { event: DeviceEvent::MouseMotion { delta: (x, y) }, .. } => {
            let scale = window.scale_factor();
            let physical_position = window.inner_position().unwrap();
            let logical_x = physical_position.x as f32 + x as f32;
            let logical_y = physical_position.y as f32 + y as f32;
            ui.handle_mouse(logical_x / scale, logical_y / scale);
        }
        _ => (),
    }
});
```

**Erro comum**: esquecer de converter coordenadas físicas para lógicas. Se você usar as coordenadas do mouse diretamente sem considerar o DPI, os elementos de UI não responderão corretamente ao hover. A solução está no tratamento do `scale_factor` e da posição da janela.

**Exercício**: Implemente um botão que muda de cor quando clicado. Dica: você precisará:
1. Adicionar um campo `clicked` ao `UiRect`
2. Modificar `handle_mouse` para detectar clicks
3. Atualizar o shader para responder ao estado de click

**Solução**:

```rust
#[derive(Debug)]
pub struct UiRect {
    // ... campos anteriores
    pub clicked: bool,
}

impl UiSystem {
    pub fn handle_click(&mut self, x: f32, y: f32) {
        for element in &mut self.elements {
            element.clicked = element.contains(x, y);
        }
    }
}

// No event loop:
Event::WindowEvent { event: WindowEvent::MouseInput { button: MouseButton::Left, state: ElementState::Pressed, .. }, .. } => {
    let scale = window.scale_factor();
    let physical_position = window.inner_position().unwrap();
    let logical_x = physical_position.x as f32 + x as f32;
    let logical_y = physical_position.y as f32 + y as f32;
    ui.handle_click(logical_x / scale, logical_y / scale);
}
```

E modifique o shader para responder ao estado:

```wgsl
@fragment
fn fs_main(frag: VertexOutput) -> @location(0) vec4<f32> {
    if frag.clicked > 0.5 {
        return vec4<f32>(frag.color.rgb * 0.8, frag.color.a);
    }
    return frag.color;
}
```