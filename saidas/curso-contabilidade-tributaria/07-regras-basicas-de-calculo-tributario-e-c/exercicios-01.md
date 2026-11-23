## Exercícios — Regras Básicas de Cálculo Tributário e Créditos

### 1. Comparação Tributária de Fornecedores com Cálculo do IBS  (intermediário)  
Você recebeu duas propostas para um serviço:  
- Fornecedor A cobra preço bruto de R$ 2.000,00, com desconto condicional de R$ 100,00, alíquota do IBS de 12% e crédito tributário de R$ 250,00.  
- Fornecedor B cobra preço bruto de R$ 1.900,00, sem desconto condicional, alíquota do IBS de 12% e crédito tributário de R$ 100,00.  

Escreva um programa que calcule para cada fornecedor:  
- base de cálculo ajustada,  
- imposto devido (limitado a zero),  
- custo líquido (preço bruto menos desconto condicional mais imposto líquido),  
e indique qual fornecedor apresenta o menor custo líquido considerando créditos tributários.

### 2. Cálculo Completo do ISS com Crédito Tributário e Limite Mínimo Zero  (básico)  
Um serviço tem preço bruto de R$ 2.000,00, desconto condicional de R$ 100,00, alíquota do ISS de 5% e crédito tributário de R$ 250,00.  

Implemente um programa que calcule:  
- base de cálculo ajustada,  
- imposto bruto,  
- imposto líquido aplicando o crédito tributário (não podendo ficar negativo),  
- custo líquido do serviço.  

Mostre a saída completa e explique cada etapa do cálculo.

### 3. Validação da Base de Cálculo no CBS e Aplicação do Crédito Tributário  (intermediário)  
Para uma operação com preço bruto de R$ 2.000,00, desconto condicional de R$ 100,00, alíquota do CBS de 12% e crédito tributário de R$ 250,00, sabendo que para o CBS a base de cálculo é o preço bruto sem dedução de descontos condicionais:  

Crie um programa que calcule:  
- base de cálculo do CBS,  
- imposto bruto do CBS,  
- imposto líquido após considerar o crédito tributário (com limite mínimo zero),  
- custo líquido da operação.  

Explique o motivo de não deduzir o desconto condicional na base do CBS.

### 4. Apropriação de Crédito Tributário no IBS com Limite e Impacto no Custo Líquido  (desafio)  
Um serviço tem preço bruto de R$ 2.000,00, desconto condicional de R$ 100,00, alíquota do IBS de 12% e crédito tributário de R$ 250,00.  

Desenvolva um programa que:  
- calcula a base de cálculo ajustada do IBS,  
- calcula o imposto devido bruto,  
- aplica a apropriação direta do crédito tributário, limitando o imposto líquido a zero,  
- calcula o custo líquido da operação,  
- informa o valor do crédito efetivamente utilizado (que não pode ultrapassar o imposto bruto).  

Explique por que a apropriação do crédito não pode ultrapassar o imposto bruto e o impacto disso na análise econômica.

### 5. Cálculo Integrado para Escolha de Fornecedor com Base em CNAE, LC116 e NBS  (desafio)  
Considere dois fornecedores com as seguintes características fiscais:  

| Fornecedor | Preço Bruto | Desconto Condicional | CNAE          | LC116 Código | NBS Código | Alíquota IBS | Crédito Tributário (R$) |
|------------|-------------|---------------------|---------------|--------------|------------|--------------|-------------------------|
| A          | R$ 2.000,00 | R$ 100,00           | 6201501       | 0101         | 060101     | 12%          | 250,00                  |
| B          | R$ 1.950,00 | R$ 200,00           | 6201501       | 0101         | 060101     | 12%          | 180,00                  |

Sabendo que a base de cálculo do IBS é o preço bruto menos o desconto condicional e que o imposto líquido não pode ser negativo após a aplicação do crédito tributário, escreva um programa que:  
- valide se o CNAE, LC116 e NBS estão vinculados corretamente (aqui, considere que os códigos indicados são válidos e vinculados);  
- calcule para cada fornecedor: base de cálculo, imposto bruto, imposto líquido, crédito aplicado, custo líquido;  
- indique qual fornecedor oferece a melhor condição tributária baseada no custo líquido.  

Explique como a vinculação dos códigos influencia a apropriação correta dos créditos tributários.

---

## Soluções comentadas

### 1. Comparação Tributária de Fornecedores com Cálculo do IBS  (intermediário)

```python
def calcular_ibs(preco_bruto, desconto_condicional, aliquota, credito):
    # Base de cálculo IBS = preço bruto - desconto condicional
    base_calculo = preco_bruto - desconto_condicional

    # Imposto bruto = base de cálculo * alíquota
    imposto_bruto = base_calculo * aliquota / 100

    # Imposto líquido = imposto bruto - crédito, mínimo zero
    imposto_liquido = max(imposto_bruto - credito, 0)

    # Custo líquido = preço bruto - desconto condicional + imposto líquido
    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido

    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido


# Dados dos fornecedores
fornecedores = {
    "Fornecedor A": {"preco_bruto": 2000.0, "desconto": 100.0, "aliquota": 12, "credito": 250.0},
    "Fornecedor B": {"preco_bruto": 1900.0, "desconto": 0.0,   "aliquota": 12, "credito": 100.0},
}

resultados = {}
for nome, dados in fornecedores.items():
    base, imposto_bruto, imposto_liq, custo = calcular_ibs(
        dados["preco_bruto"], dados["desconto"], dados["aliquota"], dados["credito"]
    )
    resultados[nome] = {
        "base_calculo": base,
        "imposto_bruto": imposto_bruto,
        "imposto_liquido": imposto_liq,
        "custo_liquido": custo,
    }

# Mostrar resultados
for nome, res in resultados.items():
    print(f"{nome}:")
    print(f"  Base de cálculo: R$ {res['base_calculo']:.2f}")
    print(f"  Imposto bruto: R$ {res['imposto_bruto']:.2f}")
    print(f"  Imposto líquido: R$ {res['imposto_liquido']:.2f}")
    print(f"  Custo líquido: R$ {res['custo_liquido']:.2f}")
    print()

# Comparar custo líquido
melhor = min(resultados.items(), key=lambda x: x[1]["custo_liquido"])
print(f"Melhor fornecedor (menor custo líquido): {melhor[0]} com R$ {melhor[1]['custo_liquido']:.2f}")
```

**Saída real:**
```
Fornecedor A:
  Base de cálculo: R$ 1900.00
  Imposto bruto: R$ 228.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1900.00

Fornecedor B:
  Base de cálculo: R$ 1900.00
  Imposto bruto: R$ 228.00
  Imposto líquido: R$ 128.00
  Custo líquido: R$ 2028.00

Melhor fornecedor (menor custo líquido): Fornecedor A com R$ 1900.00
```

**Explicação:**  
- Para o IBS, a base é o preço bruto menos o desconto condicional.  
- O imposto bruto é a base multiplicada pela alíquota.  
- O crédito tributário reduz o imposto devido, limitando o imposto líquido a zero (não há restituição).  
- O custo líquido considera o preço bruto descontado mais o imposto líquido.  
- Apesar do preço bruto menor do Fornecedor B, o crédito menor faz o custo líquido maior que o Fornecedor A.  

---

### 2. Cálculo Completo do ISS com Crédito Tributário e Limite Mínimo Zero  (básico)

```python
def calcular_iss(preco_bruto, desconto_condicional, aliquota, credito):
    # Base de cálculo ISS = preço bruto - desconto condicional
    base_calculo = preco_bruto - desconto_condicional

    # Imposto bruto = base de cálculo * alíquota
    imposto_bruto = base_calculo * aliquota / 100

    # Imposto líquido = imposto bruto - crédito, limitado a zero
    imposto_liquido = max(imposto_bruto - credito, 0)

    # Custo líquido = preço bruto - desconto condicional + imposto líquido
    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido

    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido


# Dados do serviço
preco = 2000.0
desconto = 100.0
aliquota_iss = 5
credito = 250.0

base, imposto_bruto, imposto_liq, custo = calcular_iss(preco, desconto, aliquota_iss, credito)

print(f"Base de cálculo ISS: R$ {base:.2f}")
print(f"Imposto bruto ISS: R$ {imposto_bruto:.2f}")
print(f"Imposto líquido ISS (após crédito): R$ {imposto_liq:.2f}")
print(f"Custo líquido do serviço: R$ {custo:.2f}")
```

**Saída real:**
```
Base de cálculo ISS: R$ 1900.00
Imposto bruto ISS: R$ 95.00
Imposto líquido ISS (após crédito): R$ 0.00
Custo líquido do serviço: R$ 1900.00
```

**Explicação:**  
- O desconto condicional é deduzido antes de aplicar a alíquota.  
- O crédito tributário é aplicado ao imposto bruto, mas não pode gerar imposto negativo.  
- O custo líquido considera o valor final pago, incluindo o imposto líquido devido.  

---

### 3. Validação da Base de Cálculo no CBS e Aplicação do Crédito Tributário  (intermediário)

```python
def calcular_cbs(preco_bruto, desconto_condicional, aliquota, credito):
    # Base de cálculo do CBS não deduz desconto condicional
    base_calculo = preco_bruto  # desconto não deduzido

    # Imposto bruto = base de cálculo * alíquota
    imposto_bruto = base_calculo * aliquota / 100

    # Imposto líquido = imposto bruto - crédito, mínimo zero
    imposto_liquido = max(imposto_bruto - credito, 0)

    # Custo líquido = preço bruto - desconto condicional + imposto líquido
    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido

    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido


# Dados da operação
preco = 2000.0
desconto = 100.0
aliquota_cbs = 12
credito = 250.0

base, imposto_bruto, imposto_liq, custo = calcular_cbs(preco, desconto, aliquota_cbs, credito)

print(f"Base de cálculo CBS: R$ {base:.2f}")
print(f"Imposto bruto CBS: R$ {imposto_bruto:.2f}")
print(f"Imposto líquido CBS (após crédito): R$ {imposto_liq:.2f}")
print(f"Custo líquido da operação: R$ {custo:.2f}")
```

**Saída real:**
```
Base de cálculo CBS: R$ 2000.00
Imposto bruto CBS: R$ 240.00
Imposto líquido CBS (após crédito): R$ 0.00
Custo líquido da operação: R$ 1900.00
```

**Explicação:**  
- A base do CBS é o preço bruto integral, não se deduz descontos condicionais, conforme legislação vigente.  
- O crédito tributário é aplicado somente após cálculo do imposto bruto, limitando o imposto líquido a zero.  
- O custo líquido considera o desconto condicional, porque ele reduz o valor efetivamente pago ao fornecedor.  
- Não deduzir o desconto da base evita aumento indevido do imposto.  

---

### 4. Apropriação de Crédito Tributário no IBS com Limite e Impacto no Custo Líquido  (desafio)

```python
def calcular_ibs_com_credito(preco_bruto, desconto_condicional, aliquota, credito):
    base_calculo = preco_bruto - desconto_condicional
    imposto_bruto = base_calculo * aliquota / 100

    # Crédito aplicado não pode ultrapassar o imposto bruto
    credito_aplicado = min(credito, imposto_bruto)

    imposto_liquido = imposto_bruto - credito_aplicado

    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido

    return base_calculo, imposto_bruto, credito_aplicado, imposto_liquido, custo_liquido


preco = 2000.0
desconto = 100.0
aliquota_ibs = 12
credito = 250.0

base, imposto_bruto, credito_usado, imposto_liq, custo = calcular_ibs_com_credito(
    preco, desconto, aliquota_ibs, credito
)

print(f"Base de cálculo IBS: R$ {base:.2f}")
print(f"Imposto bruto IBS: R$ {imposto_bruto:.2f}")
print(f"Crédito aplicado: R$ {credito_usado:.2f}")
print(f"Imposto líquido IBS: R$ {imposto_liq:.2f}")
print(f"Custo líquido da operação: R$ {custo:.2f}")
```

**Saída real:**
```
Base de cálculo IBS: R$ 1900.00
Imposto bruto IBS: R$ 228.00
Crédito aplicado: R$ 228.00
Imposto líquido IBS: R$ 0.00
Custo líquido da operação: R$ 1900.00
```

**Explicação:**  
- O crédito tributário não pode exceder o imposto bruto, evitando imposto negativo ou restituição.  
- O crédito aplicado é o mínimo entre crédito disponível e imposto bruto.  
- Isso assegura conformidade fiscal e evita erros no cálculo tributário.  
- O custo líquido reflete o valor final após descontos e impostos líquidos.  
- Na análise econômica, isso mostra que um crédito maior que o imposto não gera benefício adicional imediato.  

---

### 5. Cálculo Integrado para Escolha de Fornecedor com Base em CNAE, LC116 e NBS  (desafio)

```python
def validar_vinculacao(cnae, lc116, nbs):
    # Para este exercício, assumimos que os códigos dados são válidos e vinculados
    # Em sistema real, checaria tabelas oficiais de vinculação CNAE x LC116 x NBS
    return True

def calcular_ibs(preco_bruto, desconto_condicional, aliquota, credito):
    base_calculo = preco_bruto - desconto_condicional
    imposto_bruto = base_calculo * aliquota / 100
    credito_aplicado = min(credito, imposto_bruto)
    imposto_liquido = imposto_bruto - credito_aplicado
    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido
    return base_calculo, imposto_bruto, imposto_liquido, credito_aplicado, custo_liquido

fornecedores = {
    "Fornecedor A": {"preco": 2000.0, "desconto": 100.0, "cnae": "6201501", "lc116": "0101", "nbs": "060101", "aliquota": 12, "credito": 250.0},
    "Fornecedor B": {"preco": 1950.0, "desconto": 200.0, "cnae": "6201501", "lc116": "0101", "nbs": "060101", "aliquota": 12, "credito": 180.0},
}

resultados = {}
for nome, dados in fornecedores.items():
    if validar_vinculacao(dados["cnae"], dados["lc116"], dados["nbs"]):
        base, imposto_bruto, imposto_liquido, credito_usado, custo_liquido = calcular_ibs(
            dados["preco"], dados["desconto"], dados["aliquota"], dados["credito"]
        )
        resultados[nome] = {
            "base_calculo": base,
            "imposto_bruto": imposto_bruto,
            "imposto_liquido": imposto_liquido,
            "credito_aplicado": credito_usado,
            "custo_liquido": custo_liquido,
        }
    else:
        resultados[nome] = None

for nome, res in resultados.items():
    if res:
        print(f"{nome}:")
        print(f"  Base de cálculo: R$ {res['base_calculo']:.2f}")
        print(f"  Imposto bruto: R$ {res['imposto_bruto']:.2f}")
        print(f"  Crédito aplicado: R$ {res['credito_aplicado']:.2f}")
        print(f"  Imposto líquido: R$ {res['imposto_liquido']:.2f}")
        print(f"  Custo líquido: R$ {res['custo_liquido']:.2f}")
    else:
        print(f"{nome}: Vinculação inválida dos códigos CNAE/LC116/NBS")
    print()

melhor = min((f for f in resultados.items() if f[1]), key=lambda x: x[1]["custo_liquido"])
print(f"Melhor fornecedor considerando custo líquido: {melhor[0]} com R$ {melhor[1]['custo_liquido']:.2f}")
```

**Saída real:**
```
Fornecedor A:
  Base de cálculo: R$ 1900.00
  Imposto bruto: R$ 228.00
  Crédito aplicado: R$ 228.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1900.00

Fornecedor B:
  Base de cálculo: R$ 1750.00
  Imposto bruto: R$ 210.00
  Crédito aplicado: R$ 180.00
  Imposto líquido: R$ 30.00
  Custo líquido: R$ 1780.00

Melhor fornecedor considerando custo líquido: Fornecedor B com R$ 1780.00
```

**Explicação:**  
- A vinculação correta entre CNAE, LC116 e NBS é fundamental para apropriação válida de créditos tributários, garantindo que o crédito possa ser aplicado.  
- O cálculo considera base de cálculo ajustada, imposto bruto, crédito aplicado (limitado ao imposto bruto), imposto líquido e custo líquido.  
- Embora o Fornecedor A tenha crédito maior, o preço bruto e desconto diferentes fazem o custo líquido maior que o do Fornecedor B.  
- O programa valida a vinculação (simulada aqui como sempre verdadeira) para garantir conformidade.  
- Essa análise integrada permite escolher o fornecedor com o menor custo tributário líquido, não apenas pelo preço bruto.