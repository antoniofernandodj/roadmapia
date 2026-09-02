## Resumo dos princípios de arquitetura de informação

Arquitetura de informação é a resposta a uma pergunta que aparece antes de qualquer pixel: onde as coisas ficam, e como alguém que nunca viu este sistema descobre isso. Este capítulo tratou dessa pergunta em dois planos que se sustentam mutuamente — a estrutura, que organiza o conteúdo, e a organização visual, que torna essa estrutura perceptível na tela.

No plano da estrutura, o princípio de partida é que uma taxonomia serve a quem procura, não a quem produz. Estruturas que espelham o organograma da empresa são coerentes internamente e inúteis externamente; estruturas nomeadas pelas tarefas que as pessoas realizam sobrevivem a reorganizações e são encontráveis por quem chega de fora. Daí a preferência sistemática, ao longo do capítulo, por rótulos que descrevem o que se faz em vez de quem faz.

Hierarquia e agrupamento vieram em seguida, com uma faixa prática que se repete: de dois a três níveis de profundidade, com cinco a doze itens por nível. Estruturas largas e rasas superam as estreitas e profundas quando os rótulos são claros, porque varrer uma lista com o olho custa menos que acertar três decisões sequenciais. Mapas de site e fluxogramas serviram para tornar essa hierarquia visível e discutível antes de existir em código — e o fluxograma revelou, mais de uma vez, que o problema não estava na estrutura, mas em um caminho que exigia idas e voltas desnecessárias.

Navegação foi tratada pelos seus tipos e pelas suas funções. Navegação global diz onde se pode ir; navegação local diz onde se está dentro de uma seção; navegação contextual liga o que é relevante ali; e a busca é o recurso de quem já desistiu de adivinhar a categoria. Menus e barras seguiram os mesmos critérios, com atenção ao que a lei de Fitts já havia estabelecido — as bordas da tela são posições privilegiadas, e alvos pequenos custam tempo.

O segundo plano, o da organização visual, começou pelo alinhamento e pelo espaçamento. A lição central foi que o espaço em branco não é sobra: é o instrumento primário de agrupamento. Proximidade diz o que pertence a quê com mais força do que qualquer borda, e a maioria das linhas divisórias de uma interface existe para compensar espaçamento mal distribuído. Grids e sistemas de layout deram a isso uma disciplina reproduzível — uma escala de espaçamentos e um grid consistente eliminam a maior parte das decisões arbitrárias de posicionamento.

Consistência visual e padrões de design foram apresentados pelo que economizam: cada padrão reconhecido é uma decisão que a pessoa não precisa tomar de novo. Isso vale para elementos de interface — botões, ícones, campos —, cuja aparência deve dizer o que fazem e em que estado estão. Um controle que parece clicável e não é, ou que não parece e é, cobra o preço em cada encontro.

Cor e tipografia entraram como instrumentos da organização, não da decoração. Cor cria agrupamento e sinaliza estado, sempre como reforço de um sinal já dado por texto, forma ou posição — nunca como único canal. Tipografia estabelece a hierarquia de leitura, e ela exige degraus grandes: diferenças pequenas entre níveis não produzem hierarquia sutil, produzem hierarquia inexistente.

O feedback visual para interação fechou o ciclo entre estrutura e ação: estados de foco, hover, pressionado, carregando, erro e sucesso são o que confirma à pessoa que ela agiu sobre o sistema. Acessibilidade atravessou o capítulo em vez de ocupar um canto dele — ordem de leitura coerente, contraste suficiente, navegação por teclado, e estrutura semântica que faz sentido para quem não vê a tela. Uma arquitetura só existe de verdade se existe também para quem a percorre com um leitor de tela.

Design responsivo e adaptativo mostraram que a estrutura precisa sobreviver à mudança de tamanho da tela. O que muda entre desktop e celular não é apenas o layout: é a quantidade de contexto que cabe simultaneamente, e portanto a estratégia de navegação. Esconder o menu atrás de um ícone resolve espaço e cobra descoberta; a decisão depende de quantas seções existem e de quão frequentes elas são.

A validação apareceu como parte do método, não como etapa final. Testes rápidos — card sorting para construir a estrutura, tree testing para verificar se ela é navegável, teste dos cinco segundos para checar o que a tela comunica de imediato — custam horas, não semanas, e substituem a discussão por opinião. O card sorting com seis a oito pessoas costuma resolver sozinho a maioria dos agrupamentos e isolar exatamente os itens difíceis, que passam a ser o único assunto da reunião.

A documentação garantiu a durabilidade do que foi decidido: mapa de estrutura, dicionário de rótulos com os termos rejeitados, regras de colocação com critério de desempate, e um registro curto de decisões. Desses, os dois do meio são os que continuam valendo depois que o mapa envelhece, porque contêm critério em vez de retrato.

Por fim, os desafios comuns nomearam os padrões de degradação: estrutura que espelha a empresa, crescimento por acúmulo até o menu "Outros", o mesmo conceito com dois nomes, profundidade excessiva e itens que pertencem a dois lugares. Para o último, a saída preferida é um lar canônico com atalhos contextuais, e não a duplicação — que destrói a capacidade de aprender onde as coisas ficam.

O que este capítulo entrega é a ponte entre entender o usuário e desenhar a tela: você agora sabe transformar o que descobriu na pesquisa em uma estrutura navegável, sustentá-la visualmente e verificá-la com quem vai usá-la. É exatamente esse material que o próximo capítulo pega e coloca no papel — o wireframe é a arquitetura de informação ganhando forma espacial.

---
