## Input Handling

O problema central de qualquer aplicação gráfica é responder corretamente aos eventos de entrada do usuário — teclado, mouse e toque — sem perder sincronia com a renderização. Em Rust, isso exige um gerenciamento cuidadoso de estados compartilhados entre threads, especialmente quando lidamos com eventos assíncronos do Wayland.

Começamos estruturando o gerenciamento de input em três camadas:

1. **Dispositivos físicos** (teclado/mouse)
2. **Janela ativa** (foco)
3. **Elementos de UI** (widgets)

Para coordenar essas camadas, usamos um `Arc<Mutex<InputState>>` compartilhado entre threads de renderização e lógica:

```rust
struct InputState {
    keyboard: HashMap<Key, Action>,
    mouse: (f64, f64),
    focused: Option<WindowId>,
    ui_elements: Vec<Arc<Mutex<UIElement>>>,
}

impl InputState {
    fn handle_key(&mut self, key: Key, action: Action) {
        if let Some(window) = self.focused {
            if let Some(element) = self.find_ui_element(window) {
                element.lock().unwrap().handle_key(key, action);
            }
        }
    }
}
```

O erro mais comum aqui é esquecer de sincronizar os eventos de input com a renderização atual, causando travamentos ou inputs perdidos. A solução é usar um `Condvar` para sincronizar as atualizações:

```rust
let (input_tx, input_rx) = mpsc::channel();
let condvar = Arc::new(Condvar::new());

thread::spawn(move || {
    let input = input_rx.recv().unwrap();
    let mut state = condvar.wait(input).unwrap();
    state.handle_key(key, action);
});
```

Para testar esse sistema, criamos um mock de input que simula eventos de teclado e mouse:

```rust
#[test]
fn test_input_handling() {
    let state = Arc::new(Mutex::new(InputState::new()));
    let (input_tx, input_rx) = mpsc::channel();
    let condvar = Arc::new(Condvar::new());

    let mock_input = thread::spawn(move || {
        let input = input_rx.recv().unwrap();
        let mut state = condvar.wait(input).unwrap();
        state.handle_key(Key::A, Action::Press);
    });

    input_tx.send(state.clone()).unwrap();
    mock_input.join().unwrap();

    assert!(state.lock().unwrap().keyboard.contains_key(&Key::A));
}
```

O resultado final é um sistema de input que:

1. Trata eventos de teclado e mouse de forma sincronizada
2. Mantém o estado compartilhado entre threads
3. Responde corretamente a eventos assíncronos do Wayland