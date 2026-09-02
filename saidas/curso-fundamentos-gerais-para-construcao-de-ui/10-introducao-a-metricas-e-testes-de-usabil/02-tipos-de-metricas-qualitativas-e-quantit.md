## Tipos de métricas: qualitativas e quantitativas

Na avaliação da experiência do usuário (UX), medir resultados é fundamental para entender se uma interface realmente atende às necessidades e expectativas dos usuários. Mas, para isso, precisamos distinguir os dois grandes tipos de métricas disponíveis: as **qualitativas** e as **quantitativas**. Cada uma delas oferece um tipo de informação diferente, complementando-se para formar um panorama completo da usabilidade e eficácia de uma interface.

### Métricas quantitativas: o que são e para que servem

As métricas quantitativas são dados numéricos que indicam “o quanto” algo acontece. Elas respondem a perguntas como:

- Quantos usuários completaram uma tarefa?
- Quanto tempo levaram para concluir essa tarefa?
- Quantos cliques foram necessários?
- Qual a taxa de erro registrada?

Esses dados são objetivos e mensuráveis, facilitando comparações e análises estatísticas simples — mesmo sem entrar em cálculos complexos. Por exemplo, se você mede o tempo médio para um usuário encontrar um botão "Finalizar compra" em um protótipo, está coletando uma métrica quantitativa.

#### Por que métricas quantitativas são importantes?

- **Medem desempenho:** tempo, taxa de sucesso, número de erros.
- **Permitem comparação:** entre versões da interface ou diferentes grupos de usuários.
- **Facilitam a identificação de gargalos:** pontos onde o usuário demora ou falha.

#### Exemplo prático de métrica quantitativa

Imagine que você testou um protótipo de um app de delivery com 5 usuários para avaliar a tarefa de “fazer um pedido”. O tempo em segundos para conclusão da tarefa foi:

```
Usuário 1: 120s
Usuário 2: 135s
Usuário 3: 110s
Usuário 4: 140s
Usuário 5: 125s
```

Aqui, você pode calcular a média simples para ter uma ideia geral do desempenho:

\[
\text{Média} = \frac{120 + 135 + 110 + 140 + 125}{5} = \frac{630}{5} = 126s
\]

Ou seja, em média, um usuário leva 126 segundos para completar essa tarefa no protótipo.

### Métricas qualitativas: o que são e para que servem

Métricas qualitativas são dados descritivos, que capturam **o porquê** das ações dos usuários, suas impressões, dificuldades, opiniões e sentimentos durante a interação. Elas respondem a perguntas como:

- Por que o usuário não conseguiu encontrar a função desejada?
- O que causou confusão nessa etapa?
- Como o usuário descreve a facilidade de uso da interface?
- Quais sugestões ele tem para melhorar?

Esses dados são coletados geralmente por meio de entrevistas, observações, anotações durante testes de usabilidade e feedbacks abertos. Embora não sejam expressos em números, são essenciais para entender o contexto e as motivações por trás do comportamento.

#### Por que métricas qualitativas são importantes?

- **Revelam insights profundos:** ajudam a compreender as razões por trás dos dados quantitativos.
- **Identificam problemas específicos de usabilidade:** pontos onde o usuário se perde ou se frustra.
- **Guiam decisões de design:** com base em relatos reais, não apenas números.

#### Exemplo prático de métrica qualitativa

Durante o mesmo teste de usabilidade do app de delivery, você pergunta a um usuário:

> _“Você encontrou alguma dificuldade ao fazer o pedido?”_

O usuário responde:

> “Demorei a entender que precisava clicar no ícone do carrinho para revisar o pedido. Achei essa parte pouco clara e quase desisti.”

Esse relato, embora não numérico, indica um problema de comunicação visual que passaria despercebido se você analisasse apenas o tempo ou taxa de sucesso.

### Comparando as métricas qualitativas e quantitativas

| Aspecto               | Métricas Quantitativas                         | Métricas Qualitativas                       |
|-----------------------|-----------------------------------------------|---------------------------------------------|
| Natureza              | Números, dados objetivos                       | Descrições, opiniões, observações           |
| Perguntas respondidas | “Quanto?”, “Com que frequência?”               | “Por que?”, “Como?”, “O que?”                |
| Exemplo típico        | Tempo para completar uma tarefa, taxa de erro | Comentários do usuário, observação de confusão |
| Uso principal         | Medir desempenho, comparar versões             | Entender motivações, identificar problemas   |
| Ferramentas comuns    | Relógio, contadores, logs de uso                | Entrevistas, anotações, gravações de vídeo   |

### Erros comuns ao confundir os dois tipos de métricas

Um erro frequente é focar apenas em métricas quantitativas, como tempo ou número de cliques, e ignorar o que realmente motiva esses números. Por exemplo, um usuário pode completar uma tarefa rapidamente, mas fazendo muitos erros ou ficando frustrado — algo que só métricas qualitativas revelariam.

Outro erro é tentar quantificar tudo, transformando opiniões e sentimentos em números de forma simplista, o que pode distorcer a interpretação dos dados.

### Como escolher entre métricas qualitativas e quantitativas?

A escolha depende do objetivo da avaliação:

- Se precisa saber **se** a interface funciona e **como** ela performa, métricas quantitativas são essenciais.
- Se quer entender **por que** o usuário age de determinada forma ou sente certa coisa, métricas qualitativas são indispensáveis.

O ideal, sempre que possível, é usar ambas em conjunto. Por exemplo, medir o tempo médio para uma tarefa (quantitativa) e perguntar ao usuário o que achou do processo (qualitativa).

### Exercício prático

Você criou um protótipo para um site de cadastro de usuários e realizou um teste com três pessoas. Os tempos para completar o cadastro foram 80, 95 e 110 segundos, mas um dos usuários comentou que não encontrou o botão “Enviar” facilmente.

1. Calcule o tempo médio para completar o cadastro.
2. Explique por que a métrica qualitativa do comentário do usuário é importante, mesmo que os tempos não sejam muito diferentes.
3. Sugira uma possível melhoria no protótipo baseada nesse comentário.

---

### Solução comentada

1. Cálculo da média:

\[
\frac{80 + 95 + 110}{3} = \frac{285}{3} = 95 \text{ segundos}
\]

2. Embora o tempo médio seja aceitável, o comentário qualitativo indica que a interface pode confundir os usuários ao esconder ou apresentar mal o botão “Enviar”. Isso pode levar a desistências ou erros em situações reais, não captadas apenas pelo tempo.

3. Uma melhoria possível é aumentar o destaque visual do botão “Enviar”, usando uma cor contrastante, um tamanho maior ou texto mais claro, para que o usuário o identifique facilmente.

---

Assim, compreender as diferenças entre métricas qualitativas e quantitativas permite coletar dados mais ricos e confiáveis para melhorar interfaces, equilibrando números e histórias reais dos usuários.