## O que é uma entrevista técnica?

Imagine que você está construindo uma ponte. O entrevistador comportamental já avaliou se você trabalha bem em equipe (cap. 2), mas agora o engenheiro-chefe precisa saber: você realmente entende como calcular a carga máxima que os pilares suportam? Essa é a essência da entrevista técnica — uma conversa focada em validar suas habilidades práticas para executar as tarefas específicas da vaga.

### O teste por trás da conversa
Diferente da entrevista comportamental, que avalia "como" você age, a técnica examina "se" você consegue fazer. Um desenvolvedor será questionado sobre algoritmos, um contador sobre demonstrações financeiras, um enfermeiro sobre protocolos de emergência. O formato varia:

1. **Problemas teóricos**: "Como você otimizaria uma busca em um banco de dados com milhões de registros?"
2. **Exercícios práticos**: "Escreva uma função que calcule o fatorial de um número nesta lousa digital."
3. **Análise de casos**: "Este relatório fiscal tem um erro. Como você o identificaria e corrigiria?"

### Por que as empresas usam essa abordagem?
Um estudo da Harvard Business Review revelou que 85% das demissões por desempenho ocorrem por falhas em habilidades técnicas, não comportamentais. A entrevista técnica é uma "prova de estresse" controlada que:

- **Evita o efeito currículo**: Mesmo candidatos com ótimas universidades no currículo podem não resolver problemas reais.
- **Testa aprendizagem ativa**: Mostrar como você estrutura um problema desconhecido vale mais que decorar respostas.
- **Exibe raciocínio sob pressão**: A habilidade de pensar claramente quando nervoso é tão importante quanto o conhecimento técnico.

### O erro clássico (e como evitá-lo)
Candidatos iniciantes frequentemente caem na armadilha do "eu sei fazer, só não sei explicar". Veja este diálogo real de uma entrevista para analista de dados:

**Entrevistador**: "Como você trataria valores ausentes em uma coluna crítica?"  
**Candidato**: "Ah, eu apagaria as linhas com problema. No estágio sempre fiz assim."  
*(Resposta que gerou reprovação — a solução destrutiva ignora alternativas como imputação de dados)*  

A versão técnica correta exigiria:  
1. Diagnosticar a causa dos dados ausentes (erro de digitação? não coleta?)  
2. Avaliar o impacto estatístico da remoção  
3. Sugerir métodos de substituição baseados na distribuição dos dados  

### Como reconhecer uma pergunta técnica
Fique atento a esses gatilhos linguísticos:  
- **Verbos de ação**: "Implemente", "Calcule", "Debugue"  
- **Termos específicos**: "O(n)", "Margem de contribuição", "PCR"  
- **Cenários hipotéticos**: "Se um cliente reportar X, como você validaria Y?"  

No próximo tópico, veremos como decifrar exatamente o que o entrevistador está testando em cada uma dessas perguntas — mas por ora, lembre-se: uma entrevista técnica bem-sucedida não é sobre acertar tudo, mas sobre demonstrar um método de trabalho confiável.  

**Exercício**: Você está se candidatando a uma vaga de suporte técnico. O entrevistador pergunta: "Um usuário diz que o sistema 'fica lento' às 14h diariamente. Como você investigaria?"  

*Solução comentada*:  
1. **Coleta de dados**: Pedir logs de desempenho do horário, verificar se há processos agendados.  
2. **Padrão temporal**: Cruzar com picos de acesso ou backups automáticos.  
3. **Ação**: Propor teste de desativação de processos suspeitos em ambiente controlado.  
*(Nota: Mesmo sem diagnóstico final, o método sistemático impressiona mais que palpites)*