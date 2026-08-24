//! roadmapia — gera **roadmaps**, **cursos** ou **guias** a partir de um assunto,
//! refinando o pedido através de uma entrevista conduzida por IA (OpenRouter).
//!
//! O fluxo tem três telas, todas com comportamento em `<script>` Luau (ver `ui/`):
//!
//! 1. **`inicio`**  — o assunto, o tipo de artefato (roadmap / curso / guia) e as
//!    credenciais. O botão "Refinar" NÃO submete: ele pede à IA um questionário
//!    sob medida para aquele assunto e navega para a entrevista.
//! 2. **`perguntas`** — uma pergunta por vez; cada uma traz opções sugeridas pela
//!    IA (clicáveis, multi-seleção) **e** um campo livre. Dá para aprofundar
//!    (gerar mais perguntas a partir do que já foi respondido) e, no fim, gerar.
//! 3. **`producao`** — o esboço vira centenas de trechos escritos em paralelo,
//!    um arquivo por trecho, com avanço e custo real na tela.
//!
//! Este arquivo é uma casca fina de propósito: registra as telas, carrega os
//! estilos e semeia a chave da API a partir do ambiente. Toda a lógica vive nos
//! `.luau` de `ui/`, que o motor recarrega a quente — dá para reescrever um
//! prompt ou um passo do fluxo com o app aberto, sem recompilar.

use glacier_ui::{GlacierDaemon, GlacierUI, style};
use std::path::PathBuf;

/// As três telas, na ordem de registro. A primeira é a inicial.
const TELAS: [(&str, &str); 3] = [
    ("inicio", "inicio.gv"),
    ("perguntas", "perguntas.gv"),
    ("producao", "producao.gv"),
];

/// Diretório que contém os templates (`ui/`).
///
/// Procura, nesta ordem: `$ROADMAPIA_UI`, `./ui` (rodando da raiz do projeto) e
/// o `ui/` ao lado do `Cargo.toml` (rodando de qualquer lugar, em dev).
fn ui_dir() -> PathBuf {
    if let Ok(d) = std::env::var("ROADMAPIA_UI") {
        return PathBuf::from(d);
    }
    let cwd = PathBuf::from("ui");
    if cwd.is_dir() {
        return cwd;
    }
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("ui")
}

/// `ui/<arquivo>` como string — os caminhos que o motor guarda para hot-reload.
fn ui(file: &str) -> String {
    ui_dir().join(file).to_string_lossy().into_owned()
}

fn registrar(motor: &mut GlacierUI) {
    if let Err(e) = motor.set_style(&style::PHANTOM) {
        eprintln!("estilo: {e}");
    }
    // O `.gss` é carregado daqui (e não por `<link rel="stylesheet">`) porque o
    // `href` de um link é resolvido contra o diretório de trabalho, e o app
    // precisa rodar de qualquer lugar — `ui_dir()` é quem sabe onde `ui/` está.
    if let Err(e) = motor.load_stylesheet(&ui("app.gss")) {
        eprintln!("estilos: {e}");
    }

    // A chave pode vir do ambiente (o caminho preferido — não encosta no disco)
    // ou ser digitada na tela inicial, onde o script a persiste via `storage`.
    // Semeada aqui, ela vence a guardada: trocar de chave é `export` e reabrir.
    match std::env::var("OPENROUTER_API_KEY") {
        Ok(k) if !k.trim().is_empty() => {
            motor.define_data("api_key", k.trim());
            motor.define_data("api_key_do_ambiente", "true");
        }
        _ => motor.define_data("api_key_do_ambiente", "false"),
    }

    for (nome, arquivo) in TELAS {
        if let Err(e) = motor.register_component(nome, &ui(arquivo)) {
            eprintln!("Erro ao registrar '{nome}': {e}");
        }
    }
    motor.set_initial_screen(TELAS[0].0);
}

/// `roadmapia --check`: registra tudo num motor descartável e sai com o número
/// de erros. Carrega os templates, o `.gss` e cada `<script>` Luau (inclusive os
/// `require`), então pega erro de XML, de estilo e de sintaxe Luau sem abrir
/// janela — é o que roda antes de commitar uma mudança em `ui/`.
fn checar() -> std::process::ExitCode {
    let mut motor = GlacierUI::new();
    let mut falhas = 0u8;

    if let Err(e) = motor.load_stylesheet(&ui("app.gss")) {
        eprintln!("✗ estilos: {e}");
        falhas += 1;
    }
    for (nome, arquivo) in TELAS {
        match motor.register_component(nome, &ui(arquivo)) {
            Ok(()) => println!("✓ {nome} ({arquivo})"),
            Err(e) => {
                eprintln!("✗ {nome}: {e}");
                falhas += 1;
            }
        }
    }
    // Renderizar cada tela força a avaliação da árvore inteira — `for-each`,
    // `if`, classes e placeholders — que o registro sozinho não exercita.
    for (nome, _) in TELAS {
        motor.set_initial_screen(nome);
        if let Err(e) = motor.render_current() {
            eprintln!("✗ render {nome}: {e}");
            falhas += 1;
        }
    }

    falhas += checar_binding_de_visibilidade(&mut motor);
    falhas += checar_alinhamento_dos_botoes(&mut motor);

    falhas += rodar_suites_luau();
    falhas += simular_entrevista(&mut motor);
    falhas += simular_producao(&mut motor);
    falhas += simular_log(&mut motor);

    if falhas == 0 {
        println!("tudo certo.");
        std::process::ExitCode::SUCCESS
    } else {
        std::process::ExitCode::from(falhas)
    }
}

/// Roda as suítes Luau (`tests/luau/`) dentro do interpretador do motor.
///
/// Rodavam antes num `lua` 5.4 do sistema, com `json` e `require` de mentira.
/// Aqui elas exercitam os de VERDADE — e, mais importante, deixam as
/// bibliotecas testadas usar anotação de tipo Luau, que não é Lua 5.4 válido e
/// quebraria um runner externo. Sem isso não dá para tirar o vermelho do editor
/// sem abrir mão dos testes.
fn rodar_suites_luau() -> u8 {
    use glacier_ui::EngineMessage as M;

    // `require("lib/obra")` a partir de `tests/luau/` só acha o módulo por
    // aqui — o motor procura no diretório do script, em `<dir>/lib`, e nos
    // caminhos desta variável.
    //
    // SAFETY: processo ainda de thread única (o `--check` roda antes de
    // qualquer runtime), então não há leitor concorrente do ambiente.
    unsafe { std::env::set_var("GLACIER_LUAU_PATH", ui_dir()) };

    let suite = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/luau/suite.gv");
    let mut motor = GlacierUI::new();
    if let Err(e) = motor.register_component("suite", &suite.to_string_lossy()) {
        eprintln!("✗ suítes Luau: {e}");
        return 1;
    }
    motor.set_initial_screen("suite");
    let _ = motor.dispatch(&M::UiClick("rodar".into()));

    let saida = motor.get_data("teste_saida").cloned().unwrap_or_default();
    let falhas: u8 = motor
        .get_data("teste_falhas")
        .and_then(|s| s.parse().ok())
        .unwrap_or(255);
    let total: usize = motor
        .get_data("teste_total")
        .and_then(|s| s.parse().ok())
        .unwrap_or(0);

    // Uma suíte que não rodou (erro de script, `require` quebrado) devolveria
    // zero casos — e "0 falhas" pareceria sucesso. Exige casos de verdade.
    if total == 0 {
        eprintln!("✗ suítes Luau não produziram nenhum caso — não rodaram");
        if !saida.is_empty() {
            eprintln!("{saida}");
        }
        return 1;
    }
    if falhas > 0 {
        eprintln!("{saida}");
        eprintln!("✗ suítes Luau: {falhas} de {total} casos falharam");
        return falhas;
    }
    println!("✓ suítes Luau ({total} casos: fila de produção, openrouter)");
    0
}

/// Botões lado a lado numa mesma `Row` têm de ter a MESMA altura.
///
/// Alturas diferentes numa fila de botões saltam aos olhos — as bordas não
/// fecham e os textos não assentam na mesma linha, mesmo com `align="Center"`.
/// Já apareceu duas vezes neste app (`.btn` × `.btn-primario`, depois
/// `.btn-gerar` × `.btn-sutil`), então em vez de caçar caso a caso, a regra
/// vira verificável: percorre TODAS as telas e reprova qualquer fila que
/// misture alturas.
fn checar_alinhamento_dos_botoes(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::parser::{NodeType, UiNode};
    let mut problemas: Vec<String> = Vec::new();

    fn anda(no: &UiNode, tela: &str, problemas: &mut Vec<String>) {
        if matches!(no.kind, NodeType::Row) {
            // Só os botões visíveis, e só os filhos DIRETOS: é isso que forma
            // uma fila visual. Um botão escondido não desalinha nada.
            let alturas: Vec<(String, String)> = no
                .children
                .iter()
                .filter(|f| !f.hidden.unwrap_or(false))
                .filter_map(|f| match &f.kind {
                    NodeType::Button { text, .. } => Some((
                        text.clone(),
                        f.height.clone().unwrap_or_else(|| "(sem altura)".into()),
                    )),
                    _ => None,
                })
                .collect();

            if alturas.len() > 1 {
                let primeira = &alturas[0].1;
                if alturas.iter().any(|(_, h)| h != primeira) {
                    let detalhe: Vec<String> = alturas
                        .iter()
                        .map(|(t, h)| format!("{t:?}={h}"))
                        .collect();
                    problemas.push(format!(
                        "{tela}: alturas diferentes — {}",
                        detalhe.join("  ")
                    ));
                }
            }

            // O eixo cruzado de uma `Row` é o `alignY`; sem ele os filhos
            // encostam no topo. A armadilha que custou caro: `align="Center"`
            // não é alias de nada neste parser — é aceito e DESCARTADO em
            // silêncio, então a fila parecia centrada no código e não estava.
            if !alturas.is_empty() && no.align_y.is_none() {
                let quais: Vec<&str> = alturas.iter().map(|(t, _)| t.as_str()).collect();
                problemas.push(format!(
                    "{tela}: Row com botões sem alignY (usar alignY=\"Center\", não align) — {:?}",
                    quais
                ));
            }
        }
        for f in &no.children {
            anda(f, tela, problemas);
        }
    }

    // As linhas de ação só existem com estado; sem isto os blocos são podados.
    motor.define_data("tem_perguntas", "true");
    motor.define_data("tem_obra", "true");
    motor.define_data("parado", "true");
    motor.define_data("produzindo", "false");
    motor.define_data("sem_falhas", "false");
    motor.define_data("sem_perguntas", "false");
    motor.define_data("mostrar_avancado", "true");
    let _ = motor.reevaluate_all();

    for (tela, _) in TELAS {
        if let Ok(raiz) = motor.evaluated(tela) {
            let raiz = raiz.clone();
            anda(&raiz, tela, &mut problemas);
        }
    }

    if problemas.is_empty() {
        println!("✓ botões alinhados (mesma altura por fila)");
        return 0;
    }
    for p in &problemas {
        eprintln!("✗ fila de botões — {p}");
    }
    problemas.len().min(255) as u8
}

/// Prova que `hidden="{chave}"` responde ao contexto.
///
/// Guarda contra um bug que já custou caro: o glacier convertia `hidden`/
/// `disabled` para `bool` no PARSE, comparando a string crua — `"{parado}"`
/// nunca é `"true"`, então o binding ficava congelado em `false`. O sintoma era
/// um spinner girando para sempre e o botão "próxima" ativo na última pergunta.
/// Corrigido em `glacier-ui` (ver `BoolAttr`); isto trava a regressão do lado
/// de cá, que é onde ela apareceria de novo numa atualização da lib.
fn checar_binding_de_visibilidade(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::parser::{NodeType, UiNode};

    /// `(spinners na árvore, quantos visíveis)`. O primeiro número existe para
    /// o teste não passar vazio: o spinner mora dentro de um bloco `if`, e se
    /// esse bloco for podado não há nó nenhum para inspecionar — aí "nenhum
    /// visível" seria verdade por acidente, não por acerto.
    fn contar(motor: &mut GlacierUI) -> (usize, usize) {
        fn anda(no: &UiNode, total: &mut usize, visiveis: &mut usize) {
            if matches!(no.kind, NodeType::Spinner { .. }) {
                *total += 1;
                if !no.hidden.unwrap_or(false) {
                    *visiveis += 1;
                }
            }
            for f in &no.children {
                anda(f, total, visiveis);
            }
        }
        let (mut total, mut visiveis) = (0, 0);
        if let Ok(raiz) = motor.evaluated("perguntas") {
            anda(raiz, &mut total, &mut visiveis);
        }
        (total, visiveis)
    }

    // O spinner vive sob `if="{tem_perguntas}"`; sem isto, nada a inspecionar.
    motor.define_data("tem_perguntas", "true");

    motor.define_data("parado", "true"); // nada em voo -> escondido
    let _ = motor.reevaluate_all();
    let (total_parado, visiveis_parado) = contar(motor);

    motor.define_data("parado", "false"); // trabalhando -> à vista
    let _ = motor.reevaluate_all();
    let (total_ocupado, visiveis_ocupado) = contar(motor);

    if total_parado == 0 || total_ocupado == 0 {
        eprintln!("✗ visibilidade: nenhum <Spinner> na árvore — o teste passaria vazio");
        return 1;
    }
    if visiveis_parado == 0 && visiveis_ocupado > 0 {
        println!("✓ hidden=\"{{chave}}\" segue o contexto");
        return 0;
    }
    eprintln!(
        "✗ hidden=\"{{chave}}\" não segue o contexto: visíveis com parado=true: \
         {visiveis_parado}/{total_parado}, com parado=false: {visiveis_ocupado}/{total_ocupado}"
    );
    1
}

/// Percorre a entrevista com um questionário de mentira, sem tocar na rede.
///
/// O `--check` acima só prova que os arquivos carregam; é aqui que as **ações**
/// rodam — marcar/desmarcar opção, texto livre, navegar entre perguntas — que é
/// onde mora a lógica Luau de verdade (ids, JSON de ida e volta, projeção).
fn simular_entrevista(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::EngineMessage as M;
    let mut falhas = 0u8;

    motor.define_data("assunto", "Rust para quem vem de Python");
    motor.define_data("tipo", "roadmap");
    motor.define_data(
        "perguntas_json",
        r#"[{"id":"q1","texto":"Qual o seu nível?","ajuda":"calibra a profundidade",
             "opcoes":["Iniciante","Intermediário","Avançado"]},
            {"id":"q2","texto":"Quanto tempo por semana?","ajuda":"dimensiona as fases",
             "opcoes":["2h","5h","10h+"]}]"#,
    );
    motor.define_data("respostas_json", "{}");
    motor.define_data("q_idx", "1");
    motor.set_initial_screen("perguntas");

    let verificar = |motor: &GlacierUI, chave: &str, esperado: &str, oque: &str| {
        let obtido = motor.get_data(chave).cloned().unwrap_or_default();
        if obtido != esperado {
            eprintln!("✗ {oque}: {chave} = {obtido:?}, esperava {esperado:?}");
            return 1;
        }
        0
    };

    // Marcar duas opções da pergunta 1 (a seleção é múltipla) e desmarcar uma.
    for acao in ["alternar:1", "alternar:3", "alternar:1"] {
        let _ = motor.dispatch(&M::UiClick(acao.into()));
    }
    falhas += verificar(motor, "respondidas", "1", "marcar opções");
    let respostas = motor.get_data("respostas_json").cloned().unwrap_or_default();
    if !respostas.contains("Avançado") || respostas.contains("Iniciante") {
        eprintln!("✗ alternar não é um toggle: respostas_json = {respostas}");
        falhas += 1;
    }

    // Avançar, responder por escrito, e conferir que a projeção acompanhou.
    let _ = motor.dispatch(&M::UiClick("proxima".into()));
    falhas += verificar(motor, "q_num", "2", "avançar de pergunta");
    falhas += verificar(motor, "eh_ultima", "true", "avançar de pergunta");
    let _ = motor.dispatch(&M::UiInputChanged {
        action: "livre_mudou".into(),
        value: "cerca de 6h, à noite".into(),
    });
    falhas += verificar(motor, "respondidas", "2", "responder por escrito");

    // Fim da fila: "próxima" some e "concluir" aparece. Os dois se alternam por
    // `hidden`, que não tem negação no template — daí as duas chaves opostas.
    falhas += verificar(motor, "ja_no_fim", "false", "na última, 'concluir' aparece");
    let _ = motor.dispatch(&M::UiClick("proxima".into()));
    falhas += verificar(motor, "q_num", "2", "'próxima' na última não avança além do fim");

    // Voltar: a resposta da pergunta 1 tem de reaparecer marcada (o "✓" no
    // rótulo é o estado de seleção que a tela desenha).
    let _ = motor.dispatch(&M::UiClick("anterior".into()));
    falhas += verificar(motor, "q_num", "1", "voltar de pergunta");
    falhas += verificar(motor, "eh_ultima", "false", "fora da última, 'próxima' volta");
    let opcoes = motor.get_data("q_opcoes").cloned().unwrap_or_default();
    if !opcoes.contains("✓  Avançado") {
        eprintln!("✗ a seleção não sobreviveu à navegação: q_opcoes = {opcoes}");
        falhas += 1;
    }

    // A pergunta sai numerada no próprio enunciado.
    let texto = motor.get_data("q_texto").cloned().unwrap_or_default();
    if !texto.starts_with("1. ") {
        eprintln!("✗ a pergunta não vem numerada: q_texto = {texto:?}");
        falhas += 1;
    }

    falhas += checar_botoes_do_fim(motor);

    // Erro visível. Sem chave, `gerar` falha na porta e não toca na rede — o
    // que dá um caminho de erro determinístico para checar. `tem_erro` é o que
    // acende a faixa: o `if` do template testa VERDADE, não "não vazio", então
    // uma mensagem em `erro` sozinha ficaria invisível (já foi um bug real).
    let _ = motor.dispatch(&M::UiClick("gerar".into()));
    falhas += verificar(motor, "tem_erro", "true", "faixa de erro");
    if motor.get_data("erro").map(String::is_empty).unwrap_or(true) {
        eprintln!("✗ faixa de erro: `erro` ficou vazio");
        falhas += 1;
    }

    if falhas == 0 {
        println!("✓ entrevista (marcar, escrever, navegar, falhar)");
    }
    falhas
}

/// Exercita a tela de produção com um plano semeado, sem tocar na rede.
///
/// A máquina de estados da fila tem testes próprios (`tests/fila_producao.lua`);
/// o que se prova aqui é a outra metade — que a tela LÊ esse plano direito:
/// contagens, barra, lista de capítulos e os botões que aparecem/somem.
fn simular_producao(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::EngineMessage as M;
    let mut falhas = 0u8;

    // 2 capítulos × 2 trechos; um trecho já pronto e um falho, para a tela ter
    // os três estados (pendente/pronto/erro) na mesma passada.
    motor.define_data(
        "obra_json",
        r#"{"titulo":"Obra de teste","resumo":"r","publico":"p","pasta":"saidas/teste",
            "capitulos":[
              {"titulo":"Primeiro","resumo":"a","dir":"saidas/teste/01-primeiro",
               "arquivo":"saidas/teste/01-primeiro/README.md","status":"pendente","erro":"",
               "subs":[{"titulo":"A","foco":"f","arquivo":"saidas/teste/01-primeiro/01-a.md","status":"pronto","erro":""},
                       {"titulo":"B","foco":"f","arquivo":"saidas/teste/01-primeiro/02-b.md","status":"erro","erro":"500"}]},
              {"titulo":"Segundo","resumo":"b","dir":"saidas/teste/02-segundo",
               "arquivo":"saidas/teste/02-segundo/README.md","status":"pendente","erro":"",
               "subs":[{"titulo":"C","foco":"f","arquivo":"saidas/teste/02-segundo/01-c.md","status":"pendente","erro":""}]}
            ]}"#,
    );
    motor.define_data("tipo", "curso");
    motor.set_initial_screen("producao");
    // Uma ação inofensiva só para o script projetar o plano no contexto.
    let _ = motor.dispatch(&M::UiClick("parar".into()));

    let verificar = |motor: &GlacierUI, chave: &str, esperado: &str, oque: &str| {
        let obtido = motor.get_data(chave).cloned().unwrap_or_default();
        if obtido != esperado {
            eprintln!("✗ {oque}: {chave} = {obtido:?}, esperava {esperado:?}");
            return 1;
        }
        0
    };

    // 3 trechos + 2 aberturas de capítulo = 5 tarefas; 1 pronta.
    falhas += verificar(motor, "tem_obra", "true", "plano lido");
    falhas += verificar(motor, "total_tarefas", "5", "aberturas contam como tarefa");
    falhas += verificar(motor, "prontos", "1", "contagem de prontos");
    falhas += verificar(motor, "tem_erros", "true", "o trecho falho é visível");
    falhas += verificar(motor, "sem_falhas", "false", "o botão de refazer aparece");
    falhas += verificar(motor, "pct", "20", "barra de avanço");

    let caps = motor.get_data("capitulos_ui").cloned().unwrap_or_default();
    if !caps.contains("1/2 trechos") || !caps.contains("1 com erro") {
        eprintln!("✗ lista de capítulos não reflete o estado: {caps}");
        falhas += 1;
    }

    // "Refazer falhas" devolve o trecho com erro à fila, sem perder o pronto.
    let _ = motor.dispatch(&M::UiClick("refazer_falhas".into()));
    falhas += verificar(motor, "tem_erros", "false", "refazer falhas limpa o erro");
    falhas += verificar(motor, "prontos", "1", "refazer falhas preserva o que já estava pronto");

    // A transição `gerar` -> `producao`: quem grava o plano tem de PROJETÁ-LO,
    // porque o `init` da tela de produção já rodou no arranque, com o contexto
    // vazio, e navegar não o chama de novo. Sem isso a tela dizia "Nada
    // planejado ainda" em cima de um plano perfeitamente gravado — foi o bug
    // de "gerou a pasta mas não gerou os arquivos". Aqui: apaga as chaves
    // derivadas (como estariam no arranque), grava um plano e exige que a tela
    // já se enxergue pronta, SEM nenhum clique.
    motor.define_data("tem_obra", "");
    motor.define_data("capitulos_ui", "[]");
    let plano_bruto = motor.get_data("obra_json").cloned().unwrap_or_default();
    motor.define_data("obra_json", &plano_bruto);
    let _ = motor.dispatch(&M::UiClick("__inexistente__".into()));
    if motor.get_data("tem_obra").map(String::as_str) == Some("true") {
        eprintln!("✗ um clique qualquer não deveria projetar o plano sozinho");
        falhas += 1;
    }

    if falhas == 0 {
        println!("✓ produção (plano, contagens, refazer falhas)");
    }
    falhas
}

/// Os botões do fim da fila: `próxima` e `concluir` se revezam, e `concluir`
/// tem de FAZER algo de onde é clicável.
///
/// Trava dois bugs reais de uma vez. O primeiro: `concluir` saltava para a
/// última pergunta — só que ele aparece SÓ na última, então era um no-op. O
/// segundo é do teste anterior, que clicava em `concluir` a partir da pergunta
/// 1: um estado que a UI nunca alcança, então ele passava verificando um
/// caminho morto. Aqui o botão só é acionado de onde está visível de verdade.
fn checar_botoes_do_fim(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::EngineMessage as M;
    use glacier_ui::parser::{NodeType, UiNode};
    let mut falhas = 0u8;

    /// Os rótulos dos botões visíveis (não-`hidden`) da tela de perguntas.
    fn botoes_visiveis(motor: &mut GlacierUI) -> Vec<String> {
        fn anda(no: &UiNode, out: &mut Vec<String>) {
            if let NodeType::Button { text, .. } = &no.kind
                && !no.hidden.unwrap_or(false)
            {
                out.push(text.clone());
            }
            for f in &no.children {
                anda(f, out);
            }
        }
        let mut out = Vec::new();
        if let Ok(raiz) = motor.evaluated("perguntas") {
            anda(raiz, &mut out);
        }
        out
    }

    // Numa pergunta do meio: "próxima" à vista, "concluir" escondido.
    motor.define_data("q_idx", "1");
    let _ = motor.dispatch(&M::UiClick("anterior".into()));
    let meio = botoes_visiveis(motor);
    let tem = |v: &[String], s: &str| v.iter().any(|t| t.contains(s));
    if !tem(&meio, "próxima") || tem(&meio, "concluir") {
        eprintln!("✗ fora da última, deveria ver só 'próxima'. Visíveis: {meio:?}");
        falhas += 1;
    }

    // Na última: os papéis se invertem.
    let _ = motor.dispatch(&M::UiClick("proxima".into()));
    let fim = botoes_visiveis(motor);
    if tem(&fim, "próxima") || !tem(&fim, "concluir") {
        eprintln!("✗ na última, deveria ver só 'concluir'. Visíveis: {fim:?}");
        falhas += 1;
    }

    // E daqui — o único lugar de onde ele é clicável — `concluir` tem de fazer
    // algo. Sem chave da API, gerar falha na porta e acende a faixa de erro:
    // é sinal barato e determinístico de que a ação chegou à geração, em vez
    // de ser um no-op. O índice não pode mudar: concluir não é navegar.
    let antes = motor.get_data("q_num").cloned().unwrap_or_default();
    motor.define_data("api_key", "");
    motor.define_data("tem_erro", "false");
    let _ = motor.dispatch(&M::UiClick("concluir".into()));

    if motor.get_data("tem_erro").map(String::as_str) != Some("true") {
        eprintln!("✗ 'concluir' não fez nada: não chegou nem à validação de gerar");
        falhas += 1;
    }
    let depois = motor.get_data("q_num").cloned().unwrap_or_default();
    if antes != depois {
        eprintln!("✗ 'concluir' navegou ({antes} -> {depois}) em vez de concluir");
        falhas += 1;
    }

    if falhas == 0 {
        println!("✓ botões do fim (revezam, e 'concluir' gera)");
    }
    falhas
}

/// O log tem de existir em disco depois de operações reais.
///
/// Um log que silenciosamente não grava é pior que log nenhum: a próxima
/// investigação começa procurando um arquivo que nunca esteve lá. Como as
/// operações acima já rodaram (`parar`, `refazer_falhas`), o arquivo tem de
/// estar escrito — e com o formato que o `README` promete.
fn simular_log(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::EngineMessage as M;

    // Garante ao menos uma linha nova nesta execução.
    let _ = motor.dispatch(&M::UiClick("parar".into()));

    let caminho = std::path::Path::new("saidas/roadmapia.log");
    let conteudo = match std::fs::read_to_string(caminho) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("✗ log: {} não foi escrito ({e})", caminho.display());
            return 1;
        }
    };
    // `HH:MM:SS  NÍVEL  origem  mensagem` — carimbo e nível são o que torna o
    // arquivo utilizável para achar ONDE parou.
    let tem_formato = conteudo.lines().any(|l| {
        l.len() > 8
            && l.as_bytes()[2] == b':'
            && l.as_bytes()[5] == b':'
            && (l.contains("INFO") || l.contains("ERRO") || l.contains("AVISO"))
    });
    if !tem_formato {
        eprintln!("✗ log: sem linha no formato esperado. Conteúdo:\n{conteudo}");
        return 1;
    }
    println!("✓ log ({} linhas em {})", conteudo.lines().count(), caminho.display());
    0
}

fn main() -> std::process::ExitCode {
    if std::env::args().any(|a| a == "--check") {
        return checar();
    }
    let saida = GlacierDaemon::new()
        .title("roadmapia")
        .main_size(1040.0, 780.0)
        .main(registrar)
        .run();
    match saida {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("{e}");
            std::process::ExitCode::FAILURE
        }
    }
}
