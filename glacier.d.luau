-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  ESTE ARQUIVO FICA VERMELHO NO EDITOR. É ESPERADO — NÃO É BUG.           ║
-- ║                                                                          ║
-- ║  `declare` é sintaxe de ARQUIVO DE DEFINIÇÕES, não de código-fonte Luau. ║
-- ║  O `.vscode/settings.json` o carrega como definições (onde `declare` é   ║
-- ║  válido) e pede para ignorar diagnósticos em `**/*.d.luau` — mas o       ║
-- ║  `ignoreGlobs` do luau-lsp, por design, volta a reportar enquanto o      ║
-- ║  arquivo está ABERTO. Feche a aba e o vermelho some; os arquivos do app  ║
-- ║  não são afetados.                                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- Tipos das globais que o glacier-ui injeta no interpretador Luau de cada
-- componente (ver `glacier-ui/src/luau/mod.rs`).
--
-- Vale a pena manter: sem estas declarações as globais são `any`, e o checker
-- deixa passar `fetch(42)`, um campo que não existe em `FetchResult` e uma
-- chamada com aridade errada — os três verificados. A lista `globals` do
-- `.luaurc` NÃO substitui isto: ela só silencia o *lint* de global
-- desconhecida, sem dar tipo nenhum.
--
-- Na linha de comando: `luau-lsp analyze --platform=standard \
--     --definitions=glacier.d.luau <arquivo>`

export type FetchResult = {
    ok: boolean,
    status: number,
    body: string,
    error: string,
}

export type FetchOpts = {
    method: string?,
    body: string?,
    body_base64: string?,
    headers: { [string]: string }?,
    user_agent: string?,
    response: string?,
}

export type Handle = {
    cancel: (Handle) -> (),
    close: (Handle) -> (),
    send: (Handle, string) -> (),
}

-- O markup lê TEXTO, mas o script lê o tipo que gravou (glacier-ui 0.135+):
-- `boolean`, `number` ou `table` voltam como foram gravados; o que veio do
-- markup, de um widget ou de uma string escrita à mão volta texto. Ler uma
-- chave ausente dá `nil`. Daí `any`: o tipo depende de quem escreveu a chave.
declare ctx: { [string]: any }

-- O texto de um `on_change`/`on_toggle` — 1º argumento da ação e também global.
declare value: string?

-- Rede. `fetch` SUSPENDE a corrotina da ação (não bloqueia a UI) e retoma com
-- a resposta; `sse`/`websocket` registram streams e devolvem um handle na hora.
declare function fetch(url: string, opts: FetchOpts?): FetchResult
declare function sse(url: string, opts: { [string]: string }): Handle
declare function websocket(url: string, opts: { [string]: string }): Handle

-- Temporizadores. `after` é disparo único; `every` repete até `:cancel()`.
declare function after(ms: number, fn: any): Handle
declare function every(ms: number, fn: any): Handle

-- Efeitos de UI. `confirm` suspende como o `fetch` e devolve a escolha;
-- `notify` sai da janela e vai para a bandeja de notificações do SO.
declare function toast(opts: any): ()
declare function notify(opts: any): ()
declare function confirm(opts: any): boolean

-- Acrescenta texto no FIM de um `<TextEditor>` sem reescrever o binding
-- inteiro (que jogaria o cursor para o topo). Não suspende.
declare function append_textarea(binding: string, texto: string): ()
declare function navigate(tela: string): ()
declare function navigate_back(): ()
declare function viewport(): { width: number, height: number }

-- Diálogo de arquivo/pasta NATIVO do SO. Suspende como `confirm`/`fetch` e
-- retoma com o caminho escolhido, ou `nil` se o usuário cancelou.
declare function open_file(opts: any?): string?
declare function open_files(opts: any?): { string }?
declare function save_file(opts: any?): string?
declare function pick_folder(opts: any?): string?

-- Arquivos. Todos criam os diretórios que faltarem e devolvem `(ok, erro?)`;
-- `write_file` sobrescreve, `append_file` acrescenta, `zip_dir` compacta um
-- diretório inteiro num `.zip` escrito direto no caminho de destino. Todos
-- síncronos (não suspendem) e, desde a 0.168, gravam a string como bytes.
declare function write_file(caminho: string, conteudo: string): (boolean, string?)
-- Lê o arquivo inteiro sem suspender (0.168+): o conteúdo, ou `nil, mensagem`.
declare function read_file(caminho: string): (string?, string?)
-- Grava na pasta Downloads do sistema, sem diálogo e sem sobrescrever (0.160+):
-- `true, caminho` ou `false, mensagem`.
declare function save_download(nome: string, conteudo: string): (boolean, string)
declare function append_file(caminho: string, conteudo: string): (boolean, string?)
declare function zip_dir(origem: string, destino: string): (boolean, string?)

-- Múltiplas janelas (runner GlacierDaemon).
declare function broadcast(evento: string, payload: any?): ()
declare function open_window(opts: any): ()
declare function close_window(): ()

declare storage: {
    get: (string) -> any,
    set: (string, any) -> (),
    remove: (string) -> (),
}

declare json: {
    encode: (any) -> string,
    decode: (string) -> any,
    -- Marca uma tabela como ARRAY para o encode, resolvendo a ambiguidade da
    -- tabela vazia (`{}` vira `{}`; `json.array({})` vira `[]`).
    array: <T>(T) -> T,
    -- Marca a tabela como OBJETO (mesmo vazia): sem a marca, uma tabela vazia
    -- gravada no `ctx` vira `[]` (0.136+).
    object: <T>(T) -> T,
}

-- Base64 <-> bytes (0.168+). `decode` devolve os bytes ou `nil, mensagem`.
declare base64: {
    encode: (string) -> string,
    decode: (string) -> (string?, string?),
}
