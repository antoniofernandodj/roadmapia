--!nolint
-- A obra multi-arquivo: o plano (capítulos × subcapítulos), o estado de cada
-- trecho e a gravação em disco.
--
-- O plano inteiro mora em `ctx.obra_json`. Ele é lido, mutado e reescrito por
-- vários workers "ao mesmo tempo" — mas Lua roda numa thread só, e uma
-- corrotina só cede a vez num `fetch`. Então a regra é simples e vale para
-- tudo aqui: **nunca suspenda entre ler e reescrever o plano**. As funções
-- deste módulo são todas ou puras ou atômicas nesse sentido; o `fetch` fica do
-- lado de fora, no worker.
--
-- Layout em disco (uma obra = uma pasta):
--
--   saidas/<slug>/
--   ├── README.md          sumário com links para tudo
--   ├── 01-<capitulo>/
--   │   ├── README.md      abertura do capítulo
--   │   ├── 01-<trecho>.md
--   │   ├── …
--   │   └── exercicios-01.md   (só em curso, se pedido)
--   ├── …
--   └── prova/                 (só em curso, se pedida)
--       ├── README.md
--       └── parte-01.md
--
-- Os arquivos de exercício não levam prefixo numérico de propósito: letra
-- ordena depois de dígito, então eles caem no fim da listagem do capítulo sem
-- disputar numeração com os trechos — e mudar o número de exercícios na
-- revisão não renumera nada.

local A = require("lib/avaliacao")

local O = {}

-- ── os tipos da obra ────────────────────────────────────────────────────────
--
-- Declarados porque, sem eles, cada `cap.subs` e cada `sub.titulo` vira um
-- "Unknown type used in .. operation" no editor — ruído que esconde erro de
-- verdade. E porque são a documentação da forma que trafega em `ctx.obra_json`.

export type Sub = {
    titulo: string,
    foco: string,
    arquivo: string,
    status: string,
    erro: string,
    -- O que este trecho ensinou de verdade, extraído do bloco `<!--SINTESE-->`
    -- que o próprio autor devolve (ver `P.secao`). Vazio até o trecho ficar
    -- pronto (ou se o modelo não seguir o formato). É o que dá aos trechos
    -- seguintes do MESMO capítulo contexto real, não só o título deste.
    sintese: string,
}

--- Uma chamada que escreve parte dos exercícios de um capítulo, ou parte da
--- prova da obra.
---
--- `de`/`ate` são o pedaço de material que ela cobre — índices de trecho
--- DENTRO do capítulo num lote de exercícios, e índices GLOBAIS de trecho
--- (a obra achatada, ver `O.trechos_planos`) numa parte de prova. É a divisão
--- que impede duas chamadas simultâneas de escreverem o mesmo exercício: elas
--- não recebem o mesmo material. Ver `lib/avaliacao.luau`.
export type Bloco = {
    arquivo: string,
    status: string,
    erro: string,
    de: number,
    ate: number,
    --- Quantos exercícios (ou questões) esta chamada escreve.
    n: number,
}

export type Capitulo = {
    titulo: string,
    resumo: string,
    dir: string,
    arquivo: string,
    status: string,
    erro: string,
    subs: { Sub },
    -- Vazio quando a obra não é um curso, ou quando os exercícios foram
    -- desligados. `nil` num plano gravado por uma versão anterior — todo
    -- acesso a este campo tem de tolerar isso (ver `O.lotes_de`).
    exercicios: { Bloco }?,
    -- O texto da abertura do capítulo, reaproveitado como resumo dele para
    -- os capítulos seguintes (ver `O.concluir`). Vazio até a abertura sair.
    sintese: string,
}

export type Plano = {
    titulo: string,
    resumo: string,
    publico: string,
    -- As observações gerais escritas no fim da entrevista. Moram no PLANO, e
    -- não no contexto, porque é o plano que sobrevive em disco (`obra_json`):
    -- retomar uma produção interrompida, ou refazer as falhas dias depois, tem
    -- de usar as mesmas observações da primeira metade da obra. No contexto
    -- elas se perderiam ao reabrir o app, e a segunda metade sairia com outra
    -- regra que a primeira.
    observacoes: string,
    pasta: string,
    capitulos: { Capitulo },
    -- Os números de exercícios/questões que valeram para ESTA obra. Moram
    -- aqui pela mesma razão que `observacoes`: retomar uma produção
    -- interrompida dias depois tem de usar os mesmos números da primeira
    -- metade, e o contexto se perde ao fechar o app.
    avaliacao: { exercicios_por_capitulo: number, questoes_prova: number }?,
    -- As partes da prova final. Ficam no plano, e não num capítulo, porque a
    -- prova atravessa a obra inteira.
    prova: { Bloco }?,
}

--- Uma unidade de trabalho da fila.
---
---   tipo          cap    sub    idx
---   "trecho"      cap.   trecho  —
---   "abertura"    cap.    —      —
---   "exercicios"  cap.    —     o lote dentro de `cap.exercicios`
---   "prova"        —      —     a parte dentro de `plano.prova`
---
--- `cap` é opcional porque a prova não pertence a capítulo nenhum.
export type Tarefa = {
    tipo: string,
    cap: number?,
    sub: number?,
    idx: number?,
}

export type Contagem = {
    total: number,
    prontos: number,
    erros: number,
    fazendo: number,
}

O.PENDENTE = "pendente"
O.FAZENDO = "fazendo"
O.PRONTO = "pronto"
O.ERRO = "erro"

-- ── leitura/escrita do plano ────────────────────────────────────────────────

function O.plano(): Plano?
    local bruto = ctx.obra_json
    if type(bruto) ~= "string" or bruto == "" then
        return nil
    end
    local ok, v = pcall(json.decode, bruto)
    if not ok or type(v) ~= "table" or type(v.capitulos) ~= "table" then
        return nil
    end
    return v
end

--- Grava o plano E o projeta na tela, sempre.
---
--- Os dois andam juntos de propósito. Quando eram passos separados, `gerar`
--- gravava um plano de 231 trechos e navegava para uma tela que — projetada no
--- arranque, com o contexto vazio — dizia "Nada planejado ainda", sem botão
--- para produzir. Amarrando aqui, esquecer deixa de ser possível.
function O.gravar_plano(plano: Plano)
    ctx.obra_json = json.encode(plano)
    O.projetar(nil, plano)
end

-- ── montagem a partir do esboço da IA ───────────────────────────────────────

--- Normaliza o esboço cru do modelo num plano com estado, caminhos de arquivo
--- e nada de campo faltando. Descarta capítulos/trechos irrecuperáveis em vez
--- de deixar a produção quebrar no meio.
function O.montar(
    esboco: any,
    slug_base: string,
    observacoes: string?,
    avaliacao: { exercicios_por_capitulo: number, questoes_prova: number }?
): (Plano?, string?)
    if type(esboco) ~= "table" or type(esboco.capitulos) ~= "table" then
        return nil, "O modelo não devolveu um esboço com capítulos."
    end

    local pasta = "saidas/" .. slug_base
    local plano = {
        titulo = tostring(esboco.titulo or slug_base),
        resumo = tostring(esboco.resumo or ""),
        publico = tostring(esboco.publico or ""),
        -- Não vem do esboço: o modelo não as inventa, quem escreveu foi a
        -- pessoa. Chegam por parâmetro de quem confirma o plano.
        observacoes = observacoes or "",
        pasta = pasta,
        capitulos = json.array({}),
        avaliacao = {
            exercicios_por_capitulo = (avaliacao ~= nil)
                and avaliacao.exercicios_por_capitulo or 0,
            questoes_prova = (avaliacao ~= nil) and avaliacao.questoes_prova or 0,
        },
        prova = json.array({}),
    }

    for i, c in ipairs(esboco.capitulos) do
        if type(c) == "table" and type(c.titulo) == "string" and c.titulo ~= "" then
            local dir = pasta .. "/" .. O.numero(i) .. "-" .. O.slug(c.titulo)
            local cap = {
                titulo = c.titulo,
                resumo = type(c.resumo) == "string" and c.resumo or "",
                dir = dir,
                arquivo = dir .. "/README.md",
                status = O.PENDENTE,
                erro = "",
                sintese = "",
                subs = json.array({}),
            }
            local brutos = type(c.subcapitulos) == "table" and c.subcapitulos or {}
            for j, s in ipairs(brutos) do
                if type(s) == "table" and type(s.titulo) == "string" and s.titulo ~= "" then
                    table.insert(cap.subs, {
                        titulo = s.titulo,
                        foco = type(s.foco) == "string" and s.foco or s.titulo,
                        arquivo = dir .. "/" .. O.numero(j) .. "-" .. O.slug(s.titulo) .. ".md",
                        status = O.PENDENTE,
                        erro = "",
                        sintese = "",
                    })
                end
            end
            if #cap.subs > 0 then
                table.insert(plano.capitulos, cap)
            end
        end
    end

    if #plano.capitulos == 0 then
        return nil, "O esboço veio sem nenhum capítulo aproveitável."
    end

    -- As tarefas de avaliação são MATERIALIZADAS aqui, junto com as de texto,
    -- e não calculadas a cada `tomar_tarefa`. Duas razões: `O.contar` fica
    -- honesto desde o primeiro clique (a barra de avanço e a extrapolação de
    -- custo já sabem o total real), e editar o esboço na revisão recalcula
    -- tudo do zero — que é o que `O.montar` já promete para slugs e caminhos.
    local cfg = plano.avaliacao
    local total_trechos = 0
    for _, cap in ipairs(plano.capitulos) do
        total_trechos += #cap.subs
        cap.exercicios = json.array({})
        local lotes = A.lotes_exercicios(#cap.subs, cfg.exercicios_por_capitulo)
        for k, f in ipairs(lotes) do
            table.insert(cap.exercicios, {
                arquivo = cap.dir .. "/exercicios-" .. O.numero(k) .. ".md",
                status = O.PENDENTE,
                erro = "",
                de = f.de,
                ate = f.ate,
                n = f.n,
            })
        end
    end
    for k, f in ipairs(A.partes_prova(total_trechos, cfg.questoes_prova)) do
        table.insert(plano.prova, {
            arquivo = pasta .. "/prova/parte-" .. O.numero(k) .. ".md",
            status = O.PENDENTE,
            erro = "",
            de = f.de,
            ate = f.ate,
            n = f.n,
        })
    end

    return plano, nil
end

-- ── acesso tolerante a planos antigos ───────────────────────────────────────

--- Os lotes de exercícios de um capítulo (`O.lotes_de`) e as partes da prova
--- de um plano (`O.prova_de`).
---
--- Um `obra_json` gravado antes desta versão não tem os campos; retomar uma
--- produção daquelas não pode explodir. Uma lista vazia faz todo o resto do
--- módulo se comportar exatamente como antes.
function O.lotes_de(cap: Capitulo): { Bloco }
    local lista = cap.exercicios
    if type(lista) ~= "table" then
        return {}
    end
    return lista
end

function O.prova_de(plano: Plano): { Bloco }
    local lista = plano.prova
    if type(lista) ~= "table" then
        return {}
    end
    return lista
end

--- A obra achatada: todos os trechos em ordem, cada um sabendo de que capítulo
--- veio. É o índice GLOBAL que as partes da prova usam — e o que `producao`
--- percorre para montar o prompt de uma parte.
function O.trechos_planos(plano: Plano): { { ci: number, si: number, cap: Capitulo, sub: Sub } }
    local flat = {}
    for ci, cap in ipairs(plano.capitulos) do
        for si, sub in ipairs(cap.subs) do
            table.insert(flat, { ci = ci, si = si, cap = cap, sub = sub })
        end
    end
    return flat
end

-- ── a fila de trabalho ──────────────────────────────────────────────────────

--- Reserva a próxima tarefa pendente e a marca como "fazendo", numa operação
--- só. É o que impede dois workers de pegarem o mesmo trecho: entre a leitura
--- e a escrita do plano não há `fetch`, logo não há troca de corrotina.
---
--- Dentro de um MESMO capítulo, os trechos saem em ordem, um de cada vez —
--- nunca dois trechos do mesmo capítulo "fazendo" ao mesmo tempo. É o que
--- garante que, ao escrever o trecho N, a síntese dos trechos 1..N-1 daquele
--- capítulo já existe (ver `O.vizinhanca`); sem isto o pool de workers ataca
--- vários trechos do capítulo 1 ao mesmo tempo, e o de trás nunca teria o
--- contexto do da frente. Capítulos DIFERENTES continuam livres para correr
--- em paralelo — é só a ordem DENTRO de um capítulo que fica travada.
---
--- A abertura de um capítulo (`tipo = "abertura"`) só é liberada depois que
--- todos os trechos dele estão prontos — ela fala sobre eles.
function O.tomar_tarefa(): Tarefa?
    local plano = O.plano()
    if plano == nil then
        return nil
    end

    for ci, cap in ipairs(plano.capitulos) do
        for si, sub in ipairs(cap.subs) do
            if sub.status ~= O.PRONTO and sub.status ~= O.ERRO then
                -- O primeiro trecho não resolvido deste capítulo: só ele pode
                -- sair agora. Se está "fazendo", este capítulo não tem nada
                -- elegível — os de trás esperam, e o laço segue para o
                -- próximo capítulo em vez de travar a fila inteira aqui.
                if sub.status == O.PENDENTE then
                    sub.status = O.FAZENDO
                    O.gravar_plano(plano)
                    return { tipo = "trecho", cap = ci, sub = si }
                end
                break
            end
        end
    end

    for ci, cap in ipairs(plano.capitulos) do
        if cap.status == O.PENDENTE and O.capitulo_completo(cap) then
            cap.status = O.FAZENDO
            O.gravar_plano(plano)
            return { tipo = "abertura", cap = ci }
        end
    end

    -- Um lote de exercícios espera só os trechos DA FAIXA DELE, não o capítulo
    -- inteiro: num capítulo de 20 trechos com 2 lotes, o primeiro já pode sair
    -- na metade. Mais paralelismo, e o contexto que ele recebe é o mesmo de
    -- qualquer jeito — são os trechos que ele cobre.
    for ci, cap in ipairs(plano.capitulos) do
        for k, lote in ipairs(O.lotes_de(cap)) do
            if lote.status == O.PENDENTE and O.faixa_resolvida(cap.subs, lote.de, lote.ate) then
                lote.status = O.FAZENDO
                O.gravar_plano(plano)
                return { tipo = "exercicios", cap = ci, idx = k }
            end
        end
    end

    -- A prova, por último e pela mesma regra, só que sobre a obra achatada.
    local partes = O.prova_de(plano)
    if #partes > 0 then
        local flat = O.trechos_planos(plano)
        local subs_globais = {}
        for i, t in ipairs(flat) do
            subs_globais[i] = t.sub
        end
        for k, parte in ipairs(partes) do
            if parte.status == O.PENDENTE
                and O.faixa_resolvida(subs_globais, parte.de, parte.ate)
            then
                parte.status = O.FAZENDO
                O.gravar_plano(plano)
                return { tipo = "prova", idx = k }
            end
        end
    end

    return nil
end

--- Todos os trechos de `de..ate` já resolvidos (prontos ou falhos)?
---
--- É a dependência dos lotes de exercício e das partes de prova: escrever um
--- exercício sobre um trecho que ainda não existe é escrever sobre o PLANO
--- dele, e o app já paga caro para que o material fale do que foi escrito.
--- Um trecho que falhou conta como resolvido — senão um erro de rede num
--- trecho travaria o lote inteiro para sempre.
function O.faixa_resolvida(subs: { Sub }, de: number, ate: number): boolean
    for k = de, ate do
        local s = subs[k]
        if s == nil then
            return false
        end
        if s.status ~= O.PRONTO and s.status ~= O.ERRO then
            return false
        end
    end
    return true
end

function O.capitulo_completo(cap: Capitulo): boolean
    for _, s in ipairs(cap.subs) do
        if s.status ~= O.PRONTO and s.status ~= O.ERRO then
            return false
        end
    end
    return true
end

-- ── a síntese de cada trecho ────────────────────────────────────────────────

-- O bloco que `P.secao` pede no fim de cada trecho: um resumo do que ele
-- ensinou de verdade, para os trechos seguintes referenciarem em vez de
-- adivinhar a partir só do título. `%-` porque em padrão Luau `-` sozinho é
-- quantificador, não hífen literal (mesma pegadinha de `O.slug` abaixo).
local PADRAO_SINTESE = "<!%-%-SINTESE%-%->(.-)<!%-%-/SINTESE%-%->"

local function aparar(s: string): string
    return s:match("^%s*(.-)%s*$") or s
end

--- Separa o corpo do trecho (o que vai para o arquivo) do bloco de síntese
--- que o modelo anexa no fim (o que alimenta a vizinhança dos próximos
--- trechos — ver `O.vizinhanca`). Se o bloco não vier — o modelo não seguiu
--- o formato —, devolve o texto inteiro e síntese vazia: o trecho perde o
--- contexto extra, mas nada quebra.
function O.extrair_sintese(texto: string): (string, string)
    local sintese = texto:match(PADRAO_SINTESE)
    if sintese == nil then
        return texto, ""
    end
    local limpo = aparar((texto:gsub(PADRAO_SINTESE, "")))
    return limpo, aparar(sintese)
end

-- ── de uma tarefa para o que ela escreve ────────────────────────────────────

--- A entrada do plano que uma tarefa preenche: o `Sub` de um trecho, o
--- `Capitulo` de uma abertura.
---
--- Existe porque `concluir`, `falhar` e `reenfileirar` faziam esta mesma
--- resolução, cada uma com a sua cópia do `if`. Três cópias já eram três
--- chances de divergir; com mais tipos de tarefa (exercícios, prova) seriam
--- doze caminhos para acertar, e acertar onze de doze é o resultado provável.
--- Aqui há um lugar só para ensinar um tipo novo.
---
--- O retorno é `any` de propósito: as entradas têm todas `arquivo`, `status` e
--- `erro`, mas são tipos diferentes, e Luau não deixa escrever num tipo-união.
function O.alvo_de(plano: Plano, tarefa: Tarefa): any?
    local idx = tarefa.idx

    -- A prova é a única que não pertence a capítulo nenhum.
    if tarefa.tipo == "prova" then
        if idx == nil then
            return nil
        end
        return O.prova_de(plano)[idx]
    end

    local ci = tarefa.cap
    if ci == nil then
        return nil
    end
    local cap = plano.capitulos[ci]
    if cap == nil then
        return nil
    end
    if tarefa.tipo == "abertura" then
        return cap
    end
    if tarefa.tipo == "exercicios" then
        if idx == nil then
            return nil
        end
        return O.lotes_de(cap)[idx]
    end
    if tarefa.sub ~= nil then
        return cap.subs[tarefa.sub]
    end
    return nil
end

--- Grava o texto no arquivo da tarefa e marca o estado. Atômico, como acima.
--- Devolve `ok, motivo` para o chamador poder registrar uma falha de DISCO —
--- que é indistinguível de uma falha de rede olhando só para o estado, e foi
--- justamente o buraco que deixou "gerou a pasta mas não gerou os arquivos"
--- sem explicação.
function O.concluir(tarefa: Tarefa, texto: string): (boolean, string?)
    local plano = O.plano()
    if plano == nil then
        return false, "sem plano"
    end
    local alvo = O.alvo_de(plano, tarefa)
    if alvo == nil then
        return false, "tarefa fora do plano"
    end

    -- A síntese que a tarefa passa adiante. Na abertura é o texto dela inteiro
    -- (já é o resumo grounded do capítulo, de graça — nenhuma chamada extra);
    -- num trecho comum é o bloco `<!--SINTESE-->` que `P.secao` pede no fim da
    -- resposta, separado do corpo antes de gravar.
    --
    -- Exercícios e prova não passam nada adiante: ninguém escreve em cima
    -- deles, e o texto vai inteiro para o arquivo.
    local corpo, sintese = texto, ""
    if tarefa.tipo == "abertura" then
        local ci = tarefa.cap
        local cap = (ci ~= nil) and plano.capitulos[ci] or nil
        if cap == nil then
            return false, "capítulo fora do plano"
        end
        sintese = aparar(texto)
        corpo = O.cabecalho_capitulo(plano, cap, texto)
    elseif tarefa.tipo == "trecho" then
        corpo, sintese = O.extrair_sintese(texto)
    else
        corpo = aparar(texto)
    end

    local ok, err = write_file(alvo.arquivo, corpo)
    if ok then
        alvo.status = O.PRONTO
        alvo.erro = ""
        if tarefa.tipo == "trecho" or tarefa.tipo == "abertura" then
            alvo.sintese = sintese
        end
    else
        alvo.status = O.ERRO
        alvo.erro = tostring(err)
    end
    O.gravar_plano(plano)
    return ok, err
end

--- Marca a tarefa como falha (erro de rede/modelo). Ela volta a ser
--- retomável por "refazer falhas", sem perder o que já foi feito.
function O.falhar(tarefa: Tarefa, msg: any)
    local plano = O.plano()
    if plano == nil then
        return
    end
    local alvo = O.alvo_de(plano, tarefa)
    if alvo ~= nil then
        alvo.status = O.ERRO
        alvo.erro = tostring(msg)
    end
    O.gravar_plano(plano)
end

--- Devolve UMA tarefa à fila sem marcá-la como falha. Usado no recuo por rate
--- limit: o trecho não deu errado, só não é hora — outro worker (ou este,
--- depois da espera) pega de novo.
function O.reenfileirar(tarefa: Tarefa)
    local plano = O.plano()
    if plano == nil then
        return
    end
    local alvo = O.alvo_de(plano, tarefa)
    if alvo ~= nil and alvo.status == O.FAZENDO then
        alvo.status = O.PENDENTE
    end
    O.gravar_plano(plano)
end

--- Devolve tudo que falhou para a fila. Também destrava o que ficou preso em
--- "fazendo" (app fechado no meio da produção).
function O.reenfileirar_falhas(): number
    local plano = O.plano()
    if plano == nil then
        return 0
    end
    local n = 0
    local function soltar(alvo: any)
        if alvo.status == O.ERRO or alvo.status == O.FAZENDO then
            alvo.status = O.PENDENTE
            alvo.erro = ""
            n += 1
        end
    end
    for _, cap in ipairs(plano.capitulos) do
        for _, sub in ipairs(cap.subs) do
            soltar(sub)
        end
        soltar(cap)
        for _, lote in ipairs(O.lotes_de(cap)) do
            soltar(lote)
        end
    end
    for _, parte in ipairs(O.prova_de(plano)) do
        soltar(parte)
    end
    O.gravar_plano(plano)
    return n
end

-- ── o contexto que cada trecho recebe ───────────────────────────────────────

--- O que já foi ensinado antes de um trecho e o que vem depois. É isto que
--- impede 200 chamadas independentes de produzirem 200 textos que se repetem
--- — cada autor sabe o que pode assumir e o que deixar.
---
--- "Antes", dentro do MESMO capítulo, é a síntese de cada trecho já escrito
--- (não só o título — `O.tomar_tarefa` garante que eles saem em ordem, então
--- a síntese sempre existe quando este trecho é escrito). De capítulos
--- ANTERIORES é a síntese do capítulo inteiro (a abertura dele, reaproveitada
--- — ver `O.concluir`), condensada num parágrafo por capítulo em vez de um
--- por trecho, para o prompt não crescer com o tamanho da obra. Capítulos
--- correm em paralelo entre si, então a síntese de um capítulo anterior pode
--- ainda não existir — cai de volta no `resumo` planejado, que sempre existe.
---
--- "Depois" continua só título, de propósito: o autor não deve invadir
--- conteúdo futuro (ver `P.secao`).
function O.vizinhanca(plano: Plano, ci: number, si: number): { antes: string, depois: string }
    local antes, depois = {}, {}

    for k = 1, ci - 1 do
        local c = plano.capitulos[k]
        local nota = (c.sintese ~= nil and c.sintese ~= "") and c.sintese or c.resumo
        local linha = "- (cap. " .. k .. ") " .. c.titulo
        if nota ~= nil and nota ~= "" then
            linha = linha .. ": " .. nota
        end
        table.insert(antes, linha)
    end
    local cap = plano.capitulos[ci]
    for k = 1, si - 1 do
        local s = cap.subs[k]
        local nota = (s.sintese ~= nil and s.sintese ~= "") and s.sintese or s.foco
        local linha = "- " .. s.titulo
        if nota ~= nil and nota ~= "" then
            linha = linha .. ": " .. nota
        end
        table.insert(antes, linha)
    end
    for k = si + 1, #cap.subs do
        table.insert(depois, "- " .. cap.subs[k].titulo)
    end
    for k = ci + 1, #plano.capitulos do
        table.insert(depois, "- (cap. " .. k .. ") " .. plano.capitulos[k].titulo)
    end

    return {
        antes = table.concat(antes, "\n"),
        depois = table.concat(depois, "\n"),
    }
end

-- ── contagens para a tela ───────────────────────────────────────────────────

function O.contar(plano: Plano): Contagem
    local c = { total = 0, prontos = 0, erros = 0, fazendo = 0 }
    local function somar(status: string)
        c.total += 1
        if status == O.PRONTO then
            c.prontos += 1
        elseif status == O.ERRO then
            c.erros += 1
        elseif status == O.FAZENDO then
            c.fazendo += 1
        end
    end
    for _, cap in ipairs(plano.capitulos) do
        for _, sub in ipairs(cap.subs) do
            somar(sub.status)
        end
        somar(cap.status) -- a abertura do capítulo também é uma tarefa
        for _, lote in ipairs(O.lotes_de(cap)) do
            somar(lote.status)
        end
    end
    for _, parte in ipairs(O.prova_de(plano)) do
        somar(parte.status)
    end
    return c
end

-- ── projeção para a tela ────────────────────────────────────────────────────

--- Publica no contexto tudo que a tela `producao` lê sobre o PLANO.
---
--- Mora aqui, e não no `init` daquela tela, pela mesma razão de sempre neste
--- app: o `init` de um componente roda no REGISTRO, não a cada navegação. Era
--- exatamente esse o bug de "gerou a pasta mas não gerou os arquivos" — o
--- esboço era escrito e a tela, projetada no arranque com o contexto vazio,
--- continuava dizendo "Nada planejado ainda", sem botão para produzir. Quem
--- muda o plano é que projeta.
function O.projetar(rotulos: { nome: string, unidades: string }?, plano: Plano?): Contagem?
    -- `plano` opcional: quem acabou de montá-lo passa o objeto e evita um
    -- decode de ~70 KB — este caminho roda uma vez por tarefa concluída.
    plano = plano or O.plano()
    if plano == nil then
        ctx.tem_obra = "false"
        ctx.obra_titulo = "Produção"
        ctx.obra_subtitulo = ""
        ctx.obra_pasta = ""
        ctx.capitulos_ui = "[]"
        ctx.prontos = "0"
        ctx.total_tarefas = "0"
        ctx.pct = "0"
        ctx.tem_erros = "false"
        ctx.sem_falhas = "true"
        ctx.nada_a_fazer = "true"
        ctx.pode_salvar = "false"
        ctx.tem_prova = "false"
        ctx.prova_detalhe = ""
        ctx.prova_marca = "·"
        ctx.prova_cor = "#45475A"
        return nil
    end

    local c = O.contar(plano)
    ctx.tem_obra = "true"
    ctx.obra_titulo = plano.titulo
    ctx.obra_pasta = plano.pasta
    ctx.n_capitulos = tostring(#plano.capitulos)
    ctx.prontos = tostring(c.prontos)
    ctx.total_tarefas = tostring(c.total)
    ctx.pct = tostring(math.floor((c.prontos / math.max(c.total, 1)) * 100))
    ctx.tem_erros = (c.erros > 0) and "true" or "false"
    ctx.sem_falhas = (c.erros > 0) and "false" or "true"
    ctx.rotulo_erros = tostring(c.erros) .. " falharam"
    ctx.nada_a_fazer = (c.prontos >= c.total) and "true" or "false"
    -- Diferente de `nada_a_fazer` (também "true" com `total == 0`, obra
    -- ainda não montada): só existe algo pra salvar quando pelo menos um
    -- trecho foi produzido de verdade. Controla o botão "Salvar obra".
    ctx.pode_salvar = (c.prontos >= c.total and c.total > 0) and "true" or "false"
    ctx.rotulo_produzir = (c.prontos > 0) and "Continuar produção" or "Produzir a obra"

    if rotulos ~= nil then
        -- "trechos" era impreciso mesmo antes (o total sempre incluiu as
        -- aberturas); com exercícios e prova na conta, seria errado. A
        -- composição vem logo depois, para o número grande não ficar mudo.
        local partes = { rotulos.nome, tostring(#plano.capitulos) .. " " .. rotulos.unidades,
            tostring(c.total) .. " tarefas" }
        local n_exercicios, n_questoes = 0, 0
        for _, cap in ipairs(plano.capitulos) do
            for _, lote in ipairs(O.lotes_de(cap)) do
                n_exercicios += lote.n
            end
        end
        for _, parte in ipairs(O.prova_de(plano)) do
            n_questoes += parte.n
        end
        if n_exercicios > 0 then
            table.insert(partes, tostring(n_exercicios) .. " exercícios")
        end
        if n_questoes > 0 then
            table.insert(partes, "prova de " .. tostring(n_questoes) .. " questões")
        end
        ctx.obra_subtitulo = table.concat(partes, " · ")
    end

    local linhas = {}
    for i, cap in ipairs(plano.capitulos) do
        local feitos, erros = 0, 0
        for _, s in ipairs(cap.subs) do
            if s.status == O.PRONTO then
                feitos = feitos + 1
            elseif s.status == O.ERRO then
                erros = erros + 1
            end
        end
        local lotes = O.lotes_de(cap)
        local lotes_feitos = 0
        for _, lote in ipairs(lotes) do
            if lote.status == O.PRONTO then
                lotes_feitos += 1
            elseif lote.status == O.ERRO then
                erros += 1
            end
        end

        local total_cap = #cap.subs
        local marca, cor
        if erros > 0 then
            marca, cor = "!", "#F38BA8"
        elseif feitos >= total_cap and lotes_feitos >= #lotes and cap.status == O.PRONTO then
            marca, cor = "✓", "#A6E3A1"
        elseif feitos > 0 then
            marca, cor = "…", "#F9E2AF"
        else
            marca, cor = "·", "#45475A"
        end

        local detalhe = tostring(feitos) .. "/" .. tostring(total_cap) .. " trechos"
        if #lotes > 0 then
            detalhe = detalhe .. "  ·  exercícios " .. tostring(lotes_feitos)
                .. "/" .. tostring(#lotes)
        end
        if erros > 0 then
            detalhe = detalhe .. "  ·  " .. tostring(erros) .. " com erro"
        end

        table.insert(linhas, {
            n = tostring(i),
            titulo = cap.titulo,
            detalhe = detalhe,
            marca = marca,
            cor = cor,
        })
    end
    ctx.capitulos_ui = json.encode(json.array(linhas))

    -- A prova não cabe na lista de capítulos: não pertence a nenhum. Ganha um
    -- bloco próprio na tela, que só existe quando ela foi pedida.
    local partes = O.prova_de(plano)
    ctx.tem_prova = (#partes > 0) and "true" or "false"
    if #partes > 0 then
        local feitas, com_erro, questoes = 0, 0, 0
        for _, p in ipairs(partes) do
            questoes += p.n
            if p.status == O.PRONTO then
                feitas += 1
            elseif p.status == O.ERRO then
                com_erro += 1
            end
        end
        local detalhe = tostring(feitas) .. " de " .. tostring(#partes)
            .. ((#partes == 1) and " parte" or " partes")
            .. "  ·  " .. tostring(questoes) .. " questões"
        if com_erro > 0 then
            detalhe = detalhe .. "  ·  " .. tostring(com_erro) .. " com erro"
        end
        ctx.prova_detalhe = detalhe
        if com_erro > 0 then
            ctx.prova_marca, ctx.prova_cor = "!", "#F38BA8"
        elseif feitas >= #partes then
            ctx.prova_marca, ctx.prova_cor = "✓", "#A6E3A1"
        elseif feitas > 0 then
            ctx.prova_marca, ctx.prova_cor = "…", "#F9E2AF"
        else
            ctx.prova_marca, ctx.prova_cor = "·", "#45475A"
        end
    else
        ctx.prova_detalhe = ""
        ctx.prova_marca = "·"
        ctx.prova_cor = "#45475A"
    end
    return c
end

-- ── índices em disco ────────────────────────────────────────────────────────

function O.cabecalho_capitulo(plano: Plano, cap: Capitulo, corpo: string): string
    local linhas = {
        "# " .. cap.titulo,
        "",
        corpo,
        "",
        "---",
        "",
        "## Neste capítulo",
        "",
    }
    for i, sub in ipairs(cap.subs) do
        local nome = sub.arquivo:match("([^/]+)$") or sub.arquivo
        local marca = (sub.status == O.PRONTO) and "" or "  *(não gerado)*"
        table.insert(linhas, tostring(i) .. ". [" .. sub.titulo .. "](" .. nome .. ")" .. marca)
    end

    local lotes = O.lotes_de(cap)
    if #lotes > 0 then
        table.insert(linhas, "")
        table.insert(linhas, "## Exercícios")
        table.insert(linhas, "")
        for i, lote in ipairs(lotes) do
            local nome = lote.arquivo:match("([^/]+)$") or lote.arquivo
            local marca = (lote.status == O.PRONTO) and "" or "  *(não gerado)*"
            -- A faixa aparece no rótulo porque ela É a promessa do arquivo:
            -- "exercícios dos trechos 1 a 10", não "exercícios, parte 1".
            table.insert(linhas, tostring(i) .. ". [" .. tostring(lote.n)
                .. " exercícios — trechos " .. tostring(lote.de) .. " a "
                .. tostring(lote.ate) .. "](" .. nome .. ")" .. marca)
        end
    end

    table.insert(linhas, "")
    table.insert(linhas, "[↑ Sumário da obra](../README.md)")
    return table.concat(linhas, "\n")
end

--- O README da raiz: capa + sumário com links para todos os arquivos.
--- Reescrito a cada conclusão, então reflete o estado mesmo a meio caminho.
function O.gravar_sumario()
    local plano = O.plano()
    if plano == nil then
        return
    end
    local c = O.contar(plano)
    local linhas = {
        "# " .. plano.titulo,
        "",
        plano.resumo,
        "",
    }
    if plano.publico ~= "" then
        table.insert(linhas, "**Para quem é:** " .. plano.publico)
        table.insert(linhas, "")
    end
    table.insert(linhas, "> " .. tostring(c.prontos) .. " de " .. tostring(c.total)
        .. " trechos gerados.")
    table.insert(linhas, "")
    table.insert(linhas, "## Sumário")
    table.insert(linhas, "")

    for i, cap in ipairs(plano.capitulos) do
        local dir = cap.dir:match("([^/]+)$") or cap.dir
        table.insert(linhas, "### " .. tostring(i) .. ". [" .. cap.titulo
            .. "](" .. dir .. "/README.md)")
        table.insert(linhas, "")
        if cap.resumo ~= "" then
            table.insert(linhas, cap.resumo)
            table.insert(linhas, "")
        end
        for j, sub in ipairs(cap.subs) do
            local nome = sub.arquivo:match("([^/]+)$") or sub.arquivo
            local marca = (sub.status == O.PRONTO) and "" or "  *(pendente)*"
            table.insert(linhas, "  " .. tostring(j) .. ". [" .. sub.titulo .. "]("
                .. dir .. "/" .. nome .. ")" .. marca)
        end
        for _, lote in ipairs(O.lotes_de(cap)) do
            local nome = lote.arquivo:match("([^/]+)$") or lote.arquivo
            local marca = (lote.status == O.PRONTO) and "" or "  *(pendente)*"
            table.insert(linhas, "  · [Exercícios — trechos " .. tostring(lote.de)
                .. " a " .. tostring(lote.ate) .. " (" .. tostring(lote.n) .. ")]("
                .. dir .. "/" .. nome .. ")" .. marca)
        end
        table.insert(linhas, "")
    end

    local partes = O.prova_de(plano)
    if #partes > 0 then
        local questoes = 0
        for _, p in ipairs(partes) do
            questoes += p.n
        end
        table.insert(linhas, "### [Prova final](prova/README.md)")
        table.insert(linhas, "")
        table.insert(linhas, tostring(questoes) .. " questões em "
            .. tostring(#partes) .. ((#partes == 1) and " parte." or " partes."))
        table.insert(linhas, "")
    end

    write_file(plano.pasta .. "/README.md", table.concat(linhas, "\n"))
    O.gravar_indice_prova(plano)
end

--- O `prova/README.md`: a capa da prova, com o que cada parte cobre.
---
--- Não custa chamada nenhuma — é montado daqui, do que o plano já sabe. Sai
--- junto do sumário da raiz (que roda a cada tarefa concluída), então reflete
--- o estado mesmo a meio caminho.
function O.gravar_indice_prova(plano: Plano)
    local partes = O.prova_de(plano)
    if #partes == 0 then
        return
    end
    local flat = O.trechos_planos(plano)
    local questoes = 0
    for _, p in ipairs(partes) do
        questoes += p.n
    end

    local linhas = {
        "# Prova final — " .. plano.titulo,
        "",
        tostring(questoes) .. " questões, divididas por assunto. Cada parte cobre um",
        "pedaço do curso; juntas, cobrem o curso inteiro, sem repetição.",
        "",
        "O gabarito de cada parte vem no fim do próprio arquivo dela — dá para",
        "responder tudo antes de descer até ele.",
        "",
    }
    for i, p in ipairs(partes) do
        local nome = p.arquivo:match("([^/]+)$") or p.arquivo
        -- De que capítulos são os trechos desta parte: é isso que diz à pessoa
        -- o que estudar antes de abrir o arquivo.
        local primeiro = flat[p.de]
        local ultimo = flat[p.ate]
        local faixa = ""
        if primeiro ~= nil and ultimo ~= nil then
            if primeiro.ci == ultimo.ci then
                faixa = "capítulo " .. tostring(primeiro.ci)
            else
                faixa = "capítulos " .. tostring(primeiro.ci) .. " a " .. tostring(ultimo.ci)
            end
        end
        local marca = (p.status == O.PRONTO) and "" or "  *(não gerada)*"
        table.insert(linhas, tostring(i) .. ". [Parte " .. tostring(i) .. " — "
            .. tostring(p.n) .. " questões" .. ((faixa ~= "") and (", " .. faixa) or "")
            .. "](" .. nome .. ")" .. marca)
    end
    table.insert(linhas, "")
    table.insert(linhas, "[↑ Sumário da obra](../README.md)")
    write_file(plano.pasta .. "/prova/README.md", table.concat(linhas, "\n"))
end

-- ── utilidades ──────────────────────────────────────────────────────────────

function O.numero(n: number): string
    return (n < 10) and ("0" .. tostring(n)) or tostring(n)
end

-- Acentos → ASCII, aplicado ANTES do slug. Sem isto todo acento cai no
-- `[^%w]` e vira hífen — em português isso é a regra, não a exceção:
-- "Introdução à Concorrência" viraria `introdu-o-concorr-ncia`. Como `lower()`
-- do Lua só mexe em ASCII, as maiúsculas acentuadas precisam entrar aqui também.
local ACENTOS = {
    ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a",
    ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
    ["í"] = "i", ["ì"] = "i", ["î"] = "i", ["ï"] = "i",
    ["ó"] = "o", ["ò"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o",
    ["ú"] = "u", ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
    ["ç"] = "c", ["ñ"] = "n",
    ["Á"] = "a", ["À"] = "a", ["Â"] = "a", ["Ã"] = "a", ["Ä"] = "a",
    ["É"] = "e", ["È"] = "e", ["Ê"] = "e", ["Ë"] = "e",
    ["Í"] = "i", ["Ì"] = "i", ["Î"] = "i", ["Ï"] = "i",
    ["Ó"] = "o", ["Ò"] = "o", ["Ô"] = "o", ["Õ"] = "o", ["Ö"] = "o",
    ["Ú"] = "u", ["Ù"] = "u", ["Û"] = "u", ["Ü"] = "u",
    ["Ç"] = "c", ["Ñ"] = "n",
}

--- Pedaço seguro de nome de arquivo. Os parênteses descartam o segundo retorno
--- do `gsub` (a contagem), que senão vazaria pelo `return`.
function O.slug(texto: any): string
    local limpo = tostring(texto)
    for de, para in pairs(ACENTOS) do
        limpo = (limpo:gsub(de, para))
    end
    limpo = (limpo:lower():gsub("[^%w]+", "-"))
    limpo = (limpo:gsub("^%-+", ""))
    limpo = (limpo:sub(1, 40):gsub("%-+$", ""))
    if limpo == "" then
        return "trecho"
    end
    return limpo
end

return O
