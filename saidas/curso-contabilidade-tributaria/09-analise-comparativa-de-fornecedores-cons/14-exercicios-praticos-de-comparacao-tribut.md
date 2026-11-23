## Exercícios Práticos de Comparação Tributária Entre Fornecedores

Para que você possa aplicar com segurança a análise tributária na comparação entre fornecedores, apresentamos exercícios completos que simulam situações reais, envolvendo preços brutos, créditos tributários e a correta vinculação dos códigos CNAE, LC116 e NBS. O objetivo é que você desenvolva a habilidade de calcular o custo líquido tributário e decida qual fornecedor oferece a melhor oportunidade econômica.

---

### Exercício 1: Comparação Simples com Créditos Tributários

Considere dois fornecedores que oferecem o mesmo serviço, mas com diferentes preços e créditos tributários gerados.

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) | CNAE         | Código LC116 | Código NBS  |
|------------|------------------|------------------------|--------------|--------------|-------------|
| A          | 100,00           | 15,00                  | 62.02-3-00   | 01.01        | 1.01.01     |
| B          | 95,00            | 5,00                   | 62.02-3-00   | 01.01        | 1.01.01     |

**Passos para resolver:**

1. Confirme que o CNAE do fornecedor está vinculado corretamente ao código LC116.
2. Valide que o código LC116 corresponde ao código NBS para o serviço contratado.
3. Calcule o custo líquido tributário para cada fornecedor usando a fórmula:

   \[
   \text{Custo Líquido} = \text{Preço Bruto} - \text{Crédito Tributário}
   \]

4. Compare os custos líquidos e determine o fornecedor mais vantajoso.

**Cálculo:**

```python
fornecedores = {
    "A": {"preco": 100.00, "credito": 15.00},
    "B": {"preco": 95.00, "credito": 5.00}
}

for fornecedor, dados in fornecedores.items():
    custo_liquido = dados["preco"] - dados["credito"]
    print(f"Fornecerdor {fornecedor}: Custo Líquido = R$ {custo_liquido:.2f}")
```

**Saída esperada:**

```
Fornecerdor A: Custo Líquido = R$ 85.00
Fornecerdor B: Custo Líquido = R$ 90.00
```

**Análise:**  
Apesar do preço bruto do fornecedor B ser menor, o custo líquido do fornecedor A é mais vantajoso devido ao maior crédito tributário aproveitado.

---

### Exercício 2: Impacto da Vinculação Incorreta de Código LC116

Imagine que o fornecedor C indica um código LC116 incorreto que não está vinculado ao seu CNAE real, impedindo a apropriação do crédito.

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) | CNAE         | Código LC116 (incorreto) | Código NBS  |
|------------|------------------|------------------------|--------------|--------------------------|-------------|
| C          | 98,00            | 12,00                  | 62.02-3-00   | 99.99 (incorreto)        | 1.01.01     |

**Erro comum:**  
Ao tentar validar a nota fiscal com o código LC116 incorreto, o sistema fiscal rejeita a apropriação do crédito, emitindo uma mensagem como:

```
Rejeição: Código LC116 incompatível com o CNAE do prestador - crédito não permitido.
```

**Solução:**  
Corrija o código LC116 para o correto (por exemplo, 01.01) que é compatível com o CNAE 62.02-3-00.

**Cálculo corrigido:**

```python
fornecedor_c = {"preco": 98.00, "credito": 0.00}  # crédito não aproveitado
custo_liquido_c = fornecedor_c["preco"] - fornecedor_c["credito"]
print(f"Fornecerdor C corrigido: Custo Líquido = R$ {custo_liquido_c:.2f}")
```

**Saída:**

```
Fornecerdor C corrigido: Custo Líquido = R$ 98.00
```

---

### Exercício 3: Comparação com IBS e CBS Incluídos

Considere os seguintes dados, onde além do ISS, o IBS e o CBS também são considerados. Para simplificação, o crédito informado já considera a soma dos créditos desses tributos.

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) | CNAE         | Código LC116 | Código NBS  |
|------------|------------------|------------------------|--------------|--------------|-------------|
| D          | 120,00           | 20,00                  | 47.11-3-00   | 02.02        | 2.05.01     |
| E          | 115,00           | 10,00                  | 47.11-3-00   | 02.02        | 2.05.01     |

**Cálculo do custo líquido considerando créditos:**

```python
fornecedores = {
    "D": {"preco": 120.00, "credito": 20.00},
    "E": {"preco": 115.00, "credito": 10.00}
}

for fornecedor, dados in fornecedores.items():
    custo_liquido = dados["preco"] - dados["credito"]
    print(f"Fornecerdor {fornecedor}: Custo Líquido = R$ {custo_liquido:.2f}")
```

**Saída:**

```
Fornecerdor D: Custo Líquido = R$ 100.00
Fornecerdor E: Custo Líquido = R$ 105.00
```

**Conclusão:**  
Mesmo com preço bruto maior, o fornecedor D é economicamente mais vantajoso devido ao maior crédito tributário.

---

### Exercício 4: Impacto da Atualização dos Códigos na Comparação

Imagine que houve atualização da tabela do CNAE e da LC116, alterando a vinculação de um fornecedor:

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) antes | Crédito Tributário (R$) depois da atualização | CNAE Antigo | CNAE Atualizado | Código LC116 | Código NBS  |
|------------|------------------|-------------------------------|-----------------------------------------------|-------------|-----------------|--------------|-------------|
| F          | 110,00           | 15,00                         | 10,00                                         | 62.03-1-00  | 62.03-1-10      | 01.05        | 1.02.02     |

**Situação:**  
Antes da atualização, o crédito de R$ 15,00 era aproveitado. Após a atualização, a nova vinculação reduz o crédito para R$ 10,00.

**Cálculo comparativo:**

```python
preco = 110.00
credito_antes = 15.00
credito_depois = 10.00

custo_antes = preco - credito_antes
custo_depois = preco - credito_depois

print(f"Custo líquido antes da atualização: R$ {custo_antes:.2f}")
print(f"Custo líquido depois da atualização: R$ {custo_depois:.2f}")
```

**Saída:**

```
Custo líquido antes da atualização: R$ 95.00
Custo líquido depois da atualização: R$ 100.00
```

**Análise:**  
A atualização das tabelas impactou diretamente o custo líquido tributário do fornecedor, podendo alterar a decisão de compra.

---

### Exercício 5: Comparação com Descontos Condicionais na Base de Cálculo

Suponha que o fornecedor G oferece um desconto condicional que afeta a base de cálculo do ISS, alterando o crédito tributário.

| Fornecedor | Preço Bruto (R$) | Desconto Condicional (R$) | Crédito Tributário (R$) | CNAE         | Código LC116 | Código NBS  |
|------------|------------------|---------------------------|------------------------|--------------|--------------|-------------|
| G          | 130,00           | 10,00                     | 18,00                  | 62.02-3-00   | 01.01        | 1.01.01     |

**Regra:**  
Descontos condicionais devem ser deduzidos da base de cálculo para o ISS, reduzindo o crédito tributário proporcionalmente.

**Cálculo simplificado:**

```python
preco_bruto = 130.00
desconto_condicional = 10.00
credito = 18.00

# Ajuste do crédito proporcional
base_ajustada = preco_bruto - desconto_condicional
credito_ajustado = credito * (base_ajustada / preco_bruto)

custo_liquido = preco_bruto - credito_ajustado

print(f"Crédito ajustado: R$ {credito_ajustado:.2f}")
print(f"Custo líquido com desconto condicional: R$ {custo_liquido:.2f}")
```

**Saída:**

```
Crédito ajustado: R$ 16.92
Custo líquido com desconto condicional: R$ 113.08
```

**Conclusão:**  
O desconto condicional reduz o crédito tributário e aumenta o custo líquido, o que deve ser considerado na comparação.

---

## Exercício Proposto

Dado dois fornecedores com preços, créditos tributários e códigos CNAE, LC116 e NBS distintos, calcule o custo líquido tributário de cada um considerando a correta vinculação dos códigos e eventuais descontos condicionais, e indique qual é economicamente mais vantajoso.

---