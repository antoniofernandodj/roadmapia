## Exemplos de perguntas técnicas

Você está na frente do entrevistador, que abre seu laptop e diz: *"Vamos para a parte técnica"*. O coração acelera. E agora? Saber antecipadamente os tipos de perguntas que virão é como ter um mapa do território antes da batalha. Vamos desvendar os padrões mais comuns que aparecem em entrevistas técnicas reais.

### 1. Perguntas de conhecimento geral
São as "filtradoras". O entrevistador quer saber se você domina o básico necessário para a vaga:

**Exemplo real para uma vaga de desenvolvedor júnior:**
"Explique como funciona o protocolo HTTP e qual a diferença entre GET e POST."

**O que testa:**  
Conhecimento fundamental que todo profissional da área deveria ter. Uma resposta incompleta aqui pode eliminar o candidato na primeira fase.

**Armadilha comum:**  
Responder apenas "GET pega dados, POST envia dados". A entrevistadora da Amazon relatou em um fórum que 60% dos candidatos param nessa explicação superficial. O esperado é algo como:

*"GET solicita dados de um recurso específico, é idempotente e os parâmetros ficam visíveis na URL. POST envia dados para processamento, pode criar novos recursos, não é idempotente e os dados vêm no corpo da requisição, não na URL."*

### 2. Perguntas de resolução de problemas
Aqui avaliam como você pensa, não só o que sabe. Um caso clássico:

**Cenário apresentado em entrevista da Google:**
"Você tem um array não ordenado com 1 milhão de números. Como encontrar os 10 maiores valores de forma eficiente?"

**O entrevistador está observando:**  
- Se você pergunta clarificações (ex: "Os números podem se repetir?")  
- Se considera trade-offs ("Posso usar O(n log n) ou existe forma mais otimizada?")  
- Se explica o raciocínio passo a passo  

**Resposta que impressionou em caso real:**  
"Para números únicos, usaria um heap de tamanho 10. Percorro o array uma vez (O(n)), mantendo sempre os 10 maiores no heap. Inserção no heap limitado é O(log k), onde k=10, resultando em O(n log 10) ≈ O(n). Melhor que ordenar tudo (O(n log n))."

### 3. Perguntas de depuração (debugging)
Mostram como você lida com problemas reais. Um exemplo de entrevista na Microsoft:

"Um cliente reporta que o sistema fica lento às 9h toda segunda-feira. Como você investigaria?"

**Resposta estruturada que funcionou:**  
1. Verificaria logs de performance no horário reportado  
2. Analisaria métricas de uso (pico de acessos? batch jobs agendados?)  
3. Compararia com baseline de outros horários  
4. Verificaria dependências externas (APIs terceiras sofrendo lentidão?)  

**Erro frequente:**  
Pular direto para "aumentar os servidores" sem antes diagnosticar a causa raiz.

### 4. Perguntas de arquitetura/escala
Comuns para vagas sênior. Caso real de entrevista na Netflix:

"Como você projetaria um sistema de recomendação de filmes para 50 milhões de usuários simultâneos?"

**O que diferencia:**  
- Considerar particionamento de dados por região geográfica  
- Balanceamento entre recomendações em cache e personalizadas  
- Estratégias para cold start (usuários novos)  

### 5. Perguntas de codificação ao vivo
O pesadelo de muitos candidatos. Exemplo de problema dado em uma entrevista da Meta:

"Implemente uma função que inverta uma string sem usar métodos auxiliares como reverse()."

**Solução esperada (em Python):**
```python
def inverte_string(s):
    return s[::-1]
```

**Mas o que realmente avaliam:**  
- Se você escreve testes ("E se a string for vazia? E caracteres Unicode?")  
- Se pergunta requisitos ("Precisa ser in-place ou posso retornar nova string?")  
- Se explica complexidade ("O(1) para slicing em Python pois strings são imutáveis")  

### 6. Perguntas de cultura técnica
Avaliam seu engajamento com a área. Pergunta feita em startup de IA:

"Que papers ou blogs técnicos você acompanhou recentemente que acha relevantes para nossa área?"

**Resposta que se destacou:**  
"Tenho acompanhado as evoluções do Transformer Architecture, especialmente o paper 'Attention Is All You Need'. Para otimizações práticas, sigo o blog da OpenAI sobre técnicas de fine-tuning em LLMs."

### Exercício prático

**Cenário:** Você está se candidatando a uma vaga de analista de dados. O entrevistador pergunta:

"Como você explicaria o conceito de normalização de banco de dados para um colega não técnico?"

**Solução comentada:**  
"Imagine que você tem uma planilha onde repete o endereço completo de cada cliente em todas as compras. Se o cliente mudar de endereço, precisamos atualizar em todas as linhas. A normalização é como organizar esses dados em tabelas separadas (clientes, pedidos), ligadas por IDs, assim atualizamos só em um lugar."

*Por que funciona:*  
- Usa analogia com planilha (familiar para não técnicos)  
- Mostra problema concreto antes da solução  
- Explica benefício prático ("atualizar só em um lugar")  

Este trecho lhe deu um repertório real de perguntas técnicas. Na próxima seção, veremos como estruturar respostas matadoras para cada tipo desses desafios.