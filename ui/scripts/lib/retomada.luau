--!nolint
-- Retomar uma obra pela pasta dela: gerar só o que faltou.
--
-- Uma produção pode parar no meio: créditos que acabam (402), rede que cai,
-- app fechado. Antes, o plano só existia em memória (`ctx.obra_json`), então
-- a pasta pela metade ficava sem jeito de saber o que faltava. Agora:
--
--   * Toda obra grava `projeto.roadmapia` na própria pasta (ver
--     `O.gravar_projeto`), com o plano e o estado de cada parte. Retomar é
--     lê-lo de volta.
--   * Uma obra de antes disso não tem o arquivo; o plano é RECONSTRUÍDO do
--     `README.md` da obra, que lista capítulos, trechos, lotes de exercícios e
--     a prova, com os caminhos de cada um.
--
-- Nos dois casos, quem diz o que está pronto é o DISCO, não o estado gravado:
-- um arquivo que existe está pronto, um que não existe volta para a fila.
-- Assim, uma parte que falhou, uma que ficou "fazendo" quando o app fechou, e
-- um arquivo apagado à mão (para refazê-lo) caem todos no mesmo lugar.

local O = require("lib/obra")

local Ret = {}

local function aparar(s: string): string
    return (string.gsub(string.gsub(s, "^%s+", ""), "%s+$", ""))
end

local function existe(texto: string?): boolean
    return type(texto) == "string" and aparar(texto) ~= ""
end

--- Corta em até `max` bytes sem partir um caractere: volta até o último espaço.
local function cortar(s: string, max: number): string
    if #s <= max then
        return s
    end
    local corte = string.match(string.sub(s, 1, max), "^(.*)%s") or string.sub(s, 1, max)
    return corte .. "…"
end

--- Uma síntese aproximada de um trecho, tirada do próprio texto.
---
--- A síntese de verdade é o bloco `<!--SINTESE-->` que o modelo devolve, e ele
--- não vai para o arquivo. Numa obra reconstruída ela não existe; o que os
--- exercícios e a prova recebem no lugar é o primeiro parágrafo do trecho e
--- os títulos das seções dele — o que ele de fato cobriu, que é melhor que
--- cair no foco planejado (que numa reconstrução nem existe).
function Ret.sintese_de(texto: string): string
    -- O primeiro título é o do próprio trecho (o arquivo abre com ele); as
    -- seções são os que vêm depois.
    local secoes = {}
    local primeiro = true
    for h in string.gmatch("\n" .. texto, "\n##+%s+([^\n]+)") do
        if primeiro then
            primeiro = false
        else
            table.insert(secoes, aparar(h))
            if #secoes >= 8 then
                break
            end
        end
    end
    local paragrafo = ""
    for bloco in string.gmatch(texto .. "\n\n", "(.-)\n%s*\n") do
        local b = aparar(bloco)
        if b ~= "" and not string.match(b, "^#") and not string.match(b, "^```")
            and not string.match(b, "^[-*|>]")
        then
            paragrafo = cortar(string.gsub(b, "%s+", " "), 400)
            break
        end
    end
    if #secoes == 0 then
        return paragrafo
    end
    return aparar(paragrafo .. " Seções: " .. table.concat(secoes, "; ") .. ".")
end

--- O texto da abertura dentro do README de um capítulo: o que fica entre o
--- título e o `---` que `O.cabecalho_capitulo` põe antes do índice.
function Ret.abertura_de(readme: string): string
    local corpo = string.match(readme, "^#[^\n]*\n+(.-)\n+%-%-%-\n")
    return (corpo ~= nil) and aparar(corpo) or ""
end

export type SumarioLote = { de: number, ate: number, n: number, link: string }
export type SumarioSub = { titulo: string, link: string }
export type SumarioCap = {
    titulo: string,
    link: string,
    resumo: string,
    subs: { SumarioSub },
    lotes: { SumarioLote },
}
export type Sumario = {
    titulo: string,
    resumo: string,
    publico: string,
    capitulos: { SumarioCap },
    questoes: number,
}

--- Lê o `README.md` que `O.gravar_sumario` escreve. Devolve `nil, motivo` se
--- o texto não tiver a forma dele.
function Ret.ler_sumario(texto: string): (Sumario?, string?)
    local titulo = string.match(texto, "^#%s+([^\n]+)")
    local cab, corpo = string.match(texto, "^(.-)\n## Sumário\n(.*)$")
    if titulo == nil or cab == nil then
        return nil, "o README.md não tem o sumário de uma obra do roadmapia"
    end

    local resumo, publico = {}, ""
    local primeira = true
    for linha in string.gmatch(cab .. "\n", "([^\n]*)\n") do
        if primeira then
            primeira = false
        else
            local p = string.match(linha, "^%*%*Para quem é:%*%*%s*(.*)$")
            if p ~= nil then
                publico = aparar(p)
            elseif not string.match(linha, "^>") and aparar(linha) ~= "" then
                table.insert(resumo, aparar(linha))
            end
        end
    end

    local capitulos: { SumarioCap } = {}
    local atual: SumarioCap? = nil
    local questoes = 0
    for linha in string.gmatch((corpo :: string) .. "\n", "([^\n]*)\n") do
        local ct, cl = string.match(linha, "^### %d+%. %[(.-)%]%(([^)]-)%)")
        if ct ~= nil then
            atual = { titulo = ct :: string, link = cl :: string, resumo = "", subs = {}, lotes = {} }
            table.insert(capitulos, atual :: SumarioCap)
        elseif string.match(linha, "^### %[Prova final%]") then
            atual = nil
        else
            local q = string.match(linha, "^(%d+) questões em %d+ parte")
            local de, ate, n, ll = string.match(linha,
                "^%s+· %[Exercícios — trechos (%d+) a (%d+) %((%d+)%)%]%(([^)]-)%)")
            local st, sl = string.match(linha, "^%s+%d+%. %[(.-)%]%(([^)]-)%)")
            if q ~= nil then
                questoes = tonumber(q :: string) or 0
            elseif atual ~= nil and de ~= nil then
                table.insert(atual.lotes, {
                    de = tonumber(de) or 0,
                    ate = tonumber(ate) or 0,
                    n = tonumber(n) or 0,
                    link = ll :: string,
                })
            elseif atual ~= nil and st ~= nil then
                table.insert(atual.subs, { titulo = st :: string, link = sl :: string })
            elseif atual ~= nil and #atual.subs == 0 and aparar(linha) ~= "" then
                atual.resumo = aparar(atual.resumo .. " " .. aparar(linha))
            end
        end
    end
    if #capitulos == 0 then
        return nil, "o sumário do README.md não lista nenhum capítulo"
    end
    return {
        titulo = aparar(titulo),
        resumo = table.concat(resumo, "\n\n"),
        publico = publico,
        capitulos = capitulos,
        questoes = questoes,
    }, nil
end

--- Troca o prefixo de todos os caminhos do plano: a pasta pode ter mudado de
--- lugar (movida, copiada para outra máquina) desde que o projeto foi gravado.
function Ret.rebasear(plano: any, pasta: string)
    local antiga = plano.pasta or ""
    local function troca(c: string): string
        if antiga ~= "" and string.sub(c, 1, #antiga) == antiga then
            return pasta .. string.sub(c, #antiga + 1)
        end
        return c
    end
    plano.pasta = pasta
    for _, cap in ipairs(plano.capitulos) do
        cap.dir = troca(cap.dir)
        cap.arquivo = troca(cap.arquivo)
        for _, s in ipairs(cap.subs) do
            s.arquivo = troca(s.arquivo)
        end
        for _, l in ipairs(O.lotes_de(cap)) do
            l.arquivo = troca(l.arquivo)
        end
    end
    for _, p in ipairs(O.prova_de(plano)) do
        p.arquivo = troca(p.arquivo)
    end
end

--- Monta o plano de uma obra sem `projeto.roadmapia`, a partir do README dela.
function Ret.reconstruir(pasta: string): (any, string?)
    local texto = (read_file(pasta .. "/README.md"))
    if not existe(texto) then
        return nil, "Esta pasta não tem " .. O.ARQUIVO_PROJETO .. " nem o README.md de uma obra."
    end
    local s, erro = Ret.ler_sumario(texto :: string)
    if s == nil then
        return nil, erro
    end

    -- O número de exercícios é o mesmo para todos os capítulos (é um campo
    -- só no plano); a soma dos lotes do primeiro capítulo o devolve.
    local exercicios = 0
    for _, l in ipairs(s.capitulos[1].lotes) do
        exercicios += l.n
    end
    local esboco = {
        titulo = s.titulo,
        resumo = s.resumo,
        publico = s.publico,
        capitulos = {},
    }
    for _, c in ipairs(s.capitulos) do
        local subs = {}
        for _, sub in ipairs(c.subs) do
            -- O foco planejado não fica em disco; o título é o que há.
            table.insert(subs, { titulo = sub.titulo, foco = sub.titulo })
        end
        table.insert(esboco.capitulos, { titulo = c.titulo, resumo = c.resumo, subcapitulos = subs })
    end

    local slug = string.match(pasta, "([^/\\]+)$") or "obra"
    local plano, erro_montar = O.montar(esboco, slug, "", {
        exercicios_por_capitulo = exercicios,
        questoes_prova = s.questoes,
    })
    if plano == nil then
        return nil, erro_montar
    end
    -- `montar` descarta capítulo ou trecho que não consiga normalizar; aí os
    -- índices deixariam de casar com os arquivos, e "o que falta" sairia errado.
    if #plano.capitulos ~= #s.capitulos then
        return nil, "o sumário não pôde ser reconstruído (capítulos não batem)"
    end
    Ret.rebasear(plano, pasta)

    -- Os caminhos vêm dos LINKS do sumário, não do slug recalculado: são os
    -- arquivos que existem de fato, mesmo se a regra do slug mudou desde então.
    for ci, cap in ipairs(plano.capitulos) do
        local sc = s.capitulos[ci]
        if #cap.subs ~= #sc.subs then
            return nil, "o sumário não pôde ser reconstruído (trechos do capítulo "
                .. tostring(ci) .. " não batem)"
        end
        cap.arquivo = pasta .. "/" .. sc.link
        cap.dir = string.match(cap.arquivo, "^(.*)/[^/]+$") or cap.dir
        for si, sub in ipairs(cap.subs) do
            sub.arquivo = pasta .. "/" .. sc.subs[si].link
        end
        local lotes = O.lotes_de(cap)
        if #lotes == #sc.lotes then
            for li, lote in ipairs(lotes) do
                local sl = sc.lotes[li]
                lote.arquivo = pasta .. "/" .. sl.link
                lote.de, lote.ate, lote.n = sl.de, sl.ate, sl.n
            end
        end
    end

    local prefixo = string.match(slug, "^(%a+)%-")
    plano.tipo = ((#O.prova_de(plano) > 0 or exercicios > 0) and "curso")
        or ((prefixo == "roadmap" or prefixo == "guia") and prefixo)
        or "curso"
    plano.assunto = s.titulo
    return plano, nil
end

--- Acerta o estado de cada parte pelo que existe em disco. Devolve quantas
--- estão prontas e quantas faltam.
function Ret.reconciliar(plano: any): (number, number)
    local prontos, faltam = 0, 0
    local function marcar(item: any, texto: string?): boolean
        item.erro = ""
        if existe(texto) then
            item.status = O.PRONTO
            prontos += 1
            return true
        end
        item.status = O.PENDENTE
        faltam += 1
        return false
    end

    for _, cap in ipairs(plano.capitulos) do
        local readme = (read_file(cap.arquivo))
        local abertura = existe(readme) and Ret.abertura_de(readme :: string) or ""
        if marcar(cap, (abertura ~= "") and abertura or nil) then
            if (cap.sintese or "") == "" then
                cap.sintese = abertura
            end
        else
            cap.sintese = ""
        end
        for _, sub in ipairs(cap.subs) do
            local texto = (read_file(sub.arquivo))
            if marcar(sub, texto) then
                if (sub.sintese or "") == "" then
                    sub.sintese = Ret.sintese_de(texto :: string)
                end
            else
                sub.sintese = ""
            end
        end
        for _, lote in ipairs(O.lotes_de(cap)) do
            marcar(lote, (read_file(lote.arquivo)))
        end
    end
    for _, parte in ipairs(O.prova_de(plano)) do
        marcar(parte, (read_file(parte.arquivo)))
    end
    return prontos, faltam
end

--- Carrega a obra da pasta: do `projeto.roadmapia`, ou reconstruída do README.
--- Devolve `plano, origem, prontos, faltam` — ou `nil, motivo`.
---
--- `origem` é "projeto" ou "reconstruído", para a tela poder dizer de onde
--- veio o estado (uma reconstrução perde as observações e o registro de
--- conceitos, e quem retoma deve saber disso).
function Ret.carregar(pasta: string): (any, string, number, number)
    pasta = (string.gsub(pasta, "[/\\]+$", ""))
    local plano: any = nil
    local origem = "projeto"

    local bruto = (read_file(O.caminho_projeto(pasta)))
    if existe(bruto) then
        local ok, v = pcall(json.decode, bruto)
        if ok and type(v) == "table" and type(v.capitulos) == "table" then
            plano = v
            Ret.rebasear(v, pasta)
        end
    end
    if plano == nil then
        -- Sem projeto, ou com um projeto ilegível: o README ainda diz a forma
        -- da obra, e o disco diz o que está pronto.
        local p, erro = Ret.reconstruir(pasta)
        if p == nil then
            return nil, tostring(erro), 0, 0
        end
        plano = p
        origem = "reconstruído"
    end

    local pl = plano :: any
    pl.formato = O.FORMATO_PROJETO
    local prontos, faltam = Ret.reconciliar(pl)
    return pl, origem, prontos, faltam
end

return Ret
