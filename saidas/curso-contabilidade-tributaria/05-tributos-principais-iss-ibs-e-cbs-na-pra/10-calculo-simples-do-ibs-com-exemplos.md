## Cálculo Simples do IBS com Exemplos

O IBS (Imposto sobre Bens e Serviços) é um tributo estadual que incide sobre uma base ampla, englobando tanto operações com bens quanto prestações de serviços. Seu cálculo, embora simplificado na proposta da reforma tributária, exige atenção para incorporar corretamente a base de cálculo, a alíquota e os créditos tributários, evitando erros comuns que afetam o custo líquido final.

### Problema Prático: Calcular o IBS devido e o custo líquido tributário considerando créditos

Imagine que sua empresa está avaliando três fornecedores para contratar um serviço ou adquirir um bem. Cada fornecedor apresenta um preço bruto (valor da operação), uma alíquota de IBS e um crédito tributário que você pode aproveitar. Para decidir qual fornecedor oferece a melhor condição, é necessário calcular o valor do imposto devido e o custo líquido, que é o valor pago já descontado o crédito tributário.

### Passo 1: Base de cálculo do IBS

A base de cálculo do IBS é o valor bruto da operação, acrescido dos encargos e deduzidos os descontos incondicionais e impostos destacados, conforme discutido no capítulo anterior. Para o cálculo simples aqui, vamos assumir que o valor bruto já está ajustado corretamente.

### Passo 2: Cálculo do imposto bruto

O imposto bruto é a alíquota do IBS aplicada sobre a base de cálculo. Exemplo:

- Valor da operação: R$ 1.000,00  
- Alíquota IBS: 10% (0,10)  
- Imposto bruto = 1.000,00 × 0,10 = R$ 100,00

### Passo 3: Aplicação do crédito tributário

O crédito tributário é o valor que pode ser abatido do imposto devido, evitando a cumulatividade do IBS (como visto em 1.7 e 1.15). O imposto líquido, portanto, será o imposto bruto menos o crédito tributário, mas nunca negativo.

Erro comum: subtrair o crédito e deixar o imposto líquido negativo, o que não é permitido e gera inconsistência no cálculo.

**Exemplo do erro:**

```python
imposto_liquido = imposto_bruto - credito
# Se credito > imposto_bruto, imposto_liquido fica negativo
```

Mensagem de erro típica em sistemas fiscais:

```
Erro: imposto líquido negativo não permitido - revisar crédito tributário
```

### Passo 4: Custo líquido tributário

O custo líquido é o valor da operação mais o imposto líquido a pagar (se houver), ou seja:

```
custo_liquido = valor_operacao + imposto_liquido
```

### Exemplo prático completo em Python

Vamos calcular o imposto IBS e custo líquido para três fornecedores diferentes.

```python
def calcula_ibs(valor_operacao, aliquota_ibs, credito_tributario):
    imposto_bruto = valor_operacao * aliquota_ibs
    imposto_liquido = imposto_bruto - credito_tributario
    # Corrige para não permitir imposto negativo
    if imposto_liquido < 0:
        imposto_liquido = 0.0
    custo_liquido = valor_operacao + imposto_liquido
    return imposto_liquido, custo_liquido

# Dados dos fornecedores
fornecedores = [
    {"nome": "Fornecedor A", "valor": 1000.00, "aliquota": 0.10, "credito": 80.00},
    {"nome": "Fornecedor B", "valor": 950.00,  "aliquota": 0.10, "credito": 30.00},
    {"nome": "Fornecedor C", "valor": 1050.00, "aliquota": 0.10, "credito": 110.00},
]

print(f"{'Fornecedor':<15} {'Imposto IBS':>12} {'Custo Líquido':>15}")
for f in fornecedores:
    imposto, custo = calcula_ibs(f["valor"], f["aliquota"], f["credito"])
    print(f"{f['nome']:<15} R$ {imposto:10.2f} R$ {custo:14.2f}")
```

Saída:

```
Fornecedor       Imposto IBS   Custo Líquido
Fornecedor A      R$     20.00 R$       1020.00
Fornecedor B      R$     65.00 R$        1015.00
Fornecedor C      R$      0.00 R$       1050.00
```

### Análise prática do exemplo

- **Fornecedor A:** Valor bruto R$ 1.000, crédito R$ 80. O imposto bruto é R$ 100, crédito abate R$ 80, sobrando R$ 20 de imposto a pagar. Custo líquido R$ 1.020.
- **Fornecedor B:** Valor bruto R$ 950, crédito R$ 30. Imposto bruto R$ 95, crédito abate R$ 30, imposto líquido R$ 65. Custo líquido R$ 1.015.
- **Fornecedor C:** Valor bruto R$ 1.050, crédito R$ 110. Imposto bruto R$ 105, crédito maior que o imposto, imposto líquido é zero. Custo líquido R$ 1.050.

Neste cenário, o **Fornecedor B** tem o menor custo líquido tributário (R$ 1.015,00), mesmo com crédito menor que o Fornecedor A, graças ao valor bruto e à alíquota. O Fornecedor C, apesar do maior crédito, tem custo líquido mais alto devido ao valor bruto da operação.

### Erro comum e correção no código

Se você esquecer de limitar o imposto líquido a zero, poderá obter valores negativos, como no caso do Fornecedor C, o que é incorreto.

**Código incorreto:**

```python
imposto_liquido = imposto_bruto - credito_tributario
```

**Correção aplicando limite:**

```python
imposto_liquido = max(imposto_bruto - credito_tributario, 0.0)
```

### Expansão para sistemas fiscais

A função `calcula_ibs` pode ser integrada em sistemas fiscais para permitir a comparação automática entre fornecedores, levando em conta não apenas o preço bruto, mas também a alíquota e os créditos tributários que impactam o custo efetivo da operação.

### Exercício prático

Dado o valor da operação, alíquota do IBS e crédito tributário de três fornecedores distintos, implemente uma função que calcule o IBS devido e o custo líquido para cada um, e indique qual fornecedor oferece a melhor condição tributária.

---