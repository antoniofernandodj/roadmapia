## Alíquotas Vigentes do ISS, IBS e CBS

Para o correto desenvolvimento de sistemas fiscais e tomada de decisão na escolha de fornecedores, conhecer as alíquotas vigentes dos principais tributos — ISS, IBS e CBS — é fundamental. Essas alíquotas são aplicadas sobre as bases de cálculo, já detalhadas em capítulos anteriores, e variam conforme a legislação municipal, estadual e federal vigente, especialmente após a reforma tributária.

### Alíquotas do ISS (Imposto Sobre Serviços)

O ISS é um tributo municipal que incide sobre a prestação de serviços listados na Lei Complementar 116, com aplicação direta sobre o valor do serviço prestado. Após a reforma tributária e as atualizações recentes da LC116 e da tabela de serviços, as alíquotas do ISS permanecem definidas pelos municípios, mas seguem parâmetros gerais que orientam a aplicação:

- **Faixa geral de alíquotas**: de **2% a 5%** sobre o valor do serviço.
- **Alíquotas específicas**: podem variar dentro dessa faixa conforme o município e o tipo de serviço, identificado pela vinculação do CNAE, LC116 e NBS.
- **Exemplo prático de variação**:
  - Serviços de consultoria: geralmente 2% a 3%
  - Serviços de construção civil: até 5%
  - Serviços educacionais: faixa inferior, dependendo da municipalidade

A alíquota específica para cada serviço deve ser consultada na legislação municipal aplicável, considerando o código do serviço LC116 vinculado ao CNAE do fornecedor.

### Alíquotas do IBS (Imposto sobre Bens e Serviços)

O IBS, imposto estadual unificado, foi criado para simplificar e substituir tributos como ICMS, ISS e outros, aplicando-se de forma ampla sobre operações envolvendo bens e serviços. A alíquota do IBS é padronizada em âmbito estadual, com pequenas variações entre estados, conforme regulamentações locais, mas a reforma tributária estabelece parâmetros uniformes para facilitar a integração e evitar a cumulatividade.

- **Alíquota padrão do IBS**: geralmente entre **7% a 12%**.
- **Alíquota média aplicada**: próxima de **10%**, segundo propostas federais, mas ainda sujeita a legislação estadual.
- **Aplicação**:
  - Incide sobre a base ampla que inclui valor da operação, encargos e exclusão dos créditos tributários.
  - Permite apropriação e compensação de créditos tributários ao longo da cadeia produtiva.
  
É imprescindível, para sistemas fiscais, manter a tabela de alíquotas atualizada conforme o estado de operação do fornecedor, pois a variação pode impactar diretamente o custo líquido tributário.

### Alíquotas do CBS (Contribuição sobre Bens e Serviços)

A CBS é uma contribuição federal unificada que substitui a Cofins e a PIS/Pasep sobre bens e serviços, com o objetivo de simplificar a arrecadação e reduzir a cumulatividade no âmbito federal. Após a reforma tributária, a alíquota da CBS está padronizada para facilitar o cálculo e a apropriação de créditos.

- **Alíquota padrão da CBS**: **12%** sobre a receita bruta.
- **Características**:
  - Não cumulativa, permitindo créditos tributários para evitar bitributação.
  - Aplicada uniformemente independentemente do setor, salvo exceções específicas reguladas.
- **Regra prática**:
  - A alíquota de 12% deve ser aplicada sobre a receita, descontando-se créditos tributários permitidos.
  - O cálculo deve assegurar que o imposto devido não seja negativo.

### Resumo das Alíquotas Vigentes

| Tributo | Alíquota Padrão / Faixa | Incidência | Observação |
|---------|-------------------------|------------|------------|
| ISS     | 2% a 5%                 | Serviços   | Variável por município e tipo de serviço (CNAE x LC116 x NBS) |
| IBS     | 7% a 12% (média 10%)    | Bens e Serviços | Variável por estado, base ampla, crédito compensável |
| CBS     | 12%                     | Receita bruta | Federal, não cumulativa, créditos permitidos |

### Pontos Importantes para Sistemas e Desenvolvimento

- As alíquotas precisam estar **atualizadas periodicamente** conforme alterações legislativas municipais, estaduais e federais.
- A vinculação do CNAE ao código de serviço LC116 e ao NBS é essencial para identificar corretamente a alíquota do ISS.
- Para o IBS, é necessário considerar a **estado de origem e destino** da operação para aplicar a alíquota correta e gerir créditos tributários.
- A CBS, com alíquota fixa federal, requer atenção especial aos créditos e à base de cálculo para evitar erros no cálculo do imposto devido.
- Sistemas fiscais devem conter tabelas dinâmicas e rotinas de atualização automática para essas alíquotas, garantindo precisão e conformidade.

---