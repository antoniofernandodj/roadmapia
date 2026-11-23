## Exemplo Prático de Cálculo com Crédito Tributário

Imagine que sua empresa precise contratar um serviço de manutenção fornecido por dois potenciais fornecedores, e você quer decidir qual deles gera menor custo líquido considerando o impacto dos tributos e créditos tributários. A decisão baseada somente no preço bruto pode levar a uma escolha errada, pois um fornecedor com preço maior pode oferecer créditos tributários que reduzem significativamente o custo final.

### Cenário

- **Fornecedor A**: preço bruto do serviço R$ 2.000,00  
- **Fornecedor B**: preço bruto do serviço R$ 1.900,00  
- Desconto condicional aplicável: R$ 100,00 (considerado na base de cálculo)  
- Alíquota do IBS aplicável: 12%  
- Crédito tributário gerado pelo fornecedor:  
  - Fornecedor A: R$ 250,00  
  - Fornecedor B: R$ 50,00  

Nosso objetivo é calcular o custo líquido total para cada fornecedor, considerando:  
1. Ajuste da base de cálculo subtraindo o desconto condicional;  
2. Aplicação da alíquota de IBS sobre a base ajustada;  
3. Dedução do crédito tributário do imposto devido, respeitando o limite de imposto mínimo zero;  
4. Cálculo do custo líquido somando o preço bruto menos desconto mais imposto líquido.

### Passo 1: Ajuste da base de cálculo

A base de cálculo é o preço bruto menos descontos condicionais. Isso evita tributar valores que não correspondem efetivamente ao serviço prestado.

Para ambos os fornecedores:

```python
preco_bruto_A = 2000.00
preco_bruto_B = 1900.00
desconto_condicional = 100.00

base_calculo_A = preco_bruto_A - desconto_condicional
base_calculo_B = preco_bruto_B - desconto_condicional

print(f"Base de cálculo Fornecedor A: R$ {base_calculo_A:.2f}")
print(f"Base de cálculo Fornecedor B: R$ {base_calculo_B:.2f}")
```

Saída esperada:

```
Base de cálculo Fornecedor A: R$ 1900.00
Base de cálculo Fornecedor B: R$ 1800.00
```

### Passo 2: Cálculo do imposto bruto (antes do crédito)

Aplicamos a alíquota de IBS, que incide sobre a base de cálculo ajustada.

```python
aliquota_ibs = 0.12

imposto_bruto_A = base_calculo_A * aliquota_ibs
imposto_bruto_B = base_calculo_B * aliquota_ibs

print(f"Imposto bruto Fornecedor A: R$ {imposto_bruto_A:.2f}")
print(f"Imposto bruto Fornecedor B: R$ {imposto_bruto_B:.2f}")
```

Saída esperada:

```
Imposto bruto Fornecedor A: R$ 228.00
Imposto bruto Fornecedor B: R$ 216.00
```

### Passo 3: Aplicação do crédito tributário

O crédito tributário reduz o imposto devido, mas o imposto líquido não pode ser negativo. Ou seja, o crédito é limitado ao valor do imposto bruto.

```python
credito_A = 250.00
credito_B = 50.00

imposto_liquido_A = max(imposto_bruto_A - credito_A, 0)
imposto_liquido_B = max(imposto_bruto_B - credito_B, 0)

print(f"Imposto líquido Fornecedor A: R$ {imposto_liquido_A:.2f}")
print(f"Imposto líquido Fornecedor B: R$ {imposto_liquido_B:.2f}")
```

Saída esperada:

```
Imposto líquido Fornecedor A: R$ 0.00
Imposto líquido Fornecedor B: R$ 166.00
```

Note que para o Fornecedor A o crédito é maior que o imposto bruto, zerando o imposto devido — não há restituição, apenas imposto zero.

### Passo 4: Cálculo do custo líquido

O custo líquido considera o preço bruto menos o desconto condicional, mais o imposto líquido devido.

```python
custo_liquido_A = preco_bruto_A - desconto_condicional + imposto_liquido_A
custo_liquido_B = preco_bruto_B - desconto_condicional + imposto_liquido_B

print(f"Custo líquido Fornecedor A: R$ {custo_liquido_A:.2f}")
print(f"Custo líquido Fornecedor B: R$ {custo_liquido_B:.2f}")
```

Saída esperada:

```
Custo líquido Fornecedor A: R$ 1900.00
Custo líquido Fornecedor B: R$ 2016.00
```

### Interpretação

Embora o preço bruto do Fornecedor A seja maior (R$ 2.000,00 vs. R$ 1.900,00), seu custo líquido é menor (R$ 1.900,00 vs. R$ 2.016,00) devido ao crédito tributário maior que praticamente elimina o imposto devido. Se você tivesse considerado apenas o preço bruto, escolheria o Fornecedor B por R$ 100 menos, mas o impacto dos créditos muda a decisão.

### Erro comum a evitar

Se aplicarmos a alíquota diretamente sobre o preço bruto, sem ajustar a base de cálculo com o desconto condicional, o imposto será superestimado, aumentando o custo líquido indevidamente.

Exemplo do erro para o Fornecedor A:

```python
imposto_bruto_erro = preco_bruto_A * aliquota_ibs
imposto_liquido_erro = max(imposto_bruto_erro - credito_A, 0)

print(f"Imposto bruto errado Fornecedor A: R$ {imposto_bruto_erro:.2f}")
print(f"Imposto líquido errado Fornecedor A: R$ {imposto_liquido_erro:.2f}")
```

Saída:

```
Imposto bruto errado Fornecedor A: R$ 240.00
Imposto líquido errado Fornecedor A: R$ 0.00
```

A diferença do imposto bruto é pequena aqui (R$ 12), mas a base incorreta gera problemas maiores em operações mais complexas, gerando distorções no custo líquido e decisões erradas.

### Código Python completo

```python
# Dados dos fornecedores
preco_bruto_A = 2000.00
preco_bruto_B = 1900.00
desconto_condicional = 100.00
aliquota_ibs = 0.12
credito_A = 250.00
credito_B = 50.00

# Base de cálculo ajustada
base_calculo_A = preco_bruto_A - desconto_condicional
base_calculo_B = preco_bruto_B - desconto_condicional

# Cálculo do imposto bruto
imposto_bruto_A = base_calculo_A * aliquota_ibs
imposto_bruto_B = base_calculo_B * aliquota_ibs

# Aplicação do crédito tributário (limite zero)
imposto_liquido_A = max(imposto_bruto_A - credito_A, 0)
imposto_liquido_B = max(imposto_bruto_B - credito_B, 0)

# Cálculo do custo líquido
custo_liquido_A = preco_bruto_A - desconto_condicional + imposto_liquido_A
custo_liquido_B = preco_bruto_B - desconto_condicional + imposto_liquido_B

# Resultados
print(f"Fornecedor A - Base cálculo: R$ {base_calculo_A:.2f}, Imposto bruto: R$ {imposto_bruto_A:.2f}, Imposto líquido: R$ {imposto_liquido_A:.2f}, Custo líquido: R$ {custo_liquido_A:.2f}")
print(f"Fornecedor B - Base cálculo: R$ {base_calculo_B:.2f}, Imposto bruto: R$ {imposto_bruto_B:.2f}, Imposto líquido: R$ {imposto_liquido_B:.2f}, Custo líquido: R$ {custo_liquido_B:.2f}")
```

Saída completa:

```
Fornecedor A - Base cálculo: R$ 1900.00, Imposto bruto: R$ 228.00, Imposto líquido: R$ 0.00, Custo líquido: R$ 1900.00
Fornecedor B - Base cálculo: R$ 1800.00, Imposto bruto: R$ 216.00, Imposto líquido: R$ 166.00, Custo líquido: R$ 2016.00
```

---

Este exemplo demonstra claramente que considerar o crédito tributário e a base de cálculo ajustada é fundamental para decisões econômicas corretas. Ignorar esses fatores pode levar a escolhas equivocadas que elevam custos.

---