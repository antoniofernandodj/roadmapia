## Ética em Tecnologia

Um engenheiro de inteligência artificial descobre que seu algoritmo de recrutamento penaliza currículos com nomes femininos. Um desenvolvedor de redes sociais percebe que o design de rolagem infinita causa vício em adolescentes. Um técnico em biotecnologia é pressionado a acelerar testes de uma vacina sem protocolos completos. Esses não são problemas técnicos — são dilemas éticos que surgem quando a tecnologia avança mais rápido que nossa capacidade de avaliar suas consequências.

A ética em tecnologia não questiona *se* podemos desenvolver algo, mas *se devemos*. Enquanto a engenharia pergunta "como fazer funcionar", a ética pergunta "quem será afetado e de que forma". Considere os carros autônomos: a programação para decisões em acidentes inevitáveis (o "problema do bonde" digital) envolve escolher entre proteger o passageiro ou pedestres — uma decisão moral codificada em algoritmos.

**Mecanismos de impacto ético**  
Toda tecnologia opera em três níveis de consequências:  
1. **Direto**: Efeitos imediatos do uso (ex.: vazamento de dados em um app de saúde)  
2. **Estrutural**: Mudanças em comportamentos sociais (ex.: redes sociais redefinindo atenção humana)  
3. **Epistêmico**: Alteração no que consideramos verdade (ex.: deepfakes minando confiança em evidências visuais)  

O caso dos *chatbots* ilustra isso. Quando um modelo de linguagem gera discurso de ódio, não é um "bug", mas reflexo de vieses nos dados de treinamento — que por sua vez espelham preconceitos sociais existentes. Corrigir isso exige mais que ajustes técnicos; demanda um *framework* ético para curadoria de dados.

**Ferramentas para análise ética**  
1. **Matriz de riscos**: Lista impactos potenciais em eixos como privacidade, justiça e autonomia. Para um app de reconhecimento facial:  
   ```markdown
   | Dimensão    | Risco                     | Mitigação                |
   |-------------|---------------------------|--------------------------|
   | Privacidade | Coleta sem consentimento  | Opt-in explícito         |
   | Justiça     | Viés racial em algoritmos | Diversidade nos datasets |
   | Autonomia   | Vigilância constante       | Limites de uso policial  |
   ```

2. **Teste de reversibilidade**: "Se esta tecnologia fosse usada contra mim, eu aceitaria?" Um sistema de crédito baseado em *big data* pode parecer neutro até beneficiários perceberem que são negados por fatores como histórico de buscas.

3. **Simulação de consequências**: Antecipar efeitos em cascata. A introdução de *likes* em redes sociais parecia inócua, mas gerou indústrias de *influencers* e distúrbios de autoimagem.

**Erros comuns e correções**  
- *Falácia da neutralidade*: "A tecnologia é só uma ferramenta; o uso é que é bom ou ruim". Na prática, tecnologias carregam valores em seu design.  
  **Correção**: Analisar decisões de projeto. Um fórum online que prioriza engajamento (mesmo conteúdo inflamatório) não é neutro — seu algoritmo *projetou* a polarização.

- *Viés da inovação*: Pressupor que "mais tecnologia = sempre melhor".  
  **Exemplo concreto**:  
  ```python
  # Código para classificar empréstimos (versão problemática)
  def aprovar_emprestimo(renda, CEP):
      return renda > 3000 or CEP in zonas_ricas
  ```
  Mesmo funcionando, o código perpetua desigualdades ao usar CEP como *proxy* para raça. A versão ética exigiria:  
  ```python
  def aprovar_emprestimo(renda, score_credito, historico):
      return (renda > 2000 and score_credito > 600) or historico.positivo
  ```

**Exercício prático**  
Um hospital quer implementar triagem automatizada na emergência usando IA. Desenvolva:  
1. Dois riscos éticos específicos  
2. Uma cláusula para contrato de desenvolvimento que mitigue cada risco  
3. Um protocolo de auditoria pós-implantação  

**Solução comentada**:  
1. *Riscos*:  
   - Viés contra condições raras (o modelo sub-representa casos atípicos)  
   - Desresponsabilização humana ("o algoritmo errou" como desculpa)  

2. *Cláusulas*:  
   - "O dataset de treino deve incluir pelo menos 15% de casos raros validados por médicos"  
   - "Decisões de priorização devem sempre ter revisão humana em até 5 minutos"  

3. *Auditoria*:  
   - Revisão mensal de falsos negativos (pacientes classificados como não urgentes que pioraram)  
   - Painel diverso (médicos, pacientes, especialistas em ética) para avaliar impactos