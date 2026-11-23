## Documentação Fiscal Necessária para Compliance

Para garantir compliance tributário eficiente e seguro, especialmente no contexto da reforma tributária que integra CNAE, LC116, NBS e demais códigos, é imprescindível a organização e manutenção rigorosa da documentação fiscal. A ausência ou incorreção desses documentos pode gerar erros na apuração dos tributos ISS, IBS e CBS, impedir a apropriação correta dos créditos tributários e resultar em multas e autuações fiscais. Este trecho detalha os documentos fiscais essenciais para a conformidade na contabilidade tributária, destacando sua finalidade, conteúdo obrigatório e o papel na validação cruzada de códigos tributários.

### 1. Nota Fiscal Eletrônica de Serviços (NFS-e)

A NFS-e é o documento fiscal eletrônico que comprova a prestação de serviços tributados pelo ISS e, a partir da reforma, sua emissão deve refletir a vinculação correta entre o CNAE do prestador, o código de serviço LC116 e o código NBS correspondente. Essa integração é fundamental para que o sistema fiscal reconheça a operação e permita a apropriação do crédito tributário do ISS.

**Informações essenciais na NFS-e:**

- **Dados do prestador:** Razão social, CNPJ, endereço e CNAE completo (com a subclassificação correta).
- **Código de serviço LC116:** Deve corresponder exatamente ao serviço prestado, conforme a lista oficial atualizada.
- **Código NBS:** Necessário para detalhamento e validação do serviço tributado, garantindo conformidade com a legislação municipal.
- **Valor do serviço:** Base de cálculo para ISS, IBS e CBS, conforme regras específicas.
- **Alíquota aplicada:** Deve estar de acordo com a legislação municipal e a vinculação dos códigos.
- **Informação sobre créditos tributários:** Indicação clara do crédito gerado, se houver.

**Erro comum na emissão:**  
Um erro recorrente é a incompatibilidade entre o CNAE e o código de serviço LC116, que resulta na rejeição da NFS-e com a mensagem literal:

```
Erro: Código LC116 incompatível com o CNAE informado. Verifique a vinculação e corrija antes de reenviar.
```

**Solução prática:**  
Consultar a tabela vinculativa atualizada CNAE x LC116 e realizar a correção imediata na emissão da NFS-e para garantir a aceitação automática e o aproveitamento dos créditos (ver 3.12 e 6.4).

### 2. Nota Fiscal Eletrônica de Mercadorias (NF-e) e Conhecimento de Transporte Eletrônico (CT-e)

Embora a NFS-e seja voltada para serviços, a NF-e e o CT-e são documentos eletrônicos essenciais para operações envolvendo mercadorias e transporte, onde o código NCM, vinculado ao CNAE e aos códigos cTribNac, define a tributação correta para IBS, CBS e tributos federais.

**Dados imprescindíveis para compliance:**

- **Código NCM correto:** Atualizado e específico para a mercadoria comercializada.
- **Descrição detalhada do produto:** Para evitar erros genéricos que impedem a apropriação de créditos.
- **Base de cálculo e alíquotas:** Conforme normas federais e estaduais.
- **Códigos de tributação (cTribNac):** Usados para integrar e validar a incidência de IBS e CBS.
- **Informações de regime tributário:** Que influenciam a apropriação de créditos, especialmente para empresas optantes do Simples Nacional (ver 1.6 e 2.13).

### 3. Escrituração Fiscal Digital (EFD)

A EFD, parte do Sistema Público de Escrituração Digital (SPED), é documento obrigatório que registra todas as operações fiscais da empresa, integrando informações da NFS-e, NF-e, CT-e e outras notas fiscais. A conformidade da EFD depende da correta vinculação e registro dos códigos CNAE, LC116, NBS, NCM e cTribNac, garantindo a escrituração dos tributos ISS, IBS e CBS.

**Pontos de atenção na EFD:**

- **Registro detalhado das operações:** Com vinculação correta dos códigos, evitando inconsistências.
- **Controle de créditos tributários:** Que devem estar explicitamente registrados para serem aproveitados.
- **Validação cruzada automática:** Entre documentos fiscais e tabelas oficiais, impedindo erros comuns de incompatibilidade.
- **Atualização constante:** Para refletir as mudanças da reforma e das tabelas oficiais (ver 1.19 e 6.6).

### 4. Declarações Acessórias

Além dos documentos fiscais eletrônicos e da escrituração, as declarações acessórias são obrigações que consolidam informações para o fisco, sendo fundamentais para o compliance tributário.

**Principais declarações exigidas:**

- **DASN (Declaração Anual do Simples Nacional):** Para empresas enquadradas no Simples, alinhando as informações de receita e tributos.
- **DCTF (Declaração de Débitos e Créditos Tributários Federais):** Abrange IBS e CBS, consolidando débitos e créditos apurados.
- **Declarações municipais específicas:** Podem variar conforme o município, geralmente relacionadas ao ISS e à NFS-e.
- **GFIP e RAIS:** Para informações trabalhistas que impactam a base de cálculo de alguns tributos.

O não envio, envio incorreto ou atraso na entrega dessas declarações pode acarretar multas severas e bloquear o aproveitamento de créditos tributários.

### 5. Comprovantes de Retenção e Recolhimento de Tributos

Para fornecedores sujeitos a retenção na fonte de ISS, IBS ou CBS, é crucial manter os comprovantes de retenção e recolhimento para garantir a correta escrituração e apropriação dos créditos.

**Aspectos relevantes:**

- **Comprovantes oficiais emitidos pelo tomador do serviço ou cliente** contendo os valores retidos.
- **Protocolos de recolhimento:** Que confirmem a transferência dos valores retidos aos cofres públicos.
- **Registro nos sistemas contábeis e fiscais:** Vinculados aos documentos fiscais originais para auditoria e análise tributária.

### 6. Contratos e Documentos Complementares

Embora não sejam documentos fiscais propriamente ditos, contratos, pedidos de compra, e comprovantes de pagamento são essenciais para o controle fiscal e para assegurar a consistência entre valores, serviços prestados e tributos recolhidos.

**Importância prática:**

- **Verificação de itens e serviços contratados:** Evitar divergências que podem levar à rejeição de notas ou à inaproveitamento de créditos.
- **Comprovação documental em auditorias:** Que pode validar a correção das operações e a conformidade tributária.
- **Base para cálculo do custo líquido tributário:** Para análise comparativa entre fornecedores (ver 9.1).

---

### Exemplo Prático: Erro de Documento Fiscal e Correção

Imagine que uma empresa emite uma NFS-e para um serviço de consultoria, com o CNAE 62.01-5/01 e o código LC116 incorreto, por exemplo, usando um código genérico não relacionado ao CNAE.

**Mensagem de erro na validação da NFS-e:**

```
Rejeição: Código de serviço LC116 não compatível com o CNAE informado. Ajuste obrigatório para emissão.
```

**Passo a passo para corrigir:**

1. Consultar a tabela oficial de vinculação CNAE x LC116 para o CNAE 62.01-5/01.
2. Identificar o código LC116 correto para o serviço de consultoria.
3. Emitir nova NFS-e com o código LC116 corrigido.
4. Validar o código NBS correspondente para garantir a integração completa.
5. Registrar o crédito tributário gerado corretamente na escrituração fiscal.

Essa correção evita multas, permite apropriação do crédito de ISS e assegura conformidade com as obrigações acessórias.

---

### Boas Práticas para Gestão da Documentação Fiscal

- **Atualização contínua das tabelas oficiais:** CNAE, LC116, NBS, NCM e cTribNac devem estar sempre atualizadas no sistema.
- **Validação automática pré-emissão:** Implementar sistemas que verifiquem a compatibilidade dos códigos e dados antes da emissão de documentos.
- **Armazenamento digital seguro:** Para garantir acesso rápido em auditorias e fiscalizações.
- **Treinamento da equipe fiscal e contábil:** Para evitar erros comuns e garantir o uso correto dos códigos.
- **Rotinas de conferência periódicas:** Cruzar dados da escrituração com documentos fiscais emitidos e recebidos.

---

## Exercício Prático

Pesquise o código LC116 correto para o CNAE 62.01-5/01 (Atividades de desenvolvimento de programas de computador sob encomenda), simule a emissão de uma NFS-e com código LC116 incorreto e mostre a mensagem de rejeição que o sistema fiscal emitiria. Em seguida, corrija o código LC116 e simule a emissão correta da NFS-e, explicando o impacto dessa correção na apropriação de créditos tributários do ISS.

---