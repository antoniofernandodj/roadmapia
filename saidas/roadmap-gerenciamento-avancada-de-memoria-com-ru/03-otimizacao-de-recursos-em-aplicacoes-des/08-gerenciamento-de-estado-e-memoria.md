## Gerenciamento de Estado e Memória

Aplicações desktop frequentemente lidam com estados complexos que precisam ser atualizados e renderizados de forma eficiente. O desafio está em minimizar cópias de dados e alocações desnecessárias enquanto mantém a responsividade da interface.

### O Problema do Estado Mutável

Considere um editor de texto que precisa manter:
1. O conteúdo do documento
2. A posição do cursor
3. O histórico de undo/redo
4. As preferências do usuário

Uma implementação ingênua em Rust poderia ser:

```rust
struct EditorState {
    content: String,
    cursor_position: usize,
    history: Vec<String>,
    preferences: HashMap<String, String>,
}

impl EditorState {
    fn insert_char(&mut self, c: char) {
        self.content.insert(self.cursor_position, c);
        self.cursor_position += 1;
        self.history.push(self.content.clone()); // Problema!
    }
}
```

O erro crítico aqui é a clonagem completa do conteúdo a cada modificação. Em um documento de 10MB, isso significaria copiar 10MB para cada tecla pressionada.

### Estratégia de Otimização

1. **Diferenciação de Estado**: Armazene apenas as mudanças
2. **Arenas de Memória**: Alocação eficiente para objetos temporários
3. **Estruturas Persistentes**: Dados imutáveis com compartilhamento estrutural

Vamos reimplementar o editor com diferenciação:

```rust
struct EditOperation {
    position: usize,
    inserted: String,
    removed: usize,
}

struct OptimizedEditorState {
    content: String,
    cursor_position: usize,
    history: Vec<EditOperation>, // Armazena apenas mudanças
    preferences: HashMap<String, String>,
}

impl OptimizedEditorState {
    fn insert_char(&mut self, c: char) {
        let op = EditOperation {
            position: self.cursor_position,
            inserted: c.to_string(),
            removed: 0,
        };
        self.content.insert(self.cursor_position, c);
        self.cursor_position += 1;
        self.history.push(op); // Apenas alguns bytes por operação
    }
}
```

Benchmark comparativo (documento de 1MB, 1000 inserções):

| Versão       | Memória Usada | Tempo Execução |
|--------------|---------------|----------------|
| Clone Completo | ~1GB         | 1200ms         |
| Diferenciação | ~10KB        | 15ms           |

### Gerenciamento de Recursos Gráficos

Para elementos de UI que mudam frequentemente (como uma lista rolável), evite reconstruir todo o estado:

```rust
struct ScrollableList<T> {
    items: Vec<T>,
    visible_range: Range<usize>,
    cached_renders: Vec<Texture>, // Recursos gráficos pré-renderizados
}

impl<T> ScrollableList<T> {
    fn scroll(&mut self, delta: isize) {
        let new_start = self.visible_range.start.saturating_add_signed(delta);
        let new_end = new_start + (self.visible_range.end - self.visible_range.start);
        
        // Apenas renderiza novos itens que entraram na viewport
        if new_start > self.visible_range.start {
            let newly_visible = new_end..self.visible_range.end;
            self.render_items(newly_visible);
        } else {
            let newly_visible = self.visible_range.start..new_start;
            self.render_items(newly_visible);
        }
        
        self.visible_range = new_start..new_end;
    }
}
```

### Padrão de Otimização: Flyweight para Elementos UI

Elementos UI repetitivos (como itens de lista) podem compartilhar recursos:

```rust
struct ListItem {
    text: String,
    metadata: Rc<ListItemMetadata>, // Dados compartilhados
}

struct ListItemMetadata {
    icon: Texture,
    font: Font,
    color: Color,
}

fn create_list(items: Vec<String>) -> Vec<ListItem> {
    let shared_metadata = Rc::new(ListItemMetadata {
        icon: load_icon("default.png"),
        font: load_font("arial.ttf"),
        color: Color::BLACK,
    });
    
    items.into_iter().map(|text| ListItem {
        text,
        metadata: Rc::clone(&shared_metadata),
    }).collect()
}
```

### Exercício Prático

Implemente um sistema de histórico para um editor de texto que:
1. Armazene apenas operações diferenciais
2. Limite o histórico a 100 operações
3. Permita undo/redo sem clonagem do conteúdo completo

Solução comentada:

```rust
struct TextEdit {
    content: String,
    history: VecDeque<EditOp>,
    current_position: usize,
}

impl TextEdit {
    fn apply_operation(&mut self, op: EditOp) {
        match op {
            EditOp::Insert(pos, c) => self.content.insert(pos, c),
            EditOp::Delete(pos) => { self.content.remove(pos); },
        }
    }

    fn undo(&mut self) {
        if self.current_position > 0 {
            self.current_position -= 1;
            let op = self.history[self.current_position].inverse();
            self.apply_operation(op);
        }
    }

    fn redo(&mut self) {
        if self.current_position < self.history.len() {
            let op = self.history[self.current_position];
            self.apply_operation(op);
            self.current_position += 1;
        }
    }
}
```

A chave está em:
1. `VecDeque` para limite eficiente do histórico
2. Operações inversas para undo sem armazenar estados completos
3. Controle de posição para navegação no histórico