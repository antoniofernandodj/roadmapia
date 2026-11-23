## Importância da Conformidade para a Escolha de Fornecedores

Ao decidir contratar um fornecedor, o foco tradicional costuma ser o preço bruto da oferta. No entanto, na realidade tributária atual, especialmente após a reforma tributária, essa visão é incompleta e pode levar a decisões economicamente desfavoráveis. A conformidade tributária do fornecedor — isto é, o correto enquadramento e cumprimento das obrigações acessórias, e a correta vinculação entre códigos CNAE, LC116 e NBS — é um elemento crucial para assegurar que os créditos tributários gerados possam ser apropriados, reduzindo o custo líquido da contratação.

### Por que as obrigações acessórias influenciam a escolha do fornecedor?

Obrigações acessórias são os documentos, declarações e registros fiscais que a empresa deve manter e entregar para que suas operações sejam consideradas válidas perante o fisco. No contexto do ISS, IBS e CBS, essas obrigações incluem, entre outras, a emissão correta da Nota Fiscal de Serviços Eletrônica (NFS-e), a Escrituração Fiscal Digital (EFD) e declarações relativas aos créditos tributários. Se um fornecedor não cumpre rigorosamente essas obrigações, o comprador pode ter sua própria apuração de créditos comprometida, pois a legislação exige documentos fiscais válidos e corretamente preenchidos para que o crédito seja reconhecido.

Imagine que a empresa A oferece um serviço por R$ 100,00 e gera um crédito tributário de R$ 15,00 para quem o contratar, enquanto a empresa B cobra R$ 95,00, mas não cumpre corretamente as obrigações acessórias, inviabilizando o aproveitamento dos créditos. Sem a análise da conformidade, a escolha pelo menor preço (empresa B) resultaria em custo líquido superior, pois o crédito de R$ 15,00 não será reconhecido. Portanto, a conformidade é um pré-requisito para que a análise tributária possa ser confiável.

### Mecanismos da conformidade tributária no pós-reforma

Após a reforma tributária, a vinculação entre os códigos CNAE, LC116 e NBS tornou-se obrigatória para validar a emissão correta da NFS-e e a apropriação dos créditos tributários. Essa integração funciona como uma “trava” automática nos sistemas fiscais: a emissão de uma nota fiscal com código LC116 incompatível com o CNAE do fornecedor ou com o código NBS incorreto é rejeitada pela autoridade fiscal, impedindo a geração de documentos que possam ser usados para crédito.

Por exemplo, se um fornecedor com CNAE 62.01-5/01 (desenvolvimento de software) emitir uma NFS-e com um código de serviço LC116 que não corresponda a essa atividade, o documento será rejeitado. A mensagem de erro típica pode ser:

```
Rejeição: Código de serviço LC116 incompatível com o CNAE informado.
```

Esse erro não apenas impede a emissão da nota, como, caso ocorra após emissão, pode acarretar na perda do crédito tributário pelo tomador do serviço, além de multas para o fornecedor. Portanto, garantir a conformidade exige validar previamente a vinculação correta desses códigos, além de observar os prazos para entrega das obrigações acessórias, como a NFS-e e a EFD.

### Impacto da conformidade na análise tributária comparativa entre fornecedores

O processo decisório sobre qual fornecedor contratar deve incluir a avaliação da conformidade tributária, porque:

1. **Garantia da apropriação de créditos**: Sem documentos fiscais válidos e devidamente vinculados, o crédito tributário não pode ser apropriado, elevando o custo líquido da operação.

2. **Redução de riscos fiscais e financeiros**: Obrigações acessórias não cumpridas podem resultar em multas, autuações e bloqueios fiscais, afetando a relação com fornecedores e a saúde financeira da empresa.

3. **Automação confiável em sistemas fiscais**: Sistemas de gestão tributária modernos dependem da validação automática da vinculação CNAE x LC116 x NBS para evitar erros e rejeições fiscais. Fornecedores em conformidade permitem a integração segura dessas informações.

4. **Transparência e competitividade**: A conformidade evidencia a qualidade fiscal do fornecedor, que pode ser fator decisivo em processos licitatórios, contratos e auditorias.

### Exemplo prático: Simulação de escolha considerando conformidade

Suponha que você tenha dois fornecedores com as seguintes condições:

| Fornecedor | Preço Bruto | Crédito Tributário Gerado | Cumprimento das Obrigações Acessórias | Nota Fiscal Emitida |
|------------|-------------|---------------------------|---------------------------------------|---------------------|
| A          | R$ 100,00   | R$ 15,00                  | Completo e correto                     | NFS-e válida        |
| B          | R$ 95,00    | R$ 0,00                   | Incompleto, código LC116 incompatível | NFS-e rejeitada     |

O fornecedor B, apesar do preço bruto menor, não emite uma NFS-e válida, impedindo o aproveitamento do crédito e expondo a empresa a riscos fiscais. A análise correta considera o custo líquido:

- Fornecedor A: R$ 100,00 - R$ 15,00 = R$ 85,00
- Fornecedor B: R$ 95,00 - R$ 0,00 = R$ 95,00 (sem crédito)

Portanto, a decisão pela escolha do fornecedor A é mais vantajosa economicamente.

### Erro comum na prática e sua correção

Um erro muito comum ocorre na emissão da NFS-e por fornecedores que não atualizam as tabelas ou não validam a compatibilidade dos códigos usados. A mensagem de rejeição abaixo é frequente:

```
Rejeição: Código LC116 incompatível com o CNAE informado na nota fiscal.
```

Esse erro impede que a nota seja aceita para fins de crédito tributário. Para corrigir, o fornecedor deve consultar as tabelas oficiais atualizadas e validar a vinculação do seu CNAE com o código LC116 correto, conforme previsto na legislação vigente, além de garantir a correta indicação do código NBS. A validação pode ser automatizada em sistemas fiscais para evitar esse tipo de problema.

### Conformidade e obrigações acessórias: uma relação direta

O cumprimento das obrigações acessórias vai além da emissão da NFS-e. A entrega correta das declarações, escrituração fiscal e controles de crédito são fundamentais para:

- Evitar multas e autuações.
- Garantir a integridade e validade dos créditos tributários.
- Facilitar auditorias internas e fiscalização externa.
- Manter a reputação fiscal do fornecedor e do tomador.

Esse conjunto de obrigações acessórias forma a base para a análise tributária eficiente e segura na escolha de fornecedores.

---

## Exercício proposto

Considere um fornecedor com o CNAE 62.01-5/01 que emite uma NFS-e com código LC116 incorreto. Pesquise o código LC116 correto para esse CNAE, simule a rejeição da nota fiscal devido à incompatibilidade e corrija a emissão. Explique o impacto dessa correção na apropriação do crédito tributário para a empresa tomadora do serviço.

---