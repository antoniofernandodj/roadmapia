--!nocheck
-- Suíte de `ui/scripts/lib/obra.luau` — a máquina de estados que coordena a produção.
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

-- `tests/luau/` fica fora da árvore de `ui/`, sem `lib/` irmão — navegação
-- explícita (`../`) é a forma de alcançar `ui/scripts/lib/` sem depender de
-- `GLACIER_LUAU_PATH` (que exigiria mudar variável de ambiente do processo).
local O = require("../../ui/scripts/lib/obra")
local P = require("lib/prompts")  -- via GLACIER_LUAU_PATH; ver `rodar_suites_luau`

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

    -- 6 capítulos (não 3): a seção 2 abaixo prova que 6 workers pegam 6
    -- tarefas SIMULTÂNEAS, e desde que os trechos de um mesmo capítulo saem
    -- em ordem (um de cada vez — ver seção 2b), isso só é possível com pelo
    -- menos 6 capítulos disponíveis ao mesmo tempo.
    local plano = assert(O.montar(esboco(6, 4), "curso-teste"))
    O.gravar_plano(plano)

    conferir(#plano.capitulos == 6, "montar cria os capítulos pedidos")
    conferir(plano.capitulos[1].subs[1].arquivo
        == "saidas/curso-teste/01-capitulo-1/01-trecho-1-1.md",
        "caminho do trecho é numerado e com slug",
        plano.capitulos[1].subs[1].arquivo)
    conferir(O.contar(plano).total == 6 * 4 + 6,
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

    -- ── 1b. as observações gerais chegam a TODA chamada paga ────────────────────
    --
    -- É a única coisa que a pessoa escreve uma vez e que precisa valer nas
    -- centenas de chamadas da produção. Perdê-la no meio do caminho não daria
    -- erro nenhum: a obra sairia inteira, cara, e ignorando o que foi pedido.
    -- Por isso a checagem é no PROMPT, o texto que de fato é enviado — e não
    -- em `plano.observacoes`, que provaria só que o campo existe.
    local OBS = "exemplos sempre em Rust; nada de analogias com culinária"
    local com_obs = assert(O.montar(esboco(2, 2), "obs", OBS))
    conferir(com_obs.observacoes == OBS, "montar guarda as observações no plano")

    local vizinhos = { antes = "", depois = "" }
    local trecho = P.secao(com_obs, com_obs.capitulos[1], com_obs.capitulos[1].subs[1], vizinhos)
    conferir(string.find(trecho, OBS, 1, true) ~= nil,
        "as observações entram no prompt de cada trecho")
    conferir(string.find(trecho, "elas vencem", 1, true) ~= nil,
        "o prompt diz que as observações vencem em caso de conflito")

    local abertura = P.abertura(com_obs, com_obs.capitulos[1], "- um trecho")
    conferir(string.find(abertura, OBS, 1, true) ~= nil,
        "as observações entram no prompt da abertura de capítulo")

    local plano_esboco = P.esboco("assunto", "curso", "transcrição", 3, 4, OBS)
    conferir(string.find(plano_esboco, OBS, 1, true) ~= nil,
        "as observações entram no prompt do esboço")

    -- Sem observações, nada de cabeçalho órfão: um "OBSERVAÇÕES:" seguido de
    -- nada é ruído que o modelo tenta interpretar.
    local sem_obs = assert(O.montar(esboco(1, 1), "sem-obs"))
    conferir(sem_obs.observacoes == "", "sem observações, o plano guarda string vazia")
    local trecho_sem = P.secao(sem_obs, sem_obs.capitulos[1], sem_obs.capitulos[1].subs[1], vizinhos)
    conferir(string.find(trecho_sem, "OBSERVAÇÕES DE QUEM PEDIU", 1, true) == nil,
        "sem observações, o bloco não aparece no prompt")
    conferir(string.find(P.esboco("a", "curso", "t", 1, 1), "OBSERVAÇÕES DE QUEM PEDIU", 1, true) == nil,
        "sem observações, o esboço também não ganha o bloco")

    -- ── 2. a fila, com workers intercalados ─────────────────────────────────────

    O.gravar_plano(plano)
    local N_WORKERS = 6
    local emvoo, vistas, total_saidas = {}, {}, 0
    local duplicadas = 0

    -- Cada volta simula um ponto de suspensão: workers pegam tarefas antes de
    -- qualquer um concluir, que é exatamente o entrelaçamento real do pool.
    -- Com 6 capítulos disponíveis, os 6 saem de capítulos DIFERENTES — nunca
    -- dois do mesmo capítulo ao mesmo tempo (ver seção 2b).
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

    -- ── 2b. um trecho por vez, por capítulo ──────────────────────────────────────
    --
    -- A garantia que a síntese acumulada depende: dentro de um capítulo, o
    -- trecho N só é liberado depois que o N-1 está PRONTO (ou ERRO) — nunca
    -- dois do mesmo capítulo "fazendo" ao mesmo tempo. Capítulos DIFERENTES
    -- continuam livres.

    O.gravar_plano(assert(O.montar(esboco(2, 5), "sequencial")))
    local a = O.tomar_tarefa()
    local b = O.tomar_tarefa()
    conferir(a ~= nil and b ~= nil and a.cap ~= b.cap,
        "com só 2 capítulos, os 2 primeiros trechos vêm de capítulos diferentes")
    conferir(O.tomar_tarefa() == nil,
        "um 3º trecho não sai: os 2 capítulos já têm um em voo cada")
    O.concluir(a, "conteúdo")
    local d = O.tomar_tarefa()
    conferir(d ~= nil and d.cap == a.cap and d.sub == a.sub + 1,
        "concluir libera o PRÓXIMO trecho do MESMO capítulo, em ordem")

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

    -- ── 4b. a síntese que cada trecho passa adiante ─────────────────────────────

    local corpo, sintese = O.extrair_sintese(
        "## Título\n\ncorpo do trecho\n\n<!--SINTESE-->\n- ponto um\n<!--/SINTESE-->"
    )
    conferir(corpo == "## Título\n\ncorpo do trecho",
        "extrair_sintese separa o corpo do bloco", corpo)
    conferir(sintese:find("ponto um", 1, true) ~= nil,
        "extrair_sintese devolve o conteúdo do bloco")

    local corpo2, sintese2 = O.extrair_sintese("só corpo, sem bloco nenhum")
    conferir(corpo2 == "só corpo, sem bloco nenhum", "sem o bloco, o corpo sai inteiro")
    conferir(sintese2 == "", "sem o bloco, a síntese sai vazia")

    -- `O.concluir` grava a síntese extraída no trecho, e o bloco some do
    -- arquivo — ele é para o PRÓXIMO trecho, não para quem lê a obra.
    arquivos = {}
    O.gravar_plano(assert(O.montar(esboco(1, 1), "sintese")))
    local t4 = O.tomar_tarefa()
    O.concluir(t4, "## X\n\ncorpo\n\n<!--SINTESE-->\n- resumo do trecho\n<!--/SINTESE-->")
    local sub_pronto = O.plano().capitulos[1].subs[1]
    conferir(sub_pronto.sintese:find("resumo do trecho", 1, true) ~= nil,
        "concluir grava a síntese extraída no trecho")
    local gravado = arquivos[sub_pronto.arquivo]
    conferir(gravado ~= nil and gravado:find("SINTESE", 1, true) == nil,
        "o bloco de síntese não vaza para o arquivo gravado")

    -- A abertura reaproveita o próprio texto como síntese do capítulo — sem
    -- chamada extra nenhuma.
    local abertura_tarefa = O.tomar_tarefa()
    conferir(abertura_tarefa ~= nil and abertura_tarefa.tipo == "abertura",
        "capítulo de 1 trecho libera a abertura em seguida")
    O.concluir(abertura_tarefa, "o capítulo 1 trata de X e Y")
    conferir(O.plano().capitulos[1].sintese:find("capítulo 1 trata de X e Y", 1, true) ~= nil,
        "a abertura vira a síntese do capítulo")

    -- ── 5. vizinhança (o que impede 200 textos repetidos) ───────────────────────

    O.gravar_plano(assert(O.montar(esboco(3, 3), "viz")))
    local v = O.vizinhanca(O.plano(), 2, 2)
    conferir(v.antes:find("Trecho 2.1", 1, true) ~= nil, "vizinhança inclui o trecho anterior")
    conferir(v.antes:find("Capítulo 1", 1, true) ~= nil, "vizinhança inclui capítulos anteriores")
    conferir(v.antes:find("Trecho 2.2", 1, true) == nil, "vizinhança não inclui o próprio trecho")
    conferir(v.depois:find("Trecho 2.3", 1, true) ~= nil, "vizinhança aponta o trecho seguinte")
    conferir(v.depois:find("Capítulo 3", 1, true) ~= nil, "vizinhança aponta capítulos seguintes")
    conferir(v.antes:find("Capítulo 3", 1, true) == nil, "o que vem depois não vaza para antes")

    -- Com síntese de verdade disponível, vizinhança usa ela em vez de só
    -- título/foco/resumo planejados.
    local plano_vs = O.plano()
    plano_vs.capitulos[1].sintese = "SINTESE-CAP-1"
    plano_vs.capitulos[2].subs[1].sintese = "SINTESE-SUB-2-1"
    O.gravar_plano(plano_vs)
    local vs1 = O.vizinhanca(O.plano(), 2, 2)
    conferir(vs1.antes:find("SINTESE-SUB-2-1", 1, true) ~= nil,
        "vizinhança usa a síntese de um trecho já escrito do mesmo capítulo")
    local vs2 = O.vizinhanca(O.plano(), 2, 1)
    conferir(vs2.antes:find("SINTESE-CAP-1", 1, true) ~= nil,
        "vizinhança usa a síntese de um capítulo anterior quando ela existe")

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
