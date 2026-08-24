## Gerenciamento de Recursos Gráficos

Aplicações gráficas lidam com recursos pesados: texturas, buffers de vértices, shaders e fontes. Um gerenciamento inadequado causa gargalos visíveis - desde stuttering na renderização até vazamentos de memória que acumulam em sessões longas. Rust oferece ferramentas para controle preciso desses recursos.

### O Problema do Carregamento Duplicado

Considere um editor de imagens que permite aplicar filtros. Sem cuidado, cada instância do filtro carrega sua própria cópia dos shaders:

```rust
struct Filter {
    shader: ShaderProgram, // 2MB de VRAM cada
    parameters: FilterParams
}

impl Filter {
    fn new() -> Self {
        Self {
            shader: ShaderProgram::load("/shaders/blur.glsl")?, // Alocação pesada
            parameters: Default::default()
        }
    }
}
```

Ao criar 10 filtros iguais, consumimos 20MB de VRAM desnecessariamente. O erro aparece quando monitoramos o uso de memória:

```
[Memory Profiler] VRAM usage: 24.7MB (10 shader instances)
```

### Compartilhamento com Arc

A solução é compartilhar os shaders entre instâncias usando contagem de referências:

```rust
use std::sync::Arc;

struct Filter {
    shader: Arc<ShaderProgram>, // Referência compartilhada
    parameters: FilterParams
}

lazy_static! {
    static ref BLUR_SHADER: Arc<ShaderProgram> = 
        Arc::new(ShaderProgram::load("/shaders/blur.glsl").unwrap());
}

impl Filter {
    fn new() -> Self {
        Self {
            shader: BLUR_SHADER.clone(), // Incrementa contador
            parameters: Default::default()
        }
    }
}
```

Agora 10 filtros usam apenas 2.2MB (2MB do shader + overhead das estruturas). Verificamos no profiler:

```
[Memory Profiler] VRAM usage: 2.2MB (1 shader instance + references)
```

### Gerenciamento de Ciclo de Vida com Texturas

Texturas grandes devem ser liberadas quando não usadas. Um erro comum é manter referências em caches indefinidamente:

```rust
struct TextureCache {
    store: HashMap<String, Texture>, // Texturas nunca são liberadas
}
```

Isso causa vazamentos ao carregar muitas texturas temporárias. A solução combina Weak para evitar ciclos:

```rust
struct TextureCache {
    store: HashMap<String, Weak<Texture>>, // Não impede liberação
}

impl TextureCache {
    fn get(&mut self, path: &str) -> Arc<Texture> {
        if let Some(weak) = self.store.get(path) {
            if let Some(texture) = weak.upgrade() {
                return texture;
            }
        }
        
        let texture = Arc::new(Texture::load(path)?);
        self.store.insert(path.to_string(), Arc::downgrade(&texture));
        texture
    }
}
```

Quando a última Arc é dropada, a textura é liberada automaticamente, mas pode ser recarregada se necessário.

### Pool de Objetos Gráficos

Para objetos frequentemente criados/destruídos (como partículas), alocações dinâmicas são custosas. Um object pool pré-aloca recursos:

```rust
struct ParticlePool {
    free_textures: Vec<Arc<Texture>>,
    in_use: Vec<Arc<Texture>>,
}

impl ParticlePool {
    fn acquire(&mut self) -> Arc<Texture> {
        if let Some(texture) = self.free_textures.pop() {
            self.in_use.push(texture.clone());
            texture
        } else {
            let new_text = Arc::new(Texture::default_particle());
            self.in_use.push(new_text.clone());
            new_text
        }
    }

    fn release(&mut self, texture: Arc<Texture>) {
        if let Some(pos) = self.in_use.iter().position(|t| Arc::ptr_eq(t, &texture)) {
            let texture = self.in_use.remove(pos);
            self.free_textures.push(texture);
        }
    }
}
```

Benchmark mostra melhoria de 40% no tempo de criação de partículas:

```
[Benchmark] Particle creation:
- Dynamic allocation: 12,340ns/op
- Object pool: 7,210ns/op
```

### Exercício Prático

Implemente um `FontCache` que:
1. Compartilha fontes idênticas usando `Arc`
2. Limpa fontes não usadas há mais de 5 minutos
3. Reutiliza instâncias ao invés de recarregar

**Solução comentada:**

```rust
use std::sync::{Arc, Weak};
use std::collections::HashMap;
use std::time::{Instant, Duration};

struct Font {
    data: Vec<u8>,
    last_used: Instant,
}

struct FontCache {
    store: HashMap<String, Weak<Font>>,
}

impl FontCache {
    fn get(&mut self, path: &str) -> Arc<Font> {
        self.cleanup(); // Limpeza periódica

        if let Some(weak) = self.store.get(path) {
            if let Some(font) = weak.upgrade() {
                font.last_used = Instant::now();
                return font;
            }
        }

        let font_data = std::fs::read(path)?;
        let font = Arc::new(Font {
            data: font_data,
            last_used: Instant::now(),
        });
        
        self.store.insert(path.to_string(), Arc::downgrade(&font));
        font
    }

    fn cleanup(&mut self) {
        self.store.retain(|_, weak| {
            weak.upgrade().map_or(false, |font| {
                font.last_used.elapsed() < Duration::from_secs(300)
            })
        });
    }
}
```

Chaves da implementação:
- `Weak` permite que fontes não referenciadas sejam liberadas
- `cleanup` remove entradas com fontes expiradas
- Atualização do `last_used` evite remoção prematura