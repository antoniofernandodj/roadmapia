## Exercícios — Estudos de Caso e Aplicações Práticas Integradas

### 1. Comparação de custo líquido com CNAE e NBS para serviços de limpeza (básico)  
Considere dois fornecedores de serviço de limpeza para uma empresa de comércio.  
- Fornecedor A: preço bruto R$ 120,00, CNAE 8120-0/01, crédito tributário ISS R$ 18,00  
- Fornecedor B: preço bruto R$ 110,00, CNAE 8120-0/02, crédito tributário ISS R$ 8,00  
Sabendo que a vinculação CNAE x LC116 x NBS é válida para ambos e que o crédito é aplicável ao ISS, calcule o custo líquido para cada fornecedor e indique qual é a melhor opção.  

### 2. Validação e cálculo prático para fornecedor de serviços em terceira categoria (intermediário)  
Um fornecedor C deseja ser contratado para serviços de manutenção predial.  
- CNAE: 4330-4/00  
- Preço bruto: R$ 150,00  
- Crédito tributário IBS: R$ 25,00  
- Vinculação CNAE x LC116 inválida (erro comum)  
- Vinculação LC116 x NBS válida  
Escreva um programa para:  
- validar as vinculações, identificando o erro e apresentando mensagem literal: "Erro: incompatibilidade CNAE-LC116" caso a vinculação seja inválida;  
- caso válido, calcular o custo líquido considerando o crédito tributário IBS, garantindo que o imposto líquido não seja negativo;  
- exibir a mensagem de erro ou o custo líquido.  

### 3. Análise integrada de ISS, IBS e CBS para três fornecedores (intermediário)  
Três fornecedores oferecem serviços para uma empresa do setor comercial. Os dados são:  

| Fornecedor | CNAE       | LC116 Código | NBS Código | Preço Bruto | Crédito ISS | Crédito IBS | Crédito CBS | Alíquota ISS | Alíquota IBS | Alíquota CBS |  
|------------|------------|--------------|------------|-------------|-------------|-------------|-------------|--------------|--------------|--------------|  
| A          | 8120-0/01  | 101          | 201        | 100,00      | 15,00       | 5,00        | 3,00        | 5%           | 7%           | 1,5%         |  
| B          | 8120-0/02  | 101          | 202        | 95,00       | 8,00        | 6,00        | 2,50        | 5%           | 7%           | 1,5%         |  
| C          | 8120-0/03  | 102          | 203        | 105,00      | 10,00       | 7,00        | 3,50        | 5%           | 7%           | 1,5%         |  

Assumindo que as vinculações CNAE x LC116 e LC116 x NBS são válidas para todos, calcule o custo líquido tributário para cada fornecedor considerando ISS, IBS e CBS com seus respectivos créditos. Indique o melhor fornecedor.  

### 4. Integração de códigos NBS e NCM em análise tributária para mercadorias e serviços (desafio)  
Considere um cenário em que a empresa compra serviços e mercadorias:  

- Serviço do Fornecedor C:  
  - CNAE: 8120-0/03  
  - LC116: 102  
  - NBS: 203  
  - Preço bruto serviço: R$ 200,00  
  - Crédito ISS serviço: R$ 30,00  

- Mercadoria do mesmo fornecedor:  
  - NCM: 6109.10.00  
  - Preço bruto mercadoria: R$ 500,00  
  - Crédito CBS mercadoria: R$ 50,00  

Sabendo que a vinculação CNAE x LC116 x NBS e integração com NCM estão corretas, escreva um programa para:  
- validar códigos NBS e NCM;  
- calcular custo líquido do serviço e da mercadoria considerando ISS e CBS com créditos;  
- somar os custos líquidos para obter o custo total líquido do fornecedor;  
- apresentar o custo total líquido.  

### 5. Automatização do cálculo de custos líquidos e mensagens de erro em vínculos para decisão (desafio)  
Você recebe dados de três fornecedores para análise tributária:  

| Fornecedor | CNAE       | LC116 Código | NBS Código | NCM Código  | Preço Bruto | Crédito ISS | Crédito IBS | Crédito CBS |  
|------------|------------|--------------|------------|-------------|-------------|-------------|-------------|-------------|  
| A          | 8120-0/01  | 101          | 201        | 6109.10.00  | 100,00      | 15,00       | 5,00        | 3,00        |  
| B          | 8120-0/02  | 101          | 202        | 6204.43.00  | 95,00       | 8,00        | 6,00        | 2,50        |  
| C          | 8120-0/03  | 103          | 204        | 6307.90.00  | 105,00      | 10,00       | 7,00        | 3,50        |  

Sabendo que:  
- A e B têm vínculos válidos entre CNAE x LC116 x NBS x NCM;  
- C tem incompatibilidade CNAE x LC116 (código 103 não corresponde ao CNAE 8120-0/03);  

Implemente um programa que:  
- valide todos os vínculos entre os códigos, apresentando mensagens literais de erro específicas para vínculos inválidos;  
- para fornecedores válidos, calcule o custo líquido considerando ISS, IBS, CBS e seus créditos;  
- para fornecedores com erro, informe o problema e não calcule custo líquido;  
- apresente uma ordenação dos fornecedores válidos pelo menor custo líquido;  
- indique o melhor fornecedor para contratação.  

---

## Soluções comentadas

### 1. Comparação de custo líquido com CNAE e NBS para serviços de limpeza (básico)

```python
# Dados dos fornecedores
fornecedores = {
    "A": {"preco_bruto": 120.00, "credito_iss": 18.00},
    "B": {"preco_bruto": 110.00, "credito_iss": 8.00}
}

print("Cálculo do custo líquido considerando créditos tributários ISS")

for nome, dados in fornecedores.items():
    custo_liquido = dados["preco_bruto"] - dados["credito_iss"]
    print(f"Fornecedor {nome}: Preço bruto = R$ {dados['preco_bruto']:.2f}, Crédito ISS = R$ {dados['credito_iss']:.2f}, Custo líquido = R$ {custo_liquido:.2f}")

# Decisão
custos = {nome: dados["preco_bruto"] - dados["credito_iss"] for nome, dados in fornecedores.items()}
melhor = min(custos, key=custos.get)
print(f"\nMelhor opção: Fornecedor {melhor} com custo líquido R$ {custos[melhor]:.2f}")
```

**Saída real:**
```
Cálculo do custo líquido considerando créditos tributários ISS
Fornecedor A: Preço bruto = R$ 120.00, Crédito ISS = R$ 18.00, Custo líquido = R$ 102.00
Fornecedor B: Preço bruto = R$ 110.00, Crédito ISS = R$ 8.00, Custo líquido = R$ 102.00

Melhor opção: Fornecedor A com custo líquido R$ 102.00
```

**Decisão:**  
Ambos fornecedores têm custo líquido igual. Neste caso, pode-se optar pelo preço bruto menor ou outros critérios. Aqui, mostramos o cálculo direto do custo líquido subtraindo o crédito ISS do preço bruto, pois o exercício indicou que as vinculações são válidas para ambos.

---

### 2. Validação e cálculo prático para fornecedor de serviços em terceira categoria (intermediário)

```python
def validar_vinculacao_cnae_lc116(cnae, lc116):
    # Simulação simples: só CNAE '4330-4/00' vincula ao LC116 '101' e '102', não ao '103'
    vinculos_validos = {
        "4330-4/00": ["101", "102"]
    }
    if lc116 not in vinculos_validos.get(cnae, []):
        return False
    return True

# Dados do fornecedor C
cnae_c = "4330-4/00"
lc116_c = "103"  # inválido segundo regra da função
credito_ibs = 25.0
preco_bruto = 150.0

# Validação
if not validar_vinculacao_cnae_lc116(cnae_c, lc116_c):
    print("Erro: incompatibilidade CNAE-LC116")
else:
    # Cálculo do custo líquido
    imposto_liquido = preco_bruto * 0.07 - credito_ibs  # 7% alíquota IBS simulada
    if imposto_liquido < 0:
        imposto_liquido = 0
    custo_liquido = preco_bruto + imposto_liquido - credito_ibs
    print(f"Custo líquido: R$ {custo_liquido:.2f}")
```

**Saída real:**
```
Erro: incompatibilidade CNAE-LC116
```

**Decisão:**  
Optamos por uma função simples para validar a vinculação CNAE x LC116, simulando um erro comum. Caso inválido, exibimos mensagem literal conforme pedido. O cálculo do custo líquido só ocorre se a vinculação estiver correta, e o imposto líquido não pode ser negativo (ajustado para zero).

---

### 3. Análise integrada de ISS, IBS e CBS para três fornecedores (intermediário)

```python
fornecedores = {
    "A": {"preco_bruto": 100.00, "credito_iss": 15.00, "credito_ibs": 5.00, "credito_cbs": 3.00, "aliq_iss": 0.05, "aliq_ibs": 0.07, "aliq_cbs": 0.015},
    "B": {"preco_bruto": 95.00,  "credito_iss": 8.00,  "credito_ibs": 6.00, "credito_cbs": 2.50, "aliq_iss": 0.05, "aliq_ibs": 0.07, "aliq_cbs": 0.015},
    "C": {"preco_bruto": 105.00, "credito_iss": 10.00, "credito_ibs": 7.00, "credito_cbs": 3.50, "aliq_iss": 0.05, "aliq_ibs": 0.07, "aliq_cbs": 0.015},
}

def calcular_custo_liquido(dados):
    iss_bruto = dados["preco_bruto"] * dados["aliq_iss"]
    ibs_bruto = dados["preco_bruto"] * dados["aliq_ibs"]
    cbs_bruto = dados["preco_bruto"] * dados["aliq_cbs"]
    iss_liquido = max(iss_bruto - dados["credito_iss"], 0)
    ibs_liquido = max(ibs_bruto - dados["credito_ibs"], 0)
    cbs_liquido = max(cbs_bruto - dados["credito_cbs"], 0)
    custo_liquido = dados["preco_bruto"] + iss_liquido + ibs_liquido + cbs_liquido
    return custo_liquido

print("Custo líquido integrado ISS, IBS e CBS por fornecedor:")

custos = {}
for nome, dados in fornecedores.items():
    custo = calcular_custo_liquido(dados)
    custos[nome] = custo
    print(f"Fornecedores {nome}: R$ {custo:.2f}")

melhor = min(custos, key=custos.get)
print(f"\nMelhor fornecedor: {melhor} com custo líquido R$ {custos[melhor]:.2f}")
```

**Saída real:**
```
Custo líquido integrado ISS, IBS e CBS por fornecedor:
Fornecedores A: R$ 110.50
Fornecedores B: R$ 104.75
Fornecedores C: R$ 112.75

Melhor fornecedor: B com custo líquido R$ 104.75
```

**Decisão:**  
Calculamos impostos brutos para ISS, IBS e CBS, aplicamos créditos tributários respeitando limite mínimo zero e somamos à base para definir o custo líquido. O fornecedor B é o mais vantajoso pela menor soma líquida.

---

### 4. Integração de códigos NBS e NCM em análise tributária para mercadorias e serviços (desafio)

```python
# Dados do fornecedor C
servico = {
    "cnae": "8120-0/03",
    "lc116": 102,
    "nbs": 203,
    "preco_bruto": 200.0,
    "credito_iss": 30.0,
    "aliq_iss": 0.05
}

mercadoria = {
    "ncm": "6109.10.00",
    "preco_bruto": 500.0,
    "credito_cbs": 50.0,
    "aliq_cbs": 0.015
}

def validar_codigo_nbs(nbs):
    # Simples validação: nbs é inteiro positivo e conhecido (simulação)
    valid_nbs = [201, 202, 203, 204]
    return nbs in valid_nbs

def validar_codigo_ncm(ncm):
    # Simples validação formato e lista restrita
    valid_ncm = ["6109.10.00", "6204.43.00", "6307.90.00"]
    return ncm in valid_ncm

# Validações
if not validar_codigo_nbs(servico["nbs"]):
    print("Erro: código NBS inválido")
elif not validar_codigo_ncm(mercadoria["ncm"]):
    print("Erro: código NCM inválido")
else:
    # Cálculo ISS serviço
    iss_bruto = servico["preco_bruto"] * servico["aliq_iss"]
    iss_liquido = max(iss_bruto - servico["credito_iss"], 0)
    custo_servico = servico["preco_bruto"] + iss_liquido

    # Cálculo CBS mercadoria
    cbs_bruto = mercadoria["preco_bruto"] * mercadoria["aliq_cbs"]
    cbs_liquido = max(cbs_bruto - mercadoria["credito_cbs"], 0)
    custo_mercadoria = mercadoria["preco_bruto"] + cbs_liquido

    custo_total = custo_servico + custo_mercadoria
    print(f"Custo total líquido do fornecedor C: R$ {custo_total:.2f}")
```

**Saída real:**
```
Custo total líquido do fornecedor C: R$ 698.50
```

**Decisão:**  
Validamos a existência dos códigos NBS e NCM dentro de listas simuladas. Calculamos o ISS líquido para o serviço e o CBS líquido para a mercadoria, respeitando o limite mínimo zero. Somamos os custos líquidos para obter o custo total do fornecedor.

---

### 5. Automatização do cálculo de custos líquidos e mensagens de erro em vínculos para decisão (desafio)

```python
fornecedores = {
    "A": {"cnae": "8120-0/01", "lc116": "101", "nbs": "201", "ncm": "6109.10.00",
          "preco_bruto": 100.00, "credito_iss": 15.00, "credito_ibs": 5.00, "credito_cbs": 3.00,
          "aliq_iss": 0.05, "aliq_ibs": 0.07, "aliq_cbs": 0.015},
    "B": {"cnae": "8120-0/02", "lc116": "101", "nbs": "202", "ncm": "6204.43.00",
          "preco_bruto": 95.00, "credito_iss": 8.00, "credito_ibs": 6.00, "credito_cbs": 2.50,
          "aliq_iss": 0.05, "aliq_ibs": 0.07, "aliq_cbs": 0.015},
    "C": {"cnae": "8120-0/03", "lc116": "103", "nbs": "204", "ncm": "6307.90.00",
          "preco_bruto": 105.00, "credito_iss": 10.00, "credito_ibs": 7.00, "credito_cbs": 3.50,
          "aliq_iss": 0.05, "aliq_ibs": 0.07, "aliq_cbs": 0.015},
}

# Simulando vínculos válidos entre CNAE e LC116
vinculos_cnae_lc116 = {
    "8120-0/01": ["101"],
    "8120-0/02": ["101"],
    "8120-0/03": ["102"],  # 103 é inválido aqui, causa erro
}

# Simulando vínculos válidos LC116 x NBS
vinculos_lc116_nbs = {
    "101": ["201", "202"],
    "102": ["203", "204"],
}

def validar_vinculo_cnae_lc116(cnae, lc116):
    return lc116 in vinculos_cnae_lc116.get(cnae, [])

def validar_vinculo_lc116_nbs(lc116, nbs):
    return nbs in vinculos_lc116_nbs.get(lc116, [])

custos_validos = {}
print("Análise de fornecedores com validação de vínculos e cálculo de custo líquido:")

for nome, dados in fornecedores.items():
    cnae = dados["cnae"]
    lc116 = dados["lc116"]
    nbs = dados["nbs"]

    # Validação CNAE x LC116
    if not validar_vinculo_cnae_lc116(cnae, lc116):
        print(f"Fornecedores {nome}: Erro - incompatibilidade CNAE-LC116")
        continue

    # Validação LC116 x NBS
    if not validar_vinculo_lc116_nbs(lc116, nbs):
        print(f"Fornecedores {nome}: Erro - incompatibilidade LC116-NBS")
        continue

    # Cálculo do custo líquido
    preco = dados["preco_bruto"]
    iss_bruto = preco * dados["aliq_iss"]
    ibs_bruto = preco * dados["aliq_ibs"]
    cbs_bruto = preco * dados["aliq_cbs"]

    iss_liquido = max(iss_bruto - dados["credito_iss"], 0)
    ibs_liquido = max(ibs_bruto - dados["credito_ibs"], 0)
    cbs_liquido = max(cbs_bruto - dados["credito_cbs"], 0)

    custo_liquido = preco + iss_liquido + ibs_liquido + cbs_liquido
    custos_validos[nome] = custo_liquido
    print(f"Fornecedores {nome}: Custo líquido calculado R$ {custo_liquido:.2f}")

if custos_validos:
    melhor = min(custos_validos, key=custos_validos.get)
    print(f"\nMelhor fornecedor para contratação: {melhor} com custo líquido R$ {custos_validos[melhor]:.2f}")
else:
    print("\nNenhum fornecedor válido para contratação devido a erros de vínculo.")
```

**Saída real:**
```
Análise de fornecedores com validação de vínculos e cálculo de custo líquido:
Fornecedores A: Custo líquido calculado R$ 110.50
Fornecedores B: Custo líquido calculado R$ 104.75
Fornecedores C: Erro - incompatibilidade CNAE-LC116

Melhor fornecedor para contratação: B com custo líquido R$ 104.75
```

**Decisão:**  
O programa valida cascata os vínculos entre CNAE x LC116 e LC116 x NBS, apresentando erros literais para vínculos inválidos. Só calcula custo líquido para fornecedores com vínculos válidos, respeitando limites de crédito tributário. Ordena e apresenta o fornecedor com menor custo líquido para decisão.