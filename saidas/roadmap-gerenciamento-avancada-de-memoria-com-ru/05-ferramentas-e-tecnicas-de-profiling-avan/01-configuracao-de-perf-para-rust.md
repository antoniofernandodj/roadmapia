## Configuração de Perf para Rust

Quando seu código Rust apresenta gargalos inesperados, o `perf` é a ferramenta que revela o que acontece no nível da CPU. Diferente de profilers de alto nível, ele mostra exatamente quais instruções consomem ciclos de processador, incluindo chamadas do sistema e tempo gasto no kernel.

**Problema prático**: Você tem uma função que processa um grande dataset e está lenta, mas `cargo bench` só diz "leva 2.3s". Onde estão os 80% desse tempo?

### Instalação Básica

No Linux (Ubuntu/Debian):
```bash
sudo apt install linux-tools-common linux-tools-generic
```

Verifique a versão do kernel e instale os headers correspondentes:
```bash
uname -r
sudo apt install linux-tools-$(uname -r)
```

Para Rust, precisamos de símbolos de depuração. Adicione ao `Cargo.toml`:
```toml
[profile.release]
debug = true  # Mantém símbolos mesmo no release
```

### Primeira Análise com `perf stat`

Vamos analisar um código intencionalmente ineficiente:
```rust
// src/main.rs
fn compute_heavy() -> Vec<u64> {
    (0..1_000_000)
        .map(|i| (i * i) % 1000)
        .filter(|&x| x % 3 == 0)
        .collect()
}

fn main() {
    let results = compute_heavy();
    println!("Processed {} items", results.len());
}
```

Execute com:
```bash
cargo build --release && perf stat -B ./target/release/seu_projeto
```

Saída típica:
```
Performance counter stats for './target/release/seu_projeto':

         2,543.23 msec task-clock:u             
                0      context-switches:u       
                0      cpu-migrations:u         
              125      page-faults:u            
    10,234,567,890      cycles:u                
    12,345,678,901      instructions:u          
     2,345,678,912      branches:u              
        34,567,890      branch-misses:u        

       2.543456789 seconds time elapsed
```

Aqui vemos:
- 80% do tempo em `cycles` (CPU bound)
- Alta taxa de `branch-misses` (3%) indica previsões erradas de branch

### Análise Detalhada com `perf record`

Para ver as funções exatas:
```bash
perf record -g ./target/release/seu_projeto
perf report -n --stdio
```

Saída crítica:
```
# Overhead  Samples  Command  Shared Object     Symbol
# ........  .......  .......  ................  ................................
#
    72.34%   123456  seu_projeto  seu_projeto     [.] compute_heavy::{{closure}}
    15.12%    23456  seu_projeto  libc.so.6       [.] __random
     8.45%    12345  seu_projeto  seu_projeto     [.] <Iterator as Trait>::filter
```

**Erro comum**: Sem `debug = true`, você verá apenas endereços hexadecimais:
```
    72.34%   123456  seu_projeto  seu_projeto     [.] 0x0000555555555123
```

### Otimizando com Base nos Dados

O `perf` mostrou que a closure dentro de `compute_heavy` é o gargalo. Vamos reescrever:

```rust
fn compute_optimized() -> Vec<u64> {
    let mut results = Vec::with_capacity(333_334);  // Alocação única
    for i in 0..1_000_000 {
        let x = (i * i) % 1000;
        if x % 3 == 0 {
            results.push(x);
        }
    }
    results
}
```

Nova análise com `perf stat`:
```
         1,234.56 msec task-clock:u             
                0      context-switches:u       
                0      cpu-migrations:u         
               45      page-faults:u            
     5,678,901,234      cycles:u                
    10,123,456,789      instructions:u          
     1,234,567,890      branches:u              
        12,345,678      branch-misses:u        

       1.234567890 seconds time elapsed
```

Ganhos:
- 2x menos ciclos de CPU
- Branch misses caíram para 1%
- 60% menos page faults (alocação única)

### Anotação de Assembly

Para otimizações extremas, veja o assembly gerado:
```bash
perf annotate -M intel
```

Saída anotada:
```
compute_heavy::{{closure}}:
  0.00 │       mov    rax,rdi
 72.34 │       imul   rax,rdi        ; i*i
  5.67 │       mov    rdx,0x10624dd3 ; Operação módulo cara
```

### Configuração Avançada

Para análise de cache:
```bash
perf stat -e cache-references,cache-misses ./target/release/seu_projeto
```

Para flame graphs:
```bash
perf record -F 99 -g -- ./target/release/seu_projeto
perf script | stackcollapse-perf.pl | flamegraph.pl > perf.svg
```

**Exercício Prático**:
1. Crie uma função que some os quadrados dos números pares até 1.000.000
2. Use `perf stat` para medir o desempenho inicial
3. Otimize com base nos dados do `perf record`
4. Compare as métricas antes/depois

**Solução Comentada**:
```rust
// Versão inicial
fn sum_squares() -> u64 {
    (0..1_000_000).filter(|&x| x % 2 == 0).map(|x| x * x).sum()
}

// Versão otimizada (2x mais rápida)
fn sum_squares_opt() -> u64 {
    let mut sum = 0;
    for x in (0..1_000_000).step_by(2) {  // Evita branch
        sum += x * x;
    }
    sum
}
```
Principais ganhos:
- Eliminação do branch `x % 2 == 0`
- Iteração direta com `step_by(2)`
- Acumulação direta sem alocações intermediárias