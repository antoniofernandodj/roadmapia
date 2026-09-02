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

use config::Config;
use glacier_ui::{GlacierDaemon, GlacierUI, style};
use std::path::PathBuf;

/// A seção do `.ini` onde as credenciais e o modelo moram.
const SECAO: &str = "openrouter";

/// As quatro telas, na ordem de registro. A primeira é a inicial.
const TELAS: [(&str, &str); 4] = [
    ("inicio", "inicio.gv"),
    ("perguntas", "perguntas.gv"),
    ("revisao", "revisao.gv"),
    ("producao", "producao.gv"),
];

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
fn ui_dir() -> PathBuf {
    if let Ok(d) = std::env::var("ROADMAPIA_UI") {
        return PathBuf::from(d);
    }
    let cwd = PathBuf::from("ui");
    if cwd.is_dir() {
        return cwd;
    }
    if let Some(base) = std::env::current_exe().ok().and_then(|e| e.parent().map(PathBuf::from)) {
        let ao_lado = base.join("ui");
        if ao_lado.is_dir() {
            return ao_lado;
        }
        let fhs = base.join("..").join("share").join("roadmapia").join("ui");
        if fhs.is_dir() {
            return fhs;
        }
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

    semear_config(motor);

    for (nome, arquivo) in TELAS {
        if let Err(e) = motor.register_component(nome, &ui(arquivo)) {
            eprintln!("Erro ao registrar '{nome}': {e}");
        }
    }
    motor.set_initial_screen(TELAS[0].0);
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
fn semear_config(motor: &mut GlacierUI) {
    let (cfg, erro) = Config::carregar();
    if let Some(e) = erro {
        eprintln!("config: não deu para ler {}: {e}", cfg.caminho().display());
    }

    let do_ambiente = std::env::var("OPENROUTER_API_KEY")
        .ok()
        .map(|k| k.trim().to_owned())
        .filter(|k| !k.is_empty());

    let (chave, origem) = match (cfg.get(SECAO, "api_key"), do_ambiente) {
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
    if let Some(m) = cfg.get(SECAO, "modelo") {
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
fn persistir_config(motor: &GlacierUI) {
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
        if let Err(e) = cfg.set(SECAO, chave, valor) {
            eprintln!("config: não deu para gravar {}: {e}", cfg.caminho().display());
            return;
        }
    }
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
    falhas += checar_config_ini();

    falhas += rodar_suites_luau();
    falhas += simular_entrevista(&mut motor);
    falhas += simular_revisao(&mut motor);
    falhas += simular_producao(&mut motor);
    falhas += simular_log(&mut motor);

    if falhas == 0 {
        println!("tudo certo.");
        std::process::ExitCode::SUCCESS
    } else {
        std::process::ExitCode::from(falhas)
    }
}

/// A precedência da configuração, e a promessa de que gravar não destrói.
///
/// São duas regras que só se veem quando quebram, e quebram caro: uma chave
/// errada dá um 401 que parece problema da OpenRouter, e um arquivo reescrito
/// perde os comentários de quem o editou — dano silencioso e irreversível.
///
/// Roda num `.ini` de mentira apontado por `$ROADMAPIA_CONFIG`, para nunca
/// encostar na configuração real de quem rodar o `--check`.
fn checar_config_ini() -> u8 {
    let base = std::env::temp_dir().join(format!("roadmapia-check-{}", std::process::id()));
    let temp = base.join("config.ini");
    let _ = std::fs::create_dir_all(&base);

    // O `--check` é uma thread só, do começo ao fim: nada mais está lendo o
    // ambiente enquanto isto roda. Guardamos o que estava lá para devolver no
    // fim — quem rodou o `--check` pode ter uma chave de verdade exportada, e
    // este teste não tem o direito de tirá-la do processo.
    //
    // `XDG_CONFIG_HOME`/`APPDATA` entram na lista porque são o TERCEIRO elo da
    // cadeia de busca: sem apontá-los para um diretório vazio, a parte que
    // testa "sem arquivo nenhum" acharia a configuração real de quem rodou o
    // check e falharia sozinha na máquina errada.
    const VARS: [&str; 4] = [
        "ROADMAPIA_CONFIG",
        "OPENROUTER_API_KEY",
        "XDG_CONFIG_HOME",
        "APPDATA",
    ];
    let antes = VARS.map(std::env::var_os);
    unsafe {
        std::env::set_var("ROADMAPIA_CONFIG", &temp);
        std::env::set_var("OPENROUTER_API_KEY", "chave-do-ambiente");
        std::env::set_var("XDG_CONFIG_HOME", &base);
        std::env::set_var("APPDATA", &base);
    }

    // O SEGUNDO elo é `./roadmapia.ini`, relativo ao diretório de trabalho, e é
    // um arquivo legítimo de dev — não dá para apontá-lo para outro lugar. Se
    // existir, as afirmações sobre "nenhum arquivo na cadeia" não se aplicam.
    let tem_local = std::path::Path::new("roadmapia.ini").is_file();
    if tem_local {
        println!("  (./roadmapia.ini existe — pulando as checagens de ausência)");
    }
    let mut falhas = 0u8;
    let mut dizer = |ok: bool, oque: &str| {
        if !ok {
            eprintln!("✗ config: {oque}");
            falhas += 1;
        }
    };

    // A trava que faz este teste ser seguro em qualquer máquina.
    //
    // A cadeia de busca tem TRÊS entradas, e apagar o arquivo temporário faz o
    // `carregar` cair para a seguinte — que, num desenvolvedor de verdade, é a
    // configuração REAL dele. Uma versão anterior deste teste gravou
    // `chave-de-permissao` por cima de `~/.config/roadmapia/config.ini`. Então
    // nada aqui escreve sem antes provar que está escrevendo no descartável.
    macro_rules! gravar {
        ($cfg:expr, $chave:expr, $valor:expr) => {{
            if $cfg.caminho() != temp.as_path() {
                eprintln!(
                    "✗ config: o teste ia gravar em {} em vez do temporário — abortado",
                    $cfg.caminho().display()
                );
                return falhas + 1;
            }
            $cfg.set(SECAO, $chave, $valor)
        }};
    }

    // Sem arquivo, o ambiente é quem vale.
    let _ = std::fs::remove_file(&temp);
    let (cfg, _) = Config::carregar();
    if !tem_local {
        dizer(!cfg.existe(), "um arquivo apagado não devia aparecer como existente");
        dizer(
            cfg.get(SECAO, "api_key").is_none(),
            "arquivo ausente devia dar chave nenhuma",
        );
    }

    // Com arquivo, o arquivo vence o ambiente — a regra desta feature.
    let original = "\
# a chave do trabalho, expira em março
[openrouter]
api_key = chave-do-arquivo

[outra_coisa]
preservar = sim
";
    if let Err(e) = std::fs::write(&temp, original) {
        eprintln!("✗ config: não deu para escrever o .ini de teste: {e}");
        return 1;
    }
    let (mut cfg, erro) = Config::carregar();
    if let Some(e) = erro {
        eprintln!("✗ config: não deu para ler o .ini de teste: {e}");
        return 1;
    }
    dizer(cfg.existe(), "o arquivo recém-escrito devia existir");
    dizer(
        cfg.get(SECAO, "api_key").as_deref() == Some("chave-do-arquivo"),
        "o .ini não venceu OPENROUTER_API_KEY",
    );
    dizer(
        cfg.get(SECAO, "modelo").is_none(),
        "chave ausente na seção devia dar None",
    );
    dizer(
        cfg.get("outra_coisa", "api_key").is_none(),
        "achou `api_key` numa seção que não é a dela",
    );

    // Gravar troca A LINHA e deixa o resto — comentário, seção alheia, ordem.
    if let Err(e) = gravar!(cfg, "api_key", "chave-nova") {
        eprintln!("✗ config: não deu para gravar: {e}");
        return falhas + 1;
    }
    if let Err(e) = gravar!(cfg, "modelo", "autor/modelo") {
        eprintln!("✗ config: não deu para gravar o modelo: {e}");
        return falhas + 1;
    }
    let depois = std::fs::read_to_string(&temp).unwrap_or_default();
    dizer(
        depois.contains("# a chave do trabalho, expira em março"),
        "a reescrita comeu o comentário do usuário",
    );
    dizer(
        depois.contains("[outra_coisa]") && depois.contains("preservar = sim"),
        "a reescrita comeu uma seção que não é nossa",
    );
    dizer(
        !depois.contains("chave-do-arquivo"),
        "a chave velha continuou no arquivo depois de trocada",
    );
    dizer(
        depois.matches("api_key").count() == 1,
        "gravar duplicou a linha `api_key` em vez de substituí-la",
    );
    // O `modelo` é chave NOVA: tem de entrar na seção certa, não no fim do
    // arquivo (onde cairia dentro de `[outra_coisa]` e sumiria da leitura).
    let (cfg, _) = Config::carregar();
    dizer(
        cfg.get(SECAO, "modelo").as_deref() == Some("autor/modelo"),
        "a chave nova não pousou na seção [openrouter]",
    );
    dizer(
        cfg.get("outra_coisa", "preservar").as_deref() == Some("sim"),
        "a seção alheia deixou de ser legível depois da escrita",
    );

    // E a regra vista de fora: o que o BOOT semeia no contexto. `Config` estar
    // certo não basta — quem decide a precedência é o `semear_config`, e é o
    // valor dele que a tela usa para chamar a API.
    let mut motor = GlacierUI::new();
    semear_config(&mut motor);
    dizer(
        motor.get_data("api_key").map(String::as_str) == Some("chave-nova"),
        "o boot semeou a chave do ambiente com um .ini presente",
    );
    dizer(
        motor.get_data("api_key_origem").map(String::as_str) == Some("ini"),
        "a origem semeada não foi `ini`",
    );
    dizer(
        motor.get_data("modelo").map(String::as_str) == Some("autor/modelo"),
        "o modelo do .ini não chegou ao contexto",
    );

    // Sem arquivo, o ambiente volta a valer — e a tela tem de PODER dizer isso.
    let _ = std::fs::remove_file(&temp);
    let mut motor = GlacierUI::new();
    semear_config(&mut motor);
    if !tem_local {
        dizer(
            motor.get_data("api_key").map(String::as_str) == Some("chave-do-ambiente"),
            "sem .ini, o ambiente devia valer",
        );
        dizer(
            motor.get_data("api_key_origem").map(String::as_str) == Some("ambiente"),
            "sem .ini, a origem devia ser `ambiente`",
        );
        dizer(
            motor.get_data("modelo").is_none(),
            "sem .ini, `modelo` devia ficar para o padrão do Luau",
        );
    }

    // E o caminho de volta: o que o `on_message` grava. Um contexto com chave
    // nova a persiste; um contexto VAZIO não apaga a que está lá — esta é a
    // parte que, errada, destrói a configuração de alguém em silêncio.
    let (mut cfg, _) = Config::carregar();
    let _ = gravar!(cfg, "api_key", "antes-de-persistir");
    let mut motor = GlacierUI::new();
    motor.define_data("api_key", "digitada-na-tela");
    persistir_config(&motor);
    let (cfg, _) = Config::carregar();
    dizer(
        cfg.get(SECAO, "api_key").as_deref() == Some("digitada-na-tela"),
        "o on_message não gravou a chave digitada",
    );

    let mut motor = GlacierUI::new();
    motor.define_data("api_key", "");
    persistir_config(&motor);
    let (cfg, _) = Config::carregar();
    dizer(
        cfg.get(SECAO, "api_key").as_deref() == Some("digitada-na-tela"),
        "um contexto vazio apagou a chave gravada",
    );

    // Um segredo não nasce legível para o grupo. O arquivo volta a existir
    // antes desta parte: sem ele, `carregar` desceria a cadeia até a config
    // real da máquina — ver a trava acima.
    #[cfg(unix)]
    {
        let _ = std::fs::write(&temp, "[openrouter]\napi_key = a-trocar\n");
        use std::os::unix::fs::PermissionsExt;
        let (mut cfg, _) = Config::carregar();
        let _ = gravar!(cfg, "api_key", "chave-de-permissao");
        let modo = std::fs::metadata(&temp).ok().map(|m| m.permissions().mode() & 0o777);
        dizer(modo == Some(0o600), "o .ini não ficou 0600");
    }

    let _ = std::fs::remove_dir_all(&base);
    unsafe {
        for (nome, valor) in VARS.iter().zip(antes) {
            match valor {
                Some(v) => std::env::set_var(nome, v),
                None => std::env::remove_var(nome),
            }
        }
    }
    if falhas == 0 {
        println!("✓ config .ini (vence o ambiente, grava sem destruir, 0600)");
    }
    falhas
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

    let suite = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/luau/suite.gv");

    // As suítes vivem em `tests/luau/`, então é DALI que o `require` delas parte
    // (o motor usa o diretório do script de entrada como raiz de módulos). Uma
    // suíte que importa `lib/prompts` carrega o arquivo certo — mas o
    // `require("lib/entrevista")` de DENTRO dele resolveria contra
    // `tests/luau/lib/`, que não existe, e a suíte inteira falharia ao carregar.
    //
    // `GLACIER_LUAU_PATH` é a raiz extra que o motor consulta depois das suas.
    // Com `ui/scripts` nela, uma suíte pode importar qualquer módulo do app
    // pelo mesmo nome que o app usa — e as dependências internas deles também
    // resolvem.
    let antes = std::env::var_os("GLACIER_LUAU_PATH");
    // SAFETY: o `--check` é uma thread só; nada mais lê o ambiente aqui.
    unsafe {
        std::env::set_var("GLACIER_LUAU_PATH", ui_dir().join("scripts"));
    }
    // A restauração acontece assim que as suítes rodam, e ANTES de qualquer
    // `return`: um erro de registro é justamente o caminho em que a variável
    // ficaria setada para o resto do `--check`.
    let mut motor = GlacierUI::new();
    let registro = motor.register_component("suite", &suite.to_string_lossy());
    if registro.is_ok() {
        motor.set_initial_screen("suite");
        let _ = motor.dispatch(&M::UiClick("rodar".into()));
    }
    unsafe {
        match antes {
            Some(v) => std::env::set_var("GLACIER_LUAU_PATH", v),
            None => std::env::remove_var("GLACIER_LUAU_PATH"),
        }
    }
    if let Err(e) = registro {
        eprintln!("✗ suítes Luau: {e}");
        return 1;
    }

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
            if !alturas.is_empty() && no.align_y().is_none() {
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
    // A tela `revisao`: sem isto o painel de edição do capítulo (se-lecionado
    // via `c.selecionado` dentro do `for-each`) fica podado, e a fila de
    // botões que ele contém nunca é percorrida por este checador.
    motor.define_data("rev_tem_esboco", "true");
    motor.define_data("rev_tem_capitulos", "true");
    motor.define_data(
        "rev_capitulos_ui",
        r#"[{"n":"1","titulo":"Cap 1","resumo":"r","n_subs":"1","selecionado":"true"}]"#,
    );
    motor.define_data("rev_subs_ui", r#"[{"n":"1"}]"#);
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

/// Exercita a tela de revisão do plano com um esboço semeado, sem tocar na
/// rede: selecionar um capítulo, editar título, adicionar/remover
/// subcapítulo, reordenar capítulos, e a validação que bloqueia confirmar um
/// plano incompleto.
///
/// Não exercita `excluir_capitulo`: ela abre um `confirm()`, que suspende a
/// corrotina esperando uma resposta que este harness (sem UI) não dá — o
/// mesmo motivo por que `simular_producao` nunca chama `produzir()`.
fn simular_revisao(motor: &mut GlacierUI) -> u8 {
    use glacier_ui::EngineMessage as M;
    let mut falhas = 0u8;

    motor.define_data(
        "esboco_json",
        r#"{"titulo":"Obra de teste","resumo":"r","publico":"p",
            "capitulos":[
              {"titulo":"Primeiro","resumo":"a",
               "subcapitulos":[{"titulo":"A","foco":"fa"},{"titulo":"B","foco":"fb"}]},
              {"titulo":"Segundo","resumo":"b",
               "subcapitulos":[{"titulo":"C","foco":"fc"}]}
            ]}"#,
    );
    motor.define_data("esboco_slug_base", "teste");
    motor.define_data("tipo", "curso");
    motor.define_data("assunto", "teste");
    motor.set_initial_screen("revisao");
    // Seleciona o 1º capítulo: além de exercitar a seleção, força o script a
    // projetar o esboço no contexto — o `init` do componente já rodou no
    // REGISTRO, com o contexto vazio (mesmo motivo de sempre neste app, ver
    // `simular_producao`).
    let _ = motor.dispatch(&M::UiClick("selecionar_capitulo:1".into()));

    let verificar = |motor: &GlacierUI, chave: &str, esperado: &str, oque: &str| {
        let obtido = motor.get_data(chave).cloned().unwrap_or_default();
        if obtido != esperado {
            eprintln!("✗ {oque}: {chave} = {obtido:?}, esperava {esperado:?}");
            return 1;
        }
        0
    };

    falhas += verificar(motor, "rev_tem_esboco", "true", "esboço lido");
    falhas += verificar(motor, "rev_n_capitulos", "2", "contagem de capítulos");
    falhas += verificar(motor, "rev_tem_selecao", "true", "capítulo selecionado");
    falhas += verificar(motor, "rev_cap_titulo", "Primeiro", "painel abriu no capítulo certo");
    falhas += verificar(motor, "sub_titulo_1", "A", "chave por linha do 1º subcapítulo");
    falhas += verificar(motor, "sub_titulo_2", "B", "chave por linha do 2º subcapítulo");

    // Editar o título do capítulo selecionado — mesma ação que o `<input>` do
    // painel dispara a cada tecla.
    let _ = motor.dispatch(&M::UiInputChanged {
        action: "titulo_cap_mudou".into(),
        value: "Primeiro (editado)".into(),
    });
    falhas += verificar(motor, "rev_cap_titulo", "Primeiro (editado)", "editar título do capítulo");
    let _ = motor.dispatch(&M::UiClick("selecionar_capitulo:1".into())); // reprojeta os cards
    let cards = motor.get_data("rev_capitulos_ui").cloned().unwrap_or_default();
    if !cards.contains("Primeiro (editado)") {
        eprintln!("✗ a edição do título não chegou aos cards: {cards}");
        falhas += 1;
    }

    // Adicionar e remover subcapítulo.
    let _ = motor.dispatch(&M::UiClick("adicionar_sub".into()));
    falhas += verificar(motor, "sub_titulo_3", "Novo subcapítulo", "adicionar_sub acrescenta no molde certo");
    let _ = motor.dispatch(&M::UiClick("excluir_sub:3".into()));
    let subs = motor.get_data("rev_subs_ui").cloned().unwrap_or_default();
    if subs.contains("\"n\":\"3\"") {
        eprintln!("✗ excluir_sub não removeu o 3º subcapítulo: {subs}");
        falhas += 1;
    }

    // Reordenar capítulos: descer o 1º troca de lugar com o 2º. Compara
    // POSIÇÃO das substrings em vez de um prefixo exato — a ordem dos
    // CAMPOS dentro de cada objeto JSON não é uma garantia que valha a pena
    // travar num teste.
    let _ = motor.dispatch(&M::UiClick("mover_baixo:1".into()));
    let cards2 = motor.get_data("rev_capitulos_ui").cloned().unwrap_or_default();
    let pos_segundo = cards2.find("Segundo");
    let pos_obj2 = cards2.find(r#""n":"2""#);
    if !matches!((pos_segundo, pos_obj2), (Some(a), Some(b)) if a < b) {
        eprintln!("✗ mover_baixo não trocou a ordem dos capítulos: {cards2}");
        falhas += 1;
    }
    let _ = motor.dispatch(&M::UiClick("mover_cima:2".into())); // desfaz, para o resto do teste

    // Confirmar com o plano válido: monta o `Plano` de verdade e navega, sem
    // rede nenhuma envolvida (`O.montar` é local).
    let _ = motor.dispatch(&M::UiClick("confirmar".into()));
    falhas += verificar(motor, "tem_erro", "false", "confirmar um plano válido não gera erro");
    falhas += verificar(motor, "tem_obra", "true", "confirmar monta e grava o Plano");
    falhas += verificar(motor, "n_capitulos", "2", "…com os 2 capítulos do esboço");

    // Confirmar um plano incompleto (capítulo sem subcapítulo nenhum) barra
    // com uma mensagem — não monta um `Plano` com um capítulo a menos em
    // silêncio, que é o que `O.montar` sozinho faria.
    //
    // O `confirmar` de cima navegou para `producao` — sem redirecionar o
    // dispatch de volta, um clique em "confirmar" cairia nessa tela, que não
    // tem essa ação, e o teste passaria verificando um caminho morto.
    motor.set_initial_screen("revisao");
    motor.define_data(
        "esboco_json",
        r#"{"titulo":"Obra quebrada","capitulos":[
              {"titulo":"Sem subcapítulos","subcapitulos":[]}
            ]}"#,
    );
    motor.define_data("erro", "");
    motor.define_data("tem_erro", "false");
    let _ = motor.dispatch(&M::UiClick("confirmar".into()));
    falhas += verificar(motor, "tem_erro", "true", "confirmar um plano incompleto barra");
    if motor.get_data("erro").map(String::is_empty).unwrap_or(true) {
        eprintln!("✗ confirmar um plano incompleto: `erro` ficou vazio");
        falhas += 1;
    }

    // `confirmar` chama `O.gravar_sumario`, que grava em disco de verdade
    // (`write_file` aqui não é o dublê de `tests/luau/fila.luau` — só aquela
    // suíte troca a global). Limpa o que a simulação escreveu em
    // `saidas/teste`, senão sobra um `README.md` fora do `.gitignore`.
    let _ = std::fs::remove_dir_all("saidas/teste");
    // Idem para o despejo que a suíte de `openrouter` grava (ela redireciona
    // o caminho para não apagar o do usuário — ver `openrouter_casos.luau`).
    let _ = std::fs::remove_file("saidas/teste-resposta-invalida.txt");

    if falhas == 0 {
        println!("✓ revisão (selecionar, editar, adicionar/remover, reordenar, validar)");
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
