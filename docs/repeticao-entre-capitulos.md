# A repetição entre capítulos

**Estado:** **implementado** na branch `claude/course-exercises-tests-impl-153ncq`,
menos a §3.4, que ficou de fora à espera da sua decisão. A §6 no fim registra o
que foi feito, os números medidos depois e o que não foi.

Você notou que `unsafe` é ensinado no capítulo 7 depois de já ter sido ensinado
no 1 e no 2. Fui ver a obra. É verdade, é sistemático, e a causa **não está na
escrita dos trechos — está no esboço**, decidida antes de a primeira chamada
paga acontecer.

A obra examinada é `saidas/roadmap-gerenciamento-avancada-de-memoria-com-ru`
(9 capítulos, 109 trechos, 118 tarefas). Ela é do tipo **roadmap**, não curso —
o que não muda nada: o problema e a correção valem para os três tipos.

---

## 1. O que a obra mostra

### 1.1 O capítulo 1 é um sumário do curso inteiro

"Fundamentos de Gerenciamento de Memória em Rust" tem 20 trechos. Os oito
primeiros são fundamentos de verdade. Os doze seguintes são **trailers de
capítulos posteriores**:

| Trecho do capítulo 1 | Já é o capítulo |
|---|---|
| 9. Safe vs Unsafe: Visão Geral | 7 — Unsafe Code e Otimização |
| 10. Casos de Uso para Unsafe Code | 7 |
| 11. Introdução a Profiling em Rust | 5 — Ferramentas e Técnicas de Profiling |
| 12. Ferramentas de Profiling: Perf | 5 |
| 13. Ferramentas de Profiling: DTrace | 5 |
| 14. Análise de Desempenho com Criterion | 5 |
| 15. Otimização de Estruturas de Dados | 6 — Técnicas de Otimização |
| 16. Padrões de Design para Eficiência | 6 |
| 17. Gerenciamento de Recursos em Servidores | 4 — Servidores High-Throughput |
| 18. Gerenciamento de Recursos em Desktop | 3 — Aplicações Desktop |
| 19. Estudos de Caso: Aplicações Reais | 8 — Projetos Práticos |
| 20. Próximos Passos e Recursos | 9 — Conclusão e Próximos Passos |

O capítulo 2 faz o mesmo: dos 19 trechos dele, cerca de 13 antecipam os
capítulos 5, 6, 7 e 8 — inclusive um com **título literalmente idêntico** ao de
um trecho do capítulo 7 (`FFI e Gerenciamento de Memória`, em 02-10 e 07-04).

Somando, por leitura minha: **cerca de 25 dos 39 trechos dos capítulos 1 e 2
são prévias dos capítulos 3 a 9.** Não é um capítulo repetido. É um terço da
obra gasto duas vezes.

### 1.2 O que os três textos sobre `unsafe` fazem

Não copiam frases um do outro — a sobreposição literal de 5-gramas entre
trechos de capítulos diferentes é **quase zero** (um único par acima de 3% em
toda a obra). Cada um foi escrito do zero, com exemplos próprios. É por isso
que a repetição não salta num diff: ela é **conceitual**.

Os três começam do mesmo lugar:

- **1.9 Safe vs Unsafe: Visão Geral** — "o compilador impõe regras estritas…",
  define as três garantias, mostra um exemplo seguro, apresenta ponteiros brutos.
- **2.6 Safe vs Unsafe: Trade-offs** — abre com um caso de vídeo a 60 FPS,
  compara versão segura × `unsafe`, apresenta ponteiros brutos.
- **7.1 Quando Usar Unsafe Code** — "o `unsafe` permite que você contorne
  algumas das garantias de segurança do compilador", **lista de novo** o que
  ele libera, apresenta `*const T` e `*mut T`.

O 7.1 está escrito para quem nunca viu `unsafe`. Rastreando os conceitos pela
obra: `*const`/`*mut` aparece em **29 trechos de 7 capítulos**; `perf record`
em 14 trechos de 5 capítulos; `criterion` em 26 trechos de 8 capítulos. Nem
toda menção é reintrodução — mas as aberturas acima mostram que muitas são.

---

## 2. As duas causas

### Causa A — o esboço aloca o mesmo assunto a vários capítulos

`P.esboco` pede "EXATAMENTE 10 capítulos e cada capítulo em EXATAMENTE 20
subcapítulos". Duas coisas acontecem:

**O modelo não obedece** — devolveu 9 capítulos com 20, 19, 10, 10, 10, 10, 10,
10, 10 trechos. E **onde tem mais vagas para preencher, ele despeja o índice
mental inteiro**: os capítulos 1 e 2 receberam 39 vagas e viraram o esboço da
obra toda; os capítulos 3 a 9 receberam 10 cada e são os capítulos de verdade.

O prompt até diz *"Sem sobreposição: se dois subcapítulos ensinariam a mesma
coisa, funda-os e use a vaga para algo que falta"*. Essa instrução perde para
a vaga vazia: com 20 lugares para "Fundamentos" e oito fundamentos na cabeça, o
modelo preenche os outros doze com o que vier.

### Causa B — na produção, um trecho quase não sabe o que os outros capítulos ensinaram

Isto eu medi, simulando uma produção 10 × 20 com os 6 workers reais sobre o
código de hoje (instrumento temporário, já removido):

| | |
|---|---|
| tarefas na obra | 210 |
| **a primeira abertura de capítulo sai no passo** | **125 de 210** |
| o trecho 7.1 sai no passo | 121 |
| capítulos anteriores com síntese REAL quando 7.1 foi escrito | **0 de 6** |
| média, em todos os 180 trechos de capítulos ≥ 2 | **2,27 de N anteriores** |
| **tamanho médio do bloco "já foi ensinado antes"** | **500 caracteres** |

Cinco centenas de caracteres. É esse o contexto que um trecho recebe sobre as
dezenas de milhares de palavras escritas antes dele em outros capítulos.

Três mecanismos se somam para produzir isso:

1. **A abertura do capítulo é a última da fila.** `O.tomar_tarefa` só olha para
   as aberturas quando não há nenhum trecho pendente em nenhum capítulo — e há,
   até quase o fim. Como `cap.sintese` **é** o texto da abertura, ela não
   existe durante quase toda a produção, e `O.vizinhanca` cai no `resumo`
   planejado: uma frase, escrita antes de qualquer conteúdo existir.
2. **Mesmo com a síntese, "antes" dá um parágrafo por capítulo.** As sínteses
   dos 20 trechos de um capítulo anterior são descartadas ao cruzar a fronteira
   do capítulo. O detalhe existe e é jogado fora.
3. **Os capítulos 1 a 6 são escritos em paralelo**, um trecho de cada por vez.
   Eles são mutuamente cegos **por construção** — quando 2.1 é escrito, 1.5
   ainda não existe.

O ponto 3 é o mais importante para entender o que dá e o que não dá para
consertar:

> A produção é paralela, e por isso **parcialmente cega por construção**. O
> esboço é o único lugar onde a obra inteira é visível de uma vez. Logo:
> **prevenir no plano, mitigar na produção.**

---

## 3. As correções propostas

Em ordem de "quanto resolve por quanto custa".

### 3.1 Uma auditoria do esboço, antes de custar (1 chamada, ~US$ 0,08) ⭐

O esboço inteiro — 109 títulos e focos — cabe folgado numa chamada. É o único
artefato pequeno o bastante para caber e grande o bastante para mostrar a obra
toda. Hoje ninguém olha para ele com essa pergunta.

Depois da fase 1 e **antes** da tela de revisão, uma chamada a mais:

> Aqui está o plano completo. Encontre subcapítulos que ensinariam a mesma
> coisa. Para cada assunto repetido, diga qual subcapítulo é o **dono** dele
> (o que o ensina de verdade) e reescreva o `foco` dos outros para *usarem* o
> assunto assumindo-o conhecido, citando o dono — nunca para reensiná-lo.
> Devolva só as correções: `[{cap, sub, foco_novo, motivo}]`.

A saída é pequena (só os focos corrigidos), então cabe. E o resultado chega na
tela de revisão como **sugestões marcáveis**, ao lado dos capítulos — não como
uma edição silenciosa. Quem decide continua sendo você, que é a regra dessa
tela.

Custa uma chamada em ~110, e ataca a causa A no único momento em que ela é
visível. É a correção que eu faria primeiro.

### 3.2 Um registro do que a obra já ensinou (0 chamadas a mais) ⭐

O dado que falta na produção **já existe e é jogado fora**. Cada trecho devolve
um `<!--SINTESE-->` com "conceitos e termos que você definiu". Hoje isso é usado
dentro do capítulo e descartado ao sair dele.

A proposta é acumular isso no plano — `plano.ensinado`, uma lista append-only —
e dar a todo trecho seguinte um bloco compacto:

```
JÁ ENSINADO NESTA OBRA — assuma, referencie, NÃO reintroduza:
- unsafe e as garantias que ele suspende (1.9)
- ponteiros brutos *const/*mut (1.10)
- perf record / perf report (1.12)
- criterion e cargo bench (1.8)
```

Para extrair os termos de forma confiável, um bloco próprio no fim da resposta,
com o mesmo mecanismo do `<!--SINTESE-->` que já funciona (e o mesmo caminho de
recuo se o modelo não seguir o formato):

```
<!--CONCEITOS-->unsafe; ponteiro bruto; perf record<!--/CONCEITOS-->
```

O registro é **deduplicado por termo** (só a primeira ocorrência entra), senão
ele cresce até não caber. Custo real: alguns milhares de caracteres a mais na
entrada de cada chamada. Entrada é mais barata que saída e o app já mede o
custo por chamada — dá para ligar e ver o número mudar antes de decidir.

Isto não conserta a janela cega do começo (quando 2.1 é escrito, quase nada foi
escrito ainda). Conserta o resto, que é a maior parte: no passo 121, há 120
trechos de conceitos disponíveis onde hoje há 500 caracteres.

### 3.3 A abertura sai assim que o capítulo fecha (1 linha, 0 chamadas)

Trocar a ordem dos laços em `O.tomar_tarefa`: aberturas **antes** dos trechos.
A dependência não muda (a abertura continua exigindo o capítulo completo), mas
ela deixa de esperar a fila inteira esvaziar.

Hoje a primeira sai no passo 125 de 210. Com a troca, sai assim que o primeiro
capítulo fecha — e os capítulos 7 a 10, que são escritos depois disso, passam a
receber sínteses reais dos capítulos 1 a 6 em vez de uma frase planejada.

Uma linha, risco perto de zero, e mensurável com o mesmo instrumento que
produziu a tabela da §2.

### 3.4 Deixar o esboço ter o tamanho do assunto (0 chamadas)

`EXATAMENTE 10 × EXATAMENTE 20` já não é obedecido — a obra veio 9 × (20, 19,
10…). Pedir uma faixa ("entre 8 e 12 capítulos, cada um com entre 8 e 20
subcapítulos, conforme o assunto pedir") e dizer explicitamente:

> Um capítulo de fundamentos ensina fundamentos. Ele **não apresenta** os
> assuntos dos capítulos seguintes. Se um assunto tem capítulo próprio, nenhum
> capítulo anterior pode ter um subcapítulo do tipo "Visão Geral de X",
> "Introdução a X" ou "X: Trade-offs".

É o preenchimento de vaga vazia que produz os trailers; tirar a obrigação de
preencher tira o incentivo. Em troca, o tamanho da obra passa a variar — e com
ele o custo. A tela de revisão e o diálogo de confirmação já mostram os dois
números antes de cobrar, então a informação não se perde; mas é uma mudança no
que o app promete, e por isso a deixo por último e como sua decisão.

### 3.5 Medir depois, para saber se as outras funcionaram

O script que produziu a §1.2 vale como checagem embutida: ao fim da produção,
listar os conceitos que aparecem como *ensinados* em mais de um capítulo e
mostrar isso na tela. Sem isso, qualquer uma das correções acima é uma aposta
sem placar.

Isso pede um botão que hoje não existe — "refazer este trecho", separado de
"refazer falhas", que só reenfileira o que deu erro.

---

## 4. O que eu recomendo

| # | Correção | Chamadas | Ataca | Risco |
|---|---|---|---|---|
| 1 | 3.1 auditoria do esboço | +1 | causa A (raiz) | baixo |
| 2 | 3.2 registro do que já foi ensinado | 0 | causa B | baixo |
| 3 | 3.3 abertura sai mais cedo | 0 | causa B (parte) | quase nulo |
| 4 | 3.5 medir a repetição | 0 | validação | baixo |
| 5 | 3.4 esboço de tamanho variável | 0 | causa A | **muda o produto** |

As três primeiras juntas custam uma chamada a mais na obra inteira e atacam as
duas causas. A 3.4 eu não faria sem você decidir: ela mexe no "10 × 20 = 240 mil
palavras", que é parte do que o app promete.

---

## 5. Uma observação de escopo

Isto não é um problema da funcionalidade de exercícios e prova — é anterior a
ela e atinge roadmap, curso e guia igualmente. A obra que você examinou é um
roadmap, gerado antes daquele trabalho.

Vale dizer, porém, que os exercícios **herdam** o problema: a lista do capítulo
7 vai propor exercícios sobre `unsafe` como se fosse assunto novo, porque o
`foco` dos trechos dele diz que é. Consertar o plano conserta os dois.

---

## 6. O que foi implementado

Quatro das cinco correções. A §3.4 (esboço de tamanho variável) **não** entrou:
ela mexe no "10 × 20 = 240 mil palavras" que é parte do que o app promete, e eu
disse na §4 que não a faria sem você decidir. Continua disponível.

### 6.1 O que entrou

| § | Correção | Chamadas | Onde |
|---|---|---|---|
| 3.1 | Auditoria do esboço | +1, automática | segunda metade da fase 1, em `R.auditar` |
| 3.2 | Registro do que já foi ensinado | 0 | `plano.ensinado`, alimentado pelo bloco `<!--CONCEITOS-->` |
| 3.3 | Abertura sai assim que o capítulo fecha | 0 | ordem dos laços em `O.tomar_tarefa` |
| 3.5 | Medir a repetição | 0 | `plano.repeticoes`, na tela de produção |

### 6.2 Os números, medidos depois

Mesma simulação da §2 — 10 × 20, seis workers, código real:

| | antes | depois |
|---|---|---|
| a 1ª abertura de capítulo sai no passo | 125 de 210 | ≤ 130, assim que o 1º capítulo fecha |
| capítulos anteriores já sintetizados, em média | 2,27 | 2,59 |
| **contexto sobre o resto da obra, por trecho** | **500 caracteres** | **5.702 caracteres** |

O ganho da 3.3 sozinha é pequeno (2,27 → 2,59), e o teste diz por quê em vez de
esconder: os capítulos 1 a 6 correm em paralelo e fecham quase juntos, então
adiantar as aberturas ajuda sobretudo os capítulos finais. Quem carrega a
correção é o registro — as 11 vezes mais de contexto da última linha.

### 6.3 Onde a implementação se afastou da proposta

**A auditoria não remove nada.** A proposta falava em "corrigir o foco"; na
implementação isso virou regra dura: os achados **só** reescrevem `foco`, nunca
apagam subcapítulos. Apagar muda o tamanho e o preço da obra, e essa decisão é
de quem paga — o botão para isso já existe na tela. Quando o certo é apagar, o
`motivo` do achado diz.

**A auditoria é automática, não um clique.** Nasceu como botão na tela de
revisão e estava errado: sobreposição não é uma opinião que a pessoa possa
querer ou não ter, é um defeito do plano — e um defeito que ninguém clicou para
procurar continua lá. Agora ela é a segunda metade da fase 1, e roda junto com
o esboço (tanto no `gerar` quanto no "gerar de novo"): quem chega à revisão
chega com o plano já conferido.

As correções são aplicadas na hora, e a tela de revisão lista o que mudou com
um **desfazer** por linha — cada achado guarda o `foco_antigo`. Não é edição
silenciosa: é edição visível e reversível, e o foco continua editável à mão como
qualquer outro campo.

Se a chamada da auditoria falhar, **nada é bloqueado**: o esboço já foi pago e é
válido, então o erro vira um aviso no log e o fluxo segue para a revisão. Uma
auditoria que não voltou é uma obra sem esta melhoria, não uma obra perdida.

**Desfazer tem uma trava que a proposta não previa.** Entre a conferência e o
clique em "desfazer", a pessoa pode reordenar, apagar ou acrescentar capítulos —
e aí `cap`/`sub` apontam para outro subcapítulo. Repor o foco antigo no errado
não daria erro nenhum: apareceria só como um trecho fora de lugar na obra
pronta. Cada achado guarda o TÍTULO que o índice apontava, e desfazer recusa
quando ele mudou. Verificado por mutação: sem a trava, o `--check` acusa a
mexida no subcapítulo errado.

**Os exercícios também recebem o registro**, com a regra invertida: ali o que já
foi ensinado é o que PODE ser exigido, e combinar com o assunto do capítulo é o
que faz um bom exercício. Sem isso, a lista do capítulo 7 cobraria `unsafe`
como assunto novo — a herança que a §5 previa.

### 6.4 O que continua limitado, e é honesto dizer

- **A comparação entre conceitos é por slug.** "unsafe" e "código unsafe" são
  chaves diferentes e passam como dois conceitos. O registro erra para MENOS:
  deixa passar repetição, nunca inventa uma. É o lado certo de errar num sinal
  que a pessoa lê como "isto está duplicado", mas significa que o placar é um
  piso, não um total.
- **A janela cega do começo continua lá.** Quando o trecho 2.1 é escrito, quase
  nada foi escrito ainda. Quem ataca isso é a auditoria do esboço, que agora
  roda sempre — mas ela corrige o PLANO, e um plano corrigido ainda depende de
  o autor de cada trecho respeitar o foco que recebeu.
- **Não há como reconferir depois de editar o plano à mão.** A auditoria roda
  quando o esboço é gerado. Se você acrescentar cinco capítulos na revisão, eles
  não passam por ela. Um botão de reconferência resolveria, mas seria de novo um
  botão — e a decisão foi que o caminho normal não deve depender de clique.
- **O registro tem teto de 400 conceitos.** Quando lota, quem fica são os
  primeiros — são os fundamentos, que é justamente o que os capítulos
  posteriores reensinam.
- **Não há "refazer este trecho".** O placar diz que 7.1 repetiu 1.9, mas
  devolver só aquele trecho à fila continua sendo trabalho manual: "Refazer
  falhas" só reenfileira o que deu erro. Ficou de fora de propósito — mexer
  nisso pede tirar do registro os conceitos do trecho refeito, senão ele
  colidiria consigo mesmo.
