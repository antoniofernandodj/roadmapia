## Exercícios — Introdução à Contabilidade Tributária e Contexto da Reforma

### 1. Comparação Tributária entre Fornecedores com CNAE e Código LC116 (intermediário)  
Você tem dois fornecedores de serviços com os seguintes dados:  

| Fornecedor | Preço Bruto (R$) | CNAE       | Código LC116 | Crédito Tributário (R$) |
|------------|------------------|------------|--------------|------------------------|
| A          | 120,00           | 86.30-5-01 | 101          | 18,00                  |
| B          | 115,00           | 86.30-5-02 | 102          | 10,00                  |

Sabendo que a vinculação CNAE x LC116 está correta, e que o crédito tributário pode ser abatido do preço bruto para cálculo do custo líquido, escreva um programa que calcule o custo líquido de cada fornecedor e indique qual deles é a melhor opção para contratação com base no menor custo líquido.

### 2. Custo Líquido com ICMS e ISS em Operação de Compra e Serviço (desafio)  
Sua empresa compra mercadorias e contrata serviços em uma operação mista. Os dados são:  

- Mercadoria: preço bruto R$ 1.000,00, ICMS 18% com crédito integral aplicável.  
- Serviço: preço bruto R$ 500,00, ISS 5%, sem crédito tributário.  

Calcule o custo líquido total da operação considerando o crédito do ICMS e a inexistência de crédito do ISS. Apresente o custo líquido separado para mercadoria e serviço e o total geral.

### 3. Impacto da Apropriação de Créditos Tributários na Escolha de Fornecedor (básico)  
Considere dois fornecedores com preços brutos diferentes:  

- Fornecedor X: R$ 80,00, crédito tributário de R$ 5,00  
- Fornecedor Y: R$ 75,00, crédito tributário de R$ 0,00  

Explique, com base nos conceitos da reforma tributária, como a apropriação dos créditos tributários pode alterar a decisão de escolha entre os dois fornecedores mesmo com preços brutos distintos.

### 4. Identificação de Riscos e Medidas para Evitar Erros na Contabilidade Tributária (intermediário)  
Liste e descreva pelo menos três riscos comuns de erros na contabilidade tributária ao aplicar as normas vigentes em 2024, especialmente considerando a integração entre CNAE, LC116 e NBS. Para cada risco, proponha uma medida prática que pode ser implementada em sistemas fiscais para mitigar esse erro.

### 5. Comparação entre Fornecedores de Mercadoria e Serviço considerando Créditos Tributários (desafio)  
Sua empresa está avaliando dois fornecedores:  

- Fornecedor M (Mercadoria): preço bruto R$ 2.000,00, CNAE relacionado a comércio, com crédito tributário de R$ 300,00 via ICMS.  
- Fornecedor S (Serviço): preço bruto R$ 1.800,00, CNAE relacionado a serviços, sem crédito tributário (ISS sem crédito).  

Explique qual fornecedor gera créditos tributários para a empresa e como isso deve influenciar a decisão de compra considerando os preços brutos distintos. Em seguida, calcule o custo líquido de cada fornecedor e indique a melhor opção.

---

## Soluções comentadas

### 1. Comparação Tributária entre Fornecedores com CNAE e Código LC116

```python
# Dados dos fornecedores
fornecedores = [
    {"nome": "A", "preco_bruto": 120.00, "cnae": "86.30-5-01", "lc116": 101, "credito": 18.00},
    {"nome": "B", "preco_bruto": 115.00, "cnae": "86.30-5-02", "lc116": 102, "credito": 10.00},
]

# Função para calcular custo líquido
def custo_liquido(preco_bruto, credito):
    return preco_bruto - credito

# Calcular custo líquido e identificar melhor fornecedor
melhor_fornecedor = None
menor_custo = float('inf')

print("Custo líquido dos fornecedores:")
for f in fornecedores:
    custo = custo_liquido(f["preco_bruto"], f["credito"])
    print(f"Fornecedor {f['nome']}: R$ {custo:.2f}")
    if custo < menor_custo:
        menor_custo = custo
        melhor_fornecedor = f["nome"]

print(f"\nMelhor opção para contratação: Fornecedor {melhor_fornecedor} com custo líquido R$ {menor_custo:.2f}")
```

**Saída real:**
```
Custo líquido dos fornecedores:
Fornecedor A: R$ 102.00
Fornecedor B: R$ 105.00

Melhor opção para contratação: Fornecedor A com custo líquido R$ 102.00
```

**Comentário:**  
Decidimos calcular o custo líquido subtraindo o crédito tributário do preço bruto, conforme ensinado. Apesar do Fornecedor A ter preço bruto maior, seu crédito maior tornou o custo líquido inferior ao do Fornecedor B, tornando-o a melhor escolha.

---

### 2. Custo Líquido com ICMS e ISS em Operação de Compra e Serviço

```python
# Dados da operação
mercadoria_preco_bruto = 1000.00
icms_aliquota = 0.18
icms_credito = mercadoria_preco_bruto * icms_aliquota  # crédito integral aplicável

servico_preco_bruto = 500.00
iss_aliquota = 0.05
iss_credito = 0.00  # sem crédito tributário

# Calcular custo líquido
mercadoria_custo_liquido = mercadoria_preco_bruto - icms_credito
servico_custo_liquido = servico_preco_bruto + (servico_preco_bruto * iss_aliquota) - iss_credito

# Total geral
total_custo_liquido = mercadoria_custo_liquido + servico_custo_liquido

print(f"Custo líquido da mercadoria: R$ {mercadoria_custo_liquido:.2f}")
print(f"Custo líquido do serviço: R$ {servico_custo_liquido:.2f}")
print(f"Custo líquido total da operação: R$ {total_custo_liquido:.2f}")
```

**Saída real:**
```
Custo líquido da mercadoria: R$ 820.00
Custo líquido do serviço: R$ 525.00
Custo líquido total da operação: R$ 1345.00
```

**Comentário:**  
Para a mercadoria, aplicamos o crédito integral do ICMS, reduzindo o custo líquido. Para o serviço, o ISS é cobrado, mas sem crédito, portanto o custo líquido inclui o imposto sem abatimento. Somamos os dois para obter o custo total da operação. Demonstramos que a apropriação de créditos impacta diretamente o custo líquido.

---

### 3. Impacto da Apropriação de Créditos Tributários na Escolha de Fornecedor

**Resposta:**  
Mesmo que o Fornecedor Y tenha o preço bruto menor (R$ 75,00 contra R$ 80,00 do Fornecedor X), a existência de crédito tributário no Fornecedor X (R$ 5,00) reduz o custo líquido para R$ 75,00. Ou seja, ao considerar o crédito tributário, o custo líquido do Fornecedor X passa a ser igual ao do Fornecedor Y.  

Na prática, isso significa que a apropriação de créditos tributários pode equilibrar ou até inverter a vantagem entre fornecedores que, à primeira vista, pareciam mais baratos ou caros apenas pelo preço bruto. Portanto, decisões baseadas somente no preço bruto podem ser equivocadas, e a análise tributária detalhada é fundamental para uma escolha econômica eficiente após a reforma tributária.

---

### 4. Identificação de Riscos e Medidas para Evitar Erros na Contabilidade Tributária

**Risco 1: Vinculação Incorreta entre CNAE, LC116 e NBS**  
- Descrição: Atribuir códigos errados pode levar à apropriação incorreta de créditos ou à tributação equivocada.  
- Medida: Implementar validação automática cruzada dos códigos na entrada dos dados, consultando tabelas oficiais atualizadas para garantir compatibilidade.

**Risco 2: Uso de Códigos Desatualizados**  
- Descrição: Utilizar versões antigas do CNAE, LC116 ou NBS pode causar erros de cálculo e problemas legais.  
- Medida: Adotar atualização periódica automática das tabelas e alertas para revisão quando houver mudanças na legislação.

**Risco 3: Ignorar Créditos Tributários na Análise de Fornecedores**  
- Descrição: Decidir com base apenas no preço bruto pode resultar em custos maiores para a empresa.  
- Medida: Desenvolver sistemas que integrem cálculo automático do custo líquido, considerando todos os créditos tributários aplicáveis conforme as regras vigentes.

---

### 5. Comparação entre Fornecedores de Mercadoria e Serviço considerando Créditos Tributários

```python
# Dados dos fornecedores
fornecedor_mercadoria = {
    "nome": "M",
    "preco_bruto": 2000.00,
    "cnae": "47.89-0-99",  # comércio
    "credito": 300.00  # crédito ICMS
}

fornecedor_servico = {
    "nome": "S",
    "preco_bruto": 1800.00,
    "cnae": "62.01-5-01",  # serviços
    "credito": 0.00  # ISS sem crédito
}

# Calcular custo líquido
def custo_liquido(preco, credito):
    return preco - credito

custo_liquido_M = custo_liquido(fornecedor_mercadoria["preco_bruto"], fornecedor_mercadoria["credito"])
custo_liquido_S = custo_liquido(fornecedor_servico["preco_bruto"], fornecedor_servico["credito"])

print(f"Custo líquido do fornecedor {fornecedor_mercadoria['nome']}: R$ {custo_liquido_M:.2f}")
print(f"Custo líquido do fornecedor {fornecedor_servico['nome']}: R$ {custo_liquido_S:.2f}")

if custo_liquido_M < custo_liquido_S:
    melhor = fornecedor_mercadoria["nome"]
else:
    melhor = fornecedor_servico["nome"]

print(f"\nMelhor opção considerando custo líquido: Fornecedor {melhor}")
```

**Saída real:**
```
Custo líquido do fornecedor M: R$ 1700.00
Custo líquido do fornecedor S: R$ 1800.00

Melhor opção considerando custo líquido: Fornecedor M
```

**Comentário:**  
O fornecedor de mercadoria gera crédito tributário via ICMS, reduzindo o custo líquido efetivo da compra. O fornecedor de serviços não gera crédito (ISS não permite crédito), portanto o preço bruto é o custo líquido. Apesar do preço bruto do fornecedor de serviços ser menor, a apropriação de crédito torna o fornecedor de mercadoria a melhor escolha econômica. Isso reforça a importância de analisar a natureza do CNAE para identificar se o fornecedor gera créditos tributários que impactam a decisão.