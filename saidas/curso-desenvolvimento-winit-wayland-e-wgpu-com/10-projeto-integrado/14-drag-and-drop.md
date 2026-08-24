## Drag and Drop

Implementar drag and drop em uma aplicação gráfica customizada parece simples até você precisar coordenar três sistemas distintos: a janela (Winit), o protocolo de exibição (Wayland) e a renderização (WGPU). O desafio começa quando o usuário clica em um elemento e arrasta - seu programa precisa:

1. Identificar o início da operação (mouse down)
2. Rastrear o movimento (mouse move)
3. Confirmar o destino (mouse up)
4. Atualizar a interface visualmente durante todo o processo

Vamos implementar isso em nosso editor de texto, permitindo arrastar abas entre janelas. Primeiro, estendemos o `EditorState` para rastrear o estado do drag:

```rust
#[derive(Debug)]
pub struct DragState {
    pub active: bool,
    pub start_pos: (f32, f32),
    pub current_pos: (f32, f32),
    pub tab_index: usize,
}

pub struct EditorState {
    // ... outros campos
    pub drag_state: Option<DragState>,
}
```

O tratamento de eventos no loop principal precisa detectar três fases:

```rust
match event {
    WindowEvent::MouseInput { button, state, .. } if button == MouseButton::Left => {
        if state == ElementState::Pressed {
            // Verifica se o clique foi em uma aba
            if let Some(tab_index) = ui_state.tab_under_cursor {
                state.drag_state = Some(DragState {
                    active: true,
                    start_pos: cursor_pos,
                    current_pos: cursor_pos,
                    tab_index,
                });
            }
        } else if state.drag_state.is_some() {
            // Lógica para finalizar o drop
            handle_drop(&mut state, cursor_pos);
            state.drag_state = None;
        }
    }
    WindowEvent::CursorMoved { position, .. } => {
        if let Some(drag) = &mut state.drag_state {
            drag.current_pos = (position.x as f32, position.y as f32);
            // Atualiza a posição visual durante o arrasto
            request_redraw(window_id);
        }
    }
    // ... outros eventos
}
```

A renderização precisa desenhar o elemento sendo arrastado em uma camada superior, com um efeito visual de "elevação":

```rust
fn render_dragged_tab(
    render_pass: &mut wgpu::RenderPass,
    drag_state: &DragState,
    gpu_resources: &GpuResources,
) {
    let offset = (
        drag_state.current_pos.0 - drag_state.start_pos.0,
        drag_state.current_pos.1 - drag_state.start_pos.1,
    );

    let vertices = create_tab_vertices(
        TAB_WIDTH,
        TAB_HEIGHT,
        offset,
        true, // is_dragged flag
    );

    render_pass.set_pipeline(&gpu_resources.tab_pipeline);
    render_pass.set_vertex_buffer(0, vertex_buffer.slice(..));
    render_pass.draw(0..4, 0..1);
}
```

Um erro comum é esquecer de converter as coordenadas do cursor para o espaço lógico da interface, especialmente em monitores com alta densidade de pixels (HiDPI). Sem essa conversão, o elemento arrastado aparece desalinhado:

```rust
// ERRO COMUM: esquecer a conversão de DPI
let cursor_pos = (
    position.x as f32 / window.scale_factor() as f32,
    position.y as f32 / window.scale_factor() as f32,
);
```

Para Wayland, precisamos implementar o protocolo `wl_data_device` para permitir drag and drop entre aplicações. Isso requer negociação de formatos MIME e gerenciamento de ofertas de dados:

```rust
impl DataDeviceHandler for Editor {
    fn data_offer(&mut self, offer: &wl_data_offer::WlDataOffer) {
        // Negocia formatos suportados
        offer.offer("text/plain");
        offer.offer("text/utf8");
    }

    fn drop_performed(&mut self) {
        // Lida com o drop finalizado
        self.state.handle_external_drop();
    }
}
```

O exercício final consiste em implementar um sistema de snap zones - áreas onde os elementos arrastados se encaixam automaticamente quando liberados próximos o suficiente. A solução deve:

1. Calcular distâncias entre a posição atual e as zonas válidas
2. Aplicar uma animação suave ao encaixar
3. Atualizar o layout da interface após o drop

```rust
// Solução para snap zones
fn handle_drop(state: &mut EditorState, pos: (f32, f32)) {
    let mut best_zone = None;
    let mut min_dist = f32::MAX;

    for (i, zone) in state.layout.snap_zones.iter().enumerate() {
        let dist = distance(pos, zone.center());
        if dist < SNAP_THRESHOLD && dist < min_dist {
            min_dist = dist;
            best_zone = Some(i);
        }
    }

    if let Some(zone_idx) = best_zone {
        // Animação de snap
        state.start_snap_animation(zone_idx);
    } else {
        // Drop normal
        state.finish_drop(pos);
    }
}
```