## Boas práticas para prototipagem eficaz

Depois de construir alguns protótipos, o que separa os que rendem dos que consomem tempo não são técnicas novas — são hábitos. Este trecho reúne as práticas que sobrevivem ao uso real, organizadas pelo momento em que se aplicam, com o critério por trás de cada uma.

### Antes de abrir a ferramenta

**Escreva a pergunta.** Uma frase, no topo do arquivo: "Este protótipo existe para descobrir se ______". Se você não consegue completar a frase, ainda não sabe o que vai construir. E se a resposta for "para mostrar como vai ficar", não é um protótipo, é uma apresentação — o que é legítimo, mas exige decisões diferentes.

**Decida a fidelidade a partir da pergunta.** Estrutura e sequência: baixa. Leitura, densidade e preenchimento: média. Percepção visual e microinterações: alta. Escolher fidelidade alta por padrão é o desperdício mais comum da prática.

**Defina o escopo em número de telas.** "Oito frames" é um compromisso verificável; "o fluxo de compra" não é. O escopo aberto é o que transforma duas horas em dois dias.

**Converse com quem vai implementar.** Quinze minutos com os wireframes na mão, antes de prototipar. Restrições técnicas descobertas agora são premissas de projeto; descobertas depois, são retrabalho.

### Durante a construção

**Use dados reais desde o primeiro frame.** Nomes longos, valores negativos, listas vazias, datas antigas. Texto de preenchimento esconde exatamente os problemas que o protótipo deveria revelar.

**Componentize a partir da terceira repetição.** Antes disso, o custo não se paga. Depois disso, cada duplicação cobra juros.

**Nomeie as camadas enquanto trabalha.** Além da organização, é requisito técnico: o `Smart Animate` depende de nomes iguais entre frames, e uma camada `Rectangle 47` quebra a animação sem avisar.

**Trabalhe com uma escala de espaçamento.** Múltiplos de 4 ou 8, e nada fora disso. Elimina metade das decisões de posicionamento e evita os onze cinzas e os sete espaçamentos que aparecem quando tudo é arrastado no olho.

**Desenhe os estados junto com a tela.** No momento em que você faz a listagem, faça também a listagem vazia. Depois, você não volta — e o estado vazio é o que mais falta na implementação.

**Anote enquanto pensa.** A condição que desabilita o botão está clara na sua cabeça no instante em que você desenha o botão desabilitado. Uma semana depois, custa quatro vezes mais para reconstruir.

**Separe página de trabalho e página de apresentação.** Cinco minutos de organização que evitam expor rascunho a stakeholder.

### Ao testar

**Escreva a tarefa como situação, sem palavras da interface.** "Você recebeu o produto errado, resolva isso" testa o desenho; "encontre a opção de devolução" testa a sua capacidade de dar instruções.

**Fique calado.** Conte até vinte antes de intervir. A resposta que vem depois do silêncio é o dado.

**Anote comportamento, não opinião.** Onde clicou primeiro, onde hesitou, o que disse ao hesitar, se concluiu sem ajuda. Sugestões de solução do participante são sintomas, não especificações.

**Cinco pessoas agora valem mais que vinte depois.** O retorno por participante cai rápido; o retorno de testar antes de implementar não.

**Teste no dispositivo certo.** Protótipo mobile testado com mouse em monitor não revela alvo pequeno, texto ilegível nem polegar cobrindo o conteúdo.

### Ao iterar

**Diagnostique antes de corrigir.** "Não achei o botão" pode ser posição, rótulo ou expectativa — e as três correções são diferentes. Se a correção óbvia falhou duas vezes, o diagnóstico está errado.

**No máximo cinco mudanças por rodada.** Mais que isso e você perde a capacidade de atribuir causa.

**Salve versão nomeada antes de alterar.** `v3 — apresentado ao comercial 12/03`. Dez segundos que resolvem a arqueologia de dois meses depois.

**Anote o porquê de cada mudança.** É o material que o portfólio vai pedir, produzido de graça.

### Ao entregar

**Declare o que o protótipo não cobre.** Uma lista de cinco linhas transforma "será que isso está previsto?" em "isto não foi coberto, vou perguntar".

**Documente em blocos verificáveis**, não em prosa: interações com condição, dados, estados, limites, permissões.

**Faça a entrega em conversa, não por link.** Trinta minutos percorrendo junto encontram mais ambiguidade que três dias de arquivo parado.

**Revise a implementação lado a lado**, e reporte apenas o que muda o que a pessoa consegue fazer, entender ou perceber.

### O erro que você vai cometer: prototipar mais do que o problema pede

Este é o erro que engloba quase todos os outros, e ele tem uma característica traiçoeira: não parece um erro enquanto acontece. Prototipar é agradável, o arquivo vai ficando bonito, cada estado adicionado parece uma melhoria. O problema só aparece na conta final, quando o esforço de prototipagem se aproxima do esforço de implementar — e nesse ponto o protótipo perdeu a razão de existir.

Três sinais de que isso está acontecendo:

1. Você está prototipando um caminho sobre o qual **não tem dúvida**.
2. Você está refinando o visual de uma alternativa que ainda pode ser descartada.
3. Você levou mais tempo mantendo o arquivo do que teria levado alterando o código.

O contrapeso é uma pergunta feita a cada meia hora: *qual pergunta este frame que estou desenhando agora responde?* Se a resposta for "nenhuma, mas ficaria incompleto sem ele", pare. Protótipo incompleto é a condição normal de um protótipo.

### Exercício prático

**Objetivo:** aplicar a lista como checklist em um protótipo real, do início ao fim.

1. Escolha um problema pequeno e real de um sistema que você conhece.
2. Antes de abrir a ferramenta: escreva a pergunta, defina a fidelidade e fixe o escopo em número de frames.
3. Construa dentro do escopo definido, com dados reais, escala de espaçamento e estados desenhados junto.
4. Teste com três pessoas, com tarefa escrita como situação.
5. Itere uma vez, com no máximo três mudanças, salvando versão antes.
6. Ao final, responda: quantas horas custou? Qual foi a estimativa de implementação da mesma coisa? A proporção justificou o protótipo?

### Solução comentada

O passo 6 é o único item da lista que raramente é feito, e é o que constrói julgamento.

A proporção saudável, em média, fica em torno de um para cinco ou um para dez — um protótipo de três horas para uma implementação de três a cinco dias. Quando a proporção se aproxima de um para um, prototipar foi desperdício: a mesma dúvida teria sido resolvida implementando atrás de uma flag e observando o uso real, com a vantagem de gerar dado de produção em vez de dado de laboratório.

Quando a proporção é de um para vinte ou mais — um dia de protótipo para dois meses de implementação —, o protótipo provavelmente ficou **curto demais**. Numa obra desse tamanho, valeria testar mais alternativas, com mais pessoas, antes de comprometer dois meses de equipe.

Vale também olhar o passo 2 em retrospecto: o escopo em frames foi respeitado? Na primeira vez, quase nunca é — o número final costuma ser o dobro do estimado, e a diferença inteira está em estados de exceção que não foram contados. Isso não é falha de disciplina; é a mesma dificuldade de estimativa que existe em desenvolvimento, e pela mesma razão. A diferença é que aqui ela custa horas, e não semanas — o que é, no fundo, o argumento inteiro a favor de prototipar.

---
