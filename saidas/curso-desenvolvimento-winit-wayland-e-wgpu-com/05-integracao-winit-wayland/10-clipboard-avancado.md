## Clipboard Avançado

Em aplicações gráficas modernas, o clipboard vai além do simples copiar/colar texto. Vamos implementar um sistema que:
1. Suporta múltiplos formatos (texto, HTML, imagens)
2. Gerencia ownership corretamente no Wayland
3. Lida com negociação de formatos entre aplicações

O problema central aparece quando tentamos colar em um editor que espera HTML enquanto outra aplicação só oferece texto simples:

```rust
// Tentativa ingênua - falha na negociação de formatos
let clipboard = Clipboard::new(&connection);
clipboard.set_contents("Texto <b>negrito</b>"); // Apenas texto
```

O erro típico é:
```
Error: Requested format text/html but only text/plain available
```

### Implementação Completa

Primeiro, configure o clipboard no Wayland:

```rust
use wayland_client::protocol::{wl_seat, wl_data_device_manager};
use winit::platform::wayland::EventLoopWindowTargetExtWayland;

let event_loop = EventLoop::new_wayland().unwrap();
let seat = event_loop.wayland_seat().expect("No Wayland seat");
let ddm = event_loop.wayland_data_device_manager()
    .expect("Data device manager not available");

let clipboard = ddm.get_data_device(&seat).create_clipboard();
```

Para suportar múltiplos formatos, implementamos uma seleção:

```rust
use mime::Mime;

struct ClipboardData {
    plain_text: String,
    html: Option<String>,
    image: Option<Vec<u8>>,
}

impl ClipboardData {
    fn offer(&self, mime: &Mime) -> Option<Vec<u8>> {
        match (mime.type_(), mime.subtype()) {
            ("text", "plain") => Some(self.plain_text.as_bytes().to_vec()),
            ("text", "html") => self.html.as_ref().map(|h| h.as_bytes().to_vec()),
            ("image", "png") => self.image.clone(),
            _ => None,
        }
    }
}
```

Exemplo de uso completo:

```rust
let data = ClipboardData {
    plain_text: "Texto simples".to_string(),
    html: Some("<b>Texto</b> formatado".to_string()),
    image: Some(vec![255, 0, 0, 255]), // Pixel vermelho RGBA
};

clipboard.offer(mime::TEXT_PLAIN_UTF_8, |mime| data.offer(&mime));
clipboard.offer(mime::TEXT_HTML, |mime| data.offer(&mime));
clipboard.offer(mime::IMAGE_PNG, |mime| data.offer(&mime));
```

### Tratamento de Erros Comuns

1. **Formato não suportado**:
```rust
// Corrigindo com fallback
let best_format = clipboard.available_formats()
    .find(|m| m == &mime::TEXT_HTML)
    .or_else(|| clipboard.available_formats().find(|m| m == &mime::TEXT_PLAIN))
    .expect("No supported format");
```

2. **Race condition na leitura**:
```rust
// Uso seguro com timeout
let content = clipboard.load(best_format)
    .timeout(Duration::from_millis(500))
    .await
    .unwrap_or_default();
```

### Exercício Prático

Implemente um clipboard que:
1. Aceite texto e HTML simultaneamente
2. Converta Markdown para HTML quando necessário
3. Forneça fallback automático para texto simples

Solução comentada:

```rust
struct SmartClipboard {
    markdown: String,
}

impl SmartClipboard {
    fn offer(&self, mime: &Mime) -> Option<Vec<u8>> {
        match (mime.type_(), mime.subtype()) {
            ("text", "plain") => Some(self.markdown.as_bytes().to_vec()),
            ("text", "html") => {
                let html = markdown::to_html(&self.markdown);
                Some(html.as_bytes().to_vec())
            },
            _ => None,
        }
    }
}

// Uso:
let clipboard = SmartClipboard { markdown: "**Texto** em markdown".into() };
clipboard.offer_all(); // Registra ambos os formatos
```