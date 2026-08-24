## Demonstrando conhecimento técnico

Você está diante do entrevistador e ele pergunta: "Como você resolveria um problema de lentidão em um banco de dados PostgreSQL com 5 milhões de registros?" Sua mente dispara. Você conhece PostgreSQL, já trabalhou com bancos de dados grandes, mas como demonstrar isso de forma convincente?

O erro mais comum aqui é a resposta genérica: "Eu criaria índices e analisaria as queries". Isso mostra superficialidade. O entrevistador quer ver seu raciocínio técnico em ação, não um checklist de otimizações.

Vamos dissecar uma resposta exemplar:

**1. Contextualize o problema (mostre que entende a complexidade)**
"Em um cenário com 5 milhões de registros, problemas de performance geralmente aparecem em operações de JOIN, ORDER BY ou filtros complexos. Primeiro, eu identificaria as queries problemáticas usando EXPLAIN ANALYZE..."

Observe como isso difere de dizer simplesmente "eu usaria EXPLAIN". Você demonstra conhecimento do tamanho do desafio.

**2. Mostre profundidade técnica (sem jargão vazio)**
"...analisaria o plano de execução para identificar sequential scans desnecessários. Para tabelas frequentemente acessadas, consideraria:
- Índices compostos nos campos filtrados
- Particionamento por range para dados históricos
- Ajuste do work_mem para operações de sorting grandes"

Cada ponto é específico e mostra compreensão real. Compare com: "Eu faria otimizações e criaria índices".

**3. Admita o que não sabe (isso é força, não fraqueza)**
"Se o gargalo estivesse nas escritas, eu pesquisaria sobre configurações de WAL e fsync, pois minha experiência principal está em otimização de leitura."

Isso demonstra honestidade intelectual - crucial em ambientes técnicos.

**Pegadinha clássica:** Quando perguntarem "Você conhece [tecnologia X]?", não diga apenas "Sim". Prove:

"Sim, trabalhei com Redis como cache para uma API Django. Implementamos invalidação por tempo e por eventos, reduzindo a carga no banco principal em 40%."

**Exercício prático:** Você é questionado sobre lidar com requisições concorrentes em uma API REST. Escreva uma resposta demonstrando conhecimento técnico.

**Solução comentada:**
"Para concorrência em APIs REST, abordaria em três níveis:
1) Aplicação: Implementaria locks otimistas com versionamento (ETags) para evitar conflitos em escritas
2) Banco de dados: Usaria transações com o nível de isolamento apropriado (ex: REPEATABLE READ para consistência)
3) Infraestrutura: Consideraria rate limiting baseado em tokens para evitar abuso, com backpressure via filas quando necessário"

Observe como:
- Organiza a resposta em camadas
- Usa termos técnicos precisos (ETags, backpressure)
- Mostra compreensão de tradeoffs (isolamento vs performance)