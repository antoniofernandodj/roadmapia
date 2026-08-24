## Ferramentas de Profiling: DTrace

Quando seu código Rust já está otimizado em termos de ownership e alocações, mas ainda apresenta gargalos inexplicáveis, é hora de ir mais fundo. O DTrace é uma ferramenta de profiling dinâmico que permite inspecionar o comportamento do programa em tempo real, capturando desde chamadas de função até alocações de memória específicas, sem recompilar.

### Configurando o Ambiente para DTrace no Rust

Primeiro, instale as dependências no macOS (nativo) ou Linux (via SystemTap):

```bash
# macOS (já incluso)
sudo dtrace -h

# Linux (Ubuntu/Debian)
sudo apt-get install systemtap-sdt-dev
```

Adicione ao seu `Cargo.toml`:

```toml
[build-dependencies]
dtrace = { version = "0.8", features = ["probes"] }
```

Crie um arquivo `build.rs` na raiz do projeto:

```rust
fn main() {
    #[cfg(target_os = "macos")]
    println!("cargo:rustc-link-arg=-ldtrace");

    #[cfg(target_os = "linux")]
    println!("cargo:rustc-link-arg=-lSystemTap");
}
```

### Instrumentando Código Rust com Probes

Modifique seu código para incluir pontos de sondagem. Veja um exemplo que monitora uma função crítica:

```rust
use dtrace::Probe;

fn process_data(data: &[u8]) -> usize {
    dtrace::probe!("rustapp", "process-data-start", data.len());
    
    let result = data.iter().filter(|&&x| x > 100).count();
    
    dtrace::probe!("rustapp", "process-data-end", result);
    result
}

fn main() {
    let dataset = vec![120, 90, 105, 80, 130];
    let count = process_data(&dataset);
    println!("Processed {} elements", count);
}
```

Ao compilar, você verá:

```bash
$ cargo build
warning: `dtrace` probes are enabled (debuginfo is enabled)
```

### Executando e Capturando Dados

Crie um script DTrace (`profile.d`):

```d
rustapp*:::process-data-start {
    printf("Iniciando processamento: tamanho=%d\n", arg0);
}

rustapp*:::process-data-end {
    printf("Elementos processados: %d\n", arg0);
}
```

Execute o programa com o DTrace:

```bash
sudo dtrace -q -s profile.d -c "./target/debug/seu_programa"
```

Saída esperada:

```
Iniciando processamento: tamanho=5
Elementos processados: 3
Processed 3 elements
```

### Erro Comum e Correção

Se você esquecer de compilar com debuginfo, o DTrace falhará silenciosamente. O erro típico é:

```
dtrace: failed to compile script profile.d: line 1: probe description rustapp*:::process-data-start does not match any probes
```

Solução: adicione ao `Cargo.toml`:

```toml
[profile.release]
debug = true
```

### Analisando Desempenho com DTrace

Para medir tempo de execução:

```d
rustapp*:::process-data-start {
    self->start = timestamp;
}

rustapp*:::process-data-end {
    printf("Tempo de execução: %d ns\n", timestamp - self->start);
}
```

Saída avançada:

```
Tempo de execução: 1582 ns
Processed 3 elements
```

### Comparando com Outras Ferramentas

Enquanto o `perf` (visto anteriormente) foca em amostragem estatística, o DTrace oferece:

1. **Baixo overhead**: Instrumentação direta sem recompilação
2. **Precisão temporal**: Nanossegundos em chamadas específicas
3. **Contexto completo**: Acesso a argumentos e estado do programa

### Exercício Prático

Instrumente esta função para medir:
1. Tempo total de execução
2. Número de chamadas
3. Tamanho médio dos dados processados

```rust
fn analyze_buffer(buf: &[u8]) -> u8 {
    buf.iter().fold(0, |acc, &x| acc.wrapping_add(x))
}
```

**Solução:**

```rust
use dtrace::Probe;

fn analyze_buffer(buf: &[u8]) -> u8 {
    dtrace::probe!("rustapp", "analyze-start", buf.len());
    let start = std::time::Instant::now();
    
    let result = buf.iter().fold(0, |acc, &x| acc.wrapping_add(x));
    
    dtrace::probe!("rustapp", "analyze-end", 
        start.elapsed().as_nanos() as u64,
        buf.len()
    );
    result
}
```

Script DTrace correspondente:

```d
rustapp*:::analyze-start {
    @calls[pid] = count();
    @avg_size[pid] = avg(arg0);
}

rustapp*:::analyze-end {
    @time[pid] = quantize(arg0);
}
```

Execute com:

```bash
sudo dtrace -q -s analyze.d -c "./target/debug/seu_programa"
```