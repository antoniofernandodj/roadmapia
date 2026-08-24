--!nolint
-- Tela 3: a produção da obra — a fase 2, onde o material de verdade é escrito.
--
-- São centenas de chamadas (10 capítulos × 20 trechos + 10 aberturas = 210),
-- porque é a única forma de ter densidade: cada chamada gasta o teto de saída
-- inteiro num assunto pequeno. Sequencialmente isso levaria horas, então um
-- POOL de workers as faz em paralelo.
--
-- O paralelismo é real e vem de graça do motor: `fetch` suspende a corrotina da
-- ação, e o glacier guarda cada corrotina suspensa por id (`pending`). Vários
-- `after(ms, "trabalhador")` criam corrotinas independentes, cada uma com o seu
-- fetch em voo. Como Lua roda numa thread só, e uma corrotina só cede a vez num
-- `fetch`, não há corrida — desde que nada suspenda entre ler e reescrever o
-- plano (é a regra que `lib/obra.luau` mantém).

local OR = require("lib/openrouter")
local E = require("lib/entrevista")
local P = require("lib/prompts")
local O = require("lib/obra")
local L = require("lib/log")

-- Chamadas simultâneas. Seis é o ponto em que a API responde sem 429 constante
-- e a produção ainda cabe em minutos, não horas.
local WORKERS = 6
-- Tentativas por trecho antes de marcá-lo como falho. O reagendamento com
-- espera (ver `trabalhador`) é o que dá um recuo de verdade num 429.
local TENTATIVAS = 3
local ESPERA_MS = 4000

-- Estado do pool. São locais do chunk (carregado uma vez por componente), então
-- sobrevivem entre ações — ao contrário de `ctx`, que é remontado a cada turno.
local ativos = 0
local parando = false

function init(): ()
    projetar()
end

-- ── o pool ──────────────────────────────────────────────────────────────────

--- O botão de produzir. Antes de largar centenas de chamadas, escreve UM
--- trecho de amostra e mede o custo real dele — daí o diálogo pode dizer um
--- preço medido, não um chute, e o usuário pode ler a amostra em disco antes
--- de autorizar o resto. Um curso completo custa dezenas de vezes o de um
--- trecho; isso não pode acontecer por acidente.
function produzir(): ()
    if (ctx.api_key or "") == "" then
        E.erro("Falta a chave do OpenRouter (ajuste no início).")
        return
    end
    local plano = O.plano()
    if plano == nil then
        E.erro("Não há plano para produzir.")
        return
    end
    if O.contar(plano).prontos >= O.contar(plano).total then
        E.erro(nil)
        toast({ message = "Já está tudo pronto.", kind = "info" })
        return
    end

    E.erro(nil)
    parando = false
    ctx.custo_total = ctx.custo_total or "0"
    L.sessao("producao")
    L.info(
        "producao",
        "produzir: pedido pelo usuário; pendentes="
        .. tostring(O.contar(plano).total - O.contar(plano).prontos)
    )

    -- 1) A amostra: um trecho de verdade, para medir preço e qualidade.
    if (tonumber(ctx.trechos_pagos) or 0) == 0 then
        ativos = 1
        ctx.status = "Escrevendo um trecho de amostra, para medir custo e qualidade..."
        projetar()

        local tarefa = O.tomar_tarefa()
        if tarefa == nil then
            L.aviso("producao", "amostra: a fila já estava vazia")
            ativos = 0
            projetar()
            return
        end
        L.info("producao", "amostra: começando por " .. arquivo_da(tarefa))
        executar(tarefa) -- suspende no fetch; retoma aqui com o trecho escrito
        ativos = 0
        ctx.status = ""
        projetar()

        if (tonumber(ctx.trechos_pagos) or 0) == 0 then
            L.erro(
                "producao",
                "amostra falhou; produção não começou. erro=" .. tostring(ctx.erro)
            )
            E.erro("A amostra falhou — corrija o erro acima antes de produzir o resto.")
            return
        end
        L.info(
            "producao",
            "amostra pronta: " .. tostring(ctx.amostra_arquivo)
            .. " custo=" .. tostring(ctx.custo_total)
        )
    end

    -- 2) A conta, com o número medido na mão.
    local c = O.contar(O.plano())
    local faltam = c.total - c.prontos
    if faltam <= 0 then
        finalizar()
        return
    end
    local por_trecho = custo_por_trecho()
    local estimado = por_trecho * faltam

    -- `confirm` suspende a corrotina como o `fetch`; o retorno é a escolha.
    local ok = confirm({
        title = "Produzir os " .. tostring(faltam) .. " trechos restantes?",
        message = string.format(
            "O trecho de amostra custou US$ %.4f. Os %d restantes devem custar "
                .. "cerca de US$ %.2f no modelo %s.\n\n"
                .. "Leia a amostra antes de decidir:\n%s\n\n"
                .. "Dá para parar a qualquer momento — o que já foi escrito fica em disco.",
            por_trecho, faltam, estimado, ctx.modelo or "", ctx.amostra_arquivo or "?"
        ),
        confirm_label = string.format("Produzir (~US$ %.2f)", estimado),
        cancel_label = "Agora não",
    })
    L.info("producao", string.format(
        "confirmação: %s (%d trechos, ~US$ %.2f)",
        ok and "ACEITA" or "recusada", faltam, estimado)
    )
    if not ok then
        return
    end

    -- 3) O pool.
    ativos = WORKERS
    L.info(
        "producao",
        "largando " .. WORKERS .. " workers para " .. faltam .. " trechos"
    )
    for i = 1, WORKERS do
        -- Escalonados: largar seis requisições no mesmo milissegundo é o
        -- caminho mais curto para um 429 logo na primeira leva.
        after((i - 1) * 250, "trabalhador")
    end
    projetar()
end

--- Custo médio já medido por trecho. Só é chamada depois da amostra, então o
--- divisor nunca é zero.
function custo_por_trecho(): number
    local pagos = math.max(tonumber(ctx.trechos_pagos) or 0, 1)
    return (tonumber(ctx.custo_total) or 0) / pagos
end

--- Um worker. Puxa tarefas da fila até acabar (ou até mandarem parar); cada
--- volta do laço suspende no `fetch` e retoma quando a resposta chega.
function trabalhador(): ()
    while not parando do
        local tarefa = O.tomar_tarefa()
        if tarefa == nil then
            L.info("worker", "fila vazia; encerrando")
            break
        end

        local ok, motivo = executar(tarefa)
        if not ok and motivo == "recuar" then
            L.aviso("worker", "rate limit em " .. arquivo_da(tarefa)
                .. "; devolvendo à fila e esperando " .. ESPERA_MS .. "ms")
            -- Rate limit: devolve a tarefa e reagenda ESTE slot com espera, sem
            -- decrementar `ativos` — o pool continua com o mesmo tamanho, só
            -- que este worker dorme. É o recuo que um `while` não consegue
            -- fazer sozinho (nada em Luau aqui bloqueia sem travar a UI).
            O.reenfileirar(tarefa)
            projetar()
            after(ESPERA_MS, "trabalhador")
            return
        end
        projetar()
    end

    ativos -= 1
    L.info("worker", "worker saiu; ativos=" .. ativos)
    if ativos <= 0 then
        finalizar()
    end
end

--- Escreve UM trecho (ou a abertura de um capítulo). Devolve `ok, motivo`.
function executar(tarefa): (boolean, string?)
    local plano = O.plano()
    if plano == nil then
        return false, "sem plano"
    end
    local cap = plano.capitulos[tarefa.cap]
    if cap == nil then
        return false, "capítulo sumiu"
    end

    local prompt, sistema
    if tarefa.tipo == "abertura" then
        -- A abertura só é liberada depois que todos os trechos do capítulo
        -- estão prontos/com erro (ver `O.tomar_tarefa`), então a síntese de
        -- cada um já existe — cai no foco planejado só se o trecho falhou.
        local trechos = {}
        for i, s in ipairs(cap.subs) do
            local nota = (s.sintese ~= nil and s.sintese ~= "") and s.sintese or s.foco
            table.insert(trechos, tostring(i) .. ". " .. s.titulo .. ": " .. (nota or ""))
        end
        sistema = P.SISTEMA_CONTEUDO
        prompt = P.abertura(plano, cap, table.concat(trechos, "\n"))
    else
        local sub = cap.subs[tarefa.sub]
        if sub == nil then
            return false, "trecho sumiu"
        end
        ctx.status = "Escrevendo: " .. sub.titulo
        sistema = P.SISTEMA_CONTEUDO
        prompt = P.secao(
            plano,
            cap,
            sub,
            O.vizinhanca(plano, tarefa.cap, tarefa.sub)
        )
    end

    local ultimo_erro = ""
    for tentativa = 1, TENTATIVAS do
        local ok, texto, custo = OR.chat({
            key = ctx.api_key,
            model = ctx.modelo,
            system = sistema,
            user = prompt,
            temperature = 0.7,
            -- Teto alto de propósito: é o orçamento de densidade do trecho.
            max_tokens = 8000,
        })
        somar_custo(custo)

        L.chamada(
            "worker",
            arquivo_da(tarefa),
            ok,
            custo,
            ok and ("palavras~" .. tostring(math.floor(#texto / 6))) or tostring(texto)
        )

        if ok then
            local gravou, motivo_disco = O.concluir(tarefa, texto)
            if not gravou then
                L.erro("worker", "GRAVAÇÃO FALHOU em " .. arquivo_da(tarefa)
                    .. ": " .. tostring(motivo_disco))
            end
            O.gravar_sumario()
            -- Contabiliza a chamada paga: é o divisor da estimativa de custo.
            ctx.trechos_pagos = tostring((tonumber(ctx.trechos_pagos) or 0) + 1)
            if (ctx.amostra_arquivo or "") == "" then
                ctx.amostra_arquivo = arquivo_da(tarefa)
            end
            return true, nil
        end

        ultimo_erro = texto
        if eh_rate_limit(texto) then
            return false, "recuar"
        end
        -- Erro comum (rede, 5xx): tenta de novo na hora, sem gastar o slot.
        L.aviso(
            "worker",
            "tentativa "
            .. tentativa .. "/" .. TENTATIVAS .. " falhou em "
            .. arquivo_da(tarefa) .. ": "
            .. tostring(ultimo_erro)
        )
        if tentativa == TENTATIVAS then
            O.falhar(tarefa, ultimo_erro)
            O.gravar_sumario()
            return false, ultimo_erro
        end
    end
    return false, ultimo_erro
end

--- O caminho do arquivo que uma tarefa escreve (para citar a amostra ao usuário).
function arquivo_da(tarefa): string
    local plano = O.plano()
    if plano == nil then
        return ""
    end
    local cap = plano.capitulos[tarefa.cap]
    if cap == nil then
        return ""
    end
    if tarefa.tipo == "abertura" then
        return cap.arquivo
    end
    local sub = cap.subs[tarefa.sub]
    return sub ~= nil and sub.arquivo or ""
end

function eh_rate_limit(msg): boolean
    local m = tostring(msg):lower()
    return m:find("429", 1, true) ~= nil
        or m:find("rate limit", 1, true) ~= nil
        or m:find("rate%-limit") ~= nil
end

function finalizar(): ()
    O.gravar_sumario()
    do
        local pl = O.plano()
        if pl ~= nil then
            local cc = O.contar(pl)
            L.info("producao", string.format(
                "FIM: prontos=%d/%d erros=%d custo=US$%s pasta=%s",
                cc.prontos, cc.total, cc.erros, tostring(ctx.custo_total), pl.pasta))
        end
    end
    local plano = O.plano()
    if plano == nil then
        return
    end
    local c = O.contar(plano)
    ctx.status = ""
    projetar()

    if parando then
        toast({
            message = "Parado. " .. tostring(c.prontos) .. " trechos em disco.",
            kind = "info"
        })
    elseif c.erros > 0 then
        toast({
            title = "Produção terminada com falhas",
            message = tostring(c.erros) .. " trechos falharam — use 'Refazer falhas'.",
            kind = "warning",
        })
    else
        toast({
            title = "Pronto",
            message = plano.titulo .. " — " .. tostring(c.prontos) .. " trechos em " .. plano.pasta,
            kind = "success",
        })
    end
end

-- ── controles ───────────────────────────────────────────────────────────────

function parar(): ()
    L.info("producao", "parada pedida pelo usuário")
    parando = true
    ctx.status = "Parando após os trechos em voo..."
    projetar()
end

function refazer_falhas(): ()
    local n = O.reenfileirar_falhas()
    L.info("producao", "refazer falhas: " .. n .. " devolvidos à fila")
    if n == 0 then
        toast({ message = "Não há falhas para refazer.", kind = "info" })
        return
    end
    E.erro(nil)
    projetar()
    toast({ message = tostring(n) .. " trechos devolvidos à fila.", kind = "info" })
end

function salvar_obra(): ()
    local plano = O.plano()
    if plano == nil then
        return
    end
    -- Pede o destino ANTES de zipar: `zip_dir` escreve o .zip direto lá,
    -- sem passo de "zipar em algum lugar e depois mover" (moveria bytes
    -- binários por uma fronteira Lua↔Rust que só é UTF-8-safe hoje).
    local destino = pick_folder({ title = "Onde salvar a obra?" })
    if destino == nil then
        return -- cancelado
    end
    local slug = plano.pasta:match("([^/]+)$") or "obra"
    local caminho_zip = destino .. "/" .. slug .. ".zip"
    local ok, erro = zip_dir(plano.pasta, caminho_zip)
    if not ok then
        L.erro("producao", "falha ao salvar obra: " .. tostring(erro))
        toast({ title = "Falha ao salvar", message = tostring(erro), kind = "error" })
        return
    end
    L.info("producao", "obra salva em " .. caminho_zip)
    toast({ title = "Obra salva", message = caminho_zip, kind = "success" })
end

-- ── projeção para a tela ────────────────────────────────────────────────────

function somar_custo(custo): ()
    local atual = tonumber(ctx.custo_total) or 0
    ctx.custo_total = tostring(atual + (tonumber(custo) or 0))
end

--- Projeta o plano (via `O.projetar`, compartilhado) e acrescenta o que só
--- esta tela sabe: se o pool está rodando.
function projetar(): ()
    local c = O.projetar(E.rotulo(ctx.tipo))

    local produzindo = (ativos > 0)
    ctx.produzindo = produzindo and "true" or "false"
    ctx.parado = produzindo and "false" or "true"

    local custo = tonumber(ctx.custo_total) or 0
    if custo > 0 and c ~= nil then
        ctx.rotulo_custo = string.format("US$ %.3f gastos", custo)
        -- Extrapolação honesta: o custo por trecho já medido vezes o que falta.
        local pagos = math.max(tonumber(ctx.trechos_pagos) or 0, 1)
        if c.prontos < c.total then
            ctx.rotulo_custo = ctx.rotulo_custo
                .. string.format("  (~US$ %.2f no total)", (custo / pagos) * c.total)
        end
    else
        ctx.rotulo_custo = ""
    end
end

function on_error(msg): ()
    L.erro("producao", "ERRO DE SCRIPT (matou um worker): " .. tostring(msg))
    ativos = 0
    E.erro(msg)
    projetar()
end
