## Regras Simples para Comparação Tributária Entre Fornecedores

Ao escolher um fornecedor, é comum focar apenas no preço bruto ofertado. No entanto, esse valor não reflete o custo real da operação quando se considera o impacto tributário e a possibilidade de apropriação de créditos fiscais. A comparação tributária entre fornecedores, portanto, deve sempre levar em conta tanto o preço nominal quanto os créditos tributários que cada fornecedor gera e que a empresa pode aproveitar.

### Por que o preço bruto não é suficiente?

Imagine dois fornecedores:

- **Fornecedor A** cobra R$ 1.000,00 e gera R$ 150,00 em créditos tributários aproveitáveis;  
- **Fornecedor B** cobra R$ 950,00 e não gera créditos tributários.

Na análise superficial, o Fornecedor B parece mais barato. Porém, ao descontar os créditos aproveitáveis do Fornecedor A, o custo líquido dele se torna:

```
Custo líquido = Preço bruto - Crédito tributário
Custo líquido A = 1.000,00 - 150,00 = 850,00
```

O Fornecedor A, portanto, oferece melhor custo líquido, ainda que o preço bruto seja maior.

### Mecanismo simples para comparação tributária

O método básico para comparar fornecedores considerando tributos e créditos é:

1. **Identificar o CNAE do fornecedor** para conhecer sua atividade econômica;  
2. **Vincular o CNAE ao código de serviço LC116**, que indica o serviço tributável e sua incidência de ISS;  
3. **Vincular o código LC116 ao código NBS**, que detalha o serviço para fins de cálculo e classificação tributária;  
4. **Calcular o tributo devido (ISS, IBS ou CBS) considerando a base de cálculo e alíquota correta;**  
5. **Aplicar o crédito tributário correspondente, limitado ao imposto devido;**  
6. **Determinar o custo líquido subtraindo o crédito do preço bruto;**  
7. **Comparar os custos líquidos entre fornecedores para escolher a melhor opção.**

Este processo evita o erro comum de comparar apenas preços brutos e ignora os créditos fiscais.

### Exemplo prático simplificado

Suponha dois fornecedores com os seguintes dados:

| Fornecedor | Preço Bruto (R$) | CNAE         | Código LC116 | Código NBS | Alíquota IBS | Crédito Tributário (R$) |
|------------|------------------|--------------|--------------|------------|--------------|-------------------------|
| A          | 2.000,00         | 62.01-5-01   | 1234         | 5678       | 12%          | 250,00                  |
| B          | 1.950,00         | 62.02-3-02   | 1235         | 5679       | 12%          | 100,00                  |

**Passo 1:** Ajustar a base de cálculo subtraindo descontos condicionais (não fornecido aqui, vamos assumir zero para simplificação).  
**Passo 2:** Calcular o imposto bruto:  
\[
\text{Imposto bruto} = \text{Preço bruto} \times \text{Alíquota}
\]

- Fornecedor A: 2.000,00 × 12% = 240,00  
- Fornecedor B: 1.950,00 × 12% = 234,00  

**Passo 3:** Aplicar crédito tributário, limitado ao imposto devido (imposto líquido não pode ser negativo):  
\[
\text{Imposto líquido} = \max(0, \text{Imposto bruto} - \text{Crédito tributário})
\]

- Fornecedor A: max(0, 240,00 - 250,00) = 0,00  
- Fornecedor B: max(0, 234,00 - 100,00) = 134,00  

**Passo 4:** Calcular custo líquido:  
\[
\text{Custo líquido} = \text{Preço bruto} + \text{Imposto líquido} - \text{Crédito tributário}
\]

Ou, mais direto:  
\[
\text{Custo líquido} = \text{Preço bruto} + \text{Imposto líquido}
\]

Porque o crédito já está descontado no imposto. Como o imposto líquido do Fornecedor A é zero, o custo líquido é igual ao preço bruto:

- Fornecedor A: 2.000,00 + 0,00 = 2.000,00  
- Fornecedor B: 1.950,00 + 134,00 = 2.084,00  

**Resultado:** O Fornecedor A, apesar de preço bruto maior, apresenta menor custo líquido tributário devido ao crédito maior, sendo a melhor escolha.

### Código Python completo para cálculo simples

```python
def calcular_custo_liquido(preco_bruto, aliquota, credito_tributario):
    imposto_bruto = preco_bruto * aliquota
    imposto_liquido = max(0, imposto_bruto - credito_tributario)
    custo_liquido = preco_bruto + imposto_liquido
    return {
        'imposto_bruto': imposto_bruto,
        'imposto_liquido': imposto_liquido,
        'custo_liquido': custo_liquido
    }

# Dados dos fornecedores
fornecedores = {
    'Fornecedor A': {'preco': 2000.00, 'aliquota': 0.12, 'credito': 250.00},
    'Fornecedor B': {'preco': 1950.00, 'aliquota': 0.12, 'credito': 100.00}
}

for nome, dados in fornecedores.items():
    resultado = calcular_custo_liquido(dados['preco'], dados['aliquota'], dados['credito'])
    print(f"{nome}:")
    print(f"  Imposto Bruto: R$ {resultado['imposto_bruto']:.2f}")
    print(f"  Imposto Líquido: R$ {resultado['imposto_liquido']:.2f}")
    print(f"  Custo Líquido: R$ {resultado['custo_liquido']:.2f}")
    print()
```

Saída do código:

```
Fornecedor A:
  Imposto Bruto: R$ 240.00
  Imposto Líquido: R$ 0.00
  Custo Líquido: R$ 2000.00

Fornecedor B:
  Imposto Bruto: R$ 234.00
  Imposto Líquido: R$ 134.00
  Custo Líquido: R$ 2084.00
```

### Erros comuns na comparação tributária

- **Comparar apenas preço bruto:** Ignorar créditos tributários pode levar a decisões erradas e custos maiores no longo prazo.  
- **Aplicar alíquota sobre preço bruto sem ajustar a base:** Pode resultar em imposto indevido e custo distorcido.  
- **Desconsiderar limites na apropriação do crédito:** O crédito não pode ultrapassar o imposto devido; excedente não gera restituição.  
- **Ignorar a vinculação correta entre CNAE, LC116 e NBS:** Isso pode invalidar a apropriação do crédito e gerar autuações fiscais.  

### Aplicação prática do CNAE x LC116 x NBS na comparação

A precisão na comparação tributária depende da correta vinculação dos códigos:

- **CNAE do fornecedor** define a atividade econômica, fundamental para identificar o regime tributário e os tributos incidentes.  
- **Código LC116** vinculado ao CNAE indica o serviço tributável pelo ISS e suas regras específicas, incluindo alíquota.  
- **Código NBS** detalha o serviço para classificação e aplicação correta da legislação, influenciando a base de cálculo e créditos.  

Essa integração permite que sistemas fiscais calculem automaticamente os tributos e apropriem créditos, evitando erros manuais e facilitando a comparação real entre fornecedores.

### Regra prática para aplicação no sistema

1. Receba o CNAE do fornecedor;  
2. Consulte tabela vinculativa CNAE → LC116;  
3. Consulte tabela vinculativa LC116 → NBS;  
4. Consulte alíquota e condições do tributo (ISS, IBS ou CBS) segundo o código NBS;  
5. Calcule imposto bruto considerando base ajustada (descontos condicionais excluídos);  
6. Aplique crédito tributário, limitado ao imposto devido;  
7. Calcule custo líquido e armazene para comparação;  
8. Compare custo líquido entre fornecedores e selecione o menor.  

### Exemplo numérico para comparação rápida

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) | Custo Líquido (R$) |
|------------|------------------|------------------------|--------------------|
| A          | 100,00           | 15,00                  | 85,00              |
| B          | 95,00            | 0,00                   | 95,00              |

Mesmo com preço bruto maior, o Fornecedor A é mais vantajoso.

---

## Exercício proposto

Dado dois fornecedores com preços brutos, alíquotas e créditos tributários diferentes, calcule o custo líquido para cada um seguindo os passos do cálculo básico, e determine qual fornecedor oferece a melhor opção tributária para contratação.

---