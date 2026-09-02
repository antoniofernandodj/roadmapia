## Análise simples dos resultados dos testes

Cinco sessões concluídas, folhas de registro preenchidas, áudio gravado. O material é rico e, do jeito que está, inutilizável para decidir qualquer coisa. A análise é o que transforma cem observações dispersas em uma lista curta de problemas priorizados — e ela cabe em duas horas.

O erro que se comete aqui é o oposto do esperado: não é análise insuficiente, é análise sofisticada demais para o tamanho dos dados. Com cinco participantes, não há teste estatístico a fazer. Há contagem, agrupamento e julgamento.

### Passo 1: extrair as observações

Percorra as folhas de registro e transcreva cada observação como uma linha independente, com o participante e o comportamento:

```
P1 · buscou pelo nome do cliente; busca só aceita número
P1 · rolou a lista inteira, 31 s
P1 · não encontrou "Solicitar devolução" no menu Ações
P2 · buscou pelo nome; mesmo erro
P2 · encontrou a devolução em 12 s, pela aba Itens
P3 · buscou pelo nome; mesmo erro
P3 · rolou a lista inteira, 26 s
P3 · não encontrou devolução; desistiu
...
```

Uma linha por observação, sem agrupar ainda. Com cinco sessões, isso costuma dar entre trinta e sessenta linhas.

### Passo 2: agrupar em problemas

Junte as linhas que descrevem o mesmo problema, mesmo quando o comportamento variou. As três linhas de "buscou pelo nome" são o mesmo problema; "rolou a lista" e "usou Ctrl+F" também são o mesmo — falta de confiança na busca.

O agrupamento é a parte que exige julgamento, e há um teste que ajuda: **se a mesma correção resolveria as duas observações, são o mesmo problema**. Se exigiriam correções diferentes, são dois.

### Passo 3: a matriz

Problemas nas linhas, participantes nas colunas:

| Problema | P1 | P2 | P3 | P4 | P5 | n |
|---|---|---|---|---|---|---|
| Busca não aceita nome do cliente | ✗ | ✗ | ✗ | — | ✗ | 4 |
| "Solicitar devolução" oculto em "Ações" | ✗ | — | ✗ | ✗ | ✗ | 4 |
| Rolou a lista por não confiar na busca | ✗ | ✗ | ✗ | ✗ | ✗ | 5 |
| Confundiu "Devoluções" e "Cancelamentos" | — | ✗ | — | — | ✗ | 2 |
| Não viu o botão de anexar foto | — | — | — | ✗ | — | 1 |

Essa tabela é o produto central da análise. Ela mostra frequência e permite a próxima etapa.

### Passo 4: severidade

Frequência sozinha engana. Classifique cada problema pelo impacto:

| Nível | Critério |
|---|---|
| **Impediu** | A pessoa não concluiu a tarefa, ou concluiu errado |
| **Atrasou** | Concluiu, com tempo ou esforço significativamente maior |
| **Incomodou** | Concluiu normalmente; houve irritação ou dúvida passageira |

A prioridade combina os dois eixos:

- **Impediu + muitos** → corrija antes de qualquer coisa.
- **Impediu + um** → investigue; um único participante que não conseguiu concluir merece mais atenção que três que hesitaram.
- **Atrasou + muitos** → corrija; costuma ser barato e o ganho é diário.
- **Incomodou + poucos** → anote e siga. Voltará se importar.

### Passo 5: da observação à causa

Para cada problema priorizado, escreva a causa provável **e** o comportamento que a sustenta:

```
PROBLEMA  "Solicitar devolução" não encontrado (4 de 5, impediu)
COMPORTAMENTO  Todos os 4 abriram a aba "Itens" primeiro e procuraram ali
              por 15–20 s. Nenhum abriu o menu "Ações".
CAUSA PROVÁVEL  A ação está agrupada por tipo (ações do pedido) e as pessoas
              a procuram por objeto (o item que querem devolver).
CORREÇÃO PROPOSTA  Ação de devolução na linha do item, dentro da aba Itens.
O QUE ISSO PREVÊ  Se a causa estiver certa, mover a ação resolve. Se as
              pessoas continuarem não encontrando, a causa é outra — provável
              vocabulário.
```

A última linha é o que separa uma correção fundamentada de um palpite: ela declara o que se espera observar, e permite saber se a hipótese estava certa.

### O que fazer com o problema de um participante só

É a decisão mais delicada da análise, e a regra é: **frequência não é o único critério**.

Descarte se: o comportamento se explica por uma característica específica daquela pessoa (usava outro sistema parecido, tinha contexto que os outros não tinham), e a severidade foi baixa.

Investigue se: impediu a conclusão, ou se o participante pertence a um perfil que você testou pouco. Um problema que atinge um de cinco pode atingir 100% de um perfil que teve apenas um representante na amostra.

Com cinco participantes, um caso isolado corresponde a 20% da amostra — o que, em termos de o que isso significa para a população, é uma faixa muito ampla. A resposta honesta não é decidir a partir do número, é decidir a partir da severidade e do mecanismo: se você consegue explicar **por que** aquilo aconteceu, e a explicação vale para outras pessoas, é um problema real.

### O erro que você vai cometer: calcular médias e porcentagens

O impulso vem da formação técnica: você tem números, então calcula. Média de tempo, porcentagem de conclusão, desvio padrão.

Com cinco participantes, isso produz precisão falsa. "67% de taxa de conclusão" com seis pessoas dá a impressão de uma medida populacional, quando o intervalo de confiança real é largo o bastante para incluir quase qualquer valor. Apresentado assim, um resultado que era "quatro de seis conseguiram" vira um número que alguém vai comparar com o de outro trimestre, medido de outro jeito, com outra amostra.

A regra é a mesma já vista: **com menos de vinte participantes, números absolutos**. "Quatro de seis" é honesto, é fácil de entender, e sinaliza automaticamente o tamanho da amostra.

O mesmo vale para a média de tempo. Com cinco valores, um participante distraído desloca a média inteira. Use a **mediana** e, se houver espaço, mostre os cinco valores — a dispersão é informação: cinco pessoas levando 40, 42, 45, 44 e 43 segundos é um resultado muito diferente de 12, 20, 45, 90 e 130.

### Exercício prático

**Objetivo:** analisar um conjunto real de sessões, do registro à lista priorizada.

1. Use as folhas de registro de três a cinco sessões suas.
2. Extraia todas as observações como linhas independentes.
3. Agrupe em problemas, aplicando o teste da correção comum.
4. Monte a matriz problema × participante.
5. Classifique a severidade de cada um.
6. Para os três primeiros da prioridade, escreva causa provável, comportamento que a sustenta, correção proposta e o que a correção prevê.
7. Reporte todos os números em absolutos e o tempo em mediana.

### Solução comentada

O passo 3 é onde a análise realmente acontece, e o teste da correção comum resolve a maior parte das dúvidas. Mas há um caso que ele não resolve e que vale reconhecer: quando várias observações diferentes têm a **mesma causa raiz**.

O exemplo do próprio material acima: "busca não aceita nome", "rolou a lista inteira", "usou Ctrl+F". As três parecem problemas distintos e exigem correções diferentes — mas todas decorrem de uma única causa: a busca não faz o que as pessoas esperam que ela faça. Corrigir a busca resolve as três.

Reconhecer isso muda a proposta de forma substancial. Em vez de três itens no backlog, um. E em vez de "três problemas na tela de listagem", a apresentação vira "a busca não atende à forma como as pessoas procuram; isso gera três comportamentos de contorno que observamos em todos os cinco participantes". A segunda formulação é mais curta, mais forte e mais fácil de priorizar.

O sinal para procurar causa raiz: quando três ou mais problemas aparecem sempre nos **mesmos participantes**, na mesma sequência. Isso raramente é coincidência.

O passo 6, escrever o que a correção prevê, é o que fecha o ciclo com o próximo teste. Ele transforma a rodada seguinte em verificação de uma hipótese, e não em nova coleta de impressões — e, quando a previsão não se confirma, você sabe imediatamente que o diagnóstico estava errado, em vez de concluir que a correção foi insuficiente e aplicar mais da mesma coisa.

---
