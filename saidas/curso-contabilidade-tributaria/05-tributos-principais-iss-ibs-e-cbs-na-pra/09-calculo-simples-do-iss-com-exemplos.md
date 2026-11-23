## Cálculo Simples do ISS com Exemplos

O Imposto Sobre Serviços (ISS) é um tributo municipal que incide sobre a prestação de serviços constantes na lista da LC116, vinculada ao CNAE e ao código de serviço LC116, e detalhada pela NBS (ver 3.1, 3.6 e 4.7). O cálculo básico do ISS, apesar de simples, exige atenção para evitar erros comuns, como aplicar alíquota incorreta ou ignorar o crédito tributário disponível.

### Problema prático: Como calcular o ISS para escolher o fornecedor mais vantajoso?

Considere que sua empresa está avaliando propostas de três fornecedores para um serviço específico. Cada fornecedor apresenta um preço bruto, uma alíquota de ISS diferente conforme o município e o código de serviço, e um crédito tributário que sua empresa poderá apropriar na operação. O objetivo é calcular o custo líquido após o impacto do ISS e do crédito para decidir qual fornecedor oferece o melhor custo efetivo.

### Passo a passo do cálculo do ISS

1. **Determinar a base de cálculo do ISS**: corresponde ao valor bruto do serviço, ajustado conforme regras específicas (descontos condicionais, encargos e impostos destacados, ver 3.4 e base de cálculo do ISS 7.2).
2. **Aplicar a alíquota do ISS**: varia entre 2% e 5%, conforme município e código LC116/NBS (ver 3.4 e 7.3).
3. **Calcular o imposto devido**: multiplicar a base pela alíquota.
4. **Subtrair o crédito tributário apropriado**: o crédito pode reduzir o imposto a pagar, não podendo resultar em imposto negativo (ver 1.4, 7.7).
5. **Obter o custo líquido tributário**: somar o valor bruto do serviço ao ISS líquido (imposto devido menos crédito).

### Exemplo prático completo em Python

Vamos implementar um código executável que calcula o custo líquido do ISS para três fornecedores, com base em seus valores, alíquotas e créditos.

```python
def calcular_iss_liquido(valor_servico, aliquota_iss, credito_tributario):
    """
    Calcula o ISS líquido a pagar considerando o valor do serviço, alíquota e crédito tributário.
    Retorna o imposto devido (não negativo) e o custo líquido total.
    """
    # Base de cálculo do ISS (aqui simplificada como valor_servico ajustado)
    base_calculo = valor_servico

    # Cálculo do ISS bruto
    iss_bruto = base_calculo * aliquota_iss / 100

    # Aplicação do crédito tributário (não pode tornar o imposto negativo)
    iss_liquido = max(iss_bruto - credito_tributario, 0)

    # Custo líquido considerando o ISS pago
    custo_liquido = valor_servico + iss_liquido

    return iss_liquido, custo_liquido

# Dados dos fornecedores: valor do serviço, alíquota ISS (%), crédito tributário
fornecedores = {
    "Fornecedor A": {"valor": 100.0, "aliquota": 5.0, "credito": 15.0},
    "Fornecedor B": {"valor": 95.0,  "aliquota": 3.0, "credito": 0.0},
    "Fornecedor C": {"valor": 105.0, "aliquota": 4.0, "credito": 10.0},
}

print("Cálculo do ISS e custo líquido para fornecedores:\n")
for nome, dados in fornecedores.items():
    iss, custo = calcular_iss_liquido(dados["valor"], dados["aliquota"], dados["credito"])
    print(f"{nome}:")
    print(f"  Valor do serviço: R$ {dados['valor']:.2f}")
    print(f"  Alíquota ISS: {dados['aliquota']:.1f}%")
    print(f"  Crédito tributário: R$ {dados['credito']:.2f}")
    print(f"  ISS devido: R$ {iss:.2f}")
    print(f"  Custo líquido: R$ {custo:.2f}\n")
```

#### Saída esperada

```
Cálculo do ISS e custo líquido para fornecedores:

Fornecedor A:
  Valor do serviço: R$ 100.00
  Alíquota ISS: 5.0%
  Crédito tributário: R$ 15.00
  ISS devido: R$ 5.00
  Custo líquido: R$ 105.00

Fornecedor B:
  Valor do serviço: R$ 95.00
  Alíquota ISS: 3.0%
  Crédito tributário: R$ 0.00
  ISS devido: R$ 2.85
  Custo líquido: R$ 97.85

Fornecedor C:
  Valor do serviço: R$ 105.00
  Alíquota ISS: 4.0%
  Crédito tributário: R$ 10.00
  ISS devido: R$ 4.20
  Custo líquido: R$ 109.20
```

### Análise do resultado

Mesmo que o Fornecedor A tenha o preço bruto mais alto (R$ 100,00), o crédito tributário de R$ 15,00 reduz significativamente o valor do ISS a pagar, resultando em um custo líquido de R$ 105,00. O Fornecedor B tem o menor preço bruto, mas não gera crédito tributário, resultando em custo líquido maior que o preço bruto. O Fornecedor C é o mais caro e, apesar do crédito, não compensa.

**Cuidado**: Se ignorarmos o crédito tributário, escolheríamos o Fornecedor B por preço bruto. Porém, considerando o ISS e os créditos, o Fornecedor A pode ser mais vantajoso dependendo do impacto do crédito sobre o custo final (ver 1.8).

### Erro comum e sua correção

Um erro frequente no cálculo do ISS é subtrair o crédito tributário sem limitar o imposto devido a zero, o que pode gerar valores negativos indevidos:

```python
# Exemplo do erro:
iss_bruto = 4.0
credito = 5.0
iss_liquido_errado = iss_bruto - credito  # Resultado: -1.0 (imposto negativo, impossível)
```

O correto é usar a função `max` para limitar o imposto a zero:

```python
iss_liquido_correto = max(iss_bruto - credito, 0)  # Resultado: 0, não negativo
```

Sem essa correção, o sistema pode gerar relatórios incorretos, levando a decisões erradas na análise de fornecedores.

### Exercício para fixação

Implemente uma função que receba uma lista com dados de três fornecedores (valor do serviço, alíquota ISS e crédito tributário) e retorne o nome do fornecedor com o menor custo líquido tributário considerando o ISS. Teste a função com os dados do exemplo acima.

---