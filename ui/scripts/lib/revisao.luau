--!nolint
-- A revisão do esboço: o que a tela `revisao` edita antes de qualquer trecho
-- ser escrito de verdade.
--
-- Trabalha sobre a forma CRUA que `P.esboco` devolve — `{ titulo, resumo,
-- publico, capitulos: [{ titulo, resumo, subcapitulos: [{ titulo, foco }] }]
-- }`, guardada em `ctx.esboco_json` — e não sobre o `Plano` montado
-- (`ui/lib/obra.luau`), que só existe depois de confirmada a revisão. É de
-- propósito: um capítulo digitado à mão e um capítulo que a IA planejou têm
-- exatamente o mesmo molde, então "adicionar um capítulo novo" nunca precisa
-- de um formulário diferente de "editar um capítulo da IA" — e é só ao
-- confirmar que `O.montar` roda e recalcula slugs/caminhos/status do zero,
-- então reordenar, renomear, apagar e inserir aqui é sempre seguro.

local Rascunho = require("lib/rascunho")
local A = require("lib/avaliacao")
local OR = require("lib/openrouter")
local P = require("lib/prompts")

local R = {}

-- ── leitura/escrita do esboço ────────────────────────────────────────────────

function R.esboco(): any?
    local bruto = ctx.esboco_json
    if type(bruto) ~= "string" or bruto == "" then
        return nil
    end
    local ok, v = pcall(json.decode, bruto)
    if not ok or type(v) ~= "table" or type(v.capitulos) ~= "table" then
        return nil
    end
    return v
end

--- Único ponto de escrita do esboço — toda função abaixo (excluir, mover,
--- editar campo, etc.) passa por aqui, então é o único lugar que precisa
--- espelhar a mudança em disco (ver `lib/rascunho.luau`) para sobreviver a
--- fechar o app no meio da revisão.
function R.set_esboco(e: any)
    ctx.esboco_json = json.encode(e)
    Rascunho.salvar(ctx.esboco_json, ctx.tipo, ctx.assunto, ctx.esboco_slug_base)
end

-- ── capítulos ────────────────────────────────────────────────────────────────

function R.atualizar_obra(campo: string, valor: string)
    local e = R.esboco()
    if e == nil then
        return
    end
    e[campo] = valor
    R.set_esboco(e)
end

function R.excluir_capitulo(ci: number)
    local e = R.esboco()
    if e == nil then
        return
    end
    table.remove(e.capitulos, ci)
    R.set_esboco(e)
end

--- Acrescenta um capítulo vazio, no MESMO molde que a IA usa, e devolve o
--- índice dele — quem chama já abre o painel de edição nele, porque um
--- capítulo sem subcapítulo nenhum não passa em `R.validar`.
function R.adicionar_capitulo(): number
    local e = R.esboco()
    if e == nil then
        e = { titulo = "", resumo = "", publico = "", capitulos = json.array({}) }
    end
    table.insert(e.capitulos, {
        titulo = "Novo capítulo",
        resumo = "",
        subcapitulos = json.array({}),
    })
    R.set_esboco(e)
    return #e.capitulos
end

--- Troca um capítulo de lugar com o vizinho (`direcao` = -1 sobe, +1 desce).
--- A ordem dos capítulos é a ordem de DEPENDÊNCIA da obra (ver
--- `P.SISTEMA_ESBOCO`) — um capítulo novo quase sempre precisa ser
--- reposicionado, não só acrescentado no fim.
function R.mover_capitulo(ci: number, direcao: number)
    local e = R.esboco()
    if e == nil then
        return
    end
    local alvo = ci + direcao
    if alvo < 1 or alvo > #e.capitulos then
        return
    end
    e.capitulos[ci], e.capitulos[alvo] = e.capitulos[alvo], e.capitulos[ci]
    R.set_esboco(e)
end

function R.atualizar_capitulo(ci: number, campo: string, valor: string)
    local e = R.esboco()
    if e == nil then
        return
    end
    local cap = e.capitulos[ci]
    if cap == nil then
        return
    end
    cap[campo] = valor
    R.set_esboco(e)
end

-- ── subcapítulos ─────────────────────────────────────────────────────────────

function R.adicionar_sub(ci: number)
    local e = R.esboco()
    if e == nil then
        return
    end
    local cap = e.capitulos[ci]
    if cap == nil then
        return
    end
    if type(cap.subcapitulos) ~= "table" then
        cap.subcapitulos = json.array({})
    end
    table.insert(cap.subcapitulos, { titulo = "Novo subcapítulo", foco = "" })
    R.set_esboco(e)
end

function R.excluir_sub(ci: number, si: number)
    local e = R.esboco()
    if e == nil then
        return
    end
    local cap = e.capitulos[ci]
    if cap == nil or type(cap.subcapitulos) ~= "table" then
        return
    end
    table.remove(cap.subcapitulos, si)
    R.set_esboco(e)
end

function R.atualizar_sub(ci: number, si: number, campo: string, valor: string)
    local e = R.esboco()
    if e == nil then
        return
    end
    local cap = e.capitulos[ci]
    if cap == nil or type(cap.subcapitulos) ~= "table" then
        return
    end
    local sub = cap.subcapitulos[si]
    if sub == nil then
        return
    end
    sub[campo] = valor
    R.set_esboco(e)
end

-- ── a auditoria de sobreposição ──────────────────────────────────────────────
--
-- Uma chamada olha o plano inteiro e devolve os assuntos ensinados em dois
-- lugares, com o foco corrigido de cada repetidor.
--
-- Ela roda AUTOMATICAMENTE, como segunda metade da fase 1: quem gera um esboço
-- gera um esboço já conferido, e ninguém chega à revisão com um plano por
-- conferir. Era um botão, e um botão estava errado — a sobreposição não é uma
-- opinião que a pessoa possa querer ou não ter, é um defeito do plano, e um
-- defeito que ninguém clicou para procurar continua lá.
--
-- As correções são aplicadas na hora, e a tela lista o que mudou com um
-- "desfazer" por linha. Não é edição silenciosa: é edição visível e
-- reversível, e o foco continua editável à mão como qualquer outro campo.

--- O plano em texto, numerado, do jeito que a auditoria precisa ler.
--- Inclui o FOCO de cada subcapítulo: é ele, e não o título, que determina o
--- que o autor daquele trecho vai ensinar.
function R.texto_do_plano(e: any): string
    local linhas = {}
    for i, c in ipairs(e.capitulos) do
        table.insert(linhas, tostring(i) .. ". " .. tostring(c.titulo))
        local subs = (type(c.subcapitulos) == "table") and c.subcapitulos or {}
        for j, s in ipairs(subs) do
            local foco = (type(s.foco) == "string" and s.foco ~= "") and s.foco or "(sem foco)"
            table.insert(linhas, "   " .. tostring(i) .. "." .. tostring(j) .. " "
                .. tostring(s.titulo) .. " — " .. foco)
        end
    end
    return table.concat(linhas, "\n")
end

function R.achados(): { any }
    local bruto = ctx.auditoria_json
    if type(bruto) ~= "string" or bruto == "" then
        return {}
    end
    local ok, v = pcall(json.decode, bruto)
    if not ok or type(v) ~= "table" then
        return {}
    end
    return v
end

--- Normaliza o que o modelo devolveu e ANOTA os títulos que os índices
--- apontam agora.
---
--- Os títulos são a trava contra o índice velho: entre auditar e aplicar, a
--- pessoa pode reordenar, apagar ou acrescentar capítulos, e aí `cap`/`sub`
--- passam a apontar para outro subcapítulo. Reescrever o foco do subcapítulo
--- errado seria um estrago silencioso — o pior tipo, porque só apareceria na
--- obra pronta.
function R.set_achados(lista: any, e: any)
    local saida = {}
    if type(lista) == "table" then
        for _, a in ipairs(lista) do
            local ci = tonumber(a.cap)
            local si = tonumber(a.sub)
            local cap = (ci ~= nil) and e.capitulos[ci] or nil
            local subs = (cap ~= nil and type(cap.subcapitulos) == "table")
                and cap.subcapitulos or nil
            local sub = (subs ~= nil and si ~= nil) and subs[si] or nil
            if sub ~= nil and type(a.foco_novo) == "string" and a.foco_novo ~= "" then
                table.insert(saida, {
                    cap = ci,
                    sub = si,
                    cap_titulo = tostring(cap.titulo),
                    sub_titulo = tostring(sub.titulo),
                    assunto = tostring(a.assunto or "assunto repetido"),
                    dono = tostring(a.dono or ""),
                    motivo = tostring(a.motivo or ""),
                    foco_novo = a.foco_novo,
                    -- Guardado para o "desfazer": a correção é aplicada
                    -- automaticamente, então sem isto o foco original estaria
                    -- perdido e discordar da auditoria custaria reescrevê-lo
                    -- à mão.
                    foco_antigo = (type(sub.foco) == "string") and sub.foco or "",
                    aplicado = false,
                })
            end
        end
    end
    ctx.auditoria_json = json.encode(json.array(saida))
end

--- Aplica um achado: troca o foco do repetidor. Devolve `ok, motivo`.
function R.aplicar_achado(i: number): (boolean, string?)
    local lista = R.achados()
    local a = lista[i]
    if a == nil then
        return false, "achado fora da lista"
    end
    if a.aplicado then
        return false, "já aplicado"
    end
    local e = R.esboco()
    if e == nil then
        return false, "sem esboço"
    end
    local cap = e.capitulos[a.cap]
    local subs = (cap ~= nil and type(cap.subcapitulos) == "table") and cap.subcapitulos or nil
    local sub = (subs ~= nil) and subs[a.sub] or nil
    -- A trava: o índice só vale se ainda aponta para o mesmo subcapítulo.
    if sub == nil or tostring(sub.titulo) ~= a.sub_titulo then
        return false, "\"" .. a.sub_titulo .. "\" mudou de lugar depois da conferência."
            .. " Confira de novo antes de aplicar."
    end
    sub.foco = a.foco_novo
    R.set_esboco(e)
    lista[i].aplicado = true
    ctx.auditoria_json = json.encode(json.array(lista))
    return true, nil
end

--- Devolve um achado: repõe o foco original.
---
--- Mesma trava de título do `aplicar`, e pela mesma razão: entre a auditoria e
--- o clique em "desfazer" a pessoa pode ter reordenado ou apagado capítulos, e
--- repor o foco antigo no subcapítulo errado seria o mesmo estrago, ao
--- contrário.
function R.desfazer_achado(i: number): (boolean, string?)
    local lista = R.achados()
    local a = lista[i]
    if a == nil or not a.aplicado then
        return false, nil
    end
    local e = R.esboco()
    if e == nil then
        return false, "sem esboço"
    end
    local cap = e.capitulos[a.cap]
    local subs = (cap ~= nil and type(cap.subcapitulos) == "table") and cap.subcapitulos or nil
    local sub = (subs ~= nil) and subs[a.sub] or nil
    if sub == nil or tostring(sub.titulo) ~= a.sub_titulo then
        return false, "\"" .. a.sub_titulo .. "\" mudou de lugar. Edite o foco à mão."
    end
    sub.foco = a.foco_antigo
    R.set_esboco(e)
    lista[i].aplicado = false
    ctx.auditoria_json = json.encode(json.array(lista))
    return true, nil
end

--- Aplica todos os que ainda não foram. Devolve quantos entraram e quantos
--- foram recusados pela trava do título.
function R.aplicar_todos(): (number, number)
    local aplicados, recusados = 0, 0
    for i = 1, #R.achados() do
        local ok = R.aplicar_achado(i)
        if ok then
            aplicados += 1
        elseif not R.achados()[i].aplicado then
            recusados += 1
        end
    end
    return aplicados, recusados
end

--- A fase 1b inteira: pede a auditoria, aplica o que veio, e devolve quantas
--- correções entraram.
---
--- NUNCA propaga a falha como erro fatal. O esboço já foi pago e é válido; uma
--- auditoria que não voltou é uma obra sem esta melhoria, não uma obra
--- perdida. Quem chama registra o aviso e segue para a revisão.
---
--- Suspende a corrotina no `fetch`, como qualquer chamada — só pode ser
--- chamada de dentro de uma ação despachada.
function R.auditar(): (number, string?)
    local e = R.esboco()
    if e == nil then
        return 0, "não há plano para conferir"
    end
    if (ctx.api_key or "") == "" then
        return 0, "sem chave da API"
    end

    local ok, lista, custo = OR.chat_json({
        key = ctx.api_key,
        model = ctx.modelo,
        system = P.SISTEMA_AUDITORIA,
        user = P.auditoria(ctx.tipo, R.texto_do_plano(e)),
        temperature = 0.3,
        max_tokens = 8000,
    })
    ctx.custo_total = tostring((tonumber(ctx.custo_total) or 0) + (tonumber(custo) or 0))
    if not ok then
        return 0, tostring(lista)
    end

    -- O modelo às vezes embrulha o array num objeto, como já acontece com as
    -- perguntas da entrevista.
    if type(lista) == "table" and lista[1] == nil then
        lista = lista.achados or lista.repeticoes or lista.itens or lista.items or {}
    end

    -- Relê o esboço: `set_achados` precisa da forma que está valendo AGORA, e
    -- entre o pedido e a resposta a corrotina ficou suspensa.
    local atual = R.esboco()
    if atual == nil then
        return 0, "o plano sumiu durante a conferência"
    end
    R.set_achados(lista, atual)
    local aplicados = R.aplicar_todos()
    return aplicados, nil
end

-- ── validação ────────────────────────────────────────────────────────────────

--- `nil` se o esboço está pronto para virar `Plano` (mesmo critério de
--- `O.montar`, checado ANTES de gastar a chamada — um capítulo sem
--- subcapítulo ou sem título é descartado em silêncio por `O.montar`, e essa
--- silenciosidade é boa para um esboço de IA um pouco sujo, mas ruim aqui: se
--- a pessoa deixou um capítulo pela metade, ela precisa saber, não ver a
--- obra sair com um capítulo a menos.
function R.validar(e: any): string?
    if e == nil or type(e.capitulos) ~= "table" or #e.capitulos == 0 then
        return "O plano precisa de pelo menos um capítulo."
    end
    for i, c in ipairs(e.capitulos) do
        if type(c.titulo) ~= "string" or c.titulo:match("%S") == nil then
            return "O capítulo " .. tostring(i) .. " está sem título."
        end
        if type(c.subcapitulos) ~= "table" or #c.subcapitulos == 0 then
            return "\"" .. c.titulo .. "\" não tem nenhum subcapítulo."
        end
        for _, s in ipairs(c.subcapitulos) do
            if type(s.titulo) ~= "string" or s.titulo:match("%S") == nil then
                return "Um subcapítulo de \"" .. c.titulo .. "\" está sem título."
            end
        end
    end
    return nil
end

-- ── projeção para a tela ────────────────────────────────────────────────────

--- Publica no contexto tudo que a tela `revisao` lê: a lista de cards, e —
--- se houver um capítulo selecionado (`ctx.cap_sel`) — os campos do painel de
--- edição dele.
---
--- Os subcapítulos do painel usam uma chave de contexto POR LINHA
--- (`sub_titulo_<n>`/`sub_foco_<n>`, `n` = posição dentro do capítulo) em vez
--- de uma lista só — é o que permite `N` `<input>` independentes e
--- editáveis vindos de um `for-each` sem eles pisarem uns nos outros; reusar
--- uma chave só por linha faria todo input do capítulo mostrar o MESMO texto.
--- Reprojetar só troca esse conjunto quando o capítulo selecionado muda — uma
--- tecla dentro de um campo não chama isto (veria `livre_mudou` em
--- `perguntas.luau`: reprojetar a cada tecla recriaria o editor e o cursor
--- pularia para o fim).
--- Quantos trechos tem cada capítulo do esboço. É a forma REAL da obra — a
--- que a conta de exercícios e prova precisa. Na tela inicial ela ainda não
--- existe e a estimativa usa a forma padrão; aqui já dá para ser exato (o
--- modelo pode ter devolvido 8 capítulos em vez de 10, e isso muda a conta).
function R.forma(e: any): { number }
    local saida = {}
    if e == nil or type(e.capitulos) ~= "table" then
        return saida
    end
    for _, c in ipairs(e.capitulos) do
        local subs = (type(c.subcapitulos) == "table") and #c.subcapitulos or 0
        table.insert(saida, subs)
    end
    return saida
end

function R.projetar()
    local e = R.esboco()
    -- Amarrado aqui, e não em cada handler da tela, pelo mesmo motivo que
    -- `O.gravar_plano` projeta junto: acrescentar um subcapítulo muda o número
    -- de lotes, e esquecer de recalcular deixaria a tela mostrando a conta do
    -- esboço anterior. Amarrando, esquecer deixa de ser possível.
    if e ~= nil then
        A.projetar(R.forma(e), ctx.tipo)
    end
    if e == nil then
        ctx.rev_tem_esboco = "false"
        ctx.rev_titulo = ""
        ctx.rev_resumo = ""
        ctx.rev_publico = ""
        ctx.rev_capitulos_ui = "[]"
        ctx.rev_n_capitulos = "0"
        ctx.rev_tem_capitulos = "false"
        ctx.rev_tem_selecao = "false"
        ctx.rev_subs_ui = "[]"
        ctx.aud_ui = "[]"
        ctx.aud_tem_achados = "false"
        ctx.aud_rotulo = ""
        return
    end

    -- Os achados da auditoria, e o convite a rodá-la quando ainda não foi.
    -- O convite é explícito sobre o preço porque este app mostra o custo antes
    -- de cobrar; e é insistente porque a alternativa — deixar passar — custa um
    -- terço da obra escrito duas vezes.
    local achados = R.achados()
    local linhas_aud = {}
    local aplicados = 0
    for i, a in ipairs(achados) do
        if a.aplicado then
            aplicados += 1
        end
        table.insert(linhas_aud, {
            n = tostring(i),
            assunto = tostring(a.assunto),
            onde = tostring(a.cap) .. "." .. tostring(a.sub) .. " " .. tostring(a.sub_titulo)
                .. "  →  dono: " .. tostring(a.dono),
            motivo = tostring(a.motivo),
            rotulo = a.aplicado and "desfazer" or "desfeito",
        })
    end
    ctx.aud_ui = json.encode(json.array(linhas_aud))
    ctx.aud_tem_achados = (#achados > 0) and "true" or "false"
    if #achados == 0 then
        ctx.aud_rotulo = ""
    else
        ctx.aud_rotulo = tostring(#achados) .. " "
            .. ((#achados == 1) and "ASSUNTO PLANEJADO EM DOIS LUGARES"
                or "ASSUNTOS PLANEJADOS EM DOIS LUGARES")
            .. ((aplicados == #achados) and " — CORRIGIDOS"
                or (" — " .. tostring(aplicados) .. " CORRIGIDOS"))
    end

    ctx.rev_tem_esboco = "true"
    ctx.rev_titulo = type(e.titulo) == "string" and e.titulo or ""
    ctx.rev_resumo = type(e.resumo) == "string" and e.resumo or ""
    ctx.rev_publico = type(e.publico) == "string" and e.publico or ""
    ctx.rev_n_capitulos = tostring(#e.capitulos)
    ctx.rev_tem_capitulos = (#e.capitulos > 0) and "true" or "false"

    local linhas = {}
    for i, c in ipairs(e.capitulos) do
        local n_subs = (type(c.subcapitulos) == "table") and #c.subcapitulos or 0
        table.insert(linhas, {
            n = tostring(i),
            titulo = (type(c.titulo) == "string" and c.titulo ~= "") and c.titulo
                or "(sem título)",
            resumo = type(c.resumo) == "string" and c.resumo or "",
            n_subs = tostring(n_subs),
            selecionado = (tostring(i) == ctx.cap_sel) and "true" or "false",
        })
    end
    ctx.rev_capitulos_ui = json.encode(json.array(linhas))

    local ci = tonumber(ctx.cap_sel)
    local cap = ci ~= nil and e.capitulos[ci] or nil
    if cap == nil then
        ctx.rev_tem_selecao = "false"
        ctx.rev_cap_titulo = ""
        ctx.rev_cap_resumo = ""
        ctx.rev_subs_ui = "[]"
        return
    end

    ctx.rev_tem_selecao = "true"
    ctx.rev_cap_titulo = type(cap.titulo) == "string" and cap.titulo or ""
    ctx.rev_cap_resumo = type(cap.resumo) == "string" and cap.resumo or ""

    local subs = {}
    local brutos = type(cap.subcapitulos) == "table" and cap.subcapitulos or {}
    for j, s in ipairs(brutos) do
        local chave = tostring(j)
        ctx["sub_titulo_" .. chave] = type(s.titulo) == "string" and s.titulo or ""
        ctx["sub_foco_" .. chave] = type(s.foco) == "string" and s.foco or ""
        table.insert(subs, { n = chave })
    end
    ctx.rev_subs_ui = json.encode(json.array(subs))
end

return R
