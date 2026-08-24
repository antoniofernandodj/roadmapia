## Clipboard Básico

O clipboard é uma funcionalidade essencial para qualquer aplicação gráfica, permitindo que os usuários copiem e colem texto, imagens ou outros dados entre diferentes janelas e aplicativos. Em um compositor Wayland, implementar o clipboard envolve a criação de um mecanismo que gerencia a seleção de dados e a transferência desses dados entre clientes.

Vamos começar com um exemplo mínimo de como implementar o clipboard em um compositor Wayland. Para isso, precisamos entender dois conceitos principais: `wl_data_source` e `wl_data_offer`. O `wl_data_source` representa o lado que oferece os dados (quando algo é copiado), enquanto o `wl_data_offer` representa o lado que recebe os dados (quando algo é colado).

Primeiro, vamos configurar um `wl_data_source` para permitir que um cliente copie texto para o clipboard. Suponha que temos um cliente que deseja copiar o texto "Hello, Wayland!". A estrutura básica para isso seria:

```rust
use wayland_server::protocol::{wl_data_source, wl_data_offer, wl_seat};
use wayland_server::Resource;

struct Clipboard {
    data_source: Option<wl_data_source::WlDataSource>,
}

impl Clipboard {
    fn new() -> Self {
        Clipboard { data_source: None }
    }

    fn set_data_source(&mut self, source: wl_data_source::WlDataSource) {
        self.data_source = Some(source);
    }

    fn get_data_source(&self) -> Option<&wl_data_source::WlDataSource> {
        self.data_source.as_ref()
    }
}
```

Aqui, definimos uma estrutura `Clipboard` que mantém uma referência para o `wl_data_source`. Quando um cliente deseja copiar texto, ele cria um `wl_data_source` e o associa ao clipboard do compositor.

Agora, vamos lidar com o lado do cliente que deseja colar o texto. Quando um cliente solicita uma operação de colar, o compositor deve criar um `wl_data_offer` para oferecer os dados copiados:

```rust
impl Clipboard {
    fn create_data_offer(&self, seat: &wl_seat::WlSeat) -> wl_data_offer::WlDataOffer {
        let data_offer = seat.data_device().create_data_offer();
        if let Some(source) = &self.data_source {
            for mime_type in source.mime_types() {
                data_offer.offer(mime_type.to_string());
            }
        }
        data_offer
    }
}
```

Neste exemplo, o `wl_data_offer` é criado e preenchido com os tipos MIME que o `wl_data_source` suporta. O cliente pode então solicitar os dados específicos usando o tipo MIME apropriado.

Um erro comum ao implementar o clipboard é esquecer de liberar os recursos associados ao `wl_data_source` após a operação de cópia ser concluída. Isso pode levar a vazamentos de memória. Para evitar isso, devemos garantir que o `wl_data_source` seja liberado corretamente:

```rust
impl Clipboard {
    fn release_data_source(&mut self) {
        if let Some(source) = self.data_source.take() {
            source.release();
        }
    }
}
```

Finalmente, vamos integrar tudo isso em um exemplo completo:

```rust
fn main() {
    let mut clipboard = Clipboard::new();

    // Suponha que um cliente cria um wl_data_source para copiar texto
    let data_source = wl_data_source::WlDataSource::new();
    data_source.offer("text/plain".to_string());
    clipboard.set_data_source(data_source);

    // Outro cliente solicita uma operação de colar
    let seat = wl_seat::WlSeat::new();
    let data_offer = clipboard.create_data_offer(&seat);

    // O cliente seleciona o tipo MIME e recebe os dados
    if let Some(source) = clipboard.get_data_source() {
        let mime_type = "text/plain".to_string();
        let data = source.data(mime_type);
        println!("Dados colados: {}", data);
    }

    // Liberar recursos após a operação
    clipboard.release_data_source();
}
```

Neste exemplo, um cliente copia o texto "Hello, Wayland!" para o clipboard, e outro cliente cola esse texto. O código mostra como criar e gerenciar `wl_data_source` e `wl_data_offer` corretamente, além de garantir que os recursos sejam liberados após o uso.

**Exercício:** Modifique o exemplo acima para suportar múltiplos tipos MIME (por exemplo, texto e imagem) e permitir que o cliente escolha o tipo MIME desejado durante a operação de colar.

**Solução:**

```rust
impl Clipboard {
    fn create_data_offer(&self, seat: &wl_seat::WlSeat) -> wl_data_offer::WlDataOffer {
        let data_offer = seat.data_device().create_data_offer();
        if let Some(source) = &self.data_source {
            for mime_type in source.mime_types() {
                data_offer.offer(mime_type.to_string());
            }
        }
        data_offer
    }

    fn paste(&self, mime_type: String) -> Option<String> {
        self.data_source.as_ref().and_then(|source| source.data(mime_type))
    }
}

fn main() {
    let mut clipboard = Clipboard::new();

    // Suponha que um cliente cria um wl_data_source para copiar texto e imagem
    let data_source = wl_data_source::WlDataSource::new();
    data_source.offer("text/plain".to_string());
    data_source.offer("image/png".to_string());
    clipboard.set_data_source(data_source);

    // Outro cliente solicita uma operação de colar
    let seat = wl_seat::WlSeat::new();
    let data_offer = clipboard.create_data_offer(&seat);

    // O cliente seleciona o tipo MIME e recebe os dados
    let mime_type = "text/plain".to_string();
    if let Some(data) = clipboard.paste(mime_type) {
        println!("Dados colados: {}", data);
    }

    // Liberar recursos após a operação
    clipboard.release_data_source();
}
```

Nesta solução, o cliente pode escolher entre diferentes tipos MIME durante a operação de colar, e o compositor fornece os dados correspondentes.