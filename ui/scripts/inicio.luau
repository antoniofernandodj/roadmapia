--!nolint
-- Tela 1: coleta o assunto e o tipo, e monta o questionário de refinamento.
--
-- O botão "Refinar" é o coração do fluxo: ele não submete o formulário — pega
-- o assunto, pede à IA um questionário sob medida e navega para a entrevista.

local OR = require("lib/openrouter")
local E = require("lib/entrevista")
local P = require("lib/prompts")
local R = require("lib/revisao")
local Rascunho = require("lib/rascunho")
local L = require("lib/log")

-- Quantas perguntas a primeira rodada pede. Poucas o bastante para ninguém
-- desistir no meio, muitas o bastante para o material sair diferente do
-- genérico. Aprofundar na tela seguinte adiciona mais.
local PERGUNTAS_POR_RODADA = 6

-- Migração do `storage` para o `.ini` — remover quando ninguém mais tiver a
-- versão antiga instalada.
--
-- Até esta versão, a chave digitada na tela morava num JSON por componente em
-- `.glacier-storage/`. Parar de lê-lo faria a chave "sumir" para quem já usava o
-- app, que é o tipo de regressão que ninguém reporta como bug — reclama que o
-- app esqueceu e digita de novo. Então lemos o valor velho UMA vez, para o
-- contexto; o `on_message` do lado Rust o grava no `.ini` no primeiro despacho,
-- e daí em diante a fonte é o arquivo.
local function migrar_do_storage(): ()
    if ctx.api_key == "" then
        local antiga = storage.get("api_key")
        if antiga ~= nil and antiga ~= "" then
            ctx.api_key = antiga
            ctx.api_key_origem = "ini"
        end
    end
    if ctx.modelo == "" then
        ctx.modelo = storage.get("modelo") or ""
    end
end

function init(): ()
    ctx.modelos = json.encode(json.array(OR.MODELOS))

    -- A chave e o modelo chegam prontos do Rust, que já resolveu a precedência
    -- entre o `.ini` e o ambiente (ver `semear_config` no main.rs). Daqui não
    -- se lê configuração: só se escreve no contexto, e o `on_message` do lado
    -- Rust persiste. O `or` cobre a tela rodando fora do daemon (o `--check`).
    ctx.api_key = ctx.api_key or ""
    ctx.modelo = ctx.modelo or ""
    migrar_do_storage()
    if ctx.modelo == "" then
        ctx.modelo = OR.MODELO_PADRAO
    end
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

-- Digitar a chave a grava no `.ini`, que passa a vencer o ambiente — é a única
-- forma de trocar de chave sem sair do app. Quem escreve é o Rust, no
-- `on_message`; aqui basta o contexto.
function chave_mudou(texto): ()
    ctx.api_key = texto
    ctx.api_key_origem = (texto ~= "") and "ini" or ""
    E.erro(nil)
    refletir()
end

function modelo_mudou(valor): ()
    ctx.modelo = valor
    refletir()
end

--- `on_toggle` de um dos três checkboxes. Vem como `escolher_tipo:<tipo>`, então
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
    -- Entrevista nova invalida a obra planejada na anterior — e o esboço
    -- ainda em revisão, se a pessoa nunca confirmou um plano — e com elas a
    -- medição de custo (outro assunto, outro tamanho de trecho). Sem isto, um
    -- esboço do assunto ANTERIOR sobreviveria até a tela `revisao` mostrar os
    -- capítulos errados para o assunto novo.
    ctx.obra_json = nil
    ctx.esboco_json = nil
    ctx.cap_sel = ""
    Rascunho.limpar()
    ctx.custo_total = "0"
    ctx.trechos_pagos = "0"
    ctx.amostra_arquivo = ""
    refletir()
    navigate("perguntas")
end

-- ── continuar um rascunho salvo ─────────────────────────────────────────────

--- Retoma um esboço gravado em disco por uma sessão anterior (ver
--- `lib/rascunho.luau`) — o caso que motivou o módulo: fechar o app no meio
--- da revisão não pode mais perder um esboço já pago à IA. Mesmo padrão de
--- `perguntas.luau:gerar()`: projeta ANTES de navegar, porque o `init` de
--- `revisao` já rodou no arranque (com o contexto vazio) e `navigate` não o
--- chama de novo.
function continuar_rascunho(): ()
    local d = Rascunho.carregar()
    if d == nil then
        toast({ message = "Nenhum rascunho salvo.", kind = "warning" })
        return
    end
    ctx.assunto = d.assunto or ""
    aplicar_tipo((d.tipo ~= nil and d.tipo ~= "") and d.tipo or "roadmap")
    ctx.esboco_json = d.esboco_json
    ctx.esboco_slug_base = d.slug_base or ""
    ctx.cap_sel = ""
    E.erro(nil)
    R.projetar()
    navigate("revisao")
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

    -- De onde a chave veio. As duas origens são indistinguíveis no campo, e
    -- descobrir "por que ele está usando a chave errada?" sem esta linha custa
    -- caro. O caminho do arquivo entra inteiro: é o que a pessoa vai editar.
    local origem = ctx.api_key_origem or ""
    if origem == "ini" then
        ctx.nota_chave = "Gravada em " .. (ctx.config_arquivo or "config.ini") .. "."
    elseif origem == "ambiente" then
        ctx.nota_chave = "Lida de OPENROUTER_API_KEY. Digitar aqui grava em "
            .. (ctx.config_arquivo or "config.ini")
            .. ", que passa a valer."
    else
        ctx.nota_chave = ""
    end
    ctx.tem_nota_chave = (ctx.nota_chave ~= "") and "true" or "false"
end

function on_error(msg)
    L.erro("inicio", "ERRO DE SCRIPT: " .. tostring(msg))
    liberar()
    E.erro(msg)
end
