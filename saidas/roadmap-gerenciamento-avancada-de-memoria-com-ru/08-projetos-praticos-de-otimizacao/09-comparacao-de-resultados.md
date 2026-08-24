## Comparação de Resultados

Considere um servidor HTTP em Rust que processa requisições JSON, originalmente implementado sem otimizações. Antes das mudanças, seu código principal usava clones desnecessários e alocava buffers repetidamente:

```rust
// Versão não otimizada (antes)
async fn handle_request(request: Request<Body>) -> Result<Response<Body>, Infallible> {
    let full_body = hyper::body::to_bytes(request.into_body()).await?;
    let parsed: Value = serde_json::from_slice(&full_body)?; // Alocação temporária
    
    // Processamento que requer clone
    let response_data = process_data(parsed.clone()); // Cópia desnecessária
    
    Ok(Response::new(serde_json::to_string(&response_data)?.into()))
}
```

Após profiling com `perf` e `flamegraph`, identificamos dois gargalos principais:
1. 35% do tempo em alocações JSON (via `from_slice`/`to_string`)
2. 25% em operações de clone durante o processamento

A versão otimizada introduz:
- Buffers reutilizáveis com `bytes::BytesMut`
- Empréstimos (`&`) no lugar de clones
- Serialização direta para o buffer de resposta

```rust
// Versão otimizada (depois)
async fn handle_request(
    request: Request<Body>,
    buffer: &mut BytesMut  // Pool de buffers reutilizável
) -> Result<Response<Body>, Infallible> {
    buffer.clear();
    let full_body = hyper::body::to_bytes(request.into_body()).await?;
    
    // Processamento sem clone
    let response_data = process_data(&serde_json::from_slice::<Value>(&full_body)?);
    
    buffer.reserve(estimate_size(&response_data));
    serde_json::to_writer(buffer.writer(), &response_data)?;
    
    Ok(Response::new(buffer.split().freeze().into()))
}
```

### Métricas Comparativas (10k requisições/sec)

| Métrica               | Antes   | Depois  | Ganho   |
|-----------------------|---------|---------|---------|
| Alocações/req         | 12      | 3       | 75%↓    |
| Memória (MB)          | 84      | 32      | 62%↓    |
| Latência p99 (ms)     | 24.7    | 9.1     | 63%↓    |
| Throughput (req/sec)  | 3,200   | 9,800   | 3.1x↑   |

### Análise dos Resultados

1. **Alocações**: A mudança para buffers reutilizáveis eliminou 9 alocações por requisição, visível no output do `cargo-flamegraph` antes/depois:
   ```
   BEFORE: alloc::alloc::exchange_malloc (35.2%)
   AFTER:  alloc::alloc::exchange_malloc (8.1%)
   ```

2. **Clone Elimination**: O `RUST_LOG=warn` agora mostra zero ocorrências de `CLONE` nas operações críticas, enquanto antes registrava:
   ```
   WARN  - Cloning Value at handlers.rs:47
   ```

3. **Erro Comum**: Um desenvolvedor tentou otimizar prematuramente com `unsafe` para evitar cópias, mas introduziu um bug de lifetime:
   ```rust
   let parsed: &Value = unsafe { &*(serde_json::from_slice::<Value>(&full_body)? as *const _) };
   // ^^ Dangling pointer após buffer ser liberado
   ```
   O compilador Rust emite:
   ```
   error[E0597]: `full_body` does not live long enough
   --> borrows value beyond its lifetime
   ```

### Exercício Prático

**Problema**: Dado o código abaixo que processa uma lista de usuários, meça o desempenho atual com `criterion` e otimize-o aplicando:
1. Reutilização de buffers
2. Eliminação de clones
3. Iteradores lentos

```rust
fn process_users(users: Vec<User>) -> Vec<UserProfile> {
    users.iter()
        .map(|u| {
            let profile = build_profile(u.clone()); // Cópia desnecessária
            validate_profile(profile.clone());      // Outra cópia
            profile
        })
        .collect()
}
```

**Solução**:
```rust
fn process_users(users: &[User], buffer: &mut Vec<UserProfile>) {
    buffer.clear();
    buffer.reserve(users.len());
    
    users.iter()
        .map(|u| {
            let profile = build_profile(u);  // &User agora
            validate_profile(&profile);      // Empréstimo
            profile
        })
        .for_each(|p| buffer.push(p));      // Prealocado
}
```

**Resultado Esperado**:
- 2 clones eliminados por item
- 1 alocação (vetor final) vs N+1 alocações originais