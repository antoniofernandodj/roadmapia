## Profiling em Aplicações Desktop

Um editor de texto Rust consome 300MB de RAM após carregar um arquivo de 50KB. Um cliente reporta lentidão ao digitar após 2 horas de uso. Como identificar o problema? Profiling responde.

### O Ciclo de Otimização

1. **Medir**: Coletar dados reais de desempenho
2. **Analisar**: Identificar gargalos específicos
3. **Otimizar**: Modificar o código com base em evidências
4. **Validar**: Verificar se a mudança trouxe benefício

Sem profiling, otimizações são chutes. Veja como implementar o ciclo:

### Ferramentas Essenciais

#### `perf` (Linux)
Para análise de CPU e cache:

```bash
perf record -g --call-graph=dwarf ./minha_app
perf report
```

Saída típica:
```
+   42.75%  minha_app  minha_app       [.] render_text
+   31.20%  minha_app  minha_app       [.] syntax_highlight
+   12.30%  minha_app  libc.so.6       [.] malloc
```

Isso mostra que 42% do tempo é gasto em renderização de texto.

#### `heaptrack` (Multiplataforma)
Para análise de alocações de memória:

```toml
[dependencies]
heaptrack = { version = "0.1", features = ["enable"] }
```

```rust
fn main() {
    heaptrack::start("minha_app.heaptrack");
    // Código da aplicação
}
```

Execute e analise com:
```bash
heaptrack -o minha_app ./minha_app
heaptrack_print minha_app.heaptrack.gz | less
```

Exemplo de vazamento detectado:
```
Alloc 1.2MB at 0x55f4e3a2b100
  in MyApp::load_config (src/app.rs:42)
  retained by ConfigCache (src/cache.rs:88)
```

### Caso Prático: Editor de Texto

Sintoma: Lentidão progressiva ao digitar.

1. **Configuração Inicial**:

```rust
#[derive(Default)]
struct EditorState {
    undo_stack: Vec<String>,  // Armazena estados completos do texto
    current_text: String,
}
```

Problema: Cada operação de undo salva uma cópia completa do texto.

2. **Análise com `heaptrack`**:
```
Peak memory: 1.8GB after 2h
Alloc 1.5MB per keypress (undo snapshot)
```

3. **Otimização**:
```rust
struct EditorState {
    undo_stack: Vec<TextDelta>,  // Armazena apenas diferenças
    current_text: String,
}

#[derive(Clone)]
enum TextDelta {
    Insert { pos: usize, text: String },
    Delete { pos: usize, len: usize },
}
```

4. **Validação**:
```
Peak memory: 120MB after 2h
Alloc 2KB per keypress
```

### Erro Comum: False Positives

Ao analisar um relatório de profiling:

```rust
fn process_events(&mut self) {
    let start = Instant::now();  // ⚠️ Medição ingênua
    self.ui.update();
    println!("Update took: {:?}", start.elapsed());
}
```

Problema: Overhead da medição distorce os resultados. Use ferramentas especializadas:

```bash
flamegraph -- ./minha_app
```

Gera visualização interativa de chamadas onerosas.

### Exercício Prático

**Problema**: Uma aplicação de desenho está com lentidão ao mover objetos complexos.

Dados do `perf`:
```
60% time in Canvas::render
25% time in Object::hit_test
```

Código atual:
```rust
impl Canvas {
    fn render(&self) {
        for obj in &self.objects {
            obj.draw();  // Desenha mesmo objetos fora da tela
        }
    }
}
```

**Solução**:
```rust
impl Canvas {
    fn render(&self, viewport: Rect) {
        for obj in &self.objects {
            if obj.bounds().intersects(viewport) {  // Culling espacial
                obj.draw();
            }
        }
    }
}
```

**Análise**:
1. `perf` mostra que 60% do tempo está em `render`
2. Inspeção revela desenho de objetos invisíveis
3. Adicionamos verificação de visibilidade (culling)
4. Nova análise mostra redução para 30% do tempo em `render`

Resultado: 2x melhoria no FPS em cenas complexas.