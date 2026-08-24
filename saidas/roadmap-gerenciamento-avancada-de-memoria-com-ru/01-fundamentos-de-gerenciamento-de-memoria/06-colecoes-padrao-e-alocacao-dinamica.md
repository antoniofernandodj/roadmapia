## Coleções Padrão e Alocação Dinâmica

Quando você precisa armazenar múltiplos valores de forma dinâmica em Rust, as coleções da biblioteca padrão (`std::collections`) são sua primeira ferramenta. Diferente de arrays (que têm tamanho fixo conhecido em tempo de compilação), estruturas como `Vec`, `HashMap` e `String` gerenciam automaticamente a memória heap, crescendo ou encolhendo conforme necessário.

### O Vec<T>: Alocação Dinâmica com Crescimento Inteligente

Um `Vec` aloca inicialmente um buffer na heap com capacidade para alguns elementos (geralmente pequeno, como 4). Quando você adiciona elementos além da capacidade atual, ocorre um processo chamado "reallocation":

```rust
fn main() {
    let mut numbers = Vec::with_capacity(2); // Capacidade inicial: 2
    println!("Capacidade inicial: {}", numbers.capacity());
    
    numbers.push(10); // Sem realocação
    numbers.push(20); // Sem realocação
    numbers.push(30); // Realocação aqui!
    
    println!("Nova capacidade: {}", numbers.capacity()); // Geralmente dobra
    println!("Conteúdo: {:?}", numbers);
}
```

Saída típica:
```
Capacidade inicial: 2
Nova capacidade: 4
Conteúdo: [10, 20, 30]
```

O Rust não garante o fator de crescimento exato (pode variar por versão), mas a estratégia comum é dobrar a capacidade para manter operações `push` em O(1) amortizado. Isso significa que, embora ocasionalmente uma operação seja cara (quando realoca), a média é eficiente.

### Erro Comum: Realocações Desnecessárias

Considere este código que preenche um `Vec` sem pré-alocação:

```rust
let mut vec = Vec::new();
for i in 0..10_000 {
    vec.push(i); // Pode causar múltiplas realocações
}
```

Cada vez que a capacidade é excedida, o Rust:
1. Aloca um novo bloco maior
2. Copia todos os elementos existentes
3. Libera o bloco antigo

Para evitar isso, use `Vec::with_capacity` quando souber o tamanho aproximado:

```rust
let mut vec = Vec::with_capacity(10_000);
for i in 0..10_000 {
    vec.push(i); // Sem realocações
}
```

### HashMap: Alocação Sob Demanda

Um `HashMap` começa com capacidade zero e só aloca memória quando inserimos o primeiro elemento:

```rust
use std::collections::HashMap;

fn main() {
    let mut map = HashMap::new();
    println!("Capacidade inicial: {}", map.capacity()); // 0
    
    map.insert("chave", 42);
    println!("Capacidade após inserção: {}", map.capacity()); // 3 (pode variar)
}
```

A capacidade de um `HashMap` geralmente é um número primo para melhor distribuição nas buckets. Ao atingir ~75% de ocupação (fator de carga), ele realoca para manter a eficiência de busca.

### String vs &str: Duas Faces do Texto

Uma `String` é essencialmente um `Vec<u8>` garantido conter UTF-8 válido. Veja como ela gerencia memória:

```rust
fn main() {
    let mut s = String::new();
    println!("Capacidade inicial: {}", s.capacity()); // 0
    
    s.push_str("Olá");
    println!("Capacidade após 'Olá': {}", s.capacity()); // 4 bytes (1 por char)
    
    s.push_str(" mundo!");
    println!("Capacidade final: {}", s.capacity()); // Provavelmente 11
}
```

Já `&str` é uma fatia (slice) imutável que aponta para dados em outro lugar (na heap, stack ou memória estática).

### Gerenciamento de Memória nas Coleções

Todas as coleções padrão implementam `Drop` para liberar memória automaticamente quando saem de escopo:

```rust
fn cria_vec() -> Vec<i32> {
    let v = vec![1, 2, 3];
    v // Transferência de ownership
} // Nenhum vazamento aqui - memória é liberada se ninguém mais possuir

fn main() {
    let v = cria_vec();
    println!("Vec ainda vivo: {:?}", v);
} // Liberado aqui
```

### Exercício Prático

Analise este código que processa linhas de um arquivo:

```rust
fn processa_linhas(linhas: &[&str]) -> Vec<String> {
    let mut resultados = Vec::new();
    for linha in linhas {
        resultados.push(linha.trim().to_uppercase());
    }
    resultados
}
```

**Problema**: Mesmo sabendo que o número de linhas de entrada é igual ao de saída, o código não pré-aloca o `Vec` de resultados. Modifique a função para evitar realocações desnecessárias.

**Solução**:

```rust
fn processa_linhas(linhas: &[&str]) -> Vec<String> {
    let mut resultados = Vec::with_capacity(linhas.len()); // Pré-alocação
    for linha in linhas {
        resultados.push(linha.trim().to_uppercase());
    }
    resultados
}
```

A diferença de desempenho será perceptível principalmente com grandes volumes de dados. Em um benchmark com 10.000 linhas, a versão pré-alocada pode ser até 2x mais rápida por evitar múltiplas realocações e cópias.