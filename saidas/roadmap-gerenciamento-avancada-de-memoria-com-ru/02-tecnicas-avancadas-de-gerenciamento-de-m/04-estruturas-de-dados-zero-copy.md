## Estruturas de Dados Zero-Copy

Quando trabalhamos com grandes volumes de dados ou sistemas de alto desempenho, cópias desnecessárias de memória tornam-se um gargalo crítico. Rust oferece ferramentas para criar estruturas que operam diretamente sobre os dados originais, sem cópias intermediárias - as chamadas estruturas zero-copy.

Considere um parser de arquivos JSON que precisa extrair campos específicos. A abordagem ingênua seria:

```rust
use serde_json::{Value, from_str};

fn extract_title(json_str: &str) -> Option<String> {
    let parsed: Value = from_str(json_str).unwrap();
    parsed["title"].as_str().map(|s| s.to_string())
}

let data = r#"{"title": "Zero-Copy Techniques", "year": 2023}"#;
println!("{:?}", extract_title(data)); // Some("Zero-Copy Techniques")
```

Este código aloca três vezes:
1. Para a estrutura `Value` completa
2. Para a string temporária retornada por `as_str()`
3. Para a cópia final no `to_string()`

A versão zero-copy utiliza referências diretamente nos dados originais:

```rust
use serde_json::{from_str, Value};

fn extract_title_zero_copy<'a>(json_str: &'a str) -> Option<&'a str> {
    let parsed: Value = from_str(json_str).unwrap();
    parsed["title"].as_str()
}

let data = r#"{"title": "Zero-Copy Techniques", "year": 2023}"#;
println!("{:?}", extract_title_zero_copy(data)); // Some("Zero-Copy Techniques")
```

A diferença crucial está no lifetime `'a` que conecta a saída (`&str`) aos dados de entrada. O compilador garante que a referência retornada não sobreviva aos dados originais:

```rust
let result;
{
    let temp_data = String::from(r#"{"title": "Temporary"}"#);
    result = extract_title_zero_copy(&temp_data);
} // temp_data é destruído aqui
// println!("{:?}", result); // ERRO: borrowed value doesn't live long enough
```

### Técnicas Avançadas Zero-Copy

1. **Fat Pointers com Slices**:
```rust
fn process_large_data(data: &[u8]) -> &[u8] {
    &data[10..20] // Retorna uma subview sem copiar
}

let big_data = vec![0u8; 1024];
let important_part = process_large_data(&big_data);
println!("Slice length: {}", important_part.len()); // 10
```

2. **Estruturas de Visualização (View Structs)**:
```rust
struct StringView<'a> {
    start: &'a str,
    end: &'a str,
}

impl<'a> StringView<'a> {
    fn new(full: &'a str, start: usize, end: usize) -> Self {
        Self {
            start: &full[start..],
            end: &full[end..],
        }
    }
}

let text = "The quick brown fox";
let view = StringView::new(text, 4, 10);
println!("{}..{}", view.start, view.end); // "quick..brown fox"
```

3. **Cow (Copy-on-Write) para Flexibilidade**:
```rust
use std::borrow::Cow;

fn process_input(input: &str) -> Cow<str> {
    if input.contains("special") {
        Cow::Owned(input.to_uppercase()) // Aloca só quando necessário
    } else {
        Cow::Borrowed(input) // Zero-copy no caso comum
    }
}

println!("{}", process_input("normal text")); // "normal text" (sem cópia)
println!("{}", process_input("special text")); // "SPECIAL TEXT" (com alocação)
```

### Erro Comum e Correção

Um erro frequente é tentar retornar referências a dados temporários:

```rust
fn broken_zero_copy() -> &str {
    let temp = String::from("temporary");
    &temp // ERRO: `temp` não vive o suficiente
}
```

A solução correta é either:
1. Retornar um tipo owned (`String`)
2. Aceitar um buffer de entrada como parâmetro:

```rust
fn working_zero_copy<'a>(buffer: &'a mut String) -> &'a str {
    buffer.clear();
    buffer.push_str("processed");
    &buffer[..]
}
```

### Exercício Prático

Implemente um parser de cabeçalhos HTTP zero-copy que extraia o valor do cabeçalho "Content-Type" sem alocações. A assinatura deve ser:

```rust
fn get_content_type(headers: &str) -> Option<&str>
```

Solução comentada:

```rust
fn get_content_type(headers: &str) -> Option<&str> {
    // Para cada linha no cabeçalho
    for line in headers.lines() {
        // Encontra o separador ':'
        if let Some(colon) = line.find(':') {
            let header_name = &line[..colon].trim();
            // Comparação case-insensitive básica
            if header_name.eq_ignore_ascii_case("content-type") {
                return Some(line[colon + 1..].trim());
            }
        }
    }
    None
}

let http_headers = "\
Host: example.com\r\n\
Content-Type: text/html\r\n\
Accept: */*\r\n";

assert_eq!(get_content_type(http_headers), Some("text/html"));
```

Esta solução:
1. Não faz nenhuma alocação
2. Usa apenas slices dos dados originais
3. Mantém a segurança de lifetimes do Rust
4. Lida com espaços em branco e formatação HTTP padrão