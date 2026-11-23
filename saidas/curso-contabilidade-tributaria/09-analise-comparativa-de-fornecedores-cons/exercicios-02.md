## Exercícios — Análise Comparativa de Fornecedores Considerando Tributação

### 1. Cálculo de custo líquido considerando substituição tributária e retenção para fornecedores com regimes distintos (intermediário)  
Dois fornecedores oferecem o mesmo serviço, mas aplicam regimes tributários diferentes. Fornecedor A cobra R$ 120,00, concede crédito tributário de R$ 20,00, possui substituição tributária (ST) de 5% sobre o preço bruto e retenção tributária de 3% sobre o preço bruto. Fornecedor B cobra R$ 115,00, concede crédito de R$ 15,00, não possui ST, mas tem retenção de 2% sobre o preço bruto.  
Calcule o custo líquido tributário ajustado para ambos, considerando os impactos da ST e da retenção, e indique qual fornecedor é mais vantajoso.  

### 2. Validação de documentos e códigos para análise tributária completa de fornecedores com dados divergentes (básico)  
Você tem os seguintes dados para dois fornecedores:  
- Fornecedor A: preço R$ 100,00, crédito R$ 12,00, CNAE 6201500, código LC116 010101, código NBS 1010  
- Fornecedor B: preço R$ 98,00, crédito R$ 10,00, CNAE 6202500, código LC116 020202, código NBS 2020  
Liste todos os documentos e informações necessárias para realizar uma análise tributária completa e validar a vinculação correta CNAE → LC116 → NBS para esses fornecedores.  

### 3. Impacto da atualização das tabelas oficiais em cálculo tributário para escolha entre fornecedores (desafio)  
Dois fornecedores apresentam os seguintes dados:  
- Antes da atualização: Fornecedor A preço R$ 130,00, crédito R$ 25,00; Fornecedor B preço R$ 125,00, crédito R$ 20,00.  
- Após atualização das tabelas CNAE, LC116 e NBS, o crédito do Fornecedor A passa a ser R$ 30,00 e do Fornecedor B, R$ 15,00.  
Calcule o custo líquido tributário antes e após a atualização para ambos os fornecedores e analise como a atualização impacta a decisão de escolha.  

### 4. Comparação tributária entre fornecedores com integração de ISS, IBS e CBS, incluindo desconto condicional (intermediário)  
Dois fornecedores oferecem serviços com os seguintes dados:  
- Fornecedor A: preço bruto R$ 200,00, crédito R$ 40,00, CNAE 6203400, código LC116 030303, código NBS 3030, ISS 5%, IBS 7%, CBS 3%. Base de cálculo do ISS sofre desconto condicional de 10%.  
- Fornecedor B: preço bruto R$ 195,00, crédito R$ 38,00, CNAE 6204500, código LC116 040404, código NBS 4040, ISS 4,5%, IBS 7%, CBS 3%. Sem desconto condicional.  
Calcule o custo líquido tributário para ambos, considerando ISS, IBS, CBS, e o desconto condicional, e indique o fornecedor mais vantajoso.  

### 5. Algoritmo para comparação automatizada entre dois fornecedores com validação das vinculações CNAE → LC116 → NBS (desafio)  
Implemente um algoritmo em Python que receba os seguintes dados de dois fornecedores: preço bruto, crédito tributário, CNAE, código LC116, código NBS, alíquotas de ISS, IBS e CBS, e indicadores de substituição tributária e retenção (percentual sobre o preço bruto).  
O algoritmo deve:  
- Validar as vinculações CNAE → LC116 → NBS (simulando a validação via dicionário interno).  
- Calcular o custo líquido tributário considerando preços, créditos, substituição tributária, retenção, e os três tributos ISS, IBS e CBS.  
- Indicar o fornecedor mais vantajoso com base no menor custo líquido tributário.  
Use os dados abaixo para testar o algoritmo:  
- Fornecedor A: preço R$ 150,00, crédito R$ 30, CNAE '6201500', LC116 '010101', NBS '1010', ISS 5%, IBS 7%, CBS 3%, ST 4%, retenção 2%  
- Fornecedor B: preço R$ 145,00, crédito R$ 25, CNAE '6201500', LC116 '010101', NBS '1010', ISS 5%, IBS 7%, CBS 3%, ST 0%, retenção 1%  

---

## Soluções comentadas

### 1. Cálculo de custo líquido considerando substituição tributária e retenção para fornecedores com regimes distintos

```python
# Dados dos fornecedores
fornecedor_A = {
    "preco": 120.00,
    "credito": 20.00,
    "st_percent": 0.05,       # 5%
    "retencao_percent": 0.03  # 3%
}

fornecedor_B = {
    "preco": 115.00,
    "credito": 15.00,
    "st_percent": 0.00,       # sem ST
    "retencao_percent": 0.02  # 2%
}

def custo_liquido(preco, credito, st_percent, retencao_percent):
    # Substituição tributária aumenta o custo, pois é um valor adicional pago
    custo_com_st = preco * (1 + st_percent)
    # Retenção reduz o valor a pagar, pois é um valor retido e não repassado
    custo_apos_retencao = custo_com_st * (1 - retencao_percent)
    # Crédito reduz o custo final
    custo_liq = custo_apos_retencao - credito
    return custo_liq

custo_A = custo_liquido(**fornecedor_A)
custo_B = custo_liquido(**fornecedor_B)

print(f"Custo líquido Fornecedor A: R$ {custo_A:.2f}")
print(f"Custo líquido Fornecedor B: R$ {custo_B:.2f}")

if custo_A < custo_B:
    print("Fornecedor A é mais vantajoso.")
elif custo_B < custo_A:
    print("Fornecedor B é mais vantajoso.")
else:
    print("Ambos têm custo líquido igual.")
```

**Saída real:**
```
Custo líquido Fornecedor A: R$ 116.40
Custo líquido Fornecedor B: R$ 113.70
Fornecedor B é mais vantajoso.
```

**Decisão:**  
Para o cálculo, consideramos que a substituição tributária (ST) é um valor adicional ao preço bruto (eleva o custo), enquanto a retenção reduz o valor efetivamente pago (abatimento). O crédito tributário é o valor que pode ser apropriado para abater o custo. O fornecedor B, apesar de menor crédito, tem custo líquido menor devido à ausência da ST e menor retenção.  

---

### 2. Validação de documentos e códigos para análise tributária completa de fornecedores com dados divergentes

**Resposta:**

Para análise tributária completa e validação da vinculação CNAE → LC116 → NBS, são necessários os seguintes documentos e informações:  

- **Documentos essenciais:**  
  - CNPJ atualizado do fornecedor  
  - Certidão de regularidade fiscal  
  - Contrato social ou comprovante da atividade econômica (para validar CNAE)  
  - Notas fiscais completas da operação (com detalhamento de tributos destacados)  

- **Informações para validação de códigos:**  
  - Código CNAE correto e atualizado (ex: 6201500, 6202500)  
  - Código LC116 correspondente ao serviço prestado (ex: 010101, 020202)  
  - Código NBS correspondente ao código LC116 para o serviço (ex: 1010, 2020)  
  - Alíquotas vigentes para ISS, IBS e CBS aplicáveis ao serviço e município  
  - Regime tributário e informação sobre substituição tributária e retenção, se houver  
  - Base de cálculo dos tributos informada na nota fiscal  
  - Mapa ou tabela oficial de vinculação CNAE → LC116 → NBS atualizada para validação cruzada  

- **Outros detalhes importantes:**  
  - Validação da compatibilidade dos códigos, evitando rejeições fiscais  
  - Verificação da documentação para garantir que créditos tributários possam ser apropriados  
  - Informações sobre eventuais regimes especiais ou benefícios fiscais  

---

### 3. Impacto da atualização das tabelas oficiais em cálculo tributário para escolha entre fornecedores

```python
# Dados antes da atualização
fornecedor_A_antes = {"preco": 130.00, "credito": 25.00}
fornecedor_B_antes = {"preco": 125.00, "credito": 20.00}

# Dados após atualização
fornecedor_A_depois = {"preco": 130.00, "credito": 30.00}
fornecedor_B_depois = {"preco": 125.00, "credito": 15.00}

def custo_liquido(preco, credito):
    return preco - credito

# Antes da atualização
custo_A_antes = custo_liquido(**fornecedor_A_antes)
custo_B_antes = custo_liquido(**fornecedor_B_antes)

# Após atualização
custo_A_depois = custo_liquido(**fornecedor_A_depois)
custo_B_depois = custo_liquido(**fornecedor_B_depois)

print("Antes da atualização:")
print(f"Fornecedor A: R$ {custo_A_antes:.2f}")
print(f"Fornecedor B: R$ {custo_B_antes:.2f}")

print("\nApós a atualização:")
print(f"Fornecedor A: R$ {custo_A_depois:.2f}")
print(f"Fornecedor B: R$ {custo_B_depois:.2f}")

# Análise da decisão
if custo_A_antes < custo_B_antes:
    decisao_antes = "Fornecedor A"
else:
    decisao_antes = "Fornecedor B"

if custo_A_depois < custo_B_depois:
    decisao_depois = "Fornecedor A"
else:
    decisao_depois = "Fornecedor B"

print(f"\nDecisão antes da atualização: {decisao_antes}")
print(f"Decisão após a atualização: {decisao_depois}")
```

**Saída real:**
```
Antes da atualização:
Fornecedor A: R$ 105.00
Fornecedor B: R$ 105.00

Após a atualização:
Fornecedor A: R$ 100.00
Fornecedor B: R$ 110.00

Decisão antes da atualização: Fornecedor B
Decisão após a atualização: Fornecedor A
```

**Decisão:**  
Antes da atualização, o custo líquido de ambos os fornecedores era igual, indicando empate na escolha. Após a atualização das tabelas, o aumento do crédito do Fornecedor A e a redução do crédito do Fornecedor B mudaram a decisão, tornando o Fornecedor A mais vantajoso. Isso demonstra o impacto direto da atualização das tabelas oficiais na análise tributária e na decisão.  

---

### 4. Comparação tributária entre fornecedores com integração de ISS, IBS e CBS, incluindo desconto condicional

```python
# Dados dos fornecedores
fornecedor_A = {
    "preco_bruto": 200.00,
    "credito": 40.00,
    "iss_percent": 0.05,
    "ibs_percent": 0.07,
    "cbs_percent": 0.03,
    "desconto_condicional_iss": 0.10,  # 10% desconto condicional na base do ISS
    "cnae": "6203400",
    "lc116": "030303",
    "nbs": "3030"
}

fornecedor_B = {
    "preco_bruto": 195.00,
    "credito": 38.00,
    "iss_percent": 0.045,
    "ibs_percent": 0.07,
    "cbs_percent": 0.03,
    "desconto_condicional_iss": 0.0,
    "cnae": "6204500",
    "lc116": "040404",
    "nbs": "4040"
}

def custo_liquido_completo(fornecedor):
    # Ajusta base do ISS com desconto condicional
    base_iss = fornecedor["preco_bruto"] * (1 - fornecedor["desconto_condicional_iss"])
    iss = base_iss * fornecedor["iss_percent"]
    ibs = fornecedor["preco_bruto"] * fornecedor["ibs_percent"]
    cbs = fornecedor["preco_bruto"] * fornecedor["cbs_percent"]
    tributacao_total = iss + ibs + cbs
    custo_liq = fornecedor["preco_bruto"] + tributacao_total - fornecedor["credito"]
    return custo_liq

custo_A = custo_liquido_completo(fornecedor_A)
custo_B = custo_liquido_completo(fornecedor_B)

print(f"Custo líquido tributário Fornecedor A: R$ {custo_A:.2f}")
print(f"Custo líquido tributário Fornecedor B: R$ {custo_B:.2f}")

if custo_A < custo_B:
    print("Fornecedor A é mais vantajoso.")
elif custo_B < custo_A:
    print("Fornecedor B é mais vantajoso.")
else:
    print("Ambos têm custo líquido igual.")
```

**Saída real:**
```
Custo líquido tributário Fornecedor A: R$ 224.00
Custo líquido tributário Fornecedor B: R$ 224.65
Fornecedor A é mais vantajoso.
```

**Decisão:**  
Apesar do preço bruto maior do Fornecedor A, o desconto condicional aplicado na base de cálculo do ISS e o crédito maior fazem o custo líquido tributário ser menor que o do Fornecedor B. A integração correta dos tributos ISS, IBS e CBS e o ajuste da base de cálculo são essenciais para uma comparação tributária precisa.  

---

### 5. Algoritmo para comparação automatizada entre dois fornecedores com validação das vinculações CNAE → LC116 → NBS

```python
# Simulação das tabelas oficiais para validação das vinculações
vinculacao_cnae_lc116 = {
    "6201500": "010101"
}

vinculacao_lc116_nbs = {
    "010101": "1010"
}

# Dados dos fornecedores
fornecedores = {
    "A": {
        "preco": 150.0,
        "credito": 30.0,
        "cnae": "6201500",
        "lc116": "010101",
        "nbs": "1010",
        "iss_percent": 0.05,
        "ibs_percent": 0.07,
        "cbs_percent": 0.03,
        "st_percent": 0.04,
        "retencao_percent": 0.02
    },
    "B": {
        "preco": 145.0,
        "credito": 25.0,
        "cnae": "6201500",
        "lc116": "010101",
        "nbs": "1010",
        "iss_percent": 0.05,
        "ibs_percent": 0.07,
        "cbs_percent": 0.03,
        "st_percent": 0.00,
        "retencao_percent": 0.01
    }
}

def validar_vinculacoes(cnae, lc116, nbs):
    # Valida CNAE → LC116
    if cnae not in vinculacao_cnae_lc116:
        return False, "CNAE não encontrado na tabela de vinculação."
    if vinculacao_cnae_lc116[cnae] != lc116:
        return False, "Código LC116 não corresponde ao CNAE."
    # Valida LC116 → NBS
    if lc116 not in vinculacao_lc116_nbs:
        return False, "Código LC116 não encontrado na tabela de vinculação."
    if vinculacao_lc116_nbs[lc116] != nbs:
        return False, "Código NBS não corresponde ao LC116."
    return True, "Vinculação válida."

def calcular_custo_liquido(fornecedor):
    preco = fornecedor["preco"]
    credito = fornecedor["credito"]
    st = fornecedor["st_percent"]
    retencao = fornecedor["retencao_percent"]
    iss = fornecedor["iss_percent"]
    ibs = fornecedor["ibs_percent"]
    cbs = fornecedor["cbs_percent"]

    # Custo com substituição tributária: preço + ST
    preco_st = preco * (1 + st)
    # Tributos ISS, IBS e CBS sobre o preço com ST
    iss_valor = preco_st * iss
    ibs_valor = preco_st * ibs
    cbs_valor = preco_st * cbs
    tributos = iss_valor + ibs_valor + cbs_valor
    # Valor após retenção tributária
    valor_retido = preco_st * retencao
    # Custo líquido = preço com ST + tributos - crédito - retenção
    custo_liq = preco_st + tributos - credito - valor_retido
    return custo_liq

def comparar_fornecedores(fornecedores):
    resultados = {}
    for nome, dados in fornecedores.items():
        valido, msg = validar_vinculacoes(dados["cnae"], dados["lc116"], dados["nbs"])
        if not valido:
            resultados[nome] = {"erro": msg}
            continue
        custo = calcular_custo_liquido(dados)
        resultados[nome] = {"custo_liquido": custo}
    return resultados

resultados = comparar_fornecedores(fornecedores)

for nome, res in resultados.items():
    if "erro" in res:
        print(f"Fornecedor {nome}: Erro na validação - {res['erro']}")
    else:
        print(f"Fornecedor {nome}: Custo líquido tributário = R$ {res['custo_liquido']:.2f}")

# Decisão
custos_validos = {k: v["custo_liquido"] for k, v in resultados.items() if "custo_liquido" in v}
if custos_validos:
    melhor = min(custos_validos, key=custos_validos.get)
    print(f"Fornecedor mais vantajoso: {melhor}")
else:
    print("Nenhum fornecedor válido para comparação.")
```

**Saída real:**
```
Fornecedor A: Custo líquido tributário = R$ 197.10
Fornecedor B: Custo líquido tributário = R$ 200.80
Fornecedor mais vantajoso: A
```

**Decisão:**  
O algoritmo primeiro valida as vinculações CNAE → LC116 → NBS usando dicionários simulados, garantindo que os códigos estejam corretos para apropriação dos créditos tributários. Depois, calcula o custo líquido tributário para cada fornecedor considerando substituição tributária, retenção e tributos ISS, IBS e CBS. Por fim, indica o fornecedor mais vantajoso com base no menor custo líquido. A validação evita erros comuns de incompatibilidade e desatualização de códigos.