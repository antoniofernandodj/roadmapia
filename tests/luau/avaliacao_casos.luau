--!nocheck
-- Suíte de `ui/scripts/lib/avaliacao.luau` — a aritmética que divide os
-- exercícios e a prova em chamadas.
--
-- É conta pequena e cheia de fronteira: um capítulo com menos trechos do que
-- lotes pedidos, um número que não divide, um campo vazio, um "40" digitado
-- num curso de 3 trechos. Cada um desses casos, errado, produz ou uma faixa
-- vazia (uma chamada paga que não cobre trecho nenhum) ou duas faixas que se
-- encostam (dois lotes escrevendo o mesmo exercício, que é justamente o que a
-- divisão existe para impedir).
--
-- Roda sem plano, sem `ctx` de produção e sem rede — só os números.

local A = require("lib/avaliacao")

local M = {}

--- A propriedade que sustenta o módulo inteiro: as faixas cobrem `1..total`,
--- na ordem, sem buraco e sem sobreposição, e nenhuma sai vazia.
local function cobre_exatamente(faixas, total): (boolean, string)
    if #faixas == 0 then
        return total == 0, "nenhuma faixa para total=" .. tostring(total)
    end
    local esperado = 1
    for _, f in ipairs(faixas) do
        if f.de ~= esperado then
            return false, "faixa começa em " .. f.de .. ", esperava " .. esperado
        end
        if f.ate < f.de then
            return false, "faixa vazia: " .. f.de .. "-" .. f.ate
        end
        esperado = f.ate + 1
    end
    if esperado - 1 ~= total then
        return false, "cobriu até " .. (esperado - 1) .. ", esperava " .. total
    end
    return true, ""
end

local function resumir(faixas): string
    local partes = {}
    for _, f in ipairs(faixas) do
        table.insert(partes, f.de .. "-" .. f.ate
            .. (f.n ~= nil and ("(" .. f.n .. ")") or ""))
    end
    return table.concat(partes, " ")
end

function M.rodar()
    -- ── faixas ──────────────────────────────────────────────────────────────

    conferir(resumir(A.faixas(20, 2)) == "1-10 11-20",
        "faixas divide 20 em 2 pedaços iguais", resumir(A.faixas(20, 2)))
    conferir(resumir(A.faixas(7, 3)) == "1-3 4-5 6-7",
        "faixas dá o resto para os primeiros", resumir(A.faixas(7, 3)))
    conferir(resumir(A.faixas(1, 1)) == "1-1", "faixas com um trecho só")
    conferir(#A.faixas(0, 3) == 0, "faixas de nada é nada")
    conferir(#A.faixas(10, 0) == 0, "zero faixas é nada")

    -- Mais faixas que trechos: o `clamp` impede a faixa vazia — uma chamada
    -- paga que não cobriria trecho nenhum.
    conferir(#A.faixas(3, 5) == 3, "faixas nunca passa do número de trechos",
        resumir(A.faixas(3, 5)))

    -- A propriedade, varrida: nenhuma combinação pode deixar buraco ou
    -- sobreposição. É esta invariante que garante que dois lotes não têm como
    -- escrever o mesmo exercício.
    local quebrou = ""
    for total = 1, 25 do
        for n = 1, 25 do
            local ok, motivo = cobre_exatamente(A.faixas(total, n), total)
            if not ok and quebrou == "" then
                quebrou = "total=" .. total .. " n=" .. n .. ": " .. motivo
            end
        end
    end
    conferir(quebrou == "", "faixas cobrem tudo sem buraco nem sobreposição", quebrou)

    -- ── distribuir ──────────────────────────────────────────────────────────

    conferir(table.concat(A.distribuir(10, 3), ",") == "4,3,3",
        "distribuir dá o resto para os primeiros",
        table.concat(A.distribuir(10, 3), ","))
    conferir(table.concat(A.distribuir(6, 3), ",") == "2,2,2", "distribuir exato")
    conferir(table.concat(A.distribuir(0, 2), ",") == "0,0", "distribuir zero")

    local soma_quebrou = ""
    for n = 0, 40 do
        for p = 1, 12 do
            local soma = 0
            for _, v in ipairs(A.distribuir(n, p)) do
                soma += v
            end
            if soma ~= n and soma_quebrou == "" then
                soma_quebrou = "n=" .. n .. " p=" .. p .. " somou " .. soma
            end
        end
    end
    conferir(soma_quebrou == "", "distribuir entrega exatamente o que foi pedido",
        soma_quebrou)

    -- ── lotes de exercícios ─────────────────────────────────────────────────

    local l = A.lotes_exercicios(20, 10)
    conferir(resumir(l) == "1-10(5) 11-20(5)",
        "10 exercícios num capítulo de 20 trechos: 2 lotes de 5", resumir(l))

    l = A.lotes_exercicios(20, 3)
    conferir(resumir(l) == "1-20(3)",
        "3 exercícios cabem numa chamada só, cobrindo o capítulo inteiro", resumir(l))

    -- O caso degenerado: 40 exercícios num capítulo de 4 trechos. Não dá para
    -- dividir em 8 lotes — não há 8 pedaços. Os lotes ficam gordos (e a tela
    -- avisa), mas continuam disjuntos, que é o que não pode ceder.
    l = A.lotes_exercicios(4, 40)
    conferir(#l == 4, "mais lotes que trechos: um lote por trecho", resumir(l))
    conferir(A.maior(l) == 10, "…e os exercícios se acumulam neles", resumir(l))
    local ok_cobertura = cobre_exatamente(l, 4)
    conferir(ok_cobertura, "…sem deixar de cobrir o capítulo", resumir(l))

    conferir(#A.lotes_exercicios(20, 0) == 0, "zero exercícios não gera lote")
    conferir(#A.lotes_exercicios(0, 10) == 0, "capítulo sem trecho não gera lote")

    -- ── partes da prova ─────────────────────────────────────────────────────

    local p = A.partes_prova(200, 40)
    conferir(resumir(p) == "1-50(10) 51-100(10) 101-150(10) 151-200(10)",
        "40 questões sobre 200 trechos: 4 partes de 10", resumir(p))
    conferir(#A.partes_prova(200, 0) == 0, "prova desligada não gera parte")

    local total_questoes = 0
    for _, f in ipairs(A.partes_prova(37, 25)) do
        total_questoes += f.n
    end
    conferir(total_questoes == 25, "a prova entrega o número de questões pedido",
        tostring(total_questoes))

    -- ── saneamento do campo de texto ────────────────────────────────────────

    conferir(A.sanear("10", 7, 40) == 10, "número normal passa")
    conferir(A.sanear("", 7, 40) == 7, "campo vazio cai no padrão")
    conferir(A.sanear(nil, 7, 40) == 7, "campo inexistente cai no padrão")
    conferir(A.sanear("abc", 7, 40) == 7, "texto que não é número cai no padrão")
    conferir(A.sanear("-4", 7, 40) == 0, "negativo vira zero, não padrão")
    conferir(A.sanear("999", 7, 40) == 40, "acima do teto para no teto")
    conferir(A.sanear("7,5", 3, 40) == 7, "vírgula é aceita (é um app em português)")
    conferir(A.sanear("7.9", 3, 40) == 7, "fração trunca — meio exercício não existe")

    -- ── a leitura do contexto ───────────────────────────────────────────────

    ctx.quer_exercicios = "true"
    ctx.n_exercicios = "12"
    ctx.quer_prova = "true"
    ctx.n_questoes = "30"

    local cfg = A.config("curso")
    conferir(cfg.exercicios_por_capitulo == 12 and cfg.questoes_prova == 30,
        "config lê os dois números do contexto")

    -- Fora de curso a avaliação é sempre zero, e é aqui que isso se decide:
    -- marcar "guia" depois de configurar exercícios não pode produzir um guia
    -- com prova.
    cfg = A.config("guia")
    conferir(cfg.exercicios_por_capitulo == 0 and cfg.questoes_prova == 0,
        "guia nunca leva exercício nem prova")
    cfg = A.config(nil)
    conferir(cfg.exercicios_por_capitulo == 0, "tipo ausente é tratado como não-curso")

    -- …mas os valores digitados continuam no contexto: voltar para curso os
    -- encontra intactos.
    conferir(ctx.n_exercicios == "12", "trocar de tipo não apaga o que foi digitado")

    ctx.quer_exercicios = "false"
    cfg = A.config("curso")
    conferir(cfg.exercicios_por_capitulo == 0 and cfg.questoes_prova == 30,
        "desmarcar exercícios não desliga a prova")
    conferir(ctx.n_exercicios == "12", "desmarcar preserva o número digitado")

    -- ── a conta que a tela mostra ───────────────────────────────────────────

    ctx.quer_exercicios = "true"
    ctx.n_exercicios = tostring(A.PADRAO_EXERCICIOS)
    ctx.n_questoes = tostring(A.PADRAO_QUESTOES)

    local padrao = {}
    for _ = 1, 10 do
        table.insert(padrao, 20)
    end
    local c = A.contar_tarefas(padrao, A.config("curso"))
    conferir(c.trechos == 200, "obra padrão tem 200 trechos", tostring(c.trechos))
    conferir(c.lotes == 20, "…20 lotes de exercícios (2 por capítulo)", tostring(c.lotes))
    conferir(c.partes == 4, "…e 4 partes de prova", tostring(c.partes))

    A.projetar(padrao, "curso")
    conferir(ctx.aviso_avaliacao:find("24 chamadas", 1, true) ~= nil,
        "o aviso diz quantas chamadas a mais", ctx.aviso_avaliacao)
    conferir(ctx.aviso_avaliacao:find("+11%", 1, true) ~= nil,
        "o aviso diz o quanto isso pesa no custo", ctx.aviso_avaliacao)
    conferir(ctx.tem_alerta_avaliacao == "false",
        "a obra padrão não dispara alerta de densidade", ctx.alerta_avaliacao)

    -- Obra pequena com muita avaliação pedida: a tela avisa, mas não bloqueia.
    ctx.n_exercicios = "40"
    A.projetar({ 3, 3 }, "curso")
    conferir(ctx.tem_alerta_avaliacao == "true",
        "poucos trechos com muitos exercícios dispara o alerta", ctx.alerta_avaliacao)

    -- Fora de curso a tela não mostra nada disso.
    A.projetar(padrao, "guia")
    conferir(ctx.tem_aviso_avaliacao == "false" and ctx.resumo_avaliacao == "",
        "fora de curso a projeção fica muda")
end

return M
