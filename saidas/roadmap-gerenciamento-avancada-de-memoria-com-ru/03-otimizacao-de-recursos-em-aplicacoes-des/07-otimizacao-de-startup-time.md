## Otimização de Startup Time

Um aplicativo desktop que demora para iniciar frustra usuários e sugere código não otimizado. O problema real está em operações bloqueantes durante a inicialização: carregamento de recursos pesados, inicialização desnecessária de subsistemas e alocações em excesso. Veja o impacto em um caso real:

```rust
use std::time::Instant;

fn main() {
    let start = Instant::now();
    
    // Problema 1: Carregamento síncrono de assets
    let _texture = load_texture("assets/hd_background.png"); // 800ms
    let _font = load_font("assets/giant_font.ttf"); // 400ms
    
    // Problema 2: Inicialização antecipada de módulos
    database::init(); // 300ms (não usado até o usuário clicar "Salvar")
    
    println!("Tempo de inicialização: {:?}", start.elapsed());
}
```

Saída típica:
```
Tempo de inicialização: 1.512s
```

### Técnica 1: Carregamento Preguiçoso (Lazy Loading)

Converta inicializações para `OnceCell` ou `Lazy` (do crate `once_cell`), que executam apenas quando acessados:

```rust
use once_cell::sync::Lazy;
use std::sync::Mutex;

static DB_CONN: Lazy<Mutex<Database>> = Lazy::new(|| {
    Mutex::new(database::init()) // Só executa na primeira chamada
});

// Uso posterior quando necessário:
fn save_data() {
    let conn = DB_CONN.lock().unwrap();
    conn.save();
}
```

### Técnica 2: Carregamento Assíncrono

Para recursos gráficos, use threads ou carregamento assíncrono com indicadores de progresso:

```rust
fn main() {
    let runtime = tokio::runtime::Runtime::new().unwrap();
    runtime.block_on(async {
        let texture_task = tokio::spawn(load_texture_async("assets/bg.png"));
        let font_task = tokio::spawn(load_font_async("assets/font.ttf"));
        
        show_splash_screen();
        
        let _texture = texture_task.await.unwrap();
        let _font = font_task.await.unwrap();
    });
}
```

### Técnica 3: Pré-compilação de Recursos

Converta recursos para formatos binários otimizados durante o build:

```toml
# Cargo.toml
[build-dependencies]
embed-resource = "0.1"
```

```rust
// build.rs
fn main() {
    embed_resource::compile("assets/compiled_resources.embed");
}
```

### Erro Comum e Solução

**Problema**: Inicializar todos os componentes da GUI antes de mostrar a janela principal:

```rust
fn main() {
    let app = App::new()
        .init_sidebar() // Carrega dados pesados
        .init_toolbar() // Pré-renderiza ícones
        .run(); // Só então exibe a janela
}
```

**Solução**: Estruture em fases:

```rust
fn main() {
    let mut app = App::new()
        .show_main_window(); // Exibe imediatamente
        
    tokio::spawn(async {
        app.init_sidebar().await; // Carrega em background
        app.init_toolbar().await;
    });
}
```

### Exercício Prático

Modifique este código para reduzir o startup time usando lazy loading:

```rust
struct App {
    config: Config,
    db: Database,
    cache: Cache,
}

impl App {
    fn new() -> Self {
        Self {
            config: load_config(), // 200ms
            db: connect_db(),      // 300ms
            cache: build_cache(),  // 150ms
        }
    }
}
```

**Solução**:

```rust
use once_cell::sync::Lazy;

struct App {
    config: &'static Config,
    db: &'static Database,
    cache: &'static Cache,
}

static CONFIG: Lazy<Config> = Lazy::new(|| load_config());
static DB: Lazy<Database> = Lazy::new(|| connect_db());
static CACHE: Lazy<Cache> = Lazy::new(|| build_cache());

impl App {
    fn new() -> Self {
        Self {
            config: &CONFIG,
            db: &DB,
            cache: &CACHE,
        }
    }
}
```

Esta abordagem reduz o tempo inicial para quase zero, adiando os custos até o primeiro uso de cada recurso.