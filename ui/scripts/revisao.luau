--!nolint
-- Tela 3: revisão do plano — entre a entrevista e a produção.
--
-- A IA devolveu um esboço (capítulos e subcapítulos, só títulos e foco); esta
-- tela deixa corrigi-lo — editar, apagar, reordenar, acrescentar — ANTES de
-- qualquer trecho ser escrito de verdade (e cobrado). Só ao confirmar é que
-- `O.montar` roda e grava o `Plano` que a tela `producao` consome.

local OR = require("lib/openrouter")
local E = require("lib/entrevista")
local P = require("lib/prompts")
local O = require("lib/obra")
local R = require("lib/revisao")
local Rascunho = require("lib/rascunho")
local L = require("lib/log")

-- Mesma forma da obra pedida em `perguntas.luau` — "gerar de novo" tem de
-- pedir um esboço do mesmo tamanho, não um menor por engano.
local CAPITULOS = 10
local SUBCAPITULOS = 20

function init(): ()
    ctx.cap_sel = ctx.cap_sel or ""
    E.erro(nil)
    refletir()
    R.projetar()
end

-- ── capítulos ────────────────────────────────────────────────────────────────

function selecionar_capitulo(ci): ()
    ctx.cap_sel = tostring(ci)
    R.projetar()
end

function fechar_edicao(): ()
    ctx.cap_sel = ""
    R.projetar()
end

function excluir_capitulo(ci): ()
    local e = R.esboco()
    local cap = e ~= nil and e.capitulos[tonumber(ci) or 0] or nil
    local ok = confirm({
        title = "Excluir este capítulo?",
        message = "Remove \"" .. tostring(cap and cap.titulo or "?")
            .. "\" e todos os subcapítulos dele do plano. A produção ainda não "
            .. "começou — nada em disco é afetado.",
        confirm_label = "Excluir",
        cancel_label = "Cancelar",
    })
    if not ok then
        return
    end
    R.excluir_capitulo(tonumber(ci))
    if ctx.cap_sel == tostring(ci) then
        ctx.cap_sel = ""
    end
    E.erro(nil)
    R.projetar()
end

function adicionar_capitulo(): ()
    local novo = R.adicionar_capitulo()
    ctx.cap_sel = tostring(novo)
    E.erro(nil)
    R.projetar()
end

function mover_cima(ci): ()
    R.mover_capitulo(tonumber(ci), -1)
    R.projetar()
end

function mover_baixo(ci): ()
    R.mover_capitulo(tonumber(ci), 1)
    R.projetar()
end

function titulo_cap_mudou(texto): ()
    ctx.rev_cap_titulo = texto
    local ci = tonumber(ctx.cap_sel)
    if ci ~= nil then
        R.atualizar_capitulo(ci, "titulo", texto)
    end
end

function resumo_cap_mudou(texto): ()
    ctx.rev_cap_resumo = texto
    local ci = tonumber(ctx.cap_sel)
    if ci ~= nil then
        R.atualizar_capitulo(ci, "resumo", texto)
    end
end

-- ── obra (título/resumo/público) ────────────────────────────────────────────

function titulo_obra_mudou(texto): ()
    ctx.rev_titulo = texto
    R.atualizar_obra("titulo", texto)
end

function resumo_obra_mudou(texto): ()
    ctx.rev_resumo = texto
    R.atualizar_obra("resumo", texto)
end

function publico_obra_mudou(texto): ()
    ctx.rev_publico = texto
    R.atualizar_obra("publico", texto)
end

-- ── subcapítulos do capítulo selecionado ────────────────────────────────────

function adicionar_sub(): ()
    local ci = tonumber(ctx.cap_sel)
    if ci == nil then
        return
    end
    R.adicionar_sub(ci)
    E.erro(nil)
    R.projetar()
end

function excluir_sub(si): ()
    local ci = tonumber(ctx.cap_sel)
    if ci == nil then
        return
    end
    R.excluir_sub(ci, tonumber(si))
    E.erro(nil)
    R.projetar()
end

--- `si` chega como sufixo de `titulo_sub_mudou:<n>` — ver `ui/lib/revisao.luau`
--- sobre por que cada subcapítulo tem sua própria chave de contexto.
function titulo_sub_mudou(si, texto): ()
    ctx["sub_titulo_" .. tostring(si)] = texto
    local ci = tonumber(ctx.cap_sel)
    if ci ~= nil then
        R.atualizar_sub(ci, tonumber(si), "titulo", texto)
    end
end

function foco_sub_mudou(si, texto): ()
    ctx["sub_foco_" .. tostring(si)] = texto
    local ci = tonumber(ctx.cap_sel)
    if ci ~= nil then
        R.atualizar_sub(ci, tonumber(si), "foco", texto)
    end
end

-- ── gerar de novo / confirmar ────────────────────────────────────────────────

--- Pede outro esboço do zero (mesma chamada de `perguntas.luau:gerar()`),
--- substituindo o atual. Útil quando a IA errou feio demais para valer a pena
--- corrigir campo a campo.
function gerar_de_novo(): ()
    if (ctx.api_key or "") == "" then
        E.erro("Falta a chave do OpenRouter (ajuste no início).")
        return
    end
    E.erro(nil)
    ctx.cap_sel = ""
    L.info("revisao", "gerar_de_novo: pedindo outro esboço")
    ocupar("Planejando de novo...")

    local ok, esboco, custo = OR.chat_json({
        key = ctx.api_key,
        model = ctx.modelo,
        system = P.SISTEMA_ESBOCO,
        user = P.esboco(ctx.assunto, ctx.tipo, E.transcricao(), CAPITULOS, SUBCAPITULOS),
        temperature = 0.5,
        max_tokens = 16000,
    })

    liberar()
    ctx.custo_total = tostring((tonumber(ctx.custo_total) or 0) + (tonumber(custo) or 0))
    L.chamada("revisao", "esboço", ok, custo, ok and "" or tostring(esboco))

    if not ok then
        E.erro(esboco)
        return
    end

    R.set_esboco(esboco)
    R.projetar()
    toast({ message = "Novo esboço pronto.", kind = "success" })
end

--- Fecha a revisão: monta o `Plano` de verdade a partir do esboço editado e
--- segue para a produção. `O.montar` é o mesmo normalizador que a IA sempre
--- usou — reordenar/editar/acrescentar aqui não pede um caminho especial.
function confirmar(): ()
    local e = R.esboco()
    local motivo = R.validar(e)
    if motivo ~= nil then
        E.erro(motivo)
        return
    end

    local plano, erro_montar = O.montar(
        e,
        ctx.esboco_slug_base or O.slug(ctx.assunto or "obra"),
        ctx.observacoes
    )
    if plano == nil then
        E.erro(erro_montar)
        return
    end

    E.erro(nil)
    O.gravar_plano(plano)
    O.gravar_sumario()
    -- O esboço virou um `Plano` de verdade em disco; o rascunho não serve
    -- mais (e ficar para trás ofereceria "continuar" um esboço obsoleto).
    Rascunho.limpar()
    -- Projeta AQUI pelo mesmo motivo de sempre: o `init` de `producao` já
    -- rodou no arranque, com o contexto vazio, e navegar não o chama de novo.
    O.projetar(E.rotulo(ctx.tipo))
    local c = O.contar(plano)
    L.info("revisao", "plano confirmado: " .. #plano.capitulos .. " capítulos, "
        .. c.total .. " tarefas, pasta=" .. plano.pasta)
    navigate("producao")
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

function refletir(): ()
    ctx.ocupado = ctx.ocupado or "false"
    ctx.parado = (ctx.ocupado == "true") and "false" or "true"
end

function on_error(msg): ()
    L.erro("revisao", "ERRO DE SCRIPT: " .. tostring(msg))
    liberar()
    E.erro(msg)
end
