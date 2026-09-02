## Referências para aprofundamento em arquitetura de informação

Arquitetura de informação é uma disciplina com literatura própria, anterior à web e mais rigorosa do que a maioria dos conteúdos que circulam sobre o assunto. A lista abaixo está ordenada por utilidade imediata para quem vem do desenvolvimento — e, ao final, há uma sugestão de como estudar sem transformar isso numa leitura acadêmica que não muda nada no seu trabalho.

### Os livros que sustentam a disciplina

**Louis Rosenfeld, Peter Morville e Jorge Arango — *Information Architecture: For the Web and Beyond* (4ª edição).** É o livro de referência da área, conhecido como "o livro do urso polar". Cobre sistemas de organização, rotulagem, navegação e busca com uma profundidade que nenhum artigo alcança. Não leia de capa a capa: use os capítulos sobre sistemas de rotulagem e sobre taxonomias quando estiver enfrentando exatamente esses problemas. A quarta edição incorpora ecossistemas multicanal, que é o cenário real de quase todo produto hoje.

**Abby Covert — *How to Make Sense of Any Mess*.** O contraponto perfeito ao anterior: curto, prático, quase um caderno de exercícios. Trata da arquitetura de informação como um problema de linguagem antes de ser um problema de estrutura, e o capítulo sobre vocabulário controlado explica, melhor que qualquer outro texto, por que o dicionário de rótulos é o documento que mais economiza discussão. Disponível gratuitamente em inglês no site da autora.

**Donna Spencer — *A Practical Guide to Information Architecture*.** O mais orientado a execução dos três. Traz o passo a passo de card sorting, os formatos de mapa de site que funcionam na prática e conselhos concretos sobre como conduzir as conversas com stakeholders quando a estrutura proposta contraria o organograma. É o livro que você abre na véspera de uma sessão com usuários.

### Sobre organização visual e layout

**Josef Müller-Brockmann — *Grid Systems in Graphic Design*.** Clássico do design gráfico suíço, anterior ao digital, e ainda a explicação mais completa de por que grids funcionam. Se os seus layouts parecem "meio tortos" sem que você saiba dizer por quê, este livro resolve.

**Robin Williams — *Design para quem não é designer*.** Quatro princípios — proximidade, alinhamento, repetição e contraste — explicados com pares de exemplos antes-e-depois. É deliberadamente básico e é o material mais eficiente que existe para quem precisa melhorar layouts rapidamente sem virar designer gráfico.

**Ellen Lupton — *Pensar com tipos*.** A referência de tipografia com tradução para o português. Cobre hierarquia, escalas, entrelinha e composição de texto com exemplos que se aplicam diretamente à interface.

### Consulta contínua e material aplicado

**Nielsen Norman Group — artigos sobre IA e navegação (nngroup.com).** Procure especificamente pelos textos sobre card sorting, tree testing, navegação global versus local e o comportamento de busca dentro de sites. São gratuitos, curtos e baseados em estudos próprios com usuários.

**Optimal Workshop e Maze — documentação dos métodos.** Além de serem ferramentas para rodar card sorting e tree testing, ambas mantêm guias práticos de como planejar as sessões, quantos participantes usar e como ler os resultados. A documentação vale mesmo que você não use a ferramenta paga.

**WAI-ARIA Authoring Practices Guide (W3C).** Para a parte de acessibilidade estrutural: os padrões corretos de menu, árvore, abas e breadcrumb, com o comportamento de teclado esperado em cada um. É a fonte que evita reinventar um componente de navegação inacessível.

**Material Design e Human Interface Guidelines.** Não como dogma, mas como catálogo de convenções documentadas com justificativa. Quando precisar decidir onde colocar a navegação em uma tela pequena, os dois já testaram as alternativas em escala e explicam as razões das escolhas.

### Como transformar isso em prática

Ler sobre arquitetura de informação sem exercitá-la produz vocabulário, não competência. Um ciclo que funciona bem para quem trabalha com desenvolvimento:

1. **Escolha um sistema real** — de preferência um que você mantém e que já mostrou sintomas de estrutura degradada.
2. **Faça o inventário completo** de telas e rótulos antes de qualquer leitura. Ver a lista inteira ordenada alfabeticamente já produz metade das descobertas.
3. **Rode um card sorting** com seis pessoas que usam o sistema. Custa uma tarde e vale mais que três capítulos lidos.
4. **Leia o capítulo específico** do livro do urso polar sobre o problema que o card sorting revelou — rotulagem, se os nomes confundiram; organização, se os agrupamentos divergiram.
5. **Documente a decisão** no formato mínimo que você já conhece, e proponha a mudança com o dado do card sorting em mãos.

Esse ciclo tem um efeito colateral valioso: ele produz, quase de graça, um estudo de caso completo — problema identificado, método aplicado, evidência coletada, decisão tomada e justificada. É exatamente o formato que o capítulo sobre portfólio vai pedir mais adiante, e escrevê-lo enquanto o trabalho acontece custa uma fração do esforço de reconstruí-lo meses depois.

---
