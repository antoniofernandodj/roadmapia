## Créditos Tributários Relacionados ao ISS

Ao analisar fornecedores para contratação de serviços, a consideração dos créditos tributários vinculados ao ISS (Imposto Sobre Serviços) é essencial para uma decisão fiscalmente eficiente. Diferentemente dos tributos federais e estaduais, o ISS possui regras específicas quanto à apropriação de créditos tributários, que impactam diretamente o custo líquido da contratação.

### Por que os créditos tributários do ISS são relevantes?

Imagine que você vai contratar um serviço e possui duas propostas:

- Fornecedor A cobra R$ 100,00 e gera R$ 10,00 de crédito de ISS para sua empresa.
- Fornecedor B cobra R$ 95,00 e não gera crédito de ISS.

A simples comparação pelo preço bruto pode induzir a erro. Se sua empresa pode aproveitar o crédito tributário gerado pelo Fornecedor A, o custo líquido efetivo pode ser menor do que o do Fornecedor B. Logo, entender como os créditos do ISS funcionam é fundamental para decisões estratégicas e para o correto desenvolvimento de sistemas fiscais que automatizem essa análise.

### Mecanismo de crédito tributário no ISS

O ISS é um tributo municipal incidente sobre a prestação de serviços listados na Lei Complementar 116 (LC116). Após a reforma tributária, a regra geral para o crédito tributário do ISS é que ele é **não cumulativo**, ou seja, o contribuinte pode descontar o valor do imposto pago na etapa anterior (normalmente o ISS retido ou pago pelo fornecedor) do ISS devido na etapa seguinte.

Porém, diferentemente do IBS e CBS, o ISS possui limitações expressas na apropriação de créditos:

- **Créditos permitidos**: São os valores de ISS destacados na nota fiscal do serviço adquirido, desde que o serviço esteja tributado no município e que o tomador do serviço seja sujeito passivo do ISS.
- **Créditos vedados**: Serviços que não geram crédito, como aqueles prestados por profissionais liberais sem inscrição municipal, ou serviços sujeitos à imunidade ou isenção, não geram direito a crédito tributário.
- **Limitação municipal**: A legislação do município pode estabelecer regras específicas para a apropriação de créditos, incluindo percentuais máximos ou condições restritivas.

### Como calcular o crédito tributário do ISS?

O crédito apropriável é o ISS efetivamente pago ao fornecedor, calculado com base na alíquota municipal incidente sobre o valor do serviço. O cálculo do crédito deve considerar:

- O valor da nota fiscal do serviço.
- A alíquota do ISS aplicada pelo município onde o serviço foi prestado.
- Se o ISS foi retido na fonte ou pago pelo próprio fornecedor.
- A correta vinculação do serviço ao código LC116 e ao CNAE do fornecedor, garantindo que o serviço seja tributado pelo ISS e que o crédito seja legítimo.

#### Exemplo prático

Considere três fornecedores que oferecem o mesmo serviço, com dados abaixo:

| Fornecedor | Valor do Serviço (R$) | Alíquota ISS (%) | Crédito Tributário ISS (R$) |
|------------|-----------------------|------------------|-----------------------------|
| A          | 1.000,00              | 5,00             | 50,00                       |
| B          | 950,00                | 5,00             | 0,00                        |
| C          | 980,00                | 4,00             | 39,20                       |

Para calcular o custo líquido considerando o crédito tributário, usa-se:

```
Custo Líquido = Valor do Serviço - Crédito Tributário
```

Aplicando aos fornecedores:

- Fornecedor A: 1.000,00 - 50,00 = 950,00
- Fornecedor B: 950,00 - 0,00 = 950,00
- Fornecedor C: 980,00 - 39,20 = 940,80

Logo, o fornecedor C, apesar do valor bruto maior que B, tem o menor custo líquido devido ao crédito tributário.

### Erro comum na apropriação de créditos do ISS

Um erro frequente na automação do cálculo do ISS é usar o valor bruto do serviço para calcular o crédito sem validar a vinculação correta do CNAE com o código LC116 e NBS correspondente. Isso pode levar a:

- Apropriação indevida de crédito para serviços que não geram ISS.
- Cálculo incorreto da alíquota aplicada, por não considerar o município correto.
- Crédito tributário maior que o imposto devido, gerando cálculos negativos ou inconsistentes.

Exemplo do erro no código Python:

```python
def calcular_credito_iss(valor_servico, aliquota_iss, credito_informado):
    imposto_bruto = valor_servico * aliquota_iss / 100
    credito = credito_informado
    imposto_liquido = imposto_bruto - credito
    if imposto_liquido < 0:
        raise ValueError("Crédito tributário maior que o imposto devido.")
    return imposto_liquido

# Tentativa incorreta de cálculo:
valor = 1000
aliquota = 5
credito = 60  # crédito maior que o imposto bruto de R$ 50

print(calcular_credito_iss(valor, aliquota, credito))
```

Saída esperada:

```
ValueError: Crédito tributário maior que o imposto devido.
```

**Correção:** É necessário validar que o crédito informado não exceda o imposto bruto calculado, e em caso de créditos maiores, limitar o valor do imposto a zero.

### Código Python completo para cálculo correto do ISS com crédito

```python
def calcular_custo_liquido_iss(valor_servico, aliquota_iss, credito_iss):
    """
    Calcula o custo líquido do serviço considerando o ISS e o crédito tributário.

    :param valor_servico: Valor bruto do serviço (float)
    :param aliquota_iss: Alíquota do ISS em percentual (float)
    :param credito_iss: Crédito tributário de ISS disponível (float)
    :return: custo líquido do serviço após considerar crédito tributário (float)
    """
    imposto_bruto = valor_servico * aliquota_iss / 100
    imposto_liquido = max(0.0, imposto_bruto - credito_iss)
    custo_liquido = valor_servico - (imposto_bruto - imposto_liquido)
    return custo_liquido

# Exemplo com três fornecedores
fornecedores = [
    {"nome": "Fornecedor A", "valor": 1000.0, "aliquota": 5.0, "credito": 50.0},
    {"nome": "Fornecedor B", "valor": 950.0, "aliquota": 5.0, "credito": 0.0},
    {"nome": "Fornecedor C", "valor": 980.0, "aliquota": 4.0, "credito": 39.20},
]

for fornecedor in fornecedores:
    custo = calcular_custo_liquido_iss(
        fornecedor["valor"], fornecedor["aliquota"], fornecedor["credito"]
    )
    print(f"{fornecedor['nome']} - Custo líquido ISS: R$ {custo:.2f}")
```

Saída real:

```
Fornecedor A - Custo líquido ISS: R$ 950.00
Fornecedor B - Custo líquido ISS: R$ 950.00
Fornecedor C - Custo líquido ISS: R$ 940.80
```

### Aplicação prática na escolha do fornecedor

Ao desenvolver sistemas para análise tributária, é imprescindível:

- Garantir a vinculação correta do CNAE do fornecedor ao código de serviço LC116 e NBS, para confirmar a incidência do ISS.
- Validar se o serviço gera direito a crédito tributário, conforme a legislação municipal.
- Calcular o crédito tributário com base na alíquota efetiva do ISS do município onde o serviço foi prestado.
- Limitar o imposto líquido a zero para evitar erros por créditos maiores que o imposto bruto.
- Exibir o custo líquido tributário para permitir comparação justa entre fornecedores.

Assim, o sistema pode indicar a opção mais vantajosa considerando tanto o preço quanto o benefício fiscal dos créditos de ISS, alinhando-se à realidade pós-reforma tributária.

---

### Exercício proposto

Dado o valor do serviço, a alíquota do ISS e o crédito tributário para três fornecedores diferentes, implemente uma função que calcule o custo líquido considerando o ISS e identifique qual fornecedor oferece a melhor condição tributária.

---