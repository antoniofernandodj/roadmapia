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
function R.projetar()
    local e = R.esboco()
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
        return
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
