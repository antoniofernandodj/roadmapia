## Exercícios — Códigos de Tributação e Integração: cTribNac e Outros

### 1. Validar integração completa CNAE, LC116, NBS e cTribNac para fornecedor Lucro Real (intermediário)  
Dado um fornecedor com CNAE `6201-5/01`, LC116 `01.01`, NBS `6201`, e regime tributário Lucro Real, valide a integração desses códigos para identificar o código cTribNac correto. Calcule o crédito tributário para um serviço com preço bruto R$ 150,00, considerando alíquota de crédito de 15%. Explique os riscos fiscais associados a erros na vinculação desses códigos.

### 2. Comparação tributária entre fornecedores com regimes distintos usando integração CNAE-LC116-NBS-cTribNac (desafio)  
Considere dois fornecedores:  
- Fornecedor A: CNAE `6201-5/01`, LC116 `01.01`, NBS `6201`, regime Simples Nacional, preço bruto R$ 100,00, crédito tributário 15%.  
- Fornecedor B: CNAE `6201-5/01`, LC116 `01.01`, NBS `6201`, regime Lucro Real, preço bruto R$ 95,00, crédito tributário calculado conforme alíquota de 20%.  
Identifique os códigos cTribNac corretos para ambos, calcule o custo líquido para cada fornecedor e indique qual oferece a melhor opção tributária. Explique os impactos da reforma tributária na comparação.

### 3. Automatizar validação programática e cálculo de crédito para CNAE e LC116 incompatíveis (intermediário)  
Escreva um programa que receba como entrada um CNAE e um código LC116 e valide se estão compatíveis, usando uma tabela fictícia atualizada de integração (exemplo: CNAE `6204-0/00` é incompatível com LC116 `01.01`). Caso haja incompatibilidade, gere alerta e bloqueio para erro fiscal. Para entradas compatíveis, calcule crédito para valor R$ 150,00 com alíquota de 12%. Explique como a atualização das tabelas evita erros fiscais.

### 4. Desenvolvimento de função para obtenção do código cTribNac com base em múltiplas tabelas (desafio)  
Implemente uma função em Python que recebe CNAE, LC116, NBS e regime tributário e retorna o código cTribNac correto, simulando tabelas atualizadas de vinculação. Use os dados: CNAE `6204-0/00`, LC116 `01.02`, NBS `6204`, regime Lucro Real. Em seguida, calcule o crédito tributário para R$ 150,00 com alíquota de 12%. Explique como a função previne erros comuns pela validação cruzada.

### 5. Análise de impacto da não atualização das tabelas CNAE-LC116-NBS no cálculo tributário (básico)  
Explique, com um exemplo prático, como a utilização de tabelas desatualizadas de vinculação entre CNAE `6201-5/01`, LC116 `01.01` e NBS `6201` pode gerar erro na atribuição do código cTribNac e prejudicar o cálculo do crédito tributário para valor R$ 150,00. Demonstre como o erro afeta o custo líquido e quais os riscos fiscais envolvidos.

---

## Soluções comentadas

### 1. Validar integração completa CNAE, LC116, NBS e cTribNac para fornecedor Lucro Real

```python
# Dados fornecidos
cnae = "6201-5/01"
lc116 = "01.01"
nbs = "6201"
regime = "Lucro Real"
preco_bruto = 150.0
aliquota_credito = 0.15  # 15%

# Simulação tabela de vinculação (simplificada)
vinculacao_validas = {
    ("6201-5/01", "01.01", "6201", "Lucro Real"): "cTribNac_620101LR"
}

# Verificar se a combinação é válida
key = (cnae, lc116, nbs, regime)
if key in vinculacao_validas:
    cTribNac = vinculacao_validas[key]
else:
    cTribNac = None

if cTribNac is None:
    print("Erro: combinação inválida de códigos e regime.")
else:
    # Calcular crédito tributário
    credito = preco_bruto * aliquota_credito
    custo_liquido = preco_bruto - credito
    print(f"Código cTribNac: {cTribNac}")
    print(f"Crédito tributário: R$ {credito:.2f}")
    print(f"Custo líquido: R$ {custo_liquido:.2f}")

# Explicação dos riscos:
# Erros na vinculação podem bloquear declarações fiscais e impedir apropriação correta de créditos,
# gerando multas e distorções no custo tributário real.
```

Saída real:  
```
Código cTribNac: cTribNac_620101LR
Crédito tributário: R$ 22.50
Custo líquido: R$ 127.50
```

**Decisão**: Validamos os quatro códigos integrados para garantir que o código cTribNac está correto, evitando risco fiscal. O crédito é calculado com base na alíquota do regime Lucro Real. Caso a vinculação falhe, o sistema bloqueia a operação.

---

### 2. Comparação tributária entre fornecedores com regimes distintos usando integração CNAE-LC116-NBS-cTribNac

```python
# Dados dos fornecedores
fornA = {
    "cnae": "6201-5/01",
    "lc116": "01.01",
    "nbs": "6201",
    "regime": "Simples Nacional",
    "preco_bruto": 100.0,
    "aliquota_credito": 0.15
}
fornB = {
    "cnae": "6201-5/01",
    "lc116": "01.01",
    "nbs": "6201",
    "regime": "Lucro Real",
    "preco_bruto": 95.0,
    "aliquota_credito": 0.20
}

# Simulação tabela de vinculação
vinculacao_validas = {
    ("6201-5/01", "01.01", "6201", "Simples Nacional"): "cTribNac_620101SN",
    ("6201-5/01", "01.01", "6201", "Lucro Real"): "cTribNac_620101LR"
}

def calcular_custo_liquido(fornecedor):
    key = (fornecedor["cnae"], fornecedor["lc116"], fornecedor["nbs"], fornecedor["regime"])
    cTribNac = vinculacao_validas.get(key)
    if cTribNac is None:
        raise ValueError("Código cTribNac inválido para fornecedor")
    credito = fornecedor["preco_bruto"] * fornecedor["aliquota_credito"]
    custo_liquido = fornecedor["preco_bruto"] - credito
    return cTribNac, credito, custo_liquido

cTribNacA, creditoA, custoA = calcular_custo_liquido(fornA)
cTribNacB, creditoB, custoB = calcular_custo_liquido(fornB)

print(f"Fornecedor A - cTribNac: {cTribNacA}, Crédito: R$ {creditoA:.2f}, Custo líquido: R$ {custoA:.2f}")
print(f"Fornecedor B - cTribNac: {cTribNacB}, Crédito: R$ {creditoB:.2f}, Custo líquido: R$ {custoB:.2f}")

if custoA < custoB:
    melhor = "Fornecedor A"
else:
    melhor = "Fornecedor B"

print(f"Melhor fornecedor pela opção tributária: {melhor}")

# Explicação:
# A reforma tributária assegura o código cTribNac correto por regime e vinculação,
# garantindo créditos adequados e evitando erros fiscais e custo distorcido.
```

Saída real:  
```
Fornecedor A - cTribNac: cTribNac_620101SN, Crédito: R$ 15.00, Custo líquido: R$ 85.00
Fornecedor B - cTribNac: cTribNac_620101LR, Crédito: R$ 19.00, Custo líquido: R$ 76.00
Melhor fornecedor pela opção tributária: Fornecedor B
```

**Decisão**: A comparação mostra que, apesar do preço bruto menor do Fornecedor B, o crédito maior reduz ainda mais o custo líquido, tornando-o a melhor opção. Isso é possível graças à correta integração dos códigos e regime pós-reforma.

---

### 3. Automatizar validação programática e cálculo de crédito para CNAE e LC116 incompatíveis

```python
def validar_cnae_lc116(cnae, lc116):
    # Tabela fictícia de compatibilidade
    tabela_compatibilidade = {
        "6201-5/01": ["01.01", "01.03"],
        "6204-0/00": ["01.02"]
    }
    if cnae not in tabela_compatibilidade:
        return False
    return lc116 in tabela_compatibilidade[cnae]

def calcular_credito(valor, aliquota):
    return valor * aliquota

# Testes
entrada_cnae = "6204-0/00"
entrada_lc116 = "01.01"  # incompatível

if not validar_cnae_lc116(entrada_cnae, entrada_lc116):
    print(f"Alerta: LC116 {entrada_lc116} incompatível com CNAE {entrada_cnae}. Bloqueio para evitar erro fiscal.")
else:
    credito = calcular_credito(150, 0.12)
    print(f"Crédito calculado: R$ {credito:.2f}")

# Explicação:
# Atualizações constantes da tabela evitam falhas fiscais causadas por vinculações erradas.
```

Saída real:  
```
Alerta: LC116 01.01 incompatível com CNAE 6204-0/00. Bloqueio para evitar erro fiscal.
```

**Decisão**: O sistema bloqueia a operação quando detecta incompatibilidade, protegendo contra erros de declaração e perdas de crédito, conforme a necessidade da atualização contínua das tabelas.

---

### 4. Desenvolvimento de função para obtenção do código cTribNac com base em múltiplas tabelas

```python
def obter_cTribNac(cnae, lc116, nbs, regime):
    # Tabelas simuladas de vinculação
    tabela_cTribNac = {
        ("6204-0/00", "01.02", "6204", "Lucro Real"): "cTribNac_620402LR"
    }
    key = (cnae, lc116, nbs, regime)
    return tabela_cTribNac.get(key)

def calcular_credito(valor, aliquota):
    return valor * aliquota

# Dados entrada
cnae = "6204-0/00"
lc116 = "01.02"
nbs = "6204"
regime = "Lucro Real"
preco = 150.0
aliquota = 0.12

codigo = obter_cTribNac(cnae, lc116, nbs, regime)
if codigo is None:
    print("Erro: combinação inválida para cTribNac")
else:
    credito = calcular_credito(preco, aliquota)
    custo_liquido = preco - credito
    print(f"Código cTribNac: {codigo}")
    print(f"Crédito tributário: R$ {credito:.2f}")
    print(f"Custo líquido: R$ {custo_liquido:.2f}")

# Explicação:
# A função valida cruzando todas as tabelas para garantir que o código cTribNac atribuído seja correto,
# evitando erros comuns na escolha incorreta do código.
```

Saída real:  
```
Código cTribNac: cTribNac_620402LR
Crédito tributário: R$ 18.00
Custo líquido: R$ 132.00
```

**Decisão**: Essa validação cruzada automatizada previne erros de vinculação que podem causar bloqueios fiscais e prejuízo na apropriação de créditos.

---

### 5. Análise de impacto da não atualização das tabelas CNAE-LC116-NBS no cálculo tributário

Exemplo prático: Suponha que a tabela antiga atribuía para CNAE `6201-5/01` o código LC116 `01.02`, mas a atualização correta é `01.01`. Usar a tabela desatualizada gera:

- Código cTribNac incorreto, pois vincula LC116 errado;
- Crédito tributário calculado com alíquota errada ou inexistente;
- Custo líquido superestimado, prejudicando análise tributária;
- Possível rejeição da EFD IBS/NFS-e pelo erro no código;
- Multas e riscos fiscais por declarações incorretas.

Exemplo numérico:  
- Preço bruto: R$ 150,00  
- Alíquota correta (LC116 01.01): 15% → crédito R$ 22,50  
- Alíquota incorreta (LC116 01.02): 10% → crédito R$ 15,00  
- Custo líquido correto: R$ 127,50  
- Custo líquido errado: R$ 135,00 (mais caro, decisão errada)

**Conclusão:**  
Manter tabelas atualizadas é fundamental para garantir conformidade fiscal, evitar erros de código, e assegurar decisões de fornecedores baseadas em custos líquidos reais. Sistemas que não atualizam podem causar bloqueios e perdas financeiras.