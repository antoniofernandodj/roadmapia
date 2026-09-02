//! Configuração em `.ini` — o lugar onde a chave da API mora.
//!
//! Antes a chave tinha dois donos e nenhum bom: a variável de ambiente
//! `OPENROUTER_API_KEY` (que some ao fechar o terminal) e o `storage` do
//! glacier, um JSON **por componente** enterrado em `ui/.glacier-storage/` —
//! invisível para quem instala o app e impossível de editar à mão sem saber
//! que existe.
//!
//! Agora existe um arquivo, e ele **vence o ambiente**: quem escreveu uma
//! chave em disco quis aquela chave, e um `export` esquecido numa sessão
//! antiga não deve sequestrá-la em silêncio.
//!
//! ## Onde
//!
//! Na leitura, o primeiro que **existir**; na escrita, esse mesmo (ou, se
//! nenhum existe ainda, `$ROADMAPIA_CONFIG` se estiver setado, senão o do
//! usuário, criando os diretórios que faltarem):
//!
//! 1. `$ROADMAPIA_CONFIG` — caminho explícito, para testar uma chave sem
//!    encostar na de verdade.
//! 2. `./roadmapia.ini` — ao lado de onde o app rodou; é o de dev.
//! 3. O diretório de configuração do usuário, que **depende do sistema**:
//!
//!    | | |
//!    |---|---|
//!    | Unix | `$XDG_CONFIG_HOME/roadmapia/config.ini`, ou `~/.config/roadmapia/config.ini` |
//!    | Windows | `%APPDATA%\roadmapia\config.ini` (o Roaming do perfil) |
//!
//!    Não é o XDG no Windows de propósito: `~/.config` lá é um diretório que
//!    nenhuma ferramenta do sistema conhece — nem o Explorer, nem o instalador,
//!    nem o backup do perfil. `%APPDATA%` é onde um app Windows guarda config.
//!
//! ## Formato
//!
//! ```ini
//! [openrouter]
//! api_key = sk-or-v1-...
//! modelo  = anthropic/claude-sonnet-4.5
//! ```
//!
//! Seções em `[colchetes]`, `chave = valor`, comentários em `#` ou `;`. O
//! valor é a linha inteira depois do `=`, com os espaços das pontas tirados e
//! um par de aspas removido se houver — **não** há comentário no fim da linha,
//! de propósito: um `#` no meio de um segredo é caractere, não comentário.
//!
//! ## Escrita cirúrgica
//!
//! [`Config::set`] reescreve **a linha** daquela chave e deixa o resto do
//! arquivo em paz — comentários, ordem, espaçamento e qualquer seção que este
//! app não conheça. É o que separa um arquivo de configuração de um despejo de
//! estado: quem anotou "# a chave do trabalho, expira em março" ao lado da
//! chave ainda encontra a anotação lá depois de trocá-la pela tela.

use std::io;
use std::path::{Path, PathBuf};
use glacier_ui::GlacierUI;

/// O arquivo `.ini` carregado: as linhas cruas (para reescrever preservando o
/// que não é nosso) e o caminho de onde vieram — ou para onde vão.
pub struct Config {
    /// Onde este arquivo mora. Existe mesmo quando o arquivo ainda não.
    destino: PathBuf,
    /// As linhas do arquivo, sem terminador. Vazio se ele não existe.
    linhas: Vec<String>,
    /// `true` se o arquivo estava lá na hora de carregar.
    existia: bool,
    /// O terminador de linha que o arquivo usava. Um `.ini` editado no Notepad
    /// vem em CRLF, e reescrevê-lo em LF marcaria TODAS as linhas como
    /// alteradas — num arquivo versionado, um diff inteiro para uma chave.
    /// Arquivo novo nasce no terminador nativo do sistema.
    fim_de_linha: &'static str,
}

impl Config {
    /// Carrega o primeiro arquivo da cadeia que existir. Um arquivo ausente
    /// **não** é erro: dá uma config vazia que já sabe onde se gravar.
    ///
    /// Erro de leitura (permissão, por exemplo) também não derruba o app — a
    /// chave ainda pode vir do ambiente ou da tela. Quem chama decide se
    /// avisa; devolvemos o motivo junto.
    pub fn carregar() -> (Self, Option<io::Error>) {
        for caminho in candidatos() {
            if !caminho.is_file() {
                continue;
            }
            return match std::fs::read_to_string(&caminho) {
                Ok(texto) => (
                    Self {
                        fim_de_linha: if texto.contains("\r\n") { "\r\n" } else { "\n" },
                        destino: caminho,
                        linhas: texto.lines().map(str::to_owned).collect(),
                        existia: true,
                    },
                    None,
                ),
                Err(e) => (Self::vazia(caminho), Some(e)),
            };
        }
        // Nenhum existe: o destino de escrita é o explícito, se houver, senão
        // o do usuário (`~/.config` ou `%APPDATA%`) — nunca o `./roadmapia.ini`,
        // que criaria um arquivo com segredo no diretório de trabalho de quem só
        // abriu o app.
        let destino = std::env::var_os("ROADMAPIA_CONFIG")
            .map(PathBuf::from)
            .unwrap_or_else(caminho_do_usuario);
        (Self::vazia(destino), None)
    }

    fn vazia(destino: PathBuf) -> Self {
        Self {
            destino,
            linhas: Vec::new(),
            existia: false,
            fim_de_linha: if cfg!(windows) { "\r\n" } else { "\n" },
        }
    }

    /// O caminho do arquivo — o que existe, ou o que seria criado.
    pub fn caminho(&self) -> &Path {
        &self.destino
    }

    /// `true` se o arquivo estava em disco quando foi carregado.
    pub fn existe(&self) -> bool {
        self.existia
    }

    /// O valor de `chave` na seção `secao`, se houver — vazio conta como
    /// ausente, porque `api_key =` sem nada à direita é uma linha esquecida,
    /// não uma chave.
    pub fn get(&self, secao: &str, chave: &str) -> Option<String> {
        let mut atual = "";
        for linha in &self.linhas {
            match classificar(linha) {
                Linha::Secao(nome) => atual = nome,
                Linha::Par(k, v) if atual == secao && k == chave => {
                    let v = limpar_valor(v);
                    return (!v.is_empty()).then(|| v.to_owned());
                }
                _ => {}
            }
        }
        None
    }

    /// Grava `chave = valor` na seção `secao` e persiste o arquivo inteiro.
    ///
    /// Só toca a linha daquela chave; cria a seção no fim se ela não existir, e
    /// insere a chave no fim da seção certa se a seção existir sem ela. Não faz
    /// nada (nem escreve) se o valor já é esse — trocar de tela não precisa
    /// bater no disco.
    pub fn set(&mut self, secao: &str, chave: &str, valor: &str) -> io::Result<()> {
        if self.get(secao, chave).as_deref().unwrap_or("") == valor {
            return Ok(());
        }
        let nova = format!("{chave} = {valor}");

        // Onde a linha entra: substituindo a que existe, ou no fim da seção —
        // antes das linhas em branco que a separam da próxima, para a chave
        // nova não pousar depois de um parágrafo vazio.
        let mut atual = "";
        let mut fim_da_secao = None;
        let mut substituir = None;
        for (i, linha) in self.linhas.iter().enumerate() {
            match classificar(linha) {
                Linha::Secao(nome) => {
                    if atual == secao && fim_da_secao.is_none() {
                        fim_da_secao = Some(recuar_vazias(&self.linhas, i));
                    }
                    atual = nome;
                }
                Linha::Par(k, _) if atual == secao && k == chave => {
                    substituir = Some(i);
                    break;
                }
                _ => {}
            }
        }

        match substituir {
            Some(i) => self.linhas[i] = nova,
            None => match fim_da_secao.or_else(|| {
                (atual == secao).then(|| recuar_vazias(&self.linhas, self.linhas.len()))
            }) {
                Some(i) => self.linhas.insert(i, nova),
                None => {
                    if !self.linhas.is_empty() {
                        self.linhas.push(String::new());
                    }
                    self.linhas.push(format!("[{secao}]"));
                    self.linhas.push(nova);
                }
            },
        }
        self.gravar()
    }

    /// Escreve as linhas em disco, criando os diretórios que faltarem.
    ///
    /// No Unix o arquivo guarda um segredo, então nasce `0600` (só o dono lê)
    /// em vez do padrão do `umask`, que costuma deixar o grupo ler. A permissão
    /// é reaplicada a cada escrita: um arquivo criado à mão pode estar aberto, e
    /// a próxima troca de chave pela tela o fecha.
    ///
    /// No Windows não há equivalente barato: a ACL do arquivo é herdada do
    /// diretório, e `%APPDATA%` já concede só ao dono do perfil. Um `chmod` de
    /// mentira (`set_readonly`) marcaria o arquivo como somente-leitura para
    /// TODO mundo, inclusive para a próxima gravação — pioraria sem proteger.
    fn gravar(&self) -> io::Result<()> {
        if let Some(pai) = self.destino.parent() {
            std::fs::create_dir_all(pai)?;
        }
        let mut texto = self.linhas.join(self.fim_de_linha);
        texto.push_str(self.fim_de_linha);
        std::fs::write(&self.destino, texto)?;
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            std::fs::set_permissions(&self.destino, std::fs::Permissions::from_mode(0o600))?;
        }
        Ok(())
    }
}

/// Os caminhos onde um `config.ini` pode estar, do mais específico ao mais
/// geral. Ver o cabeçalho do módulo.
fn candidatos() -> Vec<PathBuf> {
    let mut v = Vec::with_capacity(3);
    if let Some(p) = std::env::var_os("ROADMAPIA_CONFIG") {
        v.push(PathBuf::from(p));
    }
    v.push(PathBuf::from("roadmapia.ini"));
    v.push(caminho_do_usuario());
    v
}

/// O `config.ini` no diretório de configuração do usuário.
///
/// Nos dois sistemas o último recurso é um caminho RELATIVO em vez de um
/// `panic`: um app gráfico que não abre porque não achou `%APPDATA%` é pior que
/// um que abre e grava a config ao lado de si.
fn caminho_do_usuario() -> PathBuf {
    base_de_config().join("roadmapia").join("config.ini")
}

/// Unix: `$XDG_CONFIG_HOME`, senão `~/.config` (o padrão do XDG).
#[cfg(unix)]
fn base_de_config() -> PathBuf {
    std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .filter(|p| p.is_absolute())
        .or_else(|| std::env::var_os("HOME").map(|h| PathBuf::from(h).join(".config")))
        .unwrap_or_else(|| PathBuf::from(".config"))
}

/// Windows: `%APPDATA%` (o Roaming do perfil), com `%USERPROFILE%` como rede de
/// segurança para os ambientes onde `APPDATA` não está no processo — serviço,
/// shell enxuto, um CI.
#[cfg(windows)]
fn base_de_config() -> PathBuf {
    std::env::var_os("APPDATA")
        .map(PathBuf::from)
        .filter(|p| p.is_absolute())
        .or_else(|| {
            std::env::var_os("USERPROFILE")
                .map(|h| PathBuf::from(h).join("AppData").join("Roaming"))
        })
        .unwrap_or_else(|| PathBuf::from("."))
}

/// O que uma linha do `.ini` é.
enum Linha<'a> {
    Secao(&'a str),
    Par(&'a str, &'a str),
    Outra,
}

fn classificar(linha: &str) -> Linha<'_> {
    let t = linha.trim();
    if t.is_empty() || t.starts_with('#') || t.starts_with(';') {
        return Linha::Outra;
    }
    if let Some(nome) = t.strip_prefix('[').and_then(|s| s.strip_suffix(']')) {
        return Linha::Secao(nome.trim());
    }
    match t.split_once('=') {
        Some((k, v)) => Linha::Par(k.trim(), v),
        None => Linha::Outra,
    }
}

/// O valor de um par: espaços fora, e um par de aspas fora se envolver tudo.
fn limpar_valor(v: &str) -> &str {
    let v = v.trim();
    for aspas in ['"', '\''] {
        if v.len() >= 2 && v.starts_with(aspas) && v.ends_with(aspas) {
            return &v[1..v.len() - 1];
        }
    }
    v
}

/// Anda para trás a partir de `fim` pulando linhas em branco — o ponto onde uma
/// chave nova pertence à seção que acabou, e não ao vazio antes da próxima.
fn recuar_vazias(linhas: &[String], fim: usize) -> usize {
    let mut i = fim;
    while i > 0 && linhas[i - 1].trim().is_empty() {
        i -= 1;
    }
    i
}

/// A seção do `.ini` onde as credenciais e o modelo moram.
pub fn secao() -> &'static str {
    "openrouter"
}

/// As quatro telas, na ordem de registro. A primeira é a inicial.
pub fn telas() -> [(&'static str, &'static str); 4] {
    [
        ("inicio", "inicio.gv"),
        ("perguntas", "perguntas.gv"),
        ("revisao", "revisao.gv"),
        ("producao", "producao.gv"),
    ]
}


/// Diretório que contém os templates (`ui/`), procurado nesta ordem:
///
/// 1. `$ROADMAPIA_UI` — override explícito.
/// 2. `./ui` — rodando da raiz do projeto.
/// 3. `<dir do executável>/ui` — o **pacote portátil**: o .zip do Windows e o
///    .tar.gz do Linux levam o `ui/` ao lado do binário. Não dá para depender
///    do item 2 aqui: o duplo-clique no Explorer entra na pasta do .exe, mas um
///    atalho no menu Iniciar pode ter qualquer "Iniciar em".
/// 4. `<dir do executável>/../share/roadmapia/ui` — o layout FHS de um `.deb`:
///    `/usr/bin/roadmapia` acha `/usr/share/roadmapia/ui`.
/// 5. O `ui/` ao lado do `Cargo.toml` — dev, rodando de qualquer lugar. É o
///    único que some no destino: `CARGO_MANIFEST_DIR` é o caminho da máquina
///    que COMPILOU, então ele só existe aqui. Por isso os itens 3 e 4 —
///    sem eles um pacote instalado abre sem tela nenhuma.
pub fn ui_dir() -> PathBuf {
    if let Ok(d) = std::env::var("ROADMAPIA_UI") {
        return PathBuf::from(d);
    }
    let cwd = PathBuf::from("ui");
    if cwd.is_dir() {
        return cwd;
    }
    if let Some(base) = std::env::current_exe()
        .ok()
        .and_then(|e| e.parent().map(PathBuf::from)) {
            let ao_lado = base.join("ui");
            if ao_lado.is_dir() {
                return ao_lado;
            }
            let fhs = base
                .join("..")
                .join("share")
                .join("roadmapia")
                .join("ui");

            if fhs.is_dir() {
                return fhs;
            }
        }
        PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("ui")
}

/// `ui/<arquivo>` como string — os caminhos que o motor guarda para hot-reload.
pub fn ui(file: &str) -> String {
    ui_dir().join(file).to_string_lossy().into_owned()
}

/// Semeia `api_key` e `modelo` no contexto, na ordem de precedência.
///
/// **`.ini` > ambiente > nada.** O arquivo vence a variável porque escrever uma
/// chave em disco é um ato deliberado, e um `export OPENROUTER_API_KEY`
/// esquecido numa sessão antiga não deve sequestrá-la sem dizer nada. Quem quer
/// o inverso apaga a linha do arquivo — ou aponta `$ROADMAPIA_CONFIG` para
/// outro.
///
/// `api_key_origem` (`"ini"` / `"ambiente"` / `""`) e `config_arquivo` existem
/// só para a tela poder DIZER de onde a chave veio: a diferença entre as duas
/// origens é invisível no campo, e "por que ele está usando a chave errada?" é
/// uma pergunta cara de responder sem essa linha na interface.
pub fn semear_config(motor: &mut GlacierUI) {
    let (cfg, erro) = Config::carregar();
    if let Some(e) = erro {
        eprintln!("config: não deu para ler {}: {e}", cfg.caminho().display());
    }

    let do_ambiente = std::env::var("OPENROUTER_API_KEY")
        .ok()
        .map(|k| k.trim().to_owned())
        .filter(|k| !k.is_empty());

    let (chave, origem) = match (cfg.get(secao(), "api_key"), do_ambiente) {
        (Some(k), _) => (k, "ini"),
        (None, Some(k)) => (k, "ambiente"),
        (None, None) => (String::new(), ""),
    };
    motor.define_data("api_key", &chave);
    motor.define_data("api_key_origem", origem);
    motor.define_data("config_arquivo", &cfg.caminho().display().to_string());

    // O modelo não tem equivalente no ambiente: ou está no arquivo, ou o Luau
    // aplica o padrão do `lib/openrouter`. Semear vazio aqui apagaria o padrão,
    // então só definimos quando há valor.
    if let Some(m) = cfg.get(secao(), "modelo") {
        motor.define_data("modelo", &m);
    }
}

/// Persiste no `.ini` o que a tela mudou — o gancho de `on_message`, que o
/// motor chama DEPOIS de cada despacho, com o estado já novo.
///
/// A camada Luau não tem I/O de arquivo além de `write_file`, e reescrever o
/// `.ini` de lá significaria serializá-lo inteiro a cada tecla, perdendo os
/// comentários de quem o editou à mão. Então o script só mexe no contexto e o
/// dono do arquivo é este lado. `Config::set` não escreve quando o valor não
/// mudou, então navegar entre telas não bate no disco.
pub fn persistir_config(motor: &GlacierUI) {
    let mut cfg = match Config::carregar() {
        (cfg, None) => cfg,
        (cfg, Some(e)) => {
            eprintln!("config: não deu para ler {}: {e}", cfg.caminho().display());
            return;
        }
    };

    for chave in ["api_key", "modelo"] {
        let Some(valor) = motor.get_data(chave) else {
            continue;
        };
        // Contexto vazio não apaga o arquivo: um `ctx.api_key = ""` (a tela
        // recém-aberta, um campo limpo sem querer) escreveria por cima de uma
        // chave boa. Apagar é editar o arquivo.
        if valor.is_empty() {
            continue;
        }
        if let Err(e) = cfg.set(secao(), chave, valor) {
            eprintln!("config: não deu para gravar {}: {e}", cfg.caminho().display());
            return;
        }
    }
}
