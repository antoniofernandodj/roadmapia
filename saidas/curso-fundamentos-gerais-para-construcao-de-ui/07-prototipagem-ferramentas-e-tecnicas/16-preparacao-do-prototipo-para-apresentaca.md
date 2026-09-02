## Preparação do protótipo para apresentação e portfólio

O mesmo protótipo serve a três públicos que querem coisas diferentes. O stakeholder quer saber se a proposta resolve o problema do negócio. O time de desenvolvimento quer saber o que exatamente será construído. O recrutador quer saber como você pensa. Entregar a mesma coisa para os três é o motivo mais comum de apresentações que não convencem.

Preparar o protótipo é escolher, para cada público, o que mostrar, em que ordem e com qual narrativa em volta.

### Para o stakeholder: o problema antes da solução

O erro que arruína apresentações internas é começar pela tela. Você abre o protótipo, mostra o novo layout, e a primeira reação é sobre a cor do cabeçalho — porque, sem contexto, é sobre isso que dá para opinar.

A estrutura que funciona tem cinco partes e leva dez minutos:

1. **O problema, com número.** "32% dos pedidos de devolução chegam por telefone porque as pessoas não encontram a opção no site. Cada um custa em média R$ 18 de atendimento."
2. **O que descobrimos.** Duas ou três frases dos usuários, literais. Uma citação vale mais que um gráfico nesta parte.
3. **A proposta, percorrida como história.** Não uma tela de cada vez: a jornada de alguém resolvendo o problema, do começo ao fim.
4. **A evidência.** "Testamos com cinco pessoas: quatro concluíram sem ajuda; na versão atual, nenhuma das cinco concluiu."
5. **O que precisamos decidir hoje.** Uma pergunta específica, não "o que vocês acham?".

O item 5 é o que transforma apresentação em reunião produtiva. Sem uma pergunta declarada, o grupo produz opiniões dispersas e nenhuma decisão, e você sai com uma lista de sugestões contraditórias.

### Para a equipe de desenvolvimento: densidade e limites

Aqui a narrativa importa menos e a completude importa mais. O que essa apresentação precisa ter:

- O fluxo completo, incluindo os caminhos alternativos.
- Os estados: vazio, carregando, erro, sem permissão.
- As anotações de comportamento, condição e limite.
- A lista explícita do que **não** está coberto.
- Acesso ao modo de inspeção, com medidas e tokens.

E uma coisa que costuma ser esquecida: **as prioridades**. Se o prazo apertar, o que pode ficar para depois? Dizer isso na apresentação evita que o corte seja feito por quem está implementando, sem informação para escolher.

### Para o portfólio: o processo, não o resultado

Esta é a diferença mais importante do trecho, e a que mais custa a quem vem do desenvolvimento.

Um portfólio de UX não é uma galeria de telas bonitas. Recrutadores da área declaram, com uma consistência que chega a ser monótona, que avaliam **como você pensa** — e telas finais não mostram pensamento. Mostram gosto.

O que precisa aparecer, em ordem:

**1. O contexto e o problema.** Que produto, que usuários, que restrições, que problema mensurável. Duas frases.

**2. O que você fez para entender.** Quantas entrevistas, que observação, que dados. Aqui entram os artefatos: mapa de jornada, personas, o card sorting.

**3. As alternativas que você considerou.** Este é o item que separa um portfólio júnior forte de um comum. Mostre os três esboços iniciais, incluindo os que foram descartados, e diga por que cada um caiu. Um processo que teve uma única ideia não é um processo.

**4. As iterações, com evidência.** A versão 1, o que o teste revelou, a versão 2, o que mudou. Um antes-e-depois lado a lado, com uma frase explicando a mudança e a observação que a motivou, é a peça mais persuasiva que um portfólio pode ter.

**5. O resultado, com honestidade.** Se houver número, use. Se o projeto não chegou a ser implementado — o que é comum e não desabona —, diga isso e apresente o que foi validado no teste.

**6. O que você faria diferente.** Uma seção curta de reflexão. Demonstra maturidade e é raríssima em portfólios júnior.

### Preparando os arquivos

Alguns cuidados práticos que fazem diferença na percepção:

**Capturas em vez de link vivo, no portfólio.** Links de protótipo quebram, mudam e exigem que o recrutador navegue. Imagens estáticas com legendas contam a história em uma passada. Ofereça o link ao lado, para quem quiser explorar.

**Uma gravação curta do fluxo.** Um GIF ou vídeo de 15 a 30 segundos percorrendo o caminho principal vale mais que dez capturas. Mostra as microinterações e prova que o protótipo funciona.

**Anonimize o que precisa.** Nomes de clientes, dados reais, valores, informação sob acordo de confidencialidade. Substitua por dados fictícios plausíveis — não por "Lorem ipsum", que apaga justamente a variedade que torna o trabalho crível. Se o projeto inteiro é confidencial, descreva o problema em termos genéricos e mostre o processo com dados alterados; isso é prática aceita e comum.

### O erro que você vai cometer: apresentar tela por tela

"Esta é a tela inicial. Aqui em cima temos o menu, com cinco seções. À esquerda, os filtros. No centro, a listagem, que mostra os pedidos ordenados por data. Passando para a próxima tela…"

Vinte minutos depois, a audiência viu doze telas descritas e não sabe qual problema foi resolvido. É uma leitura em voz alta de algo que todos já estão vendo, e não acrescenta nada ao que a imagem mostra.

A correção é narrar **a pessoa**, não a interface:

"A Marina recebeu o tênis no tamanho errado. Ela entra no site já irritada, porque na semana passada tentou isso e desistiu. Aqui, na tela inicial, ela vê os pedidos recentes — e é a primeira vez que a opção de devolver aparece sem precisar procurar. Ela clica, e..."

A diferença é enorme e não custa nada: o mesmo protótipo, a mesma sequência de telas, e uma audiência que acompanha o problema sendo resolvido em vez de uma lista de elementos.

### Exercício prático

**Objetivo:** produzir as três versões da apresentação a partir de um protótipo.

1. **Versão stakeholder:** cinco slides seguindo a estrutura de cinco partes, com a pergunta de decisão explícita no último. Cronometre: dez minutos.
2. **Versão desenvolvimento:** o arquivo organizado com fluxo completo, estados, anotações e a lista de cobertura. Sem slides.
3. **Versão portfólio:** uma página com as seis seções, incluindo pelo menos um antes-e-depois com justificativa e um parágrafo do que você faria diferente.
4. Mostre a versão portfólio a alguém de fora da área e peça que explique, com as próprias palavras, qual era o problema e o que você fez. Se a pessoa não conseguir, a página não está pronta.

### Solução comentada

O passo 4 é implacável e é o único teste que importa. O padrão de falha mais comum: a pessoa consegue descrever **o que você fez** — "você desenhou umas telas de devolução" — mas não **qual era o problema** nem **por que essas telas e não outras**.

Isso acontece porque a maior parte do espaço da página foi ocupada pelas imagens finais, e o texto de contexto ficou reduzido a uma linha. A correção é desproporcional em relação ao esforço: mover o problema para o topo, em uma frase com número, e colocar o antes-e-depois antes da galeria de telas finais. As telas bonitas não desaparecem, apenas param de ser a primeira coisa.

Sobre a seção 3, das alternativas descartadas: existe uma resistência natural a mostrar o que não deu certo, e ela é compreensível e equivocada. Um portfólio que mostra apenas o resultado final sugere uma de duas coisas ao avaliador experiente — ou o processo não existiu, ou está sendo escondido. Mostrar três alternativas e explicar por que duas caíram demonstra critério, que é exatamente a competência que se está avaliando numa contratação júnior. Ninguém espera que um candidato júnior tenha acertado de primeira; espera-se que ele saiba dizer por que escolheu.

Um último ponto sobre o item 5 do portfólio, o resultado. Se o projeto foi um exercício pessoal, sem usuários reais e sem implementação, diga isso claramente e apresente o que foi validado — "testei com cinco pessoas do meu círculo, três das quais correspondem ao perfil". Inflar um projeto de estudo até parecer um caso profissional é detectado com facilidade em entrevista, na primeira pergunta sobre restrições de negócio, e custa mais credibilidade do que a honestidade teria custado.

---
