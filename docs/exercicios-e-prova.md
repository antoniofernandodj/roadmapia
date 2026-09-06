# Exercícios e prova para o tipo "curso"

**Estado:** **implementado** na branch `claude/course-exercises-tests-impl-153ncq`.
Este documento continua sendo o plano — a §12 no fim registra onde a
implementação se afastou dele, e por quê.

Um curso sem exercício e sem avaliação é um livro com capa de curso. Hoje o app
produz os dois primeiros terços do que a própria tela inicial promete —
*"Curso — módulos, aulas, exercícios e avaliação"* — e para no texto. Este
documento planeja o terço que falta: **listas de exercícios por capítulo** e uma
**prova final**, ambas com o tamanho configurável por quem pede.

O que muda em uma frase: a fila de produção ganha **dois tipos novos de tarefa**
(`exercicios` e `prova`), materializados no plano no mesmo momento em que os
trechos são, com dependências que garantem que eles só sejam escritos **depois**
do conteúdo que cobram.

---

## 1. O que a pessoa vê

### 1.1 Tela `inicio` — a configuração

Um painel novo, visível **só quando "Curso" está marcado** (`if="{tipo_curso}"`),
entre o painel do tipo e o do modelo:

```
┌─ 3 · EXERCÍCIOS E PROVA ────────────────────────────────┐
│  ☑ Lista de exercícios ao fim de cada capítulo          │
│     [ 10 ]  exercícios por capítulo                     │
│                                                          │
│  ☑ Prova final da obra                                   │
│     [ 40 ]  questões na prova                            │
│                                                          │
│  + 24 chamadas (20 lotes de exercícios, 4 partes de      │
│    prova) — cerca de +11% no custo da obra.              │
└──────────────────────────────────────────────────────────┘
```

Detalhes que importam:

- **O painel só existe para curso.** Roadmap e guia não o veem, e trocar o tipo
  depois de configurar não deixa uma prova órfã num guia — ver §4.3.
- **Checkbox + número, não só número.** Zero também desliga, mas desmarcar tem
  de preservar o número digitado: quem desliga para ver o custo e religa não
  deve perder o que escreveu.
- **A última linha é a conta.** Este app mostra o preço antes de cobrar (é a
  razão de existir da amostra em `producao.luau`); um campo que multiplica
  chamadas sem dizer isso na cara seria uma regressão dessa cultura.
- **Os painéis renumeram:** "3 · MODELO E CHAVE" passa a ser "4 · MODELO E
  CHAVE".

### 1.2 Tela `revisao` — o que vai ser produzido

A revisão continua editando **o esboço** (capítulos e subcapítulos). Exercícios e
prova **não entram como itens editáveis** — eles não têm título nem foco a
corrigir, são derivados dos trechos. O que a tela ganha é uma linha de resumo
no painel "A OBRA":

```
10 capítulos · 200 trechos · 20 lotes de exercícios · 4 partes de prova
```

E — isto sim é edição útil — **os dois números podem ser corrigidos aqui**, com
os mesmos campos da tela inicial. É o último ponto antes de pagar, e é onde a
pessoa já está olhando para o tamanho real da obra (o esboço pode ter voltado
com 8 capítulos em vez de 10, o que muda a conta).

### 1.3 Tela `producao` — o avanço

- `obra_subtitulo` passa a somar as tarefas novas:
  `"Curso · 10 capítulos · 234 tarefas"`.
- Cada linha de capítulo em `capitulos_ui` ganha o estado dos lotes de
  exercícios no `detalhe`: `"20/20 trechos · exercícios 1/2"`.
- A prova **não cabe na lista de capítulos** (não pertence a nenhum). Ganha um
  bloco próprio abaixo da lista, visível só quando existe:
  `"Prova final — 2 de 4 partes  ·  40 questões"`.
- O diálogo de confirmação de custo passa a dizer a composição:

  > Os 233 restantes (200 trechos, 10 aberturas, 20 lotes de exercícios,
  > 4 partes de prova) devem custar cerca de US$ 19,60…

---

## 2. O modelo: exercícios e prova são **faixas de trechos**

Esta é a ideia central, e é dela que sai a simplicidade do resto.

Um lote de exercícios não é "os exercícios do capítulo 3" — é **"os exercícios
dos trechos 1 a 10 do capítulo 3"**. Uma parte da prova não é "a parte 2" — é
**"as questões sobre os trechos 51 a 100 da obra"**.

Três problemas somem de uma vez:

| Problema | Como a faixa resolve |
|---|---|
| Dois lotes do mesmo capítulo escreverem o mesmo exercício | Cobrem trechos disjuntos — não têm como |
| O modelo inventar exercício sobre o que o texto não ensinou | O prompt recebe a **síntese** de cada trecho da faixa (o `<!--SINTESE-->` que já existe) |
| Precisar ordenar os lotes entre si (como `O.tomar_tarefa` faz com os trechos) | Não precisa: lotes são independentes, correm em paralelo |

### 2.1 Como as faixas são calculadas

```
Exercícios de um capítulo com T trechos e N exercícios pedidos:
    B = clamp(ceil(N / LOTE_EXERCICIOS), 1, T)      LOTE_EXERCICIOS = 5
    os T trechos são divididos em B faixas contíguas, o mais parelhas possível
    os N exercícios são distribuídos nas B faixas (resto para as primeiras)

Prova, com T_obra trechos no total e Q questões pedidas:
    B = clamp(ceil(Q / QUESTOES_POR_PARTE), 1, T_obra)   QUESTOES_POR_PARTE = 10
    mesma divisão em faixas contíguas, agora sobre a obra inteira
```

`clamp(..., 1, T)` é o que impede o caso degenerado: um capítulo de 3 trechos
com 40 exercícios pedidos vira 3 lotes de ~13, não 8 lotes brigando por 3
trechos. Quando um lote passa de `MAX_POR_CHAMADA = 8` exercícios (ou 15
questões), a tela avisa — não bloqueia:

> Com 3 trechos por capítulo, 40 exercícios saem em lotes de 13. Uma chamada
> só rende ~8 exercícios com solução comentada; considere 24.

### 2.2 O tipo `Tarefa`

```luau
export type Tarefa = {
    tipo: string,   -- "trecho" | "abertura" | "exercicios" | "prova"
    cap: number?,   -- nil numa parte de prova (ela atravessa capítulos)
    sub: number?,   -- só em "trecho"
    idx: number?,   -- o índice do lote/parte, em "exercicios" e "prova"
}
```

`cap` passa a ser opcional, e é aqui que mora **o refactor que este trabalho
exige antes de qualquer coisa**: `O.concluir`, `O.falhar` e `O.reenfileirar`
hoje repetem, cada uma, o mesmo bloco de resolução do alvo:

```luau
local alvo: any = nil
if tarefa.tipo == "abertura" then alvo = cap
elseif tarefa.sub ~= nil then alvo = cap.subs[tarefa.sub] end
```

Três cópias viram quatro tipos cada uma = doze caminhos, e a chance de acertar
onze é alta demais. **Extrair `O.alvo_de(plano, tarefa): any?` primeiro**, e só
depois acrescentar os tipos novos. É um commit sozinho, sem mudança de
comportamento, com as suítes atuais passando iguais.

### 2.3 As dependências na fila

`O.tomar_tarefa` ganha dois laços, nesta ordem (depois dos trechos, depois das
aberturas):

| Tarefa | Liberada quando |
|---|---|
| `trecho` | é o primeiro não resolvido do capítulo (regra atual) |
| `abertura` | todos os trechos do capítulo estão prontos ou com erro (regra atual) |
| `exercicios` (lote *k* do cap. *c*) | todos os trechos **da faixa do lote** estão resolvidos |
| `prova` (parte *k*) | todos os trechos **da obra** estão resolvidos |

A regra do lote é por **faixa**, não por capítulo inteiro, de propósito: com 20
trechos e 2 lotes, o primeiro lote pode começar na metade do capítulo em vez de
esperar o fim — mais paralelismo, mesma qualidade de contexto.

A prova depende da obra inteira porque uma prova que ignora metade do material
não é uma prova. Isso a coloca naturalmente no fim da fila, o que é bom: são as
últimas 4 chamadas, e se a produção for interrompida antes delas, "Refazer
falhas" as retoma sem refazer nada de texto.

> **Invariante que a suíte tem de cobrar:** cada tarefa sai da fila **exatamente
> uma vez**, incluindo as novas. É o teste que mais importa em
> `tests/luau/fila.luau` e o motivo de ele existir — um lote pego duas vezes é
> uma chamada paga a mais, igual a um trecho.

---

## 3. Onde a configuração mora

**No plano (`obra_json`), não no contexto** — pela mesma razão que
`plano.observacoes`, e o comentário lá em `obra.luau` já explica: retomar uma
produção interrompida dias depois tem de usar os mesmos números da primeira
metade, e o contexto se perde ao fechar o app.

```luau
export type Avaliacao = {
    exercicios_por_capitulo: number,   -- 0 = desligado
    questoes_prova: number,            -- 0 = desligado
}

export type Plano = {
    -- … campos atuais …
    avaliacao: Avaliacao?,             -- nil em planos antigos: ver §7
    prova: { ParteProva }?,            -- as partes já materializadas
}

export type Capitulo = {
    -- … campos atuais …
    exercicios: { LoteExercicios }?,
}

export type LoteExercicios = {
    arquivo: string,
    status: string,       -- os mesmos O.PENDENTE/FAZENDO/PRONTO/ERRO
    erro: string,
    de: number, ate: number,   -- a faixa, em índices de sub DENTRO do capítulo
    n: number,                 -- quantos exercícios este lote escreve
}

export type ParteProva = {
    arquivo: string,
    status: string,
    erro: string,
    de: number, ate: number,   -- a faixa, em índices GLOBAIS de trecho
    n: number,                 -- quantas questões esta parte escreve
}
```

As faixas são **materializadas em `O.montar`**, não calculadas a cada
`tomar_tarefa`. Duas razões:

1. `O.contar` fica honesto desde o primeiro clique — a barra de avanço e a
   extrapolação de custo já sabem o total real;
2. editar o esboço na revisão recalcula tudo do zero, que é exatamente o que
   `O.montar` já promete ("reordenar, renomear, apagar e inserir aqui é sempre
   seguro").

O caminho da configuração até lá: `inicio`/`revisao` escrevem em
`ctx.n_exercicios` / `ctx.n_questoes` (texto cru), e `revisao.luau:confirmar()`
os saneia e passa para `O.montar` — no mesmo lugar onde `ctx.observacoes` já
entra hoje.

---

## 4. Mudanças arquivo a arquivo

### 4.1 `ui/scripts/lib/obra.luau` — o grosso

| O quê | Detalhe |
|---|---|
| `O.alvo_de(plano, tarefa)` | o refactor do §2.2, **primeiro commit** |
| Tipos `Avaliacao`, `LoteExercicios`, `ParteProva` | §3 |
| `O.faixas(total, n_faixas)` | divide 1..total em faixas contíguas parelhas — pura, testável sozinha |
| `O.distribuir(n, faixas)` | reparte N itens entre as faixas, resto para as primeiras — pura |
| `O.montar(...)` | ganha o parâmetro `avaliacao`; materializa lotes e partes |
| `O.tomar_tarefa` | os dois laços novos do §2.3 |
| `O.concluir` / `O.falhar` / `O.reenfileirar` / `O.reenfileirar_falhas` | passam pelo `alvo_de`; `reenfileirar_falhas` varre também lotes e partes |
| `O.contar` | soma lotes e partes ao total |
| `O.projetar` | `detalhe` do capítulo com o estado dos lotes; chaves novas `tem_prova`, `prova_detalhe` |
| `O.cabecalho_capitulo` | lista os arquivos de exercício no índice do capítulo |
| `O.gravar_sumario` | seção "Exercícios" por capítulo e seção "Prova final" na raiz |
| `O.gravar_indice_prova` | **novo, sem chamada à API**: o `prova/README.md` que liga as partes |

### 4.2 `ui/scripts/lib/prompts.luau` — os prompts novos

Quatro adições: `P.SISTEMA_EXERCICIOS`, `P.exercicios(...)`,
`P.SISTEMA_PROVA`, `P.prova(...)`. Rascunho em §5.

O bloco `observacoes(obra)` entra nos dois, pelo mesmo motivo de sempre: uma
observação sobre a obra inteira que não valesse nos exercícios produziria um
material que muda de regra no fim.

### 4.3 `ui/scripts/inicio.luau` + `ui/inicio.gv`

- Painel novo (§1.1) sob `if="{tipo_curso}" equals="true"`.
- `ctx.quer_exercicios`, `ctx.n_exercicios`, `ctx.quer_prova`, `ctx.n_questoes`,
  com padrões `"true" / "10" / "true" / "40"` no `init`.
- `alternar_exercicios()`, `alternar_prova()`, `n_exercicios_mudou(texto)`,
  `n_questoes_mudou(texto)`.
- `aplicar_tipo(tipo)` **não zera** os números ao sair de "curso" — só o painel
  some. Quem zera é `confirmar()`, que ignora a avaliação quando
  `ctx.tipo ~= "curso"`. Assim marcar guia por engano e voltar para curso não
  perde a configuração, e um guia nunca sai com prova.
- `refinar()` limpa a avaliação do plano anterior junto com `obra_json` /
  `esboco_json`? **Não** — os números são preferência da pessoa, não do assunto.
  Ficam.

> **A armadilha do cursor.** `n_exercicios_mudou` **não** pode reescrever
> `ctx.n_exercicios` com o valor saneado a cada tecla: recriaria o `Content` do
> editor e o cursor pularia para o fim — é o mesmo bug que o comentário de
> `livre_mudou` em `perguntas.luau` documenta. Guarde o texto cru; saneie só na
> leitura (`confirmar`) e para calcular o aviso de custo.

### 4.4 `ui/scripts/revisao.luau` + `ui/revisao.gv`

- Os mesmos dois campos, no painel "A OBRA" (§1.2).
- `confirmar()` saneia e monta a `Avaliacao`, passando-a a `O.montar` ao lado de
  `ctx.observacoes`.
- `gerar_de_novo()` não mexe nisso (a configuração não vem do modelo).

Nota de bug latente encontrada de passagem: `gerar_de_novo()` chama `P.esboco`
**sem `ctx.observacoes`**, enquanto `perguntas.luau:gerar()` passa. Gerar de
novo produz hoje um esboço cego às observações gerais. Não é escopo deste
trabalho, mas é uma linha e vale corrigir junto.

### 4.5 `ui/scripts/producao.luau` + `ui/producao.gv`

- `executar(tarefa)` ganha os dois ramos novos (montar o prompt a partir da
  faixa e das sínteses).
- O bloco da prova na tela (§1.3).
- O texto do `confirm()` com a composição das tarefas.
- **Nada muda na amostra.** Ela pega a primeira tarefa pendente, que pelas
  dependências do §2.3 é sempre um trecho — a medição continua sendo a de um
  trecho, que é o caso caro e majoritário.

### 4.6 `ui/scripts/lib/entrevista.luau`

Nada estrutural. Uma linha opcional: quando os exercícios estão ligados,
`P.entrevista` pode acrescentar *"pergunte também que tipo de exercício serve
para este assunto (implementar, depurar, ler código, projetar)"* — a resposta
melhora os dois prompts novos de graça. A restrição de mídia
(`P.SISTEMA_ENTREVISTA`) continua valendo: nada de "quiz interativo", o material
é texto.

---

## 5. Os prompts (rascunho para ajustar)

### 5.1 Sistema — exercícios

```
Você monta listas de exercícios para um curso técnico em português do Brasil,
em Markdown. Quem resolve tem SÓ o texto do curso — não há aula, não há
monitor. Um exercício que precise de algo que o material não ensinou é um
exercício quebrado.

Cada exercício tem, nesta ordem:
1. o enunciado, com o contexto concreto (dados de entrada, código de partida,
   saída esperada) — nada de "escreva um programa que faça X" solto;
2. a dificuldade: básico / intermediário / desafio;
3. a solução COMENTADA, com código completo e executável e a saída real,
   explicando a DECISÃO em cada ponto onde havia mais de um caminho.

Proibido:
- perguntar definição ("o que é X?") — isso é leitura, não exercício;
- exercício cuja solução é copiar um exemplo do texto com outro nome;
- "pesquise", "reflita", "discuta com um colega".

A lista progride: começa reproduzindo o que o texto fez e termina exigindo
combinar dois ou mais trechos.
```

### 5.2 Usuário — `P.exercicios(obra, capitulo, faixa, n, ja_pedidos)`

Recebe:

- o título e o resumo da obra e do capítulo;
- **a síntese de cada trecho da faixa** (o `<!--SINTESE-->` que o autor já
  devolve, ou o `foco` planejado se o trecho falhou) — é o que ancora o
  exercício no que foi escrito, não no que foi planejado;
- **os enunciados dos outros lotes do mesmo capítulo já prontos**, sob a
  instrução "não repita" — barato e é o que impede sobreposição residual;
- o número exato de exercícios a escrever;
- as observações gerais.

E fecha pedindo o formato: `## Exercícios — <capítulo>`, cada exercício em
`### N. <título curto>`, e as soluções depois de um `---` sob
`## Soluções comentadas`, para quem quiser tentar antes de ler.

### 5.3 Sistema — prova

```
Você escreve a prova final de um curso técnico em português do Brasil, em
Markdown. A prova mede se a pessoa consegue USAR o que o curso ensinou — não
se ela lembra das palavras que ele usou.

Formato de cada questão:
- múltipla escolha com 4 alternativas OU questão aberta com resposta curta
  (código, saída de um programa, um diagnóstico) — misture os dois;
- nas de múltipla escolha, as alternativas erradas são erros PLAUSÍVEIS que
  alguém que estudou mal cometeria, nunca absurdos de descarte imediato;
- o gabarito diz por que a certa está certa E por que cada errada está errada,
  citando o ponto do curso que a pessoa não absorveu.

Cada questão declara o que cobra ("cap. 3 — gerenciamento de memória").
Proibido: pegadinha de leitura, questão que depende de decorar um número,
questão respondível sem ter lido o curso.
```

### 5.4 Usuário — `P.prova(obra, faixa, n, parte_k, total_partes)`

Recebe as sínteses dos trechos da faixa, o número de questões desta parte, e
qual parte de quantas ela é (para o cabeçalho ficar coerente). Como as faixas
são disjuntas, nenhuma parte precisa saber o que as outras perguntaram.

### 5.5 Refinamento opcional: a síntese diz qual exercício já foi usado

`P.SISTEMA_CONTEUDO` manda cada trecho terminar com "um exercício e a solução
comentada". Então o lote de exercícios do capítulo corre risco de repetir o que
o trecho já propôs. Solução de uma linha: acrescentar ao bloco
`<!--SINTESE-->` um marcador *"o exercício que você propôs, em uma linha"*, e
passá-lo adiante no prompt do lote sob "não repita estes".

Custa quase nada e é opcional — o caminho de fallback já existe (`O.extrair_
sintese` devolve síntese vazia quando o modelo não segue o formato).

---

## 6. Layout em disco

```
saidas/curso-<assunto>/
├── README.md                      capa + sumário (ganha as duas seções novas)
├── 01-<capitulo>/
│   ├── README.md                  abertura + índice (lista os exercícios)
│   ├── 01-<trecho>.md
│   ├── …
│   ├── exercicios-01.md           trechos 1–10 · 5 exercícios
│   └── exercicios-02.md           trechos 11–20 · 5 exercícios
├── …
└── prova/
    ├── README.md                  índice das partes (gerado em código, sem API)
    ├── parte-01.md                trechos 1–50 · 10 questões + gabarito
    ├── parte-02.md
    ├── parte-03.md
    └── parte-04.md
```

Por que `exercicios-NN.md` sem prefixo numérico: os trechos são `01-`…`20-`, e
como letra ordena depois de dígito, os arquivos de exercício caem naturalmente
no fim da listagem do capítulo, sem disputar numeração com os trechos (e sem
renumerar nada se a pessoa mudar o número de exercícios na revisão).

**Gabarito junto ou separado?** O rascunho acima o põe no fim do próprio
arquivo, depois de um `---`. É uma tarefa = uma chamada = **um** arquivo, que é
o contrato de `O.concluir` hoje. Separar o gabarito em `prova/gabarito-01.md`
exigiria `O.concluir` gravar dois arquivos a partir de uma resposta (dá para
fazer, extraindo por marcador como o `<!--SINTESE-->` já é extraído) — é uma
decisão sua; anotada em §10.

---

## 7. Compatibilidade com planos antigos

Um `obra_json` gravado antes desta mudança não tem `avaliacao`, `prova` nem
`cap.exercicios`. Nada pode quebrar ao abrir o app sobre ele:

- todo acesso é defensivo (`type(cap.exercicios) ~= "table"` → lista vazia);
- `O.contar` sem lotes dá exatamente o total de antes;
- `O.tomar_tarefa` não encontra tarefa nova e a fila se comporta igual;
- **não há migração automática.** Acrescentar exercícios a uma obra já produzida
  é uma decisão que custa dinheiro; ela vem de um plano novo, não de um app que
  resolveu sozinho.

E o cuidado de sempre com `json.array({})` nas listas vazias: sem ele o
`json.encode` devolve `{}` e a lista volta do disco como objeto.

---

## 8. Custo — a conta honesta

Na obra padrão (10 capítulos × 20 trechos), com os padrões propostos:

| | tarefas | US$ a 0,084/chamada |
|---|---:|---:|
| trechos | 200 | 16,80 |
| aberturas | 10 | 0,84 |
| **lotes de exercícios** (10 exercícios/cap., lotes de 5) | **20** | **1,68** |
| **partes da prova** (40 questões, 10 por parte) | **4** | **0,34** |
| **total** | **234** | **19,66** |

**+11,4% sobre os US$ 17,64 de hoje.** É pouco porque a unidade não é o
exercício, é o lote: 200 exercícios e 40 questões saem em 24 chamadas.

A extrapolação de `producao.luau` continua sendo `custo_medido_por_trecho ×
tarefas_restantes`, e continua sendo uma aproximação — agora com uma imprecisão
a mais, porque um lote de exercícios costuma render menos tokens que um trecho.
O erro é **para cima** (a estimativa superestima), que é o lado certo de errar
numa tela que pede autorização para gastar. Vale uma frase no diálogo dizendo
isso; não vale um modelo de custo por tipo de tarefa.

---

## 9. Verificação

O `--check` é a régua deste repositório: um comando, sem dependência externa,
que roda antes de commitar. O trabalho não está pronto sem estas adições.

### 9.1 `tests/luau/fila.luau` (a suíte que mais importa)

- `O.montar` com `avaliacao` materializa **os lotes e as partes esperados**,
  com faixas contíguas, disjuntas e cobrindo todos os trechos;
- `O.contar` soma as tarefas novas;
- **a invariante forte, estendida:** seis workers intercalados esvaziam a fila e
  cada tarefa — trecho, abertura, lote e parte — saiu **exatamente uma vez**;
- **as dependências:** nenhum lote sai antes dos trechos da faixa dele; nenhuma
  parte de prova sai antes do último trecho da obra;
- `reenfileirar_falhas` devolve lote e parte falhados, e destrava os que ficaram
  em `fazendo` (app fechado no meio);
- `avaliacao = nil` (plano antigo) se comporta exatamente como hoje.

### 9.2 Suíte nova: `tests/luau/avaliacao.luau`

A aritmética das faixas é pura e cheia de fronteiras — merece teste próprio,
sem plano nem `ctx`:

- `O.faixas(20, 2)` → `{1–10, 11–20}`; `O.faixas(7, 3)` → `{1–3, 4–5, 6–7}`;
- `O.faixas(3, 5)` nunca devolve faixa vazia (o `clamp` do §2.1);
- `O.distribuir(10, 3)` → `{4, 3, 3}`; soma sempre = N;
- saneamento de entrada: `""`, `"abc"`, `"-4"`, `"999"`, `"7,5"` → o padrão ou o
  limite, nunca `nil` e nunca um número que faça `ceil` explodir.

Registrar as duas em `tests/luau/suite.luau`.

### 9.3 `src/checar.rs`

- `checar_alinhamento_dos_botoes` define `tipo_curso = "true"` (e
  `quer_exercicios`/`quer_prova`), senão o painel novo é podado e a fila de
  botões dele nunca é percorrida — é exatamente a armadilha que o comentário
  sobre `rev_capitulos_ui` naquela função já documenta;
- `simular_producao` semeia um plano **com** lotes e partes e cobra
  `total_tarefas`, o `detalhe` dos capítulos e `tem_prova`;
- uma simulação curta na tela `inicio`: marcar "curso" acende o painel, marcar
  "guia" o apaga, e um `n_exercicios_mudou("abc")` não derruba a tela nem
  apaga o valor válido anterior;
- `simular_revisao` confirma um plano com avaliação e verifica que `obra_json`
  saiu com os lotes materializados.

---

## 10. Decisões que deixei em aberto para você

| # | Decisão | O que propus | A alternativa |
|---|---|---|---|
| 1 | Escopo dos exercícios | **por capítulo**, integrativos, além do exercício que cada trecho já traz | por trecho (N por trecho) — multiplica as chamadas por 200, +100% de custo |
| 2 | Gabarito da prova | no fim do próprio arquivo da parte, depois de um `---` | arquivo separado — exige `O.concluir` gravar 2 arquivos por tarefa |
| 3 | Onde configurar | `inicio` **e** `revisao` (os mesmos dois campos) | só em `revisao`, onde a conta final é conhecida |
| 4 | Padrões | 10 exercícios/capítulo, 40 questões | mais agressivo (20 e 60) — a obra fica mais "curso", o custo sobe ~22% |
| 5 | Tipos além de curso | só curso, como você pediu | liberar exercícios (não a prova) também para o guia |
| 6 | Prova por faixa de trechos | sim — sem sobreposição por construção | prova em uma chamada só; cabe até ~15 questões, e some a densidade |
| 7 | Síntese passa a citar o exercício do trecho (§5.5) | sim, é uma linha | não, e aceitar alguma repetição entre trecho e lote |

---

## 11. Ordem de implementação

Cada item é um commit que fecha com `cargo run -- --check` verde.

1. **Refactor sem comportamento novo:** extrair `O.alvo_de` e fazer `concluir` /
   `falhar` / `reenfileirar` passarem por ele. As suítes atuais passam iguais.
2. **A aritmética pura:** `O.faixas`, `O.distribuir`, saneamento de número, e a
   suíte `tests/luau/avaliacao.luau`. Nada ligado à UI ainda.
3. **O modelo:** tipos novos, `O.montar` materializando lotes e partes,
   `O.contar`, `O.tomar_tarefa` com as dependências — e `tests/luau/fila.luau`
   estendida. Aqui a fila já produz tarefas novas que ninguém consome.
4. **Os prompts:** `P.exercicios` e `P.prova` + os dois sistemas, e o ramo
   correspondente em `producao.luau:executar`. Fim da ponta a ponta: com um
   plano semeado à mão, a produção já escreve os arquivos.
5. **A UI:** painel em `inicio`, campos em `revisao`, bloco da prova em
   `producao`, os rótulos e o texto do `confirm`, e as checagens do §9.3.
6. **Disco e índices:** `cabecalho_capitulo`, `gravar_sumario`,
   `gravar_indice_prova`.
7. **README:** o fluxo, a tabela de custo e a árvore de `saidas/` mudaram.

Os passos 1–3 não mudam nada visível e são reversíveis sozinhos; os riscos reais
(fila e custo) ficam todos cobertos por teste antes de a primeira chamada paga
existir.

---

## 12. Onde a implementação se afastou deste plano

Sete decisões estavam em aberto na §10. Todas foram tomadas como proposto,
menos a dificuldade nenhuma que a #3 acabou dando: os quatro campos aparecem
nas duas telas, e sem duplicar lógica, porque `lib/avaliacao.luau` é dono
deles e as duas telas só o chamam.

O resto são desvios que o código pediu, não escolhas de gosto:

**A prova não espera a obra inteira.** O plano dizia que uma parte de prova só
seria liberada quando todos os trechos da obra estivessem resolvidos. Ficou
igual ao lote de exercícios: cada parte espera só **a faixa dela**. A parte 1,
que cobre os trechos 1 a 50, não tem nada a ganhar esperando o trecho 200 —
ela não vai perguntar sobre ele. Mais paralelismo, mesmo aterramento.

**O recorte que vira prompt mora em `obra.luau`, não na tela.** `linhas_do_lote`
e `linhas_da_prova` iam ficar em `producao.luau`. Um off-by-one ali não daria
erro nenhum: o lote sairia escrito, cobrado, e cobrando um trecho que não é
dele — ou deixando um sem exercício. Na tela a suíte não alcança; em
`obra.luau`, ao lado de `O.vizinhanca` (que faz o mesmo tipo de projeção), ela
alcança. Tem teste.

**`O.CAPITULOS`/`O.SUBCAPITULOS` saíram das telas.** Não estava no plano. A
tela inicial precisa da forma padrão da obra para estimar o custo antes de a
obra existir, e isso faria uma **terceira** cópia de constantes que
`perguntas.luau` e `revisao.luau` já duplicavam — com um comentário em
`revisao.luau` avisando que divergir ali pediria "um esboço menor por engano".
Foram para `lib/obra`.

**A conta é recalculada por `R.projetar`, não por cada handler.** Acrescentar
um subcapítulo na revisão muda o número de lotes. Amarrar o recálculo à
projeção do esboço (mesmo padrão de `O.gravar_plano`) faz esquecer deixar de
ser possível.

**O `--check` ganhou uma simulação inteira, não só asserções.**
`simular_exercicios_e_prova` cobre o painel aparecendo e sumindo com o tipo, o
campo aceitando ficar vazio enquanto se digita, entrada inválida não derrubando
a tela, e desmarcar um interruptor não desligando o outro.

### Duas notas sobre os testes, que valem mais que o resto

O teste da dependência (nenhum lote sai antes dos trechos que ele cobra) nasceu
**vacuoso duas vezes**:

1. ele checava a invariante chamando `O.faixa_resolvida` — a mesma função que a
   fila usa para decidir. Arrancar a guarda passava despercebido: as duas
   pontas concordavam em estar erradas. Agora olha os `status` crus.
2. ele drenava a fila uma tarefa por vez, e assim nunca havia trecho em voo.
   `O.tomar_tarefa` esvazia os trechos antes de olhar para os lotes, então a
   guarda simplesmente nunca era consultada. Agora mantém 6 tarefas em voo,
   como o pool real.

As duas versões passavam com a guarda removida. A terceira falha — foi
verificado assim, arrancando a guarda e vendo o teste acusar 6 tarefas fora de
hora. Um teste de invariante que nunca foi visto falhando não é um teste.

### Números finais

| | |
|---|---|
| casos nas suítes Luau | 108 → **200** |
| checagens do `--check` | 12 → **13** |
| custo de um curso com exercícios e prova | +11,4% (US$ 17,64 → US$ 19,66) |
