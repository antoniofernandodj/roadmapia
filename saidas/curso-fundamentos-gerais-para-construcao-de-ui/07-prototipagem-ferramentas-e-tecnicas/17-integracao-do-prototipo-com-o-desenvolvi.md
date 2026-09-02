## Integração do protótipo com o desenvolvimento

O protótipo está aprovado, documentado e apresentado. Começa a implementação — e é aqui que a maior parte do trabalho de design costuma se dissolver. Três semanas depois, a tela em produção tem espaçamentos diferentes, cinco tons de cinza que não existiam, o estado vazio virou uma tabela em branco, e ninguém sabe apontar onde exatamente a coisa se perdeu.

Não se perdeu em um lugar. Perdeu-se em cinquenta decisões pequenas, tomadas por quem estava implementando, sem informação para escolher. Integrar protótipo e desenvolvimento é reduzir o número dessas decisões e tornar visíveis as que restam.

### O que atravessa a fronteira

Do arquivo de design para o código passam quatro coisas, e vale distingui-las porque cada uma se transfere de um jeito:

| O que passa | Como | Quem garante |
|---|---|---|
| Medidas e valores | Modo de inspeção, tokens | Ferramenta |
| Ativos (ícones, imagens) | Exportação em SVG/PNG | Designer |
| Comportamento e regras | Documentação escrita | Designer |
| Intenção e prioridade | Conversa | Ambos |

As duas primeiras linhas são as que todo mundo lembra e as que menos causam problema. As duas últimas são onde o resultado se decide.

### Tokens: o vocabulário compartilhado

A forma mais eficaz de reduzir divergência é parar de transferir valores e passar a transferir **nomes**. Em vez de o desenvolvedor ler "16px" no inspetor e escrever `16px` no CSS, os dois lados falam de `espaco-md`.

Um conjunto mínimo, que já resolve a maior parte:

```
Cor
  cor-primaria, cor-primaria-hover, cor-primaria-ativa
  cor-texto, cor-texto-secundario, cor-texto-desabilitado
  cor-superficie, cor-superficie-elevada, cor-borda
  cor-erro, cor-aviso, cor-sucesso, cor-info

Espaçamento (escala de 4)
  espaco-xs 4 · espaco-sm 8 · espaco-md 16 · espaco-lg 24 · espaco-xl 32 · espaco-2xl 48

Tipografia
  texto-xs 12 · texto-sm 14 · texto-md 16 · texto-lg 20 · texto-xl 28
  peso-normal 400 · peso-medio 500 · peso-forte 600

Raio e elevação
  raio-sm 4 · raio-md 8 · raio-completo 999
  sombra-1, sombra-2, sombra-3
```

O ganho não é economizar digitação. É que, quando alguém pergunta "que cinza uso aqui?", existe uma resposta em vez de uma escolha. E quando a paleta mudar, muda em um lugar nos dois lados.

Na ferramenta, isso se implementa com estilos e variáveis nomeados exatamente como no código. A correspondência de nomes é o ponto — `cor/texto/secundario` no Figma e `--cor-texto-secundario` no CSS é uma tradução mecânica; `Cinza 3` e `--text-muted` é uma tradução que exige adivinhação.

### O handoff que funciona: conversa, não entrega

A palavra "handoff" sugere um bastão sendo passado, e essa metáfora é parte do problema. O modelo que produz resultado melhor tem três momentos:

**Antes de prototipar** — quinze minutos com quem vai implementar, mostrando os wireframes. O objetivo é ouvir "isso vai ser caro por causa de X" enquanto mudar ainda custa nada. Uma restrição técnica conhecida cedo é uma restrição de projeto; conhecida tarde, é retrabalho.

**Na entrega** — uma sessão de trinta a sessenta minutos percorrendo o protótipo junto, com a lista de cobertura aberta e as perguntas anotadas. Não envie o link e espere.

**Durante a implementação** — disponibilidade para as perguntas que vão surgir, e uma revisão visual antes de considerar pronto.

O terceiro momento é o mais negligenciado e o de melhor retorno. Uma revisão de vinte minutos, comparando a tela implementada com o protótipo lado a lado, encontra as divergências enquanto o código está fresco e o custo de corrigir é baixo.

### A revisão visual: o que olhar

Uma lista curta cobre quase tudo o que costuma divergir:

1. **Espaçamentos** — os valores saíram da escala? Há um 13px onde deveria haver 16?
2. **Tipografia** — tamanhos, pesos e entrelinha conferem?
3. **Cores** — apareceu algum tom fora da paleta?
4. **Estados** — hover, foco, pressionado, desabilitado, carregando existem? O foco de teclado é visível?
5. **Estados de conteúdo** — vazio, erro e carregando foram implementados, ou só o caso com dados?
6. **Comportamento responsivo** — nas larguras prototipadas, o layout se comporta como projetado?
7. **Textos** — os rótulos e mensagens são exatamente os definidos, ou foram reescritos no caminho?

O item 5 é o que mais falha, e por uma razão previsível: o desenvolvedor implementa com os dados que tem, que raramente incluem o caso vazio. Ele não esqueceu por descuido — esqueceu porque nunca viu a tela naquele estado.

O item 7 parece pequeno e não é. Textos de interface reescritos durante a implementação perdem a precisão que foi trabalhada; "Erro ao salvar" substitui "Não foi possível salvar: o CPF informado já está cadastrado", e o usuário perde a informação que resolveria o problema dele.

### O erro que você vai cometer: exigir fidelidade de pixel

Você abre a tela implementada, compara com o protótipo, e faz uma lista de 47 divergências: 2 pixels aqui, um tom de cinza levemente diferente ali, um raio de canto de 6 em vez de 8.

O que acontece com essa lista: as três primeiras são corrigidas, o desenvolvedor se irrita, a relação azeda, e as divergências que **importam** — o estado vazio ausente, o foco de teclado invisível — ficam enterradas entre as que não importam.

A régua para separar é funcional, não estética. Pergunte, para cada divergência: **isso muda o que a pessoa consegue fazer, entender ou perceber?**

- Contraste insuficiente: sim, muda. Corrija.
- Alvo de toque de 32px em vez de 44: sim, muda. Corrija.
- Estado de foco ausente: sim, muda. Corrija.
- Espaçamento de 14px em vez de 16, isolado: não muda. Deixe.
- Espaçamento inconsistente pela tela inteira, variando entre 12 e 20: sim, muda — a percepção de agrupamento depende disso. Corrija, e a correção certa é adotar a escala, não ajustar caso a caso.

Priorizar assim tem um efeito secundário valioso: quando você aponta apenas o que importa, suas observações passam a ser levadas a sério.

### O protótipo depois da implementação

Uma pergunta prática: o que fazer com o arquivo depois que a tela existe em produção?

Manter o protótipo sincronizado com o produto é caro e quase sempre inútil — o produto vira a fonte de verdade no instante em que é publicado. O que vale preservar:

- A **versão nomeada** correspondente ao que foi implementado, para consulta histórica.
- A **documentação de comportamento**, que deve migrar para junto do código.
- Os **componentes e tokens**, que continuam vivos e servem ao próximo projeto.

O resto — as alternativas, as iterações, os testes — vira material de portfólio e pode ser arquivado. Tentar manter um protótipo "atualizado" indefinidamente produz um arquivo que ninguém confia, o que é pior do que não ter arquivo nenhum.

### Exercício prático

**Objetivo:** conduzir um ciclo de integração completo em uma tela.

1. Escolha uma tela do seu protótipo e defina os tokens que ela usa: cores, espaçamentos, tamanhos de texto. Nomeie-os.
2. Aplique esses estilos nomeados no arquivo de design (não valores soltos).
3. Escreva a documentação de comportamento da tela, no formato de blocos que você já conhece.
4. Peça a alguém que implemente a tela — ou implemente você mesmo, em HTML e CSS, usando variáveis com os mesmos nomes dos tokens.
5. Faça a revisão visual com os sete itens da lista, e classifique cada divergência encontrada em "muda o que a pessoa consegue fazer" ou "não muda".
6. Corrija apenas as da primeira categoria.

### Solução comentada

O passo 2 costuma revelar o problema antes mesmo da implementação: ao tentar aplicar estilos nomeados, você descobre que a tela usa **onze** tons de cinza e **sete** espaçamentos diferentes, muitos deles resultado de arrastar elementos com o mouse em vez de posicioná-los com valores da escala.

Essa descoberta é o principal produto do exercício. Cada valor fora da escala é uma decisão arbitrária que o desenvolvedor terá de reproduzir sem saber se ela foi intencional — e ele vai reproduzir aproximadamente, porque não há razão para acreditar que 13px seja diferente de 12px de propósito. A inconsistência do design vira inconsistência do código, ampliada.

Reduzir onze cinzas a quatro e sete espaçamentos a cinco quase nunca piora a tela. Frequentemente a melhora, porque agrupamentos que eram ambíguos — 12px aqui, 14px ali — passam a ser claros.

No passo 5, a proporção típica é reveladora: de dez a quinze divergências encontradas, duas ou três mudam o que a pessoa consegue fazer. Se você tivesse reportado as quinze, a discussão seria sobre a lista; reportando três, é sobre o problema. E as três costumam ser sempre da mesma natureza — estado ausente, foco invisível, texto reescrito — o que sugere onde investir na próxima entrega: não em mais precisão visual, mas em deixar mais explícito o que não é visível no frame.

---
