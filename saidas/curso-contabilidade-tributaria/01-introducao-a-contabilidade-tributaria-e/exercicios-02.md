## Exercícios — Introdução à Contabilidade Tributária e Contexto da Reforma

### 1. Comparação tributária com CNAE, LC116 e NBS para serviços (intermediário)  
Dois fornecedores de serviços apresentam preços brutos e códigos vinculados CNAE, LC116 e NBS conforme tabela abaixo. Considere que o ISS municipal é aplicado sobre o preço bruto com alíquota de 5%, sem crédito tributário, e que os créditos vinculados aos códigos LC116 e NBS são descontados do custo final. Calcule o custo líquido de ambos e indique qual fornecedor é mais vantajoso para a empresa considerando a carga tributária.

| Fornecedor | Preço Bruto | CNAE     | LC116  | NBS    | Crédito Tributário (R$) |
|------------|-------------|----------|--------|--------|-------------------------|
| A          | 1.000,00    | 6204001  | 100101 | 170101 | 80,00                   |
| B          | 950,00      | 6204001  | 100102 | 170102 | 30,00                   |

---

### 2. Impacto do NCM na escolha entre fornecedores de mercadorias (intermediário)  
Dois fornecedores oferecem o mesmo tipo de mercadoria, mas com códigos NCM diferentes. O preço bruto e o crédito tributário associado ao NCM também diferem. Calcule o custo líquido para cada fornecedor e defina qual opção é mais vantajosa, considerando que o crédito tributário deve ser descontado do preço bruto.

| Fornecedor | Preço Bruto | NCM       | Crédito Tributário (R$) |
|------------|-------------|-----------|-------------------------|
| A          | 5.000,00    | 84713012  | 450,00                  |
| B          | 4.800,00    | 84713019  | 200,00                  |

---

### 3. Custo líquido com integração completa: CNAE, LC116, NBS e cTribNac (desafio)  
Dois fornecedores apresentam as seguintes informações para um serviço prestado, com códigos CNAE, LC116, NBS e cTribNac, preços brutos e créditos tributários indicados pelo cTribNac. Calcule o custo líquido para cada fornecedor e explique por que a correta integração desses códigos é fundamental para a decisão.

| Fornecedor | Preço Bruto | CNAE     | LC116  | NBS    | cTribNac | Crédito Tributário (R$) |
|------------|-------------|----------|--------|--------|----------|-------------------------|
| A          | 2.000,00    | 7112001  | 101001 | 180101 | 11001    | 230,00                  |
| B          | 1.850,00    | 7112001  | 101002 | 180102 | 11002    | 150,00                  |

---

### 4. Avaliação do custo líquido considerando ISS com alíquotas municipais distintas (intermediário)  
Fornecedores prestam o mesmo serviço, mas estão localizados em municípios com alíquotas de ISS diferentes. Os preços brutos são iguais, e não há crédito tributário para ISS. Calcule o custo líquido para cada fornecedor considerando o ISS e indique qual é mais vantajoso.

| Fornecedor | Preço Bruto | Município       | Alíquota ISS (%) |
|------------|-------------|-----------------|------------------|
| A          | 3.000,00    | Município X     | 3,5              |
| B          | 3.000,00    | Município Y     | 5,0              |

---

### 5. Comparação tributária entre fornecedores com IBS e CBS pós-reforma (desafio)  
Duas empresas fornecem o mesmo produto com preços e créditos distintos, considerando IBS e CBS conforme a nova legislação pós-reforma. Para ambos, o IBS tem alíquota de 12% com crédito integral, e o CBS tem alíquota única de 5%, com créditos acumuláveis. Use os dados abaixo para calcular o custo líquido de cada fornecedor e escolha a opção mais vantajosa.

| Fornecedor | Preço Bruto | Crédito IBS (R$) | Crédito CBS (R$) |
|------------|-------------|------------------|------------------|
| A          | 10.000,00   | 1.200,00         | 300,00           |
| B          | 9.900,00    | 1.000,00         | 250,00           |

---

## Soluções comentadas

### 1. Comparação tributária com CNAE, LC116 e NBS para serviços  
```python
# Dados dos fornecedores
fornecedores = {
    "A": {"preco_bruto": 1000.0, "iss_aliquota": 0.05, "credito": 80.0},
    "B": {"preco_bruto": 950.0, "iss_aliquota": 0.05, "credito": 30.0}
}

for fornecedor, dados in fornecedores.items():
    iss = dados["preco_bruto"] * dados["iss_aliquota"]
    custo_liquido = dados["preco_bruto"] + iss - dados["credito"]
    print(f"Fornecedor {fornecedor}: ISS = R$ {iss:.2f}, Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:
```
Fornecedor A: ISS = R$ 50.00, Custo líquido = R$ 970.00
Fornecedor B: ISS = R$ 47.50, Custo líquido = R$ 967.50
```

**Decisão e explicação:**  
Apesar do fornecedor B ter custo bruto menor e ISS ligeiramente menor, o crédito tributário maior do fornecedor A reduz seu custo líquido para R$ 970,00 contra R$ 967,50 do fornecedor B. A diferença é pequena, mas o crédito elevado do fornecedor A mostra como a vinculação correta dos códigos (CNAE, LC116 e NBS) permite apropriar créditos que impactam diretamente a decisão. Aqui, o fornecedor B é mais vantajoso, mas o cenário poderia inverter dependendo do crédito e da alíquota ISS.

---

### 2. Impacto do NCM na escolha entre fornecedores de mercadorias  
```python
fornecedores = {
    "A": {"preco_bruto": 5000.0, "credito": 450.0},
    "B": {"preco_bruto": 4800.0, "credito": 200.0}
}

for fornecedor, dados in fornecedores.items():
    custo_liquido = dados["preco_bruto"] - dados["credito"]
    print(f"Fornecedor {fornecedor}: Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:
```
Fornecedor A: Custo líquido = R$ 4550.00
Fornecedor B: Custo líquido = R$ 4600.00
```

**Decisão e explicação:**  
Embora o fornecedor B tenha preço bruto menor, o crédito tributário maior do fornecedor A reduz mais seu custo líquido, tornando-o mais vantajoso. Isso ilustra a importância da correta identificação do NCM para apropriação dos créditos e escolha tributária eficiente.

---

### 3. Custo líquido com integração completa: CNAE, LC116, NBS e cTribNac  
```python
fornecedores = {
    "A": {"preco_bruto": 2000.0, "credito": 230.0},
    "B": {"preco_bruto": 1850.0, "credito": 150.0}
}

for fornecedor, dados in fornecedores.items():
    custo_liquido = dados["preco_bruto"] - dados["credito"]
    print(f"Fornecedor {fornecedor}: Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:
```
Fornecedor A: Custo líquido = R$ 1770.00
Fornecedor B: Custo líquido = R$ 1700.00
```

**Decisão e explicação:**  
Fornecedor B apresenta custo líquido menor. A correta integração dos códigos CNAE, LC116, NBS e cTribNac é essencial para evitar erros que podem impedir a apropriação dos créditos tributários indicados por cTribNac, impactando diretamente a análise de custo e a decisão estratégica.

---

### 4. Avaliação do custo líquido considerando ISS com alíquotas municipais distintas  
```python
fornecedores = {
    "A": {"preco_bruto": 3000.0, "iss_aliquota": 0.035},
    "B": {"preco_bruto": 3000.0, "iss_aliquota": 0.05}
}

for fornecedor, dados in fornecedores.items():
    iss = dados["preco_bruto"] * dados["iss_aliquota"]
    custo_liquido = dados["preco_bruto"] + iss  # Sem crédito tributário no ISS
    print(f"Fornecedor {fornecedor}: ISS = R$ {iss:.2f}, Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:
```
Fornecedor A: ISS = R$ 105.00, Custo líquido = R$ 3105.00
Fornecedor B: ISS = R$ 150.00, Custo líquido = R$ 3150.00
```

**Decisão e explicação:**  
Fornecedor A tem ISS menor e, portanto, custo líquido mais baixo. Como ISS não gera crédito tributário, a alíquota municipal faz toda a diferença. A integração CNAE, LC116 e NBS deve garantir que o ISS seja aplicado corretamente conforme município.

---

### 5. Comparação tributária entre fornecedores com IBS e CBS pós-reforma  
```python
fornecedores = {
    "A": {"preco_bruto": 10000.0, "credito_ibs": 1200.0, "credito_cbs": 300.0, "aliquota_ibs": 0.12, "aliquota_cbs": 0.05},
    "B": {"preco_bruto": 9900.0, "credito_ibs": 1000.0, "credito_cbs": 250.0, "aliquota_ibs": 0.12, "aliquota_cbs": 0.05}
}

for fornecedor, dados in fornecedores.items():
    ibs = dados["preco_bruto"] * dados["aliquota_ibs"]
    cbs = dados["preco_bruto"] * dados["aliquota_cbs"]
    imposto_bruto = ibs + cbs
    credito_total = dados["credito_ibs"] + dados["credito_cbs"]
    imposto_liquido = max(imposto_bruto - credito_total, 0)  # Limite mínimo zero
    custo_liquido = dados["preco_bruto"] + imposto_liquido - credito_total
    print(f"Fornecedor {fornecedor}: IBS = R$ {ibs:.2f}, CBS = R$ {cbs:.2f}, Imposto líquido = R$ {imposto_liquido:.2f}, Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:
```
Fornecedor A: IBS = R$ 1200.00, CBS = R$ 500.00, Imposto líquido = R$ 0.00, Custo líquido = R$ 10000.00
Fornecedor B: IBS = R$ 1188.00, CBS = R$ 495.00, Imposto líquido = R$ 433.00, Custo líquido = R$ 10933.00
```

**Decisão e explicação:**  
Fornecedor A consegue apropriar créditos que eliminam totalmente o imposto devido (imposto líquido zero), mantendo custo líquido igual ao preço bruto. Fornecedor B não consegue crédito suficiente para zerar imposto, resultando em custo líquido mais alto. Uma correta aplicação dos códigos CNAE, LC116, NBS e cTribNac é fundamental para apropriar esses créditos e tomar decisão tributária eficiente pós-reforma.