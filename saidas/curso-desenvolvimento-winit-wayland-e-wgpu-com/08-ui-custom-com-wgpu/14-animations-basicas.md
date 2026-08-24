## Animations Básicas

Uma interface sem animações parece estática e desconectada. Quando um elemento aparece, desaparece ou muda de estado, queremos que essa transição seja suave para guiar o olhar do usuário. Em WGPU, isso exige coordenar três componentes: o tempo, o estado da animação e a renderização.

Começamos com o caso mais simples: um quadrado que se move horizontalmente. O código abaixo cria uma animação linear de 2 segundos, indo da posição x=0 até x=200:

```rust
struct Animation {
    start_time: Instant,
    duration: Duration,
    start_value: f32,
    end_value: f32,
}

impl Animation {
    fn current_value(&self) -> f32 {
        let elapsed = Instant::now() - self.start_time;
        let progress = elapsed.as_secs_f32() / self.duration.as_secs_f32();
        self.start_value + (self.end_value - self.start_value) * progress.min(1.0)
    }
}

let move_anim = Animation {
    start_time: Instant::now(),
    duration: Duration::from_secs(2),
    start_value: 0.0,
    end_value: 200.0,
};
```

No loop de renderização, atualizamos a posição do quadrado:

```rust
let current_x = move_anim.current_value();
render_quad(current_x, 100.0); // Função hipotética que desenha um quadrado
```

O erro mais comum aqui é esquecer de limitar o progresso com `.min(1.0)`, o que faria a animação continuar indefinidamente após o término. Sem essa proteção, `current_value()` retornaria valores cada vez maiores após os 2 segundos.

Para animações mais complexas, como um botão que muda de cor ao ser pressionado, precisamos gerenciar múltiplas propriedades:

```rust
struct ButtonState {
    position: (f32, f32),
    color: [f32; 4],
    scale: f32,
    animations: Vec<Animation>,
}

impl ButtonState {
    fn apply_animations(&mut self) {
        for anim in &self.animations {
            match anim.property {
                Property::PositionX => self.position.0 = anim.current_value(),
                Property::ColorR => self.color[0] = anim.current_value(),
                // Outras propriedades...
            }
        }
        self.animations.retain(|a| !a.is_finished());
    }
}
```

A renderização agora inclui o estado animado:

```rust
button_state.apply_animations();
render_button(
    button_state.position,
    button_state.color,
    button_state.scale,
);
```

Quando o usuário interage, adicionamos novas animações à lista:

```rust
button_state.animations.push(Animation {
    start_time: Instant::now(),
    duration: Duration::from_millis(300),
    start_value: 1.0, // Escala normal
    end_value: 0.95,  // Efeito de pressionado
    property: Property::Scale,
});
```

Um problema frequente é a sobreposição de animações na mesma propriedade. Para resolver, podemos adicionar um método que cancela animações existentes antes de adicionar novas:

```rust
fn add_animation(&mut self, new_anim: Animation) {
    self.animations.retain(|a| a.property != new_anim.property);
    self.animations.push(new_anim);
}
```

Para otimizar, evitamos recriar buffers GPU a cada frame. Em vez disso, atualizamos apenas os uniforms relevantes:

```rust
// No pipeline de renderização:
queue.write_buffer(
    &uniform_buffer,
    0,
    bytemuck::cast_slice(&[Uniforms {
        position: button_state.position,
        color: button_state.color,
        scale: button_state.scale,
    }]),
);
```

Exercício: Implemente um efeito de fade-in para um texto que aparece gradualmente ao carregar a tela. A opacidade deve ir de 0.0 (transparente) a 1.0 (opaco) em 1 segundo.

Solução:

```rust
let fade_anim = Animation {
    start_time: Instant::now(),
    duration: Duration::from_secs(1),
    start_value: 0.0,
    end_value: 1.0,
    property: Property::Opacity,
};

// No loop de renderização:
let opacity = fade_anim.current_value();
render_text("Hello World", opacity); // Usando opacity no shader ou blend state
```

O segredo está em configurar o blend state corretamente no pipeline WGPU:

```rust
let blend_state = wgpu::BlendState {
    color: wgpu::BlendComponent {
        src_factor: wgpu::BlendFactor::SrcAlpha,
        dst_factor: wgpu::BlendFactor::OneMinusSrcAlpha,
        operation: wgpu::BlendOperation::Add,
    },
    alpha: wgpu::BlendComponent::OVER,
};
```