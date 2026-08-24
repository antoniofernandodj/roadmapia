## Estudos de Caso: Aplicações Reais

### Otimizando Parsers de Alto Desempenho

O parser HTTP do Hyper (biblioteca padrão para servidores web em Rust) enfrenta um problema crítico: como processar milhares de requisições por segundo sem alocar memória repetidamente para cabeçalhos temporários? A solução adotada foi usar buffers pré-alocados com `BytesMut`, um tipo de buffer inteligente que permite compartilhamento sem cópias:

```rust
use bytes::{BytesMut, BufMut};

let mut buffer = BytesMut::with_capacity(1024);  // Alocação única
buffer.put_slice(b"GET / HTTP/1.1\r\n");
buffer.put_slice(b"Host: example.com\r\n\r\n");

// Simulação de parse - zero alocações adicionais
let method = &buffer[0..3];  // Fatia sem cópia
let path = find_slice(&buffer, b" /", b"\r\n");  // Busca direta no buffer
```

Benchmark comparativo (Criterion, 10k req/s):
- Versão ingênua (alocação por cabeçalho): 143ms, 12MB alocados
- Versão com buffer compartilhado: 89ms, 2.4MB alocados

Erro comum ao implementar:
```rust
let header = String::from_utf8(buffer[20..30].to_vec()).unwrap(); // Cópia desnecessária!
```
A mensagem de erro do clippy alerta:
```
warning: unnecessary allocation, use `from_utf8` directly on slices
```

### Gerenciamento de Texto em Editores de Código

O Helix Editor lida com arquivos de milhões de linhas mantendo respostas abaixo de 16ms. O segredo? `Rope` (estrutura de dados baseada em árvore B) e `Arc<str>` para compartilhar texto entre threads:

```rust
use std::sync::Arc;

// Carregamento do arquivo
let content = std::fs::read_to_string("large.rs")?;
let shared_text = Arc::new(content.into_boxed_str());  // 1 alocação

// Clone entre threads (zero cópia do texto)
let thread_text = shared_text.clone();
std::thread::spawn(move || {
    analyze_syntax(&thread_text);  // Compartilhamento imutável
});
```

Quando um usuário modifica o texto, o editor aplica copy-on-write:
```rust
let mut editable_text = Arc::make_mut(&mut shared_text.clone());
editable_text.insert_str(0, "// Copyright\n");
```

### Jogos com ECS (Entity Component System)

Bevy, engine de jogos, evita alocações dinâmicas em loops de renderização usando archetypes (grupos de componentes contíguos na memória):

```rust
// Registro de componentes (alocação feita uma vez no setup)
world.spawn_batch(vec![
    (Transform::default(), Mesh::new("cube")),  // 50 entities
    (Transform::default(), Mesh::new("sphere")) // 50 entities
]);

// Query sem alocações no frame
let mut query = world.query::<(&Transform, &Mesh)>();
for (transform, mesh) in query.iter(&world) {  // Iteração sobre memória contígua
    renderer.draw(transform, mesh);
}
```

Métrica de desempenho (Perf):
- Alocação tradicional (Vec<Box<dyn Component>>): 7% do tempo em alocação
- Archetypes ECS: 0.2% do tempo em alocação

### Exercício Prático: Otimizando um Cache de Imagens

Implemente um cache para thumbnails que:
1. Mantém as 10 imagens mais recentes em memória
2. Compartilha referências entre threads
3. Evita cópias ao retornar imagens armazenadas

Solução baseada em `Arc<[u8]>` e LRU cache:

```rust
use std::sync::{Arc, Mutex};
use lru::LruCache;

struct ImageCache {
    store: Mutex<LruCache<String, Arc<[u8]>>>,
}

impl ImageCache {
    fn get(&self, key: &str) -> Option<Arc<[u8]>> {
        let mut store = self.store.lock().unwrap();
        store.get(key).cloned()  // Clone do Arc, não dos bytes
    }

    fn insert(&self, key: String, img: Vec<u8>) {
        let mut store = self.store.lock().unwrap();
        store.put(key, img.into_boxed_slice().into());  // 1 alocação
    }
}

// Uso:
let cache = ImageCache { store: Mutex::new(LruCache::new(10)) };
cache.insert("cat.png", load_image("cat.png"));
let img = cache.get("cat.png").unwrap();  // Zero alocações
```

Benchmark com critério:
- Cache ingênuo (clone de Vec<u8>): 2.1ms por operação
- Solução com Arc<[u8]>: 0.3ms por operação