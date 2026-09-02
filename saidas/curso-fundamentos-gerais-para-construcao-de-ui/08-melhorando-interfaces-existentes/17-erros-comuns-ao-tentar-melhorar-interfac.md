## Erros comuns ao tentar melhorar interfaces

Os métodos deste capítulo funcionam. O que costuma falhar é a aplicação — e as formas de falhar se repetem com tanta regularidade que valem ser nomeadas uma a uma. Reconhecer cada uma custa menos do que aprendê-las por experiência própria, que é o caminho normal e caro.

### 1. Redesenhar em vez de corrigir

O erro que engloba vários outros. A interface parece datada, e a proposta que surge é refazê-la inteira em vez de atacar os problemas identificados. Meses sem entrega, escopo crescente, reaprendizado simultâneo para todos os usuários e impossibilidade de atribuir causa a qualquer melhora ou piora.

**Como reconhecer:** a proposta não deriva de uma lista de problemas diagnosticados; ela deriva do desconforto de olhar para a tela.

**O que fazer:** exigir de si mesmo o diagnóstico antes da proposta. Se o resultado do diagnóstico for uma lista de quinze correções, o redesenho não se justifica. Se for "a arquitetura de informação está estruturalmente errada", talvez se justifique — mas isso é uma conclusão, não um ponto de partida.

### 2. Confundir preferência com problema

A lista de melhorias contém "o azul está saturado demais" ao lado de "as pessoas não conseguem remover o filtro". Misturadas, as duas se contaminam: quem lê percebe que a primeira é questão de gosto e passa a duvidar da segunda.

**Como reconhecer:** você não consegue nomear a consequência para o usuário, ou a consequência que escreve é "fica menos bonito".

**O que fazer:** duas listas separadas. Violações com consequência observável em uma; sugestões estéticas em outra, apresentada em outro momento e com outro peso.

### 3. Corrigir o sintoma sem diagnosticar a causa

"Não achei o botão" vira "vamos aumentar o botão". A correção óbvia é aplicada, e o problema persiste — porque a causa era o rótulo, ou a expectativa, e não o destaque.

**Como reconhecer:** a correção que parecia óbvia falhou, e a reação é aplicar mais da mesma coisa.

**O que fazer:** um teste de cinco minutos separa as causas. Se a pessoa viu o botão mas não sabe o que faz, é rótulo. Se nem procurou, é modelo mental. Se procurou e não achou, aí sim é destaque.

### 4. Otimizar a métrica errada

A regra dos três cliques, a obsessão por reduzir passos, a redução de campos sem verificar se os dados são usados. Cada uma otimiza um número que não corresponde à experiência.

**Como reconhecer:** a meta é expressa em uma contagem — cliques, telas, campos — em vez de em um resultado.

**O que fazer:** medir tempo até a conclusão e taxa de conclusão sem ajuda. Ambas capturam o que importa, e nenhuma premia a compressão artificial.

### 5. Melhorar a estética e piorar o trabalho

Espaçamento generoso, tipografia grande, cards com respiro. A tela fica melhor em qualquer captura, e onde cabiam vinte linhas passam a caber oito.

**Como reconhecer:** a mudança foi avaliada por captura de tela, não pelo volume real de dados e na resolução real dos usuários.

**O que fazer:** contar quantas linhas cabem antes e depois, na resolução mais apertada do parque de máquinas. Densidade é uma troca deliberada, e em sistemas de uso contínuo o usuário quase sempre quer mais, não menos.

### 6. Padronizar o que era diferente de propósito

Na cruzada por consistência, a ação destrutiva ganha o mesmo estilo das demais, e a tela crítica ganha a mesma densidade das normais. Consistência perfeita, informação perdida.

**Como reconhecer:** você unificou sem perguntar se a divergência carregava significado.

**O que fazer:** antes de padronizar, verificar se a diferença é informação. Se for, documentá-la como exceção intencional, com a razão escrita — porque a próxima pessoa a padronizar vai encontrá-la e "corrigir".

### 7. Validar com quem já viu a proposta

Faltam participantes, e o teste é feito com dois colegas de equipe que acompanharam o trabalho. Eles concluem rapidamente e confirmam a melhoria.

**Como reconhecer:** o participante conhece o projeto, ou trabalha na mesma equipe, ou é você.

**O que fazer:** recrutar de fora, mesmo que de outra área da empresa. Não substitui o usuário real, e encontra a maior parte dos problemas de descoberta e rótulo. Declare a limitação ao apresentar.

### 8. Reverter no terceiro dia

A mudança entra, as reclamações chegam, e ela é desligada antes que qualquer usuário tenha reaprendido.

**Como reconhecer:** não existe critério de reversão definido antes da entrega, e a decisão está sendo tomada pelo volume de queixas.

**O que fazer:** definir o critério antes — que número, medido quando. Isso protege a mudança do pânico inicial e protege os usuários de uma mudança ruim defendida por orgulho.

### 9. Remover o que parecia inútil

O campo obrigatório que ninguém preenche direito é removido. Três semanas depois, descobre-se que ele alimentava uma obrigação fiscal.

**Como reconhecer:** você não sabe por que aquilo existe, e assumiu que não havia razão.

**O que fazer:** dez minutos de investigação. Quem consome esse dado? Por que essa confirmação foi adicionada? A resposta costuma existir e ser específica — e quando não existe mais, a remoção passa a ser uma correção bem fundamentada em vez de um risco.

### 10. Manter uma lista paralela

A planilha de melhorias, organizada e priorizada, vive fora do backlog da equipe. Cresce, envelhece, e em seis meses ninguém confia nela.

**Como reconhecer:** o item está em um documento seu, não no sistema onde o trabalho da equipe é priorizado.

**O que fazer:** migrar cada proposta documentada para o backlog real, no formato da equipe, com etiqueta que permita filtrar. A planilha fica só para o diagnóstico em andamento.

### 11. Apresentar a solução sem apresentar o problema

O documento começa com a imagem do novo desenho. A reunião discute cor e posição, porque não foi dado nenhum critério para julgar a proposta.

**Como reconhecer:** cobrindo a parte da proposta, o que sobra não convence ninguém de que há um problema.

**O que fazer:** ordem rígida — problema, evidência, impacto, e só então proposta.

### 12. Melhorar sem impedir a dívida nova

Quinze telas são corrigidas enquanto vinte novas nascem com os mesmos problemas. O trabalho vira enxugar gelo, e a percepção de que "não adianta" se instala.

**Como reconhecer:** não há critério de qualidade na definição de pronto da equipe, nem componente compartilhado.

**O que fazer:** três critérios verificáveis na definição de pronto, e uma biblioteca de componentes. Impedir a dívida nova rende mais, a médio prazo, do que corrigir a existente.

### O erro que costura todos os outros

Se houvesse um só a evitar, seria este: **agir a partir do desconforto em vez do diagnóstico**.

Quase todos os doze acima começam da mesma forma. Você olha uma tela, sente que está ruim, e essa sensação — que costuma estar certa sobre a existência do problema — é tomada como se fosse conhecimento sobre a causa. Daí saem o redesenho sem lista, a correção do sintoma, a preferência disfarçada de achado e a padronização que apaga informação.

O desconforto é um bom detector e um péssimo diagnosticador. A disciplina inteira deste capítulo consiste em usá-lo como gatilho para investigar, e nunca como base para propor.

### Exercício prático

**Objetivo:** auditar o próprio trabalho contra a lista.

1. Pegue a sua lista de melhorias propostas até aqui.
2. Percorra os doze erros e marque, honestamente, em quais você incorreu.
3. Para cada um marcado, identifique o item específico da sua lista afetado.
4. Corrija: separe preferências, refaça diagnósticos apressados, busque a razão do que ia remover, defina o critério de reversão que falta.
5. Conte quantos itens da sua lista sobreviveram sem alteração.

### Solução comentada

O passo 5 costuma produzir um número menor do que se espera, e isso é o exercício funcionando.

Os dois erros mais frequentes em quem está começando são o 2 (preferência disfarçada de problema) e o 3 (corrigir sintoma sem diagnosticar). Juntos, costumam afetar boa parte de uma primeira lista — não por descuido, mas porque ambos exigem uma disciplina que só se adquire depois de ver uma correção "óbvia" falhar.

Vale insistir num ponto sobre o erro 2, porque ele costuma gerar resistência: separar preferências não significa que elas não valham. Um sistema visualmente datado tem custo real — de percepção de qualidade, de confiança, e às vezes de contratação de pessoal. O que não se pode é apresentar essa avaliação como se fosse um achado de usabilidade com a mesma base de evidência de "duas de cinco pessoas não concluíram a tarefa". São duas conversas diferentes, com pesos diferentes, e misturá-las enfraquece a segunda.

Um último comentário sobre a honestidade do passo 2. É tentador marcar poucos itens, e o exercício não rende assim. Uma primeira lista de melhorias feita por alguém em transição para UX quase sempre incorre em pelo menos quatro ou cinco dos doze — a maioria dos quais só se torna visível depois que alguém os nomeia, que é a razão de este trecho existir.

---
