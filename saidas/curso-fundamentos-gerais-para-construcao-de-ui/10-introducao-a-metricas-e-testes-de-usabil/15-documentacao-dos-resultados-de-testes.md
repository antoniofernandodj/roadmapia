## Documentação dos resultados de testes

Após conduzir um teste de usabilidade, o próximo passo fundamental é documentar os resultados de forma clara, objetiva e organizada. Essa documentação serve para registrar as descobertas — os problemas identificados, os comportamentos observados, as métricas coletadas e as opiniões dos usuários — de modo que qualquer pessoa envolvida no projeto possa entender o que foi testado, quais foram os principais achados e como eles impactam o desenvolvimento da interface.

### Por que documentar os resultados corretamente?

Imagine que você realizou uma série de testes com usuários, anotou algumas impressões e coletou dados importantes, mas deixou tudo solto em anotações pessoais ou disperso em mensagens de e-mail. Quando chegar o momento de apresentar esses resultados para a equipe de design, desenvolvimento ou stakeholders, será difícil transmitir a importância dos problemas encontrados ou justificar as mudanças propostas. Isso pode gerar retrabalho, confusão e até desvalorização do trabalho de UX.

Além disso, uma boa documentação ajuda a:

- Criar um histórico de testes para comparações futuras.
- Facilitar revisões e iterações do design.
- Garantir que as melhorias sejam baseadas em dados concretos.
- Comunicar resultados de forma transparente e acessível para equipes multidisciplinares.

### O que registrar na documentação dos testes?

Sem depender de softwares específicos, a documentação deve conter:

1. **Contexto do teste:**  
   - Objetivo do teste (o que se buscava avaliar).  
   - Perfil dos participantes (quantidade, características relevantes).  
   - Descrição das tarefas solicitadas.  
   - Tipo de teste realizado (presencial, remoto, moderado, não moderado).  

2. **Resumo dos resultados quantitativos:**  
   - Tempo médio para completar cada tarefa.  
   - Taxa de sucesso (quantos usuários conseguiram completar a tarefa).  
   - Número e tipos de erros cometidos.  
   - Satisfação geral, se foi medida (por exemplo, escala de 1 a 5).  

3. **Principais problemas identificados:**  
   - Descrição clara do problema (o que aconteceu, onde e por quê).  
   - Frequência do problema (quantos usuários foram impactados).  
   - Impacto na experiência do usuário (gravidade, consequência).  

4. **Comportamentos e comentários relevantes:**  
   - Reações espontâneas dos usuários.  
   - Dificuldades relatadas verbalmente.  
   - Sugestões ou dúvidas levantadas.  

5. **Conclusões e recomendações:**  
   - Prioridades para correção.  
   - Sugestões de melhorias baseadas nos achados.  
   - Próximos passos para validação ou refinamento do design.  

### Formato prático para documentação simples e eficaz

Você pode organizar essa documentação em um arquivo texto, planilha ou mesmo um documento estruturado em formato Markdown, que é simples, legível e pode ser compartilhado facilmente.

Veja um exemplo completo e simplificado de documentação para um teste de usabilidade:

---

# Documentação do Teste de Usabilidade – Protótipo App de Finanças

**Data:** 15/04/2024  
**Testadores:** 5 usuários (3 homens, 2 mulheres; faixa etária 25-40 anos; usuários iniciantes em apps financeiros)  
**Objetivo:** Avaliar a facilidade de cadastro e criação de orçamento mensal.  
**Tarefas:**  
- Tarefa 1: Criar uma conta no app.  
- Tarefa 2: Adicionar uma nova categoria de despesa.  
- Tarefa 3: Definir um orçamento mensal para a categoria criada.

---

### Resultados Quantitativos

| Tarefa                      | Tempo médio (min) | Taxa de sucesso | Erros principais                   |
|----------------------------|-------------------|-----------------|----------------------------------|
| Criar conta                 | 3:20              | 100%            | Nenhum                          |
| Adicionar categoria         | 4:10              | 80%             | Confusão com o botão “+” (2 erros) |
| Definir orçamento mensal    | 5:05              | 60%             | Dificuldade em localizar campo (3 erros) |

**Satisfação média:** 3,4 / 5 (baseado em perguntas pós-tarefa)

---

### Problemas Identificados

- **Botão “+” pouco visível:** 2 usuários não encontraram o botão para adicionar categoria na primeira tentativa, causando atraso e frustração.  
- **Campo de orçamento confuso:** 3 usuários relataram que o campo para digitar o valor do orçamento estava “escondido” ou com rótulo pouco claro, resultando em erros e desistência na tarefa.  
- **Feedback insuficiente:** O app não indicou claramente que a categoria foi criada com sucesso, gerando dúvidas nos usuários.

---

### Comportamentos e Comentários

- “Não sabia onde clicar para adicionar uma nova categoria.”  
- “Achei que o campo de orçamento estava desabilitado porque não tinha destaque.”  
- Alguns usuários tentaram clicar em áreas próximas ao botão “+” sem sucesso.  
- Um usuário sugeriu um tutorial rápido para a primeira vez.

---

### Conclusões e Recomendações

- **Melhorar a visibilidade do botão “+”**: aumentar tamanho e contraste, posicionar em local mais intuitivo.  
- **Revisar rótulo e destaque do campo de orçamento** para facilitar a identificação.  
- **Adicionar feedback visual claro após criação da categoria.**  
- Priorizar correção do botão e campo de orçamento para próxima versão do protótipo.

---

### Dicas para evitar erros comuns na documentação

- **Não misture opiniões pessoais com dados observados**; mantenha a objetividade.  
- **Registre os erros exatamente como ocorreram**, com exemplos claros.  
- **Use números com cuidado**: mesmo testes pequenos podem apontar tendências.  
- **Evite termos técnicos confusos para quem não é da área de UX.**  
- **Inclua citações diretas dos usuários** para dar voz a eles e enriquecer o relato.  

### Como organizar registros durante o teste para facilitar a documentação

Durante o teste, use um caderno ou uma planilha para anotar:

- Nome ou código do participante (para referência).  
- Cada tarefa realizada, com tempo e sucesso/falha.  
- Erros e dificuldades observadas, anotando quem e quando.  
- Comentários espontâneos ou respostas a perguntas.  

Após o teste, consolide essas anotações no formato de documentação, agrupando problemas similares e destacando padrões.

---

### Exercício prático

Imagine que você testou um protótipo de um site de comércio eletrônico com 4 usuários, pedindo para que eles encontrem e adicionem um produto ao carrinho. Você anotou o seguinte:

- 2 usuários não encontraram o botão “Adicionar ao carrinho” imediatamente.  
- 1 usuário demorou 6 minutos para completar a tarefa; os outros 3 demoraram cerca de 2 minutos.  
- 3 usuários comentaram que o filtro de categorias não estava claro.  
- Todos conseguiram finalizar a tarefa, mas 1 usuário clicou acidentalmente em um produto errado.

**Tarefa:** Organize essas informações em uma estrutura de documentação simples, incluindo contexto, resultados quantitativos, problemas, comportamentos e recomendações.

---

### Solução comentada

---

# Documentação do Teste de Usabilidade – Protótipo Site E-commerce

**Data:** [data do teste]  
**Testadores:** 4 usuários (perfil básico de compradores online)  
**Objetivo:** Avaliar facilidade para encontrar e adicionar produto ao carrinho.  
**Tarefa:** Localizar produto e adicioná-lo ao carrinho.

---

### Resultados Quantitativos

| Indicador                  | Resultado                         |
|---------------------------|----------------------------------|
| Tempo médio para tarefa    | (6 + 2 + 2 + 2) / 4 = 3,0 minutos |
| Taxa de sucesso            | 100% (4 de 4 usuários)            |
| Erros principais           | 1 clique errado em produto errado |

---

### Problemas Identificados

- Botão “Adicionar ao carrinho” pouco visível para 2 usuários.  
- Filtro de categorias pouco claro para 3 usuários.

---

### Comportamentos e Comentários

- “Não vi onde clicar para adicionar o produto.”  
- “Não entendi bem como funcionava o filtro para categorias.”  
- Clique acidental em produto errado por 1 usuário.

---

### Conclusões e Recomendações

- Destacar melhor o botão de adicionar ao carrinho (cor, tamanho, posição).  
- Melhorar a interface do filtro de categorias para maior clareza.  
- Avaliar possibilidades de evitar cliques errados, como confirmação ou aumento da área clicável.

---

Com essa documentação clara, qualquer membro da equipe pode compreender o que foi testado, quais foram as dificuldades reais dos usuários e como priorizar as melhorias, mesmo sem ter acompanhado o teste presencialmente.

---

Registrar os resultados de forma organizada é o que transforma um teste de usabilidade em uma ferramenta produtiva para evolução do design, comunicação eficaz e tomada de decisão fundamentada.

---