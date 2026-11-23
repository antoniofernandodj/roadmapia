## Exemplos Práticos de Aplicação dos Tributos em Comércio e Serviços

A escolha de fornecedores no comércio e serviços, após a reforma tributária, não pode se basear apenas no preço bruto apresentado. A correta aplicação dos tributos ISS, IBS e CBS, com seus respectivos créditos tributários, impacta diretamente no custo líquido real da operação. A seguir, apresentaremos exemplos práticos que ilustram essa dinâmica, mostrando como a integração dos códigos CNAE, LC116 e NBS permite calcular o custo tributário líquido e identificar a melhor opção de fornecedor.

### 1. Exemplo Prático de Aplicação do ISS em Serviços

Considere três fornecedores de serviços de consultoria com valores distintos, cada um com seu CNAE, código LC116 e código NBS corretamente vinculados para incidir ISS. A alíquota municipal do ISS é 3%, e cada fornecedor possui um crédito tributário diferente, resultante da apropriação de créditos conforme a legislação vigente.

| Fornecedor | Valor do Serviço (R$) | Crédito Tributário ISS (R$) | CNAE           | Código LC116 | Código NBS  |
|------------|-----------------------|-----------------------------|----------------|--------------|-------------|
| A          | 1.000,00              | 50,00                       | 70.22-4-00     | 102          | 62001000    |
| B          | 950,00                | 30,00                       | 70.22-4-00     | 102          | 62001000    |
| C          | 1.050,00              | 60,00                       | 70.22-4-00     | 102          | 62001000    |

**Cálculo do ISS devido e custo líquido:**

\[
ISS_{bruto} = Valor \times Alíquota
\]
\[
ISS_{líquido} = \max(0, ISS_{bruto} - Crédito)
\]
\[
Custo Líquido = Valor + ISS_{líquido} - Crédito
\]

Implementando em Python para automatizar o cálculo:

```python
fornecedores = [
    {"nome": "A", "valor": 1000.00, "credito": 50.00},
    {"nome": "B", "valor": 950.00, "credito": 30.00},
    {"nome": "C", "valor": 1050.00, "credito": 60.00},
]

aliquota_iss = 0.03

for fornecedor in fornecedores:
    iss_bruto = fornecedor["valor"] * aliquota_iss
    iss_liquido = max(0, iss_bruto - fornecedor["credito"])
    custo_liquido = fornecedor["valor"] + iss_liquido - fornecedor["credito"]
    print(f"Fornecedor {fornecedor['nome']}: ISS bruto = R$ {iss_bruto:.2f}, ISS líquido = R$ {iss_liquido:.2f}, Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:

```
Fornecedor A: ISS bruto = R$ 30.00, ISS líquido = R$ 0.00, Custo líquido = R$ 950.00
Fornecedor B: ISS bruto = R$ 28.50, ISS líquido = R$ 0.00, Custo líquido = R$ 920.00
Fornecedor C: ISS bruto = R$ 31.50, ISS líquido = R$ 0.00, Custo líquido = R$ 990.00
```

Apesar do Fornecedor C ter o maior valor, seu crédito tributário elevado zera o ISS devido, reduzindo o custo líquido. O fornecedor B tem o menor custo líquido, mesmo com crédito menor, por seu preço bruto mais baixo.

### 2. Exemplo Prático de Aplicação do IBS em Comércio de Mercadorias

Para o IBS, que unifica tributos estaduais sobre bens e serviços, considere três fornecedores de mercadorias com valores diferentes. A alíquota estadual do IBS é 10%, e cada operação pode gerar crédito tributário conforme a legislação estadual.

| Fornecedor | Valor da Mercadoria (R$) | Crédito Tributário IBS (R$) | CNAE           | Código NCM   |
|------------|--------------------------|-----------------------------|----------------|--------------|
| X          | 5.000,00                 | 300,00                      | 47.11-3-00     | 84713012     |
| Y          | 4.800,00                 | 100,00                      | 47.11-3-00     | 84713012     |
| Z          | 5.200,00                 | 600,00                      | 47.11-3-00     | 84713012     |

**Cálculo do IBS devido e custo líquido:**

\[
IBS_{bruto} = Valor \times Alíquota
\]
\[
IBS_{líquido} = \max(0, IBS_{bruto} - Crédito)
\]
\[
Custo Líquido = Valor + IBS_{líquido} - Crédito
\]

Código Python para o cálculo:

```python
fornecedores_ibs = [
    {"nome": "X", "valor": 5000.00, "credito": 300.00},
    {"nome": "Y", "valor": 4800.00, "credito": 100.00},
    {"nome": "Z", "valor": 5200.00, "credito": 600.00},
]

aliquota_ibs = 0.10

for fornecedor in fornecedores_ibs:
    ibs_bruto = fornecedor["valor"] * aliquota_ibs
    ibs_liquido = max(0, ibs_bruto - fornecedor["credito"])
    custo_liquido = fornecedor["valor"] + ibs_liquido - fornecedor["credito"]
    print(f"Fornecedor {fornecedor['nome']}: IBS bruto = R$ {ibs_bruto:.2f}, IBS líquido = R$ {ibs_liquido:.2f}, Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:

```
Fornecedor X: IBS bruto = R$ 500.00, IBS líquido = R$ 200.00, Custo líquido = R$ 4900.00
Fornecedor Y: IBS bruto = R$ 480.00, IBS líquido = R$ 380.00, Custo líquido = R$ 5080.00
Fornecedor Z: IBS bruto = R$ 520.00, IBS líquido = R$ 0.00, Custo líquido = R$ 4600.00
```

Aqui, o Fornecedor Z, apesar do preço bruto mais alto, apresenta o menor custo líquido graças a um crédito tributário maior que zera o IBS devido.

### 3. Exemplo Prático de Aplicação do CBS em Serviços e Mercadorias

O CBS é um tributo federal, fixo em 12%, que incide sobre a receita bruta, com créditos acumuláveis para reduzir o imposto devido.

Considere três fornecedores com valores e créditos diferentes:

| Fornecedor | Receita Bruta (R$) | Crédito Tributário CBS (R$) | CNAE           | Código LC116 / NBS / NCM  |
|------------|--------------------|-----------------------------|----------------|---------------------------|
| M          | 2.000,00           | 150,00                      | 74.90-1-99     | 62005000 / 85171200       |
| N          | 1.800,00           | 100,00                      | 74.90-1-99     | 62005000 / 85171200       |
| O          | 2.200,00           | 300,00                      | 74.90-1-99     | 62005000 / 85171200       |

**Cálculo do CBS devido e custo líquido:**

\[
CBS_{bruto} = Receita \times 0.12
\]
\[
CBS_{líquido} = \max(0, CBS_{bruto} - Crédito)
\]
\[
Custo Líquido = Receita + CBS_{líquido} - Crédito
\]

Código Python para cálculo:

```python
fornecedores_cbs = [
    {"nome": "M", "receita": 2000.00, "credito": 150.00},
    {"nome": "N", "receita": 1800.00, "credito": 100.00},
    {"nome": "O", "receita": 2200.00, "credito": 300.00},
]

aliquota_cbs = 0.12

for fornecedor in fornecedores_cbs:
    cbs_bruto = fornecedor["receita"] * aliquota_cbs
    cbs_liquido = max(0, cbs_bruto - fornecedor["credito"])
    custo_liquido = fornecedor["receita"] + cbs_liquido - fornecedor["credito"]
    print(f"Fornecedor {fornecedor['nome']}: CBS bruto = R$ {cbs_bruto:.2f}, CBS líquido = R$ {cbs_liquido:.2f}, Custo líquido = R$ {custo_liquido:.2f}")
```

Saída:

```
Fornecedor M: CBS bruto = R$ 240.00, CBS líquido = R$ 90.00, Custo líquido = R$ 1940.00
Fornecedor N: CBS bruto = R$ 216.00, CBS líquido = R$ 116.00, Custo líquido = R$ 1816.00
Fornecedor O: CBS bruto = R$ 264.00, CBS líquido = R$ 0.00, Custo líquido = R$ 1900.00
```

O fornecedor N tem o menor custo líquido, apesar de um crédito menor que M, devido ao menor valor da receita bruta.

### 4. Evitando Erros Comuns na Aplicação Prática

Um erro comum na aplicação prática desses cálculos é não limitar o imposto devido a zero quando o crédito é maior que o imposto bruto, o que pode resultar em valores negativos de imposto devido, distorcendo o custo líquido.

Por exemplo, se no cálculo do ISS:

```python
iss_liquido = iss_bruto - credito  # erro se iss_bruto < credito
```

pode gerar valor negativo. A correção é usar:

```python
iss_liquido = max(0, iss_bruto - credito)
```

Esse cuidado deve ser aplicado também para IBS e CBS para garantir a consistência dos cálculos.

Outro erro é não vincular corretamente o CNAE ao código LC116 e ao código NBS no caso do ISS, ou ao NCM no caso do IBS e CBS, o que pode gerar cálculos errados ou impossibilidade de apropriação dos créditos tributários.

### 5. Integração dos Códigos para Análise Prática

A integração dos códigos CNAE x LC116 x NBS (para ISS) e CNAE x NCM (para IBS e CBS) é fundamental para garantir que o sistema tributário reconheça corretamente a natureza do serviço ou mercadoria, aplique a alíquota correta e permita o uso adequado dos créditos tributários.

No exemplo prático, o sistema deve:

- Receber o CNAE do fornecedor.
- Consultar a tabela de vinculação para obter o código LC116 correspondente.
- Para serviços, usar LC116 para buscar o código NBS e determinar o ISS.
- Para mercadorias, identificar o NCM para cálculo do IBS e CBS.
- Aplicar as alíquotas vigentes e calcular os tributos brutos.
- Aplicar os créditos tributários conforme as regras.
- Limitar o imposto devido a zero, evitando valores negativos.
- Calcular o custo líquido para comparação e escolha do fornecedor.

### 6. Conclusão dos Exemplos Práticos

Esses exemplos mostram que o fornecedor com menor preço bruto nem sempre oferece a melhor condição financeira após considerar os créditos tributários. A aplicação correta dos tributos ISS, IBS e CBS, com a vinculação correta dos códigos CNAE, LC116, NBS e NCM, permite calcular o custo líquido real e tomar decisões mais eficientes.

---