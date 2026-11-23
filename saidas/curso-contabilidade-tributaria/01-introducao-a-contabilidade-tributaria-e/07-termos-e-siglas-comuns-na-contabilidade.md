## Termos e Siglas Comuns na Contabilidade Tributária

Na contabilidade tributária, especialmente após a reforma tributária, entender os termos e siglas mais usados é fundamental para interpretar corretamente os documentos fiscais, integrar sistemas, aplicar regras e comparar fornecedores. Embora alguns desses termos sejam familiares, o contexto tributário exige precisão para evitar erros que podem causar impactos financeiros significativos.

### CNAE (Classificação Nacional de Atividades Econômicas)

Como já conhecido (ver 2.1 e 2.2), o CNAE identifica a atividade econômica principal de uma empresa. É a base para definir quais tributos incidem, quais créditos são possíveis e como vincular os códigos de serviço e mercadorias. A leitura correta do código CNAE evita erros na apropriação de créditos e na emissão de notas fiscais.

### LC 116 (Lei Complementar 116)

Esta lei regulamenta o ISS, o imposto municipal sobre serviços. O código de serviço da LC116 (ver 3.2) é usado para classificar cada tipo de serviço tributado. A correta associação do CNAE ao código LC116 permite identificar a tributação exata do serviço prestado, essencial para o cálculo do ISS e para entender a ausência ou presença de créditos tributários nesse imposto.

### NBS (Nomenclatura Brasileira de Serviços)

A NBS (ver 4.1) detalha os serviços de forma padronizada, vinculando-se ao código de serviço LC116 para garantir uniformidade na classificação. Isso é crucial para sistemas que automatizam o cálculo do ISS e para a integração com o CNAE, pois permite a identificação precisa do tipo de serviço.

### NCM (Nomenclatura Comum do Mercosul)

O NCM (ver 4.4) é a classificação oficial usada para mercadorias, essencial para aplicação correta de tributos federais e estaduais, como ICMS e IBS. Conhecer o NCM completo evita erros na tributação de bens e na apropriação de créditos fiscais.

### ISS, IBS e CBS

- **ISS (Imposto Sobre Serviços)**: Tributo municipal que incide sobre a prestação de serviços listados na LC116. Não admite crédito tributário para abatimento, o que diferencia sua análise tributária (ver 5.1).

- **IBS (Imposto sobre Bens e Serviços)**: Tributo unificado que integra parte dos tributos federais e estaduais sobre bens e serviços, permitindo crédito tributário e alíquotas uniformes. Sua aplicação exige integração do CNAE, LC116 e NBS (ver 5.2).

- **CBS (Contribuição sobre Bens e Serviços)**: Substitui o PIS/Cofins, incide sobre o faturamento e permite crédito tributário, complementando o IBS (ver 5.3).

Saber distinguir esses tributos e suas regras de crédito é essencial para a correta apuração do custo líquido tributário.

### cTribNac (Códigos de Tributação Nacionais)

São códigos oficiais usados para identificar a tributação aplicada a uma operação, integrando informações do CNAE, LC116, NBS e NCM (ver 6.1). A correta aplicação dos cTribNac permite automatizar o cálculo tributário, evitar erros comuns e comparar fornecedores considerando custos líquidos tributários.

### Crédito Tributário

Apesar de já conhecido, reforçamos que o crédito tributário é o valor que pode ser abatido do imposto devido, reduzindo o custo líquido da operação. A correta identificação dos créditos depende da integração dos códigos CNAE, LC116 e NBS, além do entendimento dos tributos que permitem ou não crédito (ver 7.7).

---

### Termos Complementares Importantes

- **Base de Cálculo**: Valor sobre o qual incide o tributo, podendo ser o preço de venda, faturamento ou outra referência definida por lei.

- **Alíquota**: Percentual aplicado sobre a base de cálculo para determinar o valor do tributo.

- **Substituição Tributária e Retenção**: Regras que podem alterar o responsável pelo recolhimento do tributo, impactando o cálculo e a apropriação do crédito.

- **Obrigações Acessórias**: Documentações e declarações que as empresas devem apresentar para comprovar a correta apuração e recolhimento dos tributos.

---

### Exemplo Prático de Uso das Siglas

Imagine dois fornecedores:

| Fornecedor | Preço Bruto | CNAE          | Código LC116 | Código NBS  | Crédito Tributário |
|------------|-------------|---------------|--------------|-------------|--------------------|
| A          | R$ 100,00   | 62.01-5-01    | 0101         | 01.01.01    | R$ 15,00           |
| B          | R$ 95,00    | 62.02-3-02    | 0202         | 02.02.02    | R$ 0,00            |

Para decidir o fornecedor mais vantajoso, o sistema vincula o CNAE ao código LC116 e depois ao NBS. Com isso, calcula o custo líquido considerando o crédito tributário permitido, mostrando que, apesar do preço bruto maior, o fornecedor A é mais barato após crédito.

---

### Erro Comum ao Usar Termos e Siglas

Um erro frequente é confundir os códigos ou aplicar créditos indevidos, por exemplo, tentar apropriar crédito do ISS, que não permite, ou vincular o CNAE errado ao código LC116, gerando cálculo incorreto de tributos e custos.

Exemplo de erro:

```plaintext
Erro: Crédito tributário do ISS não permitido para o código de serviço informado.
```

Solução: Verifique a lista oficial da LC116 e a vinculação correta com o CNAE e NBS para garantir a inexistência de crédito no ISS.

---

### Exercício Proposto

Dado dois fornecedores com preços brutos, seus respectivos CNAE, códigos LC116 e NBS, e a informação sobre créditos tributários possíveis, calcule o custo líquido de cada um e indique qual é a opção mais vantajosa para a empresa.

---