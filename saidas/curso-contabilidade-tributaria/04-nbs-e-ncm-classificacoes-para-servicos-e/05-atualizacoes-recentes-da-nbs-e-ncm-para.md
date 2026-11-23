## Atualizações Recentes da NBS e NCM para 2024

A correta classificação tributária de serviços e mercadorias depende da atualização contínua dos códigos NBS (Nomenclatura Brasileira de Serviços) e NCM (Nomenclatura Comum do Mercosul). Em 2024, foram publicadas alterações essenciais em ambas as tabelas, motivadas pela reforma tributária e pela necessidade de adequação às novas regras de incidência, base de cálculo e crédito tributário. Entender essas atualizações é fundamental para o correto enquadramento dos serviços e mercadorias, evitando erros na apuração do ISS, ICMS, IPI, IBS, CBS e outros tributos.

### Atualizações na NBS para 2024

A NBS foi revista para detalhar e ampliar a classificação de serviços, especialmente aqueles ligados à economia digital, serviços tecnológicos e consultorias especializadas, setores em crescimento e com alta relevância tributária pós-reforma. As principais mudanças são:

- **Inclusão de novos códigos para serviços digitais e tecnológicos**: Serviços como desenvolvimento de software sob demanda, consultoria em segurança cibernética e análise de dados passaram a ter códigos NBS específicos. Antes, esses serviços eram classificados em categorias genéricas, o que dificultava a aplicação correta do ISS e a apropriação de créditos. Por exemplo, o código que antes era genérico para "consultoria em tecnologia" foi desdobrado em subitens que discriminam, por exemplo, segurança da informação (NBS 7.01.01.11) e análise de big data (NBS 7.01.01.12).

- **Revisão e detalhamento de códigos existentes para serviços financeiros e administrativos**: Muitos serviços de assessoria financeira, auditoria e gestão documental foram reclassificados para refletir melhor a complexidade tributária, evitando interpretações ambíguas que causem autuações fiscais. Isso implica que fornecedores devem revisar seus códigos NBS para garantir conformidade e captar créditos possíveis.

- **Padronização e alinhamento com a LC116 e CNAE**: A integração obrigatória da NBS com o código de serviço LC116 e o CNAE foi reforçada. Para 2024, a Receita Federal e as secretarias estaduais e municipais de fazenda publicaram orientações para que todas as operações utilizem códigos NBS atualizados para evitar rejeições em notas fiscais eletrônicas (NFS-e). Essa padronização é crucial para sistemas fiscais automatizados.

- **Exclusão de códigos obsoletos**: Serviços que perderam relevância econômica ou que foram incorporados em outras categorias tiveram seus códigos removidos, exigindo atenção para evitar uso de códigos inválidos que geram erros na apuração do ISS.

#### Exemplo prático na NBS 2024

Suponha um fornecedor de consultoria em segurança da informação que antes usava o código genérico 7.01.01.00. Com a atualização, será necessário utilizar o código mais específico 7.01.01.11. A aplicação incorreta do código genérico pode gerar rejeição na NFS-e com mensagem como:

```
Rejeição: Código NBS inválido ou desatualizado para o serviço informado.
```

Ao corrigir para o código atualizado, o cálculo do ISS será feito com a alíquota correta e o crédito tributário será apropriadamente contabilizado.

---

### Atualizações na NCM para 2024

A NCM também passou por revisões importantes, principalmente devido à incorporação de novas mercadorias ligadas a tecnologias emergentes e à atualização de códigos para produtos com maior incidência do IBS e CBS pós-reforma.

As principais atualizações são:

- **Inclusão de códigos para novas categorias de produtos eletrônicos e tecnológicos**: Produtos como dispositivos de IoT (Internet das Coisas), equipamentos para energia renovável e insumos para fabricação de veículos elétricos ganharam códigos específicos. Isso facilita a correta tributação do IPI, ICMS e a apropriação de créditos tributários.

- **Atualização de códigos para mercadorias usadas e recondicionadas**: A NCM passou a detalhar melhor as categorias para bens usados, importante para avaliação correta do custo tributário e crédito no momento da compra, como em notebooks usados (ver exercício do cap. 3.12). A distinção entre código para mercadoria nova e usada impacta diretamente na base de cálculo e alíquotas aplicáveis.

- **Correção de descrições e exclusão de códigos obsoletos**: Para evitar erros na emissão de notas fiscais eletrônicas (NF-e), a Receita Federal atualizou descrições que estavam ambíguas e eliminou códigos que não refletem mais o mercado atual. Isso reduz os casos de rejeição fiscal e perda de créditos.

- **Ajustes para compatibilidade com o IBS e CBS**: A classificação dos bens também foi ajustada para promover integração com os novos tributos pós-reforma, garantindo que a base de cálculo e os créditos sejam calculados corretamente com os códigos NCM atualizados.

#### Exemplo prático na NCM 2024

Um fornecedor que vende notebooks usados deve usar o código NCM atualizado que distingue mercadoria usada da nova, por exemplo:

- Notebook novo: NCM 8471.30.12
- Notebook usado/recondicionado: NCM 8471.90.12 (exemplo ilustrativo)

Ao usar o código errado, a nota fiscal pode ser rejeitada ou o recolhimento do ICMS/IBS poderá ser incorreto, gerando multas ou perda de créditos.

Mensagem comum de erro neste caso:

```
Rejeição: Código NCM incompatível com a descrição da mercadoria.
```

Corrigir para o código correto evita essa rejeição e permite análise tributária precisa para comparação entre fornecedores.

---

### Impacto das Atualizações na Análise Tributária e na Escolha de Fornecedores

Essas atualizações da NBS e NCM são essenciais para o sistema que você irá desenvolver, pois:

- **Garantem a precisão na identificação dos serviços e mercadorias**, fundamental para o cálculo correto do ISS, IBS e CBS, evitando erros fiscais e permitindo a apropriação integral dos créditos tributários.

- **Evitarão rejeições e autuações fiscais** causadas pelo uso de códigos desatualizados ou incorretos, que impactam diretamente na confiabilidade da análise tributária e na comparação de fornecedores.

- **Permitem a integração eficaz com CNAE e LC116**, assegurando que o sistema vincule corretamente o fornecedor ao código tributário correto, facilitando a escolha pelo fornecedor com melhor custo líquido tributário.

- **Facilitam a atualização contínua do sistema**: sistemas fiscais automatizados devem estar preparados para incorporar as atualizações anuais das tabelas NBS e NCM, garantindo que as regras de cálculo e apropriação de créditos estejam sempre corretas.

---

### Como aplicar as atualizações em um sistema fiscal

Para implementar essas atualizações em um sistema que compare fornecedores considerando créditos tributários:

1. **Atualize as bases de dados NBS e NCM** com as tabelas oficiais de 2024, disponíveis no site da Receita Federal e órgãos municipais de fazenda.

2. **Implemente validação automática dos códigos** ao inserir serviços e mercadorias, rejeitando códigos desatualizados ou genéricos sem especificação.

3. **Vincule os códigos corretamente com CNAE e LC116**, conforme já detalhado, para garantir a correta aplicação das alíquotas e regras de crédito.

4. **Inclua regras para cálculo de créditos tributários** baseadas nas alíquotas e incidências vigentes, usando os códigos atualizados para definir se o crédito é permitido e qual o percentual.

5. **Implemente relatórios e dashboards** que indiquem o impacto tributário real considerando os créditos, permitindo ao usuário comparar fornecedores e optar pela melhor opção financeira.

---

### Exercício prático

Considere que você está desenvolvendo a funcionalidade para comparar fornecedores de serviços de consultoria em segurança da informação e equipamentos de informática usados para escritório.

- Para o serviço, identifique o código NBS atualizado para 2024 referente a consultoria em segurança da informação e explique por que o uso desse código é crucial para o cálculo correto do ISS e apropriação de créditos.

- Para o equipamento usado, escolha o código NCM correto para notebooks usados conforme as atualizações 2024 e explique como esse código impacta a tributação do ICMS, IBS e a análise do custo líquido tributário.

Explique como o sistema deve validar e aplicar essas classificações para garantir a comparação tributária correta entre fornecedores.

---