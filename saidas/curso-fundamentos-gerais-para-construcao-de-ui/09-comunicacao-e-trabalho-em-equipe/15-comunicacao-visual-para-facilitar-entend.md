## Comunicação visual para facilitar entendimento

Existe um tipo específico de reunião que se arrasta: aquela em que seis pessoas discutem um fluxo que ninguém desenhou. Cada uma tem na cabeça uma versão diferente da sequência de passos, todas usam as mesmas palavras, e a divergência só aparece semanas depois, na implementação.

Vinte minutos desenhando o fluxo em um quadro — mesmo mal desenhado — teriam encerrado a discussão no primeiro dia. Não porque o desenho seja bonito, mas porque ele torna a divergência visível.

Comunicação visual, aqui, não é sobre produzir peças bonitas. É sobre escolher, para cada tipo de informação, a representação que expõe o que o texto esconde.

### Qual representação para qual informação

| O que você precisa comunicar | Use |
|---|---|
| Sequência de passos, com desvios | Fluxograma |
| Estrutura hierárquica | Lista indentada ou árvore |
| O que acontece ao longo do tempo, com emoção | Mapa de jornada |
| Comparação entre alternativas | Tabela |
| Relação entre partes de uma tela | Wireframe anotado |
| Antes e depois | Duas capturas lado a lado |
| Quantidade, proporção, tendência | Gráfico |
| Quem faz o quê, quando | Diagrama de raias |

A escolha errada custa clareza. Um fluxo descrito em texto corrido esconde os desvios; uma hierarquia desenhada como fluxograma vira um emaranhado; uma comparação em prosa obriga o leitor a construir a tabela mentalmente.

### O fluxograma que qualquer um consegue fazer

É a peça de melhor retorno e a que mais gente evita por achar que precisa de ferramenta. Não precisa. Quatro símbolos bastam:

```
[retângulo]  uma tela ou um passo
<losango>    uma decisão, com as saídas rotuladas
(oval)       início ou fim
──►          o caminho

        (início)
           │
      [Buscar pedido]
           │
    <encontrou?>──não──► [Mensagem: nenhum resultado]
           │ sim                    │
    [Abrir pedido]                  └──► [Nova busca]
           │
    [Solicitar devolução]
           │
    <foto obrigatória?>──sim──► [Anexar foto]
           │ não                     │
           └──────────┬──────────────┘
                      │
              [Confirmação]
                      │
                   (fim)
```

Duas regras que fazem um fluxograma ser útil: **toda decisão tem as saídas rotuladas** (sem "sim" e "não" escritos, o leitor adivinha), e **todo caminho termina** em algum lugar. A segunda é o que revela os becos sem saída — e é por isso que desenhar o fluxo encontra problemas que a discussão verbal não encontra.

### Anotar imagens: a técnica mais subutilizada

Uma captura de tela com três anotações numeradas comunica mais rápido que dois parágrafos, e é a peça que mais aparece em documentação boa de interface.

Três convenções que fazem funcionar:

**Numere e referencie.** Os números na imagem correspondem a itens de uma lista abaixo. Isso permite descrever cada ponto com o detalhe necessário sem poluir a imagem.

**Use uma cor que não existe na interface.** Se o sistema é azul, anote em magenta. Anotação da mesma cor do produto se confunde com o produto.

**Diga o que observou, não só o que propõe.** "1 — Nenhuma indicação de que a lista está filtrada" comunica o problema; "1 — Adicionar etiquetas" comunica só a solução, e perde a razão dela.

### Antes e depois: a peça mais persuasiva, e a mais fácil de falsear

Duas capturas lado a lado convencem mais que qualquer argumento. Justamente por isso, a honestidade dessa peça é uma questão de credibilidade profissional.

As regras não negociáveis: **mesmos dados, mesma resolução, mesmo estado**. Comparar a tela antiga cheia de registros com a nova mostrando três linhas escolhidas é manipulação, e é detectada por qualquer avaliador experiente — com um custo de confiança muito maior do que o ganho da comparação.

Se a nova versão precisa de dados diferentes para ser demonstrada, isso é informação sobre a proposta, não um detalhe de apresentação.

### Gráficos: poucos e simples

Em comunicação de design, os gráficos que aparecem são quase sempre de três tipos, e cada um tem um uso claro:

**Barras** para comparar quantidades entre categorias — chamados por assunto, tempo por versão, acertos por tarefa. É o mais legível e resolve a maioria dos casos.

**Linha** para tendência ao longo do tempo — abandono por mês, chamados por trimestre.

**Funil** para etapas sequenciais com perda — a peça mais direta para mostrar onde as pessoas desistem.

Três cuidados: rotule os eixos, comece o eixo de quantidade em zero (truncar exagera diferenças e é percebido como manipulação), e escreva a conclusão no título. "Abandono concentra-se na etapa 3" é um título; "Taxa de abandono por etapa" é uma legenda que obriga o leitor a tirar a própria conclusão — e nem todo leitor vai tirar a que os dados sustentam.

### O erro que você vai cometer: caprichar no diagrama antes de validar o conteúdo

Você precisa comunicar um fluxo. Abre a ferramenta de diagramas, escolhe uma paleta, alinha as caixas, ajusta as curvas das setas. Duas horas depois, o diagrama está lindo — e na primeira apresentação alguém aponta que falta um caminho inteiro, e refazer significa reorganizar tudo.

O acabamento cedo demais tem dois custos. O óbvio é o retrabalho. O menos óbvio é o mesmo dos protótipos: um diagrama acabado desencoraja a correção — as pessoas relutam em apontar um problema estrutural em algo que claramente deu trabalho.

A ordem que funciona é a mesma da prototipagem: **rascunho à mão, validação, e só então acabamento — se o acabamento for necessário**. Uma foto de um quadro branco enviada no canal da equipe recolhe as correções em vinte minutos. Muitas vezes o rascunho é suficiente e o diagrama bonito nunca precisa existir.

O acabamento se justifica quando a peça vai circular fora da equipe, ficar em documentação de longa duração, ou ser apresentada a quem não acompanhou a construção. Nos demais casos, ele é custo sem retorno.

### Exercício prático

**Objetivo:** substituir uma explicação em texto por uma peça visual e medir a diferença.

1. Encontre, na documentação do seu projeto, um trecho de texto que descreve um fluxo ou uma estrutura.
2. Escolha a representação adequada pela tabela deste trecho.
3. Desenhe à mão, em papel ou quadro. Não use ferramenta ainda.
4. Mostre a duas pessoas: uma lê o texto original, outra vê o desenho. Peça a cada uma que explique o fluxo com as próprias palavras, e cronometre.
5. Anote as diferenças: quem entendeu mais rápido, quem cometeu erros, quais partes ficaram ambíguas em cada versão.
6. Só então, se a peça for circular, produza a versão acabada — incorporando as correções do passo 5.

### Solução comentada

O passo 4 costuma mostrar duas coisas ao mesmo tempo, e a segunda é a mais interessante.

A primeira, esperada: quem vê o desenho explica mais rápido e comete menos erros de sequência. Não é surpresa — sequência é exatamente o que um fluxograma representa melhor que o texto.

A segunda, menos esperada: quem lê o texto às vezes menciona **detalhes que o desenho perdeu**. Condições específicas, exceções, o valor exato de um limite. Isso não é falha do desenho; é uma propriedade da representação visual — ela comunica estrutura e perde nuance.

A conclusão prática é que texto e imagem não competem, se complementam. A documentação que funciona melhor tem o diagrama para a estrutura e o texto ao lado para as condições. Substituir integralmente um pelo outro perde informação nas duas direções.

Sobre o passo 3, desenhar à mão: além de ser mais rápido, o rascunho tem um efeito social específico em revisões. Um desenho torto e claramente provisório convida à correção — as pessoas apontam problemas sem cerimônia. O mesmo conteúdo em um diagrama impecável recebe silêncio e concordância educada. Se o seu objetivo é encontrar o que está errado, o acabamento trabalha contra você.

---
