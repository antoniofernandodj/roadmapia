--!nolint
-- Tela 2: a entrevista. Uma pergunta por vez; as respostas vão para o estado
-- compartilhado (ver `lib/entrevista`) assim que são dadas — não há "salvar".
--
-- Duas ações fazem chamadas à IA:
--   `aprofundar` — pede uma rodada extra de perguntas, ciente do que já foi dito;
--   `gerar`      — fecha a entrevista e produz o material.

local OR = require("lib/openrouter")
local E = require("lib/entrevista")
local P = require("lib/prompts")
local O = require("lib/obra")
local R = require("lib/revisao")
local L = require("lib/log")

local PERGUNTAS_POR_APROFUNDAMENTO = 4

-- A forma da obra. 10 × 20 = 200 trechos de ~1.200 palavras dão um livro de
-- verdade (~240 mil palavras), que é o ponto: material para aprender, não uma
-- ementa. Mexer aqui muda o tamanho — e a conta — de tudo.
local CAPITULOS = 10
local SUBCAPITULOS = 20

function init(): ()
    E.set_indice(E.indice())
    E.projetar()
    refletir()
end

-- ── responder ───────────────────────────────────────────────────────────────

--- Clique num chip de opção. A ação chega como `alternar:<n>`, com `<n>` o
--- índice (1-based) da opção dentro da pergunta em foco — o `for-each` do
--- template o interpola no próprio nome da ação.
---
--- É um TOGGLE, e a seleção é múltipla: um assunto raramente cabe numa opção só.
function alternar(indice): ()
    local p = E.pergunta_atual()
    if p == nil then
        return
    end
    local rotulo = p.opcoes[tonumber(indice) or 0]
    if rotulo == nil then
        return
    end

    local r = E.resposta(p.id)
    local restantes = {}
    local estava = false
    for _, e in ipairs(r.escolhas) do
        if e == rotulo then
            estava = true
        else
            table.insert(restantes, e)
        end
    end
    if not estava then
        table.insert(restantes, rotulo)
    end

    r.escolhas = restantes
    E.set_resposta(p.id, r)
    E.projetar()
    refletir()
end

--- Texto livre da pergunta em foco (a cada tecla).
function livre_mudou(texto): ()
    local p = E.pergunta_atual()
    if p == nil then
        return
    end
    local r = E.resposta(p.id)
    r.livre = texto
    E.set_resposta(p.id, r)
    -- De propósito NÃO chama `E.projetar()`: reescrever `ctx.q_livre` a cada
    -- tecla recriaria o `Content` do editor e o cursor pularia para o fim.
    ctx.respondidas = tostring(E.respondidas())
    ctx.progresso = tostring(math.floor((E.respondidas() / math.max(#E.perguntas(), 1)) * 100))
end

-- ── navegar ─────────────────────────────────────────────────────────────────

function proxima(): ()
    E.set_indice(E.indice() + 1)
    E.projetar()
    refletir()
end

function anterior(): ()
    E.set_indice(E.indice() - 1)
    E.projetar()
    refletir()
end

--- "Concluir": encerra a entrevista e parte para a geração.
---
--- Ele aparece SÓ na última pergunta, no lugar de `próxima`. A primeira versão
--- deste botão saltava para a última pergunta — que é justamente o único lugar
--- de onde ele é clicável, então não fazia nada. Concluir uma entrevista é
--- passar para o que vem depois dela, não navegar dentro dela.
function concluir(): ()
    L.info("perguntas", "concluir: entrevista encerrada pelo botão do fim")
    gerar()
end

-- ── mais perguntas ──────────────────────────────────────────────────────────

--- Segunda (terceira, …) rodada de perguntas, informada pelas respostas já
--- dadas — o prompt manda explicitamente não repetir o que já se sabe. As novas
--- perguntas são ANEXADAS, e o foco pula para a primeira delas.
function aprofundar(): ()
    if (ctx.api_key or "") == "" then
        E.erro("Falta a chave do OpenRouter (ajuste no início).")
        return
    end
    E.erro(nil)
    ocupar("Pensando em perguntas mais específicas...")

    local existentes = E.perguntas()
    local ok, valor, custo = OR.chat_json({
        key = ctx.api_key,
        model = ctx.modelo,
        system = P.SISTEMA_ENTREVISTA,
        user = P.entrevista(
            ctx.assunto,
            ctx.tipo,
            PERGUNTAS_POR_APROFUNDAMENTO,
            E.transcricao()
        ),
    })

    liberar()
    L.chamada("perguntas", "aprofundar", ok, custo, ok and "" or tostring(valor))
    if not ok then
        E.erro(valor)
        return
    end

    local lista = valor
    if type(lista) == "table" and lista[1] == nil then
        lista = valor.perguntas or valor.questions or valor.itens or valor.items
    end

    -- O deslocamento mantém os ids únicos entre rodadas: sem ele a rodada 2
    -- reusaria "q1".."q4" e herdaria as respostas da rodada 1.
    local novas = E.normalizar(lista, #existentes)
    if #novas == 0 then
        E.erro("O modelo não devolveu perguntas novas.")
        return
    end

    for _, p in ipairs(novas) do
        table.insert(existentes, p)
    end
    E.set_perguntas(existentes)
    E.set_indice(#existentes - #novas + 1)
    E.projetar()
    refletir()
    toast({
        message = tostring(#novas) .. " perguntas novas.",
        kind = "success",
    })
end

-- ── gerar: fase 1, o esboço ─────────────────────────────────────────────────

--- O "Generate" NÃO escreve a obra — ele a PLANEJA. Uma chamada só devolve, no
--- máximo, alguns milhares de tokens; nesse espaço só cabe um índice (foi o que
--- a primeira versão deste app produzia: uma grade de estudos sem uma linha de
--- código dentro). Então aqui sai só a arquitetura — capítulos e trechos, com o
--- foco de cada um. Ela vai para a tela `revisao`, onde dá para corrigir o que
--- a IA planejou ANTES de pagar pela produção; só de lá o plano segue para
--- `producao`, que escreve o conteúdo, um trecho por chamada, com o teto de
--- saída inteiro dedicado a um assunto pequeno.
function gerar(): ()
    if (ctx.api_key or "") == "" then
        E.erro("Falta a chave do OpenRouter (ajuste no início).")
        return
    end
    if #E.perguntas() == 0 then
        E.erro("Não há entrevista para usar.")
        return
    end

    E.erro(nil)
    L.sessao("perguntas")
    L.info("perguntas", "gerar: esboço de " .. CAPITULOS .. "x" .. SUBCAPITULOS
        .. " a partir de " .. #E.perguntas() .. " perguntas ("
        .. E.respondidas() .. " respondidas)")
    local r = E.rotulo(ctx.tipo)
    ocupar("Planejando " .. tostring(CAPITULOS) .. " " .. r.unidades .. " × "
        .. tostring(SUBCAPITULOS) .. " " .. r.subunidades .. "...")

    local ok, esboco, custo = OR.chat_json({
        key = ctx.api_key,
        model = ctx.modelo,
        system = P.SISTEMA_ESBOCO,
        user = P.esboco(ctx.assunto, ctx.tipo, E.transcricao(), CAPITULOS, SUBCAPITULOS),
        temperature = 0.5,
        -- O esboço inteiro (10 × 20 títulos + focos) é grande: sem teto folgado
        -- ele volta cortado, e um JSON cortado não decodifica.
        max_tokens = 16000,
    })

    liberar()
    ctx.custo_total = tostring((tonumber(ctx.custo_total) or 0) + (tonumber(custo) or 0))
    L.chamada("perguntas", "esboço", ok, custo, ok and "" or tostring(esboco))

    if not ok then
        E.erro(esboco)
        return
    end

    -- Não monta o `Plano` ainda — o esboço cru vai para a tela `revisao`, onde
    -- pode ser corrigido (capítulos e subcapítulos editados, apagados ou
    -- acrescentados) antes de qualquer trecho ser escrito de verdade. Só ao
    -- confirmar por lá é que `O.montar` roda e grava o `Plano`.
    ctx.esboco_slug_base = O.slug(ctx.tipo) .. "-" .. O.slug(ctx.assunto)
    -- `R.set_esboco` (e não `ctx.esboco_json = json.encode(...)` direto) para
    -- também gravar o rascunho em disco (ver `lib/rascunho.luau`) — sem isso
    -- um esboço recém-gerado sobrevive só até a próxima vez que o app fechar.
    R.set_esboco(esboco)
    L.info("perguntas", "esboço pronto para revisão: "
        .. tostring(#(esboco.capitulos or {})) .. " capítulos")
    -- Projeta AQUI pelo mesmo motivo de sempre: o `init` de `revisao` já
    -- rodou no arranque, com o contexto vazio, e navegar não o chama de novo
    -- (ver o mesmo comentário em `revisao.luau:confirmar()`).
    ctx.cap_sel = ""
    R.projetar()
    navigate("revisao")
end

-- ── apoio ───────────────────────────────────────────────────────────────────

function ocupar(mensagem): ()
    ctx.ocupado = "true"
    ctx.parado = "false"
    ctx.status = mensagem
end

function liberar(): ()
    ctx.ocupado = "false"
    ctx.parado = "true"
    ctx.status = ""
end

--- O que não é derivado do estado da entrevista (isso é com `E.projetar`):
--- só o par ocupado/parado, que governa o spinner e os botões desabilitados.
function refletir(): ()
    ctx.ocupado = ctx.ocupado or "false"
    ctx.parado = (ctx.ocupado == "true") and "false" or "true"
end

function on_error(msg): ()
    L.erro("perguntas", "ERRO DE SCRIPT: " .. tostring(msg))
    liberar()
    E.erro(msg)
end
