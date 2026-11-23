## Cálculo do IBS: Passo a Passo Básico

Imagine que sua empresa precisa contratar um serviço de fornecimento, e a análise tributária envolve o Imposto sobre Bens e Serviços (IBS), um tributo unificado pós-reforma tributária que incide sobre operações envolvendo bens e serviços, substituindo e simplificando diversos tributos anteriores. Para tomar a decisão correta, não basta olhar o preço bruto do fornecedor, é preciso calcular o imposto devido, considerando base de cálculo ajustada, alíquota correta e créditos tributários.

Vamos detalhar um cálculo básico do IBS, isolado do ISS e CBS, para entender como aplicar essa lógica na prática, passo a passo.

---

### Passo 1: Determinar a Base de Cálculo Ajustada

A base de cálculo do IBS não é simplesmente o preço bruto. É necessário ajustar o valor para excluir descontos condicionais e impostos destacados, conforme as regras legais (ver 5.6). Isso evita pagar imposto sobre valores que não compõem efetivamente a receita tributável.

Considere:

- Preço bruto: R$ 2.000,00  
- Descontos condicionais: R$ 100,00

A base de cálculo será:

```python
preco_bruto = 2000.00
desconto_condicional = 100.00

base_calculo = preco_bruto - desconto_condicional
print(f"Base de cálculo ajustada: R$ {base_calculo:.2f}")
```

Saída:

```
Base de cálculo ajustada: R$ 1900.00
```

---

### Passo 2: Aplicar a Alíquota do IBS

A alíquota do IBS é definida pela legislação e varia conforme o setor e o tipo de operação (ver 5.8). Para este exemplo, usemos 12%.

O imposto devido antes de créditos é:

```python
aliquota_ibs = 0.12

imposto_bruto = base_calculo * aliquota_ibs
print(f"Imposto bruto (antes dos créditos): R$ {imposto_bruto:.2f}")
```

Saída:

```
Imposto bruto (antes dos créditos): R$ 228.00
```

---

### Passo 3: Subtrair o Crédito Tributário

O crédito tributário é um valor que a empresa pode abater do imposto devido, reduzindo o custo líquido (ver 5.13). Suponha que o crédito disponível seja R$ 250,00.

Agora, aplique o crédito ao imposto bruto:

```python
credito_tributario = 250.00

imposto_liquido = imposto_bruto - credito_tributario
# Limite mínimo zero para imposto devido:
imposto_liquido = max(imposto_liquido, 0.00)
print(f"Imposto líquido devido (após crédito): R$ {imposto_liquido:.2f}")
```

Saída:

```
Imposto líquido devido (após crédito): R$ 0.00
```

Note que o imposto não pode ser negativo, mesmo que o crédito seja maior que o imposto bruto, garantindo que não haja restituição via crédito nesse cálculo.

---

### Passo 4: Calcular o Custo Líquido do Serviço

O custo líquido é o que a empresa pagará efetivamente, considerando o preço bruto, os descontos e o impacto tributário do IBS.

```python
custo_liquido = preco_bruto - desconto_condicional + imposto_liquido
print(f"Custo líquido do serviço: R$ {custo_liquido:.2f}")
```

Saída:

```
Custo líquido do serviço: R$ 1900.00
```

Explicação: Apesar do preço bruto ser R$ 2.000,00, o desconto condicional reduz a base de cálculo, o crédito tributário elimina o imposto devido, e o custo líquido final é R$ 1.900,00.

---

### Passo 5: Erro Comum — Aplicar Alíquota Diretamente sobre o Preço Bruto

Um erro frequente é aplicar a alíquota do IBS diretamente sobre o preço bruto, sem descontar os descontos condicionais. Isso gera cálculo incorreto do imposto e pode levar a pagar tributos indevidos.

Veja o erro:

```python
imposto_errado = preco_bruto * aliquota_ibs
print(f"Imposto errado (aplicado sobre preço bruto): R$ {imposto_errado:.2f}")
```

Saída:

```
Imposto errado (aplicado sobre preço bruto): R$ 240.00
```

Comparando com o imposto correto de R$ 228,00, este erro causa o pagamento de R$ 12,00 a mais.

---

### Código Completo do Exemplo

```python
# Dados do exemplo
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_ibs = 0.12
credito_tributario = 250.00

# Cálculo da base de cálculo ajustada
base_calculo = preco_bruto - desconto_condicional

# Cálculo do imposto bruto
imposto_bruto = base_calculo * aliquota_ibs

# Aplicação do crédito tributário e limite mínimo zero
imposto_liquido = imposto_bruto - credito_tributario
imposto_liquido = max(imposto_liquido, 0.00)

# Cálculo do custo líquido
custo_liquido = preco_bruto - desconto_condicional + imposto_liquido

# Saídas detalhadas
print(f"Preço bruto: R$ {preco_bruto:.2f}")
print(f"Desconto condicional: R$ {desconto_condicional:.2f}")
print(f"Base de cálculo ajustada: R$ {base_calculo:.2f}")
print(f"Alíquota do IBS: {aliquota_ibs*100:.1f}%")
print(f"Imposto bruto: R$ {imposto_bruto:.2f}")
print(f"Crédito tributário: R$ {credito_tributario:.2f}")
print(f"Imposto líquido devido: R$ {imposto_liquido:.2f}")
print(f"Custo líquido do serviço: R$ {custo_liquido:.2f}")
```

Saída completa:

```
Preço bruto: R$ 2000.00
Desconto condicional: R$ 100.00
Base de cálculo ajustada: R$ 1900.00
Alíquota do IBS: 12.0%
Imposto bruto: R$ 228.00
Crédito tributário: R$ 250.00
Imposto líquido devido: R$ 0.00
Custo líquido do serviço: R$ 1900.00
```

---

### Exercício Proposto

Calcular o custo líquido e o imposto devido para um serviço com preço bruto R$ 2.000,00, desconto condicional R$ 100,00, alíquota do IBS de 12% e crédito tributário de R$ 250,00.

---