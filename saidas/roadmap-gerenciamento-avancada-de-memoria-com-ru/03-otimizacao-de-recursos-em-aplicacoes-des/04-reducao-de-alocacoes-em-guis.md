## Redução de Alocações em GUIs

Uma interface gráfica típica renderiza dezenas de elementos na tela 60 vezes por segundo. Cada botão, rótulo ou painel pode gerar alocações dinâmicas que, quando acumuladas, criam gargalos de desempenho visíveis. O problema se agrava quando esses elementos são recriados a cada frame em vez de reutilizados.

Considere este trecho de um editor de texto usando GTK-rs:

```rust
use gtk::prelude::*;
use gtk::{Button, Label, Window, WindowType};

fn build_ui() {
    let window = Window::new(WindowType::Toplevel);
    window.set_title("Editor de Texto");
    
    for _ in 0..100 {
        let label = Label::new(Some("Linha de texto"));
        window.add(&label);
    }
    
    let save_btn = Button::with_label("Salvar");
    window.add(&save_btn);
    
    window.show_all();
}

fn main() {
    gtk::init().unwrap();
    build_ui();
    gtk::main();
}
```

A cada chamada de `Label::new()` e `Button::with_label()`, ocorre uma alocação no heap. Para 100 labels, são 100 alocações separadas - um desperdício quando os textos são idênticos ou podem ser reutilizados.

### Técnica 1: Object Pooling para Widgets

Implemente um armazenamento reutilizável de widgets:

```rust
use std::cell::RefCell;
use std::collections::VecDeque;

struct WidgetPool<T> {
    widgets: RefCell<VecDeque<T>>,
    create_fn: Box<dyn Fn() -> T>,
}

impl<T> WidgetPool<T> {
    fn new(create_fn: impl Fn() -> T + 'static) -> Self {
        Self {
            widgets: RefCell::new(VecDeque::new()),
            create_fn: Box::new(create_fn),
        }
    }

    fn get(&self) -> T {
        self.widgets.borrow_mut().pop_front().unwrap_or_else(|| (self.create_fn)())
    }

    fn recycle(&self, widget: T) {
        self.widgets.borrow_mut().push_back(widget);
    }
}
```

Uso no editor de texto:

```rust
let label_pool = WidgetPool::new(|| Label::new(Some("Linha de texto")));

for _ in 0..100 {
    let label = label_pool.get();
    window.add(&label);
    // Armazena para reutilização posterior
    label_pool.recycle(label);
}
```

### Técnica 2: Renderização por Lotes

Ao invés de atualizar widgets individualmente, agrupe as mudanças:

```rust
use gtk::TextBuffer;

fn update_text(buffer: &TextBuffer, updates: &[(&str, &str)]) {
    buffer.begin_user_action();
    for (tag, text) in updates {
        let start = buffer.start_iter();
        let end = buffer.end_iter();
        buffer.apply_tag_by_name(tag, &start, &end);
        buffer.insert(&mut buffer.end_iter(), text);
    }
    buffer.end_user_action();
}
```

Isso reduz o número de operações de redesenho de O(n) para O(1).

### Erro Comum: Clone Desnecessário

Este código parece inofensivo mas esconde um problema:

```rust
fn create_toolbar(items: Vec<String>) -> gtk::Box {
    let toolbar = gtk::Box::new(gtk::Orientation::Horizontal, 0);
    for text in items {
        let btn = Button::with_label(&text.clone()); // Clone desnecessário!
        toolbar.add(&btn);
    }
    toolbar
}
```

A mensagem do compilador seria:
```
warning: unnecessary clone
  --> src/main.rs:10:39
   |
10 |         let btn = Button::with_label(&text.clone());
   |                                       ^^^^^^^^^^^^ help: remove this
```

A versão correta:

```rust
let btn = Button::with_label(&text);
```

### Técnica 3: Strings Estáticas

Para textos constantes, use `&'static str`:

```rust
const BUTTON_TEXTS: [&str; 3] = ["Novo", "Abrir", "Salvar"];

fn create_buttons() -> Vec<Button> {
    BUTTON_TEXTS.iter().map(|&t| Button::with_label(t)).collect()
}
```

Isso evita alocações de String completamente para textos conhecidos em tempo de compilação.

### Exercício Prático

Refatore este trecho de um visualizador de imagens para reduzir alocações:

```rust
fn load_images(paths: Vec<String>) -> Vec<gtk::Image> {
    paths.iter()
        .map(|p| {
            let pixbuf = gdk_pixbuf::Pixbuf::from_file(p).unwrap();
            gtk::Image::from_pixbuf(Some(&pixbuf))
        })
        .collect()
}
```

**Solução Comentada:**

```rust
fn load_images(paths: &[&str]) -> Vec<gtk::Image> {
    paths.iter()
        .map(|&p| {
            // Reutiliza o buffer se possível
            thread_local! {
                static BUF: RefCell<Vec<u8>> = RefCell::new(Vec::with_capacity(1_000_000));
            }
            
            let pixbuf = BUF.with(|b| {
                let mut buffer = b.borrow_mut();
                buffer.clear();
                let loader = gdk_pixbuf::PixbufLoader::new();
                // Carrega direto no buffer existente
                let file = std::fs::File::open(p).unwrap();
                std::io::copy(&mut std::io::BufReader::new(file), &mut buffer).unwrap();
                loader.write(&buffer).unwrap();
                loader.close().unwrap();
                loader.get_pixbuf().unwrap()
            });
            
            gtk::Image::from_pixbuf(Some(&pixbuf))
        })
        .collect()
}
```

As melhorias incluem:
1. Uso de `&str` em vez de `String` para paths
2. Buffer reutilizável thread-local
3. Operações de I/O direto no buffer existente
4. Remoção de alocações intermediárias

Esta versão reduz as alocações de O(n) para O(1) para buffers de imagem, crucial quando carregando centenas de thumbnails.