## Acessibilidade cognitiva básica

Acessibilidade, para a maioria dos desenvolvedores, é uma lista de coisas técnicas: contraste de cor, atributos `alt`, navegação por teclado, rótulos de formulário. Tudo isso é real e necessário — e cobre principalmente barreiras sensoriais e motoras. Falta uma categoria inteira, que atinge muito mais gente e quase nunca aparece nos checklists: as barreiras **cognitivas**.

Elas afetam quem tem dislexia, TDAH, transtornos de ansiedade, autismo, comprometimento de memória por idade, e também qualquer pessoa em condições ruins — cansada, apressada, num idioma que não é o seu, num ônibus em movimento, lendo com uma criança no colo. É por isso que este é o tipo de acessibilidade com o melhor retorno: as correções que ajudam quem tem dislexia melhoram a tela para todo mundo, sempre.

### O que está sendo sobrecarregado

Você já viu que a memória de trabalho é curta e que a carga cognitiva se divide entre a intrínseca (a dificuldade real da tarefa) e a estranha (a dificuldade que a interface inventou). Acessibilidade cognitiva é, essencialmente, uma disciplina de eliminação sistemática da carga estranha, com atenção especial a quatro capacidades que variam muito entre pessoas:

- **Memória de trabalho** — quantos itens a pessoa consegue sustentar enquanto age.
- **Atenção sustentada** — por quanto tempo consegue manter o foco sem se perder.
- **Processamento de linguagem** — quanto esforço custa decodificar uma frase.
- **Velocidade de processamento** — quanto tempo leva para transformar o que viu em decisão.

Uma interface que exige as quatro no talo funciona bem para o desenvolvedor que a construiu, em silêncio, com contexto completo, e falha para quase todo o resto.

### Seis práticas com efeito imediato

**1. Uma tarefa por tela, um objetivo por bloco.** Formulários longos divididos em etapas curtas, com progresso visível, reduzem abandono de forma consistente. O ganho não é estético: cada etapa fecha um ciclo de memória de trabalho, e a pessoa não precisa mais sustentar o que já preencheu.

**2. Nunca exija que a pessoa carregue informação entre telas.** O caso clássico: a tela A mostra um código de confirmação, e a tela B pede que ele seja digitado. Isso transforma uma tarefa trivial num teste de memória. A correção é levar o dado junto — repetir o código na tela B, ou preenchê-lo automaticamente.

**3. Escreva em linguagem simples, e isso é medível.** Frases de até 20 palavras. Voz ativa. Uma ideia por frase. Termos técnicos apenas quando forem o vocabulário real do usuário. Compare:

> *Antes:* "A não confirmação do endereço de e-mail cadastrado no prazo de 48 horas implicará no cancelamento automático da solicitação."
>
> *Depois:* "Confirme seu e-mail em até 48 horas. Se não confirmar, cancelamos o pedido."

O segundo texto tem menos palavras, mas o ganho principal não é o tamanho: é que a ação vem primeiro e o sujeito de cada frase é claro.

**4. Torne o erro barato e reversível.** Ansiedade consome memória de trabalho. Uma pessoa que teme apagar algo irreversivelmente relê tudo três vezes e ainda assim erra mais, porque parte da sua capacidade está sendo gasta com o medo. Desfazer disponível é uma medida de acessibilidade cognitiva, não só de usabilidade.

**5. Dê tempo, ou avise antes de tirá-lo.** Sessões que expiram sem aviso, carrosséis que trocam sozinhos, notificações que somem em três segundos: todos punem quem lê devagar. A regra prática é que qualquer conteúdo que desaparece sozinho precisa ter um jeito de ser pausado ou reaberto.

**6. Seja previsível.** Mesma ação, mesmo lugar, mesmo nome, em todas as telas. Mudança de contexto sem aviso — um `select` que navega ao ser alterado, um clique que abre uma aba nova sem indicação — é especialmente cara para quem tem dificuldade de atenção, porque exige reconstruir o modelo mental do zero.

### Tipografia como acessibilidade

Algumas decisões tipográficas deixam de ser preferência estética quando se olha para dislexia:

| Decisão | Por quê |
|---|---|
| Alinhamento à esquerda, nunca justificado | Texto justificado cria "rios" de espaço irregular que dificultam o rastreio da linha |
| Entrelinha de 1,5 no corpo de texto | Reduz a chance de o olho pular ou repetir a linha |
| Linhas de 45 a 75 caracteres | Linhas longas fazem perder o ponto de retorno à esquerda |
| Evitar TEXTO TODO EM MAIÚSCULAS | Remove o contorno das palavras, que é parte do reconhecimento rápido |
| Contraste alto, mas não máximo | Preto puro sobre branco puro aumenta o cintilamento percebido para alguns leitores; #1a1a1a sobre #fafafa é mais confortável |

### O erro que você vai cometer: confiar no ícone sozinho

Uma barra de ferramentas de dez ícones, sem rótulos, com tooltips que só aparecem depois de meio segundo de repouso do mouse. Em desktop, é o padrão de mil aplicações. O que se vê em teste com usuários novos: eles passam o mouse por todos os ícones, um a um, lendo os tooltips, e depois **esquecem** — na sessão seguinte repetem a varredura inteira.

O problema é que ícone sem rótulo troca reconhecimento por recordação. Um ícone convencional (lupa, impressora, disquete) funciona porque é aprendido culturalmente; qualquer ícone específico do seu domínio não é convencional, por definição. Para quem tem dificuldade de memória ou está usando o sistema pela primeira vez, cada ícone é um enigma.

A correção não é remover os ícones — é colocar o rótulo ao lado, ou embaixo, em texto permanente. Se não couber, o problema é de quantidade de ações na barra, não de espaço. E em telas de toque, o tooltip simplesmente não existe: não há estado de repouso do dedo.

### Exercício prático

**Objetivo:** aplicar uma revisão cognitiva a um fluxo existente.

Escolha um fluxo de três a cinco telas de um sistema que você conheça (cadastro, checkout, abertura de chamado). Percorra-o respondendo, para cada tela:

1. Quantas coisas a pessoa precisa lembrar da tela anterior para agir nesta? (Meta: zero.)
2. Qual é a frase mais longa da tela? Reescreva-a com metade das palavras sem perder informação.
3. Existe alguma ação irreversível? Ela tem desfazer, ou pelo menos uma confirmação que diz o que exatamente vai acontecer?
4. Existe algum elemento que desaparece ou muda sozinho? Ele pode ser pausado ou recuperado?
5. Existe algum ícone sem rótulo? Mostre-o isolado para alguém que não usa o sistema e peça que adivinhe a função.

Reescreva a tela com o pior resultado.

### Solução comentada

O item 1 costuma ser o mais revelador, e a resposta quase nunca é zero. O caso mais frequente não é um código de confirmação — é um **número de referência** (protocolo, pedido, nota) que aparece numa tela e é pedido em outra, ou uma escolha feita no passo 2 que muda o significado dos campos do passo 4 sem que o passo 4 relembre qual foi a escolha. A correção é sempre a mesma e é barata: exibir o dado no lugar onde ele é necessário. Custa uma linha de template e elimina uma exigência de memória.

No item 5, o padrão de resposta é interessante: ícones de ações genéricas (salvar, imprimir, buscar) são acertados por quase todos; ícones de ações do domínio (aprovar, conciliar, homologar, arquivar) são acertados por quase ninguém, e frequentemente confundidos entre si. Isso dá um critério objetivo para decidir onde o rótulo é obrigatório — não é uma questão de gosto, é uma taxa de acerto que você acabou de medir.

Por fim, vale notar o que essa revisão **não** faz: ela não deixa a interface mais simples do que o problema. Uma tarefa genuinamente complexa continua exigindo esforço — essa é a carga intrínseca, e reduzi-la significaria remover função. O alvo aqui é a carga estranha: tudo o que a pessoa gasta para operar a interface em vez de resolver o problema dela.

---
