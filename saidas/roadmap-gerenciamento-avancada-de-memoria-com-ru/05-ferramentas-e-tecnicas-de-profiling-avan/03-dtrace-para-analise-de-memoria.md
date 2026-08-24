## DTrace para Análise de Memória

Quando um sistema Rust apresenta problemas de desempenho inesperados ou consumo excessivo de memória, muitas vezes a causa está em alocações ocultas ou padrões de acesso ineficientes. O DTrace, disponível em sistemas Solaris, macOS e BSD, permite investigar esses problemas com granularidade inigualável, rastreando chamadas de sistema, alocações de heap e até instruções específicas do programa.

### Configurando o Ambiente para DTrace com Rust

Primeiro, verifique se o DTrace está disponível em seu sistema. Em macOS, ele vem pré-instalado. Para Rust, precisamos compilar com símbolos de depuração:

```bash
RUSTFLAGS="-g" cargo build --release
```

Crie um programa de teste com um problema de memória intencional:

```rust
// src/main.rs
use std::thread;
use std::time::Duration;

fn process_data(data: Vec<u8>) -> Vec<u8> {
    thread::sleep(Duration::from_millis(10));
    data.into_iter().map(|x| x.wrapping_add(1)).collect()
}

fn main() {
    let mut handles = vec![];
    
    for _ in 0..100 {
        handles.push(thread::spawn(|| {
            let data = vec![0u8; 1024 * 1024]; // 1MB por thread
            let _processed = process_data(data);
        }));
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

Este código cria 100 threads, cada uma alocando 1MB de dados. Mesmo sendo um exemplo artificial, ele demonstra um padrão comum: alocação repetitiva em loops ou threads.

### Rastreando Alocações de Memória

Crie um script DTrace (`memtrace.d`) para monitorar alocações:

```d
#!/usr/sbin/dtrace -s

pid$target::*alloc*:entry
{
    @alloc[ustack()] = count();
}

tick-10s
{
    printa(@alloc);
    clear(@alloc);
}
```

Execute o programa com o DTrace:

```bash
sudo dtrace -s memtrace.d -c "./target/release/seu_programa"
```

A saída mostrará pilhas de chamada onde ocorrem alocações, com contagens:

```
              libsystem_malloc.dylib`malloc
              libsystem_malloc.dylib`malloc_zone_malloc
              librustc_std_workspace_alloc.dylib`__rust_alloc
              seu_programa`alloc::alloc::alloc
              seu_programa`alloc::raw_vec::RawVec<T,A>::allocate_in
              seu_programa`alloc::raw_vec::RawVec<T,A>::with_capacity
              seu_programa`alloc::vec::Vec<T>::with_capacity
              seu_programa`main::process_data
              seu_programa`main::{{closure}}
              100
```

### Analisando Vazamentos de Memória

Para detectar memória alocada mas não liberada, modifique o script:

```d
pid$target::*alloc*:entry
{
    self->size = arg0;
}

pid$target::*alloc*:return
/self->size > 1024/
{
    @mem[pid, ustack()] = sum(self->size);
    self->size = 0;
}

pid$target::*free*:entry
{
    @mem[pid, ustack()] = sum(-arg0);
}
```

Este script rastreia:
1. Alocações maiores que 1KB
2. Operações de liberação
3. Calcula o saldo de memória por pilha de chamada

### Otimizando com Base nos Dados

A análise revela que nosso programa:
1. Aloca repetidamente buffers de 1MB
2. Não reutiliza memória entre threads
3. Tem sobrecarga de inicialização

A versão otimizada usa `Arc<[u8]>` para compartilhamento seguro:

```rust
use std::sync::Arc;
use std::thread;

fn process_data(data: Arc<[u8]>) -> Arc<[u8]> {
    thread::sleep(std::time::Duration::from_millis(10));
    Arc::new(data.iter().map(|x| x.wrapping_add(1)).collect::<Vec<_>>().into())
}

fn main() {
    let data = Arc::new(vec![0u8; 1024 * 1024].into_boxed_slice());
    let mut handles = vec![];
    
    for _ in 0..100 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            let _processed = process_data(data);
        }));
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

### Comparando o Desempenho

Antes (com `Vec`):
- 100 alocações de 1MB
- 100MB totais alocados
- Tempo: ~1.5s

Depois (com `Arc<[u8]>`):
- 1 alocação de 1MB
- 100 clonagens de Arc
- Tempo: ~1.1s
- Memória: redução de 99MB

### Exercício Prático

Identifique o problema de memória neste código usando DTrace:

```rust
fn parse_logs(logs: &str) -> Vec<String> {
    logs.lines()
        .filter(|line| line.contains("ERROR"))
        .map(|line| line.trim().to_string())
        .collect()
}

fn main() {
    let logs = "INFO: System started\nERROR: Disk full\nWARN: Network slow\nERROR: Timeout";
    for _ in 0..1000 {
        let _errors = parse_logs(logs);
    }
}
```

**Solução:**

1. Crie um script DTrace para rastrear alocações de String
2. Execute com `sudo dtrace -s string_alloc.d -c "./target/release/programa"`

O problema está na alocação repetida de Strings para as mesmas mensagens de erro. A solução é usar `&str` ou armazenar em cache as Strings:

```rust
fn parse_logs(logs: &str) -> Vec<&str> {
    logs.lines()
        .filter(|line| line.contains("ERROR"))
        .map(|line| line.trim())
        .collect()
}
```

Ou para casos onde a ownership é necessária:

```rust
use once_cell::sync::Lazy;

static ERROR_LOGS: Lazy<Vec<String>> = Lazy::new(|| {
    let logs = "INFO: System started\nERROR: Disk full\nWARN: Network slow\nERROR: Timeout";
    logs.lines()
        .filter(|line| line.contains("ERROR"))
        .map(|line| line.trim().to_string())
        .collect()
});

fn main() {
    for _ in 0..1000 {
        let _errors = &*ERROR_LOGS;
    }
}
```