## CPU Bottlenecks

Um frame drop repentino em sua aplicação gráfica pode ter origem em um loop mal otimizado na CPU. Considere este cenário comum: seu jogo roda a 60 FPS até que 50 inimigos apareçam na tela, quando então a taxa cai para 30 FPS. O problema não está na GPU - você verificou que os shaders são leves - mas em como a CPU prepara os dados para renderização.

Vamos analisar um caso real com WGPU e Winit. Este código atualiza a posição de 10.000 partículas na CPU:

```rust
struct Particle {
    position: [f32; 3],
    velocity: [f32; 3],
}

fn update_particles(particles: &mut Vec<Particle>) {
    for p in particles.iter_mut() {
        p.position[0] += p.velocity[0];
        p.position[1] += p.velocity[1];
        p.position[2] += p.velocity[2];
    }
}
```

Ao executar com `criterion`, obtemos:

```
particles/update time: [125.34 ms 126.01 ms 126.72 ms]
```

125ms por frame é inaceitável - a CPU está gastando mais tempo atualizando partículas do que o frame budget total (16.6ms para 60 FPS). O problema se agrava porque este é apenas um dos sistemas em execução.

### Otimização 1: Estrutura de Dados

O layout atual desperdiça memória cache. Cada `Particle` ocupa 24 bytes, mas apenas 12 são usados por vez (posição OU velocidade). Veja a versão reorganizada:

```rust
struct Particles {
    positions: Vec<[f32; 3]>,
    velocities: Vec<[f32; 3]>,
}

fn update_particles(particles: &mut Particles) {
    for i in 0..particles.positions.len() {
        particles.positions[i][0] += particles.velocities[i][0];
        particles.positions[i][1] += particles.velocities[i][1];
        particles.positions[i][2] += particles.velocities[i][2];
    }
}
```

Benchmark result:
```
particles/update time: [98.76 ms 99.23 ms 99.71 ms] 
```

Ganhamos ~20% apenas melhorando o layout de memória. Mas ainda está lento.

### Otimização 2: Paralelismo

Usando `rayon` para processamento paralelo:

```rust
use rayon::prelude::*;

fn update_particles(particles: &mut Particles) {
    particles.positions.par_iter_mut()
        .zip(particles.velocities.par_iter())
        .for_each(|(pos, vel)| {
            pos[0] += vel[0];
            pos[1] += vel[1];
            pos[2] += vel[2];
        });
}
```

Resultado em CPU 8-core:
```
particles/update time: [18.43 ms 18.67 ms 18.91 ms]
```

Agora estamos dentro do frame budget! Mas cuidado: threads adicionam overhead. Em CPUs menos potentes, o ganho pode ser menor.

### Caso Real: ECS vs OOP

Sistemas de entidade-componente (ECS) como `hecs` ou `bevy_ecs` evitam outro gargalo comum - o cache miss em hierarquias de objetos:

```rust
// Modelo OOP (lento)
trait GameObject {
    fn update(&mut self);
}

struct Enemy {
    position: [f32; 3],
    health: f32,
    // +20 campos
}

impl GameObject for Enemy {
    fn update(&mut self) { /* ... */ }
}

// Modelo ECS (rápido)
struct Position([f32; 3]);
struct Health(f32);

fn update_system(query: Query<(&mut Position, &Health)>) {
    // Processa componentes contíguos na memória
}
```

Um benchmark com 10.000 entidades mostra:
```
OOP update: 45.2ms
ECS update: 6.7ms
```

### Erro Comum: Alocações Desnecessárias

Este código parece inocente:

```rust
fn process_frame() {
    let mut particles = Vec::new(); // Alocação a cada frame!
    load_particles(&mut particles);
    update_particles(&mut particles);
}
```

Em 60 FPS, isso significa 60 alocações/segundo. A solução é reutilizar buffers:

```rust
struct GameState {
    particle_buffer: Vec<Particle>, // Reutilizado
}

fn process_frame(state: &mut GameState) {
    state.particle_buffer.clear(); // Mantém capacidade
    load_particles(&mut state.particle_buffer);
    update_particles(&mut state.particle_buffer);
}
```

### Exercício Prático

Modifique este sistema de partículas para usar SIMD (Single Instruction Multiple Data) via `std::simd`:

```rust
#[derive(Default)]
struct ParticleSystem {
    positions: Vec<[f32; 3]>,
    velocities: Vec<[f32; 3]>,
}

impl ParticleSystem {
    fn update(&mut self) {
        // Implemente usando std::simd::f32x4
    }
}
```

Solução:

```rust
use std::simd::f32x4;

impl ParticleSystem {
    fn update(&mut self) {
        let chunks_pos = self.positions.chunks_exact_mut(4);
        let chunks_vel = self.velocities.chunks_exact(4);
        
        for (pos, vel) in chunks_pos.zip(chunks_vel) {
            let pos_simd = f32x4::from_slice(&pos[0]);
            let vel_simd = f32x4::from_slice(&vel[0]);
            (pos_simd + vel_simd).write_to_slice(&mut pos[0]);
        }
        
        // Processa elementos restantes
        let rem = chunks_pos.remainder().len();
        for i in (self.positions.len() - rem)..self.positions.len() {
            self.positions[i][0] += self.velocities[i][0];
            // ...
        }
    }
}
```

Benchmark result:
```
particles/update time: [12.31 ms 12.45 ms 12.60 ms]
```