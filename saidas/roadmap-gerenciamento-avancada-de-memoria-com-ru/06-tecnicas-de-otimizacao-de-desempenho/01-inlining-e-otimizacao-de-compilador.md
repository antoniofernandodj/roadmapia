## Inlining e Otimização de Compilador

Considere esta função simples que calcula o quadrado de um número:

```rust
fn square(x: i32) -> i32 {
    x * x
}

fn main() {
    let result = square(5);
    println!("Resultado: {}", result);
}
```

Quando compilado sem otimizações, o código gerado contém uma chamada real à função `square`. Isso significa:

1. O programa empurra o valor 5 para a pilha
2. Salva o endereço de retorno
3. Transfere execução para `square`
4. Calcula o resultado
5. Retorna ao chamador
6. Recupera o valor

Tudo isso para uma operação que poderia ser simplesmente `5 * 5`. O overhead é significativo quando essa função é chamada milhões de vezes.

### O Poder do Inlining

O compilador Rust (via LLVM) aplica automaticamente **inlining**, que substitui a chamada de função pelo seu corpo:

```rust
// O que realmente é executado após inlining:
fn main() {
    let result = 5 * 5;  // Chamada substituída pelo corpo da função
    println!("Resultado: {}", result);
}
```

Para forçar o inlining (ou desativá-lo), usamos atributos:

```rust
#[inline(always)]  // Força inlining mesmo em builds de debug
fn square(x: i32) -> i32 {
    x * x
}

#[inline(never)]   // Nunca aplica inlining
fn debug_log(msg: &str) {
    eprintln!("[DEBUG] {}", msg);
}
```

### Quando o Inlining Ajuda (e Quando Atrasa)

**Cenário ideal:**
```rust
#[inline]
fn calculate_distance(x1: f64, y1: f64, x2: f64, y2: f64) -> f64 {
    ((x2 - x1).powi(2) + (y2 - y1).powi(2)).sqrt()
}
```
- Funções pequenas (1-3 operações)
- Chamadas frequentes em loops críticos
- Sem efeitos colaterais complexos

**Cenário problemático:**
```rust
#[inline]  // Má ideia!
fn process_large_data(data: &[u8]) -> Vec<u8> {
    // 50 linhas de processamento complexo
    // Alocações temporárias múltiplas
    // Chamadas a outras funções
    todo!()
}
```
- Código grande aumenta o tamanho do binário
- Pode estourar o cache de instruções
- Piora a localidade de referência

### Impacto na Memória

O inlining afeta a memória de duas formas principais:

1. **Pilha de Execução:**
```rust
fn a() {
    let x = b();  // Sem inlining: frame de b() na pilha
    c(x);
}

#[inline]
fn b() -> i32 { 5 }  // Com inlining: valor direto na pilha de a()
```

2. **Alocação Temporária:**
```rust
fn process() -> String {
    format_data(generate_data())  // String intermediária pode ser eliminada
}

#[inline]
fn generate_data() -> String {
    String::from("dados")
}

#[inline]
fn format_data(data: String) -> String {
    format!("Processado: {}", data)
}
// Com inlining agressivo, o compilador pode transformar em:
// -> format!("Processado: {}", String::from("dados"))
// -> E depois otimizar para uma única alocação
```

### Verificando as Otimizações

Use o Compiler Explorer (https://godbolt.org/) com estas flags:
```bash
rustc -O --emit=asm --crate-type=lib -C "llvm-args=-print-after-all" 2>&1 | less
```

Ou no Cargo.toml:
```toml
[profile.release]
lto = true          # Otimização entre crates
codegen-units = 1   # Máxima otimização
opt-level = 3       # Otimização agressiva
```

### Caso Real: Iteradores vs Loops

Sem inlining:
```rust
let sum: u32 = (1..1000).filter(|x| x % 2 == 0).sum();
```
- Cada passo (filter, sum) é uma chamada separada
- Múltiplos passes pelos dados

Com inlining agressivo:
- O compilador transforma em um loop equivalente:
```rust
let mut sum = 0;
for x in 1..1000 {
    if x % 2 == 0 {
        sum += x;
    }
}
```

### Exercício Prático

Analise este código que calcula estatísticas básicas:

```rust
fn mean(data: &[f64]) -> f64 {
    data.iter().sum::<f64>() / data.len() as f64
}

fn variance(data: &[f64]) -> f64 {
    let m = mean(data);
    data.iter().map(|x| (x - m).powi(2)).sum::<f64>() / data.len() as f64
}

fn main() {
    let data = vec![1.0, 2.0, 3.0, 4.0, 5.0];
    println!("Variância: {}", variance(&data));
}
```

**Tarefa:**
1. Identifique onde o inlining seria benéfico
2. Adicione os atributos `#[inline]` apropriados
3. Use `cargo inspect --what-does-this-do` para ver o efeito

**Solução comentada:**

```rust
#[inline]  // Chamado múltiplas vezes no cálculo
fn mean(data: &[f64]) -> f64 {
    data.iter().sum::<f64>() / data.len() as f64
}

#[inline]  // Função pequena e crítica
fn variance(data: &[f64]) -> f64 {
    let m = mean(data);
    data.iter().map(|x| (x - m).powi(2)).sum::<f64>() / data.len() as f64
}
// O compilador agora pode:
// 1. Inlinear mean dentro de variance
// 2. Combinar as operações de iteração
// 3. Eliminar cálculos redundantes
```

Para ver o efeito real, compare o assembly gerado com e sem as dicas de inlining usando:
```bash
cargo rustc --release -- --emit asm -C "llvm-args=-print-after-all"
```