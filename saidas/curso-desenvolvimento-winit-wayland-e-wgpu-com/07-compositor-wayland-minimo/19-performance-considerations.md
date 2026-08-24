## Performance Considerations

Um compositor Wayland lida com centenas de eventos por segundo enquanto coordena a renderização de múltiplas superfícies. O gargalo mais imediato aparece quando você tenta processar tudo sequencialmente:

```rust
// Exemplo problemático - loop de eventos bloqueante
while let Some(event) = event_receiver.recv() {
    handle_event(event); // Bloqueia até terminar
    render_surfaces();   // Só executa após o evento
}
```

A saída desse código mostra o problema claramente:

```
Frame 1: 16ms (60 FPS)
Frame 2: 120ms (evento lento)
Frame 3: 18ms 
Frame 4: 250ms (evento muito lento)
```

O primeiro erro de performance vem da mistura de tarefas de latência crítica (renderização) com operações potencialmente lentas (tratamento de eventos). A solução é separar as threads:

```rust
// Thread de renderização (prioridade máxima)
std::thread::spawn(|| {
    loop {
        render_surfaces();
        std::thread::sleep(Duration::from_millis(16)); // ~60 FPS
    }
});

// Thread principal para eventos
while let Some(event) = event_receiver.recv() {
    handle_event(event); // Pode demorar sem travar a renderização
}
```

Mas isso introduz um novo problema - conflito no acesso às superfícies. O Rust nos ajuda com `Arc<Mutex<SurfaceList>>`, mas um lock mal posicionado causa contenção:

```rust
// ERRADO: Lock mantido por muito tempo
let surfaces = surface_list.lock().unwrap();
for surface in &surfaces {
    process_surface(surface); // Operação lenta
}
// Lock só liberado aqui

// CERTO: Lock apenas para cópia dos handles
let handles: Vec<SurfaceHandle> = {
    let surfaces = surface_list.lock().unwrap();
    surfaces.iter().map(|s| s.handle()).collect()
};
for handle in handles {
    process_handle(handle); // Sem lock ativo
}
```

Outro gargalo comum é o redesenho desnecessário. Sem tracking de danos (damage tracking), você acaba renderizando superfícies inteiras mesmo quando apenas uma pequena região mudou:

```rust
// Sem damage tracking - renderiza tudo
fn render() {
    for surface in &surfaces {
        renderer.draw(surface); // Desenha surface completa
    }
}

// Com damage tracking - só áreas alteradas
fn render(damage: &DamageRegion) {
    for surface in &surfaces {
        if damage.intersects(surface.rect()) {
            renderer.draw(surface, damage); // Clipping automático
        }
    }
}
```

O impacto é visível no uso da GPU:

```
Sem damage tracking: 
GPU usage: 45% (renderiza 1920x1080 todo frame)

Com damage tracking (10% da tela muda):
GPU usage: 8% (só renderiza 1920x108 pixels)
```

Para input, o problema inverso ocorre - eventos de mouse em alta frequência (1000Hz) podem sobrecarregar o sistema se processados individualmente. A solução é agregação:

```rust
let mut mouse_events = Vec::new();
while let Ok(event) = mouse_receiver.try_recv() {
    mouse_events.push(event);
}
if !mouse_events.is_empty() {
    process_aggregated_events(&mouse_events); // Processa em lote
}
```

Exercício: Implemente um sistema de damage tracking que:
1. Aceita regiões retangulares de dano
2. Mescla regiões sobrepostas
3. Fornece um iterator para as regiões afetadas

Solução comentada:

```rust
struct DamageTracker {
    regions: Vec<Rect>,
}

impl DamageTracker {
    fn add_damage(&mut self, new_rect: Rect) {
        // Mescla com regiões existentes se sobrepostas
        for existing in &mut self.regions {
            if existing.intersects(&new_rect) {
                *existing = existing.union(&new_rect);
                return;
            }
        }
        // Nova região se não houve overlap
        self.regions.push(new_rect);
    }

    fn regions(&self) -> impl Iterator<Item = &Rect> {
        self.regions.iter()
    }

    fn clear(&mut self) {
        self.regions.clear();
    }
}
```