//! roadmapia — gera **roadmaps**, **cursos** ou **guias** a partir de um assunto,
//! refinando o pedido através de uma entrevista conduzida por IA (OpenRouter).
//!
//! O fluxo tem quatro telas, todas com comportamento em `<script>` Luau (ver `ui/`):
//!
//! 1. **`inicio`**  — o assunto, o tipo de artefato (roadmap / curso / guia) e as
//!    credenciais. O botão "Refinar" NÃO submete: ele pede à IA um questionário
//!    sob medida para aquele assunto e navega para a entrevista.
//! 2. **`perguntas`** — uma pergunta por vez; cada uma traz opções sugeridas pela
//!    IA (clicáveis, multi-seleção) **e** um campo livre. Dá para aprofundar
//!    (gerar mais perguntas a partir do que já foi respondido) e, no fim, gerar.
//! 3. **`revisao`** — a IA devolveu um esboço (capítulos e subcapítulos, só
//!    títulos e foco); esta tela deixa corrigi-lo — editar, apagar, reordenar,
//!    acrescentar — ANTES de qualquer trecho ser escrito de verdade e cobrado.
//! 4. **`producao`** — o plano confirmado vira centenas de trechos escritos em
//!    paralelo, um arquivo por trecho, com avanço e custo real na tela.
//!
//! Este arquivo é uma casca fina de propósito: registra as telas, carrega os
//! estilos e liga a configuração (`config.rs`) ao contexto do motor nas duas
//! direções — semeia a chave da API no arranque e persiste o que a tela mudar.
//! Toda a lógica vive nos `.luau` de `ui/`, que o motor recarrega a quente — dá
//! para reescrever um prompt ou um passo do fluxo com o app aberto, sem
//! recompilar.
//!
//! `roadmapia --demo revisao` abre direto na revisão com um plano de exemplo
//! (o do curso de contabilidade tributária em `saidas/`) e a conferência de
//! repetições já aplicada — para ver e ajustar essa tela sem pagar a
//! entrevista e o esboço que normalmente vêm antes dela.

mod checar;
mod config;

use crate::config::{persistir_config, semear_config, semear_dir_saidas, telas, ui};
use checar::checar;
use glacier_ui::{GlacierDaemon, style};

fn main() -> std::process::ExitCode {
    if std::env::args().any(|a| a == "--check") {
        return checar();
    }
    let demo = match demo_pedida() {
        Ok(d) => d,
        Err(msg) => {
            eprintln!("{msg}");
            return std::process::ExitCode::FAILURE;
        }
    };

    let saida = GlacierDaemon::new()
        .title(if demo.is_some() {
            "roadmapia — demo"
        } else {
            "roadmapia"
        })
        .main_size(1040.0, 780.0)
        .main(move |motor| {
            if let Err(e) = motor.set_style(&style::PHANTOM) {
                eprintln!("estilo: {e}");
            }
            // O `.gss` é carregado daqui (e não por `link(rel = stylesheet)`) porque o
            // `href` de um link é resolvido contra o diretório de trabalho, e o app
            // precisa rodar de qualquer lugar — `ui_dir()` é quem sabe onde `ui/` está.
            if let Err(e) = motor.load_stylesheet(&ui("app.gss")) {
                eprintln!("estilos: {e}");
            }

            match demo {
                // Sem `semear_config`: sem chave, nenhuma chamada à IA sai da
                // demo nem por engano. E a pasta de saída é temporária, para o
                // rascunho que a revisão grava a cada edição não cobrir o
                // rascunho real.
                Some(tela) => {
                    let dir = std::env::temp_dir().join("roadmapia-demo");
                    let _ = std::fs::create_dir_all(&dir);
                    motor.define_data("dir_saidas", &dir.to_string_lossy());
                    // Antes do registro: o `init` de cada tela roda nele.
                    motor.define_data("demo", tela);
                }
                None => {
                    semear_config(motor);
                    semear_dir_saidas(motor);
                }
            }

            for (nome, arquivo) in telas() {
                if let Err(e) = motor.register_component(nome, &ui(arquivo)) {
                    eprintln!("Erro ao registrar '{nome}': {e}");
                }
            }
            motor.set_initial_screen(demo.unwrap_or(telas()[0].0));
        })
        .on_message(move |_, motor| {
            // A demo não tem chave para persistir, e não deve gravar nada no
            // `.ini` de verdade.
            if demo.is_none() {
                persistir_config(motor)
            }
        })
        .run();

    match saida {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("{e}");
            std::process::ExitCode::FAILURE
        }
    }
}

/// As telas que `--demo` sabe abrir sem chamar a IA.
const DEMOS: &[&str] = &["revisao"];

/// `--demo <tela>` → `Some(tela)`; sem `--demo` → `None`. Uma tela que não
/// tem demo é erro, e não um app aberto normalmente: quem pediu a demo não
/// quer gastar créditos por ter errado o nome.
fn demo_pedida() -> Result<Option<&'static str>, String> {
    let args: Vec<String> = std::env::args().collect();
    let Some(i) = args.iter().position(|a| a == "--demo") else {
        return Ok(None);
    };
    let tela = args.get(i + 1).map(String::as_str).unwrap_or("");
    DEMOS
        .iter()
        .find(|d| **d == tela)
        .map(|d| Some(*d))
        .ok_or_else(|| {
            format!(
                "--demo precisa de uma destas telas: {} (ex.: roadmapia --demo revisao)",
                DEMOS.join(", ")
            )
        })
}
