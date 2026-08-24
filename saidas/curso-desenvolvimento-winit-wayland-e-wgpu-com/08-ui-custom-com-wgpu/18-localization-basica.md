## Localization Básica

Uma aplicação gráfica precisa falar a língua do usuário, mas sistemas de internacionalização complexos são excessivos para interfaces customizadas. O problema aparece quando você tem strings fixas no código ("Login", "Save") que precisam variar conforme o idioma, sem sacrificar performance ou adicionar dependências pesadas.

A solução mínima em Rust usa enums para chaves de tradução e hash maps para armazenar os textos. Veja como implementar:

```rust
// Defina um enum com todas as strings traduzíveis
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum LocaleKey {
    LoginButton,
    SaveButton,
    WindowTitle,
}

// Estrutura que armazenará as traduções
pub struct Localization {
    strings: HashMap<LocaleKey, String>,
    current_lang: String,
}

impl Localization {
    pub fn new(lang: &str) -> Self {
        let mut strings = HashMap::new();
        
        // Carrega as strings para o idioma especificado
        match lang {
            "pt_BR" => {
                strings.insert(LocaleKey::LoginButton, "Entrar".to_string());
                strings.insert(LocaleKey::SaveButton, "Salvar".to_string());
                strings.insert(LocaleKey::WindowTitle, "Aplicação".to_string());
            },
            "en_US" => {
                strings.insert(LocaleKey::LoginButton, "Login".to_string());
                strings.insert(LocaleKey::SaveButton, "Save".to_string());
                strings.insert(LocaleKey::WindowTitle, "Application".to_string());
            },
            _ => panic!("Idioma não suportado: {}", lang),
        }

        Self {
            strings,
            current_lang: lang.to_string(),
        }
    }

    pub fn get(&self, key: LocaleKey) -> &str {
        self.strings.get(&key).unwrap()
    }
}
```

Erro comum: esquecer de lidar com chaves ausentes. Se alguém adicionar um novo `LocaleKey` mas esquecer de incluí-lo nas traduções, o `.unwrap()` causará um panic. A solução é usar um método mais seguro:

```rust
pub fn get(&self, key: LocaleKey) -> &str {
    self.strings.get(&key).unwrap_or_else(|| {
        eprintln!("AVISO: String de localização faltando para {:?} (idioma: {})", key, self.current_lang);
        "MISSING_TEXT"
    })
}
```

Para integrar com a UI, crie uma instância global (usando `OnceCell` ou `Lazy` do std) e acesse onde precisar renderizar texto:

```rust
use std::sync::OnceLock;

static LOCALE: OnceLock<Localization> = OnceLock::new();

fn init_app() {
    // Detecta o idioma do sistema ou usa padrão
    let lang = detect_system_language().unwrap_or("en_US");
    LOCALE.set(Localization::new(lang)).unwrap();
}

fn render_login_button() {
    let locale = LOCALE.get().unwrap();
    draw_button(locale.get(LocaleKey::LoginButton));
}
```

Para textos dinâmicos com parâmetros (como "Bem-vindo, {}!"), use formatadores:

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum LocaleKey {
    WelcomeMessage,
    // ...
}

impl Localization {
    // ...
    pub fn format(&self, key: LocaleKey, args: &[&str]) -> String {
        let template = self.get(key);
        let mut result = template.to_string();
        
        for (i, arg) in args.iter().enumerate() {
            result = result.replace(&format!("{{{}}}", i), arg);
        }
        
        result
    }
}

// Uso:
let message = locale.format(LocaleKey::WelcomeMessage, &["João"]);
// "Bem-vindo, João!" ou "Welcome, João!"
```

O sistema de localização básico deve:
1. Ser inicializado no startup da aplicação
2. Usar enums para evitar strings mágicas
3. Ter fallback claro para textos ausentes
4. Suportar substituição de parâmetros
5. Não alocar memória desnecessariamente (por isso `&str` no `get`)

Exercício: Implemente um método `switch_language` que permite trocar o idioma em runtime, atualizando todas as strings na interface. Dica: você precisará de um `Arc<Mutex<Localization>>` e notificar os componentes UI sobre a mudança.

Solução comentada:

```rust
use std::sync::{Arc, Mutex};

// Versão thread-safe do Localization
pub struct SharedLocalization {
    inner: Arc<Mutex<Localization>>,
}

impl SharedLocalization {
    pub fn new(lang: &str) -> Self {
        Self {
            inner: Arc::new(Mutex::new(Localization::new(lang))),
        }
    }

    pub fn switch_language(&self, new_lang: &str) {
        let mut lock = self.inner.lock().unwrap();
        *lock = Localization::new(new_lang);
        // Em um sistema real, notificaria os widgets aqui
    }

    pub fn get(&self, key: LocaleKey) -> String {
        let lock = self.inner.lock().unwrap();
        lock.get(key).to_string()
    }
}
```