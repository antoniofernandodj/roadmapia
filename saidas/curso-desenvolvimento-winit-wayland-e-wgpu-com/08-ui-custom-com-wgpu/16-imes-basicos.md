## IMEs Básicos

Um usuário digitando em japonês ou chinês precisa de um Input Method Editor (IME) - um sistema que converte teclas pressionadas em caracteres complexos. Sem suporte adequado, sua aplicação Rust/WGPU mostrará apenas os keystrokes intermediários (como "k", "a", "n", "j" em vez de "漢字"). O Winit fornece a infraestrutura, mas implementar o fluxo completo exige entender três eventos-chave:

1. **IMEEnabled**: Quando o usuário ativa o IME (normalmente Ctrl+Space)
2. **Preedit**: Texto provisório durante a composição
3. **Commit**: Texto finalizado para inserção

Vamos criar um campo de texto básico com suporte mínimo para IMEs. Comece com a estrutura que armazenará o estado:

```rust
pub struct TextField {
    text: String,
    preedit: Option<(String, Vec<u32>)>, // (texto, intervalos de destaque)
    ime_active: bool,
    cursor_pos: usize,
}
```

O problema surge quando tentamos renderizar o texto sem distinguir entre conteúdo final e preedit. Veja o erro comum:

```rust
// ERRADO: mistura texto final e preedit diretamente
fn render_text(&self) -> String {
    if let Some((preedit, _)) = &self.preedit {
        format!("{}{}", self.text, preedit)
    } else {
        self.text.clone()
    }
}
```

Isso quebra quando o usuário tenta editar texto no meio do campo. A solução requer separação clara entre os estados:

```rust
fn render_text(&self) -> (String, Option<(String, usize)>) {
    let base = self.text.clone();
    if let Some((preedit, _)) = &self.preedit {
        let pos = self.cursor_pos.min(base.len());
        let mut with_preedit = base.clone();
        with_preedit.insert_str(pos, preedit);
        (base, Some((preedit.clone(), pos)))
    } else {
        (base, None)
    }
}
```

Agora, conectamos com os eventos do Winit. O tratamento básico envolve:

```rust
fn handle_ime_event(&mut self, event: &WindowEvent) {
    match event {
        WindowEvent::Ime(ime) => match ime {
            winit::event::Ime::Enabled => self.ime_active = true,
            winit::event::Ime::Disabled => {
                self.ime_active = false;
                self.preedit = None;
            }
            winit::event::Ime::Preedit(text, underlines) => {
                self.preedit = Some((text.clone(), underlines.clone()));
            }
            winit::event::Ime::Commit(text) => {
                let pos = self.cursor_pos.min(self.text.len());
                self.text.insert_str(pos, text);
                self.cursor_pos += text.len();
                self.preedit = None;
            }
        },
        _ => {}
    }
}
```

Para renderização visual, o preedit deve aparecer destacado. Este shader WGSL aplica um sublinhado ondulado:

```rust
// Inclua no seu pipeline de renderização de texto
[[stage(fragment)]]
fn fs_main(in: TextVertexOutput) -> [[location(0)]] vec4<f32> {
    let base_color = textureSample(texture_atlas, texture_sampler, in.uv);
    var color = base_color.rgba;
    
    // Se dentro da região de preedit (passado via uniform)
    if in.is_preedit > 0.5 {
        let wave = sin(in.pos.y * 0.1) * 0.5 + 0.5;
        color = mix(color, vec4(1.0, 1.0, 0.0, 1.0), wave * 0.3);
    }
    
    return color;
}
```

Erro comum ao implementar IMEs é esquecer de limpar o estado do preedit após o commit. O resultado é texto duplicado:

```
Input: 漢字 (via IME)
Saída incorreta: 漢漢字字
```

A correção está no tratamento do evento `Commit` mostrado acima, onde resetamos `self.preedit = None`.

**Exercício**: Implemente uma caixa de texto que mostra o preedit em vermelho e o texto commitado em preto. Inclua um cursor piscante na posição correta durante a edição.

**Solução comentada**:

```rust
pub struct TextField {
    text: String,
    preedit: Option<String>,
    cursor_pos: usize,
    cursor_visible: bool,
    cursor_timer: f32,
}

impl TextField {
    fn update(&mut self, delta_time: f32) {
        self.cursor_timer += delta_time;
        if self.cursor_timer >= 1.0 {
            self.cursor_timer = 0.0;
            self.cursor_visible = !self.cursor_visible;
        }
    }

    fn render(&self) -> Vec<TextSection> {
        let mut sections = Vec::new();
        
        // Texto antes do cursor
        if self.cursor_pos > 0 {
            sections.push(TextSection::new(
                &self.text[..self.cursor_pos],
                TextStyle::default(),
            ));
        }
        
        // Preedit ou cursor
        if let Some(preedit) = &self.preedit {
            sections.push(TextSection::new(
                preedit,
                TextStyle { color: Color::RED, ..Default::default() },
            ));
        } else if self.cursor_visible {
            sections.push(TextSection::new(
                "|",
                TextStyle::default(),
            ));
        }
        
        // Texto após o cursor
        if self.cursor_pos < self.text.len() {
            sections.push(TextSection::new(
                &self.text[self.cursor_pos..],
                TextStyle::default(),
            ));
        }
        
        sections
    }
}
```