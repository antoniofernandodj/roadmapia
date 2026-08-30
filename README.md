# roadmapia

Gera **roadmaps**, **cursos** ou **guias** sobre qualquer assunto — mas não de um
prompt só: o app primeiro **entrevista você** sobre o tema, com perguntas que a
própria IA formula a partir do que você digitou, e então **escreve a obra
inteira**, um arquivo por trecho.

Interface em [glacier-ui](../glacier-ui) (XML declarativo + Luau), modelos via
[OpenRouter](https://openrouter.ai).

## O fluxo

```
  inicio ──"Refinar"──▶ perguntas ──"Generate"──▶ producao
     │                      │  ▲                      │
  assunto +            uma pergunta            esboço (1 chamada)
  roadmap/curso/guia   por vez, com                   ↓
                       opções da IA +          200+ trechos escritos
                       texto livre             em paralelo, 1 arquivo
                            └─"+ aprofundar"─┘  cada
```

1. **`inicio`** — um campo para o assunto e três checkboxes (roadmap / curso /
   guia). O botão principal **não submete**: ele leva o assunto à IA e volta com
   um questionário sob medida.
2. **`perguntas`** — uma pergunta por vez. Cada uma traz opções sugeridas pela IA
   (chips clicáveis, **seleção múltipla**) **e** um campo de texto livre — os dois
   convivem: dá para marcar duas opções e completar por escrito.
3. **`producao`** — o "Generate" planeja a obra (10 capítulos × 20 trechos), e a
   produção escreve cada trecho numa chamada própria, seis em paralelo, gravando
   um arquivo por trecho conforme ficam prontos.

## Por que duas fases

Uma chamada ao modelo tem teto de saída de alguns milhares de tokens. Nesse
espaço **só cabe um índice** — foi o que a primeira versão deste app produzia:
uma grade de estudos de 700 palavras, sem uma linha de código dentro.

A separação resolve isso:

| | chamadas | o que sai |
|---|---|---|
| **fase 1** — esboço | 1 | títulos e o *foco* de cada trecho: a arquitetura |
| **fase 2** — conteúdo | 1 **por trecho** | o texto, com o teto de saída inteiro dedicado a um assunto pequeno |

Um trecho medido: **2.465 palavras e 27 blocos de código** — 3,5× o curso
inteiro da versão anterior. Com 10 × 20, a obra passa de 400 mil palavras.

O que impede 200 chamadas independentes de virarem 200 textos repetidos é a
**vizinhança**: cada trecho recebe no prompt o que já foi ensinado antes dele
(para assumir, não reintroduzir) e o que vem depois (para não invadir).

## O custo, e por que ele aparece antes

Material desse tamanho custa dinheiro de verdade: medido em Sonnet 4.5, deu
**US$ 0,084 por trecho — cerca de US$ 17 pela obra completa**. Por isso
"Produzir" não larga as 200 chamadas de cara:

1. escreve **um trecho de amostra** e mede o custo real dele;
2. mostra um diálogo com o preço extrapolado, o modelo e **o caminho do arquivo
   de amostra**, para você ler antes de autorizar;
3. só então libera o pool.

Durante a produção o gasto acumulado aparece na tela (número real, vindo do
`usage.cost` que o OpenRouter devolve), e dá para parar a qualquer momento — o
que já foi escrito fica em disco. Modelos mais baratos (Haiku, Gemini Flash)
cortam isso em ~10×; o seletor está em "ajustes", na tela inicial.

## Rodar

```bash
cargo run
```

Cole a chave em "ajustes", na tela inicial — ela fica gravada no arquivo de
configuração e o app abre com ela nas próximas vezes. Para uma sessão avulsa,
sem escrever nada em disco:

```bash
export OPENROUTER_API_KEY=sk-or-v1-...
```

## Configuração

Um `.ini`, procurado nesta ordem — o primeiro que **existir** vence:

| | Caminho | Para quê |
|---|---|---|
| 1 | `$ROADMAPIA_CONFIG` | apontar para outro arquivo, ex.: testar uma segunda chave |
| 2 | `./roadmapia.ini` | ao lado de onde o app rodou; é o de dev |
| 3 | `~/.config/roadmapia/config.ini` | o normal (respeita `$XDG_CONFIG_HOME`) |

```ini
[openrouter]
api_key = sk-or-v1-...
modelo  = anthropic/claude-sonnet-4.5
```

**O arquivo vence `OPENROUTER_API_KEY`.** Escrever uma chave em disco é um ato
deliberado; um `export` esquecido numa sessão antiga não deve sequestrá-la sem
dizer nada. A tela inicial mostra, embaixo do campo, de onde veio a que está
valendo — e digitar ali grava no arquivo, que passa a valer.

O arquivo nasce `0600` (só o dono lê) e é editável à mão: gravar pela tela troca
**a linha** daquela chave e deixa comentários, ordem e seções desconhecidas
intactos. Nada é apagado por um campo vazio — para tirar uma chave, apague a
linha.

Quem já usava a versão anterior não perde nada: a chave que estava no `storage`
do componente é lida uma última vez e migrada para o `.ini` no primeiro clique.

## A obra em disco

```
saidas/<tipo>-<assunto>/
├── README.md                   capa + sumário com links (reescrito a cada trecho)
├── 01-<capitulo>/
│   ├── README.md               abertura do capítulo + índice
│   ├── 01-<trecho>.md
│   └── …
└── …
```

Os arquivos aparecem conforme ficam prontos, então dá para começar a ler antes
do fim. Se algo falhar, "Refazer falhas" devolve só o que falhou à fila —
inclusive o que ficou preso se o app foi fechado no meio.

## Log

Toda operação vai para `saidas/roadmapia.log`, em append — sobrevive a fechar o
app no meio de uma produção:

```
16:02:37  INFO  producao   produzir: pedido pelo usuário; pendentes=231
16:02:41  INFO  producao   amostra: começando por saidas/curso-x/01-intro/01-a.md
16:03:02  INFO  worker     chamada saidas/curso-x/01-intro/01-a.md ok=true custo=0.08430 palavras~2465
16:03:02  AVISO worker     rate limit em …/02-b.md; devolvendo à fila e esperando 4000ms
16:03:15  ERRO  worker     GRAVAÇÃO FALHOU em …/03-c.md: Permission denied
```

Cada chamada à API sai com custo e resultado, cada gravação em disco é
distinguível de uma falha de rede, e cada worker anuncia quando entra e sai.
É o que responde "onde parou?" sem adivinhação.

## Verificar

```bash
cargo run -- --check    # tudo: templates, .gss, layout, suítes Luau, ações, log

# integração: o pool de workers no motor de verdade (abre uma janela, ~15s)
POOL_UI=tests/pool POOL_OUT=/tmp/pool.txt cargo run --example pool_concorrente
cat /tmp/pool.txt   # espera: feitos=6 … sobrou=0
```

Um comando só, sem dependências externas. `--check` registra as três telas num
motor descartável (sem abrir janela), renderiza cada uma, roda as **suítes Luau**
(`tests/luau/`, 62 casos) e então **executa as ações**: marca e desmarca opções,
escreve no campo livre, navega, provoca um erro, lê um plano semeado, refaz
falhas. Sai com o número de falhas.

As suítes Luau rodam **dentro do interpretador do motor**, não num `lua` do
sistema. Isso importa por três motivos: exercitam o `json` e o `require` de
verdade; permitem que as bibliotecas testadas usem anotação de tipo Luau (que
não é Lua 5.4 válido e quebraria um runner externo); e dispensam ter um `lua`
instalado.

`tests/luau/fila.luau` é o teste que mais importa: seis workers puxando da mesma
fila, e um trecho pego duas vezes custa uma chamada paga a mais (× 200). Ele
simula esse entrelaçamento e cobra a invariante forte — **cada tarefa sai da fila
exatamente uma vez**. `tests/luau/openrouter_casos.luau` cobre o recorte de JSON
e a contabilidade de custo, com `fetch` enlatado.

## Estrutura

| Arquivo | Papel |
|---|---|
| `src/main.rs` | casca fina: registra as telas, carrega o `.gss`, liga a config ao contexto, e o `--check`. |
| `src/config.rs` | o `.ini`: onde procurar, ler, e gravar uma chave sem estragar o resto. |
| `ui/inicio.gv` · `scripts/inicio.luau` | assunto, tipo, credenciais; a ação `refinar`. |
| `ui/perguntas.gv` · `scripts/perguntas.luau` | a entrevista; `alternar`, `aprofundar` e `gerar` (fase 1). |
| `ui/revisao.gv` · `scripts/revisao.luau` | o esboço da IA antes de custar: editar, apagar, reordenar. |
| `ui/producao.gv` · `scripts/producao.luau` | o pool de workers (fase 2), avanço, custo, refazer falhas. |
| `ui/scripts/lib/openrouter.luau` | cliente da API, recorte de JSON, custo por chamada. |
| `ui/scripts/lib/entrevista.luau` | perguntas/respostas e sua projeção para a tela. |
| `ui/scripts/lib/obra.luau` | o plano multi-arquivo: fila, estados, caminhos, índices. |
| `ui/scripts/lib/prompts.luau` | os prompts das três fases. |
| `glacier.d.luau` | tipos das globais do motor, para o editor não pintar tudo de vermelho. |
| `tests/luau/` | as suítes, rodadas pelo `--check` no interpretador do motor. |

Tudo em `ui/` é **hot-reload**: com o app aberto, editar um prompt, um estilo ou
um passo do fluxo tem efeito na hora. Só `src/main.rs` exige recompilar.

## Três bugs que valem a história

**`hidden="{chave}"` não ligava — corrigido em `glacier-ui`.** O motor convertia
`hidden`/`disabled` para `bool` no *parse*, comparando a string crua: `"{parado}"`
nunca é `"true"`, então o binding ficava congelado em `false`. O sintoma era um
spinner girando para sempre e o botão "próxima" ativo na última pergunta. A
correção segue o padrão que o próprio parser já usava para atributos numéricos
(`NumAttr`): guardar a string e resolvê-la na avaliação (`BoolAttr`). Também foi
adicionado `append_file` à camada Luau, irmão de `write_file`, sem o qual um log
confiável não é possível.

**O custo sumia nos erros pós-faturamento.** Em `M.chat`, os caminhos de erro
que acontecem DEPOIS de um HTTP 200 — resposta vazia, sem escolhas, e sobretudo
o corte por `finish_reason == "length"` — devolviam só `(false, mensagem)`. O
terceiro retorno virava `nil` e o custo daquela chamada sumia da conta. O corte
por tokens é o pior caso possível: uma geração faturada no TETO, a mais cara que
existe, repetida `TENTATIVAS` vezes por trecho, reportando US$ 0 — subestimando
justamente a estimativa que autoriza uma produção de dezenas de dólares. Achado
pelo type checker (`Function only returns 2 values, but 3 are required`).

**Gravar o plano não acendia a tela.** `gerar` escrevia um plano de 231 trechos e
navegava para `producao` — que, tendo rodado o `init` no arranque com o contexto
vazio, dizia "Nada planejado ainda", sem botão para produzir. Era exatamente o
"gerou a pasta mas não gerou os arquivos". A correção não foi lembrar de chamar
a projeção: foi **amarrá-la a `O.gravar_plano`**, para que esquecer deixe de ser
possível.

## Detalhes que valem saber

- **Nada de async no `init`.** `GlacierUI::install_component` guarda só
  `ctx.streams` do `init` — `after()` e `fetch()` chamados ali são descartados
  **em silêncio**. Todo o async do app parte de uma ação (um clique), nunca do
  `init`. `examples/pool_concorrente.rs` existe por causa disso.
- **O paralelismo é real e vem do motor.** `fetch` suspende a corrotina da ação
  e o glacier guarda cada corrotina suspensa por id, então N workers têm N
  requisições em voo. Provado em `examples/pool_concorrente` — as tarefas
  terminam fora de ordem, que é a assinatura de concorrência de verdade.
- **Sem corrida, com uma regra.** Lua roda numa thread só e uma corrotina só
  cede a vez num `fetch`; então basta **nunca suspender entre ler e reescrever o
  plano**. É a invariante que `ui/scripts/lib/obra.luau` mantém.
- **`init` roda uma vez.** O `init` de um componente acontece no *registro*, não
  a cada navegação — por isso quem muda o estado é que chama a projeção. Esta é
  a armadilha número um deste motor: já mordeu duas vezes neste app.
- **O material é só texto.** O prompt da entrevista proíbe explicitamente
  perguntar sobre formato ou mídia — sem isso o modelo pergunta sobre videoaulas
  e cria uma expectativa que a obra em Markdown não pode cumprir.
- **Ações parametrizadas.** Um chip de opção despacha `alternar:<n>`; o motor
  fatia no `:` e chama `alternar(n)`. É o que deixa um `for-each` gerar N botões
  distintos sem N funções.
- **`align` é aceito e ignorado.** No parser do glacier os aliases de `alignX`
  são só `alignX`/`align_x`/`align-x`/`alinhamento_x` — `align` não casa nada
  (embora o README da lib o documente como alias). E o eixo cruzado de uma
  `Row` é o `alignY`, não o `alignX`. Resultado: `<Row align="Center">` parece
  centrado no código e encosta no topo na tela. O `--check` reprova qualquer
  `Row` com botões que não declare `alignY`.
- **Botões de uma fila têm altura fixa igual.** Alturas diferentes lado a lado
  saltam aos olhos; as classes de ação são todas 44px e o `--check` percorre as
  três telas reprovando qualquer `Row` que misture alturas.
- **`if` testa verdade, não "não vazio".** `if="{erro}"` com uma mensagem
  qualquer é *falso* — daí o par `erro` (texto) + `tem_erro` (interruptor). O
  `--check` tem uma asserção para isso.
- **Acento vira hífen se você deixar.** `[^%w]` não casa UTF-8 multibyte, então
  "Introdução à Concorrência" viraria `introdu-o-concorr-ncia`. `O.slug`
  translitera antes.
- **Modelos cercam o JSON mesmo proibidos.** `tests/resposta_openrouter.txt` é
  uma resposta real que veio em ```json apesar da instrução contrária.
- **Resposta cortada.** `finish_reason == "length"` vira mensagem própria —
  senão o sintoma apareceria como "JSON inválido", apontando para o lugar errado.
