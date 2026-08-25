--!nolint
-- Cliente mínimo da API de chat do OpenRouter, por cima do `fetch` do glacier.
--
-- `fetch` SUSPENDE a corrotina da ação (não bloqueia a UI), então `M.chat`
-- parece síncrono aqui em cima, mas a janela segue respondendo enquanto a
-- resposta não chega — é o que deixa o "gerando..." aparecer na tela.
--
-- Duas portas de entrada:
--   M.chat(opts)      -> ok:boolean, texto:string        (texto cru do modelo)
--   M.chat_json(opts) -> ok:boolean, valor:any|string    (JSON já decodificado)
--
-- opts = { key, model?, system?, user, temperature?, max_tokens? }

-- Caminho RELATIVO (e não "lib/log", como as telas escrevem): a suíte de
-- testes carrega este módulo de fora da árvore de `ui/`, e ali a raiz de
-- busca é outra — `./log` acha o irmão a partir do arquivo, sempre.
local L = require("./log")

local M = {}

--- Os campos que `M.chat`/`M.chat_json` aceitam. Todos opcionais menos, na
--- prática, `key` e `user` — que são validados em runtime, com mensagem.
export type ChatOpts = {
    key: string?,
    model: string?,
    system: string?,
    user: string?,
    temperature: number?,
    max_tokens: number?,
}

M.ENDPOINT = "https://openrouter.ai/api/v1/chat/completions"

-- Onde a última resposta que não decodificou fica guardada, crua. É o único
-- jeito de saber DEPOIS o que o modelo devolveu: a chamada já foi paga e não
-- se repete de graça.
M.ARQUIVO_RESPOSTA_CRUA = "saidas/ultima-resposta-invalida.txt"

-- Uma mensagem só para o corte por tokens: ele chega por três caminhos
-- (o `finish_reason` padrão, o nativo do provedor, e um JSON que simplesmente
-- acaba no meio) e os três descrevem a mesma coisa para quem lê a tela.
M.MSG_CORTADA = "A resposta foi cortada no limite de tokens. Reduza o escopo "
    .. "do assunto ou escolha um modelo com saída maior."

M.MODELO_PADRAO = "anthropic/claude-sonnet-4.5"

-- Modelos oferecidos no seletor da tela inicial. Só rótulos — qualquer id
-- aceito pelo OpenRouter funciona se digitado no campo "outro modelo".
M.MODELOS = {
    { label = "Claude Sonnet 4.5 (equilibrado)", value = "anthropic/claude-sonnet-4.5" },
    { label = "Claude Haiku 4.5 (rápido/barato)", value = "anthropic/claude-haiku-4.5" },
    { label = "GPT-4.1 mini", value = "openai/gpt-4.1-mini" },
    { label = "Gemini 2.5 Flash", value = "google/gemini-2.5-flash" },
    { label = "Llama 3.3 70B", value = "meta-llama/llama-3.3-70b-instruct" },
    { label = "DeepSeek V3", value = "deepseek/deepseek-chat" },
}

--- Uma chamada de chat. Devolve `false, mensagem` em qualquer falha (rede,
--- HTTP != 2xx, corpo inesperado) — o chamador nunca precisa de pcall.
function M.chat(opts: ChatOpts): (boolean, string, number)
    -- O `or ""` externo é o que garante uma string: `match` devolve `string?`,
    -- e um `nil` aqui viraria "attempt to concatenate nil" lá no header.
    local key = ((opts.key or ""):match("^%s*(.-)%s*$")) or ""
    if key == "" then
        return false, "Falta a chave da API do OpenRouter.", 0
    end

    local mensagens = {}
    if opts.system and opts.system ~= "" then
        table.insert(mensagens, { role = "system", content = opts.system })
    end
    table.insert(mensagens, { role = "user", content = opts.user or "" })

    local corpo = json.encode({
        model = opts.model ~= nil and opts.model ~= "" and opts.model or M.MODELO_PADRAO,
        messages = mensagens,
        temperature = opts.temperature or 0.6,
        max_tokens = opts.max_tokens or 4000,
    })

    local res = fetch(M.ENDPOINT, {
        method = "POST",
        body = corpo,
        headers = {
            ["Authorization"] = "Bearer " .. key,
            ["Content-Type"] = "application/json",
            -- Identificam o app nos rankings do OpenRouter; opcionais na API.
            ["HTTP-Referer"] = "https://github.com/antoniofernandodj/roadmapia",
            ["X-Title"] = "roadmapia",
        },
    })

    if not res.ok then
        -- Status de erro (429, 5xx, rede): não há geração faturada, custo 0.
        -- Mesmo assim a API costuma mandar um JSON com o motivo; ele é bem
        -- mais útil que "HTTP 401".
        local detalhe = M.motivo_do_erro(res.body)
        if detalhe then
            return false, detalhe, 0
        end
        if res.error ~= nil and res.error ~= "" then
            return false, res.error, 0
        end
        return false, "A API respondeu " .. tostring(res.status) .. ".", 0
    end

    local ok, corpo_decodificado = pcall(json.decode, res.body)
    if not ok or type(corpo_decodificado) ~= "table" then
        return false, "Resposta da API em formato inesperado.", 0
    end

    -- O custo REAL desta chamada, que o OpenRouter reporta em `usage.cost` (em
    -- dólares), extraído ANTES de qualquer validação do conteúdo.
    --
    -- A ordem importa e já foi um bug: daqui para baixo a chamada JÁ FOI
    -- COBRADA — veio 200 com corpo — então todo caminho de saída precisa
    -- devolver o custo, inclusive os de erro. O pior era o corte por tokens
    -- logo abaixo: uma resposta truncada é uma geração faturada no TETO, a mais
    -- cara que existe, e com `TENTATIVAS` repetições por trecho ela era cobrada
    -- várias vezes reportando US$ 0. Isso subestimava justamente a estimativa
    -- que autoriza uma produção de dezenas de dólares.
    local custo = 0
    local uso = corpo_decodificado.usage
    if type(uso) == "table" and type(uso.cost) == "number" then
        custo = uso.cost
    end

    local motivo = M.motivo_do_erro(res.body)
    if motivo then
        return false, motivo, custo
    end

    local escolhas = corpo_decodificado.choices
    if type(escolhas) ~= "table" or escolhas[1] == nil then
        return false, "A API não devolveu nenhuma escolha.", custo
    end
    local msg = escolhas[1].message
    local texto = msg ~= nil and msg.content or nil
    if type(texto) ~= "string" or texto == "" then
        return false, "A API devolveu uma resposta vazia.", custo
    end

    -- Corte no teto de tokens: o texto volta 200 OK, só que pela metade — e,
    -- num pedido de JSON, um JSON pela metade não decodifica. Sem esta checagem
    -- o sintoma vira "JSON inválido", que aponta para o lugar errado.
    --
    -- `native_finish_reason` junto porque o motivo NORMALIZADO nem sempre chega:
    -- alguns provedores do OpenRouter mandam `stop` no campo padrão e só contam
    -- o corte no campo nativo. Ler só o padrão deixava passar exatamente o caso
    -- que esta checagem existe para pegar.
    local fim = escolhas[1].finish_reason
    local fim_nativo = escolhas[1].native_finish_reason
    if fim == "length" or fim_nativo == "length" or fim == "max_tokens" then
        return false, M.MSG_CORTADA, custo
    end

    return true, texto, custo
end

--- Como `M.chat`, mas exige JSON de volta: reforça a instrução no `system`,
--- decodifica a resposta tolerando cercas ```json e texto em volta e, se ela
--- vier malformada, tenta consertá-la antes de desistir (ver `M.reparar_json`).
function M.chat_json(opts: ChatOpts): (boolean, any, number)
    local reforco =
        "Responda EXCLUSIVAMENTE com JSON válido, sem cercas de código, "
        .. "sem comentários e sem texto antes ou depois. Toda string fica em "
        .. "UMA linha: nunca quebre a linha dentro de aspas. Para citar algo "
        .. "dentro de um texto, use aspas simples ('assim') — aspas duplas não "
        .. "escapadas quebram o JSON."
    local sistema = opts.system and (opts.system .. "\n\n" .. reforco) or reforco

    local ok, texto, custo = M.chat({
        key = opts.key,
        model = opts.model,
        system = sistema,
        user = opts.user,
        temperature = opts.temperature or 0.4,
        max_tokens = opts.max_tokens or 4000,
    })
    if not ok then
        -- `custo` e não `0`: os erros pós-200 do `M.chat` (corte por tokens,
        -- resposta vazia) JÁ FORAM FATURADOS. Zerar aqui desfazia, no último
        -- metro, toda a contabilidade que o `M.chat` teve o cuidado de manter.
        return false, texto, custo
    end

    local bruto = M.extrair_json(texto)
    if bruto == nil then
        M.guardar_resposta(texto)
        return false, "Não encontrei JSON na resposta do modelo.", custo
    end

    local decodificou, valor = pcall(json.decode, bruto)
    if decodificou then
        return true, valor, custo
    end

    -- Segunda tentativa, com o texto remendado. Um modelo mais fraco erra o
    -- JSON de duas formas previsíveis (quebra de linha literal dentro de uma
    -- string, vírgula pendurada antes de `}`/`]`), e o conteúdo está todo lá —
    -- desistir de uma geração paga por causa disso é jogar dinheiro fora.
    local remendado = M.reparar_json(bruto)
    if remendado ~= bruto then
        local ok_remendo, valor_remendado = pcall(json.decode, remendado)
        if ok_remendo then
            L.aviso("openrouter", "JSON malformado do modelo, consertado por "
                .. "`reparar_json` (aspas não escapadas / quebra de linha em "
                .. "string / vírgula pendurada)")
            return true, valor_remendado, custo
        end
    end

    -- Desistiu: guarda a resposta crua e diz O QUE estava errado. Sem isso o
    -- erro na tela era só "JSON inválido" — verdadeiro e inútil, porque a única
    -- prova do que aconteceu ia embora junto com a chamada.
    local onde = M.guardar_resposta(texto)
    -- Sobre o REMENDADO, e não sobre o bruto: com aspas soltas no meio do texto
    -- a varredura de profundidade se perde sobre qual `{` está dentro de uma
    -- string, e acusaria "cortada" uma resposta que chegou inteira.
    if M.parece_cortado(remendado) then
        L.erro("openrouter", "JSON cortado no meio; resposta crua em " .. onde)
        return false, M.MSG_CORTADA, custo
    end
    local detalhe = M.detalhe_do_decode(valor)
    L.erro("openrouter", "JSON inválido (" .. detalhe .. "); resposta crua em " .. onde)
    return false,
        "O modelo devolveu um JSON inválido (" .. detalhe .. "). "
            .. "A resposta crua ficou em " .. onde .. ".",
        custo
end

--- Estando dentro de uma string, o `"` em `pos` FECHA a string, ou é uma aspa
--- que o modelo esqueceu de escapar no meio do texto?
---
--- Decide pelo que vem depois, que é o que um parser de JSON esperaria de um
--- fecha-string: `,`, `}`, `]`, `:` ou o fim. A vírgula é o caso ambíguo — em
--- português, `objeções ao "tudo vale", segundo ele` tem exatamente essa cara —
--- então ali exige-se também que depois da vírgula COMECE um valor ou uma chave
--- (`"`, `{`, `[`, número, `true`/`false`/`null`) ou feche o que estava aberto
--- (`}`, `]` — a vírgula pendurada). Prosa continuando com uma palavra qualquer
--- não é nenhum deles, e a aspa é reconhecida como texto.
local function fecha_string(bruto: string, pos: number): boolean
    local n = #bruto
    local j = pos + 1
    while j <= n and bruto:sub(j, j):match("^%s$") ~= nil do
        j += 1
    end
    if j > n then
        return true
    end

    local depois = bruto:sub(j, j)
    if depois == "}" or depois == "]" or depois == ":" then
        return true
    end
    if depois ~= "," then
        return false
    end

    local k = j + 1
    while k <= n and bruto:sub(k, k):match("^%s$") ~= nil do
        k += 1
    end
    if k > n then
        return true
    end

    local inicio = bruto:sub(k, k)
    return inicio == '"'
        or inicio == "{"
        or inicio == "["
        or inicio == "-"
        -- `,}` e `,]`: a vírgula pendurada, o outro defeito que esta função
        -- remenda. Se ela não contasse como fecha-string, o valor antes dela
        -- ficaria aberto e o remendo estragaria um JSON que só tinha ISSO.
        or inicio == "}"
        or inicio == "]"
        or inicio:match("^%d$") ~= nil
        or bruto:sub(k, k + 3) == "true"
        or bruto:sub(k, k + 3) == "null"
        or bruto:sub(k, k + 4) == "false"
end

--- Conserta os defeitos de JSON que os modelos cometem de verdade, sem tentar
--- ser um parser tolerante: aspas não escapadas dentro de uma string, quebra de
--- linha (e outros caracteres de controle) literal dentro de uma string, e
--- vírgula pendurada antes de `}`/`]`.
---
--- Varre caractere a caractere de propósito. Um `gsub` não serve: ele não sabe
--- se está dentro ou fora de uma string, e trocaria também as vírgulas e as
--- quebras que fazem parte do TEXTO — corrompendo o conteúdo em vez de salvá-lo.
function M.reparar_json(bruto: string): string
    local saida: { string } = {}
    local dentro = false -- dentro de uma string JSON?
    local escapado = false

    for i = 1, #bruto do
        local c = bruto:sub(i, i)
        if dentro then
            if escapado then
                escapado = false
                table.insert(saida, c)
            elseif c == "\\" then
                escapado = true
                table.insert(saida, c)
            elseif c == '"' then
                -- A aspa que o modelo esqueceu de escapar: `Não discute "tudo
                -- vale".` derrubou uma geração inteira de esboço, com o resto
                -- do JSON — 10 capítulos — perfeito à volta dela.
                if fecha_string(bruto, i) then
                    dentro = false
                    table.insert(saida, c)
                else
                    table.insert(saida, '\\"')
                end
            elseif c == "\n" then
                table.insert(saida, "\\n")
            elseif c == "\r" then
                table.insert(saida, "\\r")
            elseif c == "\t" then
                table.insert(saida, "\\t")
            elseif c < " " then
                -- Outro caractere de controle: vira espaço. `c < " "` compara
                -- byte a byte, então acentuado (>= 0x80) não cai aqui.
                table.insert(saida, " ")
            else
                table.insert(saida, c)
            end
        elseif c == '"' then
            dentro = true
            table.insert(saida, c)
        elseif c == "}" or c == "]" then
            -- Vírgula pendurada: anda para trás por cima do espaço já emitido e
            -- apaga a vírgula, se houver uma.
            local j = #saida
            while j >= 1 and saida[j]:match("^%s$") ~= nil do
                j -= 1
            end
            if j >= 1 and saida[j] == "," then
                table.remove(saida, j)
            end
            table.insert(saida, c)
        else
            table.insert(saida, c)
        end
    end

    return table.concat(saida)
end

--- O JSON acabou no meio (chaves/colchetes abertos, ou uma string sem fechar)?
--- É o sintoma de uma resposta que bateu no teto de saída do modelo sem que o
--- provedor tenha reportado `finish_reason = "length"`.
function M.parece_cortado(bruto: string): boolean
    local profundidade = 0
    local dentro = false
    local escapado = false

    for i = 1, #bruto do
        local c = bruto:sub(i, i)
        if dentro then
            if escapado then
                escapado = false
            elseif c == "\\" then
                escapado = true
            elseif c == '"' then
                dentro = false
            end
        elseif c == '"' then
            dentro = true
        elseif c == "{" or c == "[" then
            profundidade += 1
        elseif c == "}" or c == "]" then
            profundidade -= 1
        end
    end

    return dentro or profundidade > 0
end

--- A mensagem do `json.decode` (que vem do serde, com linha e coluna), sem o
--- prefixo do módulo e em uma linha só — cabe na faixa de erro da tela.
function M.detalhe_do_decode(erro: any): string
    local texto = tostring(erro)
    texto = texto:gsub("^.*json%.decode:%s*", "")
    texto = texto:gsub("%s+", " ")
    if #texto > 160 then
        texto = texto:sub(1, 160) .. "…"
    end
    if texto == "" then
        return "sem detalhe"
    end
    return texto
end

--- Grava a resposta crua que não decodificou, para dar para olhar depois.
--- Sempre no MESMO arquivo (não um por falha): o que interessa é a última, e um
--- diretório enchendo de despejos seria um problema novo. Devolve o caminho.
function M.guardar_resposta(texto: string): string
    if write_file ~= nil then
        write_file(M.ARQUIVO_RESPOSTA_CRUA, texto)
    end
    return M.ARQUIVO_RESPOSTA_CRUA
end

--- Recorta o primeiro objeto/array JSON de um texto que pode vir embrulhado em
--- ```json … ``` ou com um parágrafo de cortesia em volta. Devolve `nil` se não
--- houver nada parecido com JSON.
function M.extrair_json(texto: string): string?
    -- 1) Cerca de código explícita — o caso mais comum.
    local cercado = texto:match("```json%s*(.-)%s*```") or texto:match("```%s*(.-)%s*```")
    -- Num local próprio, e não reatribuindo o parâmetro: `cercado` é `string?`,
    -- e reatribuir `texto` alargava o tipo dele para o resto da função.
    local corpo = texto
    if cercado ~= nil and cercado ~= "" then
        corpo = cercado
    end

    -- 2) Do primeiro `{`/`[` até o último `}`/`]` correspondente. Um corte
    --    ingênuo em `find`/`reverse-find` basta: o conteúdo entre eles é o JSON
    --    inteiro, e `json.decode` valida o resto.
    local inicio_obj: number? = corpo:find("{", 1, true)
    local inicio_arr: number? = corpo:find("%[", 1, false)
    local inicio: number? = inicio_obj
    if inicio == nil or (inicio_arr ~= nil and inicio_arr < inicio) then
        inicio = inicio_arr
    end
    if inicio == nil then
        return nil
    end

    local fecha = (corpo:sub(inicio, inicio) == "{") and "}" or "]"
    local fim = nil
    for i = #corpo, inicio, -1 do
        if corpo:sub(i, i) == fecha then
            fim = i
            break
        end
    end
    if fim == nil then
        return nil
    end
    return corpo:sub(inicio, fim)
end

--- Lê `{"error":{"message":…}}` de um corpo de resposta, se houver.
function M.motivo_do_erro(corpo: any): string?
    if type(corpo) ~= "string" or corpo == "" then
        return nil
    end
    local ok, t = pcall(json.decode, corpo)
    if not ok or type(t) ~= "table" or type(t.error) ~= "table" then
        return nil
    end
    local msg = t.error.message
    if type(msg) ~= "string" or msg == "" then
        return nil
    end
    local codigo = t.error.code
    if codigo ~= nil then
        return "OpenRouter (" .. tostring(codigo) .. "): " .. msg
    end
    return "OpenRouter: " .. msg
end

return M
