## Ferramentas de Profiling: Perf

Suponha que você otimizou seu código Rust para evitar alocações desnecessárias, mas ainda não está satisfeito com o desempenho. Como identificar os gargalos reais? O `perf` é a ferramenta de profiling do Linux que mostra exatamente onde seu programa gasta tempo e recursos.

Vamos analisar um caso real. Considere este processador de logs que parece lento:

```rust
use std::fs::File;
use std::io::{BufRead, BufReader};

fn count_error_logs(path: &str) -> usize {
    let file = File::open(path).unwrap();
    let reader = BufReader::new(file);
    
    reader.lines()
        .filter(|line| line.as_ref().unwrap().contains("ERROR"))
        .count()
}
```

Primeiro, compile com símbolos de debug para o `perf` mapear o código:

```bash
RUSTFLAGS="-g" cargo build --release
```

Execute o programa com o `perf` coletando dados:

```bash
perf record -g ./target/release/seu_programa large_log.txt
```

Isso gera um arquivo `perf.data`. Veja o relatório com:

```bash
perf report
```

A saída típica mostra:

```
+   48.23%  seu_programa  [kernel]       [k] __clear_user
+   25.71%  seu_programa  libc.so.6      [.] _IO_getc
+   12.45%  seu_programa  seu_programa   [.] std::io::buffered::BufReader<R>::fill_buf
+    6.12%  seu_programa  seu_programa   [.] <std::io::Lines<B> as Iterator>::next
```

O problema está claro: 48% do tempo no kernel copiando dados (__clear_user) e 25% na libc lendo caracteres um a um (_IO_getc). Isso indica que nosso `BufReader` está usando buffers pequenos demais.

Vamos otimizar aumentando o buffer e processando blocos maiores:

```rust
fn count_error_logs_fast(path: &str) -> usize {
    let file = File::open(path).unwrap();
    let mut reader = BufReader::with_capacity(1_000_000, file); // Buffer de 1MB
    let mut count = 0;
    let mut line = String::new();
    
    while reader.read_line(&mut line).unwrap() > 0 {
        if line.contains("ERROR") {
            count += 1;
        }
        line.clear();
    }
    count
}
```

Após recompilar e rodar novamente o `perf`, a nova análise mostra:

```
+   68.12%  seu_programa  seu_programa   [.] std::io::buffered::BufReader<R>::fill_buf 
+   15.23%  seu_programa  libc.so.6      [.] memchr
+    8.12%  seu_programa  seu_programa   [.] alloc::string::String::clear
```

Agora o tempo principal está no preenchimento do buffer (68%), que é o esperado, e o kernel não aparece mais nos hotspots. O throughput aumentou 3× na nossa medição.

### Erro Comum: Perf Sem Símbolos de Debug

Se você esquecer os símbolos de debug, verá algo inútil como:

```
+   72.34%  seu_programa  [unknown]      [.] 0x000055555555a3b0
```

Sempre compile com `-g` para Rust ou `-ggdb` para C/C++.

### Exercício Prático

Analise este processador de CSV com `perf` e otimize-o:

```rust
use std::fs::File;
use std::io::{BufRead, BufReader};

fn sum_csv_column(path: &str, column: usize) -> f64 {
    let file = File::open(path).unwrap();
    let reader = BufReader::new(file);
    
    reader.lines()
        .map(|line| {
            let line = line.unwrap();
            line.split(',')
                .nth(column)
                .unwrap()
                .parse::<f64>()
                .unwrap()
        })
        .sum()
}
```

**Solução:**

O `perf` revelará que:
1. Muitas alocações de String nas operações `line.unwrap()` e `split()`
2. Parsing repetido de floats é lento

Versão otimizada:

```rust
fn sum_csv_column_fast(path: &str, column: usize) -> f64 {
    let file = File::open(path).unwrap();
    let mut reader = BufReader::with_capacity(1_000_000, file);
    let mut sum = 0.0;
    let mut line = String::new();
    let mut temp_vec = Vec::with_capacity(32); // Reutilizado
    
    while reader.read_line(&mut line).unwrap() > 0 {
        temp_vec.extend(line.split(','));
        
        if let Some(value) = temp_vec.get(column) {
            sum += value.parse::<f64>().unwrap();
        }
        
        line.clear();
        temp_vec.clear();
    }
    sum
}
```

Principais melhorias:
- Buffer grande (1MB)
- Reutilização de String e Vec
- Processamento por blocos em vez de iterators encadeados