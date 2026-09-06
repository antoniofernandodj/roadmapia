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

-- `tostring` em tudo porque uma parte de prova não tem `cap` (ela atravessa a
-- obra inteira) e um trecho não tem `idx`: concatenar `nil` cru estouraria.
local function chave(t)
    return t.tipo .. ":" .. tostring(t.cap) .. ":" .. tostring(t.sub)
        .. ":" .. tostring(t.idx)
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

    -- ── 8. exercícios e prova ───────────────────────────────────────────────────
    --
    -- Dois tipos de tarefa a mais na mesma fila. O risco é o de sempre, e é
    -- pago: uma tarefa que sai duas vezes é uma chamada cobrada duas vezes.
    -- O risco NOVO é a dependência — um exercício escrito antes do trecho que
    -- ele cobra fala do PLANO do trecho, não do texto dele.

    local CFG = { exercicios_por_capitulo = 10, questoes_prova = 20 }
    arquivos = {}
    local pa = assert(O.montar(esboco(2, 4), "avaliacao", nil, CFG))
    O.gravar_plano(pa)

    -- 4 trechos por capítulo e 10 exercícios pedidos: 2 lotes de 5, cobrindo
    -- os trechos 1-2 e 3-4. É a divisão que impede os dois de escreverem o
    -- mesmo exercício — eles não recebem o mesmo material.
    local lotes1 = O.lotes_de(pa.capitulos[1])
    conferir(#lotes1 == 2, "10 exercícios num capítulo de 4 trechos viram 2 lotes",
        tostring(#lotes1))
    conferir(lotes1[1].de == 1 and lotes1[1].ate == 2
        and lotes1[2].de == 3 and lotes1[2].ate == 4,
        "os lotes cobrem faixas contíguas e disjuntas de trechos")
    conferir(lotes1[1].n == 5 and lotes1[2].n == 5, "e repartem os 10 exercícios")
    conferir(lotes1[1].arquivo == "saidas/avaliacao/01-capitulo-1/exercicios-01.md",
        "o arquivo do lote fica dentro do capítulo", lotes1[1].arquivo)

    local partes = O.prova_de(pa)
    conferir(#partes == 2, "20 questões viram 2 partes de prova", tostring(#partes))
    conferir(partes[1].de == 1 and partes[1].ate == 4
        and partes[2].de == 5 and partes[2].ate == 8,
        "as partes dividem os trechos da OBRA, não de um capítulo")
    conferir(partes[1].arquivo == "saidas/avaliacao/prova/parte-01.md",
        "a prova mora numa pasta própria", partes[1].arquivo)

    -- 8 trechos + 2 aberturas + 4 lotes + 2 partes.
    conferir(O.contar(pa).total == 16, "contar inclui exercícios e prova",
        tostring(O.contar(pa).total))

    -- A drenagem inteira, cobrando as duas invariantes ao mesmo tempo: nada
    -- sai duas vezes, e nada sai antes do material que cobre.
    --
    -- A checagem da dependência olha os STATUS crus, e de propósito não chama
    -- `O.faixa_resolvida`: usar a mesma função que a fila usa para decidir
    -- tornaria o teste tautológico — arrancar a guarda de `tomar_tarefa`
    -- passaria despercebido, porque as duas pontas concordariam em estar
    -- erradas. (Verificado: com a guarda removida, este teste falha.)
    local function trechos_prontos(subs, de, ate): boolean
        for k = de, ate do
            local s = subs[k]
            if s == nil or (s.status ~= "pronto" and s.status ~= "erro") then
                return false
            end
        end
        return true
    end

    -- O pool tem de ficar CHEIO: é com trechos em voo (status "fazendo") que a
    -- dependência é exercitada. Drenando um de cada vez — pega, conclui, pega —
    -- nunca há trecho pendurado, `tomar_tarefa` esvazia os trechos antes de
    -- olhar para os lotes, e a guarda jamais é consultada. Foi assim que a
    -- primeira versão deste teste passou com a guarda arrancada.
    local ordem, vistas_av, dup_av, fora_de_hora = {}, {}, 0, 0
    local emvoo_av = {}
    while true do
        while #emvoo_av < 6 do
            local t = O.tomar_tarefa()
            if t == nil then
                break
            end
            if vistas_av[chave(t)] then
                dup_av += 1
            end
            vistas_av[chave(t)] = true

            local pl = O.plano()
            if t.tipo == "exercicios" then
                local cap = pl.capitulos[t.cap]
                local lote = O.lotes_de(cap)[t.idx]
                if not trechos_prontos(cap.subs, lote.de, lote.ate) then
                    fora_de_hora += 1
                end
            elseif t.tipo == "prova" then
                local globais = {}
                for i, x in ipairs(O.trechos_planos(pl)) do
                    globais[i] = x.sub
                end
                local parte = O.prova_de(pl)[t.idx]
                if not trechos_prontos(globais, parte.de, parte.ate) then
                    fora_de_hora += 1
                end
            end
            table.insert(ordem, t)
            table.insert(emvoo_av, t)
        end
        if #emvoo_av == 0 then
            break
        end
        local feita = table.remove(emvoo_av, 1)
        O.concluir(feita, "texto de " .. chave(feita))
    end

    conferir(dup_av == 0, "com exercícios e prova, nenhuma tarefa sai duas vezes")
    conferir(#ordem == 16, "a fila entrega as 16 tarefas", tostring(#ordem))
    conferir(fora_de_hora == 0,
        "nenhum lote nem parte sai antes dos trechos que ele cobra",
        tostring(fora_de_hora) .. " fora de hora")
    conferir(O.contar(O.plano()).prontos == 16, "tudo termina pronto")

    -- Um lote não passa síntese adiante (ninguém escreve em cima dele) e o
    -- texto vai INTEIRO para o arquivo — nada de recorte.
    local lote_pronto = O.plano().capitulos[1].exercicios[1]
    conferir(lote_pronto.status == "pronto", "o lote termina pronto")
    conferir(lote_pronto.sintese == nil, "um lote não ganha campo de síntese")
    conferir(arquivos[lote_pronto.arquivo] ~= nil, "o lote grava o arquivo dele")
    conferir(arquivos[O.prova_de(O.plano())[1].arquivo] ~= nil,
        "a parte de prova grava o arquivo dela")

    -- ── 8a. o recorte que vira prompt ───────────────────────────────────────────
    --
    -- Off-by-one aqui não daria erro nenhum: o lote sairia escrito, cobrado, e
    -- cobrando um trecho que não é dele — ou deixando um sem exercício. Por
    -- isso o recorte mora em `obra.luau` (ao lado de `O.vizinhanca`, que faz o
    -- mesmo tipo de projeção) e não na tela, que a suíte não alcança.

    local pl_rec = O.plano()
    local cap_rec = pl_rec.capitulos[1]
    cap_rec.subs[1].sintese = "SINTESE-DO-TRECHO-1"
    local dentro, fora = O.linhas_do_lote(cap_rec, O.lotes_de(cap_rec)[1])
    conferir(dentro:find("Trecho 1.1", 1, true) ~= nil
        and dentro:find("Trecho 1.2", 1, true) ~= nil,
        "o lote 1 recebe os trechos 1 e 2 do capítulo", dentro)
    conferir(dentro:find("Trecho 1.3", 1, true) == nil,
        "…e não os do lote seguinte", dentro)
    conferir(dentro:find("SINTESE-DO-TRECHO-1", 1, true) ~= nil,
        "…com a síntese do que o trecho ensinou, não com o foco planejado")
    conferir(fora:find("Trecho 1.3", 1, true) ~= nil
        and fora:find("Trecho 1.1", 1, true) == nil,
        "a fronteira lista só o que é de outro lote", fora)

    -- A prova recorta a obra ACHATADA: a parte 2 começa no capítulo 2, e cada
    -- linha diz de que capítulo veio.
    local linhas_p2 = O.linhas_da_prova(pl_rec, O.prova_de(pl_rec)[2])
    conferir(linhas_p2:find("Trecho 2.1", 1, true) ~= nil,
        "a parte 2 da prova cobre os trechos 5 a 8 — os do capítulo 2", linhas_p2)
    conferir(linhas_p2:find("Trecho 1.1", 1, true) == nil,
        "…e nenhum do capítulo 1, que é da parte 1")
    conferir(linhas_p2:find("(cap. 2)", 1, true) ~= nil,
        "…dizendo de que capítulo cada trecho veio")

    -- ── 8b. os prompts novos ────────────────────────────────────────────────────
    --
    -- Mesma exigência da seção 1b: as observações gerais valem em TODA chamada
    -- paga, e estas duas são chamadas pagas como qualquer outra.

    local ex = P.exercicios(com_obs, com_obs.capitulos[1], "1. T: sintese", "- outro", 5)
    conferir(string.find(ex, OBS, 1, true) ~= nil,
        "as observações entram no prompt dos exercícios")
    conferir(string.find(ex, "EXATAMENTE 5", 1, true) ~= nil,
        "o prompt pede o número exato de exercícios do lote")
    conferir(string.find(ex, "- outro", 1, true) ~= nil,
        "…e diz quais trechos são de outro lote")
    local ex_sem_fora = P.exercicios(com_obs, com_obs.capitulos[1], "1. T: s", "", 3)
    conferir(string.find(ex_sem_fora, "NÃO são seus", 1, true) == nil,
        "lote único não ganha bloco de fronteira vazio")

    local pr = P.prova(com_obs, "(cap. 1) T: sintese", 10, 2, 4)
    conferir(string.find(pr, OBS, 1, true) ~= nil,
        "as observações entram no prompt da prova")
    conferir(string.find(pr, "EXATAMENTE", 1, true) ~= nil,
        "o prompt pede o número exato de questões")
    conferir(string.find(pr, "parte 2 de 4", 1, true) ~= nil,
        "a parte sabe qual pedaço da prova ela é")

    -- A síntese que cada trecho devolve passou a incluir o exercício com que
    -- ele terminou — é o que deixa a lista do capítulo não repetir o que o
    -- texto já propôs.
    local sec = P.secao(com_obs, com_obs.capitulos[1], com_obs.capitulos[1].subs[1], vizinhos)
    conferir(string.find(sec, "Exercício proposto:", 1, true) ~= nil,
        "a síntese do trecho passa adiante o exercício que ele propôs")
    conferir(string.find(ex, "NÃO repita", 1, true) ~= nil,
        "…e a lista do capítulo é instruída a não repeti-lo")

    -- ── 8c. falhar e refazer um lote e uma parte ────────────────────────────────
    --
    -- O caminho que o refactor do `O.alvo_de` existe para proteger: uma tarefa
    -- nova que funcionasse ao CONCLUIR e vazasse em "fazendo" ao FALHAR ficaria
    -- presa para sempre, sem aparecer em "refazer falhas".

    O.gravar_plano(assert(O.montar(esboco(1, 2), "falha-av", nil,
        { exercicios_por_capitulo = 2, questoes_prova = 5 })))
    local falhadas = {}
    while true do
        local t = O.tomar_tarefa()
        if t == nil then
            break
        end
        if t.tipo == "exercicios" or t.tipo == "prova" then
            O.falhar(t, "500 do servidor")
            table.insert(falhadas, t)
        else
            O.concluir(t, "x")
        end
    end
    conferir(#falhadas == 2, "saiu um lote e uma parte", tostring(#falhadas))
    conferir(O.contar(O.plano()).erros == 2, "falhar marca erro em lote e em parte",
        tostring(O.contar(O.plano()).erros))
    conferir(O.reenfileirar_falhas() == 2, "refazer falhas alcança lote e parte")

    local voltou = O.tomar_tarefa()
    conferir(voltou ~= nil and (voltou.tipo == "exercicios" or voltou.tipo == "prova"),
        "e eles voltam a sair")
    O.reenfileirar(voltou)
    conferir(O.contar(O.plano()).erros == 0, "reenfileirar um lote não marca erro")
    conferir(chave(O.tomar_tarefa()) == chave(voltou),
        "o lote reenfileirado por rate limit volta a sair")

    -- ── 8d. os índices em disco ─────────────────────────────────────────────────

    arquivos = {}
    O.gravar_plano(assert(O.montar(esboco(2, 2), "indices-av", nil,
        { exercicios_por_capitulo = 4, questoes_prova = 10 })))
    while true do
        local t = O.tomar_tarefa()
        if t == nil then
            break
        end
        O.concluir(t, "corpo")
    end
    O.gravar_sumario()

    local cap_readme = arquivos["saidas/indices-av/01-capitulo-1/README.md"]
    conferir(cap_readme ~= nil and cap_readme:find("## Exercícios", 1, true) ~= nil,
        "a abertura do capítulo lista os exercícios dele")
    conferir(cap_readme ~= nil and cap_readme:find("(exercicios-01.md)", 1, true) ~= nil,
        "…com link para o arquivo")
    local raiz = arquivos["saidas/indices-av/README.md"]
    conferir(raiz ~= nil and raiz:find("Prova final", 1, true) ~= nil,
        "o sumário da obra anuncia a prova")
    local prova_readme = arquivos["saidas/indices-av/prova/README.md"]
    conferir(prova_readme ~= nil, "o índice da prova é gravado — sem chamada nenhuma")
    conferir(prova_readme ~= nil and prova_readme:find("Parte 1", 1, true) ~= nil,
        "…listando as partes")

    -- 4 trechos + 2 aberturas + 2 lotes + 1 parte + sumário + índice da prova.
    local n_av = 0
    for _ in pairs(arquivos) do
        n_av += 1
    end
    conferir(n_av == 11, "um arquivo por tarefa, mais os dois índices", tostring(n_av))

    -- ── 8e. planos de antes desta versão ────────────────────────────────────────
    --
    -- Um `obra_json` gravado por uma versão anterior não tem `exercicios` nem
    -- `prova`. Retomar uma produção daquelas não pode explodir nem mudar de
    -- contagem no meio.

    local antigo = assert(O.montar(esboco(1, 2), "antigo"))
    conferir(#O.lotes_de(antigo.capitulos[1]) == 0, "sem avaliação, nenhum lote")
    conferir(#O.prova_de(antigo) == 0, "sem avaliação, nenhuma parte de prova")

    antigo.capitulos[1].exercicios = nil
    antigo.prova = nil
    O.gravar_plano(antigo)
    conferir(O.contar(O.plano()).total == 3,
        "plano sem os campos novos conta como sempre contou",
        tostring(O.contar(O.plano()).total))
    conferir(O.tomar_tarefa() ~= nil, "…e continua produzindo")
    conferir(ctx.tem_prova == "false", "…e a tela não anuncia prova nenhuma")

    -- ── 9. quanto um trecho sabe do resto da obra ───────────────────────────────
    --
    -- A repetição entre capítulos (o `unsafe` ensinado do zero no capítulo 7
    -- depois de já ter sido ensinado no 1 e no 2) tem duas causas, e esta é a
    -- da PRODUÇÃO: um trecho de um capítulo posterior mal sabe o que os
    -- anteriores ensinaram.
    --
    -- A causa era a ordem de despacho. A abertura do capítulo é quem produz
    -- `cap.sintese`, e ela saía DEPOIS de todos os trechos de todos os
    -- capítulos — no passo 125 de 210 numa obra de 10 × 20. Até lá,
    -- `O.vizinhanca` caía no `resumo` planejado de cada capítulo: uma frase
    -- escrita antes de qualquer conteúdo existir.
    --
    -- Isto mede, com o pool real de 6 workers, e trava o número. Sem a medida
    -- a correção seria uma aposta sem placar.

    O.gravar_plano(assert(O.montar(esboco(10, 20), "medida")))

    local passo, primeira_abertura = 0, nil
    local medidos, soma_com_sintese = 0, 0
    local emvoo_m = {}
    while true do
        while #emvoo_m < 6 do
            local t = O.tomar_tarefa()
            if t == nil then
                break
            end
            passo += 1
            if t.tipo == "abertura" and primeira_abertura == nil then
                primeira_abertura = passo
            end
            if t.tipo == "trecho" and t.cap > 1 then
                local pl = O.plano()
                for k = 1, t.cap - 1 do
                    local sn = pl.capitulos[k].sintese
                    if sn ~= nil and sn ~= "" then
                        soma_com_sintese += 1
                    end
                end
                medidos += 1
            end
            table.insert(emvoo_m, t)
        end
        if #emvoo_m == 0 then
            break
        end
        local f = table.remove(emvoo_m, 1)
        O.concluir(f, "corpo\n<!--SINTESE-->\n- ensinou algo\n<!--/SINTESE-->")
    end

    local total_m = O.contar(O.plano()).total
    conferir(total_m == 210, "a obra de medida tem 210 tarefas", tostring(total_m))

    -- Era 125 de 210. O primeiro capítulo fecha por volta do passo 120, e a
    -- abertura dele tem de sair logo em seguida — não no fim da fila.
    conferir(primeira_abertura ~= nil and primeira_abertura <= 130,
        "a 1a abertura sai assim que o 1o capítulo fecha, não no fim da fila",
        "passo " .. tostring(primeira_abertura) .. " de " .. tostring(total_m))

    -- Quantos capítulos anteriores já tinham síntese REAL (não o resumo
    -- planejado) quando cada trecho foi escrito. Era 2,27 com a ordem antiga.
    --
    -- O ganho da troca é modesto de propósito, e é honesto dizer por quê: os
    -- capítulos 1 a 6 correm em paralelo e fecham quase juntos, então adiantar
    -- as aberturas ajuda sobretudo os capítulos finais. A cegueira entre
    -- capítulos escritos ao mesmo tempo é inerente ao paralelismo — quem a
    -- ataca é o registro do que já foi ensinado (seção 10) e, na raiz, a
    -- auditoria do esboço.
    local media = soma_com_sintese / math.max(medidos, 1)
    conferir(media > 2.5,
        "um trecho encontra mais capítulos anteriores já sintetizados que antes",
        string.format("%.2f (era 2,27)", media))

    write_file = write_file_real
    limpar_ctx()
end

return M
