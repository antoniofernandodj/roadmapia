## Crash Reporting

Quando sua aplicação gráfica trava no meio de um frame complexo, descobrir o que deu errado pode ser como procurar uma agulha em um palheiro. O problema pode estar em um shader malformado, um buffer que estourou seus limites, ou até mesmo em um driver de GPU bugado. Rust nos dá segurança contra muitos tipos de erro, mas em aplicações gráficas, ainda precisamos lidar com:

1. Panics do Rust que escapam do thread principal
2. Erros de validação do WGPU
3. Falhas do driver gráfico (que muitas vezes matam o processo sem mensagem)
4. Crashes no Wayland compositor

Vamos implementar um sistema mínimo que captura informações úteis antes do crash e as salva em um arquivo local, sem depender de serviços externos.

### Capturando Panics do Rust

O mecanismo básico é substituir o hook padrão de panics do Rust. Isso nos permite interceptar o erro antes que ele encerre o processo:

```rust
use std::panic;
use std::fs::File;
use std::io::Write;

fn setup_panic_hook() {
    panic::set_hook(Box::new(|panic_info| {
        let mut crash_file = File::create("crash_report.txt").unwrap();
        
        writeln!(&mut crash_file, "=== CRASH REPORT ===").unwrap();
        writeln!(&mut crash_file, "Panic occurred:").unwrap();
        
        if let Some(s) = panic_info.payload().downcast_ref::<&str>() {
            writeln!(&mut crash_file, "Message: {}", s).unwrap();
        }

        if let Some(location) = panic_info.location() {
            writeln!(&mut crash_file, "Location: {}:{}", 
                location.file(), 
                location.line()
            ).unwrap();
        }

        // Backtrace só funciona com RUST_BACKTRACE=1
        writeln!(&mut crash_file, "{:?}", backtrace::Backtrace::new()).unwrap();
    }));
}
```

Testando com um panic intencional:

```rust
fn main() {
    setup_panic_hook();
    
    // Simula um crash
    panic!("Erro de teste no shader");
}
```

O arquivo `crash_report.txt` conterá:

```
=== CRASH REPORT ===
Panic occurred:
Message: Erro de teste no shader
Location: src/main.rs:42
Backtrace: [stack trace completo]
```

### Erros do WGPU

O WGPU tem seu próprio sistema de validação que pode capturar erros antes que eles causem um crash. Podemos configurar um callback:

```rust
let instance = wgpu::Instance::new(wgpu::Backends::all());
instance.push_error_scope(wgpu::ErrorFilter::Validation);

// Em algum lugar após a configuração
if let Some(err) = instance.pop_error_scope().block_on() {
    let mut file = File::create("wgpu_error.txt").unwrap();
    writeln!(&mut file, "WGPU Validation Error: {:?}", err).unwrap();
    
    // Opcional: tentar continuar em modo degradado
    log::error!("Erro WGPU: {}", err);
}
```

Isso capturaria erros como:
- Bind group layouts incompatíveis
- Texturas com formatos não suportados
- Pipelines com estados inválidos

### Wayland Connection Errors

Em aplicações Wayland, a conexão com o compositor pode falhar silenciosamente. Precisamos monitorar a conexão:

```rust
use wayland_client::{Display, EventQueue};

fn setup_wayland_monitoring(display: &Display, queue: &EventQueue) {
    std::thread::spawn(move || {
        if let Err(e) = queue.dispatch() {
            let mut file = File::create("wayland_crash.txt").unwrap();
            writeln!(&mut file, "Wayland connection lost: {:?}", e).unwrap();
            std::process::abort();
        }
    });
}
```

### Erro Comum e Correção

Um erro frequente é esquecer de chamar `poll` após `map_async` no WGPU:

```rust
buffer.slice(..).map_async(wgpu::MapMode::Read, |result| {
    // Esquecer de lidar com o resultado causa crash silencioso
});

// Correção:
if let Some(err) = buffer.slice(..).map_async(wgpu::MapMode::Read, |result| {
    if let Err(e) = result {
        log::error!("Falha no mapeamento: {}", e);
    }
}).block_on() {
    log::error!("Erro imediato: {}", err);
}
buffer.slice(..).get_mapped_range(); // Só funciona após poll
```

### Exercício Prático

Implemente um sistema que:
1. Capture panics do Rust
2. Registre erros do WGPU
3. Monitore a conexão Wayland
4. Salve tudo em um arquivo com timestamp

Solução comentada:

```rust
use std::time::SystemTime;
use std::fmt::Write;

struct CrashReporter {
    log_file: String,
}

impl CrashReporter {
    fn new() -> Self {
        let timestamp = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap()
            .as_secs();
            
        Self {
            log_file: format!("crash_{}.log", timestamp),
        }
    }
    
    fn setup(&self) {
        self.setup_panic_hook();
    }
    
    fn setup_panic_hook(&self) {
        let log_file = self.log_file.clone();
        panic::set_hook(Box::new(move |info| {
            let mut file = File::create(&log_file).unwrap();
            writeln!(&mut file, "[PANIC]").unwrap();
            // Restante do panic hook...
        }));
    }
    
    fn log_wgpu_error(&self, err: wgpu::Error) {
        let mut file = OpenOptions::new()
            .append(true)
            .create(true)
            .open(&self.log_file)
            .unwrap();
            
        writeln!(&mut file, "[WGPU] {:?}", err).unwrap();
    }
}
```