## Desafios Pessoais

Agora que você domina técnicas avançadas de gerenciamento de memória em Rust, é hora de testar suas habilidades com desafios práticos que simulam problemas reais. Seguem quatro níveis de complexidade:

**1. Micro-Otimizações em Estruturas Críticas**  
Implemente uma versão otimizada da função abaixo, que processa um grande vetor de transações financeiras, eliminando alocações desnecessárias:

```rust
struct Transaction {
    from: String,
    to: String,
    amount: f64,
}

fn process_transactions(transactions: Vec<Transaction>) -> HashMap<String, f64> {
    let mut balances = HashMap::new();
    for txn in transactions {
        *balances.entry(txn.from).or_insert(0.0) -= txn.amount;
        *balances.entry(txn.to).or_insert(0.0) += txn.amount;
    }
    balances
}
```

**Desafio**: Reescreva usando `&str` em vez de `String` para campos de endereço, e `with_capacity` para pré-alocar o HashMap. Meça o ganho de performance com criterion (100k transações).

---

**2. Sistema de Cache com Gerenciamento Manual**  
Crie um `LruCache` que:  
- Aloque blocos de memória com `std::alloc::alloc`  
- Utilize `MaybeUninit` para inicialização tardia  
- Implemente política de evicção customizável  
- Expõe API segura (sem unsafe no código do usuário)

**Dica**: Comece com capacidade fixa, depois generalize. Teste com valgrind para verificar vazamentos.

---

**3. Servidor HTTP com Pool de Buffers**  
Construa um servidor async que:  
- Mantém um pool de buffers pré-alocados para requisições  
- Reutiliza buffers entre conexões com Arc<Mutex<Vec<u8>>>  
- Implemente um benchmark comparando com alocação por requisição  
- Extra: substitua Mutex por lock-free structure usando crossbeam

**Métrica-alvo**: 10% reduction em alocações para carga de 1k RPS.

---

**4. Otimização de Algoritmo Numérico**  
Pegue qualquer implementação existente de:  
- FFT  
- Pathfinding (A*/Dijkstra)  
- SIMD matrix multiplication  

**Sua missão**:  
1. Profile com flamegraph para identificar hotspots  
2. Aplike:  
   - Arena allocation para estruturas temporárias  
   - Prefetching manual  
   - Alinhamento de memória (align_to)  
3. Documente cada mudança com benchmarks antes/depois

**Dica**: O crate `bencher` é seu aliado para medições precisas.

---

**Regras para Todos os Desafios**:  
- Sem compromisso com "a solução certa" - explore tradeoffs  
- Mantenha um log de decisões com motivações técnicas  
- Compare sempre com a versão ingênua  
- Ao terminar, publique no GitHub como learning repo  

Estes exercícios forçam escolhas arquiteturais onde técnicas do livro se aplicam diretamente. Quando enfrentar bloqueios, revise os capítulos sobre profiling (5) e unsafe optimizations (7).