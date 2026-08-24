## Clipboard

Um editor de texto sem suporte a copiar e colar é como uma tesoura sem corte. O desafio começa quando você precisa integrar o clipboard do sistema operacional com sua aplicação Rust, especialmente quando rodando sobre Wayland - onde o protocolo exige tratamento assíncrono e negociação de formatos.

O Winit fornece uma abstração básica através do módulo `window::Clipboard`, mas ela esconde complexidades cruciais. Vejamos como implementar um sistema completo:

```rust
use winit::window::Window;
use winit::event_loop::EventLoop;
use clipboard::{ClipboardContext, ClipboardProvider};

struct EditorClipboard {
    system: ClipboardContext,
    internal: String, // Para operações internas antes da confirmação
}

impl EditorClipboard {
    pub fn new() -> Self {
        Self {
            system: ClipboardProvider::new().unwrap(),
            internal: String::new(),
        }
    }

    pub fn copy(&mut self, text: &str) {
        self.internal = text.to_string();
        if let Err(e) = self.system.set_contents(text.to_string()) {
            eprintln!("Falha ao acessar clipboard do sistema: {}", e);
        }
    }

    pub fn paste(&mut self) -> String {
        match self.system.get_contents() {
            Ok(contents) => contents,
            Err(e) => {
                eprintln!("Falha ao ler clipboard do sistema: {}", e);
                self.internal.clone() // Fallback para clipboard interno
            }
        }
    }
}
```

O erro mais comum é tentar acessar o clipboard fora da thread principal. Isso causa falhas imediatas no macOS e comportamentos imprevisíveis no Wayland. Veja o que acontece quando cometemos esse erro:

```rust
// ERRO: Acesso em thread secundária
std::thread::spawn(|| {
    let mut clipboard = ClipboardProvider::new().unwrap();
    clipboard.set_contents("texto".to_string()).unwrap();
});
```

A mensagem de erro no macOS é clara:
```
Thread '<unnamed>' panicked at 'clipboard must be accessed from the main thread'
```

A solução envolve enviar operações de clipboard para a thread principal através de canais. Aqui está a implementação correta:

```rust
use std::sync::mpsc;

enum ClipboardOp {
    Copy(String),
    Paste(mpsc::Sender<String>),
}

fn setup_clipboard_handler(event_loop: &EventLoop<()>) -> mpsc::Sender<ClipboardOp> {
    let (tx, rx) = mpsc::channel();
    
    let proxy = event_loop.create_proxy();
    std::thread::spawn(move || {
        let mut clipboard = EditorClipboard::new();
        
        for op in rx {
            let proxy = proxy.clone();
            match op {
                ClipboardOp::Copy(text) => {
                    proxy.send_event(()).unwrap();
                    clipboard.copy(&text);
                },
                ClipboardOp::Paste(tx_result) => {
                    proxy.send_event(()).unwrap();
                    let contents = clipboard.paste();
                    tx_result.send(contents).unwrap();
                }
            }
        }
    });
    
    tx
}
```

No Wayland, o protocolo exige que negociemos formatos suportados. O Winit abstrai isso, mas para maior controle, podemos implementar diretamente:

```rust
use wayland_client::protocol::wl_data_device_manager::WlDataDeviceManager;

fn setup_wayland_clipboard(
    seat: &wayland_client::protocol::wl_seat::WlSeat,
    data_device_manager: &WlDataDeviceManager
) {
    let data_device = data_device_manager.get_data_device(seat);
    
    data_device.quick_assign(|data_device, event, _| {
        match event {
            wayland_client::protocol::wl_data_device::Event::DataOffer { id } => {
                // Novo conteúdo oferecido ao clipboard
                let offer = id;
                offer.accept(
                    Some("text/plain"),
                    Some("text/plain;charset=utf-8")
                );
            },
            _ => {}
        }
    });
}
```

Para testar nosso sistema, vamos criar um exemplo completo com Winit:

```rust
use winit::event::{Event, WindowEvent};
use winit::event_loop::ControlFlow;

fn main() {
    let event_loop = EventLoop::new();
    let window = Window::new(&event_loop).unwrap();
    let clipboard_tx = setup_clipboard_handler(&event_loop);
    
    // Simula copiar
    clipboard_tx.send(ClipboardOp::Copy("Hello Clipboard".to_string())).unwrap();
    
    // Simula colar
    let (paste_tx, paste_rx) = mpsc::channel();
    clipboard_tx.send(ClipboardOp::Paste(paste_tx)).unwrap();
    let contents = paste_rx.recv().unwrap();
    println!("Pasted: {}", contents);

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;
        
        match event {
            Event::WindowEvent { event: WindowEvent::CloseRequested, .. } => {
                *control_flow = ControlFlow::Exit;
            },
            _ => {}
        }
    });
}
```

A saída esperada:
```
Pasted: Hello Clipboard
```

**Exercício**: Implemente um clipboard interno que armazene os últimos 5 itens copiados, com um método `paste_previous(index)` para acessar o histórico. Mantenha a compatibilidade com o clipboard do sistema.

**Solução**:

```rust
struct HistoryClipboard {
    system: ClipboardContext,
    history: Vec<String>,
}

impl HistoryClipboard {
    const MAX_HISTORY: usize = 5;

    pub fn paste_previous(&self, index: usize) -> Option<String> {
        if index < self.history.len() {
            Some(self.history[index].clone())
        } else {
            None
        }
    }

    pub fn copy(&mut self, text: String) {
        if self.history.len() == Self::MAX_HISTORY {
            self.history.pop();
        }
        self.history.insert(0, text.clone());
        self.system.set_contents(text).unwrap();
    }
}
```