## Cálculo do ISS: Passo a Passo Básico

Ao calcular o Imposto Sobre Serviços (ISS), a principal dificuldade para iniciantes é entender como aplicar corretamente a base de cálculo, a alíquota e, posteriormente, os créditos tributários para obter o imposto devido e o custo líquido final. O ISS, como visto em 3.1 e 5.1, incide sobre o valor do serviço prestado, mas não necessariamente sobre o preço bruto apresentado na nota fiscal. A correta definição da base de cálculo evita erros comuns que resultam em pagamento indevido ou interpretação equivocada do custo tributário.

### Passo 1: Determinar a Base de Cálculo Correta

A base de cálculo do ISS é o valor do serviço ajustado, o qual deve excluir descontos condicionais concedidos e impostos destacados que não compõem o valor tributável. Por exemplo, se o preço bruto do serviço é R$ 1.500,00, com um desconto condicional de R$ 100,00 e impostos destacados, esses valores não entram na base para o cálculo do ISS.

Erro comum: aplicar a alíquota diretamente sobre o preço bruto sem excluir descontos ou impostos destacados.

Exemplo prático errado:

```python
preco_bruto = 1500.00
aliquota_iss = 0.05  # 5%

imposto_errado = preco_bruto * aliquota_iss
print(f"Imposto (cálculo errado): R$ {imposto_errado:.2f}")
```

Saída incorreta:

```
Imposto (cálculo errado): R$ 75.00
```

Neste caso, pode-se pagar imposto a mais, pois o desconto condicionado não foi excluído.

Correção aplicando desconto condicional:

```python
preco_bruto = 1500.00
desconto_condicional = 100.00
aliquota_iss = 0.05  # 5%

base_calculo = preco_bruto - desconto_condicional
imposto_correto = base_calculo * aliquota_iss
print(f"Base de cálculo: R$ {base_calculo:.2f}")
print(f"Imposto devido: R$ {imposto_correto:.2f}")
```

Saída correta:

```
Base de cálculo: R$ 1400.00
Imposto devido: R$ 70.00
```

### Passo 2: Aplicar a Alíquota Correspondente

A alíquota do ISS varia conforme a legislação municipal e o serviço prestado, geralmente entre 2% e 5%, conforme visto em 5.8. Após definir a base de cálculo ajustada, aplica-se a alíquota para obter o imposto devido bruto.

### Passo 3: Considerar Créditos Tributários

Apesar do ISS ser um imposto municipal, a reforma tributária e a correta vinculação dos códigos CNAE, LC116 e NBS permitem identificar créditos tributários que podem ser apropriados, reduzindo o valor líquido do imposto a pagar, como discutido em 5.12.

O crédito tributário é um valor que reduz o imposto devido; porém, o imposto não pode ser negativo. Se o crédito for maior que o imposto bruto, o imposto devido será zero.

Exemplo:

```python
credito_tributario = 20.00

imposto_liquido = imposto_correto - credito_tributario
if imposto_liquido < 0:
    imposto_liquido = 0.00

print(f"Imposto líquido após crédito: R$ {imposto_liquido:.2f}")
```

Saída:

```
Imposto líquido após crédito: R$ 50.00
```

### Passo 4: Calcular o Custo Líquido do Serviço

O custo líquido é o preço bruto do serviço menos os descontos condicionais, acrescido do imposto líquido devido. É este valor que representa o custo real para a empresa.

```python
custo_liquido = (preco_bruto - desconto_condicional) + imposto_liquido
print(f"Custo líquido do serviço: R$ {custo_liquido:.2f}")
```

Saída:

```
Custo líquido do serviço: R$ 1450.00
```

### Código Completo e Executável

Vamos consolidar tudo em um único exemplo para um serviço com preço bruto de R$ 1.500,00, desconto condicional de R$ 100,00, alíquota de ISS de 5% e crédito tributário de R$ 20,00:

```python
# Dados iniciais
preco_bruto = 1500.00
desconto_condicional = 100.00
aliquota_iss = 0.05  # 5%
credito_tributario = 20.00

# Passo 1: Base de cálculo ajustada
base_calculo = preco_bruto - desconto_condicional

# Passo 2: Imposto devido bruto
imposto_bruto = base_calculo * aliquota_iss

# Passo 3: Aplicar crédito tributário
imposto_liquido = imposto_bruto - credito_tributario
if imposto_liquido < 0:
    imposto_liquido = 0.00

# Passo 4: Custo líquido do serviço
custo_liquido = base_calculo + imposto_liquido

# Resultados
print(f"Preço bruto: R$ {preco_bruto:.2f}")
print(f"Desconto condicional: R$ {desconto_condicional:.2f}")
print(f"Base de cálculo para ISS: R$ {base_calculo:.2f}")
print(f"Imposto bruto (ISS): R$ {imposto_bruto:.2f}")
print(f"Crédito tributário aplicado: R$ {credito_tributario:.2f}")
print(f"Imposto líquido devido: R$ {imposto_liquido:.2f}")
print(f"Custo líquido do serviço: R$ {custo_liquido:.2f}")
```

Saída:

```
Preço bruto: R$ 1500.00
Desconto condicional: R$ 100.00
Base de cálculo para ISS: R$ 1400.00
Imposto bruto (ISS): R$ 70.00
Crédito tributário aplicado: R$ 20.00
Imposto líquido devido: R$ 50.00
Custo líquido do serviço: R$ 1450.00
```

### Erro Comum: Imposto Negativo

Se o crédito tributário for maior que o imposto bruto, o cálculo incorreto pode resultar em imposto negativo. Por exemplo:

```python
imposto_bruto = 15.00
credito_tributario = 20.00

imposto_liquido = imposto_bruto - credito_tributario
print(f"Imposto líquido (errado): R$ {imposto_liquido:.2f}")
```

Saída errada:

```
Imposto líquido (errado): R$ -5.00
```

Esse valor negativo não é aceito pela legislação. O correto é limitar o imposto a zero:

```python
if imposto_liquido < 0:
    imposto_liquido = 0.00
print(f"Imposto líquido (corrigido): R$ {imposto_liquido:.2f}")
```

Saída correta:

```
Imposto líquido (corrigido): R$ 0.00
```

---

## Exercício Prático

Calcule o custo líquido e o imposto devido para um serviço com preço bruto de R$ 2.000,00, descontos condicionais de R$ 100,00, alíquota do ISS de 5% e crédito tributário de R$ 250,00.

---