## Boas práticas para revisão e aprovação de designs

Aprovação é onde propostas boas morrem por motivos que não têm nada a ver com a qualidade delas: ninguém sabia que estava aprovando, três pessoas podiam vetar e nenhuma podia decidir, o retorno chegou em rodadas infinitas, ou a aprovação foi dada e depois desfeita porque alguém que não estava presente discordou.

Um processo de revisão e aprovação claro não é burocracia — é o que permite que o trabalho termine.

### Revisão e aprovação são coisas diferentes

Confundi-las é a causa da maior parte dos problemas.

**Revisão** melhora o trabalho. Participam pares, quem implementa, quem dá suporte. Não decide nada. Pode acontecer várias vezes, quanto mais cedo melhor.

**Aprovação** autoriza a seguir. Participa quem tem mandato. Acontece uma vez, no fim, e produz um registro.

Quando as duas se misturam, dois problemas aparecem. Uma revisão informal produz uma "aprovação" que não vale — e é desfeita depois. E a aprovação vira sessão de crítica, com quem decide sugerindo mudanças de detalhe em vez de decidir.

A separação começa no convite: declare qual das duas é, e repita na abertura.

### Quem aprova o quê

O primeiro item a definir em qualquer projeto, e o mais esquecido:

| Tipo de decisão | Quem aprova |
|---|---|
| Estrutura e fluxo | Produto, com validação de usuário |
| Comportamento e regra de negócio | Produto, com a área dona da regra |
| Viabilidade e escopo técnico | Liderança técnica |
| Conformidade, dados, jurídico | A área responsável, quando aplicável |
| Detalhe visual dentro do padrão | Quem faz o design |

A última linha é a que precisa ser defendida e a mais frequentemente violada. Se cada ajuste de espaçamento precisa de aprovação, o trabalho não avança — e, mais importante, o padrão existe justamente para que essas decisões não precisem ser tomadas caso a caso.

E a distinção que resolve metade dos impasses: **quem opina não é quem aprova**. Muita gente pode e deve dar retorno; uma pessoa decide. Se três podem vetar e nenhuma pode aprovar, o trabalho está estruturalmente travado, e isso precisa ser nomeado.

### Rodadas de revisão: quantas, e por que limitar

Sem um número acordado, revisões são infinitas por construção — sempre há mais um ajuste possível, e cada rodada gera novas observações sobre o que mudou.

O acordo que funciona, declarado no início:

> "Duas rodadas de retorno. Na primeira, tudo é discutível. Na segunda, apenas o que mudou desde a primeira. A partir da terceira, tratamos como escopo novo."

A segunda frase é a que evita o problema mais irritante: alguém revisitar, na segunda rodada, uma decisão que já tinha passado na primeira. Isso não é má-fé — é o resultado natural de olhar de novo com olhos frescos. O acordo prévio dá a resposta pronta: "isso foi decidido na rodada 1; se você acha que precisa ser revisto, vamos tratar separadamente."

### O que pedir e o que não pedir em cada rodada

O direcionamento vale tanto quanto o número de rodadas:

**Rodada 1 — estrutura.** "Preciso saber se a sequência faz sentido e se falta informação em alguma tela. Visual, textos e estados de erro ainda não estão prontos."

**Rodada 2 — detalhe.** "A estrutura está fechada. Preciso de retorno sobre os textos e sobre os estados de exceção."

Declarar o que está fora de escopo em cada rodada elimina boa parte dos comentários que não podem ser atendidos naquele momento — e que, sem essa declaração, geram uma dívida social: quem sugeriu espera resposta.

### O registro de aprovação

Uma aprovação que não foi registrada não aconteceu. Duas semanas depois, cada participante lembra uma versão diferente, e a divergência aparece no pior momento.

O formato mínimo, enviado no mesmo dia:

```
Aprovação — fluxo de devolução — v5 — 14/04
Aprovado por: [nome, papel]

O QUE FOI APROVADO
Fluxo em 3 etapas, telas 1 a 6, com os estados vazio, erro e carregando
conforme documentado no arquivo (link, versão v5).

O QUE NÃO ESTÁ INCLUÍDO
Painel administrativo, e-mail de confirmação, versão mobile.

EM ABERTO
Devolução parcial — [responsável], até 21/04.

PRÓXIMO PASSO
Entra na sprint de maio. Estimativa acordada: 6 dias.
```

A seção "o que não está incluído" é a que evita a conversa mais desagradável de todas — aquela em que se descobre, na entrega, que a outra parte esperava mais.

E o link precisa apontar para uma **versão nomeada**, não para o arquivo. Sem isso, "aprovado" refere-se a um estado que já mudou.

### O erro que você vai cometer: buscar consenso quando precisa de decisão

Você apresenta a proposta a seis pessoas. Quatro concordam, uma tem uma ressalva, uma discorda. Em vez de pedir a decisão a quem tem o mandato, você tenta convencer as duas — porque seguir com alguém discordando parece atropelar.

O que acontece: uma rodada extra para atender a ressalva, que introduz outro problema; a pessoa que discordava continua discordando, agora com uma versão pior; e o projeto atrasa duas semanas.

Consenso é ótimo quando acontece e é um péssimo requisito. A maior parte das decisões de design tem alternativas defensáveis, e sempre haverá alguém que preferia a outra. Esperar unanimidade é dar poder de veto a qualquer participante.

A postura que funciona: **ouvir com atenção genuína, registrar a divergência, e pedir a decisão a quem decide**.

> "A [nome] prefere a alternativa B, pelo argumento X, que é legítimo. Escolhi A por causa de Y. Precisamos de uma decisão para seguir — [nome de quem decide], qual das duas?"

Isso respeita quem discorda — a posição dela foi apresentada com justiça, não minimizada — e não trava o trabalho. E tem um efeito colateral valioso: as pessoas param de sentir que precisam insistir para serem ouvidas, porque sabem que a divergência será registrada de qualquer forma.

### Exercício prático

**Objetivo:** estruturar o processo de revisão e aprovação de um trabalho seu.

1. Escolha um trabalho em andamento.
2. Preencha a tabela de quem aprova o quê, com nomes reais. Marque as linhas em que você não sabe a resposta.
3. Descubra as respostas que faltam, perguntando diretamente.
4. Declare, por escrito, para os envolvidos: número de rodadas, o que se discute em cada uma, e quem aprova ao final.
5. Conduza a rodada 1 com o direcionamento explícito do que está e do que não está em jogo.
6. Ao aprovar, produza o registro de quatro seções, apontando para uma versão nomeada.
7. Verifique depois: alguma decisão da rodada 1 foi revisitada na rodada 2? Como você respondeu?

### Solução comentada

O passo 2 costuma deixar pelo menos duas linhas em branco, e são sempre as mais importantes: quem aprova estrutura e fluxo, e quem aprova regra de negócio. Em muitas organizações, essas decisões nunca foram atribuídas formalmente — elas acontecem por costume, por quem fala mais alto, ou por quem estava na reunião.

Descobrir isso é metade do valor do exercício. A pergunta do passo 3, feita diretamente — "quem decide se este fluxo tem três ou cinco etapas?" —, produz três tipos de resposta, todas úteis: um nome (ótimo), "acho que somos nós dois" (a ser resolvido antes de precisar), ou um silêncio constrangido, que revela que ninguém sabe. O último é o caso mais comum e o mais valioso de resolver, porque ele é a causa dos projetos que travam sem que ninguém saiba explicar por quê.

O passo 7 verifica a parte do acordo que mais é testada. A revisita de decisões já tomadas acontece em praticamente toda rodada 2, e quase sempre de boa-fé. A resposta preparada — "isso foi fechado na rodada 1; se você acha que precisa ser revisto, vamos tratar como um item separado, com o custo de refazer" — funciona por dois motivos: não recusa a discussão, e torna o custo visível. Muitas revisitas desaparecem quando o custo aparece, porque a pessoa percebe que a preferência dela não valia duas semanas.

E quando não desaparece, isso é informação relevante: uma objeção que sobrevive ao custo declarado provavelmente é sobre algo importante, e vale ser levada a sério.

---
