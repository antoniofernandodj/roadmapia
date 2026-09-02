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

mod config;
mod checar;

use checar::checar;
use glacier_ui::{GlacierDaemon, style};
use crate::config::{persistir_config, semear_config, telas, ui};


fn main() -> std::process::ExitCode {
    if std::env::args().any(|a| a == "--check") {
        return checar();
    }

    let saida = GlacierDaemon::new()
        .title("roadmapia")
        .main_size(1040.0, 780.0)
        .main(|motor| {
            if let Err(e) = motor.set_style(&style::PHANTOM) {
                eprintln!("estilo: {e}");
            }
            // O `.gss` é carregado daqui (e não por `<link rel="stylesheet">`) porque o
            // `href` de um link é resolvido contra o diretório de trabalho, e o app
            // precisa rodar de qualquer lugar — `ui_dir()` é quem sabe onde `ui/` está.
            if let Err(e) = motor.load_stylesheet(&ui("app.gss")) {
                eprintln!("estilos: {e}");
            }

            semear_config(motor);

            for (nome, arquivo) in telas() {
                if let Err(e) = motor.register_component(nome, &ui(arquivo)) {
                    eprintln!("Erro ao registrar '{nome}': {e}");
                }
            }
            motor.set_initial_screen(telas()[0].0);
        })
        .on_message(|_, motor| persistir_config(motor))
        .run();

    match saida {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("{e}");
            std::process::ExitCode::FAILURE
        }
    }
}
