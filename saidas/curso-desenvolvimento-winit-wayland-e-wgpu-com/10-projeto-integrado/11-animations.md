## Animations

Uma interface estática é funcional, mas falta vida. Quando um botão responde ao clique com um leve afundamento, ou uma transição suave guia o olhar entre telas, a experiência se torna intuitiva. Em Rust com WGPU, animações não são apenas estéticas — são otimizações. Um quadrado que se move entre dois pontos pode ser renderizado 60 vezes por segundo, ou podemos calcular seu trajeto uma vez e deixar a GPU interpolar os frames.

Comecemos com o caso mais simples: um retângulo que se move horizontalmente na tela. O estado da animação precisa de três valores:

```rust
struct AnimationState {
    start_position: f32,  // posição inicial (em pixels)
    end_position: f32,    // posição final
    progress: f32,        // 0.0 a 1.0
}
```

Para atualizar a posição a cada frame, usamos o tempo delta (o tempo entre frames) para evitar que a animação fique mais rápida em máquinas com maior FPS:

```rust
impl AnimationState {
    fn update(&mut self, delta_time: f32, duration: f32) {
        self.progress = (self.progress + delta_time / duration).min(1.0);
    }

    fn current_position(&self) -> f32 {
        self.start_position + (self.end_position - self.start_position) * self.progress
    }
}
```

No loop principal, após processar os eventos do Winit, atualizamos e renderizamos:

```rust
let mut animation = AnimationState {
    start_position: 50.0,
    end_position: 400.0,
    progress: 0.0,
};

event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Poll;

    match event {
        Event::MainEventsCleared => {
            let now = Instant::now();
            let delta_time = now.duration_since(last_frame_time).as_secs_f32();
            last_frame_time = now;

            animation.update(delta_time, 2.0); // Duração de 2 segundos

            let current_pos = animation.current_position();
            // Renderiza o retângulo em `current_pos`
        }
        _ => (),
    }
});
```

A saída esperada é um retângulo que se move suavemente da posição 50 para 400 em 2 segundos, independente da taxa de atualização.

### Erro Comum: Acúmulo de Delta Time

Um erro frequente é esquecer de reiniciar `last_frame_time`, causando um `delta_time` gigantesco quando a janela perde foco:

```text
thread 'main' panicked at 'animation.progress overflow: 1.0000001'
```

A solução é garantir que `delta_time` tenha um valor máximo razoável:

```rust
let delta_time = delta_time.min(0.1); // Limita a 100ms (10 FPS mínimo)
```

### Interpolação Não-Linear

Movimentos lineares parecem artificiais. Funções de easing adicionam aceleração e desaceleração:

```rust
fn ease_in_out_quad(x: f32) -> f32 {
    if x < 0.5 { 2.0 * x * x } 
    else { 1.0 - (-2.0 * x + 2.0).powi(2) / 2.0 }
}
```

Modifique `current_position()` para usar easing:

```rust
fn current_position(&self) -> f32 {
    let eased_progress = ease_in_out_quad(self.progress);
    self.start_position + (self.end_position - self.start_position) * eased_progress
}
```

### Animando Propriedades de UI

Para animar um botão sendo pressionado, armazene o estado da interação:

```rust
enum ButtonState {
    Idle,
    Hovered,
    Pressed,
}

struct ButtonAnimation {
    state: ButtonState,
    progress: f32,
    target_scale: f32,
}
```

Atualize com base no estado:

```rust
impl ButtonAnimation {
    fn update(&mut self, delta_time: f32) {
        let target_progress = match self.state {
            ButtonState::Pressed => 1.0,
            _ => 0.0,
        };
        
        // Interpola suavemente para o target
        self.progress = if self.progress < target_progress {
            (self.progress + delta_time * 5.0).min(target_progress)
        } else {
            (self.progress - delta_time * 5.0).max(target_progress)
        };
    }

    fn current_scale(&self) -> f32 {
        1.0 + (self.target_scale - 1.0) * self.progress
    }
}
```

### Exercício: Animação de Transição de Tela

Implemente um sistema onde duas "telas" (retângulos coloridos) trocam de lugar com uma animação de deslize. A tela atual deve sair para a esquerda enquanto a nova entra da direita, ambas movendo-se simultaneamente.

**Solução:**

```rust
struct ScreenTransition {
    current_screen: usize,
    progress: f32,
    screens: [Rectangle; 2],
}

impl ScreenTransition {
    fn update(&mut self, delta_time: f32) {
        self.progress = (self.progress + delta_time * 2.0).min(1.0);
    }

    fn render(&self) {
        let offset = self.progress * SCREEN_WIDTH;
        
        // Tela atual saindo para a esquerda
        render_rectangle(
            self.screens[self.current_screen],
            -offset,
            0.0,
        );
        
        // Nova tela entrando da direita
        let next_screen = (self.current_screen + 1) % 2;
        render_rectangle(
            self.screens[next_screen],
            SCREEN_WIDTH - offset,
            0.0,
        );
    }

    fn trigger(&mut self) {
        self.current_screen = (self.current_screen + 1) % 2;
        self.progress = 0.0;
    }
}
```