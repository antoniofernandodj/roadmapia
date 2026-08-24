## Introdução a Profiling em Rust

Um programa Rust pode estar correto, mas lento. O problema não está no que ele faz, mas em como faz. Considere esta função que processa um vetor de números:

```rust
fn processa_dados(dados: &[i32]) -> Vec<i32> {
    let mut resultado = Vec::new();
    for &numero in dados {
        if numero % 2 == 0 {
            resultado.push(numero * 2);
        } else {
            resultado.push(numero * 3);
        }
    }
    resultado
}

fn main() {
    let dados = (0..10000).collect::<Vec<_>>();
    let _ = processa_dados(&dados);
}
```

Aparentemente inofensiva, mas e se dissermos que em um caso real ela está consumindo 150ms quando deveria levar 15ms? Como descobrir onde está o problema?

**Profiling** é a técnica de medir onde um programa gasta tempo e recursos. Em Rust, isso é crucial porque:

1. O sistema de ownership evita vazamentos, mas não otimiza automaticamente
2. Alocações desnecessárias podem passar despercebidas
3. Operações O(n²) podem estar escondidas em código aparentemente simples

Vamos instrumentar nosso exemplo para encontrar gargalos. Primeiro, adicione ao Cargo.toml:

```toml
[profile.release]
debug = true  # Mantém símbolos de debug para profiling
```

Agora, execute com o perf (Linux):

```bash
perf record --call-graph dwarf cargo run --release
perf report
```

Você verá algo como:

```
+   95.23%  processa_dados
     - 87.15% Vec::push
        - 62.33% alloc::raw_vec::RawVec::reserve
           + 58.91% __realloc
        + 24.82% core::ptr::write
     + 8.08% main
```

O relatório mostra que 95% do tempo está em `processa_dados`, sendo 87% só em `Vec::push`. Por quê? Cada `push` pode realocar o vetor. A solução é pré-alocar:

```rust
fn processa_dados_otimizado(dados: &[i32]) -> Vec<i32> {
    let mut resultado = Vec::with_capacity(dados.len());  // Pré-alocação
    for &numero in dados {
        resultado.push(if numero % 2 == 0 {
            numero * 2
        } else {
            numero * 3
        });
    }
    resultado
}
```

Com esta mudança, o tempo cai para ~20ms. O profiling nos mostrou:

1. **Onde** o tempo estava sendo gasto (alocações)
2. **Por quê** (realocações frequentes)
3. **Como** corrigir (pré-alocação)

### Erro Comum: Ignorar o Custo de Traits

Considere este código que usa trait objects:

```rust
trait Processavel {
    fn processa(&self) -> i32;
}

impl Processavel for i32 {
    fn processa(&self) -> i32 {
        self * 2
    }
}

fn processa_todos(itens: &[Box<dyn Processavel>]) -> Vec<i32> {
    itens.iter().map(|item| item.processa()).collect()
}
```

O profiling revelará chamadas indiretas (dynamic dispatch) que são mais lentas que chamadas diretas. A mensagem típica será:

```
+   45.12%  processa_todos
     - 38.77% <dyn Processavel as Processavel>::processa
        + 35.23% core::ops::function::FnOnce::call_once
     + 6.35% alloc::vec::Vec::extend_from_slice
```

A solução? Quando possível, usar generics:

```rust
fn processa_todos_generic<T: Processavel>(itens: &[T]) -> Vec<i32> {
    itens.iter().map(|item| item.processa()).collect()
}
```

### Tipos de Análise em Profiling

1. **CPU-bound**: Onde o tempo de CPU é gasto
   - Chamadas de função
   - Hot loops
   - Branch mispredictions

2. **Memory-bound**: Acesso à memória
   - Cache misses
   - Alocações frequentes
   - Padrões de acesso

3. **I/O-bound**: Espera por recursos externos
   - Syscalls bloqueantes
   - Operações de arquivo/rede

### Exercício Prático

Analise este código com profiling:

```rust
fn concatena_strings(strings: &[String]) -> String {
    let mut resultado = String::new();
    for s in strings {
        resultado.push_str(s);
    }
    resultado
}
```

1. Qual é o problema de desempenho principal?
2. Como você o resolveria?
3. Qual seria o ganho esperado?

**Solução:**

1. O problema está nas múltiplas realocações da `String` resultado. Cada `push_str` pode exigir realocação.

2. Solução: Pré-calcular o tamanho total e pré-alocar:

```rust
fn concatena_strings_otimizado(strings: &[String]) -> String {
    let tamanho_total = strings.iter().map(|s| s.len()).sum();
    let mut resultado = String::with_capacity(tamanho_total);
    for s in strings {
        resultado.push_str(s);
    }
    resultado
}
```

3. Ganho: De O(n²) para O(n) nas operações de alocação. Para 10,000 strings de 100 bytes, a versão original pode levar ~50ms enquanto a otimizada ~5ms.

O profiling transforma suposições em dados mensuráveis. Sem ele, você estará otimizando no escuro - talvez acelerando partes que já são rápidas enquanto ignora os verdadeiros gargalos.