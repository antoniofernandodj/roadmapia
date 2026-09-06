--!nolint
-- Os prompts. Ficam isolados aqui porque são a parte que mais se mexe — dá
-- para ajustar o tom e a densidade do material sem tocar em tela nenhuma (e,
-- com o hot-reload do glacier, sem recompilar).
--
-- A geração tem DUAS fases, e a razão é dura: uma única chamada tem teto de
-- saída (alguns milhares de tokens), e nesse espaço só cabe um índice. Foi
-- exatamente o que a primeira versão produzia — uma grade de estudos, sem uma
-- linha de código dentro. Então:
--
--   fase 1 (`P.esboco`)  — 1 chamada: divide o assunto em capítulos e
--                          subcapítulos, só títulos e foco de cada um.
--   fase 2 (`P.secao`)   — 1 chamada POR SUBCAPÍTULO: escreve o conteúdo
--                          daquele pedaço, com o teto de saída inteiro à
--                          disposição de um assunto pequeno.
--
-- É a fase 2 que produz material de verdade: 200 chamadas de ~1.200 palavras
-- dão um livro, não uma ementa.

local E = require("lib/entrevista")

-- Formas que os prompts leem. Estruturais (só os campos usados) porque o
-- `require` do glacier é uma global custom e o checker não consegue seguir os
-- tipos exportados de outro módulo.
type Obra = { titulo: string, resumo: string, publico: string, observacoes: string? }
type Capitulo = { titulo: string, resumo: string }
type Sub = { titulo: string, foco: string }
type Vizinhanca = { antes: string, depois: string }

local P = {}

--- O bloco das OBSERVAÇÕES GERAIS, escrito pela pessoa no fim da entrevista.
---
--- Entra nos três prompts (esboço, trecho, abertura) e é o mesmo texto nos
--- três: é uma instrução sobre a obra INTEIRA, e valer só em alguns lugares
--- produziria uma obra que muda de regra no meio. Vazio quando não há nada
--- escrito — um cabeçalho "Observações:" seguido de nada é ruído que o modelo
--- tenta interpretar.
---
--- Fica perto do FIM de cada prompt, logo antes da instrução de escrever, e
--- não junto do cabeçalho: é a última coisa que o modelo lê antes de agir, e
--- diz explicitamente que vence o resto — senão uma regra geral ("nada de
--- código") perde para uma instrução específica do trecho três telas acima.
local function observacoes(obra: Obra): { string }
    local texto = obra.observacoes or ""
    if texto == "" then
        return {}
    end
    return {
        "OBSERVAÇÕES DE QUEM PEDIU — valem para a obra inteira e para ESTE",
        "trecho. Em caso de conflito com o que foi dito acima, elas vencem:",
        "",
        texto,
        "",
    }
end

-- ── fase 0: a entrevista ────────────────────────────────────────────────────

P.SISTEMA_ENTREVISTA = [[
Você é um projetista instrucional experiente. Antes de produzir qualquer
material, você entrevista quem pediu para descobrir o que ele realmente
precisa — nível atual, objetivo concreto, tempo disponível, contexto de uso e
restrições.

Suas perguntas são curtas, específicas ao assunto (nunca genéricas) e cada uma
vem com opções plausíveis que cobrem a maior parte dos casos, deixando espaço
para quem quiser responder por escrito.

RESTRIÇÃO DE MÍDIA — inegociável:
O material produzido é SEMPRE, e apenas, TEXTO ESCRITO em Markdown. Não existe
vídeo, áudio, aula ao vivo, slide, quiz interativo, app, mentoria ou turma.
Portanto NUNCA pergunte sobre formato, mídia, suporte ou canal de entrega, e
nunca ofereça uma opção que pressuponha algo além de texto ("videoaulas",
"podcast", "aulas gravadas", "ao vivo", "plataforma"). Perguntar isso cria uma
expectativa que o material não pode cumprir.

Gaste as perguntas no que MUDA O TEXTO: profundidade, recorte do assunto,
pré-requisitos que se pode assumir, quais ferramentas/versões usar nos
exemplos, que tipo de exemplo serve, o que deve ficar de fora.
]]

--- Pede o questionário de refinamento sobre o assunto.
--- `anteriores` (opcional) é a transcrição do que já foi respondido, para uma
--- rodada de aprofundamento que não repete o que já se sabe.
function P.entrevista(assunto: string, tipo: string?, quantidade: number, anteriores: string?): string
    local r = E.rotulo(tipo)
    local partes = {
        "Alguém quer que você produza " .. r.artigo .. " (" .. r.resumo .. ") sobre:",
        "",
        assunto,
        "",
        "O material será TEXTO ESCRITO em Markdown — só isso, nada de vídeo, aula",
        "ou plataforma. Não pergunte sobre formato nem ofereça opções de mídia.",
        "",
        "Formule " .. tostring(quantidade) .. " perguntas de refinamento que mudem de verdade",
        "o material final. Elas devem ser específicas DESTE assunto — se o assunto",
        "fosse outro, as perguntas teriam de ser outras.",
    }

    if anteriores ~= nil and anteriores ~= "" then
        table.insert(partes, "")
        table.insert(partes, "A pessoa já respondeu o que segue. NÃO repita nem reformule")
        table.insert(partes, "estas perguntas; aprofunde a partir delas.")
        table.insert(partes, "")
        table.insert(partes, anteriores)
    end

    table.insert(partes, "")
    table.insert(partes, [[
Devolva um array JSON. Cada item:

  {
    "texto":  "a pergunta, em uma frase",
    "ajuda":  "por que ela importa, em no máximo 12 palavras",
    "opcoes": ["4 a 6 respostas plausíveis, curtas e mutuamente distintas"]
  }

As opções são sugestões marcáveis — a pessoa também pode escrever a dela.
Ordene da pergunta mais decisiva para a menos decisiva.]])

    return table.concat(partes, "\n")
end

-- ── fase 1: o esboço ────────────────────────────────────────────────────────

P.SISTEMA_ESBOCO = [[
Você é um projetista instrucional experiente, planejando a estrutura de uma
obra completa em português do Brasil.

Você NÃO está escrevendo o conteúdo agora — está decidindo a arquitetura: o que
entra, em que ordem e por quê. Cada peça do plano será escrita depois, por
extenso, por um autor que só vai enxergar o título e o foco que você der a ela.
Então o foco de cada peça precisa ser autossuficiente e inequívoco: dois
subcapítulos com foco vago viram dois textos redundantes.

Princípios:
- Ordem por DEPENDÊNCIA: nada aparece antes do que ele precisa.
- Granularidade uniforme: cada subcapítulo é um assunto que se ensina em
  1.000–1.500 palavras. Nem "a linguagem inteira", nem "o ponto e vírgula".
- Sem sobreposição: se dois subcapítulos ensinariam a mesma coisa, funda-os e
  use a vaga para algo que falta.
- Progressão real: os últimos capítulos são visivelmente mais difíceis que os
  primeiros.
]]

--- Fase 1: o plano da obra inteira. Uma chamada só — cabe, porque são títulos.
--- As `obs` são as observações gerais escritas no fim da entrevista. Elas
--- chegam aqui, e não só nos trechos, porque um esboço cego a elas planejaria
--- uma obra que cada trecho depois teria de contrariar sozinho — e "sem código"
--- não conserta um capítulo que só existe para mostrar código.
function P.esboco(assunto: string, tipo: string?, transcricao: string, n_unidades: number, n_sub: number, obs: string?): string
    local r = E.rotulo(tipo)
    local partes = {
        "Planeje " .. r.artigo .. " completo sobre:",
        "",
        assunto,
        "",
        "A entrevista de refinamento com quem pediu foi esta:",
        "",
        transcricao,
        "",
    }

    for _, linha in ipairs(observacoes({ titulo = "", resumo = "", publico = "", observacoes = obs })) do
        table.insert(partes, linha)
    end

    local resto = {
        "Divida a obra em EXATAMENTE " .. tostring(n_unidades) .. " " .. r.unidades,
        "e cada " .. r.unidade .. " em EXATAMENTE " .. tostring(n_sub) .. " " .. r.subunidades .. ".",
        "",
        "Devolva um objeto JSON com esta forma:",
        "",
        '  {',
        '    "titulo":  "título da obra",',
        '    "resumo":  "2 a 3 frases: o que a pessoa sabe fazer ao terminar",',
        '    "publico": "de quem é este material e o que ele já pressupõe",',
        '    "capitulos": [',
        '      {',
        '        "titulo": "título do ' .. r.unidade .. '",',
        '        "resumo": "1 a 2 frases sobre o papel dele na obra",',
        '        "subcapitulos": [',
        '          {',
        '            "titulo": "título do ' .. r.subunidade .. '",',
        -- Em UMA linha, e é de propósito: o exemplo anterior quebrava esta
        -- string em três linhas para caber na margem — e virava um JSON
        -- inválido, que os modelos mais fracos copiavam fielmente. O erro
        -- chegava na tela como "o modelo devolveu um JSON inválido"; o modelo
        -- só tinha imitado o molde que a gente mandou.
        '            "foco": "2 a 3 frases dizendo EXATAMENTE o que este texto deve ensinar, e o que ele NÃO deve cobrir por pertencer a outro ' .. r.subunidade .. '"',
        '          }',
        '        ]',
        '      }',
        '    ]',
        '  }',
        "",
        "Nada além do JSON. Sem conteúdo didático aqui — só a arquitetura.",
        "Cada valor de texto ocupa UMA linha: quebra de linha dentro de aspas",
        "não é JSON válido e derruba a geração inteira.",
    }
    for _, linha in ipairs(resto) do
        table.insert(partes, linha)
    end

    return table.concat(partes, "\n")
end

-- ── fase 1b: a auditoria do esboço ──────────────────────────────────────────
--
-- Uma chamada, entre o esboço e a revisão, e é a única correção que ataca a
-- repetição na RAIZ. As outras (o registro de conceitos, a abertura saindo mais
-- cedo) mitigam na produção — e a produção é paralela, logo parcialmente cega
-- por construção: quando o trecho 2.1 é escrito, o 1.5 ainda não existe. O
-- esboço é o único artefato pequeno o bastante para caber numa chamada e
-- grande o bastante para mostrar a obra inteira de uma vez.
--
-- O que ela procura foi medido numa obra real: num roadmap de 9 capítulos,
-- doze dos vinte trechos do capítulo "Fundamentos" eram trailers de capítulos
-- posteriores, e cerca de 25 dos 39 trechos dos dois primeiros capítulos
-- antecipavam os capítulos 3 a 9 — um deles com título idêntico ao de um
-- trecho do capítulo 7.

P.SISTEMA_AUDITORIA = [[
Você audita o PLANO de uma obra didática procurando um defeito específico e
caro: o mesmo assunto ensinado em dois lugares.

Ele nasce de um jeito previsível. Um capítulo de fundamentos com muitas vagas
para preencher acaba recebendo "Visão Geral de X", "Introdução a X" e "X:
Trade-offs" — quando X tem um capítulo próprio mais adiante. O leitor aprende
X três vezes, com exemplos diferentes, e quem pagou pagou três vezes.

QUEM É O DONO DE UM ASSUNTO. É onde ele é tratado a fundo — normalmente o
capítulo dedicado a ele —, e NÃO quem o menciona primeiro. Se o capítulo 7 é
"Unsafe Code" e o capítulo 1 traz "Safe vs Unsafe: Visão Geral", o dono é o 7:
quem cede é o 1. Inverter isso é o erro que estraga uma auditoria destas —
resultaria num capítulo dedicado proibido de ensinar o próprio tema.

O que NÃO é repetição, e você não deve tocar:
- usar um assunto já ensinado para ensinar outro (isso é progressão);
- voltar a um assunto em profundidade maior, quando o segundo lugar exige de
  fato mais do leitor;
- dois trechos do MESMO capítulo que se completam.
]]

--- Fase 1b: procura sobreposição no plano e devolve focos corrigidos.
---
--- Devolve só CORREÇÕES DE FOCO, nunca remoções: apagar um subcapítulo muda o
--- tamanho (e o preço) da obra, e essa é uma decisão de quem pediu — a tela de
--- revisão já tem o botão para isso. Quando o certo é apagar, o `motivo` diz.
function P.auditoria(tipo: string?, plano_texto: string): string
    local r = E.rotulo(tipo)
    return table.concat({
        "Este é o plano completo de " .. r.artigo .. ", com o foco de cada "
            .. r.subunidade .. ":",
        "",
        plano_texto,
        "",
        "Encontre os assuntos ensinados em mais de um lugar. Para cada um,",
        "escolha o DONO pela regra do sistema (onde o assunto é tratado a fundo,",
        "não quem o menciona primeiro) e reescreva o foco de CADA outro para que",
        "ele use o assunto assumindo-o conhecido, em vez de reensiná-lo.",
        "",
        "Devolva um array JSON, e nada além dele:",
        "",
        '  [',
        '    {',
        '      "cap": 1,',
        '      "sub": 9,',
        '      "assunto": "o assunto repetido, em 2 a 4 palavras",',
        '      "dono": "7.1",',
        '      "motivo": "uma frase: por que este é o repetidor e não o dono",',
        -- Uma linha, como no molde do esboço, e pela mesma razão: quebra de
        -- linha dentro de aspas não é JSON válido, e os modelos mais fracos
        -- copiam fielmente o molde que a gente mandou.
        '      "foco_novo": "o foco corrigido deste ' .. r.subunidade .. ', em 2 a 3 frases, dizendo o que ASSUMIR como já ensinado e o que ele deve fazer de fato"',
        '    }',
        '  ]',
        "",
        "`cap` e `sub` são os números do plano acima, e apontam para o REPETIDOR,",
        "nunca para o dono. Ordene do mais grave para o menos grave.",
        "Se não houver sobreposição nenhuma, devolva `[]` — é uma resposta boa,",
        "não uma falha.",
        "Cada valor de texto ocupa UMA linha.",
    }, "\n")
end

-- ── fase 2: o conteúdo ──────────────────────────────────────────────────────

P.SISTEMA_CONTEUDO = [[
Você é um autor técnico escrevendo UM trecho de uma obra maior, em português do
Brasil, em Markdown. Quem lê aprende SÓ pelo seu texto — não há aula, não há
professor, não há outro material. Se você não explicar, ninguém explica.

O QUE VOCÊ ESTÁ ESCREVENDO É O CONTEÚDO, NÃO O PLANO DELE.
Isto está proibido, e é o erro que arruína este tipo de material:
- listar tópicos que "serão abordados";
- escrever "veremos", "vamos estudar", "é importante entender";
- descrever um exemplo em vez de mostrá-lo;
- resumir um conceito em uma frase e seguir adiante.

Escreva como um bom livro técnico escreve:
- Comece pelo problema concreto que o assunto resolve, não pela definição.
- Explique o mecanismo de verdade — o que acontece por baixo, e por quê.
- CÓDIGO COMPLETO E EXECUTÁVEL, não fragmentos com "...". Mostre a saída real
  em um bloco à parte. Se o exemplo não roda como está, ele não serve.
- Mostre o erro que a pessoa VAI cometer, com a mensagem literal que a
  ferramenta emite, e conserte-o na frente dela.
- Compare com o que ela já conhece, quando isso encurtar o caminho.
- Termine com um exercício e a solução comentada.

Densidade: entre 1.000 e 1.600 palavras. Um texto de 300 palavras sobre este
assunto é uma falha, não uma economia.

Formato: comece direto no `## <título do trecho>`. Sem preâmbulo, sem
"neste capítulo", sem despedida, sem recapitulação do que veio antes.
]]

--- Fase 2: o texto de UM subcapítulo.
---
--- O contexto em volta (obra, capítulo, vizinhos) é o que impede 200 chamadas
--- independentes de virarem 200 textos que se repetem: cada autor sabe o que
--- já foi ensinado antes dele e o que vem depois, e pode assumir/deixar.
function P.secao(
    obra: Obra,
    capitulo: Capitulo,
    sub: Sub,
    ctx_vizinhos: Vizinhanca,
    ensinado: string?
): string
    local partes = {
        "Obra: **" .. obra.titulo .. "**",
        obra.resumo or "",
        "",
        "Público: " .. (obra.publico or "não especificado"),
        "",
        "Você está escrevendo o trecho **" .. sub.titulo .. "**,",
        "dentro do capítulo **" .. capitulo.titulo .. "** ("
            .. (capitulo.resumo or "") .. ").",
        "",
        "O que ESTE trecho deve ensinar:",
        sub.foco or sub.titulo,
        "",
    }

    if ctx_vizinhos.antes ~= "" then
        table.insert(partes, "Já foi ensinado antes deste trecho (ASSUMA como conhecido,")
        table.insert(partes, "não reintroduza, mas pode referenciar):")
        table.insert(partes, ctx_vizinhos.antes)
        table.insert(partes, "")
    end

    -- O registro do que a obra ensinou em OUTROS capítulos. O bloco acima
    -- ("já foi ensinado antes") cobre o capítulo atual com a síntese inteira
    -- de cada trecho; este cobre o resto da obra com uma linha por conceito.
    --
    -- Sem ele, um trecho do capítulo 7 recebia meia página sobre os 120
    -- trechos escritos antes dele, e reensinava `unsafe` do zero achando que
    -- estava apresentando o assunto. A instrução é explícita sobre a diferença
    -- entre USAR e REAPRESENTAR: proibir a menção produziria um texto que
    -- finge que o leitor nunca viu o conceito.
    if ensinado ~= nil and ensinado ~= "" then
        table.insert(partes, "JÁ DEFINIDO EM OUTRO CAPÍTULO DESTA OBRA. Trate como conhecido:")
        table.insert(partes, "use, aplique e cite (\"como visto em 1.9\") à vontade — mas NÃO")
        table.insert(partes, "defina de novo, NÃO explique o que é, e NÃO abra o trecho")
        table.insert(partes, "apresentando o assunto como se fosse novo:")
        table.insert(partes, ensinado)
        table.insert(partes, "")
    end

    if ctx_vizinhos.depois ~= "" then
        table.insert(partes, "Vem DEPOIS deste trecho (NÃO invada, no máximo cite de passagem):")
        table.insert(partes, ctx_vizinhos.depois)
        table.insert(partes, "")
    end

    for _, linha in ipairs(observacoes(obra)) do
        table.insert(partes, linha)
    end

    table.insert(partes, "Escreva agora o trecho completo, começando por:")
    table.insert(partes, "## " .. sub.titulo)
    table.insert(partes, "")
    table.insert(partes, "Depois do texto, feche a resposta com este bloco — fica FORA do")
    table.insert(partes, "trecho (não é para quem lê a obra, é só para o autor do PRÓXIMO")
    table.insert(partes, "trecho saber o que você já cobriu):")
    table.insert(partes, "")
    table.insert(partes, "<!--SINTESE-->")
    table.insert(partes, "- 3 a 6 marcadores curtos (até ~40 palavras cada): conceitos e")
    table.insert(partes, "  termos que você definiu, exemplos que usou, a conclusão a que")
    table.insert(partes, "  chegou. Nada de \"neste trecho vimos\" — vá direto ao que foi dito.")
    -- Esta linha custa quase nada e evita uma repetição cara: a lista de
    -- exercícios do capítulo (`P.exercicios`) recebe estas sínteses e é
    -- instruída a não repetir o que os trechos já propuseram. Sem ela, os dois
    -- lados escolhem o exercício mais óbvio do assunto — que é o mesmo.
    table.insert(partes, "- por último, uma linha começando por \"Exercício proposto:\"")
    table.insert(partes, "  com o enunciado do exercício que fecha este trecho, em uma frase.")
    table.insert(partes, "<!--/SINTESE-->")

    -- O segundo bloco, em forma de máquina. A síntese acima é para outro
    -- MODELO ler; esta lista é para o CÓDIGO indexar, e é o que alimenta o
    -- "já ensinado nesta obra" de todos os trechos seguintes. Por isso o
    -- formato rígido e a instrução de nomear o conceito como ele é conhecido:
    -- a comparação é textual, e "unsafe" e "o bloco unsafe do Rust" não se
    -- reconhecem como o mesmo assunto.
    table.insert(partes, "")
    table.insert(partes, "E feche com este outro bloco, separado do anterior — os conceitos")
    table.insert(partes, "que ESTE trecho DEFINIU (não os que ele apenas usou), separados por")
    table.insert(partes, "ponto e vírgula, cada um nomeado como o assunto é conhecido, sem")
    table.insert(partes, "artigo e sem frase (\"ponteiros brutos\", não \"o que são ponteiros")
    table.insert(partes, "brutos em Rust\"). De 2 a 6 termos, ou nenhum se o trecho só aplicou")
    table.insert(partes, "o que já estava definido:")
    table.insert(partes, "")
    table.insert(partes, "<!--CONCEITOS-->termo; outro termo; mais um<!--/CONCEITOS-->")

    return table.concat(partes, "\n")
end

--- A abertura de um capítulo: o texto que amarra os subcapítulos dele.
--- Curto de propósito — o conteúdo mora nos subcapítulos, não aqui.
---
--- `trechos` traz, por linha, o título de cada trecho do capítulo E o que ele
--- realmente ensinou (a síntese extraída dele — ver `O.extrair_sintese` — ou,
--- na falta dela, o foco planejado). É o que deixa a abertura amarrar o que
--- foi ESCRITO, não só o que foi planejado.
function P.abertura(obra: Obra, capitulo: Capitulo, trechos: string): string
    local partes = {
        "Obra: **" .. obra.titulo .. "** — " .. (obra.resumo or ""),
        "",
        "Escreva a ABERTURA do capítulo **" .. capitulo.titulo .. "**.",
        "Papel dele na obra: " .. (capitulo.resumo or ""),
        "",
        "Os trechos deste capítulo, na ordem, e o que cada um cobre:",
        trechos,
        "",
    }

    for _, linha in ipairs(observacoes(obra)) do
        table.insert(partes, linha)
    end

    local resto = {
        "Em 300 a 500 palavras: o problema que este capítulo resolve, por que ele",
        "vem nesta posição (o que o leitor precisava saber antes), e o fio que liga",
        "os trechos acima na ordem em que estão. Termine dizendo o que a pessoa",
        "saberá fazer ao final do capítulo.",
        "",
        "Comece direto no texto, sem título — o título já está no arquivo.",
        "NÃO resuma o conteúdo dos trechos; eles se explicam sozinhos.",
    }
    for _, linha in ipairs(resto) do
        table.insert(partes, linha)
    end

    return table.concat(partes, "\n")
end

-- ── fase 3: exercícios e prova (só em curso) ────────────────────────────────
--
-- Uma chamada por LOTE, e cada lote recebe um pedaço do material — os trechos
-- 1 a 10 de um capítulo, ou o primeiro quarto da obra. A divisão é o que
-- impede dois lotes simultâneos de escreverem o mesmo exercício: eles não
-- estão olhando para o mesmo texto. Ver `lib/avaliacao.luau`.
--
-- O que chega aqui como `cobertos` são as SÍNTESES dos trechos da faixa (o
-- bloco `<!--SINTESE-->` que cada autor devolve), não os focos planejados. É
-- a diferença entre cobrar o que foi escrito e cobrar o que era para ter sido.

P.SISTEMA_EXERCICIOS = [[
Você monta listas de exercícios para um curso técnico, em português do Brasil,
em Markdown. Quem resolve tem SÓ o texto do curso — não há aula, não há
monitor, não há gabarito além do seu. Um exercício que dependa de algo que o
material não ensinou é um exercício quebrado.

Cada exercício traz, nesta ordem:
1. o enunciado, com contexto CONCRETO — dados de entrada, código de partida,
   saída esperada. "Escreva um programa que faça X" solto não serve;
2. a dificuldade, entre parênteses: básico, intermediário ou desafio;
3. a solução comentada, com código COMPLETO e executável e a saída real, e
   explicando a decisão em cada ponto onde havia mais de um caminho.

Proibido, e é o que estraga uma lista destas:
- perguntar definição ("o que é X?") — isso é leitura, não exercício;
- exercício cuja solução é copiar um exemplo do texto trocando os nomes;
- "pesquise", "reflita", "discuta com um colega", "explore a documentação";
- enunciado ambíguo, que aceita duas respostas incompatíveis como corretas.

A lista progride: começa aplicando o que o texto fez e termina exigindo
combinar dois ou mais trechos.
]]

--- Um lote de exercícios: `n` exercícios sobre os trechos que `cobertos`
--- descreve.
---
--- `fora` são os títulos dos trechos do MESMO capítulo que pertencem a outros
--- lotes. Entram como fronteira explícita: as faixas já garantem que dois
--- lotes não vejam o mesmo material, e dizer isto ao modelo evita que ele
--- estique o assunto para um vizinho que outro lote vai cobrir.
function P.exercicios(
    obra: Obra,
    capitulo: Capitulo,
    cobertos: string,
    fora: string,
    n: number,
    ensinado: string?
): string
    local partes = {
        "Obra: **" .. obra.titulo .. "**",
        obra.resumo or "",
        "",
        "Público: " .. (obra.publico or "não especificado"),
        "",
        "Escreva EXATAMENTE " .. tostring(n) .. " exercícios sobre estes trechos do",
        "capítulo **" .. capitulo.titulo .. "**, e só sobre eles:",
        "",
        cobertos,
        "",
        "Cada linha acima traz o que aquele trecho ENSINOU de verdade, e a última",
        "delas diz o exercício com que o próprio trecho terminou. NÃO repita",
        "nenhum desses exercícios: os seus são a lista do capítulo, e valem por",
        "combinarem trechos que, no texto, foram ensinados separados.",
        "",
    }

    if fora ~= "" then
        table.insert(partes, "Estes outros trechos do capítulo NÃO são seus — outra lista os cobre.")
        table.insert(partes, "Não escreva exercício sobre eles:")
        table.insert(partes, fora)
        table.insert(partes, "")
    end

    -- A lista também herda o registro: sem ele, os exercícios de um capítulo
    -- que reensina um assunto cobram esse assunto como se fosse novo. Aqui a
    -- regra é o contrário da do trecho — combinar com o que já se sabe é
    -- exatamente o que um bom exercício de capítulo faz.
    if ensinado ~= nil and ensinado ~= "" then
        table.insert(partes, "O leitor JÁ SABE isto, ensinado em outros capítulos. Pode ser exigido")
        table.insert(partes, "sem reapresentação, e combinar com o assunto deste capítulo é o que")
        table.insert(partes, "faz um bom exercício aqui:")
        table.insert(partes, ensinado)
        table.insert(partes, "")
    end

    for _, linha in ipairs(observacoes(obra)) do
        table.insert(partes, linha)
    end

    local resto = {
        "Formato:",
        "",
        "## Exercícios — " .. capitulo.titulo,
        "",
        "### 1. <título curto do exercício>  (básico)",
        "<enunciado com contexto concreto>",
        "",
        "…e assim por todos os " .. tostring(n) .. ".",
        "",
        "Depois de TODOS os enunciados, uma linha com `---` e então:",
        "",
        "## Soluções comentadas",
        "",
        "### 1. <mesmo título>",
        "<a solução, com código completo e a saída real>",
        "",
        "As soluções ficam todas no fim, depois do `---`, para dar a quem lê a",
        "chance de tentar antes de ver. Comece direto no `## Exercícios` — sem",
        "preâmbulo e sem recapitular o capítulo.",
    }
    for _, linha in ipairs(resto) do
        table.insert(partes, linha)
    end

    return table.concat(partes, "\n")
end

P.SISTEMA_PROVA = [[
Você escreve a prova final de um curso técnico, em português do Brasil, em
Markdown. A prova mede se a pessoa consegue USAR o que o curso ensinou — não
se ela lembra das palavras que ele usou.

Misture os dois formatos, em proporção parecida:
- múltipla escolha com 4 alternativas, em que as ERRADAS são erros plausíveis,
  do tipo que alguém que estudou mal cometeria — nunca absurdos de descarte
  imediato, que transformam a questão num chute com três pistas;
- questão aberta de resposta curta: o que este código imprime, qual é o erro
  aqui, que estrutura resolve isto e por quê.

Cada questão declara entre parênteses o que cobra ("cap. 3 — tempo de vida").

O gabarito de cada questão diz por que a certa está certa E, nas de múltipla
escolha, por que cada errada está errada — nomeando o mal-entendido que leva
a ela. É a parte que ensina; um gabarito que só aponta a letra não serve.

Proibido: pegadinha de leitura do enunciado, questão que dependa de decorar um
número ou um nome de API, e questão respondível por qualquer pessoa da área
sem ter lido este curso.
]]

--- Uma parte da prova: `n` questões sobre a faixa de trechos que `cobertos`
--- descreve. Como as faixas são disjuntas, nenhuma parte precisa saber o que
--- as outras perguntaram — por isso não há um "não repita" aqui.
function P.prova(
    obra: Obra,
    cobertos: string,
    n: number,
    parte: number,
    total_partes: number
): string
    local partes = {
        "Obra: **" .. obra.titulo .. "**",
        obra.resumo or "",
        "",
        "Público: " .. (obra.publico or "não especificado"),
        "",
        "Esta é a **parte " .. tostring(parte) .. " de " .. tostring(total_partes)
            .. "** da prova final. Escreva EXATAMENTE",
        tostring(n) .. " questões, e só sobre o que estes trechos ensinaram:",
        "",
        cobertos,
        "",
        "As outras partes cobrem o resto do curso — não invada, e não escreva",
        "abertura nem encerramento da prova: você está escrevendo um pedaço dela.",
        "",
    }

    for _, linha in ipairs(observacoes(obra)) do
        table.insert(partes, linha)
    end

    local resto = {
        "Formato:",
        "",
        "## Prova final — parte " .. tostring(parte) .. " de " .. tostring(total_partes),
        "",
        "### 1. <a pergunta>  (cap. N — assunto)",
        "a) …  b) …  c) …  d) …",
        "",
        "…e assim por todas as " .. tostring(n) .. ".",
        "",
        "Depois de TODAS as questões, uma linha com `---` e então:",
        "",
        "## Gabarito — parte " .. tostring(parte),
        "",
        "### 1. <resposta>",
        "<por que ela está certa; nas de múltipla escolha, por que cada outra",
        "está errada>",
        "",
        "O gabarito fica todo no fim, depois do `---`, para a prova poder ser",
        "respondida antes de ele aparecer.",
    }
    for _, linha in ipairs(resto) do
        table.insert(partes, linha)
    end

    return table.concat(partes, "\n")
end

return P
