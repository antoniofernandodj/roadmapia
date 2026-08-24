## Preparação para perguntas técnicas

Imagine que você está diante do entrevistador e ele pergunta: *"Como você resolveria um problema de lentidão em um banco de dados?"* Se sua mente ficar em branco ou sua resposta for genérica demais, a oportunidade escorre pelos dedos. O erro mais comum aqui não é a falta de conhecimento técnico, mas a falta de um **método claro para organizar e articular o que você sabe**.

### Por que a preparação técnica falha (e como consertar)

1. **O problema do "eu sei, mas não sei explicar"**:  
   Você reconhece este trecho de código quando vê:
   ```python
   def fibonacci(n):
       if n <= 1:
           return n
       else:
           return fibonacci(n-1) + fibonacci(n-2)
   ```
   Mas na entrevista, ao ser questionado sobre complexidade algorítmica, trava. A solução? **Prática vocalizada** - explique conceitos em voz alta como se estivesse ensinando. Grave-se respondendo:  
   *"Este é um algoritmo recursivo de Fibonacci. Sua complexidade é O(2^n) porque... [complete]"*

2. **A armadilha do "estudei tudo superficialmente"**:  
   Candidatos frequentemente pesquisam "top 50 perguntas técnicas" e decoram respostas prontas. Quando o entrevistador pergunta algo como *"Como você implementaria um sistema de cache distribuído?"*, a resposta decorada não se encaixa. O remédio é o **estudo em profundidade de 3-5 tópicos-chave** do seu currículo.

### Técnica do "Túnel de Preparação"

1. **Mapeie seu conhecimento real**  
   Crie uma tabela honesta dividindo suas habilidades em:

   | Tópico          | Nível (1-5) | Posso explicar? | Posso codificar? | Exemplo concreto |
   |-----------------|-------------|-----------------|------------------|------------------|
   | Estrutura de dados | 4           | Sim             | Sim              | Implementei uma hash table em Java no projeto X |
   | Arquitetura REST  | 3           | Parcialmente    | Não              | Consumi APIs no estágio, mas não projetei |

2. **Construa sua "biblioteca de casos"**  
   Para cada tópico da tabela acima, prepare:
   - 1 **definição técnica** (curta)
   - 1 **exemplo de aplicação** (do seu histórico)
   - 1 **erro comum** + solução
   - 1 **pergunta avançada** (que você NÃO sabe, mas pesquisará)

   Exemplo para *SQL*:
   ```markdown
   ### JOINs em SQL
   **Definição**: Operação que combina linhas de duas ou mais tabelas...
   
   **Caso real**: No sistema de pedidos da empresa Y, otimizei uma query com INNER JOIN que reduziu o tempo...
   
   **Armadilha**: LEFT JOIN vs RIGHT JOIN - esquecer que a ordem das tabelas altera o resultado. Solução: [exemplo]
   
   **Para pesquisar**: Como otimizar JOINs em bancos com milhões de registros?
   ```

3. **Simulações com cronômetro**  
   Pratique com o método STAR (Situação, Tarefa, Ação, Resultado), mas adaptado para respostas técnicas:

   *"Quando enfrentamos lentidão nas queries (Situação), precisávamos reduzir o tempo abaixo de 2s (Tarefa). Analisei o EXPLAIN PLAN e recriei os índices (Ação), o que cortou 70% do tempo de resposta (Resultado). Se fosse hoje, testaria também particionamento."*

### Erro que você vai cometer (e como evitar)

**Sintoma**: Durante a entrevista, você começa: *"Bem, sobre otimização de consultas... são várias formas... talvez criar índices... ou..."*

**Problema**: Resposta desconexa demonstra falta de método.

**Correção**: Use a estrutura **D.E.E.P**:
- **D**efinição (1 frase)
- **E**xemplo (seu caso)
- **E**rro comum (mostra experiência)
- **P**erspectiva (o que está estudando agora)

Exemplo refeito:  
*"Otimização de consultas envolve técnicas para reduzir tempo de execução (Definição). No meu estágio, uma query demorava 8s - ao analisar com EXPLAIN, vi scans completos da tabela. Adicionei um índice composto nas colunas filtradas (Exemplo). Um erro frequente é indexar todas as colunas, o que prejudica inserts (Erro). Agora estudo como estatísticas do banco afetam esses planos (Perspectiva)."*

### Exercício prático

Selecione um tópico técnico do seu currículo e construa:

1. Uma **definição técnica** em 15-30 palavras
2. Um **exemplo real** (mesmo que de estudos)
3. Um **erro comum** relacionado
4. Uma **pergunta avançada** sobre o tema

**Solução exemplo (Front-end):**

1. **Definição**: Virtual DOM é uma representação leve do DOM real que permite atualizações eficientes ao comparar diferenças.
2. **Caso**: No projeto do curso, implementei um renderizador condicional que evitava 200ms de reflow desnecessário.
3. **Armadilha**: Esquecer que keys estáveis são cruciais para a reconciliação do React.
4. **Pesquisar**: Como o React 18 melhorou o algoritmo de diffing com lane prioritization?

Compare sua resposta com este modelo. Falta algum elemento? Ajuste até que possa responder qualquer pergunta sobre o tópico em no máximo 2 minutos, com começo-meio-fim claros.