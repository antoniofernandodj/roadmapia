## Resumo dos conceitos e técnicas de prototipagem

Este capítulo tratou da etapa em que o desenho para de ser estático e passa a ser experimentável. O que muda com isso não é a estética do trabalho — é a natureza das perguntas que podem ser respondidas antes de escrever código.

O ponto de partida foi a distinção entre protótipo e wireframe. O wireframe responde "o que existe nesta tela"; o protótipo responde "o que acontece quando eu faço isto". A finalidade de um protótipo é reduzir incerteza por unidade de esforço, e o critério de qualidade dele não é o acabamento, é quanta dúvida ele elimina.

Os níveis de fidelidade organizaram a escolha do meio. Baixa fidelidade para explorar estrutura e sequência, quando o objetivo é descartar alternativas rapidamente. Média para questões de leitura, densidade e preenchimento. Alta para percepção visual e microinterações. A regra que atravessa tudo: o nível de acabamento determina o tipo de feedback que você recebe, e um protótipo polido demais desvia a conversa para cor e alinhamento quando a dúvida era de estrutura.

Lunacy e Figma foram comparadas pelo que cada uma resolve — a primeira local, rápida e com interatividade básica; a segunda colaborativa, com variantes, animação e compartilhamento por link. A conclusão foi deliberadamente modesta: a ferramenta é a decisão menos importante do capítulo.

A criação de interações revelou o modelo mental que governa toda ferramenta de prototipagem: não há estado, não há variável, não há condicional. Existe uma máquina de estados desenhada à mão, em que cada estado é uma tela e cada interação é uma aresta. Aceitar isso é o que permite trabalhar rápido; esquecê-lo é o que leva a arquivos com quarenta frames e nenhuma pergunta respondida. Sobre essa base vieram as três operações fundamentais — navegar entre telas, abrir sobreposições e trocar variantes de componente — e o limite honesto de que o protótipo simula a aparência da validação, não a validação.

Os fluxos de navegação trouxeram a disciplina de pensar o conjunto antes das ligações: escrever o percurso em texto, com todas as saídas de cada tela, expõe becos sem saída, estados órfãos e ciclos sem progresso antes que eles apareçam numa sessão de teste. Componentes reutilizáveis deram a economia de manutenção e, com as variantes, o realismo dos estados — hover, foco, erro — a custo quase zero por tela. O paralelo com funções em código vale inteiro, inclusive no risco: uma abstração errada engessa tanto quanto uma assinatura errada.

Os testes rápidos foram o momento em que o esforço se paga ou não. Cinco pessoas, uma de cada vez, tarefa escrita como situação e não como instrução, e a disciplina de ficar calado. Anota-se comportamento — onde clicou primeiro, onde hesitou, se concluiu sem ajuda — e não opinião, porque as pessoas são péssimas em prever o próprio comportamento e boas em relatar o que acabaram de fazer. Sugestões de solução vindas do participante são sintomas, não especificações.

As particularidades de plataforma mostraram que a mesma arquitetura exige decisões diferentes conforme o meio. Desktop pede densidade, hover, foco de teclado, atalhos e tabelas com dados reais e variados. Mobile pede alvos de 44 a 48 pontos, atenção à zona do polegar, gestos que nunca são o único caminho para uma ação, e o frame com o teclado aberto — que é onde o botão de salvar costuma desaparecer. Web pede pontos de quebra derivados do conteúdo, estados que só o navegador produz, e a disciplina de desenhar as quatro versões de cada componente: vazio, mínimo, típico e extremo.

Feedback visual e microinterações deram o vocabulário do que acontece entre as telas: os estados que todo elemento interativo precisa ter, as durações que funcionam — 50 a 100 ms para mudança de estado, 200 a 300 ms para transição de tela — e o achado que costuma surpreender: uma versão com mais tempo real de espera pode ser percebida como mais rápida, porque tempo informado não é tempo vazio.

Compartilhamento, documentação e integração trataram do que acontece depois que o protótipo funciona. Link certo para o público certo, com uma mensagem que declara o que já está decidido e o que se pede de retorno. Documentação em blocos verificáveis — interações com condição, dados, estados, limites, permissões — escrita durante a construção e não depois, porque a mesma frase custa quatro vezes mais uma semana adiante. E a entrega ao desenvolvimento como conversa em três momentos, não como bastão passado, com tokens nomeados igual dos dois lados e uma revisão visual que reporta apenas o que muda o que a pessoa consegue fazer.

A iteração fechou o ciclo com o passo que quase todos pulam: diagnosticar antes de corrigir. Uma observação é sintoma, e a correção óbvia que falha duas vezes indica diagnóstico errado, não correção insuficiente. Limite de três a cinco mudanças por rodada, versão nomeada antes de alterar, mesma tarefa no reteste.

As limitações foram nomeadas sem eufemismo, porque é delas que vêm as decisões erradas mais caras: o protótipo não sabe nada sobre desempenho, volume real de dados, uso continuado, aprendizado ao longo do tempo, contexto real e integrações. Ele responde muito bem a perguntas de estrutura, sequência, rótulo, descoberta e compreensão — e quase nada além disso. Saber declarar essa fronteira é o que dá credibilidade ao trabalho.

Os casos práticos e as boas práticas convergiram em um único critério, que é o que você leva deste capítulo: prototipe proporcionalmente ao problema. A pergunta vem antes do arquivo, a fidelidade vem da pergunta, o escopo é um número de frames, e o protótipo termina quando a pergunta foi respondida — não quando as telas ficaram bonitas.

O próximo capítulo aplica tudo isso a um contexto diferente e muito mais comum na vida profissional: interfaces que já existem, já têm usuários e já não podem ser redesenhadas do zero.

---
