## Feedback qualitativo e quantitativo

No processo de design centrado no usuário, o feedback é a bússola que orienta as decisões e ajustes necessários para criar interfaces realmente eficazes e satisfatórias. Mas o que torna o feedback útil não é apenas o fato de recebê-lo, e sim compreender os diferentes tipos de feedback — qualitativo e quantitativo — e como cada um contribui para a iteração do design.

### O problema do feedback superficial ou mal interpretado

Imagine que você desenvolveu um protótipo para um aplicativo de agendamento de consultas médicas e apresentou para um grupo de usuários. Eles dizem apenas “gostei” ou “não gostei”. Esse tipo de retorno, apesar de parecer positivo, não informa o que exatamente funcionou ou falhou. Sem entender o porquê, qualquer mudança que você faça será um tiro no escuro, correndo o risco de afastar ainda mais o usuário.

Esse problema ocorre porque o feedback pode ser genérico, emocional, ou até contraditório. Por isso, distinguir entre feedback qualitativo e quantitativo ajuda a extrair informações que realmente guiam melhorias eficazes.

---

### Feedback qualitativo: o que é e para que serve

O feedback qualitativo é aquele que descreve experiências, sentimentos, opiniões e percepções dos usuários de forma detalhada e contextual. Ele responde às perguntas “por quê?” e “como?”, oferecendo insights profundos sobre a experiência real do usuário.

Exemplos típicos de feedback qualitativo:

- Comentários em entrevistas ou sessões de teste dizendo “Achei difícil encontrar o botão de cancelar, porque ele estava muito pequeno e no canto.”
- Observações sobre emoções, como “Fiquei frustrado ao esperar muito tempo para a tela carregar.”
- Sugestões específicas, como “Seria melhor se o formulário tivesse menos campos para preencher.”

Esse tipo de feedback é essencial para entender os motivos por trás dos comportamentos, identificar problemas ocultos e descobrir necessidades não atendidas, que dificilmente aparecem em números.

**Por que o feedback qualitativo é indispensável?**

- Revela aspectos subjetivos da experiência, como frustração, confusão ou satisfação.
- Ajuda a compreender contextos de uso e motivações do usuário.
- Descobre erros de usabilidade que não aparecem em métricas.
- Orienta melhorias focadas no sentimento e na percepção do usuário.

---

### Feedback quantitativo: o que é e para que serve

Já o feedback quantitativo é o retorno medido por dados numéricos e estatísticos, como taxas, quantidades, tempos e frequências. Ele responde a perguntas do tipo “quanto?”, “com que frequência?” e “qual a proporção?”.

Exemplos típicos de feedback quantitativo:

- Percentual de usuários que completaram uma tarefa com sucesso.
- Tempo médio para finalizar um cadastro.
- Número de cliques necessários para acessar uma função.
- Taxa de abandono em determinada etapa do fluxo.

Esse tipo de feedback permite medir a performance da interface, comparar versões, detectar gargalos e validar hipóteses com base em números objetivos.

**Por que o feedback quantitativo é indispensável?**

- Fornece dados objetivos para avaliação e comparação.
- Ajuda a identificar padrões e tendências no uso.
- Permite priorizar problemas com base na frequência ou impacto.
- Facilita a comunicação com equipes técnicas e stakeholders.

---

### Como combinar feedback qualitativo e quantitativo para iterar eficazmente

O valor real do feedback aparece quando os dois tipos são usados em conjunto. Por exemplo, se uma métrica quantitativa mostra que 40% dos usuários abandonam um formulário na etapa 3, o feedback qualitativo ajuda a entender o motivo — talvez o campo solicitado seja confuso ou invasivo.

Dessa forma, você evita erros comuns como:

- Focar apenas em números e ignorar o contexto emocional e funcional do usuário.
- Reagir a opiniões isoladas sem validar se são recorrentes ou pontuais.
- Fazer mudanças superficiais que não resolvem os problemas reais.

**Exemplo prático:**

Você recebeu os seguintes dados após um teste com protótipo:

- Quantitativo: 30% dos usuários falharam ao tentar usar o filtro de busca.
- Qualitativo: Nos relatos, usuários mencionaram que o ícone do filtro não estava claro e que não sabiam que era possível refinar a busca.

Combinando as informações, a solução pode ser tornar o ícone mais explícito e oferecer uma breve orientação visual, algo que números sozinhos não indicariam.

---

### Erro comum e sua mensagem

Um erro frequente em times iniciantes é coletar feedback qualitativo de forma desestruturada, por exemplo, anotando apenas “não gostei” ou “acho ruim”, e tentar transformar isso em um dado quantitativo sem contexto. Isso leva a relatórios confusos e decisões erradas.

Mensagem típica de erro em ferramenta de análise qualitativa mal utilizada:

```
Erro: feedback insuficiente para categorização. Insira detalhes adicionais para análise.
```

Ou, em teste de usabilidade, pode ocorrer:

```
Aviso: taxa de sucesso na tarefa abaixo do esperado, porém relatos inconsistentes.
```

Esse erro ocorre porque o feedback qualitativo sem profundidade ou o quantitativo isolado sem contexto não são suficientes para um bom diagnóstico.

---

### Como evitar esse erro?

- Ao coletar feedback qualitativo, use perguntas abertas que estimulem explicações, e registre as falas ou atitudes do usuário.
- Na análise quantitativa, certifique-se de que as métricas estão alinhadas com objetivos claros e que têm contexto para interpretação.
- Relacione dados numéricos com relatos qualitativos para validar hipóteses.
- Documente exemplos reais de uso para ilustrar os dados.

---

### Exercício prático: Interpretando feedback qualitativo e quantitativo

Você conduziu um teste de usabilidade com 10 usuários para um protótipo de app de delivery. Recebeu os seguintes dados:

- Quantitativo: 6 usuários demoraram mais de 2 minutos para concluir o pedido, e 4 deles desistiram antes de finalizar.
- Qualitativo: Entre os que desistiram, 3 mencionaram que a etapa de pagamento era confusa, e 2 reclamaram que não encontraram o botão para alterar o endereço de entrega.

**Tarefa:**

1. Analise os dados e descreva um possível problema central no fluxo do app.
2. Proponha duas mudanças no protótipo para testar na próxima iteração.
3. Explique por que essas mudanças têm base no feedback combinado.

---

### Solução comentada

1. **Problema central:** O fluxo de pagamento e edição do endereço está dificultando a finalização dos pedidos, causando demora e desistência.

2. **Mudanças propostas:**

   - Tornar a etapa de pagamento mais clara, com instruções visuais e menos passos.
   - Incluir um botão visível e acessível para alterar o endereço de entrega, com ícone intuitivo.

3. **Justificativa:**

   - A demora e desistência indicam frustração e dificuldade, refletidas no feedback qualitativo sobre confusão no pagamento.
   - A reclamação sobre o botão indica ausência de um elemento crucial para o usuário, que pode ser resolvido com melhor design.
   - Essas mudanças focam nas causas reais identificadas, e não apenas nos sintomas numéricos.

---

Compreender e diferenciar o feedback qualitativo e quantitativo é fundamental para uma iteração eficiente no design de interfaces. Eles são complementares e essenciais para criar experiências que realmente atendam às necessidades e expectativas dos usuários, evitando decisões baseadas em achismos ou dados isolados.