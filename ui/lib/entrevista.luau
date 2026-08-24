--!nolint
-- O estado da entrevista, guardado no contexto compartilhado do motor.
--
-- O contexto do glacier é um mapa `string -> string`, então as estruturas
-- (perguntas, respostas) trafegam serializadas em JSON. Este módulo é a única
-- coisa que sabe disso: as telas falam em tabelas Lua.
--
-- Chaves de contexto que ele possui:
--   assunto          -- o tema digitado na tela inicial
--   tipo             -- "roadmap" | "curso" | "guia"
--   perguntas_json   -- [{ id, texto, ajuda, opcoes = { "…" } }]
--   respostas_json   -- { [id] = { escolhas = { "…" }, livre = "…" } }
--   q_idx            -- índice (1-based) da pergunta em foco
--
-- As telas `perguntas`/`resultado` só leem daqui; quem escreve são as ações.

local E = {}

-- O vocabulário de um tipo de obra. Exportado porque `obra` e `prompts` o
-- recebem como parâmetro — e um parâmetro sem tipo faz o checker reprovar
-- cada `..` que o usa.
export type Rotulos = {
    nome: string,
    artigo: string,
    resumo: string,
    unidade: string,
    unidades: string,
    subunidade: string,
    subunidades: string,
}

E.TIPOS = { "roadmap", "curso", "guia" }

-- Rótulos e o vocabulário que entra nos prompts. `artigo` deixa as frases
-- naturais ("gere **um** roadmap" / "**um** curso" / "**um** guia");
-- `unidade`/`subunidade` dão a cada tipo o nome certo das suas divisões, para
-- o prompt de esboço não pedir "capítulos" de um roadmap.
E.ROTULOS = {
    roadmap = {
        nome = "Roadmap",
        artigo = "um roadmap",
        resumo = "trilha de estudo por fases, com marcos e dependências",
        unidade = "fase",
        unidades = "fases",
        subunidade = "etapa",
        subunidades = "etapas",
    },
    curso = {
        nome = "Curso",
        artigo = "um curso",
        resumo = "programa com módulos, aulas, exercícios e avaliação",
        unidade = "capítulo",
        unidades = "capítulos",
        subunidade = "subcapítulo",
        subunidades = "subcapítulos",
    },
    guia = {
        nome = "Guia",
        artigo = "um guia",
        resumo = "material de referência prático, direto ao ponto",
        unidade = "parte",
        unidades = "partes",
        subunidade = "seção",
        subunidades = "seções",
    },
}

--- Rótulos do tipo ativo (cai em `roadmap` se o contexto estiver vazio).
function E.rotulo(tipo: string?): Rotulos
    return E.ROTULOS[tipo or ""] or E.ROTULOS.roadmap
end

-- ── erro visível ────────────────────────────────────────────────────────────

--- Publica (ou limpa, com `nil`) a mensagem de erro das três telas.
---
--- Vem em par porque o `if` do template é um teste de VERDADE ("true"/"1"/
--- "sim"/…), não de "não vazio": uma mensagem qualquer em `ctx.erro` é falsy,
--- e a faixa nunca acenderia. `tem_erro` é o interruptor; `erro`, o texto.
function E.erro(msg)
    local texto = msg or ""
    ctx.erro = texto
    ctx.tem_erro = (texto:match("%S") ~= nil) and "true" or "false"
end

-- ── leitura/escrita do contexto ─────────────────────────────────────────────

local function decodificar(bruto, padrao)
    if type(bruto) ~= "string" or bruto == "" then
        return padrao
    end
    local ok, v = pcall(json.decode, bruto)
    if not ok or type(v) ~= "table" then
        return padrao
    end
    return v
end

function E.perguntas()
    return decodificar(ctx.perguntas_json, {})
end

function E.set_perguntas(lista)
    ctx.perguntas_json = json.encode(json.array(lista))
    ctx.total_perguntas = tostring(#lista)
end

function E.respostas()
    return decodificar(ctx.respostas_json, {})
end

function E.set_respostas(mapa)
    -- Objeto, não array: as chaves são ids de pergunta.
    ctx.respostas_json = json.encode(mapa)
end

--- A resposta de uma pergunta, sempre com a forma completa (nunca `nil`).
function E.resposta(id)
    local r = E.respostas()[id]
    if type(r) ~= "table" then
        return { escolhas = {}, livre = "" }
    end
    return {
        escolhas = type(r.escolhas) == "table" and r.escolhas or {},
        livre = type(r.livre) == "string" and r.livre or "",
    }
end

function E.set_resposta(id, resposta)
    local todas = E.respostas()
    todas[id] = {
        escolhas = json.array(resposta.escolhas or {}),
        livre = resposta.livre or "",
    }
    E.set_respostas(todas)
end

function E.indice()
    return tonumber(ctx.q_idx) or 1
end

function E.set_indice(i)
    local total = #E.perguntas()
    if i < 1 then
        i = 1
    end
    if total > 0 and i > total then
        i = total
    end
    ctx.q_idx = tostring(i)
end

function E.pergunta_atual()
    return E.perguntas()[E.indice()]
end

-- ── normalização do que a IA devolve ────────────────────────────────────────

--- Aceita a lista crua do modelo e devolve perguntas com a forma que a UI
--- espera: id estável, texto não vazio, opções como lista de strings.
--- Descarta entradas irrecuperáveis em vez de deixar a tela quebrar.
function E.normalizar(lista, deslocamento)
    local saida = {}
    if type(lista) ~= "table" then
        return saida
    end
    for i, bruta in ipairs(lista) do
        if type(bruta) == "table" and type(bruta.texto) == "string" and bruta.texto ~= "" then
            local opcoes = {}
            if type(bruta.opcoes) == "table" then
                for _, o in ipairs(bruta.opcoes) do
                    if type(o) == "string" and o ~= "" then
                        table.insert(opcoes, o)
                    elseif type(o) == "table" and type(o.label) == "string" then
                        table.insert(opcoes, o.label)
                    end
                end
            end
            table.insert(saida, {
                -- O id precisa ser estável e único mesmo entre rodadas de
                -- aprofundamento, senão respostas antigas migram de dono.
                id = "q" .. tostring((deslocamento or 0) + i),
                texto = bruta.texto,
                ajuda = type(bruta.ajuda) == "string" and bruta.ajuda or "",
                opcoes = json.array(opcoes),
            })
        end
    end
    return saida
end

-- ── projeção para a tela ────────────────────────────────────────────────────

--- Achata a pergunta em foco em chaves simples que o template lê direto.
--- As opções viram uma lista de `{ i, rotulo, cor }` para o `for-each`: a cor
--- e o "✓" no rótulo são o estado de seleção — sem uma chave de contexto por
--- opção, e sem checkbox por linha.
---
--- Roda daqui (e não do `init` da tela `perguntas`) porque o `init` de um
--- componente acontece **uma vez, no registro** — navegar até ele não o chama
--- de novo. Quem muda o estado é que reprojeta.
function E.projetar()
    local perguntas = E.perguntas()
    local total = #perguntas
    ctx.total_perguntas = tostring(total)

    -- Vocabulário do tipo ativo: o cabeçalho e o botão de gerar leem daqui.
    local r = E.rotulo(ctx.tipo)
    ctx.tipo_rotulo = r.nome:upper()
    ctx.tipo_artigo = r.artigo

    local faltam = total - E.respondidas()
    if total == 0 then
        ctx.aviso_gerar = ""
    elseif faltam <= 0 then
        ctx.aviso_gerar = "Todas as perguntas respondidas."
    elseif faltam == 1 then
        ctx.aviso_gerar = "1 pergunta sem resposta — entra como \"sem preferência\"."
    else
        ctx.aviso_gerar = tostring(faltam)
            .. " perguntas sem resposta — entram como \"sem preferência\"."
    end

    if total == 0 then
        ctx.q_texto = ""
        ctx.q_ajuda = ""
        ctx.q_opcoes = "[]"
        ctx.q_livre = ""
        ctx.q_num = "0"
        ctx.tem_perguntas = "false"
        ctx.eh_primeira = "true"
        ctx.eh_ultima = "true"
        ctx.progresso = "0"
        return
    end

    local i = E.indice()
    local p = perguntas[i]
    local r = E.resposta(p.id)

    local marcada = {}
    for _, e in ipairs(r.escolhas) do
        marcada[e] = true
    end

    local opcoes = {}
    for n, rotulo in ipairs(p.opcoes) do
        local sel = marcada[rotulo] == true
        table.insert(opcoes, {
            i = tostring(n),
            rotulo = (sel and "✓  " or "○  ") .. rotulo,
            cor = sel and "#89B4FA" or "#313244",
        })
    end

    -- A pergunta sai numerada no próprio texto: o "Pergunta 3 de 6" do
    -- cabeçalho fica longe do enunciado, e quem está lendo a pergunta quer
    -- saber onde está sem procurar.
    ctx.q_texto = tostring(i) .. ". " .. p.texto
    ctx.q_ajuda = p.ajuda
    ctx.q_opcoes = json.encode(json.array(opcoes))
    ctx.tem_opcoes = (#opcoes > 0) and "true" or "false"
    ctx.q_livre = r.livre
    ctx.q_num = tostring(i)
    ctx.tem_perguntas = "true"
    ctx.eh_primeira = (i <= 1) and "true" or "false"
    ctx.eh_ultima = (i >= total) and "true" or "false"
    -- Complemento de `eh_ultima`: os dois botões do fim da fila ("próxima" e
    -- "concluir") se alternam por `hidden`, e `hidden` não tem negação no
    -- template — então cada um precisa da sua própria chave.
    ctx.ja_no_fim = (i >= total) and "false" or "true"
    ctx.progresso = tostring(math.floor((E.respondidas() / total) * 100))
    ctx.respondidas = tostring(E.respondidas())
end

--- Quantas perguntas têm alguma resposta (opção marcada ou texto livre).
function E.respondidas()
    local n = 0
    for _, p in ipairs(E.perguntas()) do
        local r = E.resposta(p.id)
        if #r.escolhas > 0 or r.livre:match("%S") ~= nil then
            n += 1
        end
    end
    return n
end

--- Os pares pergunta/resposta em texto corrido — o insumo do prompt final.
--- Perguntas sem resposta entram como "(sem preferência)": a ausência também
--- informa o modelo, e omiti-las embaralharia a numeração.
function E.transcricao()
    local linhas = {}
    for n, p in ipairs(E.perguntas()) do
        local r = E.resposta(p.id)
        local partes = {}
        if #r.escolhas > 0 then
            table.insert(partes, table.concat(r.escolhas, "; "))
        end
        if r.livre:match("%S") ~= nil then
            table.insert(partes, r.livre)
        end
        local resposta = #partes > 0 and table.concat(partes, " — ") or "(sem preferência)"
        table.insert(linhas, tostring(n) .. ". " .. p.texto .. "\n   R: " .. resposta)
    end
    return table.concat(linhas, "\n")
end

return E
