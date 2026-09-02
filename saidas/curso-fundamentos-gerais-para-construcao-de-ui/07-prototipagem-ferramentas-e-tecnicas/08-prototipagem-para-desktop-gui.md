## Prototipagem para desktop GUI

Prototipar uma aplicação desktop é o caso que menos se parece com os tutoriais que você encontra por aí — quase todos usam telas de celular. E as diferenças não são de tamanho: são de modelo de interação, de densidade de informação e de expectativa de quem usa. Uma pessoa que passa oito horas por dia dentro do mesmo sistema desktop quer coisas que um visitante de aplicativo detestaria.

### O que muda em relação a mobile e web

**A área é grande e o ponteiro é preciso.** A lei de Fitts trabalha a seu favor: alvos podem ser menores, e as bordas e cantos da tela são posições privilegiadas — o ponteiro para na borda, o que torna um menu no topo absoluto da tela mais fácil de acertar do que um a dez pixels dela.

**Existem estados que só existem aqui.** Hover é real (não existe em toque). Foco de teclado é essencial. Clique direito abre menu de contexto. Duplo clique tem significado. Arrastar e soltar é esperado. Atalhos de teclado não são luxo, são o principal caminho de quem usa o sistema todo dia.

**A janela é redimensionável e pode ser múltipla.** O usuário pode ter o seu sistema em meia tela ao lado de uma planilha. Pode abrir duas janelas do mesmo sistema. Pode estar em um monitor 4K ou em um notebook de 1366 × 768 — que ainda é comum em parque de máquinas corporativo.

**A densidade esperada é alta.** Espaçamento generoso, que é qualidade em uma landing page, vira desperdício em um sistema de operação: se caberiam 30 linhas e cabem 12, a pessoa rola três vezes mais para fazer o mesmo trabalho.

**Existe convenção de sistema operacional.** Onde ficam os botões de confirmar e cancelar em uma caixa de diálogo, o que faz `Esc`, se a barra de menus fica na janela ou no topo da tela — tudo isso é diferente entre Windows, macOS e os ambientes Linux, e contrariar a convenção local irrita justamente quem usa mais.

### Montando o arquivo de protótipo

Comece pelas dimensões certas. Não prototipe em uma tela grande e confortável se o seu usuário está num notebook antigo. Duas medidas para trabalhar:

| Frame | Tamanho | Uso |
|---|---|---|
| Mínimo suportado | 1366 × 768 | O caso apertado; se funciona aqui, funciona |
| Comum | 1920 × 1080 | O caso típico de estação de trabalho |

Desconte a barra de tarefas e a moldura da janela: em 1366 × 768, a área útil real de uma janela maximizada fica em torno de 1366 × 690. Prototipar na medida cheia esconde exatamente o problema que você precisa ver — o conteúdo que não cabe.

O padrão estrutural dominante em desktop corporativo:

```
┌─────────────────────────────────────────────────────┐
│ Barra de título / menu do aplicativo                │
├──────────┬──────────────────────────────────────────┤
│          │ Barra de ferramentas / filtros           │
│ Navegação├──────────────────────────────────────────┤
│ lateral  │                                          │
│          │ Área de conteúdo                         │
│          │ (tabela, formulário, editor)             │
│          │                                          │
├──────────┴──────────────────────────────────────────┤
│ Barra de status: contagem, conexão, mensagens       │
└─────────────────────────────────────────────────────┘
```

A barra de status é frequentemente esquecida em protótipos e é onde mora informação que o usuário consulta o dia inteiro: quantos registros foram carregados, se há alterações não salvas, se a conexão caiu.

### Prototipando o que é específico de desktop

**Hover.** Use variantes de componente com interação `On hover` → `Change to`. Vale para linhas de tabela (destacar a linha sob o ponteiro), botões e itens de menu. É o que mais aproxima o protótipo da sensação real.

**Menus de contexto.** O gatilho de clique direito não existe nas ferramentas de prototipagem. A convenção é simular com um clique normal em uma área designada, e avisar o participante do teste: "aqui, considere que você clicou com o botão direito". Alternativamente, use uma tecla como gatilho.

**Atalhos de teclado.** Figma permite gatilho `On key press`. Ligue `Ctrl+S` a uma sobreposição de "Salvo" e `Esc` a `Close overlay` em todos os modais. Prototipar isso muda o teste: usuários experientes tentam usar atalhos espontaneamente, e você descobre quais eles esperam.

**Redimensionamento.** Nenhuma ferramenta simula bem. A saída é desenhar dois ou três frames em larguras diferentes e mostrar lado a lado — não é interativo, mas comunica a intenção para quem vai implementar.

**Tabelas densas.** Não desenhe cinco linhas de exemplo. Desenhe quarenta, com dados reais e variados: nomes longos que estouram a coluna, valores negativos, células vazias, status diferentes. A tabela de cinco linhas com dados bonitos é a maior fonte de surpresa desagradável na implementação.

### O erro que você vai cometer: prototipar como se fosse um site

O sintoma é reconhecível: espaçamento de 24 pixels entre campos, botões de 48 pixels de altura, tipografia de 18 pixels, cards com sombra, uma ação principal grande e colorida por tela. Fica bonito na apresentação e é péssimo em uso contínuo.

O que acontece quando isso chega ao usuário real: cabem seis campos onde caberiam quinze, o operador precisa rolar dentro de um formulário que deveria caber inteiro na tela, e uma tarefa que levava dois minutos passa a levar três. Multiplicado por duzentas repetições diárias, é uma hora de trabalho perdida por pessoa.

A correção não é apertar tudo aleatoriamente, é adotar uma **escala de densidade** compatível com o contexto: tipografia de corpo em 13 ou 14 pixels, altura de linha de tabela entre 28 e 36 pixels, altura de campo entre 28 e 32, espaçamento vertical entre campos de 8 a 12. E, principalmente: teste com o volume real de dados e com o usuário real, que quase sempre pede mais densidade, não menos.

Há uma exceção que vale registrar: se o seu usuário desktop é ocasional — usa o sistema uma vez por semana —, a densidade alta perde valor e a clareza volta a mandar. Densidade é uma troca entre eficiência para o experiente e facilidade para o novato, e a escolha depende de qual dos dois você tem mais.

### Exercício prático

**Objetivo:** prototipar uma tela de listagem desktop com interações próprias da plataforma.

Monte uma tela de gestão de pedidos em 1366 × 690, contendo:

1. Navegação lateral com quatro seções, sendo uma ativa.
2. Barra de ferramentas com busca, dois filtros e um botão de ação primária.
3. Tabela com pelo menos 25 linhas de dados variados — inclua um nome com 60 caracteres, um valor negativo, uma célula vazia e três status diferentes.
4. Barra de status com a contagem de registros.

Adicione as interações:

- Hover na linha da tabela, com destaque.
- Clique na linha abrindo um painel lateral de detalhe (sobreposição alinhada à direita), com `Esc` fechando.
- Atalho `Ctrl+F` levando o foco ao campo de busca (simulado com uma variante de campo em foco).
- Estado de tabela vazia, acessível por um gatilho de teste.

### Solução comentada

O item 3 é o que costuma quebrar o layout, e essa é a intenção do exercício.

O nome de 60 caracteres força uma decisão que ninguém toma voluntariamente: a coluna cresce, o texto quebra em duas linhas, ou é truncado com reticências? As três opções têm consequências. Coluna elástica desalinha a tabela inteira e faz as colunas dançarem entre uma consulta e outra. Quebra de linha destrói a altura uniforme das linhas, que é o que permite varrer a tabela com o olho. Truncar esconde informação — e se dois clientes se chamam "Distribuidora Comercial de Alimentos e Bebidas do…", truncar torna a tabela inútil.

A resposta usual em sistemas maduros é truncar com reticências, manter largura fixa, e mostrar o valor completo em tooltip ou no painel de detalhe. Mas essa escolha só aparece quando você coloca o dado real no protótipo; com "João Silva" em todas as linhas, ela nunca é feita, e o problema chega ao usuário.

Sobre o painel lateral de detalhe: a escolha entre painel lateral e modal centralizado não é estética. O painel lateral mantém a lista visível, o que permite comparar itens e navegar de um para o outro sem fechar nada — comportamento frequente em trabalho de conferência. O modal centralizado bloqueia o contexto e é adequado quando a ação exige atenção exclusiva, como uma confirmação destrutiva. Se, no seu teste, os participantes fecharem o detalhe e abrirem outro repetidamente, o painel lateral é a escolha certa e o modal está cobrando um preço a cada troca.

Por fim, o atalho `Ctrl+F`: prototipá-lo revela um conflito que só existe em desktop e em navegador. `Ctrl+F` é a busca nativa do navegador e do sistema. Se o seu sistema roda em navegador e captura essa tecla, você está sobrescrevendo um comportamento que o usuário conhece há vinte anos — o que é defensável em uma aplicação intensiva, e irritante em uma de uso ocasional. É exatamente o tipo de decisão que vale ser tomada explicitamente, e não por omissão.

---
