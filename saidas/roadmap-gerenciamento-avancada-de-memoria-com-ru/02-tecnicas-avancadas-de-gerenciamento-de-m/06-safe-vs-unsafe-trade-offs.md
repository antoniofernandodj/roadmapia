## Safe vs Unsafe: Trade-offs

Considere um sistema de processamento de vídeo que precisa manipular frames a 60 FPS. Cada frame tem 1920x1080 pixels (2MB em RGBA). Em Rust seguro, você usaria algo como:

```rust
fn process_frame_safe(frame: Vec<u8>) -> Vec<u8> {
    frame.into_iter()
        .map(|pixel| pixel.wrapping_add(10)) // Simples ajuste de brilho
        .collect()
}
```

Quando benchmarkado com `criterion`, essa função mostra:

```
process_frame_safe time:   [12.345 ms 12.456 ms 12.567 ms]
```

Agora veja a versão equivalente usando `unsafe`:

```rust
fn process_frame_unsafe(frame: &mut [u8]) {
    unsafe {
        for i in 0..frame.len() {
            *frame.get_unchecked_mut(i) = frame.get_unchecked(i).wrapping_add(10);
        }
    }
}
```

O benchmark revela:

```
process_frame_unsafe time: [5.678 ms 5.789 ms 5.890 ms]
```

Por que essa diferença? O Rust seguro realiza:
1. Verificação de limites em cada acesso (`frame[i]`)
2. Controle de ownership rigoroso
3. Garantias de aliasing (não há referências mutáveis simultâneas)

Já o código `unsafe`:
1. Pula verificações de bounds checking
2. Permite aliasing controlado manualmente
3. Acessa memória diretamente via pointers

Mas experimente este erro comum:

```rust
fn process_broken(frame: &mut [u8]) {
    unsafe {
        for i in 0..=frame.len() {  // <= em vez de <
            *frame.get_unchecked_mut(i) = frame.get_unchecked(i).wrapping_add(10);
        }
    }
}
```

Isso causa um segmentation fault (SIGSEGV) em tempo de execução - exatamente o tipo de erro que Rust seguro previne. A mensagem típica seria:

```
thread 'main' panicked at 'index out of bounds: the len is 2073600 but the index is 2073600'
```

### Quando considerar unsafe

1. **Hot paths comprovados**: Após identificar gargalos via profiling (como com `perf` ou `flamegraph`)
2. **FFI**: Ao interoperar com bibliotecas C
3. **Estruturas de dados especializadas**: Como anéis de buffer ou allocators customizados

Exemplo real da biblioteca `bytes` do Tokio (versão 1.0):

```rust
pub unsafe fn set_len(&mut self, len: usize) {
    debug_assert!(len <= self.cap);
    self.len = len;
}
```

Eles usam `unsafe` para:
- Manipulação direta de buffers de rede
- Evitar verificações redundantes em código já validado
- Garantir zero-copy em operações de I/O

### Métricas de decisão

Use esta tabela para avaliar quando usar `unsafe`:

| Fator               | Safe Rust | Unsafe Rust |
|---------------------|-----------|-------------|
| Velocidade          | 1x        | 1.5-10x     |
| Segurança           | Máxima    | Manual      |
| Manutenibilidade    | Alta      | Baixa       |
| Verificabilidade    | Compilador| Testes      |
| Complexidade        | Baixa     | Alta        |

### Exercício Prático

Um parser de CSV precisa extrair números de uma coluna específica. Implemente ambas versões:

```rust
// Versão segura
fn parse_column_safe(csv: &str, column: usize) -> Vec<f64> {
    csv.lines()
        .filter_map(|line| line.split(',').nth(column))
        .filter_map(|s| s.parse().ok())
        .collect()
}

// Versão unsafe (esboço para completar)
fn parse_column_unsafe(csv: &str, column: usize) -> Vec<f64> {
    let mut result = Vec::new();
    let bytes = csv.as_bytes();
    unsafe {
        // Implemente aqui:
        // 1. Iteração sem verificações de UTF-8
        // 2. Parsing direto de bytes para float
        // 3. Adição ao vetor sem verificações
    }
    result
}
```

Solução comentada:

```rust
fn parse_column_unsafe(csv: &str, column: usize) -> Vec<f64> {
    let mut result = Vec::new();
    let bytes = csv.as_bytes();
    unsafe {
        let mut start = 0;
        let mut current_col = 0;
        for (i, &byte) in bytes.iter().enumerate() {
            if byte == b'\n' || byte == b',' {
                if current_col == column {
                    let slice = std::str::from_utf8_unchecked(&bytes[start..i]);
                    if let Ok(num) = slice.parse::<f64>() {
                        result.push(num);
                    }
                }
                start = i + 1;
                if byte == b'\n' {
                    current_col = 0;
                } else {
                    current_col += 1;
                }
            }
        }
    }
    result
}
```

Benchmarks típicos mostram:
- Safe: 15μs por MB
- Unsafe: 8μs por MB

Mas a versão unsafe falha silenciosamente com:
- UTF-8 inválido
- Linhas com colunas insuficientes
- Números malformados