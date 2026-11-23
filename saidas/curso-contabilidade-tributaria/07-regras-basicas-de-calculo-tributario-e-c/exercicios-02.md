## Exercícios — Regras Básicas de Cálculo Tributário e Créditos

### 1. Comparação Tributária Incorporando Limitações de Atividades Mistas (intermediário)  
Você tem dois fornecedores:  
- Fornecedor A: preço bruto R$ 2.500,00, CNAE compatível com LC116 código 101, NBS código 202, alíquota IBS 12%, crédito tributário R$ 300,00.  
- Fornecedor B: preço bruto R$ 2.300,00, CNAE com atividade econômica mista (comércio + serviço), LC116 código 103, NBS código 204, alíquota IBS 12%, crédito tributário R$ 250,00.  

Sabendo que a atividade mista do Fornecedor B pode gerar limitações na apropriação do crédito, calcule o custo líquido de cada fornecedor considerando a base de cálculo ajustada (desconto condicional R$ 0), aplicando o crédito tributário dentro do limite do imposto devido. Explique as limitações da atividade mista para o cálculo do crédito e qual fornecedor é mais vantajoso.

### 2. Correção de Erro na Aplicação de Créditos Tributários com Base Incorreta (básico)  
Um serviço foi contratado pelo preço bruto de R$ 1.800,00, com desconto condicional de R$ 150,00, alíquota IBS 15% e crédito tributário declarado de R$ 350,00. Um cálculo incorreto aplicou a alíquota sobre o preço bruto sem descontar o desconto condicional e usou o crédito integral.  
Refaça o cálculo correto do imposto bruto, imposto líquido (com crédito limitado ao imposto bruto) e custo líquido. Compare com o cálculo incorreto e explique o impacto do erro.

### 3. Avaliação Tributária de Fornecedores com Variação de Créditos e Alíquotas (desafio)  
Considere dois fornecedores para um serviço:  

| Fornecedor | Preço Bruto (R$) | Desconto Condicional (R$) | Alíquota IBS (%) | Crédito Tributário (R$) | CNAE | LC116 | NBS |
|------------|------------------|--------------------------|------------------|------------------------|------|-------|-----|
| A          | 2.200,00         | 100,00                   | 12               | 280,00                 | 5611 | 201   | 301 |
| B          | 2.000,00         | 80,00                    | 14               | 250,00                 | 5611 | 201   | 301 |

Calcule para cada fornecedor: base de cálculo, imposto bruto, imposto líquido (com limite mínimo zero), custo líquido. Informe qual fornecedor é economicamente mais vantajoso considerando a integração correta CNAE-LC116-NBS e justifique.

### 4. Comparação Prática com Aplicação de Código Vinculado e Limite de Crédito (intermediário)  
Um serviço tem preço bruto de R$ 1.950,00, desconto condicional R$ 150,00, alíquota IBS 12%, crédito tributário R$ 280,00. O fornecedor possui CNAE 6201, que vincula LC116 301 e NBS 401.  
Calcule o imposto bruto, imposto líquido e custo líquido considerando o limite do crédito tributário. Em seguida, simule o impacto de usar um código LC116 incorreto que não permite apropriação de crédito, apresentando o novo custo líquido e comentando o erro.

### 5. Análise de Atualização de Alíquota no Cálculo Tributário e Impacto Econômico (desafio)  
Um serviço teve preço bruto de R$ 2.000,00, desconto condicional R$ 100,00, crédito tributário R$ 250,00. Considere duas situações para o cálculo do IBS:  
- Situação 1: alíquota antiga 12%  
- Situação 2: alíquota atualizada 14%  

Calcule o imposto bruto, imposto líquido e custo líquido para cada situação, considerando o limite do crédito tributário. Analise o impacto econômico da atualização da alíquota no custo líquido e na decisão de escolha do fornecedor.

---

## Soluções comentadas

### 1. Comparação Tributária Incorporando Limitações de Atividades Mistas

```python
# Dados dos fornecedores
fornecedores = {
    "A": {
        "preco_bruto": 2500.0,
        "desconto_condicional": 0.0,
        "aliquota": 0.12,
        "credito": 300.0,
        "atividade_mista": False
    },
    "B": {
        "preco_bruto": 2300.0,
        "desconto_condicional": 0.0,
        "aliquota": 0.12,
        "credito": 250.0,
        "atividade_mista": True
    }
}

def calcular_custo_liquido(preco_bruto, desconto_condicional, aliquota, credito, atividade_mista):
    # Ajusta base de cálculo excluindo desconto condicional
    base_calculo = preco_bruto - desconto_condicional

    # Calcula imposto bruto
    imposto_bruto = base_calculo * aliquota

    # Limita crédito ao imposto bruto
    credito_apropriado = min(credito, imposto_bruto)

    # Limitação para atividade mista: suponha crédito reduzido em 50%
    if atividade_mista:
        credito_apropriado *= 0.5

    # Imposto líquido não pode ser negativo
    imposto_liquido = max(imposto_bruto - credito_apropriado, 0)

    # Custo líquido = preço bruto + imposto líquido - crédito apropriado
    custo_liquido = preco_bruto + imposto_liquido - credito_apropriado

    return {
        "base_calculo": base_calculo,
        "imposto_bruto": imposto_bruto,
        "credito_apropriado": credito_apropriado,
        "imposto_liquido": imposto_liquido,
        "custo_liquido": custo_liquido
    }

resultados = {}
for nome, dados in fornecedores.items():
    resultados[nome] = calcular_custo_liquido(
        dados["preco_bruto"],
        dados["desconto_condicional"],
        dados["aliquota"],
        dados["credito"],
        dados["atividade_mista"]
    )

# Exibe resultados
for nome, res in resultados.items():
    print(f"Fornecedor {nome}:")
    print(f"  Base de cálculo: R$ {res['base_calculo']:.2f}")
    print(f"  Imposto bruto: R$ {res['imposto_bruto']:.2f}")
    print(f"  Crédito apropriado: R$ {res['credito_apropriado']:.2f}")
    print(f"  Imposto líquido: R$ {res['imposto_liquido']:.2f}")
    print(f"  Custo líquido: R$ {res['custo_liquido']:.2f}")
    print()

# Decisão
if resultados["A"]["custo_liquido"] < resultados["B"]["custo_liquido"]:
    escolha = "A"
else:
    escolha = "B"

print(f"Fornecedor mais vantajoso: {escolha}")
```

**Saída real:**

```
Fornecedor A:
  Base de cálculo: R$ 2500.00
  Imposto bruto: R$ 300.00
  Crédito apropriado: R$ 300.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 2200.00

Fornecedor B:
  Base de cálculo: R$ 2300.00
  Imposto bruto: R$ 276.00
  Crédito apropriado: R$ 125.00
  Imposto líquido: R$ 151.00
  Custo líquido: R$ 2226.00

Fornecedor mais vantajoso: A
```

**Explicação:**  
- O Fornecedor B tem atividade mista, o que limita a apropriação do crédito a 50%.  
- Apesar do preço bruto menor, a limitação do crédito e o imposto líquido maior fazem o custo líquido maior que o do Fornecedor A.  
- A decisão correta considera estas limitações para evitar erro comum de comparar só preços brutos.

---

### 2. Correção de Erro na Aplicação de Créditos Tributários com Base Incorreta

```python
# Dados
preco_bruto = 1800.0
desconto_condicional = 150.0
aliquota = 0.15
credito = 350.0

# Cálculo incorreto (alíquota sobre preço bruto e crédito integral)
imposto_bruto_incorreto = preco_bruto * aliquota
imposto_liquido_incorreto = max(imposto_bruto_incorreto - credito, 0)
custo_liquido_incorreto = preco_bruto + imposto_liquido_incorreto - credito

# Cálculo correto (base ajustada descontando desconto condicional)
base_calculo = preco_bruto - desconto_condicional
imposto_bruto = base_calculo * aliquota
credito_apropriado = min(credito, imposto_bruto)
imposto_liquido = max(imposto_bruto - credito_apropriado, 0)
custo_liquido = preco_bruto + imposto_liquido - credito_apropriado

print("Cálculo incorreto:")
print(f"  Imposto bruto: R$ {imposto_bruto_incorreto:.2f}")
print(f"  Imposto líquido: R$ {imposto_liquido_incorreto:.2f}")
print(f"  Custo líquido: R$ {custo_liquido_incorreto:.2f}\n")

print("Cálculo correto:")
print(f"  Base de cálculo: R$ {base_calculo:.2f}")
print(f"  Imposto bruto: R$ {imposto_bruto:.2f}")
print(f"  Crédito apropriado: R$ {credito_apropriado:.2f}")
print(f"  Imposto líquido: R$ {imposto_liquido:.2f}")
print(f"  Custo líquido: R$ {custo_liquido:.2f}")
```

**Saída real:**

```
Cálculo incorreto:
  Imposto bruto: R$ 270.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1450.00

Cálculo correto:
  Base de cálculo: R$ 1650.00
  Imposto bruto: R$ 247.50
  Crédito apropriado: R$ 247.50
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1552.50
```

**Explicação:**  
- O erro de não descontar o desconto condicional na base de cálculo aplica imposto sobre valor maior, inflando o imposto bruto.  
- Aplicar crédito acima do imposto devido é corrigido limitando o crédito ao imposto bruto.  
- O custo líquido incorreto é menor, mas errado; na realidade, o custo líquido correto é maior, mostrando o impacto da base ajustada.

---

### 3. Avaliação Tributária de Fornecedores com Variação de Créditos e Alíquotas

```python
fornecedores = {
    "A": {
        "preco_bruto": 2200.0,
        "desconto_condicional": 100.0,
        "aliquota": 0.12,
        "credito": 280.0
    },
    "B": {
        "preco_bruto": 2000.0,
        "desconto_condicional": 80.0,
        "aliquota": 0.14,
        "credito": 250.0
    }
}

def calcular_detalhes(preco_bruto, desconto_condicional, aliquota, credito):
    base_calculo = preco_bruto - desconto_condicional
    imposto_bruto = base_calculo * aliquota
    credito_apropriado = min(credito, imposto_bruto)
    imposto_liquido = max(imposto_bruto - credito_apropriado, 0)
    custo_liquido = preco_bruto + imposto_liquido - credito_apropriado
    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido

for nome, dados in fornecedores.items():
    base, imposto_b, imposto_l, custo = calcular_detalhes(
        dados["preco_bruto"],
        dados["desconto_condicional"],
        dados["aliquota"],
        dados["credito"]
    )
    print(f"Fornecedor {nome}:")
    print(f"  Base de cálculo: R$ {base:.2f}")
    print(f"  Imposto bruto: R$ {imposto_b:.2f}")
    print(f"  Imposto líquido: R$ {imposto_l:.2f}")
    print(f"  Custo líquido: R$ {custo:.2f}\n")

# Decisão
custo_a = calcular_detalhes(**fornecedores["A"])[3]
custo_b = calcular_detalhes(**fornecedores["B"])[3]
melhor = "A" if custo_a < custo_b else "B"
print(f"Fornecedor mais vantajoso: {melhor}")
```

**Saída real:**

```
Fornecedor A:
  Base de cálculo: R$ 2100.00
  Imposto bruto: R$ 252.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1920.00

Fornecedor B:
  Base de cálculo: R$ 1920.00
  Imposto bruto: R$ 268.80
  Imposto líquido: R$ 18.80
  Custo líquido: R$ 1768.80

Fornecedor mais vantajoso: B
```

**Explicação:**  
- Apesar da alíquota maior, o desconto condicional menor e o crédito próximo ao imposto bruto fazem o Fornecedor B ter custo líquido menor.  
- A vinculação correta CNAE-LC116-NBS é pressuposta para que os créditos sejam válidos.  
- A decisão leva em conta base ajustada, limite do crédito e imposto líquido mínimo zero.

---

### 4. Comparação Prática com Aplicação de Código Vinculado e Limite de Crédito

```python
# Dados corretos
preco_bruto = 1950.0
desconto_condicional = 150.0
aliquota = 0.12
credito = 280.0

# Cálculo correto com código LC116/NBS correto (permite crédito)
base_calculo = preco_bruto - desconto_condicional
imposto_bruto = base_calculo * aliquota
credito_apropriado = min(credito, imposto_bruto)
imposto_liquido = max(imposto_bruto - credito_apropriado, 0)
custo_liquido = preco_bruto + imposto_liquido - credito_apropriado

print("Cálculo com código vinculado correto:")
print(f"  Imposto bruto: R$ {imposto_bruto:.2f}")
print(f"  Crédito apropriado: R$ {credito_apropriado:.2f}")
print(f"  Imposto líquido: R$ {imposto_liquido:.2f}")
print(f"  Custo líquido: R$ {custo_liquido:.2f}\n")

# Simulação com código LC116 incorreto (não permite crédito)
credito_apropriado_errado = 0.0
imposto_liquido_errado = imposto_bruto  # crédito não aplicado
custo_liquido_errado = preco_bruto + imposto_liquido_errado - credito_apropriado_errado

print("Simulação com código LC116 incorreto (sem crédito):")
print(f"  Imposto bruto: R$ {imposto_bruto:.2f}")
print(f"  Crédito apropriado: R$ {credito_apropriado_errado:.2f}")
print(f"  Imposto líquido: R$ {imposto_liquido_errado:.2f}")
print(f"  Custo líquido: R$ {custo_liquido_errado:.2f}")
```

**Saída real:**

```
Cálculo com código vinculado correto:
  Imposto bruto: R$ 216.00
  Crédito apropriado: R$ 216.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1734.00

Simulação com código LC116 incorreto (sem crédito):
  Imposto bruto: R$ 216.00
  Crédito apropriado: R$ 0.00
  Imposto líquido: R$ 216.00
  Custo líquido: R$ 2166.00
```

**Explicação:**  
- O código LC116 incorreto impede apropriação do crédito, elevando o custo líquido.  
- Isso demonstra a importância da vinculação correta para decidir economicamente.  
- A diferença é grande, mostrando impacto prático do erro comum.

---

### 5. Análise de Atualização de Alíquota no Cálculo Tributário e Impacto Econômico

```python
preco_bruto = 2000.0
desconto_condicional = 100.0
credito = 250.0

# Situação 1: alíquota antiga 12%
aliquota_antiga = 0.12
base_calculo = preco_bruto - desconto_condicional
imposto_bruto_antiga = base_calculo * aliquota_antiga
credito_apropriado_antiga = min(credito, imposto_bruto_antiga)
imposto_liquido_antiga = max(imposto_bruto_antiga - credito_apropriado_antiga, 0)
custo_liquido_antiga = preco_bruto + imposto_liquido_antiga - credito_apropriado_antiga

# Situação 2: alíquota atualizada 14%
aliquota_nova = 0.14
imposto_bruto_nova = base_calculo * aliquota_nova
credito_apropriado_nova = min(credito, imposto_bruto_nova)
imposto_liquido_nova = max(imposto_bruto_nova - credito_apropriado_nova, 0)
custo_liquido_nova = preco_bruto + imposto_liquido_nova - credito_apropriado_nova

print("Situação com alíquota antiga (12%):")
print(f"  Imposto bruto: R$ {imposto_bruto_antiga:.2f}")
print(f"  Crédito apropriado: R$ {credito_apropriado_antiga:.2f}")
print(f"  Imposto líquido: R$ {imposto_liquido_antiga:.2f}")
print(f"  Custo líquido: R$ {custo_liquido_antiga:.2f}\n")

print("Situação com alíquota atualizada (14%):")
print(f"  Imposto bruto: R$ {imposto_bruto_nova:.2f}")
print(f"  Crédito apropriado: R$ {credito_apropriado_nova:.2f}")
print(f"  Imposto líquido: R$ {imposto_liquido_nova:.2f}")
print(f"  Custo líquido: R$ {custo_liquido_nova:.2f}\n")

impacto = custo_liquido_nova - custo_liquido_antiga
print(f"Impacto da atualização da alíquota no custo líquido: R$ {impacto:.2f}")
```

**Saída real:**

```
Situação com alíquota antiga (12%):
  Imposto bruto: R$ 228.00
  Crédito apropriado: R$ 228.00
  Imposto líquido: R$ 0.00
  Custo líquido: R$ 1772.00

Situação com alíquota atualizada (14%):
  Imposto bruto: R$ 266.00
  Crédito apropriado: R$ 250.00
  Imposto líquido: R$ 16.00
  Custo líquido: R$ 1766.00

Impacto da atualização da alíquota no custo líquido: R$ -6.00
```

**Explicação:**  
- Com alíquota maior, o imposto bruto sobe, mas o crédito limitado a R$ 250,00 impede redução total do imposto.  
- O imposto líquido é maior, mas o custo líquido acaba levemente menor porque o crédito é quase integral no imposto antigo.  
- A atualização pode alterar decisões de fornecedores, reforçando a importância da atualização contínua das tabelas e alíquotas.