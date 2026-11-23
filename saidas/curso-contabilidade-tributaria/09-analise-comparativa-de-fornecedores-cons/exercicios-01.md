## Exercícios — Análise Comparativa de Fornecedores Considerando Tributação

### 1. Comparação de fornecedores com diferentes CNAE e impacto tributário (intermediário)  
Dado que dois fornecedores apresentam preços e créditos diferentes, e que seus CNAEs vinculam-se a códigos distintos LC116 e NBS, calcule o custo líquido tributário de cada fornecedor e indique qual é a melhor escolha considerando a possibilidade de apropriação de créditos.  
Dados:  
- Fornecedor A: preço R$ 120,00, CNAE 6201501 (desenvolvimento de software), crédito previsto R$ 20,00  
- Fornecedor B: preço R$ 110,00, CNAE 4322300 (instalação elétrica), crédito previsto R$ 5,00  
Utilize a vinculação CNAE → LC116 → NBS para validar os créditos e justificar a decisão final.

### 2. Cálculo do custo líquido considerando erros comuns na vinculação de códigos (desafio)  
Considere dois fornecedores com preços próximos, mas um deles apresenta erro na vinculação do seu código CNAE com o LC116, o que impede a apropriação total do crédito tributário.  
Dados:  
- Fornecedor A: preço R$ 150,00, CNAE 7111201 (serviços de engenharia), crédito potencial R$ 30,00, porém vinculação incorreta entre CNAE e LC116  
- Fornecedor B: preço R$ 160,00, CNAE 7111201, crédito efetivo R$ 25,00, vinculação correta  
Calcule o custo líquido tributário real para ambos considerando a limitação do crédito no fornecedor A e indique qual fornecedor é mais vantajoso.

### 3. Integração dos códigos para cálculo automático do custo líquido (intermediário)  
Implemente um programa em Python que receba como entrada o preço bruto, CNAE, crédito tributário e realize a vinculação automática CNAE → LC116 → NBS (simulada por dicionários) para validar o crédito e calcular o custo líquido tributário.  
Use os dados:  
- Fornecedor A: preço R$ 200,00, CNAE 6201501, crédito R$ 40,00  
- Fornecedor B: preço R$ 190,00, CNAE 4322300, crédito R$ 10,00  
O programa deverá informar qual fornecedor tem o menor custo líquido tributário e justificar o resultado.

### 4. Comparação de fornecedores com diferentes créditos e aplicação da reforma tributária (desafio)  
Dois fornecedores apresentam preços e créditos tributários, mas um deles possui códigos LC116 e NBS atualizados pós-reforma tributária, enquanto o outro ainda usa códigos antigos, o que pode invalidar créditos.  
Dados:  
- Fornecedor A: preço R$ 130,00, crédito R$ 25,00, LC116 e NBS atualizados  
- Fornecedor B: preço R$ 125,00, crédito R$ 30,00, códigos desatualizados (simular erro de validação)  
Calcule o custo líquido tributário considerando a validação dos códigos e indique qual fornecedor é mais vantajoso.

### 5. Escolha do fornecedor com análise combinada de CNAE, LC116, NBS e créditos em cenário de setores mistos (desafio)  
Dado dois fornecedores com atividades mistas, cujos CNAEs possuem múltiplas subclasses e vinculam a mais de um código LC116 e NBS, calcule o custo líquido tributário considerando a segregação dos créditos para cada código.  
Dados:  
- Fornecedor A: preço R$ 300,00, CNAE 4711301 (comércio varejista de mercadorias diversas), vincula a LC116 códigos 0101 e 0202, créditos R$ 20,00 e R$ 15,00 respectivamente  
- Fornecedor B: preço R$ 290,00, CNAE 6201501 (serviços de tecnologia), vincula a LC116 código 0101, crédito R$ 30,00  
Calcule o custo líquido tributário total para cada fornecedor e indique o mais vantajoso.

---

## Soluções comentadas

### 1. Comparação de fornecedores com diferentes CNAE e impacto tributário  
Neste exercício, o foco é calcular o custo líquido tributário considerando a vinculação CNAE → LC116 → NBS para validar os créditos.

Decisão chave:  
- Validar se o crédito informado é aplicável via a vinculação dos códigos  
- Subtrair o crédito do preço bruto para obter o custo líquido tributário  
- Comparar custos líquidos para indicar o fornecedor mais vantajoso

```python
# Dados dos fornecedores
fornecedores = {
    "A": {"preco": 120.00, "cnae": "6201501", "credito": 20.00},
    "B": {"preco": 110.00, "cnae": "4322300", "credito": 5.00},
}

# Simulação das vinculações CNAE -> LC116 -> NBS para validação
# Consideraremos que CNAE 6201501 valida crédito integralmente
# CNAE 4322300 também valida, mas com crédito menor
vinculacoes = {
    "6201501": {"lc116": "0101", "nbs": "101"},
    "4322300": {"lc116": "0202", "nbs": "202"},
}

def validar_credito(cnae, credito):
    # Validação simples: se CNAE está na tabela, crédito é válido
    return credito if cnae in vinculacoes else 0.0

resultados = {}

for f, dados in fornecedores.items():
    credito_valido = validar_credito(dados["cnae"], dados["credito"])
    custo_liquido = dados["preco"] - credito_valido
    resultados[f] = custo_liquido
    print(f"Fornecedor {f}: preço {dados['preco']}, crédito válido {credito_valido}, custo líquido {custo_liquido}")

# Decisão
vencedor = min(resultados, key=resultados.get)
print(f"\nFornecedor mais vantajoso: {vencedor} com custo líquido R$ {resultados[vencedor]:.2f}")
```

Saída real:

```
Fornecedor A: preço 120.0, crédito válido 20.0, custo líquido 100.0
Fornecedor B: preço 110.0, crédito válido 5.0, custo líquido 105.0

Fornecedor mais vantajoso: A com custo líquido R$ 100.00
```

Explicação: Apesar do fornecedor B ter preço bruto menor, o crédito tributário maior do fornecedor A (validado via vinculação adequada) torna o custo líquido dele menor, justificando a escolha por A.

---

### 2. Cálculo do custo líquido considerando erros comuns na vinculação de códigos  
Aqui, é necessário simular a limitação do crédito do fornecedor A devido a vinculação incorreta.

Decisão chave:  
- Fornecedor A perde parte do crédito por erro na vinculação (ex: só apropria 50% do crédito)  
- Fornecedor B tem crédito integral  
- Calcular custo líquido considerando essas condições

```python
fornecedores = {
    "A": {"preco": 150.00, "cnae": "7111201", "credito_potencial": 30.00, "vinculacao_valida": False},
    "B": {"preco": 160.00, "cnae": "7111201", "credito_potencial": 25.00, "vinculacao_valida": True},
}

def apropriar_credito(fornecedor):
    if fornecedor["vinculacao_valida"]:
        return fornecedor["credito_potencial"]
    else:
        # Limitação por vinculação incorreta, apropria metade do crédito
        return fornecedor["credito_potencial"] * 0.5

resultados = {}

for f, dados in fornecedores.items():
    credito_efetivo = apropriar_credito(dados)
    custo_liquido = dados["preco"] - credito_efetivo
    resultados[f] = custo_liquido
    print(f"Fornecedor {f}: preço {dados['preco']}, crédito efetivo {credito_efetivo}, custo líquido {custo_liquido}")

vencedor = min(resultados, key=resultados.get)
print(f"\nFornecedor mais vantajoso: {vencedor} com custo líquido R$ {resultados[vencedor]:.2f}")
```

Saída real:

```
Fornecedor A: preço 150.0, crédito efetivo 15.0, custo líquido 135.0
Fornecedor B: preço 160.0, crédito efetivo 25.0, custo líquido 135.0

Fornecedor mais vantajoso: A com custo líquido R$ 135.00
```

Explicação: Mesmo com vinculação incorreta, o fornecedor A fica empatado com B no custo líquido. Dependendo da política da empresa, pode-se preferir A pelo preço bruto menor, mas a limitação do crédito evidencia o risco de erro na análise.

---

### 3. Integração dos códigos para cálculo automático do custo líquido  
Neste código Python, simulamos as vinculações usando dicionários e validamos créditos para calcular custo líquido.

Decisão chave:  
- Vincular CNAE ao LC116 e este ao NBS para validar crédito  
- Se a vinculação não existir, crédito não é aplicado

```python
# Dados
fornecedores = {
    "A": {"preco": 200.00, "cnae": "6201501", "credito": 40.00},
    "B": {"preco": 190.00, "cnae": "4322300", "credito": 10.00},
}

# Simulação de tabela CNAE -> LC116
cnae_lc116 = {
    "6201501": "0101",
    "4322300": "0202",
}

# Simulação de tabela LC116 -> NBS
lc116_nbs = {
    "0101": "101",
    "0202": "202",
}

def validar_vinculacao(cnae, credito):
    lc116 = cnae_lc116.get(cnae)
    if not lc116:
        return 0.0
    nbs = lc116_nbs.get(lc116)
    if not nbs:
        return 0.0
    # Se ambos existem, crédito válido
    return credito

custos_liquidos = {}

for f, dados in fornecedores.items():
    credito_valido = validar_vinculacao(dados["cnae"], dados["credito"])
    custo_liquido = dados["preco"] - credito_valido
    custos_liquidos[f] = custo_liquido
    print(f"Fornecedor {f}: preço {dados['preco']}, crédito válido {credito_valido}, custo líquido {custo_liquido}")

melhor = min(custos_liquidos, key=custos_liquidos.get)
print(f"\nFornecedor mais vantajoso: {melhor} com custo líquido R$ {custos_liquidos[melhor]:.2f}")
```

Saída real:

```
Fornecedor A: preço 200.0, crédito válido 40.0, custo líquido 160.0
Fornecedor B: preço 190.0, crédito válido 10.0, custo líquido 180.0

Fornecedor mais vantajoso: A com custo líquido R$ 160.00
```

Explicação: A vinculação correta permite validar o crédito maior do fornecedor A, tornando seu custo líquido menor, mesmo com preço bruto maior.

---

### 4. Comparação de fornecedores com diferentes créditos e aplicação da reforma tributária  
Simulamos a validação de códigos atualizados pós-reforma. Fornecedor B tem códigos desatualizados e perde crédito.

Decisão chave:  
- Fornecedor A tem crédito integral, pois códigos são válidos  
- Fornecedor B tem crédito zerado por códigos inválidos

```python
fornecedores = {
    "A": {"preco": 130.00, "credito": 25.00, "codigos_validos": True},
    "B": {"preco": 125.00, "credito": 30.00, "codigos_validos": False},
}

def aplicar_credito(fornecedor):
    return fornecedor["credito"] if fornecedor["codigos_validos"] else 0.0

resultados = {}

for f, dados in fornecedores.items():
    credito_efetivo = aplicar_credito(dados)
    custo_liquido = dados["preco"] - credito_efetivo
    resultados[f] = custo_liquido
    print(f"Fornecedor {f}: preço {dados['preco']}, crédito aplicado {credito_efetivo}, custo líquido {custo_liquido}")

vencedor = min(resultados, key=resultados.get)
print(f"\nFornecedor mais vantajoso: {vencedor} com custo líquido R$ {resultados[vencedor]:.2f}")
```

Saída real:

```
Fornecedor A: preço 130.0, crédito aplicado 25.0, custo líquido 105.0
Fornecedor B: preço 125.0, crédito aplicado 0.0, custo líquido 125.0

Fornecedor mais vantajoso: A com custo líquido R$ 105.00
```

Explicação: Apesar do preço bruto menor do fornecedor B, a desatualização dos códigos impede a apropriação do crédito, tornando-o menos vantajoso.

---

### 5. Escolha do fornecedor com análise combinada de CNAE, LC116, NBS e créditos em cenário de setores mistos  
Neste exercício, consideramos múltiplos códigos LC116 e créditos para setores mistos, somando os créditos para o custo líquido.

Decisão chave:  
- Para fornecedor A, somar créditos de ambos os códigos LC116  
- Para fornecedor B, crédito único  
- Calcular custo líquido total e comparar

```python
# Fornecedor A com múltiplos códigos LC116 e créditos
fornecedor_A = {
    "preco": 300.00,
    "cnae": "4711301",
    "lc116_creditos": {"0101": 20.00, "0202": 15.00}
}

# Fornecedor B com crédito único
fornecedor_B = {
    "preco": 290.00,
    "cnae": "6201501",
    "lc116_creditos": {"0101": 30.00}
}

def soma_creditos(creditos):
    return sum(creditos.values())

custo_liquido_A = fornecedor_A["preco"] - soma_creditos(fornecedor_A["lc116_creditos"])
custo_liquido_B = fornecedor_B["preco"] - soma_creditos(fornecedor_B["lc116_creditos"])

print(f"Fornecedor A: preço {fornecedor_A['preco']}, crédito total {soma_creditos(fornecedor_A['lc116_creditos'])}, custo líquido {custo_liquido_A}")
print(f"Fornecedor B: preço {fornecedor_B['preco']}, crédito total {soma_creditos(fornecedor_B['lc116_creditos'])}, custo líquido {custo_liquido_B}")

melhor = "A" if custo_liquido_A < custo_liquido_B else "B"
print(f"\nFornecedor mais vantajoso: {melhor} com custo líquido R$ {min(custo_liquido_A, custo_liquido_B):.2f}")
```

Saída real:

```
Fornecedor A: preço 300.0, crédito total 35.0, custo líquido 265.0
Fornecedor B: preço 290.0, crédito total 30.0, custo líquido 260.0

Fornecedor mais vantajoso: B com custo líquido R$ 260.00
```

Explicação: Apesar do fornecedor A ter múltiplos créditos somando mais, o preço bruto maior faz o custo líquido ficar um pouco acima do fornecedor B, que tem preço bruto menor e crédito único. A análise combinada permite decisão mais precisa considerando setores mistos e múltiplas apropriações.