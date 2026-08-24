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
    if escolhas[1].finish_reason == "length" then
        return false,
            "A resposta foi cortada no limite de tokens. Reduza o escopo do "
                .. "assunto ou escolha um modelo com saída maior.",
            custo
    end

    return true, texto, custo
end

--- Como `M.chat`, mas exige JSON de volta: reforça a instrução no `system` e
--- decodifica a resposta, tolerando cercas ```json e texto em volta.
function M.chat_json(opts: ChatOpts): (boolean, any, number)
    local reforco =
        "Responda EXCLUSIVAMENTE com JSON válido, sem cercas de código, "
        .. "sem comentários e sem texto antes ou depois."
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
        return false, texto, 0
    end

    local bruto = M.extrair_json(texto)
    if bruto == nil then
        return false, "Não encontrei JSON na resposta do modelo.", custo
    end
    local decodificou, valor = pcall(json.decode, bruto)
    if not decodificou then
        return false, "O modelo devolveu um JSON inválido.", custo
    end
    return true, valor, custo
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
