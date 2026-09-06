--!nolint
-- Exercícios e prova de um curso: os números que a pessoa configura e a
-- aritmética que os transforma em tarefas.
--
-- O PROBLEMA. Dez exercícios com solução comentada não cabem numa resposta só
-- — é o mesmo teto de saída que já obriga o app a escrever um trecho por
-- chamada. Então os dez saem em duas chamadas de cinco. Só que as duas correm
-- ao mesmo tempo e nenhuma sabe o que a outra escreveu: mandando "escreva 5
-- exercícios sobre o capítulo 3" nas duas, as duas olham o capítulo inteiro,
-- escolhem os assuntos mais óbvios dele e devolvem exercícios repetidos —
-- dez pagos, seis distintos.
--
-- A SOLUÇÃO. Dividir o capítulo entre elas. A primeira chamada recebe os
-- trechos 1 a 10; a segunda, os 11 a 20. Não é um pedido ("por favor não
-- repita"), que o modelo pode ignorar: é impossibilidade — as duas estão
-- olhando para material diferente.
--
--   Capítulo 3, 20 trechos:
--     trecho 1 ──────────── 10 │ trecho 11 ──────────── 20
--     └── lote 1: 5 exercícios ┘ └── lote 2: 5 exercícios ┘
--
-- A prova é a mesma ideia um nível acima: 40 questões viram 4 chamadas de 10,
-- e cada uma recebe um quarto dos trechos DA OBRA em vez do curso inteiro.
-- Assim a prova cobre tudo, de ponta a ponta, sem buraco e sem repetição.
--
-- Como cada pedaço é conhecido de antemão, o prompt recebe junto a SÍNTESE de
-- cada trecho que ele cobre (o bloco `<!--SINTESE-->` que o autor já devolve).
-- É o que faz o exercício cobrar o que foi ESCRITO, e não o que estava no
-- plano — se o trecho saiu diferente do planejado, o exercício acompanha.
--
-- Este módulo é quase todo função pura: entra número, sai número. É de
-- propósito — as fronteiras (um capítulo com menos trechos que lotes, um
-- resto que não divide) são onde este tipo de conta erra, e `tests/luau/
-- avaliacao.luau` as cobre sem plano, sem `ctx` e sem rede.

local A = {}

-- ── os limites ──────────────────────────────────────────────────────────────

-- Quanto rende UMA chamada. Cinco exercícios com enunciado, contexto e solução
-- comentada é o que cabe com folga nos 8000 tokens de teto que `producao.luau`
-- concede a um trecho; dez questões de prova cabem porque a resposta de cada
-- uma é curta.
A.LOTE_EXERCICIOS = 5
A.QUESTOES_POR_PARTE = 10

-- Acima disto a chamada fica apertada e a qualidade cai (enunciados curtos,
-- soluções sem código). Não é um erro — é um aviso na tela, porque o caso que
-- leva até aqui é legítimo: uma obra de poucos trechos com muitos exercícios
-- pedidos não tem por onde dividir mais.
A.MAX_EXERCICIOS_POR_LOTE = 8
A.MAX_QUESTOES_POR_PARTE = 15

-- O que a tela oferece e até onde deixa ir. 10 por capítulo dão 100 exercícios
-- na obra padrão (10 capítulos); 40 questões são uma prova de verdade.
A.PADRAO_EXERCICIOS = 10
A.PADRAO_QUESTOES = 40
A.MAX_EXERCICIOS = 40
A.MAX_QUESTOES = 120

export type Faixa = {
    de: number,
    ate: number,
    n: number,
}

export type Config = {
    exercicios_por_capitulo: number,
    questoes_prova: number,
}

-- ── aritmética pura ─────────────────────────────────────────────────────────

--- Divide `1..total` em `n` pedaços contíguos, o mais parelhos possível. Os
--- primeiros ficam com o resto: `faixas(7, 3)` dá `1-3`, `4-5`, `6-7`.
---
--- Contíguos e sem sobreposição é a propriedade inteira deste módulo — é o que
--- garante que dois lotes não possam escrever o mesmo exercício.
function A.faixas(total: number, n: number): { { de: number, ate: number } }
    local saida = {}
    if total < 1 or n < 1 then
        return saida
    end
    if n > total then
        n = total
    end
    local base = math.floor(total / n)
    local resto = total % n
    local cursor = 1
    for i = 1, n do
        local tamanho = base + ((i <= resto) and 1 or 0)
        table.insert(saida, { de = cursor, ate = cursor + tamanho - 1 })
        cursor += tamanho
    end
    return saida
end

--- Reparte `n` itens entre `pedacos` pedaços, resto para os primeiros. A soma
--- é sempre exatamente `n` — é o que garante que a pessoa receba o número de
--- exercícios que pediu, nem um a mais nem um a menos.
function A.distribuir(n: number, pedacos: number): { number }
    local saida = {}
    if pedacos < 1 then
        return saida
    end
    local base = math.floor(n / pedacos)
    local resto = n % pedacos
    for i = 1, pedacos do
        table.insert(saida, base + ((i <= resto) and 1 or 0))
    end
    return saida
end

--- O plano de lotes: quantas chamadas, cada uma cobrindo que trechos e
--- escrevendo quantos exercícios.
---
--- `por_chamada` é o alvo, não um teto: o `math.min` com `total_trechos` é o
--- que impede o caso degenerado de um capítulo de 3 trechos com 40 exercícios
--- pedidos virar 8 lotes brigando por 3 trechos. Ali os lotes ficam gordos (e
--- a tela avisa), mas continuam disjuntos.
function A.lotes(total_trechos: number, n_itens: number, por_chamada: number): { Faixa }
    if total_trechos < 1 or n_itens < 1 then
        return {}
    end
    local quantos = math.ceil(n_itens / por_chamada)
    if quantos < 1 then
        quantos = 1
    end
    if quantos > total_trechos then
        quantos = total_trechos
    end

    local faixas = A.faixas(total_trechos, quantos)
    local quotas = A.distribuir(n_itens, #faixas)
    local saida: { Faixa } = {}
    for i, f in ipairs(faixas) do
        table.insert(saida, { de = f.de, ate = f.ate, n = quotas[i] })
    end
    return saida
end

--- Os lotes de exercícios de UM capítulo, pelos seus trechos.
function A.lotes_exercicios(n_trechos: number, n_exercicios: number): { Faixa }
    return A.lotes(n_trechos, n_exercicios, A.LOTE_EXERCICIOS)
end

--- As partes da prova, pelos trechos da OBRA (não de um capítulo).
function A.partes_prova(n_trechos_obra: number, n_questoes: number): { Faixa }
    return A.lotes(n_trechos_obra, n_questoes, A.QUESTOES_POR_PARTE)
end

--- O maior lote de uma lista — o que dispara o aviso de qualidade.
function A.maior(faixas: { Faixa }): number
    local maior = 0
    for _, f in ipairs(faixas) do
        if f.n > maior then
            maior = f.n
        end
    end
    return maior
end

-- ── a entrada da tela ───────────────────────────────────────────────────────

--- Um número digitado num `<input>` — que é texto, e texto que uma pessoa
--- está no meio de digitar.
---
--- Aceita vírgula (é um app em português; "7,5" é o que se digita) e trunca:
--- meio exercício não existe. Campo vazio cai no padrão em vez de zero — quem
--- quer zero desliga no checkbox, e apagar o campo para redigitar não pode
--- significar "não quero nada". O que a conta usa aparece sempre no aviso
--- abaixo do campo, então o padrão nunca age escondido.
function A.sanear(texto: any, padrao: number, maximo: number): number
    local bruto = tostring(texto or ""):gsub(",", ".")
    local n = tonumber(bruto)
    if n == nil then
        return padrao
    end
    n = math.floor(n)
    if n < 0 then
        return 0
    end
    if n > maximo then
        return maximo
    end
    return n
end

--- Os números que valem AGORA, lidos do contexto.
---
--- Fora de "curso" a avaliação é sempre zero, e é aqui que isso se decide (não
--- na tela): marcar guia depois de configurar exercícios não pode produzir um
--- guia com prova. Os valores digitados ficam guardados no contexto assim
--- mesmo — voltar para curso os encontra intactos.
function A.config(tipo: string?): Config
    if (tipo or "") ~= "curso" then
        return { exercicios_por_capitulo = 0, questoes_prova = 0 }
    end
    local ex = 0
    if ctx.quer_exercicios == "true" then
        ex = A.sanear(ctx.n_exercicios, A.PADRAO_EXERCICIOS, A.MAX_EXERCICIOS)
    end
    local qu = 0
    if ctx.quer_prova == "true" then
        qu = A.sanear(ctx.n_questoes, A.PADRAO_QUESTOES, A.MAX_QUESTOES)
    end
    return { exercicios_por_capitulo = ex, questoes_prova = qu }
end

--- Semeia os padrões no contexto, sem pisar no que já está lá. Roda no `init`
--- de `inicio`.
function A.aplicar_padroes()
    if (ctx.quer_exercicios or "") == "" then
        ctx.quer_exercicios = "true"
    end
    if (ctx.quer_prova or "") == "" then
        ctx.quer_prova = "true"
    end
    if (ctx.n_exercicios or "") == "" then
        ctx.n_exercicios = tostring(A.PADRAO_EXERCICIOS)
    end
    if (ctx.n_questoes or "") == "" then
        ctx.n_questoes = tostring(A.PADRAO_QUESTOES)
    end
end

-- ── o que a tela mostra ─────────────────────────────────────────────────────

--- Quantas tarefas a avaliação acrescenta a uma obra com estes capítulos.
--- `trechos_por_capitulo` é uma lista: `{20, 20, …}` na obra padrão, ou a
--- forma real do esboço quando ele já existe.
function A.contar_tarefas(
    trechos_por_capitulo: { number },
    cfg: Config
): { lotes: number, partes: number, trechos: number, maior_lote: number, maior_parte: number }
    local total_trechos = 0
    local lotes, maior_lote = 0, 0
    for _, t in ipairs(trechos_por_capitulo) do
        total_trechos += t
        local f = A.lotes_exercicios(t, cfg.exercicios_por_capitulo)
        lotes += #f
        maior_lote = math.max(maior_lote, A.maior(f))
    end
    local partes = A.partes_prova(total_trechos, cfg.questoes_prova)
    return {
        lotes = lotes,
        partes = #partes,
        trechos = total_trechos,
        maior_lote = maior_lote,
        maior_parte = A.maior(partes),
    }
end

--- Publica o aviso de custo e o alerta de qualidade. Este app mostra o preço
--- antes de cobrar — é a razão de existir da amostra em `producao.luau` — e um
--- par de campos que multiplica chamadas sem dizer isso na cara seria uma
--- regressão dessa cultura.
function A.projetar(trechos_por_capitulo: { number }, tipo: string?)
    local eh_curso = (tipo or "") == "curso"
    ctx.tipo_e_curso = eh_curso and "true" or "false"
    if not eh_curso then
        ctx.aviso_avaliacao = ""
        ctx.tem_aviso_avaliacao = "false"
        ctx.alerta_avaliacao = ""
        ctx.tem_alerta_avaliacao = "false"
        ctx.resumo_avaliacao = ""
        return
    end

    local cfg = A.config(tipo)
    local c = A.contar_tarefas(trechos_por_capitulo, cfg)
    local extras = c.lotes + c.partes
    local base = c.trechos + #trechos_por_capitulo

    if extras == 0 then
        ctx.aviso_avaliacao = "Sem exercícios e sem prova — só o texto do curso."
        ctx.tem_aviso_avaliacao = "true"
    else
        local pedacos = {}
        if c.lotes > 0 then
            table.insert(pedacos, tostring(c.lotes) .. " "
                .. ((c.lotes == 1) and "lote de exercícios" or "lotes de exercícios"))
        end
        if c.partes > 0 then
            table.insert(pedacos, tostring(c.partes) .. " "
                .. ((c.partes == 1) and "parte de prova" or "partes de prova"))
        end
        local pct = (base > 0) and math.floor((extras / base) * 100 + 0.5) or 0
        ctx.aviso_avaliacao = "+ " .. tostring(extras) .. " chamadas ("
            .. table.concat(pedacos, ", ") .. ") — cerca de +" .. tostring(pct)
            .. "% no custo da obra."
        ctx.tem_aviso_avaliacao = "true"
    end

    -- O alerta de qualidade: o caso legítimo em que não há por onde dividir.
    local alertas = {}
    if c.maior_lote > A.MAX_EXERCICIOS_POR_LOTE then
        table.insert(alertas, "lotes de até " .. tostring(c.maior_lote)
            .. " exercícios (uma chamada rende ~" .. tostring(A.MAX_EXERCICIOS_POR_LOTE) .. ")")
    end
    if c.maior_parte > A.MAX_QUESTOES_POR_PARTE then
        table.insert(alertas, "partes de até " .. tostring(c.maior_parte)
            .. " questões (uma chamada rende ~" .. tostring(A.MAX_QUESTOES_POR_PARTE) .. ")")
    end
    if #alertas > 0 then
        ctx.alerta_avaliacao = "Poucos trechos para tanta coisa: "
            .. table.concat(alertas, " e ") .. ". A densidade cai; considere menos."
        ctx.tem_alerta_avaliacao = "true"
    else
        ctx.alerta_avaliacao = ""
        ctx.tem_alerta_avaliacao = "false"
    end

    local resumo = { tostring(#trechos_por_capitulo) .. " capítulos",
        tostring(c.trechos) .. " trechos" }
    if c.lotes > 0 then
        table.insert(resumo, tostring(c.lotes) .. " lotes de exercícios")
    end
    if c.partes > 0 then
        table.insert(resumo, tostring(c.partes) .. " partes de prova")
    end
    ctx.resumo_avaliacao = table.concat(resumo, " · ")
end

return A
