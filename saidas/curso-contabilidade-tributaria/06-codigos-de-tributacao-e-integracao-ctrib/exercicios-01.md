## Exercícios — Códigos de Tributação e Integração: cTribNac e Outros

### 1. Vinculação Hierárquica e Comparação Tributária entre Fornecedores (intermediário)  
Você tem dois fornecedores com os seguintes dados:  
- Fornecedor A: CNAE 6201-5/01, código LC116 01.01, regime tributário Simples Nacional, preço R$ 100,00  
- Fornecedor B: CNAE 6201-5/01, código LC116 01.01, regime tributário Lucro Real, preço R$ 95,00  

Sabendo que o código cTribNac integra CNAE, LC116 e regime tributário para definir alíquotas e créditos, escreva um programa que:  
- Identifique o código cTribNac correto para cada fornecedor;  
- Calcule o crédito tributário estimado para cada um;  
- Calcule o custo líquido considerando o crédito (preço - crédito);  
- Exiba qual fornecedor oferece a melhor relação custo líquido e crédito tributário.  

Dado:  
- Para Simples Nacional, crédito é 10% do preço;  
- Para Lucro Real, crédito é 15% do preço;  
- Para o exercício, use como código cTribNac para Simples: "cTrib-SN-01" e para Lucro Real: "cTrib-LR-01".  

Saída esperada (exemplo):  
```
Fornecedor A: cTribNac cTrib-SN-01, crédito R$ 10,00, custo líquido R$ 90,00  
Fornecedor B: cTribNac cTrib-LR-01, crédito R$ 14,25, custo líquido R$ 80,75  
Melhor opção: Fornecedor B  
```

---

### 2. Validação Cruzada do Código cTribNac em Sistema Contábil (desafio)  
Implemente uma função de validação para um sistema contábil que receba CNAE, LC116 e regime tributário e retorne o código cTribNac correto.  

Use a tabela simplificada:  
| CNAE        | LC116 | Regime Tributário | cTribNac   | Alíquota ISS | Crédito % |  
|-------------|--------|-------------------|------------|--------------|-----------|  
| 6201-5/01   | 01.01  | Simples Nacional   | cTrib-SN-01| 2%           | 10%       |  
| 6201-5/01   | 01.01  | Lucro Real        | cTrib-LR-01| 2,5%         | 15%       |  
| 6204-0/00   | 01.02  | Lucro Real        | cTrib-LR-02| 3%           | 12%       |  

A função deve:  
- Validar se o CNAE é válido na tabela;  
- Validar se o código LC116 é compatível com o CNAE;  
- Validar se o regime está na tabela para a combinação;  
- Retornar o código cTribNac correto ou erro claro de validação;  
- Explicar o risco de erro caso o código cTribNac incorreto seja usado para cálculo tributário.  

Teste a função com os dados: CNAE 6201-5/01, LC116 01.01, regime Simples Nacional (válido) e CNAE 6204-0/00, LC116 01.01, regime Lucro Real (inválido).

---

### 3. Integração Hierárquica para Fornecedor de Consultoria em TI (intermediário)  
Um fornecedor de consultoria em TI tem os dados: CNAE 6204-0/00, código LC116 01.02 e código NBS 10.02.01, regime Lucro Real.  

Com base na integração CNAE → LC116 → NBS, determine:  
- O código cTribNac correto para este fornecedor;  
- O crédito tributário estimado se a alíquota ISS é 3% e o crédito é 12% do preço;  
- Calcule o custo líquido para um preço de R$ 200,00;  
- Explique como a atualização das tabelas oficiais impacta a validade do código cTribNac.  

Use o código cTribNac "cTrib-LR-02" para esta combinação.

---

### 4. Correção de Erro de Código cTribNac para Regime Simples Nacional (básico)  
Você recebeu o seguinte registro de fornecedor: CNAE 6201-5/01, código LC116 01.01, regime Simples Nacional, mas com código cTribNac incorreto "cTrib-LR-01" (válido apenas para Lucro Real).  

Explique:  
- Qual é o erro cometido;  
- Os impactos fiscais e de cálculo tributário que esse erro pode gerar;  
- Faça a correção do código cTribNac para o correto;  
- Mostre o cálculo do crédito tributário e custo líquido para preço R$ 150,00, antes e depois da correção, considerando 10% de crédito no Simples Nacional e 15% no Lucro Real.

---

### 5. Cálculo de Crédito Tributário e Custo Líquido com Atualização de Código cTribNac (desafio)  
Um sistema contábil precisa atualizar o código cTribNac para um fornecedor com CNAE 6201-5/01 e LC116 01.01 no regime Simples Nacional, pois o código antigo estava desatualizado ("cTrib-SN-00").  

Faça um programa que:  
- Atualize o código para o correto "cTrib-SN-01";  
- Calcule o impacto no crédito tributário e custo líquido para um preço de R$ 120,00, usando 10% de crédito;  
- Explique os riscos de usar um código cTribNac desatualizado em sistemas automáticos de cálculo tributário;  
- Apresente saída mostrando o código antigo, o código atualizado, o crédito antes e depois, e o custo líquido antes e depois da atualização.

---

## Soluções comentadas

### 1. Vinculação Hierárquica e Comparação Tributária entre Fornecedores

```python
# Dados dos fornecedores
fornecedores = [
    {"nome": "Fornecedor A", "CNAE": "6201-5/01", "LC116": "01.01", "regime": "Simples Nacional", "preco": 100.0},
    {"nome": "Fornecedor B", "CNAE": "6201-5/01", "LC116": "01.01", "regime": "Lucro Real", "preco": 95.0}
]

# Função para identificar código cTribNac e crédito
def identificar_cTribNac_credito(cnae, lc116, regime, preco):
    if regime == "Simples Nacional":
        cTribNac = "cTrib-SN-01"
        credito = preco * 0.10
    elif regime == "Lucro Real":
        cTribNac = "cTrib-LR-01"
        credito = preco * 0.15
    else:
        cTribNac = "cTrib-Unknown"
        credito = 0.0
    return cTribNac, credito

# Processar fornecedores e comparar
for fornecedor in fornecedores:
    cTribNac, credito = identificar_cTribNac_credito(fornecedor["CNAE"], fornecedor["LC116"], fornecedor["regime"], fornecedor["preco"])
    custo_liquido = fornecedor["preco"] - credito
    fornecedor["cTribNac"] = cTribNac
    fornecedor["credito"] = credito
    fornecedor["custo_liquido"] = custo_liquido

# Encontrar melhor opção (menor custo líquido)
melhor = min(fornecedores, key=lambda f: f["custo_liquido"])

# Exibir resultados
for f in fornecedores:
    print(f'{f["nome"]}: cTribNac {f["cTribNac"]}, crédito R$ {f["credito"]:.2f}, custo líquido R$ {f["custo_liquido"]:.2f}')
print(f"Melhor opção: {melhor['nome']}")
```

Saída real:

```
Fornecedor A: cTribNac cTrib-SN-01, crédito R$ 10.00, custo líquido R$ 90.00
Fornecedor B: cTribNac cTrib-LR-01, crédito R$ 14.25, custo líquido R$ 80.75
Melhor opção: Fornecedor B
```

**Decisão:** Usamos regime para determinar o código cTribNac e percentual de crédito, pois a alíquota e crédito variam com o regime. Isso permite comparar fornecedores considerando não só preço, mas também crédito tributário, conforme o objetivo do exercício.

---

### 2. Validação Cruzada do Código cTribNac em Sistema Contábil

```python
# Tabela simplificada
tabela = [
    {"CNAE": "6201-5/01", "LC116": "01.01", "regime": "Simples Nacional", "cTribNac": "cTrib-SN-01", "aliquota": 0.02, "credito_pct": 0.10},
    {"CNAE": "6201-5/01", "LC116": "01.01", "regime": "Lucro Real", "cTribNac": "cTrib-LR-01", "aliquota": 0.025, "credito_pct": 0.15},
    {"CNAE": "6204-0/00", "LC116": "01.02", "regime": "Lucro Real", "cTribNac": "cTrib-LR-02", "aliquota": 0.03, "credito_pct": 0.12},
]

def validar_codigo_cTribNac(cnae, lc116, regime):
    # Verifica se existe a combinação na tabela
    for registro in tabela:
        if registro["CNAE"] == cnae:
            if registro["LC116"] == lc116:
                if registro["regime"] == regime:
                    return registro["cTribNac"]
                else:
                    return f"Erro: Regime tributário '{regime}' inválido para CNAE {cnae} e LC116 {lc116}."
            else:
                # continua procurando no mesmo CNAE
                continue
    return f"Erro: Combinação CNAE {cnae} e LC116 {lc116} não encontrada."

# Testes
testes = [
    ("6201-5/01", "01.01", "Simples Nacional"),  # válido
    ("6204-0/00", "01.01", "Lucro Real"),        # inválido LC116 para CNAE
]

for cnae, lc116, regime in testes:
    resultado = validar_codigo_cTribNac(cnae, lc116, regime)
    print(f"Validação para CNAE={cnae}, LC116={lc116}, Regime={regime}: {resultado}")

print("\nRiscos de erro: Usar código cTribNac incorreto pode gerar cálculo errado do ISS e créditos, resultando em multas fiscais e perda de benefícios tributários.")
```

Saída real:

```
Validação para CNAE=6201-5/01, LC116=01.01, Regime=Simples Nacional: cTrib-SN-01
Validação para CNAE=6204-0/00, LC116=01.01, Regime=Lucro Real: Erro: Combinação CNAE 6204-0/00 e LC116 01.01 não encontrada.

Riscos de erro: Usar código cTribNac incorreto pode gerar cálculo errado do ISS e créditos, resultando em multas fiscais e perda de benefícios tributários.
```

**Decisão:** A função valida a existência da combinação, priorizando confirmação do CNAE e LC116 antes do regime, pois a incompatibilidade entre CNAE e LC116 é mais grave. O erro devolvido é claro para evitar uso incorreto do código cTribNac.

---

### 3. Integração Hierárquica para Fornecedor de Consultoria em TI

```python
# Dados do fornecedor
cnae = "6204-0/00"
lc116 = "01.02"
nbs = "10.02.01"
regime = "Lucro Real"
preco = 200.0

# Código cTribNac definido para esta combinação
cTribNac = "cTrib-LR-02"
aliquota_iss = 0.03  # 3%
credito_pct = 0.12   # 12%

# Calculo do crédito tributário
credito = preco * credito_pct

# Custo líquido
custo_liquido = preco - credito

# Explicação da atualização
explicacao = (
    "A atualização das tabelas oficiais é crucial para garantir que o código cTribNac "
    "reflete corretamente a legislação e as alíquotas vigentes. Sem atualização, "
    "o sistema pode usar códigos inválidos, causando erros no cálculo de tributos e créditos, "
    "levando a riscos fiscais e financeiros."
)

print(f"Código cTribNac: {cTribNac}")
print(f"Crédito tributário estimado: R$ {credito:.2f}")
print(f"Custo líquido: R$ {custo_liquido:.2f}")
print(f"Explicação: {explicacao}")
```

Saída real:

```
Código cTribNac: cTrib-LR-02
Crédito tributário estimado: R$ 24.00
Custo líquido: R$ 176.00
Explicação: A atualização das tabelas oficiais é crucial para garantir que o código cTribNac reflete corretamente a legislação e as alíquotas vigentes. Sem atualização, o sistema pode usar códigos inválidos, causando erros no cálculo de tributos e créditos, levando a riscos fiscais e financeiros.
```

**Decisão:** Aplicamos os dados fornecidos e explicamos o impacto da atualização das tabelas para reforçar a importância da manutenção dos dados para conformidade e exatidão fiscal.

---

### 4. Correção de Erro de Código cTribNac para Regime Simples Nacional

```python
# Dados iniciais
cnae = "6201-5/01"
lc116 = "01.01"
regime = "Simples Nacional"
codigo_incorreto = "cTrib-LR-01"  # incorreto para Simples Nacional
preco = 150.0

# Erro cometido
erro = (
    "Erro: Código cTribNac 'cTrib-LR-01' é válido apenas para regime Lucro Real. "
    "Usá-lo para Simples Nacional causa cálculo errado de tributos e créditos."
)

# Código correto para Simples Nacional
codigo_correto = "cTrib-SN-01"

# Créditos antes e depois
credito_antes = preco * 0.15  # 15% do Lucro Real (incorreto)
credito_depois = preco * 0.10  # 10% do Simples Nacional (correto)

# Custos líquidos
custo_antes = preco - credito_antes
custo_depois = preco - credito_depois

print(erro)
print(f"Código corrigido: {codigo_correto}")
print(f"Crédito antes da correção: R$ {credito_antes:.2f}")
print(f"Custo líquido antes da correção: R$ {custo_antes:.2f}")
print(f"Crédito após correção: R$ {credito_depois:.2f}")
print(f"Custo líquido após correção: R$ {custo_depois:.2f}")
```

Saída real:

```
Erro: Código cTribNac 'cTrib-LR-01' é válido apenas para regime Lucro Real. Usá-lo para Simples Nacional causa cálculo errado de tributos e créditos.
Código corrigido: cTrib-SN-01
Crédito antes da correção: R$ 22.50
Custo líquido antes da correção: R$ 127.50
Crédito após correção: R$ 15.00
Custo líquido após correção: R$ 135.00
```

**Decisão:** O erro levou a superestimar o crédito tributário, o que pode causar declaração incorreta e riscos fiscais. Corrigir o código ajusta o crédito e custo líquido, evitando problemas fiscais e financeiros.

---

### 5. Cálculo de Crédito Tributário e Custo Líquido com Atualização de Código cTribNac

```python
# Dados
cnae = "6201-5/01"
lc116 = "01.01"
regime = "Simples Nacional"
codigo_antigo = "cTrib-SN-00"
codigo_novo = "cTrib-SN-01"
preco = 120.0
credito_pct = 0.10  # 10% para Simples Nacional

# Créditos e custos antes da atualização
credito_antigo = preco * 0.05  # Vamos supor que código antigo aplicava crédito errado de 5%
custo_liquido_antigo = preco - credito_antigo

# Créditos e custos após atualização
credito_novo = preco * credito_pct
custo_liquido_novo = preco - credito_novo

# Riscos de código desatualizado
riscos = (
    "O uso de código cTribNac desatualizado pode levar a cálculo incorreto de crédito, "
    "sub ou superestimando o valor, acarretando multas, passivos fiscais e decisões equivocadas."
)

print(f"Código antigo: {codigo_antigo}")
print(f"Código atualizado: {codigo_novo}")
print(f"Crédito antes da atualização: R$ {credito_antigo:.2f}")
print(f"Custo líquido antes da atualização: R$ {custo_liquido_antigo:.2f}")
print(f"Crédito após atualização: R$ {credito_novo:.2f}")
print(f"Custo líquido após atualização: R$ {custo_liquido_novo:.2f}")
print(f"Riscos da demora na atualização: {riscos}")
```

Saída real:

```
Código antigo: cTrib-SN-00
Código atualizado: cTrib-SN-01
Crédito antes da atualização: R$ 6.00
Custo líquido antes da atualização: R$ 114.00
Crédito após atualização: R$ 12.00
Custo líquido após atualização: R$ 108.00
Riscos da demora na atualização: O uso de código cTribNac desatualizado pode levar a cálculo incorreto de crédito, sub ou superestimando o valor, acarretando multas, passivos fiscais e decisões equivocadas.
```

**Decisão:** Demonstra o impacto direto no cálculo do crédito e custo líquido pelo uso de código desatualizado e reforça a necessidade de manutenção das tabelas para evitar erros fiscais e financeiros.

---

Esses exercícios combinam conceitos do capítulo com regras básicas de crédito tributário e integração dos códigos, permitindo desenvolvimento prático e análise crítica para um sistema de comparação tributária entre fornecedores.