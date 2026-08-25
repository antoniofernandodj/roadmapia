--!nocheck
-- Suíte de `ui/scripts/lib/openrouter.luau`: o recorte de JSON e a
-- CONTABILIDADE DE CUSTO — as duas coisas que, quando quebram, quebram calado.
--
-- Roda no interpretador do glacier (ver `suite.luau`), com `json` de verdade.
-- Só `fetch` é substituído, por respostas enlatadas: é o que permite exercitar
-- a taxonomia de erro da API inteira sem rede e sem gastar um centavo.
--
-- `--!nocheck` porque um harness troca globais do motor de propósito.

-- `tests/luau/` fica fora da árvore de `ui/`, sem `lib/` irmão — navegação
-- explícita (`../`) é a forma de alcançar `ui/scripts/lib/`.
local OR = require("../../ui/scripts/lib/openrouter")

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

-- ── o remendo de JSON malformado ────────────────────────────────────────────

-- Os defeitos que um modelo comete DE VERDADE, e que custam uma geração paga
-- inteira quando `json.decode` os rejeita. O caso da quebra de linha dentro da
-- string é o que derrubou uma geração real de esboço (deepseek, 10×20): o
-- próprio prompt trazia um exemplo com a string partida em três linhas, e o
-- modelo copiou o molde.
local CASOS_REMENDO = {
    {
        nome = "quebra de linha literal dentro de uma string",
        texto = '{"foco": "duas frases\naqui, partidas"}',
        confere = function(v)
            return v.foco == "duas frases\naqui, partidas"
        end,
    },
    {
        nome = "vírgula pendurada antes de } e de ]",
        texto = '{"a": [1, 2,], "b": "x",}',
        confere = function(v)
            return v.b == "x" and #v.a == 2
        end,
    },
    {
        -- O caso real: um esboço de 11 capítulos inteiro, perdido por duas
        -- aspas soltas no meio de dois `foco`.
        nome = "aspas não escapadas dentro de uma string",
        texto = '{"foco": "Objeções ao "tudo vale". Não discute respostas."}',
        confere = function(v)
            return v.foco == 'Objeções ao "tudo vale". Não discute respostas.'
        end,
    },
    {
        -- A ambiguidade que o lookahead resolve: aqui a aspa vem seguida de
        -- vírgula, igual a um fecha-string — mas depois da vírgula continua
        -- prosa, e prosa não começa valor nenhum de JSON.
        nome = "aspas seguidas de vírgula, com prosa depois",
        texto = '{"a": "chamou de "ciência normal", segundo Kuhn", "b": 1}',
        confere = function(v)
            return v.a == 'chamou de "ciência normal", segundo Kuhn' and v.b == 1
        end,
    },
    {
        nome = "tabulação literal dentro de uma string",
        texto = '{"t": "col1\tcol2"}',
        confere = function(v)
            return v.t == "col1\tcol2"
        end,
    },
}

local function testar_remendo()
    for _, caso in ipairs(CASOS_REMENDO) do
        -- A premissa do caso: o texto original REALMENTE não decodifica. Sem
        -- isto o teste passaria com um remendo que não faz nada.
        conferir(not (pcall(json.decode, caso.texto)),
            "remendo: " .. caso.nome .. " (não decodifica cru)")
        local ok, valor = pcall(json.decode, OR.reparar_json(caso.texto))
        conferir(ok and caso.confere(valor),
            "remendo: " .. caso.nome .. " (decodifica remendado, conteúdo intacto)")
    end

    -- O remendo não pode MEXER no que já está certo — nem na vírgula e na
    -- quebra de linha que fazem parte do texto, escapadas como manda o JSON.
    local intacto = '{"a": "x, y", "b": "linha\\nlinha", "c": [1, 2]}'
    conferir(OR.reparar_json(intacto) == intacto,
        "remendo: JSON válido passa incólume", OR.reparar_json(intacto))

    conferir(OR.parece_cortado('{"a": [{"b": 1}, {"c": 2}'),
        "cortado: objeto que acaba no meio")
    conferir(OR.parece_cortado('{"a": "texto sem fech'),
        "cortado: string que acaba no meio")
    conferir(not OR.parece_cortado('{"a": [1, 2]}'),
        "cortado: JSON inteiro não é cortado")
    conferir(not OR.parece_cortado('{"a": "chave } aqui"}'),
        "cortado: chave dentro de string não conta")

    -- O remendo não pode inventar um fecha-string onde havia um de verdade: uma
    -- string vazia (`""`) e um valor seguido de `,` continuam fechando.
    local vazio = '{"a": "", "b": ["x", "y"], "c": {"d": "e"}}'
    conferir(OR.reparar_json(vazio) == vazio,
        "remendo: string vazia e aninhamento passam incólumes", OR.reparar_json(vazio))
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

    -- Alguns provedores do OpenRouter reportam o corte SÓ no campo nativo, com
    -- `stop` no normalizado. Ler só o normalizado deixava o JSON pela metade
    -- seguir adiante e falhar depois como "JSON inválido" — no lugar errado.
    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"stop",'
        .. '"native_finish_reason":"length","message":{"content":"pela metade"}}]}'), function()
        local ok, msg, custo = chat_de_teste()
        conferir(not ok, "corte reportado só no campo nativo é reprovado")
        conferir(msg:find("cortada", 1, true) ~= nil, "…com a mesma mensagem", tostring(msg))
        conferir(custo == 0.0842, "…e devolve o custo", tostring(custo))
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

    -- O custo tem de atravessar TAMBÉM os erros que o `chat` já reprovou: o
    -- corte por tokens é a geração mais cara que existe (saída no teto), e o
    -- `chat_json` zerava o valor no repasse.
    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"length",'
        .. '"message":{"content":"{\\"a\\": 1"}}]}'), function()
        local ok2, msg2, custo2 = OR.chat_json({ key = "k", user = "oi" })
        conferir(not ok2, "chat_json reprova o corte por tokens")
        conferir(custo2 == 0.0842, "…SEM zerar o custo no repasse", tostring(custo2))
        conferir(tostring(msg2):find("cortada", 1, true) ~= nil, "…e diz que foi corte")
    end)

    -- O caminho que motivou tudo isto: JSON malformado que o remendo salva. A
    -- chamada foi paga; jogá-la fora por causa de uma quebra de linha era o
    -- desperdício mais caro do app.
    com_fetch(resposta(200, '{' .. uso .. ',"choices":[{"finish_reason":"stop",'
        .. '"message":{"content":"{\\"foco\\": \\"parte um\\nparte dois\\"}"}}]}'), function()
        local ok2, valor2, custo2 = OR.chat_json({ key = "k", user = "oi" })
        conferir(ok2, "chat_json conserta a quebra de linha dentro da string",
            tostring(valor2))
        conferir(ok2 and valor2.foco == "parte um\nparte dois", "…preservando o texto")
        conferir(custo2 == 0.0842, "…e contabiliza o custo", tostring(custo2))
    end)
end

function M.rodar()
    -- O despejo da resposta crua vai para um arquivo de TESTE enquanto a suíte
    -- roda. Não é asseio: os casos de erro do `chat_json` gravam de verdade, e
    -- rodar os testes apagava a última resposta inválida de uma sessão real —
    -- justamente a prova que esse arquivo existe para guardar.
    local caminho_real = OR.ARQUIVO_RESPOSTA_CRUA
    OR.ARQUIVO_RESPOSTA_CRUA = "saidas/teste-resposta-invalida.txt"

    testar_recorte()
    testar_remendo()
    testar_custo()

    OR.ARQUIVO_RESPOSTA_CRUA = caminho_real
end

return M
