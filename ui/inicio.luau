--!nolint
-- Tela 1: coleta o assunto e o tipo, e monta o questionário de refinamento.
--
-- O botão "Refinar" é o coração do fluxo: ele não submete o formulário — pega
-- o assunto, pede à IA um questionário sob medida e navega para a entrevista.

local OR = require("lib/openrouter")
local E = require("lib/entrevista")
local P = require("lib/prompts")
local L = require("lib/log")

-- Quantas perguntas a primeira rodada pede. Poucas o bastante para ninguém
-- desistir no meio, muitas o bastante para o material sair diferente do
-- genérico. Aprofundar na tela seguinte adiciona mais.
local PERGUNTAS_POR_RODADA = 6

function init(): ()
    ctx.modelos = json.encode(json.array(OR.MODELOS))

    -- A chave pode ter vindo do ambiente (semeada pelo Rust). Só cai no
    -- `storage` se não veio — assim a variável de ambiente sempre vence.
    if ctx.api_key == nil or ctx.api_key == "" then
        ctx.api_key = storage.get("api_key") or ""
    end
    ctx.modelo = ctx.modelo or storage.get("modelo") or OR.MODELO_PADRAO
    ctx.assunto = ctx.assunto or ""

    if ctx.tipo == nil or ctx.tipo == "" then
        aplicar_tipo("roadmap")
    end

    ctx.mostrar_avancado = ctx.mostrar_avancado or "false"
    ctx.q_idx = ctx.q_idx or "1"
    ctx.status = ""
    E.erro(nil)
    refletir()
end

-- ── ações de campo ──────────────────────────────────────────────────────────

function assunto_mudou(texto): ()
    ctx.assunto = texto
    E.erro(nil)
end

function chave_mudou(texto): ()
    ctx.api_key = texto
    storage.set("api_key", texto)
    E.erro(nil)
    refletir()
end

function modelo_mudou(valor): ()
    ctx.modelo = valor
    storage.set("modelo", valor)
    refletir()
end

--- `onToggle` de um dos três checkboxes. Vem como `escolher_tipo:<tipo>`, então
--- o motor entrega o sufixo como 1º argumento (e o booleano do check como 2º —
--- ignorado de propósito: os três são um rádio, não caixas independentes, e
--- desmarcar o tipo ativo deixaria o app sem tipo nenhum).
function escolher_tipo(tipo): ()
    aplicar_tipo(tipo)
    refletir()
end

function alternar_avancado(): ()
    ctx.mostrar_avancado = (ctx.mostrar_avancado == "true") and "false" or "true"
    refletir()
end

-- ── a ação principal ────────────────────────────────────────────────────────

function refinar(): ()
    local assunto = (ctx.assunto or ""):match("^%s*(.-)%s*$")
    if assunto == "" then
        E.erro("Escreva primeiro sobre o que é o material.")
        return
    end
    if (ctx.api_key or "") == "" then
        E.erro("Falta a chave do OpenRouter — abra 'ajustes' e cole a sua.")
        ctx.mostrar_avancado = "true"
        refletir()
        return
    end

    E.erro(nil)
    L.sessao("inicio")
    L.info("inicio", "refinar: pedindo " .. PERGUNTAS_POR_RODADA .. " perguntas")
    ocupar("Montando as perguntas sobre \"" .. assunto .. "\"...")

    -- `chat_json` suspende a corrotina desta ação; a UI segue viva e já mostra
    -- o status acima. A execução retoma nesta mesma linha com a resposta.
    local ok, valor, custo = OR.chat_json({
        key = ctx.api_key,
        model = ctx.modelo,
        system = P.SISTEMA_ENTREVISTA,
        user = P.entrevista(assunto, ctx.tipo, PERGUNTAS_POR_RODADA, nil),
    })

    liberar()
    L.chamada("inicio", "entrevista", ok, custo, ok and "" or tostring(valor))

    if not ok then
        E.erro(valor)
        return
    end

    -- O modelo às vezes embrulha a lista em `{ "perguntas": [...] }`.
    local lista = valor
    if type(lista) == "table" and lista[1] == nil then
        lista = valor.perguntas or valor.questions or valor.itens or valor.items
    end

    local perguntas = E.normalizar(lista, 0)
    L.info("inicio", "entrevista: " .. #perguntas .. " perguntas aproveitadas")
    if #perguntas == 0 then
        E.erro("O modelo não devolveu perguntas utilizáveis. Tente de novo ou troque de modelo.")
        return
    end

    -- Entrevista nova: as respostas da anterior não valem mais.
    E.set_perguntas(perguntas)
    E.set_respostas({})
    E.set_indice(1)
    E.projetar()
    -- Entrevista nova invalida a obra planejada na anterior, e com ela a
    -- medição de custo (outro assunto, outro tamanho de trecho).
    ctx.obra_json = nil
    ctx.custo_total = "0"
    ctx.trechos_pagos = "0"
    ctx.amostra_arquivo = ""
    refletir()
    navigate("perguntas")
end

-- ── apoio ───────────────────────────────────────────────────────────────────

function aplicar_tipo(tipo): ()
    ctx.tipo = tipo
    for _, t in ipairs(E.TIPOS) do
        ctx["tipo_" .. t] = (t == tipo) and "true" or "false"
    end
end

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

--- Recalcula as chaves derivadas que o template lê (rótulos, visibilidade).
function refletir(): ()
    ctx.ocupado = ctx.ocupado or "false"
    ctx.parado = (ctx.ocupado == "true") and "false" or "true"
    ctx.rotulo_avancado = (ctx.mostrar_avancado == "true") and "ocultar ajustes" or "ajustes"
    ctx.sem_perguntas = (#E.perguntas() > 0) and "false" or "true"

    local chave = ctx.api_key or ""
    local estado_chave = (chave == "") and "sem chave" or ("chave ••••" .. chave:sub(-4))
    ctx.resumo_config = (ctx.modelo or OR.MODELO_PADRAO) .. "  ·  " .. estado_chave
end

function on_error(msg)
    L.erro("inicio", "ERRO DE SCRIPT: " .. tostring(msg))
    liberar()
    E.erro(msg)
end
