## Testes rápidos com protótipos

O protótipo está pronto e navegável. A pergunta que resta é a única que importa: ele funciona para outra pessoa? E a resposta não sai de mais uma rodada de opinião interna — sai de colocar o protótipo na frente de cinco pessoas que não o construíram, uma de cada vez, e ficar quieto enquanto elas tentam usá-lo.

Este é o momento em que o esforço de prototipagem se paga ou não. Um protótipo que nunca é testado por alguém de fora é apenas um desenho caro.

### Por que cinco pessoas, e por que uma de cada vez

A pesquisa clássica de usabilidade mostra que os primeiros participantes revelam a maioria dos problemas graves, e que o retorno por participante adicional cai rapidamente — cerca de cinco pessoas costumam expor a maior parte dos problemas de um fluxo específico. Isso não significa que cinco é um número mágico: significa que **cinco testes agora valem infinitamente mais que vinte testes daqui a três meses**.

E uma de cada vez porque o objetivo não é medir, é entender. Em grupo, as pessoas concordam entre si, a mais falante domina, e ninguém admite que não entendeu.

### O roteiro mínimo de uma sessão de 20 minutos

**1. Enquadramento (2 minutos).** Diga três coisas, sempre:

> "Isto é um protótipo, nem tudo funciona. Estamos testando o desenho, não você — se algo der errado, o problema é nosso. E eu vou te pedir para pensar em voz alta enquanto usa."

A segunda frase não é gentileza: sem ela, a pessoa esconde as dificuldades para não parecer incompetente, e o dado se perde.

**2. Contexto e tarefa (1 minuto).** Dê uma situação, não uma instrução. Compare:

> ❌ "Clique em Pedidos e depois em Devoluções."
> ❌ "Encontre a opção de devolução."
> ✅ "Você comprou um par de tênis e ele veio no tamanho errado. Resolva isso."

A primeira testa a sua capacidade de dar instruções. A segunda entrega o vocabulário da interface de bandeja — se o menu se chama "Devoluções", você acabou de dar a resposta. A terceira testa se a pessoa encontra o caminho partindo do problema dela, que é o que acontece na vida real.

**3. Observação (12 a 15 minutos).** Aqui a sua única função é ficar calado. Quando a pessoa travar e olhar para você, devolva a pergunta:

> "O que você acha que aconteceria se clicasse aí?"
> "O que você esperava encontrar nessa tela?"

**4. Fechamento (3 minutos).** Uma pergunta aberta — "o que mais te incomodou?" — e uma específica sobre o momento em que ela hesitou mais.

### O que anotar

Não anote opiniões. Anote comportamento observável, que é o que sustenta uma decisão:

| Anote | Não anote |
|---|---|
| Onde clicou primeiro, em cada tela | "Achou bonito" |
| Quanto tempo até a primeira ação | "Disse que gostou do layout" |
| Onde hesitou (pausa maior que 3 segundos) | "Sugeriu colocar o botão em cima" |
| O que disse em voz alta ao hesitar | "Acha que os usuários vão preferir azul" |
| Se concluiu a tarefa sem ajuda | |
| A palavra que usou para nomear a coisa | |

A coluna da direita não é inútil, mas é a menos confiável: as pessoas são péssimas em prever o próprio comportamento e ótimas em relatar o que acabaram de fazer. Sugestões de solução vindas do participante devem ser tratadas como **sintomas**, não como especificações. Quando alguém diz "esse botão devia ser vermelho", o dado real é "não encontrei o botão", e vermelho é apenas a primeira solução que ocorreu a essa pessoa.

### O erro que você vai cometer: socorrer o participante

A cena é inevitável na primeira sessão. A pessoa está há 40 segundos procurando algo que está bem ali. O silêncio fica insuportável. Você diz: "está no menu de cima, à direita".

O que se perdeu naquele instante: você não vai descobrir se ela encontraria sozinha, quanto tempo levaria, ou por qual caminho alternativo tentaria. E, pior, você acabou de ensinar a ela que basta esperar que a resposta vem — as tarefas seguintes ficam contaminadas.

A regra prática é contar até vinte, em silêncio, antes de qualquer intervenção. Se depois disso ela continuar travada, a intervenção correta não é apontar a resposta, é escalonar:

1. "O que você está procurando agora?"
2. "Onde você imaginava que isso estaria?"
3. "Se estivesse em casa, sem ninguém aqui, o que você faria?"
4. Só então: "vou te mostrar onde está, e queria entender por que não pareceu óbvio".

A resposta ao passo 3 é frequentemente "eu desistiria e ligaria para o suporte" — um dado valiosíssimo que a intervenção precoce teria apagado.

### Testes ainda mais rápidos

Nem todo teste precisa de 20 minutos. Três formatos que cabem em uma pausa para o café:

**Teste dos cinco segundos.** Mostre uma tela por cinco segundos, esconda, e pergunte: o que é isto? o que se pode fazer aqui? o que mais chamou atenção? Testa hierarquia visual e clareza da proposta, e três participantes já indicam se a tela comunica.

**Teste do primeiro clique.** Mostre uma tela estática e uma tarefa. Pergunte apenas onde a pessoa clicaria primeiro. Existe correlação forte entre acertar o primeiro clique e concluir a tarefa: se o primeiro passo está errado, o resto quase sempre desanda.

**Corredor.** Pegue quem estiver disponível na empresa — do financeiro, do comercial, qualquer um que não tenha trabalhado neste fluxo — e peça cinco minutos. Não substitui usuário real, mas encontra os problemas grosseiros antes de gastar o tempo de um participante de verdade.

### Exercício prático

**Objetivo:** conduzir três sessões e transformar o observado em decisões.

1. Escolha o protótipo que você vem construindo e defina **uma** tarefa realista, escrita como situação, sem usar nenhuma palavra que apareça na interface.
2. Recrute três pessoas que não participaram do projeto.
3. Conduza as sessões separadamente, seguindo o roteiro de quatro etapas. Cronometre o tempo até a primeira ação em cada tela e anote toda hesitação maior que três segundos.
4. Monte uma tabela: linhas são os problemas observados, colunas são os participantes, e cada célula marca se aquele participante enfrentou aquele problema.
5. Para cada problema que atingiu dois ou mais participantes, escreva uma frase de causa provável e uma de correção proposta.

### Solução comentada

A tabela do passo 4 é o instrumento que separa uma sessão de teste de uma conversa agradável. Ela produz três categorias, e cada uma pede um tratamento diferente.

**Problemas que atingiram os três participantes** são problemas de design, ponto final. Não precisam de mais evidência, não precisam de discussão. Corrija.

**Problemas que atingiram dois** são fortes candidatos, mas vale entender o terceiro caso: por que aquela pessoa não travou? Frequentemente a resposta é que ela tinha experiência prévia com um sistema parecido — o que significa que o problema atinge usuários novos e some para os veteranos. Isso muda a prioridade dependendo de quem é o seu público.

**Problemas que atingiram um** são o campo minado. A tentação é descartá-los como caso isolado, e às vezes é isso mesmo. Mas a pergunta certa não é "quantos enfrentaram", é "qual foi a gravidade". Um único participante que **não conseguiu concluir a tarefa** vale mais atenção que três que hesitaram e seguiram. Combine frequência com severidade antes de decidir.

Um último ponto, sobre o passo 1. Escrever a tarefa sem usar palavras da interface é mais difícil do que parece, e a dificuldade é informativa: se você não consegue descrever a situação sem usar o rótulo do menu, é provável que o rótulo esteja no vocabulário do sistema e não no do usuário. Nesse caso, o teste já começou a dar resultado antes de a primeira sessão acontecer.

---
