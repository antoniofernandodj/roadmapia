## Async Loading

Em aplicações gráficas modernas, especialmente aquelas que lidam com grandes volumes de recursos como texturas, modelos 3D ou shaders, o carregamento desses elementos pode se tornar um gargalo significativo. Se tudo for carregado de forma síncrona, o usuário pode enfrentar travamentos ou tempos de inicialização excessivamente longos. A solução é carregar recursos em background, aproveitando a capacidade de multitarefa das CPUs modernas e mantendo a aplicação responsiva.

### O Problema do Carregamento Síncrono

Imagine uma aplicação que precisa carregar uma textura de alta resolução de 4K para um modelo 3D. Se o carregamento for feito de forma síncrona, a thread principal ficará bloqueada até que a textura esteja completamente carregada. Durante esse tempo, a aplicação não responderá a eventos de entrada ou atualizações na tela, resultando em uma experiência ruim para o usuário.

```rust
let texture = Texture::load("textures/high_res_texture.png");
renderer.draw_model_with_texture(&model, &texture);
```

Aqui, `Texture::load` bloqueia a thread principal até que a textura seja carregada. Isso é inaceitável em aplicações gráficas modernas.

### Carregamento Assíncrono com `tokio`

Para resolver esse problema, podemos utilizar a crate `tokio`, que fornece um runtime assíncrono para Rust. Com `tokio`, podemos carregar a textura em uma tarefa em background, permitindo que a thread principal continue executando outras operações.

```rust
use tokio::fs;
use tokio::task;

async fn load_texture_async(path: &str) -> Result<Texture, std::io::Error> {
    let data = fs::read(path).await?;
    Texture::from_bytes(&data)
}

task::spawn(async {
    let texture = load_texture_async("textures/high_res_texture.png").await.unwrap();
    renderer.draw_model_with_texture(&model, &texture);
});
```

Neste exemplo, `load_texture_async` é uma função assíncrona que carrega a textura sem bloquear a thread principal. A função `task::spawn` cria uma nova tarefa assíncrona que executa o carregamento em background.

### Lidando com o Estado da Aplicação

Um desafio comum ao carregar recursos em background é garantir que a aplicação não tente usar um recurso antes que ele esteja completamente carregado. Para isso, podemos utilizar um `Arc<Mutex<Option<Texture>>>` para compartilhar o estado da textura entre threads de forma segura.

```rust
use std::sync::{Arc, Mutex};

let texture_state = Arc::new(Mutex::new(None));

let texture_state_clone = Arc::clone(&texture_state);
task::spawn(async move {
    let texture = load_texture_async("textures/high_res_texture.png").await.unwrap();
    *texture_state_clone.lock().unwrap() = Some(texture);
});

// No loop principal da aplicação
loop {
    if let Some(texture) = texture_state.lock().unwrap().as_ref() {
        renderer.draw_model_with_texture(&model, texture);
    } else {
        // Exibir uma mensagem de carregamento ou uma textura temporária
    }
}
```

Aqui, `texture_state` é um `Arc<Mutex<Option<Texture>>>` que permite que a thread principal e a tarefa assíncrona acessem o estado da textura de forma segura. O loop principal verifica se a textura já foi carregada e, caso contrário, pode exibir uma mensagem de carregamento ou uma textura temporária.

### Erro Comum: Deadlock

Um erro comum ao usar `Mutex` é causar um deadlock ao tentar adquirir o lock duas vezes na mesma thread. Por exemplo, se você tentar acessar `texture_state` dentro de uma função que já possui o lock, o programa travará.

```rust
let mut texture_guard = texture_state.lock().unwrap();
if let Some(texture) = texture_guard.as_ref() {
    renderer.draw_model_with_texture(&model, texture);
} else {
    // Tentar acessar texture_state novamente causará deadlock
    // let mut texture_guard = texture_state.lock().unwrap(); // Deadlock aqui
}
```

Para evitar isso, sempre libere o lock antes de tentar adquirir novamente, ou reorganize o código para evitar a necessidade de adquirir o lock múltiplas vezes.

### Exercício: Carregar Múltiplos Recursos

Como exercício, modifique o exemplo acima para carregar múltiplas texturas em background. Utilize um `HashMap<String, Arc<Mutex<Option<Texture>>>>` para armazenar o estado de cada textura e garantir que todas sejam carregadas antes de iniciar a renderização.

**Solução:**

```rust
use std::collections::HashMap;

let mut texture_map: HashMap<String, Arc<Mutex<Option<Texture>>>> = HashMap::new();
let paths = vec!["textures/texture1.png", "textures/texture2.png"];

for path in paths {
    let texture_state = Arc::new(Mutex::new(None));
    texture_map.insert(path.to_string(), Arc::clone(&texture_state));

    task::spawn(async move {
        let texture = load_texture_async(path).await.unwrap();
        *texture_state.lock().unwrap() = Some(texture);
    });
}

loop {
    let mut all_loaded = true;
    for (path, texture_state) in &texture_map {
        if texture_state.lock().unwrap().is_none() {
            all_loaded = false;
            break;
        }
    }

    if all_loaded {
        // Todas as texturas foram carregadas, iniciar renderização
        for (path, texture_state) in &texture_map {
            let texture = texture_state.lock().unwrap().as_ref().unwrap();
            renderer.draw_model_with_texture(&model, texture);
        }
    } else {
        // Exibir uma mensagem de carregamento ou uma textura temporária
    }
}
```

Nesta solução, `texture_map` armazena o estado de cada textura, e o loop principal verifica se todas as texturas foram carregadas antes de iniciar a renderização.