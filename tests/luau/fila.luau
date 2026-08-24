--!nocheck
-- Suíte de `ui/lib/obra.luau` — a máquina de estados que coordena a produção.
--
-- É o código mais arriscado do app: seis workers puxam da mesma fila, e um
-- trecho pego duas vezes custa uma chamada paga a mais (× 200). A suíte simula
-- esses workers intercalados e cobra a invariante forte: **cada tarefa sai da
-- fila exatamente uma vez**.
--
-- Roda no interpretador do glacier (ver `suite.luau`), então `json` e `require`
-- aqui são os de verdade — não dublês. Só `write_file` é substituído, para as
-- gravações ficarem em memória e poderem ser inspecionadas.
--
-- `--!nocheck` porque um harness troca globais do motor de propósito; as
-- bibliotecas TESTADAS seguem verificadas normalmente.

local O = require("lib/obra")

local M = {}

local arquivos = {}

--- Esvazia a tabela `ctx` NO LUGAR. Um `ctx = {}` rebindaria a global, e a
--- partir daí o motor (e a própria `suite.luau`) estariam escrevendo noutra
--- tabela — os resultados da suíte simplesmente sumiriam.
local function limpar_ctx()
    for k in pairs(ctx) do
        ctx[k] = nil
    end
end

local function esboco(n_cap, n_sub)
    local e = { titulo = "Obra", resumo = "r", publico = "p", capitulos = {} }
    for i = 1, n_cap do
        local c = { titulo = "Capítulo " .. i, resumo = "res " .. i, subcapitulos = {} }
        for j = 1, n_sub do
            table.insert(c.subcapitulos, { titulo = "Trecho " .. i .. "." .. j, foco = "f" })
        end
        table.insert(e.capitulos, c)
    end
    return e
end

local function chave(t)
    return t.tipo .. ":" .. t.cap .. ":" .. tostring(t.sub)
end

function M.rodar()
    -- Dublê de disco: captura o que seria gravado, sem tocar no sistema de
    -- arquivos. O `write_file` real volta no fim.
    local write_file_real = write_file
    arquivos = {}
    write_file = function(caminho, conteudo)
        arquivos[caminho] = conteudo
        return true, nil
    end
    limpar_ctx()

    -- ── 1. montagem ─────────────────────────────────────────────────────────────

    local plano = assert(O.montar(esboco(3, 4), "curso-teste"))
    O.gravar_plano(plano)

    conferir(#plano.capitulos == 3, "montar cria os capítulos pedidos")
    conferir(plano.capitulos[1].subs[1].arquivo
        == "saidas/curso-teste/01-capitulo-1/01-trecho-1-1.md",
        "caminho do trecho é numerado e com slug",
        plano.capitulos[1].subs[1].arquivo)
    conferir(O.contar(plano).total == 3 * 4 + 3,
        "contar inclui a abertura de cada capítulo como tarefa")

    local sujo = {
        capitulos = {
            { titulo = "Bom", subcapitulos = { { titulo = "t" } } },
            { titulo = "Sem trechos", subcapitulos = {} },
            { naoTemTitulo = true },
            { titulo = "Com trecho ruim", subcapitulos = { { foco = "sem título" }, { titulo = "ok" } } },
        },
    }
    local p2 = assert(O.montar(sujo, "x"))
    conferir(#p2.capitulos == 2, "montar descarta capítulo sem trechos e sem título")
    conferir(#p2.capitulos[2].subs == 1, "montar descarta trecho sem título")
    conferir(select(1, O.montar({}, "x")) == nil, "montar rejeita esboço sem capítulos")

    -- ── 2. a fila, com workers intercalados ─────────────────────────────────────

    O.gravar_plano(plano)
    local N_WORKERS = 6
    local emvoo, vistas, total_saidas = {}, {}, 0
    local duplicadas = 0

    -- Cada volta simula um ponto de suspensão: workers pegam tarefas antes de
    -- qualquer um concluir, que é exatamente o entrelaçamento real do pool.
    for _ = 1, N_WORKERS do
        local t = O.tomar_tarefa()
        if t then table.insert(emvoo, t) end
    end
    conferir(#emvoo == N_WORKERS, "seis workers pegam seis tarefas")

    for _, t in ipairs(emvoo) do
        if vistas[chave(t)] then duplicadas = duplicadas + 1 end
        vistas[chave(t)] = true
    end
    conferir(duplicadas == 0, "nenhuma tarefa saiu duas vezes na primeira leva")

    -- Drena tudo, sempre com o pool cheio, concluindo e pegando de forma alternada.
    while #emvoo > 0 do
        local t = table.remove(emvoo, 1)
        O.concluir(t, "conteúdo de " .. chave(t))
        total_saidas = total_saidas + 1
        local novo = O.tomar_tarefa()
        if novo then
            if vistas[chave(novo)] then duplicadas = duplicadas + 1 end
            vistas[chave(novo)] = true
            table.insert(emvoo, novo)
        end
    end

    local depois = O.plano()
    local c = O.contar(depois)
    conferir(duplicadas == 0, "nenhuma tarefa saiu duas vezes na drenagem inteira")
    conferir(total_saidas == c.total,
        "a fila entrega exatamente o total de tarefas",
        total_saidas .. " de " .. c.total)
    conferir(c.prontos == c.total, "tudo termina pronto", c.prontos .. "/" .. c.total)
    conferir(O.tomar_tarefa() == nil, "fila vazia devolve nil")

    -- ── 3. a abertura espera os trechos ─────────────────────────────────────────

    O.gravar_plano(assert(O.montar(esboco(2, 3), "ordem")))
    local ordem = {}
    while true do
        local t = O.tomar_tarefa()
        if t == nil then break end
        table.insert(ordem, t)
        O.concluir(t, "x")
    end
    local primeira_abertura, ultimo_trecho_cap1
    for i, t in ipairs(ordem) do
        if t.tipo == "abertura" and t.cap == 1 and not primeira_abertura then
            primeira_abertura = i
        end
        if t.tipo == "trecho" and t.cap == 1 then
            ultimo_trecho_cap1 = i
        end
    end
    conferir(primeira_abertura ~= nil and primeira_abertura > ultimo_trecho_cap1,
        "a abertura do capítulo só sai depois de todos os trechos dele")

    -- ── 4. falhas e retomada ────────────────────────────────────────────────────

    O.gravar_plano(assert(O.montar(esboco(2, 3), "falhas")))
    local t1 = O.tomar_tarefa()
    local t2 = O.tomar_tarefa()
    O.concluir(t1, "ok")
    O.falhar(t2, "500 do servidor")
    local preso = O.tomar_tarefa() -- fica em "fazendo", como se o app fechasse aqui

    conferir(O.contar(O.plano()).erros == 1, "falhar marca erro")
    local devolvidas = O.reenfileirar_falhas()
    conferir(devolvidas == 2, "refazer falhas recupera o que falhou E o que ficou preso",
        tostring(devolvidas))
    conferir(O.contar(O.plano()).erros == 0, "depois de reenfileirar não há erro pendente")
    conferir(preso ~= nil, "havia mesmo uma tarefa presa em fazendo")

    -- `reenfileirar` (recuo por rate limit) devolve sem marcar erro.
    local t3 = O.tomar_tarefa()
    O.reenfileirar(t3)
    conferir(O.contar(O.plano()).erros == 0, "reenfileirar não marca erro")
    conferir(chave(O.tomar_tarefa()) == chave(t3), "a tarefa reenfileirada volta a sair")

    -- ── 5. vizinhança (o que impede 200 textos repetidos) ───────────────────────

    O.gravar_plano(assert(O.montar(esboco(3, 3), "viz")))
    local v = O.vizinhanca(O.plano(), 2, 2)
    conferir(v.antes:find("Trecho 2.1", 1, true) ~= nil, "vizinhança inclui o trecho anterior")
    conferir(v.antes:find("Capítulo 1", 1, true) ~= nil, "vizinhança inclui capítulos anteriores")
    conferir(v.antes:find("Trecho 2.2", 1, true) == nil, "vizinhança não inclui o próprio trecho")
    conferir(v.depois:find("Trecho 2.3", 1, true) ~= nil, "vizinhança aponta o trecho seguinte")
    conferir(v.depois:find("Capítulo 3", 1, true) ~= nil, "vizinhança aponta capítulos seguintes")
    conferir(v.antes:find("Capítulo 3", 1, true) == nil, "o que vem depois não vaza para antes")

    -- ── 6. índices em disco ─────────────────────────────────────────────────────

    arquivos = {}
    O.gravar_plano(assert(O.montar(esboco(2, 2), "indices")))
    while true do
        local t = O.tomar_tarefa()
        if t == nil then break end
        O.concluir(t, "corpo")
    end
    O.gravar_sumario()

    local sumario = arquivos["saidas/indices/README.md"]
    conferir(sumario ~= nil, "o sumário da obra é gravado")
    conferir(sumario and sumario:find("01-capitulo-1/01-trecho-1-1.md", 1, true) ~= nil,
        "o sumário linka os arquivos dos trechos")
    local abertura = arquivos["saidas/indices/01-capitulo-1/README.md"]
    conferir(abertura ~= nil and abertura:find("# Capítulo 1", 1, true) == 1,
        "a abertura do capítulo ganha título próprio")
    conferir(abertura and abertura:find("(01-trecho-1-1.md)", 1, true) ~= nil,
        "a abertura linka os trechos do capítulo")

    local n_md = 0
    for _ in pairs(arquivos) do n_md = n_md + 1 end
    conferir(n_md == 2 * 2 + 2 + 1, "um arquivo por trecho + um por capítulo + o sumário",
        tostring(n_md))

    -- ── 7. gravar o plano projeta a tela ────────────────────────────────────────

    -- A invariante que custou o bug de "gerou a pasta mas não gerou os arquivos":
    -- gravar um plano SEMPRE publica as chaves que a tela lê. Antes eram dois
    -- passos, e `gerar` fazia só o primeiro — a tela ficava dizendo "Nada
    -- planejado ainda" em cima de um plano gravado, sem botão para produzir.
    limpar_ctx()
    conferir(ctx.tem_obra == nil, "contexto começa limpo")
    O.gravar_plano(assert(O.montar(esboco(2, 3), "projecao")))
    conferir(ctx.tem_obra == "true", "gravar o plano acende a tela", tostring(ctx.tem_obra))
    conferir(ctx.total_tarefas == "8", "…com as contagens certas (2x3 + 2 aberturas)",
        tostring(ctx.total_tarefas))
    conferir(ctx.obra_pasta == "saidas/projecao", "…e a pasta", tostring(ctx.obra_pasta))
    conferir(ctx.capitulos_ui ~= nil and ctx.capitulos_ui ~= "[]",
        "…e a lista de capítulos")
    conferir(ctx.nada_a_fazer == "false", "…com o botão de produzir liberado")

    -- E acompanha o avanço: concluir uma tarefa atualiza a tela sem passo extra.
    local t = O.tomar_tarefa()
    O.concluir(t, "x")
    conferir(ctx.prontos == "1", "concluir atualiza a contagem na tela", tostring(ctx.prontos))

    -- Sem plano, a tela volta a dizer que não há nada.
    limpar_ctx()
    O.projetar()
    conferir(ctx.tem_obra == "false", "sem plano, a tela se declara vazia")

    write_file = write_file_real
    limpar_ctx()
end

return M
