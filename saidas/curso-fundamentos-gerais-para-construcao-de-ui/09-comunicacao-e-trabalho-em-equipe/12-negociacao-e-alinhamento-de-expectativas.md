## Negociação e alinhamento de expectativas

Metade dos conflitos em projetos de interface não é sobre design. É sobre expectativas que nunca foram declaradas: o gestor achava que a entrega incluía as telas de administração; o desenvolvedor achava que o protótipo era a especificação completa; o cliente achava que "protótipo" significava algo funcionando.

Nenhuma dessas pessoas foi desonesta. Cada uma preencheu um silêncio com a suposição mais natural para ela — e as suposições naturais de perfis diferentes divergem.

### O que precisa ser declarado antes de começar

Cinco itens. Declará-los custa dez minutos e evita a maior parte das fricções posteriores:

**1. O que está no escopo, e o que explicitamente não está.** O segundo é mais importante que o primeiro. "Este trabalho cobre o fluxo de devolução, telas 1 a 6. Não cobre o painel administrativo, o e-mail de confirmação nem a versão mobile."

**2. O que será entregue, em que formato.** Wireframes? Protótipo navegável? Especificação escrita? Telas prontas para implementação? Cada um significa uma quantidade de trabalho muito diferente, e as palavras são usadas de forma intercambiável por quem não trabalha na área.

**3. Quantas rodadas de revisão.** Sem esse número, revisões são infinitas por construção — sempre há mais um ajuste. "Duas rodadas de retorno; a partir da terceira, tratamos como escopo novo" não é rigidez, é a condição para que o trabalho termine.

**4. Quem decide.** Não quem opina — quem decide. Se três pessoas podem vetar e nenhuma pode aprovar, o trabalho não avança.

**5. Qual é o critério de pronto.** "Aprovado por quem decide, com a documentação de comportamento entregue e a estimativa acordada com a engenharia."

### Negociar escopo em vez de qualidade

Quando o prazo aperta — e ele aperta —, há três variáveis que podem ceder: escopo, prazo e qualidade. A terceira é a que cede por omissão, quando ninguém negocia as duas primeiras. E ela cede sempre nos mesmos lugares: os estados de erro, o estado vazio, o foco de teclado, o teste com usuário.

O que evita isso é apresentar o corte como uma escolha, com as opções nomeadas:

> "Nas duas semanas que temos, dá para fazer o fluxo completo com os estados principais, ou os três primeiros passos com todos os estados e acessibilidade. Não dá para fazer os dois. Qual prefere?"

Duas coisas acontecem com essa formulação. A decisão de cortar passa a ser explícita e de quem tem o mandato — e o que foi cortado fica registrado, o que permite retomá-lo depois em vez de ele simplesmente não existir.

O contrário — aceitar o prazo e entregar tudo pela metade — produz um resultado pior e ainda transfere a culpa para você quando os estados faltantes aparecerem em produção.

### A frase que resolve a maioria das negociações

> **"O que precisaria ser verdade para isso ser possível?"**

Ela transforma uma recusa em uma condição. As respostas costumam ser específicas: "se não precisasse ser em tempo real, cai para dois dias"; "se entrasse depois do fechamento, dá"; "se o consentimento for coletado no cadastro, o campo sai da tela".

Cada uma dessas é uma alternativa que você não teria formulado sozinho, porque depende de conhecimento da outra pessoa. É por isso que a pergunta rende mais que qualquer argumento.

### Quando a expectativa já divergiu

Nem sempre dá para prevenir. Quando você descobre, no meio do caminho, que o outro lado esperava algo diferente, três passos:

**1. Nomeie a divergência sem atribuir culpa.** "Percebi que estamos com expectativas diferentes sobre o que entra nesta entrega — vamos alinhar antes de seguir."

**2. Estabeleça o estado atual com fatos.** O que já foi feito, quanto tempo resta, o que é possível no prazo.

**3. Ofereça opções, não uma explicação.** "Podemos: (a) entregar o combinado no prazo e tratar o resto como próxima fase; (b) incluir o que falta e mover a entrega em duas semanas; (c) reduzir a profundidade e entregar tudo, sem estados de exceção." Cada opção com o custo real.

O passo 3 é o que muda a conversa. Explicar por que houve divergência gera defesa; apresentar opções coloca a decisão onde ela pertence.

### O erro que você vai cometer: aceitar o prazo para evitar o desconforto

O pedido chega: "dá para ter isso pronto na sexta?". Você olha, sabe que não dá, e diz que dá — porque negar parece pouco colaborativo, porque talvez dê se tudo correr bem, porque a conversa seria desconfortável agora.

O desconforto não desaparece; ele é transferido para a sexta-feira, multiplicado, e agora com a sua credibilidade envolvida. E o custo maior não é esse: é que a organização passa a planejar com base em uma capacidade que não existe, e todo o resto do cronograma herda o erro.

A resposta que funciona não é "não dá". É a contraoferta com números:

> "Na sexta dá para ter o fluxo principal navegável, sem estados de erro e sem teste com usuário. Com os estados e um teste rápido, quarta da semana seguinte. Qual das duas serve melhor?"

Isso preserva a colaboração — você está oferecendo algo para sexta — e transfere a decisão sobre o trade-off para quem tem o mandato de fazê-la, com a informação necessária.

Vale reconhecer por que isso é difícil na prática: para quem está começando na área, ou em transição, dizer não parece arriscado. O que reduz o risco é a forma — nunca negar sem oferecer alternativa, e nunca prometer o que depende de tudo dar certo. Uma pessoa que entrega o que prometeu, consistentemente, acumula mais espaço para negociar do que uma que promete tudo e cumpre parte.

### Exercício prático

**Objetivo:** aplicar alinhamento de expectativas a um trabalho em andamento.

1. Escolha um trabalho seu em curso.
2. Escreva os cinco itens de escopo — incluindo, com atenção, o que **não** está incluído.
3. Envie isso, em cinco linhas, a quem pediu o trabalho, pedindo confirmação.
4. Registre as divergências que aparecerem na resposta. Provavelmente haverá pelo menos uma.
5. Para a divergência mais significativa, formule três opções com custo real, no formato (a)/(b)/(c).
6. Escreva também a sua contraoferta padrão para o próximo pedido com prazo apertado.

### Solução comentada

O passo 4 quase sempre produz divergência, e ela costuma estar no item 2 — **o formato da entrega**.

O padrão é conhecido: você entendeu que entregaria wireframes; quem pediu esperava telas prontas para implementação, com visual definido. As duas coisas diferem em semanas de trabalho, e ambas foram chamadas de "o design da tela" na conversa inicial. Ninguém errou; a palavra é ambígua e cada lado a preencheu com o significado da própria disciplina.

Descobrir isso na primeira semana custa uma conversa de dez minutos. Descobrir na entrega custa a entrega inteira, mais a confiança.

A prevenção é mais fácil do que parece: substituir o nome do artefato pela descrição do que ele contém. Em vez de "vou entregar wireframes", escreva "vou entregar seis telas em cinza, mostrando quais elementos existem e a hierarquia entre eles, sem cores nem tipografia final, com anotações de comportamento". Ninguém consegue interpretar isso de duas maneiras.

O passo 3, pedir confirmação por escrito, gera algum desconforto na primeira vez — parece formal demais para uma equipe que conversa o dia inteiro. Vale reformular o tom sem perder a função: "só para eu confirmar que entendi certo, o que vou entregar é isso aqui; me avisa se estiver diferente do que você espera". É colaborativo e cumpre exatamente o mesmo papel — deixar a expectativa registrada onde os dois lados podem consultá-la.

---
