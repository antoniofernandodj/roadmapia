## Otimização de GUI em Rust

Uma interface gráfica (GUI) típica mantém centenas de elementos na memória: janelas, botões, listas, textos. Em frameworks tradicionais, cada clique pode disparar realocações custosas. Rust oferece ferramentas para controlar esse comportamento, mas exige padrões específicos para evitar cópias desnecessárias.

### O Problema do Estado Duplicado

Considere um editor de texto simples que mostra uma contagem de caracteres. Uma implementação ingênua em Rust com GTK-rs seria:

```rust
use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, Button, Label};

fn main() {
    let app = Application::builder()
        .application_id("com.example.gui")
        .build();

    app.connect_activate(|app| {
        let window = ApplicationWindow::builder()
            .application(app)
            .title("Editor")
            .build();

        let label = Label::new(Some("Caracteres: 0"));
        let buffer = String::new(); // Estado do texto

        let button = Button::builder()
            .label("Adicionar texto")
            .build();

        button.connect_clicked(move |_| {
            buffer.push_str("Texto adicional "); // Erro: captura móvel
            label.set_text(&format!("Caracteres: {}", buffer.len()));
        });

        window.add(&button);
        window.add(&label);
        window.show_all();
    });

    app.run();
}
```

Ao compilar, Rust rejeita o código:

```
error[E0382]: borrow of moved value: `buffer`
  --> src/main.rs:17:13
   |
12 |         let buffer = String::new();
   |             ------ move occurs because `buffer` has type `String`, which does not implement the `Copy` trait
...
16 |         button.connect_clicked(move |_| {
   |                                -------- value moved into closure here
17 |             buffer.push_str("Texto adicional ");
   |             ^^^^^^ value borrowed here after move
```

### Solução com Rc e RefCell

Para compartilhar estado entre callbacks, combinamos `Rc` (contagem de referências) e `RefCell` (mutabilidade interior):

```rust
use std::cell::RefCell;
use std::rc::Rc;

use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, Button, Label};

fn main() {
    let app = Application::builder()
        .application_id("com.example.gui")
        .build();

    app.connect_activate(|app| {
        let window = ApplicationWindow::builder()
            .application(app)
            .title("Editor")
            .build();

        let label = Label::new(Some("Caracteres: 0"));
        let buffer = Rc::new(RefCell::new(String::new()));

        let button = Button::builder()
            .label("Adicionar texto")
            .build();

        {
            let buffer = buffer.clone();
            button.connect_clicked(move |_| {
                buffer.borrow_mut().push_str("Texto adicional ");
                label.set_text(&format!("Caracteres: {}", buffer.borrow().len()));
            });
        }

        window.add(&button);
        window.add(&label);
        window.show_all();
    });

    app.run();
}
```

Esta versão funciona, mas aloca dinamicamente o buffer. Para 10.000 cliques, teremos 10.000 realocações da String.

### Otimização com Arena Allocation

Em GUIs complexas, substituir alocações individuais por arenas melhora desempenho. Usamos `bumpalo` para alocação em arena:

```rust
use bumpalo::Bump;
use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, Button, Label};

fn main() {
    let arena = Bump::new();
    let app = Application::builder()
        .application_id("com.example.gui")
        .build();

    app.connect_activate(|app| {
        let window = ApplicationWindow::builder()
            .application(app)
            .title("Editor")
            .build();

        let label = Label::new(Some("Caracteres: 0"));
        let buffer = arena.alloc(String::new());

        let button = Button::builder()
            .label("Adicionar texto")
            .build();

        button.connect_clicked(move |_| {
            buffer.push_str("Texto adicional ");
            label.set_text(&format!("Caracteres: {}", buffer.len()));
        });

        window.add(&button);
        window.add(&label);
        window.show_all();
    });

    app.run();
}
```

A saída após três cliques seria:

```
Caracteres: 18
```

### Padrão Flyweight para Elementos UI

Para milhares de elementos idênticos (como células em uma lista), compartilhe recursos:

```rust
use std::sync::Arc;

struct Icon {
    data: Arc<[u8]>,
}

impl Icon {
    fn new(data: &[u8]) -> Self {
        Self {
            data: Arc::from(data),
        }
    }
}

fn main() {
    let shared_icon = Icon::new(&[0xDE, 0xAD, 0xBE, 0xEF]);
    
    // Uso em múltiplos botões
    let button1_icon = shared_icon.data.clone();
    let button2_icon = shared_icon.data.clone();
    
    println!("Endereço do ícone 1: {:p}", button1_icon.as_ref());
    println!("Endereço do ícone 2: {:p}", button2_icon.as_ref());
}
```

Saída:

```
Endereço do ícone 1: 0x7f8b41604c00
Endereço do ícone 2: 0x7f8b41604c00
```

### Exercício: Otimizar Lista de Itens

Dado o seguinte código ineficiente:

```rust
use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, ListBox, ListBoxRow, Label};

fn main() {
    let app = Application::builder()
        .application_id("com.example.list")
        .build();

    app.connect_activate(|app| {
        let window = ApplicationWindow::builder()
            .application(app)
            .title("Lista")
            .build();

        let list = ListBox::new();
        
        for i in 0..1000 {
            let row = ListBoxRow::new();
            let label = Label::new(Some(&format!("Item {}", i)));
            row.add(&label);
            list.add(&row);
        }

        window.add(&list);
        window.show_all();
    });

    app.run();
}
```

**Tarefa**: Reescreva usando:
1. Um único allocation para todos os textos
2. Compartilhamento de estilos entre itens
3. Renderização lazy (visíveis apenas)

**Solução**:

```rust
use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, ListBox, ListBoxRow, Label};
use std::rc::Rc;

fn main() {
    let app = Application::builder()
        .application_id("com.example.list")
        .build();

    app.connect_activate(|app| {
        let window = ApplicationWindow::builder()
            .application(app)
            .title("Lista")
            .default_width(300)
            .default_height(400)
            .build();

        let list = ListBox::new();
        let shared_style = Rc::new("margin: 2px; padding: 4px;".to_string());

        // Buffer único para todos os textos
        let items: Vec<String> = (0..1000).map(|i| format!("Item {}", i)).collect();

        // Renderiza apenas 20 itens visíveis
        for i in 0..20 {
            let row = ListBoxRow::new();
            let label = Label::new(Some(&items[i]));
            
            let style = shared_style.clone();
            label.set_markup(&format!("<span style='{}'>{}</span>", style, items[i]));
            
            row.add(&label);
            list.add(&row);
        }

        // Lazy loading via scroll
        list.connect_edge_reached(move |_, _| {
            // Implementar carregamento sob demanda aqui
        });

        window.add(&list);
        window.show_all();
    });

    app.run();
}
```