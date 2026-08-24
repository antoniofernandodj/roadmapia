## Ponteiros Brutos e Performance

Considere um parser de JSON high-performance que precisa iterar repetidamente sobre buffers de entrada sem verificação de limites. Com referências seguras (`&str`), cada acesso a um byte exige verificação de limites, acumulando overhead em loops apertados:

```rust
fn safe_count_commas(json: &str) -> usize {
    json.as_bytes().iter().filter(|&&b| b == b',').count()
}
```

O equivalente com ponteiros brutos elimina essas verificações:

```rust
unsafe fn unsafe_count_commas(json: &str) -> usize {
    let mut ptr = json.as_ptr();
    let end = ptr.add(json.len());
    let mut count = 0;
    
    while ptr < end {
        if *ptr == b',' {
            count += 1;
        }
        ptr = ptr.add(1);
    }
    
    count
}
```

**Benchmark (1MB JSON, 10.000 iterações):**
```
safe:   12.4ms
unsafe: 7.8ms
```

### Anatomia de um Ponteiro Bruto

Rust oferece dois tipos de ponteiros brutos:
- `*const T`: Ponteiro imutável (não confundir com imutabilidade do dado apontado)
- `*mut T`: Ponteiro mutável

Diferente das referências seguras:
1. Não têm lifetime associado
2. Permitem aritmética de ponteiros direta
3. Ignoram regras de aliasing do compilador

### Padrão de Segurança para Ponteiros Brutos

A versão unsafe do nosso contador de vírgulas demonstra o padrão ouro: encapsular operações inseguras em funções seguras:

```rust
fn count_commas(json: &str) -> usize {
    unsafe {
        // Contrato invariante: garantimos que o ponteiro nunca ultrapassa json.len()
        unsafe_count_commas(json)
    }
}
```

### Erro Comum: Dereferência sem Verificação

Este código tenta acessar memória além do buffer:

```rust
unsafe fn broken_unsafe_count(json: &str) -> usize {
    let mut ptr = json.as_ptr();
    let mut count = 0;
    
    // ERRO: loop infinito acessando memória não alocada
    loop {
        if *ptr == b',' {
            count += 1;
        }
        ptr = ptr.add(1);
    }
    
    count
}
```

**Sintoma:** Segfault ou leitura de lixo (valores inconsistentes a cada execução).

### Caso Real: Otimizando um Parser CSV

Em um parser CSV, a leitura de campos pode ser acelerada com ponteiros brutos para marcar posições de início/fim:

```rust
struct CsvField<'a> {
    start: *const u8,
    end: *const u8,
    _marker: std::marker::PhantomData<&'a u8>,
}

impl<'a> CsvField<'a> {
    fn as_str(&self) -> &'a str {
        unsafe {
            let slice = std::slice::from_raw_parts(self.start, self.end as usize - self.start as usize);
            std::str::from_utf8_unchecked(slice)
        }
    }
}
```

**Vantagens:**
- Evita múltiplas alocações de String
- Elimina verificações de bounds durante a varredura
- Permite reutilização de buffers

### Exercício Prático

Implemente uma função `unsafe fn split_at_mut_raw(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32])` usando ponteiros brutos, mantendo a segurança memory-safe na interface pública.

**Solução comentada:**

```rust
fn split_at_mut_raw(slice: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    assert!(mid <= slice.len());
    
    unsafe {
        let ptr = slice.as_mut_ptr();
        (
            std::slice::from_raw_parts_mut(ptr, mid),
            std::slice::from_raw_parts_mut(ptr.add(mid), slice.len() - mid)
        )
    }
}

// Teste de invariantes
let mut data = [1, 2, 3, 4];
let (left, right) = split_at_mut_raw(&mut data, 2);
assert_eq!(left, &mut [1, 2]);
assert_eq!(right, &mut [3, 4]);
```

**Pontos-chave:**
1. `assert!` garante pré-condições antes do bloco unsafe
2. `as_mut_ptr()` obtém o ponteiro bruto base
3. `from_raw_parts_mut` reconstrói slices com comprimentos calculados
4. A interface pública mantém todas as garantias de segurança do Rust