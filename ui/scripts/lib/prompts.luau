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
type Obra = { titulo: string, resumo: string, publico: string }
type Capitulo = { titulo: string, resumo: string }
type Sub = { titulo: string, foco: string }
type Vizinhanca = { antes: string, depois: string }

local P = {}

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
function P.esboco(assunto: string, tipo: string?, transcricao: string, n_unidades: number, n_sub: number): string
    local r = E.rotulo(tipo)
    return table.concat({
        "Planeje " .. r.artigo .. " completo sobre:",
        "",
        assunto,
        "",
        "A entrevista de refinamento com quem pediu foi esta:",
        "",
        transcricao,
        "",
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
        '            "foco":   "2 a 3 frases dizendo EXATAMENTE o que este texto',
        '                       deve ensinar, e o que ele NÃO deve cobrir por',
        '                       pertencer a outro ' .. r.subunidade .. '"',
        '          }',
        '        ]',
        '      }',
        '    ]',
        '  }',
        "",
        "Nada além do JSON. Sem conteúdo didático aqui — só a arquitetura.",
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
function P.secao(obra: Obra, capitulo: Capitulo, sub: Sub, ctx_vizinhos: Vizinhanca): string
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

    if ctx_vizinhos.depois ~= "" then
        table.insert(partes, "Vem DEPOIS deste trecho (NÃO invada, no máximo cite de passagem):")
        table.insert(partes, ctx_vizinhos.depois)
        table.insert(partes, "")
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
    table.insert(partes, "<!--/SINTESE-->")

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
    return table.concat({
        "Obra: **" .. obra.titulo .. "** — " .. (obra.resumo or ""),
        "",
        "Escreva a ABERTURA do capítulo **" .. capitulo.titulo .. "**.",
        "Papel dele na obra: " .. (capitulo.resumo or ""),
        "",
        "Os trechos deste capítulo, na ordem, e o que cada um cobre:",
        trechos,
        "",
        "Em 300 a 500 palavras: o problema que este capítulo resolve, por que ele",
        "vem nesta posição (o que o leitor precisava saber antes), e o fio que liga",
        "os trechos acima na ordem em que estão. Termine dizendo o que a pessoa",
        "saberá fazer ao final do capítulo.",
        "",
        "Comece direto no texto, sem título — o título já está no arquivo.",
        "NÃO resuma o conteúdo dos trechos; eles se explicam sozinhos.",
    }, "\n")
end

return P
