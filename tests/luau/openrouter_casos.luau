--!nocheck
-- Suíte de `ui/lib/openrouter.luau`: o recorte de JSON e a CONTABILIDADE DE
-- CUSTO — as duas coisas que, quando quebram, quebram calado.
--
-- Roda no interpretador do glacier (ver `suite.luau`), com `json` de verdade.
-- Só `fetch` é substituído, por respostas enlatadas: é o que permite exercitar
-- a taxonomia de erro da API inteira sem rede e sem gastar um centavo.
--
-- `--!nocheck` porque um harness troca globais do motor de propósito.

local OR = require("lib/openrouter")

local M = {}

-- ── o recorte de JSON ───────────────────────────────────────────────────────

local CASOS_JSON = {
    {
        nome = "cercado em ```json (o que a API faz de verdade)",
        texto = '```json\n[{"texto":"a","opcoes":["x"]}]\n```',
    },
    { nome = "array cru, sem cerca", texto = '[{"texto":"a","opcoes":["x"]}]' },
    { nome = "objeto embrulhando a lista", texto = '{"perguntas":[{"texto":"a"}]}' },
    { nome = "prosa em volta, sem cerca", texto = 'Claro! Aqui vai: [{"texto":"a"}] Espero ajudar.' },
    { nome = "cerca sem a tag json", texto = '```\n[{"texto":"a"}]\n```' },
    -- Este caso é o ÚNICO que separa o desembrulho da cerca do fallback de
    -- colchetes: com prosa depois do fecha-cerca contendo `]`, a varredura
    -- "do primeiro `[` até o último `]`" arrasta a cerca e a prosa junto, e o
    -- `json.decode` engasga. Sem ele, apagar o ramo da cerca não quebrava
    -- teste nenhum — a suíte passava sem cobrir a razão de a função existir.
    {
        nome = "cerca + prosa depois, com colchete na prosa",
        texto = '```json\n[{"texto":"a"}]\n```\n\nEspero ter ajudado [veja a doc].',
    },
    { nome = "sem JSON nenhum", texto = "Desculpe, nao posso ajudar.", espera_nil = true },
}

local function testar_recorte()
    for _, caso in ipairs(CASOS_JSON) do
        local r = OR.extrair_json(caso.texto)
        local ok
        if caso.espera_nil then
            ok = (r == nil)
        else
            -- Um recorte bom abre e fecha com o par certo, não arrastou a cerca
            -- junto, e — o teste mais forte — DECODIFICA. Aqui o `json` é o do
            -- motor, então isso prova o caminho inteiro, não uma aproximação.
            ok = r ~= nil
                and r:find("```", 1, true) == nil
                and pcall(json.decode, r)
        end
        conferir(ok, "recorte: " .. caso.nome, r and r:sub(1, 40) or "nil")
    end
end

-- ── contabilidade de custo ──────────────────────────────────────────────────

--- Instala um `fetch` que devolve sempre a mesma resposta enlatada.
local function com_fetch(resposta, corpo_fn)
    local fetch_real = fetch
    fetch = function()
        return resposta
    end
    corpo_fn()
    fetch = fetch_real
end

local function resposta(status, corpo)
    return { ok = (status >= 200 and status < 300), status = status, body = corpo, error = "" }
end

local function chat_de_teste()
    return OR.chat({ key = "k", model = "m", user = "oi" })
end

--- Todo caminho de saída DEPOIS de uma resposta faturada tem de devolver o
--- custo. Já foi bug: os erros pós-200 devolviam só 2 valores, o custo virava
--- `nil` e sumia da conta. O pior era o corte por tokens — uma geração
--- faturada no TETO, repetida por `TENTATIVAS`, reportando US$ 0 — que
--- subestimava justamente a estimativa que autoriza dezenas de dólares.
local function testar_custo()
    local uso = '"usage":{"cost":0.0842,"total_tokens":100}'

    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"stop",'
        .. '"message":{"content":"texto"}}]}'), function()
        local ok, texto, custo = chat_de_teste()
        conferir(ok and texto == "texto", "sucesso devolve o texto")
        conferir(custo == 0.0842, "sucesso devolve o custo", tostring(custo))
    end)

    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"length",'
        .. '"message":{"content":"pela metade"}}]}'), function()
        local ok, msg, custo = chat_de_teste()
        conferir(not ok, "corte por tokens é reprovado")
        conferir(msg:find("cortada", 1, true) ~= nil, "…com mensagem própria", tostring(msg))
        conferir(custo == 0.0842, "…E DEVOLVE O CUSTO (foi faturado)", tostring(custo))
    end)

    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"stop",'
        .. '"message":{"content":""}}]}'), function()
        local ok, _, custo = chat_de_teste()
        conferir(not ok, "resposta vazia é reprovada")
        conferir(custo == 0.0842, "…e devolve o custo", tostring(custo))
    end)

    com_fetch(resposta(200, '{' .. uso .. ',"choices":[]}'), function()
        local ok, _, custo = chat_de_teste()
        conferir(not ok, "sem escolhas é reprovado")
        conferir(custo == 0.0842, "…e devolve o custo", tostring(custo))
    end)

    -- Antes da geração não há o que faturar: custo 0, nunca `nil` (um `nil`
    -- viraria `tonumber(nil)` na soma e zeraria o acumulado).
    com_fetch(resposta(429, '{"error":{"message":"rate limited","code":429}}'), function()
        local ok, msg, custo = chat_de_teste()
        conferir(not ok, "429 é reprovado")
        conferir(msg:find("rate limited", 1, true) ~= nil, "…com o motivo da API", tostring(msg))
        conferir(custo == 0, "…e custo zero (nada faturado)", tostring(custo))
    end)

    com_fetch(resposta(200, "isto não é json"), function()
        local ok, _, custo = chat_de_teste()
        conferir(not ok, "corpo ilegível é reprovado")
        conferir(custo == 0, "…e custo zero", tostring(custo))
    end)

    local ok, msg, custo = OR.chat({ key = "", user = "oi" })
    conferir(not ok and custo == 0, "sem chave: reprova antes de qualquer rede",
        tostring(msg))

    -- `chat_json` repassa o custo do `chat` por baixo, inclusive quando o JSON
    -- não decodifica — a chamada foi paga do mesmo jeito.
    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"stop",'
        .. '"message":{"content":"sem json aqui"}}]}'), function()
        local ok2, _, custo2 = OR.chat_json({ key = "k", user = "oi" })
        conferir(not ok2, "chat_json reprova resposta sem JSON")
        conferir(custo2 == 0.0842, "…e ainda assim contabiliza o custo", tostring(custo2))
    end)
end

function M.rodar()
    testar_recorte()
    testar_custo()
end

return M
