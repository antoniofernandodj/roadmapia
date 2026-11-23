## Exercícios Práticos de Cálculo Tributário com Créditos

Para fixar o cálculo básico dos tributos ISS, IBS e CBS e a correta apropriação dos créditos tributários, apresentamos exercícios práticos que simulam situações reais de análise econômica na escolha de fornecedores. Cada exercício propõe o cálculo do imposto devido, do crédito aplicado e do custo líquido tributário, com base em dados típicos de operações comerciais após a reforma tributária. A resolução detalhada e o código Python mostram o passo a passo, para que o aluno compreenda os mecanismos e evite erros comuns.

---

### Exercício 1: Cálculo Simples com IBS - Base Ajustada, Alíquota e Crédito

**Dados:**

- Preço bruto do serviço: R$ 2.000,00  
- Desconto condicional: R$ 100,00  
- Alíquota do IBS: 12%  
- Crédito tributário disponível: R$ 250,00  

**Objetivos:**

- Determinar a base de cálculo correta do IBS ajustada pelo desconto condicional (que reduz a base).  
- Calcular o imposto bruto (alíquota sobre a base ajustada).  
- Aplicar o crédito tributário, limitando o imposto devido a mínimo zero.  
- Calcular o custo líquido tributário do serviço.

---

**Resolução detalhada:**

1. **Base de cálculo do IBS**: preço bruto menos desconto condicional.  
   \[
   \text{Base} = 2.000,00 - 100,00 = 1.900,00
   \]

2. **Imposto bruto**: aplicar alíquota de 12% sobre a base.  
   \[
   \text{Imposto bruto} = 1.900,00 \times 0,12 = 228,00
   \]

3. **Imposto líquido**: subtrair o crédito tributário, respeitando o limite mínimo zero.  
   \[
   \text{Imposto líquido} = \max(228,00 - 250,00, 0) = 0
   \]

4. **Custo líquido**: preço bruto menos desconto condicional mais imposto líquido.  
   \[
   \text{Custo líquido} = 1.900,00 + 0 = 1.900,00
   \]

**Observação:** O crédito é maior que o imposto bruto, portanto o imposto devido é zero, sem restituição.

---

**Código Python completo:**

```python
def calcular_custo_ibs(preco_bruto, desconto_condicional, aliquota, credito):
    base_calculo = preco_bruto - desconto_condicional
    imposto_bruto = base_calculo * aliquota
    imposto_liquido = max(imposto_bruto - credito, 0)
    custo_liquido = base_calculo + imposto_liquido
    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido

# Dados do exercício
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_ibs = 0.12
credito_tributario = 250.00

base, imposto_b, imposto_l, custo = calcular_custo_ibs(
    preco_bruto,
    desconto_condicional,
    aliquota_ibs,
    credito_tributario
)

print(f"Base de cálculo: R$ {base:.2f}")
print(f"Imposto bruto: R$ {imposto_b:.2f}")
print(f"Imposto líquido (após crédito): R$ {imposto_l:.2f}")
print(f"Custo líquido tributário: R$ {custo:.2f}")
```

**Saída esperada:**

```
Base de cálculo: R$ 1900.00
Imposto bruto: R$ 228.00
Imposto líquido (após crédito): R$ 0.00
Custo líquido tributário: R$ 1900.00
```

---

### Exercício 2: Cálculo do ISS com Desconto Condicional e Crédito Tributário

**Dados:**

- Preço bruto do serviço: R$ 2.000,00  
- Desconto condicional: R$ 100,00  
- Alíquota do ISS: 5%  
- Crédito tributário: R$ 250,00  

**Objetivos:**

- Calcular a base de cálculo do ISS excluindo o desconto condicional.  
- Calcular o imposto bruto com aplicação da alíquota sobre a base ajustada.  
- Aplicar o crédito tributário com limite mínimo zero.  
- Determinar o custo líquido tributário final.

---

**Resolução:**

1. Base de cálculo:  
   \[
   2.000,00 - 100,00 = 1.900,00
   \]

2. Imposto bruto:  
   \[
   1.900,00 \times 0,05 = 95,00
   \]

3. Imposto líquido:  
   \[
   \max(95,00 - 250,00, 0) = 0
   \]

4. Custo líquido tributário:  
   \[
   1.900,00 + 0 = 1.900,00
   \]

---

**Código Python:**

```python
def calcular_custo_iss(preco_bruto, desconto_condicional, aliquota, credito):
    base_calculo = preco_bruto - desconto_condicional
    imposto_bruto = base_calculo * aliquota
    imposto_liquido = max(imposto_bruto - credito, 0)
    custo_liquido = base_calculo + imposto_liquido
    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido

# Dados
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_iss = 0.05
credito_tributario = 250.00

base, imposto_b, imposto_l, custo = calcular_custo_iss(
    preco_bruto,
    desconto_condicional,
    aliquota_iss,
    credito_tributario
)

print(f"Base de cálculo: R$ {base:.2f}")
print(f"Imposto bruto: R$ {imposto_b:.2f}")
print(f"Imposto líquido (após crédito): R$ {imposto_l:.2f}")
print(f"Custo líquido tributário: R$ {custo:.2f}")
```

**Saída:**

```
Base de cálculo: R$ 1900.00
Imposto bruto: R$ 95.00
Imposto líquido (após crédito): R$ 0.00
Custo líquido tributário: R$ 1900.00
```

---

### Exercício 3: Cálculo do CBS respeitando base integral e crédito

**Dados:**

- Preço bruto da operação: R$ 2.000,00  
- Desconto condicional: R$ 100,00 (não deduzido da base)  
- Alíquota CBS: 12%  
- Crédito tributário: R$ 250,00  

**Objetivos:**

- Calcular o imposto CBS aplicando a alíquota sobre o preço bruto integral (sem desconto).  
- Aplicar o crédito tributário com limite mínimo zero.  
- Calcular o custo líquido tributário, considerando o desconto condicional e o imposto líquido.

---

**Resolução:**

1. Base de cálculo do CBS: preço bruto integral, pois não exclui desconto condicional.  
   \[
   2.000,00
   \]

2. Imposto bruto:  
   \[
   2.000,00 \times 0,12 = 240,00
   \]

3. Imposto líquido:  
   \[
   \max(240,00 - 250,00, 0) = 0
   \]

4. Custo líquido:  
   \[
   (2.000,00 - 100,00) + 0 = 1.900,00
   \]

---

**Código Python:**

```python
def calcular_custo_cbs(preco_bruto, desconto_condicional, aliquota, credito):
    base_calculo = preco_bruto  # CBS não deduz desconto condicional
    imposto_bruto = base_calculo * aliquota
    imposto_liquido = max(imposto_bruto - credito, 0)
    custo_liquido = (preco_bruto - desconto_condicional) + imposto_liquido
    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido

# Dados
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_cbs = 0.12
credito_tributario = 250.00

base, imposto_b, imposto_l, custo = calcular_custo_cbs(
    preco_bruto,
    desconto_condicional,
    aliquota_cbs,
    credito_tributario
)

print(f"Base de cálculo: R$ {base:.2f}")
print(f"Imposto bruto: R$ {imposto_b:.2f}")
print(f"Imposto líquido (após crédito): R$ {imposto_l:.2f}")
print(f"Custo líquido tributário: R$ {custo:.2f}")
```

**Saída:**

```
Base de cálculo: R$ 2000.00
Imposto bruto: R$ 240.00
Imposto líquido (após crédito): R$ 0.00
Custo líquido tributário: R$ 1900.00
```

---

### Exercício 4: Comparação tributária entre dois fornecedores considerando créditos

**Dados:**

- **Fornecedor A:**  
  - Preço bruto: R$ 100,00  
  - Crédito tributário gerado: R$ 15,00  

- **Fornecedor B:**  
  - Preço bruto: R$ 95,00  
  - Crédito tributário gerado: R$ 0,00  

**Objetivo:**

- Calcular o custo líquido de cada fornecedor considerando o crédito tributário.  
- Identificar qual fornecedor é mais vantajoso economicamente.

---

**Resolução:**

1. **Fornecedor A:**  
   \[
   \text{Custo líquido} = 100,00 - 15,00 = 85,00
   \]

2. **Fornecedor B:**  
   \[
   \text{Custo líquido} = 95,00 - 0,00 = 95,00
   \]

**Conclusão:** Apesar de o preço bruto do Fornecedor A ser maior, o crédito tributário faz com que o custo líquido seja menor, tornando-o a melhor opção.

---

**Código Python:**

```python
def comparar_fornecedores(preco_a, credito_a, preco_b, credito_b):
    custo_liquido_a = preco_a - credito_a
    custo_liquido_b = preco_b - credito_b
    melhor = "Fornecedor A" if custo_liquido_a < custo_liquido_b else "Fornecedor B"
    return custo_liquido_a, custo_liquido_b, melhor

preco_a = 100.00
credito_a = 15.00
preco_b = 95.00
credito_b = 0.00

custo_a, custo_b, melhor_fornecedor = comparar_fornecedores(preco_a, credito_a, preco_b, credito_b)
print(f"Custo líquido Fornecedor A: R$ {custo_a:.2f}")
print(f"Custo líquido Fornecedor B: R$ {custo_b:.2f}")
print(f"Melhor fornecedor: {melhor_fornecedor}")
```

**Saída:**

```
Custo líquido Fornecedor A: R$ 85.00
Custo líquido Fornecedor B: R$ 95.00
Melhor fornecedor: Fornecedor A
```

---

### Exercício 5: Erro comum ao aplicar alíquota diretamente sobre preço bruto e correção

**Situação:**

Um profissional aplica a alíquota do IBS de 12% diretamente sobre o preço bruto de R$ 2.000,00, sem descontar o desconto condicional de R$ 100,00, e depois aplica o crédito tributário de R$ 250,00.

**Cálculo incorreto:**

- Imposto bruto (errado):  
  \[
  2.000,00 \times 0,12 = 240,00
  \]

- Imposto líquido:  
  \[
  \max(240,00 - 250,00, 0) = 0
  \]

- Custo líquido:  
  \[
  (2.000,00 - 100,00) + 0 = 1.900,00
  \]

**Porém, o erro está em calcular imposto sobre base errada, pois deve descontar o desconto condicional para base de cálculo.**

---

**Correção:**

- Base correta:  
  \[
  2.000,00 - 100,00 = 1.900,00
  \]

- Imposto bruto corrigido:  
  \[
  1.900,00 \times 0,12 = 228,00
  \]

- Imposto líquido corrigido:  
  \[
  \max(228,00 - 250,00, 0) = 0
  \]

- Custo líquido corrigido:  
  \[
  1.900,00 + 0 = 1.900,00
  \]

---

**Código Python para comparar:**

```python
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_ibs = 0.12
credito = 250.00

# Cálculo incorreto
imposto_bruto_errado = preco_bruto * aliquota_ibs
imposto_liquido_errado = max(imposto_bruto_errado - credito, 0)
custo_liquido_errado = (preco_bruto - desconto_condicional) + imposto_liquido_errado

# Cálculo correto
base_calculo_correta = preco_bruto - desconto_condicional
imposto_bruto_correto = base_calculo_correta * aliquota_ibs
imposto_liquido_correto = max(imposto_bruto_correto - credito, 0)
custo_liquido_correto = base_calculo_correta + imposto_liquido_correto

print("Cálculo incorreto:")
print(f"Imposto bruto: R$ {imposto_bruto_errado:.2f}")
print(f"Imposto líquido: R$ {imposto_liquido_errado:.2f}")
print(f"Custo líquido: R$ {custo_liquido_errado:.2f}\n")

print("Cálculo correto:")
print(f"Base de cálculo: R$ {base_calculo_correta:.2f}")
print(f"Imposto bruto: R$ {imposto_bruto_correto:.2f}")
print(f"Imposto líquido: R$ {imposto_liquido_correto:.2f}")
print(f"Custo líquido: R$ {custo_liquido_correto:.2f}")
```

**Saída:**

```
Cálculo incorreto:
Imposto bruto: R$ 240.00
Imposto líquido: R$ 0.00
Custo líquido: R$ 1900.00

Cálculo correto:
Base de cálculo: R$ 1900.00
Imposto bruto: R$ 228.00
Imposto líquido: R$ 0.00
Custo líquido: R$ 1900.00
```

---

### Exercício 6: Apropriação proporcional de crédito tributário em operação mista

**Contexto:**

Um fornecedor tem atividade mista, e a apropriação do crédito tributário deve ser proporcional à parcela da operação tributada pelo IBS. Suponha:

- Preço bruto: R$ 3.000,00  
- Desconto condicional: R$ 150,00  
- Alíquota IBS: 12%  
- Crédito tributário total disponível: R$ 450,00  
- Parcela tributada pelo IBS: 60% do preço bruto  

**Objetivo:**

Calcular:

- A base de cálculo para IBS (descontando o desconto condicional e considerando a parcela tributada).  
- O imposto bruto sobre a base proporcional.  
- Crédito tributário proporcional aplicado.  
- Imposto líquido e custo líquido tributário.

---

**Resolução:**

1. Base ajustada:  
   \[
   (3.000,00 - 150,00) \times 0,60 = 2.850,00 \times 0,60 = 1.710,00
   \]

2. Imposto bruto:  
   \[
   1.710,00 \times 0,12 = 205,20
   \]

3. Crédito proporcional:  
   \[
   450,00 \times 0,60 = 270,00
   \]

4. Imposto líquido:  
   \[
   \max(205,20 - 270,00, 0) = 0
   \]

5. Custo líquido:  
   \[
   (3.000,00 - 150,00) + 0 = 2.850,00
   \]

---

**Código Python:**

```python
def calcular_credito_proporcional(preco_bruto, desconto_condicional, aliquota, credito_total, proporcao_tributada):
    base_ajustada = (preco_bruto - desconto_condicional) * proporcao_tributada
    imposto_bruto = base_ajustada * aliquota
    credito_proporcional = credito_total * proporcao_tributada
    imposto_liquido = max(imposto_bruto - credito_proporcional, 0)
    custo_liquido = (preco_bruto - desconto_condicional) + imposto_liquido
    return base_ajustada, imposto_bruto, credito_proporcional, imposto_liquido, custo_liquido

preco_bruto = 3000.00
desconto_condicional = 150.00
aliquota_ibs = 0.12
credito_total = 450.00
proporcao_tributada = 0.60

base, imposto_b, credito_p, imposto_l, custo = calcular_credito_proporcional(
    preco_bruto,
    desconto_condicional,
    aliquota_ibs,
    credito_total,
    proporcao_tributada
)

print(f"Base ajustada para IBS: R$ {base:.2f}")
print(f"Imposto bruto: R$ {imposto_b:.2f}")
print(f"Crédito proporcional aplicado: R$ {credito_p:.2f}")
print(f"Imposto líquido: R$ {imposto_l:.2f}")
print(f"Custo líquido tributário: R$ {custo:.2f}")
```

**Saída:**

```
Base ajustada para IBS: R$ 1710.00
Imposto bruto: R$ 205.20
Crédito proporcional aplicado: R$ 270.00
Imposto líquido: R$ 0.00
Custo líquido tributário: R$ 2850.00
```

---

## Exercício Proposto

Calcule o custo líquido, o imposto bruto, o imposto líquido (após crédito tributário) e a base de cálculo para um serviço com preço bruto de R$ 2.000,00, desconto condicional de R$ 100,00, alíquota do IBS de 12% e crédito tributário de R$ 250,00. Compare o resultado com a aplicação incorreta de alíquota sobre o preço bruto sem desconto e explique o impacto da apropriação correta do crédito tributário.

---