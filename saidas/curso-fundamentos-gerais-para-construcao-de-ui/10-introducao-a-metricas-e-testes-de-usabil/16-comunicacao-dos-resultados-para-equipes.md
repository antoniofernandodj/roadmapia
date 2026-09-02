## Comunicação dos resultados para equipes

Imagine que você realizou um teste de usabilidade e coletou uma série de dados — números, observações, citações dos usuários, vídeos da interação — mas agora precisa apresentar esses resultados para a equipe de design, desenvolvimento e stakeholders que não participaram diretamente do teste. O desafio é: como transmitir o que foi descoberto de forma clara, objetiva e que facilite decisões práticas? A resposta está em comunicar os resultados sem transformar o relatório em um documento técnico maçante ou em gráficos complexos que só especialistas entendem.

### O problema de apresentar dados brutos

O erro mais comum é entregar a equipe uma planilha cheia de números ou um relatório gigante com transcrições de entrevistas. Isso pode causar confusão, desinteresse e, no pior caso, ignorar os insights valiosos que você identificou. Por exemplo, imagine um gerenciador de produto recebendo uma tabela com as seguintes métricas de um teste de usabilidade:

| Usuário | Tempo para completar a tarefa (s) | Erros cometidos | Satisfação (1-5) |
|---------|----------------------------------|-----------------|------------------|
| 1       | 120                              | 3               | 2                |
| 2       | 95                               | 1               | 3                |
| 3       | 150                              | 4               | 1                |

Sem contexto, essas informações são só números. O gerente pode não saber o que fazer com elas, nem qual a prioridade para melhoria.

### Como facilitar o entendimento dos dados

O segredo está em transformar dados em histórias visuais e narrativas curtas que conectam o que foi medido com o que realmente importa: a experiência do usuário e as ações possíveis para o time.

#### 1. Use resumos visuais simples

Transforme números em gráficos fáceis de interpretar, como:

- **Gráfico de barras** para comparar o tempo médio de tarefas entre diferentes versões.
- **Diagramas de fluxo** para mostrar onde os usuários travaram ou abandonaram o processo.
- **Mapas de calor simplificados** para indicar áreas de maior interação ou confusão.

Por exemplo, ao invés da tabela acima, você pode gerar um gráfico de barras mostrando o tempo médio, com uma anotação que destaca que “Usuários gastaram em média 120 segundos, mas 40% cometeram erros que os levaram a refazer etapas”.

#### 2. Destaque os problemas e oportunidades com exemplos reais

Inclua citações diretas dos usuários que mostrem as dificuldades encontradas. Por exemplo:

> “Não encontrei onde clicar para avançar, o botão estava pequeno demais e parecia um texto comum.”

Esse tipo de comentário cria empatia e ajuda a equipe a entender o impacto real do problema.

#### 3. Categorize os achados por prioridade

Separe os problemas em grupos, como:

- **Críticos:** bloqueiam o uso ou causam frustração intensa.
- **Importantes:** afetam a eficiência, mas não impedem o uso.
- **Menores:** detalhes que podem melhorar o conforto, mas não são urgentes.

Essa priorização ajuda a equipe a focar esforços.

#### 4. Faça recomendações objetivas e acionáveis

Cada problema identificado deve vir acompanhado de sugestões práticas, por exemplo:

> Problema: Botão de avançar pouco visível e com tamanho inadequado.  
> Recomendação: Aumentar o tamanho do botão para 44x44 pixels e usar uma cor contrastante para destacá-lo.

Evite recomendações vagas como “melhorar o botão” sem especificar o que e por quê.

### Formatos eficazes para comunicação

Você não precisa de um software sofisticado para comunicar resultados de forma eficaz. Eis alguns formatos simples que funcionam:

- **Slides resumidos:** use poucas palavras, gráficos claros e exemplos ilustrativos. Evite textos longos.
- **Relatório executivo:** uma página com principais descobertas, impacto e recomendações, focado em stakeholders.
- **Quadro visual na equipe:** mural ou quadro branco com post-its organizados por prioridade, para discussões rápidas.
- **Apresentação oral com demonstração:** mostrar vídeos curtos de usuários interagindo, combinados com os dados resumidos.

### Exemplo prático: comunicação de resultados de um teste de registro

Imagine que o teste avaliou o fluxo de cadastro em um app, usando as métricas de tempo, erros e satisfação.

**Resumo para equipe em slides:**

---

**Slide 1: Tempo médio para cadastro – 2 minutos 15 segundos**

- 3 usuários levaram mais de 3 minutos por confusão no campo de CPF.  
- Usuários tentaram digitar letras, o sistema não indicava o formato esperado.

**Slide 2: Erros comuns**

- 60% erraram ao preencher CPF pela falta de máscara de entrada.  
- 40% não encontraram o botão “Próximo” porque estava na cor cinza-claro.

**Slide 3: Satisfação geral**

- Média 2,3/5, usuários criticaram a clareza e a usabilidade.  
- Comentário exemplar: “Fiquei inseguro se o cadastro estava completo, não tinha feedback claro.”

**Slide 4: Recomendações**

- Implementar máscara de CPF para evitar erros.  
- Destacar o botão “Próximo” com cor azul e tamanho maior.  
- Adicionar mensagem de confirmação após o cadastro.

---

Esse formato comunica o essencial em poucos minutos, facilitando decisões rápidas e alinhadas.

### Evitando erros comuns na comunicação

- **Não exagere no jargão técnico:** termos como “heurística”, “taxa de cliques” ou “métrica NPS” devem ser explicados ou evitados quando o público não for familiar.
- **Não misture opinião pessoal com dados:** se quiser comentar, deixe claro que é uma interpretação ou sugestão.
- **Não sobrecarregue com excesso de dados:** escolha os indicadores mais relevantes para o objetivo da reunião.

### Exercício prático

Você realizou um teste de usabilidade para um protótipo de aplicativo de agendamento de consultas. Os dados coletados são:

| Usuário | Tempo para agendar (s) | Erros | Comentário do usuário                      |
|---------|-----------------------|-------|--------------------------------------------|
| 1       | 180                   | 2     | “Não sabia que precisava escolher o horário” |
| 2       | 220                   | 3     | “Algumas opções ficaram escondidas na tela”  |
| 3       | 150                   | 1     | “Gostei do passo a passo, mas o botão ‘Confirmar’ é pequeno” |

Monte um resumo simples para apresentar à equipe, contendo:

- Tempo médio para agendar e o que isso indica.  
- Principais erros e seu impacto.  
- Citação que exemplifique um problema.  
- Duas recomendações para melhorar a experiência.

---

### Solução comentada

**Resumo para equipe:**

---

**Tempo médio para agendar: 183 segundos**

- Usuários gastaram mais de 3 minutos em média, indicando fluxo lento e dificuldades.

**Principais erros:**

- Falta de clareza na seleção do horário causou confusão e erros.  
- Elementos importantes estavam fora da vista imediata, dificultando a navegação.

**Comentário exemplar:**

> “Não sabia que precisava escolher o horário.”

**Recomendações:**

- Inserir indicação clara e destacada para a escolha do horário, como um texto explicativo ou ícone.  
- Ajustar o layout para garantir que todas as opções estejam visíveis sem precisar rolar a tela.  
- Aumentar o tamanho do botão "Confirmar" para facilitar a interação.

---

Essa estrutura mostra como organizar e apresentar dados de testes de usabilidade para facilitar a compreensão e o uso prático pela equipe, sem precisar de relatórios complexos ou ferramentas específicas.

---