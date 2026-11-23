## Resumo dos Passos para Análise Comparativa Eficiente

Para realizar uma análise comparativa eficiente entre fornecedores considerando a tributação pós-reforma, é necessário seguir uma sequência estruturada que integra corretamente os códigos tributários, calcula o impacto dos tributos e créditos, e permite a decisão baseada no custo líquido tributário real. A seguir, detalhamos os passos essenciais para essa análise.

### 1. Identificação do CNAE do Fornecedor

O ponto de partida é a identificação precisa do CNAE (Classificação Nacional de Atividades Econômicas) do fornecedor, que define a atividade econômica principal e subsidiária. Essa classificação é essencial para vincular corretamente os demais códigos tributários. A identificação deve ser feita com base na documentação fiscal e cadastral do fornecedor, garantindo que o código CNAE esteja atualizado e corresponda exatamente à atividade exercida.

> **Erro comum:** Utilizar um CNAE genérico ou incorreto pode resultar em rejeição fiscal ou perda de créditos tributários, como ocorre quando o sistema retorna mensagem do tipo:  
> `"Rejeição: CNAE incompatível com código de serviço LC116 informado"`.

### 2. Vinculação do CNAE ao Código de Serviço LC116

Com o CNAE identificado, o próximo passo é vincular esse código ao correspondente código de serviço previsto na LC116. Essa vinculação é fundamental para determinar a incidência correta do ISS (Imposto Sobre Serviços) e identificar a base de cálculo e alíquota aplicáveis.

A vinculação deve seguir a tabela oficial de correspondência CNAE → LC116, garantindo que o serviço prestado pelo fornecedor esteja contemplado na lista tributável do ISS. O erro mais comum nessa etapa é informar um código LC116 incompatível com o CNAE, o que impede a apropriação dos créditos tributários.

```python
# Exemplo simples de vinculação em Python
tabela_cnae_lc116 = {
    '6201-5/01': '0101',  # Desenvolvimento de software sob encomenda
    '7112-0/00': '0202',  # Serviços de consultoria técnica
    # demais vínculos...
}

def vincular_lc116(cnae):
    return tabela_cnae_lc116.get(cnae, None)

cnae_fornecedor = '6201-5/01'
codigo_lc116 = vincular_lc116(cnae_fornecedor)
print(f"CNAE: {cnae_fornecedor} -> Código LC116: {codigo_lc116}")
```

Saída:
```
CNAE: 6201-5/01 -> Código LC116: 0101
```

### 3. Vinculação do Código LC116 ao Código NBS

Após confirmar o código LC116, é necessário vinculá-lo ao código NBS (Nomenclatura Brasileira de Serviços). A NBS detalha a natureza do serviço para fins de apuração do ISS, IBS e CBS, e essa vinculação assegura que a tributação seja aplicada corretamente conforme a legislação vigente.

A tabela de vinculação LC116 → NBS deve ser atualizada periodicamente para refletir as mudanças da reforma tributária e evitar erros, como a rejeição com a mensagem:  
`"Código LC116 incompatível com NBS informado"`.

```python
tabela_lc116_nbs = {
    '0101': '1010101',  # Desenvolvimento de software sob encomenda
    '0202': '2020202',  # Consultoria técnica
    # demais vínculos...
}

def vincular_nbs(lc116):
    return tabela_lc116_nbs.get(lc116, None)

codigo_nbs = vincular_nbs(codigo_lc116)
print(f"Código LC116: {codigo_lc116} -> Código NBS: {codigo_nbs}")
```

Saída:
```
Código LC116: 0101 -> Código NBS: 1010101
```

### 4. Determinação dos Tributos Incidentes e Alíquotas

Com a vinculação CNAE → LC116 → NBS consolidada, identifica-se quais tributos incidem sobre a operação: ISS (municipal), IBS (estadual/federal) e CBS (federal). Cada tributo possui regras específicas de base de cálculo, alíquotas e possibilidade de crédito, conforme já detalhado (ver 5.1, 5.2 e 5.3).

É fundamental aplicar as alíquotas vigentes, considerando variações municipais e estaduais, e ajustar a base de cálculo para descontos, retenções e substituições tributárias.

### 5. Cálculo do Custo Tributário Bruto

O custo tributário bruto corresponde ao valor total dos tributos devidos sem considerar os créditos. Calcula-se multiplicando a base de cálculo pelas alíquotas aplicáveis para ISS, IBS e CBS separadamente, e somando os valores apurados.

```python
def calcular_tributos(base_calculo, aliquotas):
    return sum(base_calculo * aliq for aliq in aliquotas)

base_calculo = 1000.0
aliquotas = [0.05, 0.12, 0.03]  # ISS, IBS, CBS

imposto_bruto = calcular_tributos(base_calculo, aliquotas)
print(f"Imposto bruto total: R$ {imposto_bruto:.2f}")
```

Saída:
```
Imposto bruto total: R$ 200.00
```

### 6. Identificação e Apropriação dos Créditos Tributários

Com o imposto bruto calculado, é preciso identificar os créditos tributários que o comprador pode apropriar, conforme a legislação e a vinculação dos códigos CNAE, LC116 e NBS.

Créditos tributários são valores que reduzem o custo líquido dos tributos, podendo ser originados de ICMS, ISS, IBS e CBS, e sua apropriação depende da regularidade da vinculação e da natureza da operação.

> **Erro comum:** Apropriar créditos sem validação da vinculação pode acarretar rejeição fiscal e multas, por exemplo:  
> `"Crédito tributário não permitido para o CNAE/LC116/NBS informado"`.

### 7. Cálculo do Custo Líquido Tributário

O custo líquido tributário é obtido subtraindo o valor dos créditos tributários do imposto bruto devido. Esse cálculo revela o impacto real da tributação no custo da operação, permitindo comparar fornecedores de forma justa e econômica.

```python
imposto_bruto = 200.0
credito_tributario = 50.0

custo_liquido = imposto_bruto - credito_tributario
print(f"Custo tributário líquido: R$ {custo_liquido:.2f}")
```

Saída:
```
Custo tributário líquido: R$ 150.00
```

### 8. Cálculo do Custo Total Líquido e Comparação entre Fornecedores

O custo total líquido considera o preço bruto do fornecedor acrescido do custo líquido tributário. Esse valor é a base para a comparação econômica real entre fornecedores.

Por exemplo:

| Fornecedor | Preço Bruto | Crédito Tributário | Custo Líquido Tributário | Custo Total Líquido |
|------------|-------------|--------------------|--------------------------|---------------------|
| A          | R$ 100,00   | R$ 15,00           | R$ 10,00                 | R$ 110,00            |
| B          | R$ 95,00    | R$ 0,00            | R$ 14,25                 | R$ 109,25            |

Neste caso, mesmo com crédito, o fornecedor B é mais vantajoso. Contudo, se o crédito do fornecedor A for maior, por exemplo R$ 20,00, ele pode se tornar o mais econômico.

```python
fornecedores = [
    {'nome': 'A', 'preco': 100.0, 'credito': 15.0, 'custo_tributario': 25.0},
    {'nome': 'B', 'preco': 95.0, 'credito': 0.0, 'custo_tributario': 14.25},
]

def custo_total_liquido(fornecedor):
    return fornecedor['preco'] + (fornecedor['custo_tributario'] - fornecedor['credito'])

for f in fornecedores:
    total = custo_total_liquido(f)
    print(f"Fornecer {f['nome']}: Custo Total Líquido = R$ {total:.2f}")
```

Saída:
```
Fornecer A: Custo Total Líquido = R$ 110.00
Fornecer B: Custo Total Líquido = R$ 109.25
```

### 9. Validação Final e Atualização Contínua

Por fim, valide todos os códigos tributários usados e as tabelas de vinculação CNAE → LC116 → NBS para garantir que estejam atualizadas conforme as últimas normas e a reforma tributária. Sistemas fiscais devem realizar essa validação automaticamente para evitar erros e garantir a conformidade fiscal.

### Fluxo Resumido da Análise Comparativa Tributária

| Passo | Descrição                              | Documentos/Códigos envolvidos          |
|--------|--------------------------------------|---------------------------------------|
| 1      | Identificar CNAE do fornecedor       | CNAE cadastrado atualizado             |
| 2      | Vincular CNAE ao código LC116        | Tabela oficial CNAE → LC116            |
| 3      | Vincular código LC116 ao código NBS  | Tabela oficial LC116 → NBS             |
| 4      | Determinar tributos e alíquotas      | ISS, IBS, CBS e suas alíquotas         |
| 5      | Calcular imposto bruto               | Base de cálculo e alíquotas aplicáveis |
| 6      | Identificar créditos tributários     | Regra de apropriação conforme códigos  |
| 7      | Calcular custo líquido tributário    | Imposto bruto - créditos               |
| 8      | Somar custo líquido tributário ao preço bruto | Comparar custos líquidos totais      |
| 9      | Validar dados e atualizar tabelas    | Atualização contínua e validação       |

---

## Exercício proposto

Considere dois fornecedores com os seguintes dados:

- Fornecedor X: preço bruto R$ 120,00; CNAE '7112-0/00'; crédito tributário estimado R$ 25,00; custo tributário bruto R$ 30,00.
- Fornecedor Y: preço bruto R$ 110,00; CNAE '6201-5/01'; crédito tributário estimado R$ 10,00; custo tributário bruto R$ 22,00.

Utilizando as tabelas de vinculação CNAE → LC116 e LC116 → NBS, calcule o custo total líquido tributário de cada fornecedor e indique qual é a opção economicamente mais vantajosa.

---