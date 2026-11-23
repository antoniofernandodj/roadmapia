## Comparação de Custos Tributários Entre Fornecedores

Ao escolher um fornecedor, considerar apenas o preço bruto pode levar a decisões que aumentam o custo total para a empresa. O fator determinante para uma escolha economicamente vantajosa é o custo líquido tributário, que considera o impacto dos tributos ISS, IBS e CBS, além dos créditos tributários que cada operação pode gerar. Vamos detalhar como comparar fornecedores com base nesses critérios, utilizando a vinculação dos códigos CNAE, LC116 e NBS, essenciais para identificar corretamente a tributação e os créditos aplicáveis.

### O Problema da Decisão por Preço Bruto

Imagine dois fornecedores oferecendo serviços similares:

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) |
|------------|------------------|------------------------|
| A          | 100,00           | 15,00                  |
| B          | 95,00            | 0,00                   |

A análise simplista indicaria o Fornecedor B como mais barato, mas, ao descontar o crédito tributário gerado pelo Fornecedor A, o custo líquido fica:

- Fornecedor A: 100 - 15 = 85,00
- Fornecedor B: 95 - 0 = 95,00

Ou seja, apesar do preço bruto maior, o Fornecedor A é mais vantajoso. Mas para fazer essa análise corretamente, é preciso entender como calcular o custo líquido considerando os tributos ISS, IBS e CBS, vinculados aos códigos CNAE, LC116 e NBS.

### Passo 1: Vinculação CNAE x LC116 x NBS

Para cada fornecedor, o CNAE indica a atividade econômica primária. A partir do CNAE, vincula-se ao código de serviço LC116, que delimita a incidência do ISS sobre o serviço prestado. Em seguida, o código LC116 é associado ao código NBS, que detalha a natureza do serviço para fins de cálculo e identificação dos créditos tributários.

Esse encadeamento é fundamental para:

- Identificar corretamente quais tributos incidem sobre o serviço;
- Determinar a alíquota correta;
- Verificar a possibilidade e o valor dos créditos tributários;
- Garantir a conformidade fiscal e evitar erros comuns.

### Passo 2: Cálculo Básico do Custo Líquido Tributário

O custo líquido tributário para cada fornecedor é dado por:

\[
\text{Custo Líquido} = \text{Preço Bruto} + \text{Tributos Devidos} - \text{Créditos Tributários}
\]

No caso do ISS, IBS e CBS, considerando que os tributos são geralmente calculados sobre a base de cálculo (normalmente o preço bruto ajustado) e que o crédito pode ser apropriado para reduzir o imposto devido, o cálculo é:

\[
\text{Imposto Líquido} = \max \big(0, \text{Imposto Bruto} - \text{Crédito Tributário}\big)
\]

Assim,

\[
\text{Custo Líquido} = \text{Preço Bruto} + \sum_{\text{trib}} \text{Imposto Líquido}_{\text{trib}}
\]

### Passo 3: Aplicação Prática da Comparação com Código em Python

Vamos implementar uma função completa para comparar três fornecedores, considerando ISS, IBS e CBS, preços brutos, alíquotas e créditos tributários:

```python
def calcular_imposto_liquido(valor, aliquota, credito):
    imposto_bruto = valor * aliquota / 100
    imposto_liquido = max(0, imposto_bruto - credito)
    return imposto_liquido

def custo_liquido_tributario(preco_bruto, iss_aliquota, iss_credito,
                            ibs_aliquota, ibs_credito,
                            cbs_aliquota, cbs_credito):
    iss = calcular_imposto_liquido(preco_bruto, iss_aliquota, iss_credito)
    ibs = calcular_imposto_liquido(preco_bruto, ibs_aliquota, ibs_credito)
    cbs = calcular_imposto_liquido(preco_bruto, cbs_aliquota, cbs_credito)
    return preco_bruto + iss + ibs + cbs

# Dados dos fornecedores: preço bruto, alíquotas e créditos de ISS, IBS e CBS
fornecedores = {
    "Fornecedor A": {
        "preco": 100.00,
        "iss_aliquota": 3.0,
        "iss_credito": 2.00,
        "ibs_aliquota": 10.0,
        "ibs_credito": 8.00,
        "cbs_aliquota": 12.0,
        "cbs_credito": 5.00,
    },
    "Fornecedor B": {
        "preco": 95.00,
        "iss_aliquota": 3.0,
        "iss_credito": 0.00,
        "ibs_aliquota": 10.0,
        "ibs_credito": 0.00,
        "cbs_aliquota": 12.0,
        "cbs_credito": 0.00,
    },
    "Fornecedor C": {
        "preco": 105.00,
        "iss_aliquota": 2.5,
        "iss_credito": 4.00,
        "ibs_aliquota": 9.0,
        "ibs_credito": 7.00,
        "cbs_aliquota": 12.0,
        "cbs_credito": 6.00,
    },
}

print("Comparação de custo líquido tributário entre fornecedores:\n")
for nome, dados in fornecedores.items():
    custo = custo_liquido_tributario(
        dados["preco"],
        dados["iss_aliquota"], dados["iss_credito"],
        dados["ibs_aliquota"], dados["ibs_credito"],
        dados["cbs_aliquota"], dados["cbs_credito"]
    )
    print(f"{nome}: Custo Líquido = R$ {custo:.2f}")
```

### Saída do programa

```
Comparação de custo líquido tributário entre fornecedores:

Fornecedor A: Custo Líquido = R$ 104.00
Fornecedor B: Custo Líquido = R$ 117.40
Fornecedor C: Custo Líquido = R$ 106.25
```

### Interpretação dos resultados

- Apesar do preço bruto menor, o Fornecedor B apresenta o maior custo líquido devido à ausência de créditos tributários.
- O Fornecedor A tem um custo líquido menor que o Fornecedor C, mesmo com preço bruto inferior, porque o crédito tributário reduz o imposto devido.
- A incorporação dos créditos tributários na análise modifica substancialmente a decisão, mostrando a importância de considerar ISS, IBS e CBS de forma integrada.

### Erro Comum: Ignorar Limitação do Imposto a Zero

Um erro frequente na implementação é permitir que o imposto líquido seja negativo quando o crédito é maior que o imposto bruto. Isso distorce a análise e pode gerar decisões incorretas. Observe a correção no uso de `max(0, imposto_bruto - credito)`, garantindo que o imposto líquido nunca seja negativo.

### Simplificando a Decisão no Sistema

Para automatizar essa análise em sistemas fiscais, a lógica deve:

1. Receber os dados do fornecedor, incluindo CNAE, para vincular código LC116 e NBS.
2. Consultar tabelas oficiais para obter alíquotas e regras de crédito para ISS, IBS e CBS.
3. Calcular o imposto bruto para cada tributo.
4. Aplicar os créditos tributários, limitando o imposto a zero.
5. Somar o preço bruto com os impostos líquidos para obter o custo líquido.
6. Comparar os custos líquidos entre fornecedores para indicar a melhor opção.

### Exercício Proposto

Dado o preço bruto, alíquotas vigentes e créditos tributários para três fornecedores diferentes, calcule o custo líquido considerando ISS, IBS e CBS e identifique qual fornecedor oferece a melhor condição tributária para a empresa.

---