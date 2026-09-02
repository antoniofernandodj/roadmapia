## Reuniões produtivas em projetos de design

Uma reunião de design mal conduzida tem um custo específico e mensurável: seis pessoas por uma hora são seis horas de trabalho, e o resultado típico é uma lista de opiniões contraditórias e nenhuma decisão. Repetida semanalmente, essa reunião consome mais tempo de equipe do que o próprio trabalho de design.

O que separa uma reunião produtiva de uma sessão de opinião não é habilidade de facilitação — é preparo estrutural: saber qual é o tipo da reunião, quem precisa estar, o que se decide e como se registra.

### Os quatro tipos, e por que não misturar

| Tipo | Objetivo | Duração | Quem |
|---|---|---|---|
| **Alinhamento** | Concordar sobre o problema e a prioridade | 30 min | Quem decide + quem propõe |
| **Crítica** | Melhorar o trabalho em andamento | 45 min | Pares, quem implementa |
| **Decisão** | Escolher entre alternativas | 30 min | Quem decide, com poder de decidir |
| **Ideação** | Gerar alternativas | 60–90 min | Grupo diverso, incluindo quem implementa |

A falha estrutural mais comum é misturar crítica com decisão. A reunião começa como "vamos revisar o trabalho" e, no meio, alguém pergunta "então fica assim?" — e uma decisão é tomada sem que as pessoas certas estejam presentes ou preparadas. O oposto também ocorre: uma reunião de decisão vira sessão de redesenho coletivo, e ninguém decide nada.

O remédio é declarar o tipo no convite e repeti-lo na abertura: "esta é uma reunião de crítica; não vamos decidir nada hoje, vou levar o retorno e trazer a proposta na quinta".

### O convite: o trabalho começa antes

Um convite de reunião de design que funciona tem cinco linhas:

```
Tipo: crítica
Objetivo: melhorar o fluxo de devolução antes de fechar a proposta
O que preparei: protótipo de 6 telas (link) — 10 min de leitura antes, por favor
O que preciso de vocês: se a sequência faz sentido e se falta informação
                        em alguma tela
O que NÃO está pronto: textos finais, estados de erro, cores
Duração: 45 min
```

A terceira linha — pedir leitura prévia — é a que mais muda o rendimento. Uma reunião que começa com dez minutos de apresentação do contexto tem dez minutos a menos de discussão. Se as pessoas não leem, isso é informação: ou o material está longo demais, ou a reunião não importa o suficiente para elas, e as duas coisas são resolvíveis.

### Conduzindo cada tipo

**Alinhamento.** Comece pelo problema com número. Termine com uma frase escrita de acordo: "concordamos que o problema é X, e que a prioridade dele é acima de Y". Se não conseguir escrever essa frase, o alinhamento não aconteceu, por mais amistosa que a conversa tenha sido.

**Crítica.** Duas regras que mudam tudo: quem apresenta declara o que quer avaliar, e quem critica descreve o que observou antes de propor solução. "Levei um tempo para achar o botão de confirmar" é útil. "Põe o botão em cima" já pulou para a solução, e escondeu a observação que a sustentava.

**Decisão.** Apresente no máximo três alternativas, com o trade-off de cada uma explícito. Termine com a decisão registrada e o responsável nomeado. Se a decisão não puder ser tomada, registre o que falta para tomá-la e quem vai buscar.

**Ideação.** Separe geração de julgamento, rigorosamente. Primeiro todo mundo gera em silêncio, individualmente, por dez minutos — isso evita que a primeira ideia dita ancore o grupo inteiro. Depois se apresenta, depois se agrupa, e só então se avalia.

### O registro: cinco linhas, no mesmo dia

Reunião sem registro não aconteceu. Uma semana depois, cada participante lembra uma versão diferente do que foi combinado, e a divergência aparece no pior momento possível.

O formato mínimo, enviado no mesmo dia, no canal onde a equipe conversa:

```
Reunião de decisão — fluxo de devolução — 14/04
Presentes: [nomes]

DECIDIDO
• Fluxo em 3 etapas, não em 5 (teste com 6 pessoas mostrou irritação com 5)
• Foto do produto passa a ser opcional no registro

EM ABERTO
• Devolução parcial é permitida? — [responsável], até 21/04

PRÓXIMO PASSO
• Proposta atualizada até 18/04; entra na sprint de maio
```

Três seções, nunca mais. E o registro serve também como correção silenciosa: se alguém lembra diferente, discorda por escrito, no dia seguinte, quando a memória ainda é boa — e não em maio.

### O erro que você vai cometer: convidar todo mundo

O impulso é inclusivo e bem-intencionado: chamar todos os interessados evita que alguém se sinta excluído e reduz o risco de uma objeção tardia.

O que acontece com oito pessoas na sala: a discussão se dispersa, cada participante contribui com o ângulo dele — que raramente é o assunto da pauta —, o tempo acaba, e a decisão não sai. Pior, com muita gente ninguém se sente responsável por decidir, e a reunião termina com "vamos pensar e conversar de novo".

A regra prática: **reunião de decisão com no máximo cinco pessoas, das quais uma tem autoridade para decidir**. Os demais interessados recebem o registro e podem discordar por escrito em 24 horas. Isso preserva a inclusão sem pagar o custo da sala cheia.

Há um sinal de que a lista está inflada: se você não consegue dizer, para cada convidado, qual contribuição específica se espera dele, essa pessoa não precisa estar lá — precisa receber o registro.

### Quando não fazer reunião

Boa parte das reuniões de design recorrentes pode ser substituída por outra coisa, com ganho:

- **Atualização de status** → mensagem escrita, ou o próprio quadro de tarefas.
- **Crítica pontual** → comentários no arquivo, respondidos de forma assíncrona.
- **Alinhamento com uma pessoa só** → uma conversa de dez minutos, não um convite de trinta.
- **Aprovação de algo consensual** → mensagem com prazo: "se ninguém discordar até quinta, seguimos com isto."

O último formato — decisão por silêncio com prazo — é subutilizado e resolve uma quantidade grande de aprovações que hoje ocupam agenda. Ele só funciona com duas condições: prazo explícito e destinatários nomeados.

### Exercício prático

**Objetivo:** reformular uma reunião recorrente que não rende.

1. Escolha uma reunião de design ou de produto que você participa e que costuma terminar sem decisão.
2. Classifique-a: qual dos quatro tipos ela é? Ela mistura mais de um?
3. Liste os participantes e escreva, para cada um, a contribuição específica esperada. Marque os que não têm uma.
4. Reescreva o convite no formato de cinco linhas, com o tipo declarado e o pedido de preparação prévia.
5. Conduza uma edição no novo formato, com a lista reduzida.
6. Envie o registro de três seções no mesmo dia.
7. Compare: a reunião produziu decisão? Quanto tempo durou?

### Solução comentada

O passo 2 costuma revelar que a reunião problemática é, na verdade, três reuniões ocupando o mesmo horário: começa com atualização de status, passa por crítica do trabalho em andamento e termina tentando decidir algo. Cada transição confunde os participantes sobre o que se espera deles, e a decisão do fim é tomada com quem sobrou de atenção.

Separar em duas — uma de crítica, assíncrona por comentários no arquivo, e uma de decisão, de trinta minutos com quatro pessoas — costuma reduzir o tempo total de sala e aumentar o número de decisões. É um ganho que aparece na primeira semana.

O passo 3 é o mais desconfortável, porque nomeia pessoas. Vale reformular o critério para tirar o peso pessoal: a pergunta não é "esta pessoa é importante?", é "que contribuição específica esperamos dela nesta pauta?". Alguém extremamente importante para o projeto pode não ter contribuição para uma pauta específica — e vai preferir receber o registro a passar uma hora ouvindo.

Sobre o passo 6: o registro no mesmo dia é a parte mais fácil de negligenciar e a que mais rende. Enviado no dia seguinte, ele já compete com a memória; enviado três dias depois, ele é uma reconstrução. A prática que funciona é escrever as três seções **durante** a reunião, nos últimos cinco minutos, lendo em voz alta para confirmar — o que tem o efeito adicional de revelar, na hora, quando as pessoas achavam ter concordado com coisas diferentes.

---
