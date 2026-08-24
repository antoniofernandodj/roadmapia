## Auditoria de Unsafe Code

Um sistema bancário processa milhões de transações por segundo. Para reduzir latência, a equipe substituiu verificações de segurança por blocos `unsafe` que manipulam diretamente buffers de rede. Três meses depois, um ataque explorou um desalinhamento de memória, corrompendo saldos de contas. O problema? Ninguém auditaria o código inseguro.

### O Que Torna Unsafe Perigoso

Este código parece inocente:

```rust
unsafe fn transfer_funds(src: *mut u64, dst: *mut u64, amount: u64) {
    *src -= amount;
    *dst += amount;
}
```

Quando chamado com ponteiros inválidos, causa comportamento indefinido:

```rust
let malicious = 0xDEADBEEF as *mut u64;
unsafe { transfer_funds(malicious, malicious, 1000) }; // SEGFAULT
```

A saída real é imprevisível - pode ser um crash, corrupção silenciosa de dados, ou pior.

### Checklist de Auditoria

1. **Validação de Ponteiros Brutos**
   Antes de dereferenciar, verifique:
   - Alinhamento (`pointer.align_offset(align)`)
   - Não-nulidade (`!ptr.is_null()`)
   - Limites (para slices convertidas)

```rust
unsafe fn safe_transfer(src: *mut u64, dst: *mut u64, amount: u64) -> Result<(), &'static str> {
    if src.is_null() || dst.is_null() {
        return Err("Ponteiro nulo");
    }
    if src.align_offset(std::mem::align_of::<u64>()) != 0 {
        return Err("Desalinhamento em src");
    }
    // Operação segura
    *src -= amount;
    *dst += amount;
    Ok(())
}
```

2. **Invariantes de Tipo**
   Em FFI ou manipulação de bytes crus, garanta que os dados brutos correspondem ao tipo esperado:

```rust
unsafe fn parse_packet(buffer: &[u8]) -> Option<Transaction> {
    if buffer.len() != std::mem::size_of::<Transaction>() {
        return None;
    }
    // Transmute seguro só após verificação de tamanho
    Some(std::ptr::read(buffer.as_ptr() as *const _))
}
```

3. **Exclusividade de Acesso**
   Para múltiplos ponteiros brutos, assegure que não há aliasing:

```rust
unsafe fn no_overlap(src: *const u8, dst: *mut u8, len: usize) -> bool {
    let src_range = src as usize..src as usize + len;
    let dst_range = dst as usize..dst as usize + len;
    src_range.end <= dst_range.start || dst_range.end <= src_range.start
}
```

### Ferramentas de Apoio

- `cargo-geiger`: Detecta uso de `unsafe` no crate e dependências
- `Miri` (executor do Rust): Identifica comportamento indefinido em testes
- `clippy::unsafe`: Lints básicos para práticas arriscadas

### Padrão Ouro: Isolamento

Empacote cada operação insegura em uma função segura com verificações rigorosas:

```rust
// API segura
fn process_transaction(tx: &mut Transaction) -> Result<(), TransactionError> {
    validate_tx(tx)?;
    unsafe {
        // Bloco mínimo com pré-validações
        raw_apply(tx.as_mut_ptr())
    }
}

unsafe fn raw_apply(ptr: *mut Transaction) {
    // Lógica crítica de performance
}
```

### Exercício

Um analisador de protocolo contém este código inseguro:

```rust
unsafe fn parse_header(data: *const u8) -> Header {
    std::ptr::read(data as *const Header)
}
```

Identifique três vulnerabilidades potenciais e reescreva com verificações. Considere:
1. Tamanho do buffer
2. Alinhamento da estrutura
3. Padrões de bits inválidos

**Solução:**

```rust
fn safe_parse(data: &[u8]) -> Option<Header> {
    if data.len() < std::mem::size_of::<Header>() {
        return None;
    }
    if (data.as_ptr() as usize) % std::mem::align_of::<Header>() != 0 {
        return None;
    }
    let header = unsafe { std::ptr::read(data.as_ptr() as *const Header) };
    if !header.is_valid() {
        return None;
    }
    Some(header)
}
```

Esta versão verifica:
- Buffer grande o suficiente (`size_of`)
- Alinhamento correto (`align_of`)
- Validade semântica (`is_valid`)
Mantendo o `unsafe` restrito a uma operação válida.