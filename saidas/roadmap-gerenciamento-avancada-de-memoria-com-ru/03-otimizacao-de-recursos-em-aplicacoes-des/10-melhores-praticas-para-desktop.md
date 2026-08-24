## Melhores Práticas para Desktop

Aplicações desktop enfrentam desafios únicos de desempenho: interação responsiva com o usuário, renderização gráfica eficiente e gerenciamento de estado complexo. Rust oferece ferramentas poderosas para esses cenários, mas requer padrões específicos para extrair o máximo desempenho sem sacrificar segurança.

### Minimizando Cópias em Operações de UI

Em interfaces gráficas, operações como redimensionamento de janelas ou atualização de listas frequentemente envolvem manipulação de buffers de pixels ou coleções de dados. Considere este exemplo comum (porém ineficiente) de atualização de uma lista:

```rust
struct Item {
    id: u64,
    label: String,
}

fn update_list(items: Vec<Item>, new_item: Item) -> Vec<Item> {
    let mut new_items = items.clone(); // Cópia desnecessária
    new_items.push(new_item);
    new_items
}
```

Este padrão aloca uma nova Vec e copia todos os elementos sempre que um item é adicionado. Em vez disso, trabalhe com referências mutáveis quando possível:

```rust
fn update_list_efficient(items: &mut Vec<Item>, new_item: Item) {
    items.push(new_item);
}
```

Para cenários onde ownership é necessário, considere `Rc<RefCell<T>>` ou `Arc<Mutex<T>>` para compartilhamento controlado:

```rust
use std::rc::Rc;
use std::cell::RefCell;

struct SharedItem {
    id: u64,
    label: Rc<str>, // String imutável compartilhada
}

fn update_shared_list(
    items: &Rc<RefCell<Vec<SharedItem>>>,
    new_item: SharedItem
) {
    items.borrow_mut().push(new_item);
}
```

### Gerenciamento Eficiente de Recursos Gráficos

Texturas, buffers e outros recursos gráficos devem ser reaproveitados. Um pool de recursos evita alocações frequentes:

```rust
struct TexturePool {
    textures: Vec<Option<Texture>>,
    free_indices: Vec<usize>,
}

impl TexturePool {
    fn allocate(&mut self) -> Option<(usize, &mut Texture)> {
        if let Some(idx) = self.free_indices.pop() {
            if let Some(Some(texture)) = self.textures.get_mut(idx) {
                return Some((idx, texture));
            }
        }
        None
    }

    fn deallocate(&mut self, idx: usize) {
        self.free_indices.push(idx);
    }
}
```

### Padrão de Estado Imutável para Interfaces Reativas

Aplicações desktop frequentemente implementam o padrão Model-View-Controller. Em Rust, podemos otimizá-lo:

```rust
struct AppState {
    items: Rc<[String]>,
    selected_index: usize,
}

enum Message {
    ItemSelected(usize),
    ItemsLoaded(Rc<[String]>),
}

fn update(state: &mut AppState, message: Message) {
    match message {
        Message::ItemSelected(idx) => {
            state.selected_index = idx;
        }
        Message::ItemsLoaded(new_items) => {
            state.items = new_items; // Compartilhamento sem cópia
        }
    }
}
```

### Cache de Layout para Redução de Cálculos

Recalcular layouts é custoso. Implemente cache com invalidação seletiva:

```rust
struct CachedLayout {
    cache: Option<(Rect, f32, f32)>,
    last_size: (f32, f32),
}

impl CachedLayout {
    fn calculate(&mut self, available: (f32, f32)) -> Rect {
        if self.last_size != available || self.cache.is_none() {
            let rect = compute_expensive_layout(available);
            self.cache = Some((rect, available.0, available.1));
            self.last_size = available;
            rect
        } else {
            self.cache.unwrap().0
        }
    }
}
```

### Exercício Prático: Otimizando uma Lista Virtual

Implemente uma lista virtual que renderiza apenas os itens visíveis, com reciclagem de elementos de UI:

```rust
struct VirtualList {
    item_height: f32,
    scroll_position: f32,
    visible_range: Range<usize>,
    recycled_views: Vec<Box<dyn View>>,
    all_items: Rc<[String]>,
}

impl VirtualList {
    fn update_visible_items(&mut self, container_height: f32) {
        let first_visible = (self.scroll_position / self.item_height).floor() as usize;
        let count_visible = (container_height / self.item_height).ceil() as usize + 1;
        
        self.visible_range = first_visible..(first_visible + count_visible).min(self.all_items.len());
    }
    
    fn get_view(&mut self, idx: usize) -> Box<dyn View> {
        if !self.visible_range.contains(&idx) {
            return Box::new(EmptyView);
        }
        
        self.recycled_views.pop()
            .map(|mut view| {
                view.update(&self.all_items[idx]);
                view
            })
            .unwrap_or_else(|| Box::new(ItemView::new(&self.all_items[idx])))
    }
}
```

**Solução comentada:**
1. `visible_range` calcula quais itens estão efetivamente visíveis
2. `recycled_views` armazena views não visíveis para reutilização
3. `get_view` recicla views ou cria novas somente quando necessário
4. `Rc<[String]>` compartilha os dados entre todas as views sem cópia

Esta implementação reduz alocações de memória e criação de objetos ao mínimo necessário, mantendo a interface responsiva mesmo com milhares de itens.