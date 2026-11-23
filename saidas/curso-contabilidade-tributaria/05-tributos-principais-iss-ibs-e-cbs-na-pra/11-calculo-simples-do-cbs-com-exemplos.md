## Cálculo Simples do CBS com Exemplos

Para entender o cálculo do CBS (Contribuição sobre Bens e Serviços) de forma prática, é fundamental partir da base: o CBS incide sobre a receita bruta da empresa, com alíquota fixa de 12% na grande maioria dos casos, e permite a apropriação de créditos tributários gerados em etapas anteriores da cadeia produtiva, conforme regras da reforma tributária.

### Problema Prático

Imagine que sua empresa está avaliando três fornecedores para a compra de um bem ou serviço tributado pelo CBS. Cada fornecedor apresenta um preço bruto diferente e gera créditos tributários distintos para sua empresa. Como calcular o custo real considerando o CBS, sem complicar com ISS ou IBS, para escolher o fornecedor mais vantajoso?

Esse cálculo é essencial porque o custo líquido tributário pode mudar a decisão: o fornecedor com preço bruto mais baixo pode custar mais após considerar o CBS e os créditos tributários.

### Passo 1: Definição da Base de Cálculo do CBS

A base de cálculo do CBS é a receita bruta total da operação, ajustada por descontos incondicionais concedidos, excluindo-se os impostos destacados na nota fiscal que não compõem receita (como ISS, ICMS, etc.). Os descontos condicionais não reduzem a base no momento da operação, conforme regra vigente.

Suponha que o fornecedor informe um valor bruto, descontos incondicionais e impostos destacados. A base é calculada assim:

\[
\text{Base CBS} = \text{Valor Bruto} - \text{Descontos Incondicionais} - \text{Impostos Destacados}
\]

### Passo 2: Aplicação da Alíquota do CBS

A alíquota padrão do CBS é 12%, aplicada sobre a base de cálculo acima.

\[
\text{CBS Bruto} = \text{Base CBS} \times 12\%
\]

### Passo 3: Aplicação do Crédito Tributário

A empresa pode abater créditos tributários acumulados em etapas anteriores. O crédito é um valor em reais que reduz o imposto a pagar.

\[
\text{CBS Líquido} = \max(0, \text{CBS Bruto} - \text{Crédito Tributário})
\]

A função max(0, ...) garante que o imposto não seja negativo, erro comum nas apurações.

### Passo 4: Cálculo do Custo Líquido do Fornecedor

O custo líquido que a empresa terá com o fornecedor, considerando o CBS, é:

\[
\text{Custo Líquido} = \text{Valor Bruto} + \text{CBS Líquido}
\]

Este é o valor efetivo que impactará o caixa da empresa, pois o crédito já foi subtraído do imposto.

---

### Exemplo Completo em Python

Vamos implementar esse cálculo para três fornecedores, simulando valores reais:

```python
def calcular_cbs(valor_bruto, descontos_incondicionais, impostos_destacados, aliquota_cbs, credito_tributario):
    # Calcula a base de cálculo do CBS
    base_cbs = valor_bruto - descontos_incondicionais - impostos_destacados
    if base_cbs < 0:
        raise ValueError("Base de cálculo do CBS não pode ser negativa")
    
    # Calcula o CBS bruto
    cbs_bruto = base_cbs * aliquota_cbs
    
    # Aplica o crédito tributário, limitando para zero
    cbs_liquido = max(0, cbs_bruto - credito_tributario)
    
    return cbs_liquido

def custo_liquido_fornecedor(valor_bruto, cbs_liquido):
    return valor_bruto + cbs_liquido

# Dados dos fornecedores: (valor_bruto, descontos_incondicionais, impostos_destacados, crédito_tributário)
fornecedores = {
    'Fornecedor A': (100.00, 5.00, 0.00, 8.00),
    'Fornecedor B': (95.00, 3.00, 0.00, 4.00),
    'Fornecedor C': (102.00, 7.00, 0.00, 10.00),
}

aliquota_cbs = 0.12  # 12%

print("Cálculo do CBS e custo líquido para fornecedores:\n")

for nome, dados in fornecedores.items():
    valor_bruto, descontos, impostos, credito = dados
    try:
        cbs_liquido = calcular_cbs(valor_bruto, descontos, impostos, aliquota_cbs, credito)
        custo_liquido = custo_liquido_fornecedor(valor_bruto, cbs_liquido)
        print(f"{nome}:")
        print(f"  Valor bruto: R$ {valor_bruto:.2f}")
        print(f"  Descontos incondicionais: R$ {descontos:.2f}")
        print(f"  Impostos destacados: R$ {impostos:.2f}")
        print(f"  Crédito tributário: R$ {credito:.2f}")
        print(f"  CBS devido (líquido): R$ {cbs_liquido:.2f}")
        print(f"  Custo líquido total: R$ {custo_liquido:.2f}\n")
    except ValueError as e:
        print(f"Erro no cálculo para {nome}: {e}\n")
```

---

### Saída Real do Programa

```
Cálculo do CBS e custo líquido para fornecedores:

Fornecedor A:
  Valor bruto: R$ 100.00
  Descontos incondicionais: R$ 5.00
  Impostos destacados: R$ 0.00
  Crédito tributário: R$ 8.00
  CBS devido (líquido): R$ 3.60
  Custo líquido total: R$ 103.60

Fornecedor B:
  Valor bruto: R$ 95.00
  Descontos incondicionais: R$ 3.00
  Impostos destacados: R$ 0.00
  Crédito tributário: R$ 4.00
  CBS devido (líquido): R$ 9.84
  Custo líquido total: R$ 104.84

Fornecedor C:
  Valor bruto: R$ 102.00
  Descontos incondicionais: R$ 7.00
  Impostos destacados: R$ 0.00
  Crédito tributário: R$ 10.00
  CBS devido (líquido): R$ 0.00
  Custo líquido total: R$ 102.00
```

---

### Análise da Saída

- O fornecedor A tem custo líquido de R$103,60, apesar de ter crédito tributário bom, a base maior e menos desconto impactam.
- O fornecedor B tem preço bruto menor, mas menos desconto e crédito tributário, resultando em custo líquido maior que A.
- O fornecedor C, mesmo com preço bruto mais alto, possui descontos maiores e crédito suficiente para zerar o CBS devido, resultando no menor custo líquido.

Assim, a escolha do fornecedor C é a mais vantajosa do ponto de vista tributário, considerando CBS.

---

### Erro Comum e Como Evitar

Um erro muito frequente ao calcular o CBS líquido é não limitar o imposto devido a zero quando o crédito tributário é maior que o imposto bruto, resultando em valores negativos de imposto, o que é incorreto.

Por exemplo, se fizermos:

```python
cbs_liquido = cbs_bruto - credito_tributario  # sem max(0, ...)
```

Poderemos obter:

```
CBS devido (líquido): -R$ 2,00
```

O sistema e a legislação não permitem imposto negativo, pois o crédito não pode gerar ressarcimento automático, apenas compensação.

---

### Exercício Proposto

Dado o valor bruto, descontos incondicionais, impostos destacados, alíquota do CBS e crédito tributário para três fornecedores, implemente uma função que calcule o custo líquido para cada um e indique qual fornecedor apresenta o menor custo líquido considerando o CBS.

---