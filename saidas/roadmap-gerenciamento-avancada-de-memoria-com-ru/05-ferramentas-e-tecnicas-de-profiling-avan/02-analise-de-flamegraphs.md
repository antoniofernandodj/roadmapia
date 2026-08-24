## Análise de Flamegraphs

Um flamegraph é uma visualização hierárquica de onde seu programa gasta tempo de CPU ou memória. Quando você suspeita que sua aplicação Rust tem problemas de desempenho relacionados a alocação de memória, o flamegraph revela quais funções estão consumindo mais recursos.

Considere este cenário: sua aplicação web em Rust está respondendo lentamente sob carga. Você já usou `perf` para gerar um flamegraph (como visto no capítulo anterior), mas agora precisa interpretar os resultados.

### Estrutura de um Flamegraph

Um flamegraph típico mostra:

1. **Eixo X**: Espaço proporcional ao tempo de execução ou alocação
2. **Eixo Y**: Pilha de chamadas (call stack) hierárquica
3. **Cores**: Geralmente sem significado específico, apenas para diferenciação

Exemplo de um trecho problemático:

```rust
fn process_data(data: &[u8]) -> Vec<u8> {
    let mut buffer = Vec::with_capacity(data.len() * 2);  // Alocação suspeita
    
    // Processamento intensivo
    for &byte in data {
        buffer.push(byte);
        buffer.push(byte.wrapping_add(1));  // Operação dummy
    }
    
    buffer
}
```

No flamegraph, essa função apareceria como um bloco largo (consumindo tempo significativo) com estas características:

- Chamada por `handle_request`
- Alocações frequentes mostradas como "sub-chamas" dentro do bloco
- Proporcionalmente maior que outras funções no mesmo nível

### Identificando Problemas de Memória

1. **Alocações frequentes**: Procure por padrões de "picos" estreitos e repetitivos
   - Indica muitas pequenas alocações em vez de poucas grandes
   - Comum em loops com `Vec::new()` ou `String::new()`

2. **Cópias desnecessárias**: Blocos largos antes/after operações de clone
   - Procure por chamadas a `.clone()` ou `to_owned()`

3. **Realocações**: Padrão de "escada" em operações com vetores
   - Ocorre quando `Vec` precisa crescer e realocar memória

Exemplo problemático no flamegraph:

```
process_data (45.2%)  <-- Grande consumo de tempo
├── memcpy (32.1%)    <-- Cópias de memória
├── malloc (28.7%)    <-- Muitas alocações
└── free (15.2%)      <-- Desalocações frequentes
```

### Caso Prático: Otimizando um Processador de Dados

Vamos analisar um flamegraph real de uma função que processa linhas de log:

```rust
fn count_errors(logs: &[String]) -> usize {
    logs.iter()
        .filter(|line| line.contains("ERROR"))
        .count()
}
```

O flamegraph mostra:

1. 60% do tempo gasto em alocação de Strings temporárias
2. 25% em operações de comparação (`contains`)
3. 15% em iteração

A versão otimizada evita alocações:

```rust
fn count_errors(logs: &[&str]) -> usize {  // Recebe string slices
    logs.iter()
        .filter(|&&line| line.contains("ERROR"))  // Operação direta
        .count()
}
```

Resultado no novo flamegraph:

1. 85% em operações de comparação (agora dominante)
2. 15% em iteração
3. 0% em alocações

### Erros Comuns de Interpretação

1. **Confundir largura com altura**:
   - Um bloco alto não é necessariamente problemático
   - Foque nos blocos mais largos (que consomem mais tempo)

2. **Ignorar chamadas do sistema**:
   - `malloc`, `free`, `memcpy` indicam problemas de memória
   - Não são "parte do Rust" mas aparecem no flamegraph

3. **Otimizar o caminho feliz**:
   - Verifique se os gargalos estão no caso comum ou em erros

### Exercício Prático

Analise este flamegraph parcial de uma função de ordenação:

```
sort_data (100%)
├── Vec::sort (75%)
│   ├── memcmp (60%)
│   └── swap (15%)
├── Vec::with_capacity (20%)
└── data_normalization (5%)
```

1. Qual é o maior gargalo de desempenho?
2. Que tipo de otimização você sugeriria?
3. Como a alocação inicial (`with_capacity`) impacta o desempenho?

**Solução Comentada**:

1. O maior gargalo é `memcmp` (60%), indicando que a comparação de elementos é custosa
2. Sugestões:
   - Implementar `Ord` manualmente para tipos complexos
   - Considerar ordenação por chave mais simples (`sort_by_key`)
3. `with_capacity` consome 20% - pode ser otimizado alocando com tamanho exato antecipadamente