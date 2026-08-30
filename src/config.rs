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
//! nenhum existe ainda, `$ROADMAPIA_CONFIG` se estiver setado, senão o XDG,
//! criando os diretórios que faltarem):
//!
//! 1. `$ROADMAPIA_CONFIG` — caminho explícito, para testar uma chave sem
//!    encostar na de verdade.
//! 2. `./roadmapia.ini` — ao lado de onde o app rodou; é o de dev.
//! 3. `$XDG_CONFIG_HOME/roadmapia/config.ini`, ou `~/.config/roadmapia/config.ini`.
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

/// O arquivo `.ini` carregado: as linhas cruas (para reescrever preservando o
/// que não é nosso) e o caminho de onde vieram — ou para onde vão.
pub struct Config {
    /// Onde este arquivo mora. Existe mesmo quando o arquivo ainda não.
    destino: PathBuf,
    /// As linhas do arquivo, sem terminador. Vazio se ele não existe.
    linhas: Vec<String>,
    /// `true` se o arquivo estava lá na hora de carregar.
    existia: bool,
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
        // o XDG — nunca o `./roadmapia.ini`, que criaria um arquivo com
        // segredo no diretório de trabalho de quem só abriu o app.
        let destino = std::env::var_os("ROADMAPIA_CONFIG")
            .map(PathBuf::from)
            .unwrap_or_else(caminho_xdg);
        (Self::vazia(destino), None)
    }

    fn vazia(destino: PathBuf) -> Self {
        Self {
            destino,
            linhas: Vec::new(),
            existia: false,
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
    /// O arquivo guarda um segredo, então nasce `0600` (só o dono lê) em vez
    /// do padrão do `umask`, que costuma deixar o grupo ler. Reaplicamos a
    /// permissão a cada escrita: um arquivo criado à mão antes desta versão
    /// pode estar aberto, e a próxima troca de chave pela tela o fecha.
    fn gravar(&self) -> io::Result<()> {
        if let Some(pai) = self.destino.parent() {
            std::fs::create_dir_all(pai)?;
        }
        let mut texto = self.linhas.join("\n");
        texto.push('\n');
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
    v.push(caminho_xdg());
    v
}

/// `$XDG_CONFIG_HOME/roadmapia/config.ini`, com o fallback do padrão XDG
/// (`~/.config`). Sem `HOME`, cai num caminho relativo — melhor que entrar em
/// pânico num app gráfico.
fn caminho_xdg() -> PathBuf {
    let base = std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .filter(|p| p.is_absolute())
        .or_else(|| std::env::var_os("HOME").map(|h| PathBuf::from(h).join(".config")))
        .unwrap_or_else(|| PathBuf::from(".config"));
    base.join("roadmapia").join("config.ini")
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
