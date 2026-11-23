## Casos de Uso: Vinculação para Escolha de Fornecedores

Imagine que sua empresa precise contratar um serviço de consultoria em tecnologia da informação. Dois fornecedores apresentam propostas semelhantes, mas com valores diferentes: o Fornecedor A cobra R$ 100.000, enquanto o Fornecedor B oferece R$ 95.000. À primeira vista, a escolha óbvia seria o segundo, mais barato. Porém, após aplicar a vinculação tributária correta entre CNAE, código de serviço LC116 e NBS, percebe-se que o Fornecedor A gera créditos tributários que reduzem seu custo líquido efetivo para R$ 85.000, tornando-o a opção mais vantajosa.

Essa situação ilustra o poder da vinculação correta dos códigos para análise tributária prática na escolha de fornecedores. A seguir, exploraremos casos concretos que demonstram como essa vinculação é fundamental para decisões econômicas mais inteligentes e alinhadas à legislação pós-reforma tributária.

---

### Caso 1: Serviços de Desenvolvimento de Software

**Contexto:** Dois fornecedores oferecem serviços de desenvolvimento de software, com preços brutos distintos.

| Fornecedor | Preço Bruto (R$) | CNAE            | Código LC116 | Código NBS | Crédito Tributário (R$) | Custo Líquido (R$) |
|------------|------------------|-----------------|--------------|------------|------------------------|--------------------|
| A          | 120.000          | 6201-5/01       | 101010       | 62010010   | 20.000                 | 100.000            |
| B          | 110.000          | 6201-5/01       | 101010       | 62010010   | 5.000                  | 105.000            |

**Análise:**
- Ambos os fornecedores possuem o mesmo CNAE, vinculando-se corretamente ao código LC116 referente a “Serviços de desenvolvimento de software”.
- O código LC116 vincula-se à NBS específica para serviços de TI, permitindo apuração correta do ISS e créditos tributários.
- Fornecedor A, apesar do preço bruto maior, gera créditos tributários significativos (exemplo: crédito de CBS e ISS) que reduzem seu custo líquido para R$ 100.000.
- Fornecedor B tem preço bruto menor, mas crédito tributário reduzido, resultando em custo líquido maior.

**Mensagem prática:** A vinculação correta CNAE → LC116 → NBS possibilita identificar o crédito tributário gerado, evitando decisões baseadas apenas em preço bruto.

---

### Caso 2: Compra de Mercadorias com NCM e Análise Integrada

**Contexto:** Uma empresa compra equipamentos de informática de dois fornecedores, com NCM diferentes e códigos tributários vinculados.

| Fornecedor | Preço Bruto (R$) | NCM       | CNAE            | Código LC116 | Crédito CBS (R$) | Crédito IBS (R$) | Custo Líquido (R$) |
|------------|------------------|-----------|-----------------|--------------|------------------|-----------------|--------------------|
| C          | 50.000           | 84713012  | 4651-0/01       | 201020       | 2.000            | 3.000           | 45.000             |
| D          | 48.000           | 84713011  | 4651-0/01       | 201020       | 500              | 1.000           | 46.500             |

**Análise:**
- O NCM indica a mercadoria exata, impactando diretamente na incidência do IBS e CBS.
- A vinculação do NCM com o CNAE e o código LC116 permite identificar corretamente os créditos tributários disponíveis.
- Fornecedor C, com preço bruto maior, gera créditos maiores, reduzindo o custo líquido abaixo do fornecedor D.
- Ignorar a vinculação e os créditos levaria à escolha equivocada pelo preço bruto.

---

### Caso 3: Serviços Mistos com Segregação de Receitas

**Contexto:** Um fornecedor presta serviços mistos, envolvendo consultoria e venda de software. A correta segregação entre serviços e mercadorias é vital para apropriação de créditos.

- CNAE: 6202-3/00 (Serviços de consultoria em TI)
- Código LC116: 101020 (Consultoria em informática)
- NBS: 62020020 (Consultoria em TI)
- NCM: 85234900 (Software de prateleira)

**Situação:**

A nota fiscal apresenta itens distintos, e a empresa compradora deve vincular corretamente cada item para cálculo do crédito tributário:

| Item      | Tipo          | Código Aplicável | Valor (R$) | Crédito Tributário (R$) |
|-----------|---------------|------------------|------------|------------------------|
| Consultoria | Serviço       | LC116 101020 / NBS 62020020 | 60.000     | 9.000                  |
| Software    | Mercadoria    | NCM 85234900     | 40.000     | 4.000                  |

**Importância da Vinculação:**
- Vinculação correta separa os valores e aplica alíquotas e créditos específicos para ISS, IBS e CBS.
- Falha na segregação pode resultar em perda de créditos sobre mercadorias ou serviços.
- A integração CNAE-LC116-NBS-NCM assegura a correta apropriação dos créditos e cálculo do custo líquido.

---

### Caso 4: Impacto da Atualização das Tabelas Oficiais na Escolha de Fornecedores

**Problema comum:** Utilizar tabelas desatualizadas de vinculação CNAE-LC116 ou LC116-NBS.

**Exemplo prático:**

- Fornecedor E usa código LC116 antigo, não mais válido para sua atividade.
- Sistema rejeita a nota fiscal, gerando autuação e impossibilidade de apropriar crédito tributário.
- Fornecedor F usa códigos atualizados, garantindo conformidade e crédito pleno.

**Conclusão:** A atualização constante das tabelas de vinculação é tão importante quanto a vinculação correta para garantir a vantagem tributária na escolha do fornecedor.

---

### Caso 5: Validação Programática para Escolha Automatizada

Imagine um sistema que recebe propostas de diversos fornecedores com dados completos (CNAE, LC116, NBS e NCM) e executa a validação automática da vinculação para calcular o custo líquido real, considerando créditos tributários.

```python
for fornecedor in fornecedores:
    cnae = fornecedor['cnae']
    lc116 = fornecedor['lc116']
    nbs = fornecedor['nbs']
    preco_bruto = fornecedor['preco_bruto']
    creditos = calcular_creditos(cnae, lc116, nbs, preco_bruto)
    custo_liquido = preco_bruto - creditos
    fornecedor['custo_liquido'] = custo_liquido

melhor_fornecedor = min(fornecedores, key=lambda f: f['custo_liquido'])
print(f"Melhor fornecedor: {melhor_fornecedor['nome']} com custo líquido de R$ {melhor_fornecedor['custo_liquido']:.2f}")
```

**Benefícios:**
- Automatiza decisões tributárias complexas.
- Evita erros manuais na vinculação dos códigos.
- Permite análises rápidas e atualizadas conforme tabela vigente.

---

## Exercício Proposto

Simule a análise tributária comparativa entre dois fornecedores que oferecem serviços semelhantes, aplicando a vinculação dos códigos CNAE, LC116 e NBS para identificar qual apresenta o menor custo líquido considerando os créditos tributários gerados. Apresente tabela comparativa com preços brutos, valores de créditos e custo líquido final.

---