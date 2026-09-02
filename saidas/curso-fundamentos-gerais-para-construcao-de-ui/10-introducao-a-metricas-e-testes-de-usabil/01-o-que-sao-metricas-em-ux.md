## O que são métricas em UX

"A nova versão está melhor." Essa frase, dita numa reunião, tem exatamente o peso da autoridade de quem a diz — nenhum a mais. Substitua por "o tempo médio para concluir o cadastro caiu de 4min12 para 2min48, e a taxa de conclusão subiu de 39% para 62% em três semanas", e a frase passa a ter peso próprio, independente de quem fala.

Essa é a função de uma métrica em UX: transformar uma percepção sobre a experiência em algo verificável, comparável ao longo do tempo e discutível por quem não estava presente quando você observou.

### O que é e o que não é uma métrica

Uma métrica é um **número, definido de forma reproduzível, coletado da mesma maneira em momentos diferentes**. Os três elementos importam:

- **Número** — permite comparar e agregar.
- **Definido de forma reproduzível** — outra pessoa, seguindo a definição, chega ao mesmo valor.
- **Coletado da mesma maneira** — sem isso, a comparação entre antes e depois mede o método, não o produto.

O segundo item é o mais violado. "Taxa de conclusão do cadastro" parece autoexplicativo até alguém perguntar: conta quem começou a preencher, ou quem abriu a tela? Quem concluiu no mesmo dia, ou em qualquer momento? Quem tentou três vezes conta como uma pessoa ou três? Cada resposta produz um número diferente para o mesmo nome.

O que **não** é métrica: "os usuários gostaram", "ficou mais intuitivo", "reduzimos a fricção". São conclusões, e podem ser verdadeiras — mas sem um número por trás, não podem ser verificadas nem comparadas.

### Métricas de comportamento e métricas de atitude

A divisão mais útil separa o que as pessoas **fazem** do que elas **dizem**.

| | Comportamento | Atitude |
|---|---|---|
| Origem | Observação, logs | Perguntas, questionários |
| Exemplos | Taxa de conclusão, tempo, erros, cliques | Satisfação, facilidade percebida, intenção de recomendar |
| Força | Registra o que aconteceu de fato | Captura percepção, que afeta adoção |
| Fraqueza | Não diz por quê | As pessoas são péssimas em prever o próprio comportamento |

As duas divergem com frequência incômoda, e a divergência é informação. Um caso comum: participantes declaram preferir a versão com mais opções e, medidos, são mais rápidos e cometem menos erros na versão com menos. Quando isso acontece, o comportamento é o dado sobre usabilidade; a atitude é um dado sobre adoção — e ignorar qualquer um dos dois leva a decisões ruins por caminhos diferentes.

### Métricas de produto e métricas de tarefa

Outra divisão que evita confusão:

**Métricas de produto** são acompanhadas continuamente: usuários ativos, retenção, taxa de conversão, volume de chamados. Respondem "como está o produto?".

**Métricas de tarefa** são medidas em um teste ou em um fluxo específico: taxa de conclusão de uma tarefa, tempo até o primeiro clique certo, número de erros. Respondem "esta tela funciona?".

A confusão entre as duas produz um erro comum: esperar que uma melhoria de interface mova uma métrica de produto. Se o cadastro representa 4% da jornada total e a retenção depende de outros dez fatores, uma melhoria excelente no cadastro pode não aparecer na retenção. Isso não significa que a melhoria não funcionou — significa que a métrica escolhida estava distante demais da mudança.

A régua: **escolha a métrica mais próxima possível do que você mudou**, e só depois verifique se ela se propaga.

### A cadeia entre a mudança e o resultado

Uma forma útil de escolher métrica é escrever a cadeia causal inteira e medir o elo mais próximo:

```
Mudança          → Etiquetas de filtro visíveis com "x" para remover
Efeito imediato  → Pessoas conseguem remover filtros sem recarregar
Métrica próxima  → Taxa de sucesso ao remover filtro em teste (mede direto)
Efeito seguinte  → Menos confusão sobre "sumiram pedidos"
Métrica média    → Chamados com esse assunto por trimestre
Efeito distante  → Menos tempo de atendimento
Métrica distante → Tempo médio de atendimento (muitos outros fatores)
```

A métrica próxima responde rápido e com pouco ruído. A distante é a que interessa ao negócio e é influenciada por dezenas de coisas. Medir só a distante é receita para não detectar efeito nenhum; medir só a próxima é receita para não convencer ninguém. Meça as duas, e apresente-as nessa ordem.

### O erro que você vai cometer: escolher a métrica depois

O trabalho é feito, a mudança entra, e só então você procura um número que mostre a melhora. Encontra um: os acessos à tela subiram 18%.

Dois problemas. Primeiro, sem linha de base coletada **antes**, nas mesmas condições, você não sabe se 18% é efeito da mudança, sazonalidade ou uma campanha do comercial. Segundo — e mais grave — procurar um número que confirme depois é o mecanismo clássico de encontrar o que se quer encontrar: com dezenas de números disponíveis, sempre haverá algum que subiu.

A disciplina que evita isso tem duas partes, e ambas acontecem **antes** da mudança:

1. **Declare a métrica e o resultado esperado.** "Espero que a taxa de sucesso em remover filtro suba de cerca de 30% para acima de 80%."
2. **Colete a linha de base**, nas mesmas condições em que medirá depois.

Isso transforma a avaliação em teste de uma previsão, e não em busca por confirmação. E tem um benefício adicional: quando o resultado se confirma, a afirmação é muito mais forte, porque foi feita antes.

Vale acrescentar o passo que quase ninguém dá: declarar também **o que faria você concluir que não funcionou**. Uma previsão que nenhum resultado possível pode contrariar não é previsão.

### Exercício prático

**Objetivo:** definir métricas para uma mudança que você propôs.

1. Escolha uma melhoria sua, ainda não implementada.
2. Escreva a cadeia causal completa, da mudança ao efeito distante, com pelo menos quatro elos.
3. Escolha uma métrica próxima e uma distante. Para cada uma, escreva a definição operacional completa: o que conta, o que não conta, em que período, com quem.
4. Peça a alguém que leia só a definição e diga como coletaria o número. Se a pessoa descrever um procedimento diferente do seu, a definição está ambígua — reescreva.
5. Declare o resultado esperado e o que indicaria que a mudança não funcionou.
6. Colete a linha de base antes de qualquer alteração.

### Solução comentada

O passo 4 é o teste da definição, e a taxa de falha na primeira tentativa é alta. O padrão: você escreve "taxa de conclusão do cadastro" achando que é evidente, e a outra pessoa propõe contar de um jeito que você não tinha considerado.

Os pontos de ambiguidade se repetem: o denominador (quem entra na conta?), a janela de tempo (concluiu quando?), a unidade (pessoa ou sessão?), e o tratamento de repetições (quem tentou três vezes conta quantas?). Resolver os quatro explicitamente é o que torna a métrica reproduzível — e o que impede a discussão de dois meses depois, quando alguém apresenta um número diferente para a mesma coisa.

O passo 5, declarar o que indicaria fracasso, costuma ser o mais desconfortável e é o que distingue medição de justificação. Sem ele, qualquer resultado é interpretado favoravelmente: se o número subiu, a mudança funcionou; se ficou igual, "outros fatores interferiram"; se caiu, "ainda é cedo". Uma previsão que sobrevive a qualquer resultado não informa nada.

E o passo 6 é o que mais se lamenta quando pulado. Uma vez implementada a mudança, a linha de base é irrecuperável — e a partir daí a única coisa que se pode dizer é "acho que melhorou", que é exatamente a frase que este trecho existe para substituir.

---
