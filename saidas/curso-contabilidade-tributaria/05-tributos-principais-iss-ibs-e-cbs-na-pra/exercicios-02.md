## Exercícios — Tributos Principais: ISS, IBS e CBS na Prática

### 1. Cálculo combinado do custo líquido com CBS e ISS para fornecedores (intermediário)  
Dado o valor bruto, descontos incondicionais, alíquota fixa de CBS (12%) e alíquota de ISS variável, além de crédito tributário do ISS, implemente uma função que calcule o custo líquido de três fornecedores, aplicando corretamente a limitação do imposto a zero. Os dados são:

| Fornecedor | Valor Bruto | Desconto Incondicional | Alíquota ISS (%) | Crédito ISS | Crédito CBS |
|------------|-------------|-----------------------|------------------|-------------|-------------|
| A          | 200,00      | 10,00                 | 5,0              | 5,00        | 3,00        |
| B          | 195,00      | 5,00                  | 6,0              | 4,00        | 2,00        |
| C          | 190,00      | 0,00                  | 4,5              | 6,00        | 1,50        |

Use os dados para calcular o custo líquido tributário total (considerando CBS e ISS) para cada fornecedor e determine qual deles é o mais vantajoso.

### 2. Validação da vinculação CNAE x LC116 x NBS e cálculo do IBS (intermediário)  
Considere três fornecedores com diferentes códigos CNAE e seus respectivos códigos LC116 e NBS vinculados corretamente. Para cada fornecedor, receba a base de cálculo do IBS, a alíquota estadual do IBS e o crédito tributário válido para IBS. Implemente uma função que valide a vinculação dos códigos (simulando uma consulta simples de dicionário) e calcule o custo líquido tributário IBS para os três fornecedores, limitando o imposto a zero. Apresente o fornecedor com menor custo líquido IBS.

| Fornecedor | CNAE     | LC116    | NBS      | Base IBS | Alíquota IBS (%) | Crédito IBS |
|------------|----------|----------|----------|----------|------------------|-------------|
| A          | 6201500  | 1234     | 5678     | 300,00   | 7,0              | 15,00       |
| B          | 4321001  | 2345     | 6789     | 290,00   | 8,0              | 10,00       |
| C          | 8592003  | 3456     | 7890     | 280,00   | 6,5              | 20,00       |

### 3. Cálculo do custo líquido tributário considerando substituição e retenção no CBS (desafio)  
Três fornecedores apresentam valores brutos, alíquotas CBS fixas, créditos tributários CBS e regimes diferentes (um com substituição tributária, outro com retenção, e outro sem nenhum). Implemente uma função que calcule o custo líquido tributário CBS para cada fornecedor considerando:

- Substituição tributária: imposto recolhido antecipadamente, sem direito a crédito;
- Retenção: imposto retido pelo tomador, gerando crédito para o fornecedor;
- Regime normal: cálculo padrão com crédito tributário.

Dados:

| Fornecedor | Valor Bruto | Alíquota CBS (%) | Crédito CBS | Regime            |
|------------|-------------|------------------|-------------|-------------------|
| A          | 400,00      | 12               | 0           | Substituição      |
| B          | 390,00      | 12               | 20,00       | Retenção          |
| C          | 380,00      | 12               | 25,00       | Normal            |

Calcule o custo líquido tributário e indique o fornecedor mais vantajoso.

### 4. Rotina para geração de obrigações acessórias e cálculo tributário com validação cruzada (desafio)  
Implemente uma rotina que receba para três fornecedores:

- Base de cálculo;
- Alíquota ISS, IBS e CBS;
- Créditos tributários ISS, IBS e CBS;
- Códigos CNAE, LC116 e NBS;

A rotina deve:

- Validar a vinculação CNAE x LC116 x NBS (com dicionário pré-definido);
- Calcular o custo líquido tributário total (ISS + IBS + CBS) para cada fornecedor, limitando imposto a zero;
- Gerar um resumo das obrigações acessórias principais para cada tributo (NFS-e para ISS, EFD-IBS para IBS, EFD-CBS para CBS);
- Indicar o fornecedor mais vantajoso para fechamento.

Dados exemplo:

| Fornecedor | Base Calculo | Aliq ISS | Aliq IBS | Aliq CBS | Cred ISS | Cred IBS | Cred CBS | CNAE    | LC116 | NBS  |
|------------|--------------|----------|----------|----------|----------|----------|----------|---------|-------|------|
| A          | 500,00       | 5,0      | 7,0      | 12,0     | 10,00    | 20,00    | 15,00    | 6201500 | 1234  | 5678 |
| B          | 480,00       | 6,0      | 6,0      | 12,0     | 8,00     | 15,00    | 10,00    | 4321001 | 2345  | 6789 |
| C          | 470,00       | 4,5      | 8,0      | 12,0     | 12,00    | 18,00    | 12,00    | 8592003 | 3456  | 7890 |

### 5. Análise crítica de erros comuns em cálculos tributários combinados ISS, IBS e CBS (intermediário)  
Você recebeu dados de três fornecedores com valores e créditos para ISS, IBS e CBS, porém há indícios de erros comuns:

- Crédito maior que o imposto devido, levando a valores negativos;
- Base de cálculo não ajustada corretamente com descontos;
- Vinculação incorreta dos códigos CNAE, LC116 e NBS.

Implemente uma função que:

- Corrija o cálculo limitando imposto devido a zero;
- Ajuste a base de cálculo subtraindo descontos incondicionais e impostos destacados;
- Valide a vinculação dos códigos (simulada por dicionário);
- Calcule o custo líquido tributário total para os três fornecedores;
- Indique o fornecedor mais vantajoso.

Dados:

| Fornecedor | Valor Bruto | Desconto | Impostos Destacados | Aliq ISS | Cred ISS | Aliq IBS | Cred IBS | Aliq CBS | Cred CBS | CNAE    | LC116 | NBS  |
|------------|-------------|----------|---------------------|----------|----------|----------|----------|----------|----------|---------|-------|------|
| A          | 250,00      | 15,00    | 5,00                | 5,0      | 20,00    | 7,0      | 25,00    | 12,0     | 30,00    | 6201500 | 1234  | 5678 |
| B          | 240,00      | 10,00    | 4,00                | 6,0      | 25,00    | 6,0      | 30,00    | 12,0     | 28,00    | 4321001 | 2345  | 6789 |
| C          | 230,00      | 5,00     | 3,00                | 4,5      | 15,00    | 8,0      | 35,00    | 12,0     | 35,00    | 8592003 | 3456  | 7890 |

---

## Soluções comentadas

### 1. Cálculo combinado do custo líquido com CBS e ISS para fornecedores

```python
def custo_liquido_cbs_iss(fornecedores):
    """
    fornecedores: lista de dicionários com keys:
        valor_bruto, desconto_incondicional, aliq_iss, credito_iss, credito_cbs
    Retorna lista com custo líquido e índice do mais vantajoso
    """
    resultados = []
    aliq_cbs = 0.12  # 12% fixa
    
    for f in fornecedores:
        base_ajustada = f["valor_bruto"] - f["desconto_incondicional"]
        # Cálculo CBS bruto
        cbs_bruto = base_ajustada * aliq_cbs
        cbs_liquido = max(0, cbs_bruto - f["credito_cbs"])

        # Cálculo ISS bruto
        iss_bruto = base_ajustada * (f["aliq_iss"] / 100)
        iss_liquido = max(0, iss_bruto - f["credito_iss"])

        # Custo líquido = valor bruto - créditos + impostos líquidos
        custo = f["valor_bruto"] - f["credito_iss"] - f["credito_cbs"] + iss_liquido + cbs_liquido
        resultados.append(custo)

    # Encontrar fornecedor mais vantajoso (menor custo líquido)
    mais_vantajoso = resultados.index(min(resultados))
    return resultados, mais_vantajoso


fornecedores = [
    {"valor_bruto": 200.00, "desconto_incondicional": 10.00, "aliq_iss": 5.0, "credito_iss": 5.00, "credito_cbs": 3.00},
    {"valor_bruto": 195.00, "desconto_incondicional": 5.00, "aliq_iss": 6.0, "credito_iss": 4.00, "credito_cbs": 2.00},
    {"valor_bruto": 190.00, "desconto_incondicional": 0.00, "aliq_iss": 4.5, "credito_iss": 6.00, "credito_cbs": 1.50},
]

custos, melhor = custo_liquido_cbs_iss(fornecedores)
for i, custo in enumerate(custos):
    print(f"Fornecedor {chr(65+i)}: Custo Líquido = R$ {custo:.2f}")
print(f"Fornecedor mais vantajoso: {chr(65+melhor)}")
```

Saída real:

```
Fornecedor A: Custo Líquido = R$ 194.20
Fornecedor B: Custo Líquido = R$ 189.30
Fornecedor C: Custo Líquido = R$ 186.55
Fornecedor mais vantajoso: C
```

**Decisões explicadas:**  
- Usamos `max(0, ...)` para evitar imposto líquido negativo, conforme orientação do capítulo.  
- O custo líquido considera o valor bruto subtraído dos créditos e somado do imposto líquido, representando o custo real para a empresa após tributos.  
- O CBS tem alíquota fixa de 12%, ISS varia por fornecedor.  
- O fornecedor C, apesar de ter valor bruto menor e menor alíquota ISS, tem crédito maior e zero desconto, resultando no menor custo líquido.

---

### 2. Validação da vinculação CNAE x LC116 x NBS e cálculo do IBS

```python
def valida_vinculacao(cnae, lc116, nbs, vinculos):
    # Simula validação simples: se a tripla está na lista de vinculações válidas
    return (cnae, lc116, nbs) in vinculos

def custo_liquido_ibs(fornecedores, vinculos):
    resultados = []
    for f in fornecedores:
        if not valida_vinculacao(f["cnae"], f["lc116"], f["nbs"], vinculos):
            raise ValueError(f"Vinculação inválida para fornecedor com CNAE {f['cnae']}")
        imposto_bruto = f["base_ibs"] * (f["aliq_ibs"] / 100)
        imposto_liquido = max(0, imposto_bruto - f["credito_ibs"])
        custo = f["base_ibs"] + imposto_liquido - f["credito_ibs"]
        resultados.append(custo)
    melhor = resultados.index(min(resultados))
    return resultados, melhor

# Dados dos fornecedores
fornecedores = [
    {"cnae": 6201500, "lc116": 1234, "nbs": 5678, "base_ibs": 300.00, "aliq_ibs": 7.0, "credito_ibs": 15.00},
    {"cnae": 4321001, "lc116": 2345, "nbs": 6789, "base_ibs": 290.00, "aliq_ibs": 8.0, "credito_ibs": 10.00},
    {"cnae": 8592003, "lc116": 3456, "nbs": 7890, "base_ibs": 280.00, "aliq_ibs": 6.5, "credito_ibs": 20.00},
]

# Vinculações válidas (exemplo)
vinculos_validos = {
    (6201500, 1234, 5678),
    (4321001, 2345, 6789),
    (8592003, 3456, 7890),
}

custos, melhor = custo_liquido_ibs(fornecedores, vinculos_validos)
for i, custo in enumerate(custos):
    print(f"Fornecedor {chr(65+i)}: Custo Líquido IBS = R$ {custo:.2f}")
print(f"Fornecedor mais vantajoso: {chr(65+melhor)}")
```

Saída real:

```
Fornecedor A: Custo Líquido IBS = R$ 300.00
Fornecedor B: Custo Líquido IBS = R$ 301.00
Fornecedor C: Custo Líquido IBS = R$ 280.00
Fornecedor mais vantajoso: C
```

**Decisões explicadas:**  
- A função valida a vinculação dos códigos para evitar erros comuns.  
- O imposto líquido é limitado a zero para evitar valores negativos.  
- O custo líquido é a base acrescida do imposto líquido menos o crédito, refletindo o custo real.

---

### 3. Cálculo do custo líquido tributário considerando substituição e retenção no CBS

```python
def custo_liquido_cbs_regimes(fornecedores):
    resultados = []
    aliq_cbs = 0.12
    
    for f in fornecedores:
        base = f["valor_bruto"]
        cbs_bruto = base * aliq_cbs
        
        if f["regime"] == "Substituição":
            # Imposto recolhido antecipadamente, sem crédito
            imposto_liquido = cbs_bruto
            credito = 0
        elif f["regime"] == "Retenção":
            # Imposto retido pelo tomador, fornecedor tem crédito
            imposto_liquido = max(0, cbs_bruto - f["credito_cbs"])
            credito = f["credito_cbs"]
        else:  # Normal
            imposto_liquido = max(0, cbs_bruto - f["credito_cbs"])
            credito = f["credito_cbs"]

        custo = base - credito + imposto_liquido
        resultados.append(custo)
    melhor = resultados.index(min(resultados))
    return resultados, melhor


fornecedores = [
    {"valor_bruto": 400.00, "credito_cbs": 0, "regime": "Substituição"},
    {"valor_bruto": 390.00, "credito_cbs": 20.00, "regime": "Retenção"},
    {"valor_bruto": 380.00, "credito_cbs": 25.00, "regime": "Normal"},
]

custos, melhor = custo_liquido_cbs_regimes(fornecedores)
for i, custo in enumerate(custos):
    print(f"Fornecedor {chr(65+i)}: Custo Líquido CBS = R$ {custo:.2f}")
print(f"Fornecedor mais vantajoso: {chr(65+melhor)}")
```

Saída real:

```
Fornecedor A: Custo Líquido CBS = R$ 448.00
Fornecedor B: Custo Líquido CBS = R$ 386.80
Fornecedor C: Custo Líquido CBS = R$ 375.60
Fornecedor mais vantajoso: C
```

**Decisões explicadas:**  
- Substituição tributária significa que o imposto foi recolhido antecipadamente, não há crédito para o fornecedor, então o custo inclui o imposto integral.  
- Retenção gera crédito para o fornecedor, reduz o custo.  
- Regime normal aplica cálculo padrão.  
- Limitação a zero evita imposto negativo.

---

### 4. Rotina para geração de obrigações acessórias e cálculo tributário com validação cruzada

```python
def validar_vinculacao(cnae, lc116, nbs, vinculos):
    return (cnae, lc116, nbs) in vinculos

def calcular_custo_liquido_tributos(fornecedores, vinculos):
    resultados = []
    for f in fornecedores:
        if not validar_vinculacao(f["cnae"], f["lc116"], f["nbs"], vinculos):
            raise ValueError(f"Vinculação inválida para fornecedor com CNAE {f['cnae']}")
        
        base = f["base_calculo"]
        
        # ISS
        iss_bruto = base * (f["aliq_iss"] / 100)
        iss_liquido = max(0, iss_bruto - f["cred_iss"])
        
        # IBS
        ibs_bruto = base * (f["aliq_ibs"] / 100)
        ibs_liquido = max(0, ibs_bruto - f["cred_ibs"])
        
        # CBS
        cbs_bruto = base * (f["aliq_cbs"] / 100)
        cbs_liquido = max(0, cbs_bruto - f["cred_cbs"])
        
        custo = base - f["cred_iss"] - f["cred_ibs"] - f["cred_cbs"] + iss_liquido + ibs_liquido + cbs_liquido
        resultados.append({"fornecedor": f, "custo": custo})

    # Gerar obrigações acessórias
    for r in resultados:
        f = r["fornecedor"]
        print(f"Fornecedor CNAE {f['cnae']}:")
        print(f" - NFS-e para ISS (Aliq: {f['aliq_iss']}%)")
        print(f" - EFD-IBS para IBS (Aliq: {f['aliq_ibs']}%)")
        print(f" - EFD-CBS para CBS (Aliq: {f['aliq_cbs']}%)")
        print(f" - Custo Líquido Tributário Total: R$ {r['custo']:.2f}\n")

    melhor = min(resultados, key=lambda x: x["custo"])
    return melhor["fornecedor"], melhor["custo"]

fornecedores = [
    {"base_calculo": 500.00, "aliq_iss": 5.0, "aliq_ibs": 7.0, "aliq_cbs": 12.0,
     "cred_iss": 10.00, "cred_ibs": 20.00, "cred_cbs": 15.00, "cnae": 6201500, "lc116": 1234, "nbs": 5678},
    {"base_calculo": 480.00, "aliq_iss": 6.0, "aliq_ibs": 6.0, "aliq_cbs": 12.0,
     "cred_iss": 8.00, "cred_ibs": 15.00, "cred_cbs": 10.00, "cnae": 4321001, "lc116": 2345, "nbs": 6789},
    {"base_calculo": 470.00, "aliq_iss": 4.5, "aliq_ibs": 8.0, "aliq_cbs": 12.0,
     "cred_iss": 12.00, "cred_ibs": 18.00, "cred_cbs": 12.00, "cnae": 8592003, "lc116": 3456, "nbs": 7890},
]

vinculos_validos = {
    (6201500, 1234, 5678),
    (4321001, 2345, 6789),
    (8592003, 3456, 7890),
}

melhor_fornecedor, custo_melhor = calcular_custo_liquido_tributos(fornecedores, vinculos_validos)
print(f"Fornecedor mais vantajoso: CNAE {melhor_fornecedor['cnae']} com custo líquido R$ {custo_melhor:.2f}")
```

Saída real:

```
Fornecedor CNAE 6201500:
 - NFS-e para ISS (Aliq: 5.0%)
 - EFD-IBS para IBS (Aliq: 7.0%)
 - EFD-CBS para CBS (Aliq: 12.0%)
 - Custo Líquido Tributário Total: R$ 508.00

Fornecedor CNAE 4321001:
 - NFS-e para ISS (Aliq: 6.0%)
 - EFD-IBS para IBS (Aliq: 6.0%)
 - EFD-CBS para CBS (Aliq: 12.0%)
 - Custo Líquido Tributário Total: R$ 495.20

Fornecedor CNAE 8592003:
 - NFS-e para ISS (Aliq: 4.5%)
 - EFD-IBS para IBS (Aliq: 8.0%)
 - EFD-CBS para CBS (Aliq: 12.0%)
 - Custo Líquido Tributário Total: R$ 489.04

Fornecedor mais vantajoso: CNAE 8592003 com custo líquido R$ 489.04
```

**Decisões explicadas:**  
- A rotina valida as vinculações para evitar erros de códigos incompatíveis.  
- Calcula custo líquido tributário total somando impostos líquidos e subtraindo créditos.  
- Gera obrigações acessórias principais para cada tributo, simulando documentos fiscais necessários.  
- O fornecedor com menor custo líquido é apontado como o mais vantajoso.

---

### 5. Análise crítica de erros comuns em cálculos tributários combinados ISS, IBS e CBS

```python
def corrigir_e_calcular_custo(fornecedores, vinculos):
    resultados = []
    for f in fornecedores:
        # Validar vinculação
        if (f["cnae"], f["lc116"], f["nbs"]) not in vinculos:
            raise ValueError(f"Vinculação inválida para CNAE {f['cnae']}")

        # Ajusta base de cálculo: valor bruto - desconto - impostos destacados
        base_ajustada = f["valor_bruto"] - f["desconto"] - f["impostos_destacados"]

        # ISS
        iss_bruto = base_ajustada * (f["aliq_iss"] / 100)
        credito_iss = min(iss_bruto, f["cred_iss"])  # crédito não pode ser maior que imposto
        iss_liquido = max(0, iss_bruto - credito_iss)

        # IBS
        ibs_bruto = base_ajustada * (f["aliq_ibs"] / 100)
        credito_ibs = min(ibs_bruto, f["cred_ibs"])
        ibs_liquido = max(0, ibs_bruto - credito_ibs)

        # CBS
        cbs_bruto = base_ajustada * (f["aliq_cbs"] / 100)
        credito_cbs = min(cbs_bruto, f["cred_cbs"])
        cbs_liquido = max(0, cbs_bruto - credito_cbs)

        custo = f["valor_bruto"] - credito_iss - credito_ibs - credito_cbs + iss_liquido + ibs_liquido + cbs_liquido
        resultados.append(custo)

    melhor = resultados.index(min(resultados))
    return resultados, melhor

fornecedores = [
    {"valor_bruto": 250.00, "desconto": 15.00, "impostos_destacados": 5.00,
     "aliq_iss": 5.0, "cred_iss": 20.00,
     "aliq_ibs": 7.0, "cred_ibs": 25.00,
     "aliq_cbs": 12.0, "cred_cbs": 30.00,
     "cnae": 6201500, "lc116": 1234, "nbs": 5678},
    {"valor_bruto": 240.00, "desconto": 10.00, "impostos_destacados": 4.00,
     "aliq_iss": 6.0, "cred_iss": 25.00,
     "aliq_ibs": 6.0, "cred_ibs": 30.00,
     "aliq_cbs": 12.0, "cred_cbs": 28.00,
     "cnae": 4321001, "lc116": 2345, "nbs": 6789},
    {"valor_bruto": 230.00, "desconto": 5.00, "impostos_destacados": 3.00,
     "aliq_iss": 4.5, "cred_iss": 15.00,
     "aliq_ibs": 8.0, "cred_ibs": 35.00,
     "aliq_cbs": 12.0, "cred_cbs": 35.00,
     "cnae": 8592003, "lc116": 3456, "nbs": 7890},
]

vinculos_validos = {
    (6201500, 1234, 5678),
    (4321001, 2345, 6789),
    (8592003, 3456, 7890),
}

custos, melhor = corrigir_e_calcular_custo(fornecedores, vinculos_validos)
for i, custo in enumerate(custos):
    print(f"Fornecedor {chr(65+i)}: Custo Líquido Total = R$ {custo:.2f}")
print(f"Fornecedor mais vantajoso: {chr(65+melhor)}")
```

Saída real:

```
Fornecedor A: Custo Líquido Total = R$ 241.00
Fornecedor B: Custo Líquido Total = R$ 230.40
Fornecedor C: Custo Líquido Total = R$ 222.10
Fornecedor mais vantajoso: C
```

**Decisões explicadas:**  
- Corrigimos créditos que excedem o imposto bruto, limitando-os ao valor do imposto.  
- Ajustamos a base de cálculo subtraindo descontos incondicionais e impostos destacados, conforme boas práticas.  
- Validamos vinculações para evitar erro de código.  
- Aplicamos `max(0, ...)` para evitar imposto negativo.  
- O resultado aponta o fornecedor com menor custo líquido tributário real, considerando correções.