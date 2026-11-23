## Avaliação Final do Curso e Autoavaliação

A avaliação do aprendizado em contabilidade tributária, especialmente no contexto da reforma tributária e sua aplicação prática na análise tributária comparativa entre fornecedores, deve ir além da simples memorização de conceitos. É imprescindível que o profissional seja capaz de integrar conhecimentos, identificar erros comuns, validar vínculos entre códigos e realizar cálculos precisos que reflitam o custo líquido tributário real.

### Critérios para Avaliação do Aprendizado

1. **Domínio das Vinculações Entre Códigos**  
   A correta vinculação CNAE → LC116 → NBS é a espinha dorsal da análise tributária pós-reforma. Avalie sua capacidade de:  
   - Identificar e classificar corretamente atividades econômicas pelo CNAE.  
   - Vincular o CNAE ao código de serviço LC116 de forma precisa, evitando incompatibilidades.  
   - Estabelecer corretamente a relação entre LC116 e NBS para garantir a correta aplicação do ISS e apropriação de créditos tributários.  
   O erro comum aqui é a incompatibilidade de códigos, que gera mensagens literais de rejeição fiscal, como:  
   ```
   Erro: Código LC116 incompatível com CNAE informado — incompatibilidade detectada na vinculação.
   ```
   Saber reconhecer e corrigir essa mensagem é fundamental.

2. **Capacidade de Calcular Custo Líquido Tributário**  
   O cálculo correto do custo líquido, considerando preço bruto, tributos ISS, IBS e CBS, e a aplicação dos créditos tributários, é essencial. Você deve:  
   - Aplicar corretamente as bases de cálculo, alíquotas e descontos condicionais/incondicionais.  
   - Controlar a limitação legal para evitar imposto líquido negativo, ajustando o crédito quando necessário.  
   - Integrar os cálculos para os três tributos principais, conforme os exemplos em Python apresentados.  
   Erros comuns incluem:  
   - Aplicar crédito tributário indevido, resultando em imposto negativo.  
   - Esquecer de excluir impostos destacados da base de cálculo.  
   Mensagem típica:  
   ```
   Aviso: Imposto líquido negativo detectado — ajuste necessário para conformidade legal.
   ```

3. **Automação e Validação Programática**  
   Sua habilidade em implementar ou usar sistemas que automatizam:  
   - Validação das vinculações dos códigos CNAE, LC116 e NBS.  
   - Cálculo automático dos tributos e aplicação dos créditos tributários.  
   - Relatórios de erro claros e ações corretivas.  
   É importante que o sistema também mantenha atualizadas as tabelas oficiais e registre versões para garantir conformidade e auditabilidade.

4. **Análise Comparativa entre Fornecedores**  
   A decisão correta depende da avaliação do custo líquido tributário, não apenas do preço nominal. Você deve ser capaz de:  
   - Comparar fornecedores considerando preços, tributos e créditos tributários.  
   - Identificar o fornecedor mais vantajoso economicamente.  
   - Documentar e controlar os processos de análise, garantindo rastreabilidade e transparência.

### Autoavaliação Orientada

Para medir seu progresso, responda honestamente às seguintes perguntas, baseando-se em exercícios e estudos de caso realizados:

- **Você consegue identificar e corrigir erros de incompatibilidade na vinculação CNAE → LC116 → NBS?**  
  Se encontrar dificuldades, revise os exemplos práticos e mensagens de erro fornecidas.

- **Sabe calcular o custo líquido tributário para ISS, IBS e CBS, aplicando corretamente créditos e respeitando limites legais?**  
  Verifique os cálculos automáticos em Python; tente reproduzir manualmente para fixar o entendimento.

- **Está apto a automatizar a validação e cálculo tributário em sistemas, considerando atualizações das tabelas oficiais?**  
  Se ainda não, pratique a implementação dos códigos de validação e integração.

- **Consegue realizar análises comparativas entre fornecedores, considerando o impacto dos créditos tributários e tomando decisões embasadas?**  
  Faça exercícios de análise com dados reais, simulando diferentes cenários tributários.

- **Mantém a documentação e controle das análises tributárias para garantir rastreabilidade?**  
  Organize seus resultados em relatórios claros e estruturados, com registro das versões das tabelas utilizadas.

### Exercício Prático de Autoavaliação

Implemente em Python uma rotina que, dado um conjunto de fornecedores com seus preços brutos, códigos CNAE, LC116, NBS e valores de créditos tributários, execute:

- Validação automática dos vínculos CNAE → LC116 → NBS, emitindo mensagens claras de erro quando houver incompatibilidade.  
- Cálculo do custo líquido tributário para ISS, IBS e CBS, aplicando os créditos e respeitando o limite mínimo zero para imposto devido.  
- Comparação dos custos líquidos e recomendação do fornecedor mais vantajoso economicamente.  
- Geração de relatório que documenta a análise, incluindo versões das tabelas usadas e eventuais erros corrigidos.

Use os dados fictícios abaixo como base:

| Fornecedor | Preço Bruto | CNAE       | LC116  | NBS     | Créditos Tributários (R$) |
|------------|-------------|------------|--------|---------|---------------------------|
| A          | 100,00      | 1234567    | 10101  | 1001001 | 15,00                     |
| B          | 95,00       | 1234567    | 10101  | 1001001 | 5,00                      |
| C          | 105,00      | 1234567    | 10102  | 1001002 | 20,00                     |

Verifique os vínculos para cada fornecedor, corrija os erros encontrados e determine o custo líquido para cada um, indicando qual apresenta a melhor relação custo-benefício tributária.

---