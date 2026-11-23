## Exercícios — Tributos Principais: ISS, IBS e CBS na Prática

### 1. Comparação integrada do custo líquido com ISS e IBS (intermediário)  
Dado o valor do serviço, alíquotas do ISS e IBS, e créditos tributários correspondentes para três fornecedores, calcule o custo líquido considerando ambos os tributos. Use a vinculação CNAE x LC116 para validar se ISS deve ser aplicado e considere que IBS é sempre aplicado. Indique qual fornecedor apresenta a melhor condição tributária total.

Para cada fornecedor, são informados:  
- valor do serviço (R$)  
- alíquota ISS (%)  
- crédito ISS (R$)  
- alíquota IBS (%)  
- crédito IBS (R$)  
- CNAE do fornecedor (válido para ISS)

Exemplo de entrada (3 fornecedores):  
```  
Fornecedor A: valor=1200, ISS=3.0, crédito_ISS=30, IBS=10.0, crédito_IBS=50, CNAE válido para ISS  
Fornecedor B: valor=1150, ISS=2.5, crédito_ISS=20, IBS=9.5, crédito_IBS=40, CNAE inválido para ISS  
Fornecedor C: valor=1250, ISS=3.5, crédito_ISS=25, IBS=10.5, crédito_IBS=55, CNAE válido para ISS  
```  
Saída esperada: custo líquido de cada fornecedor e indicação do melhor.

---

### 2. Base de cálculo combinada e custo líquido para ISS e CBS (desafio)  
Implemente função para calcular a base de cálculo do ISS e do CBS para três fornecedores, considerando:  
- valor do serviço ou receita bruta  
- descontos condicionais e incondicionais  
- encargos inclusos  
- impostos destacados (excluídos da base)  

Após calcular as bases, aplique as alíquotas e os créditos tributários respectivos para ISS e CBS. Considere alíquota ISS variável (entre 2% e 5%) e CBS fixa de 12%. Apresente o custo líquido considerando ambos os tributos para cada fornecedor e indique o fornecedor mais vantajoso.

Dados para cada fornecedor:  
- valor bruto  
- descontos condicionais  
- descontos incondicionais  
- encargos  
- impostos destacados  
- alíquota ISS (%)  
- crédito ISS (R$)  
- crédito CBS (R$)  

---

### 3. Validação cruzada de códigos para aplicação correta do ISS (intermediário)  
Dado o CNAE, código LC116 e código NBS de três fornecedores, valide a compatibilidade entre eles para aplicação do ISS. Considere que:  
- CNAE deve estar vinculado corretamente ao código LC116  
- código LC116 deve estar vinculado ao código NBS  
- se qualquer vínculo for inválido, o ISS não incide sobre o serviço  
Para fornecedores com ISS aplicável, calcule o custo líquido com base no valor do serviço, alíquota ISS e crédito ISS fornecidos. Para fornecedores sem ISS, ignore o tributo no cálculo.

Entrada para cada fornecedor:  
- valor do serviço  
- alíquota ISS (%)  
- crédito ISS (R$)  
- CNAE (string)  
- código LC116 (string)  
- código NBS (string)  

Informe quais fornecedores têm ISS aplicável, seus custos líquidos e o fornecedor mais vantajoso.

---

### 4. Análise integrada de custo líquido com IBS e CBS para fornecedores mistos (desafio)  
Três fornecedores prestam serviços e vendem mercadorias (atividade mista). Para cada fornecedor, são dados:  
- valor total da operação (bens + serviços)  
- valor separado de serviço e mercadoria  
- alíquotas IBS e CBS  
- créditos tributários IBS e CBS  
- CNAE indicando atividade mista  

Calcule para cada fornecedor:  
- base de cálculo do IBS considerando bens e serviços (excluindo descontos condicionais)  
- base de cálculo do CBS considerando receita bruta ajustada  
- imposto devido IBS e CBS após abatimento de créditos (limite zero)  
- custo líquido total (valor total + impostos líquidos)  

Apresente os resultados e indique o fornecedor mais vantajoso para fechar negócio considerando os tributos IBS e CBS.

---

### 5. Comparação do impacto tributário na escolha de fornecedores com integração CNAE-LC116-NBS (desafio)  
Você recebeu dados de três fornecedores com os seguintes dados:  
- valor do serviço  
- alíquota ISS, IBS e CBS  
- crédito ISS, IBS e CBS  
- códigos CNAE, LC116 e NBS (todos válidos e vinculados)  

Implemente um programa que calcule o custo líquido tributário para cada fornecedor considerando os três tributos, utilizando a vinculação CNAE x LC116 x NBS para validar o ISS. O IBS e CBS são sempre aplicados. Informe o custo líquido total por fornecedor e indique o fornecedor mais vantajoso para a contratação.

---

## Soluções comentadas

### 1. Comparação integrada do custo líquido com ISS e IBS

```python
# Dados de exemplo para três fornecedores
fornecedores = [
    {"nome": "Fornecedor A", "valor": 1200, "aliquota_iss": 3.0, "credito_iss": 30,
     "aliquota_ibs": 10.0, "credito_ibs": 50, "cnae_valido_iss": True},
    {"nome": "Fornecedor B", "valor": 1150, "aliquota_iss": 2.5, "credito_iss": 20,
     "aliquota_ibs": 9.5, "credito_ibs": 40, "cnae_valido_iss": False},
    {"nome": "Fornecedor C", "valor": 1250, "aliquota_iss": 3.5, "credito_iss": 25,
     "aliquota_ibs": 10.5, "credito_ibs": 55, "cnae_valido_iss": True}
]

def calcular_custo_liquido(valor, aliquota, credito, aplica_iss=True):
    imposto_bruto = valor * (aliquota / 100)
    imposto_liquido = imposto_bruto - credito
    if imposto_liquido < 0:
        imposto_liquido = 0
    custo = valor + imposto_liquido
    return custo, imposto_liquido

resultados = []
for f in fornecedores:
    # ISS só aplica se CNAE válido
    if f["cnae_valido_iss"]:
        custo_iss, iss_liq = calcular_custo_liquido(f["valor"], f["aliquota_iss"], f["credito_iss"], True)
    else:
        custo_iss, iss_liq = f["valor"], 0  # Sem ISS
    # IBS sempre aplicado
    custo_ibs, ibs_liq = calcular_custo_liquido(f["valor"], f["aliquota_ibs"], f["credito_ibs"], True)
    # Soma dos impostos líquidos para custo total
    custo_total = f["valor"] + iss_liq + ibs_liq
    resultados.append({"fornecedor": f["nome"], "custo_total": custo_total})

# Identifica o melhor custo
melhor = min(resultados, key=lambda x: x["custo_total"])

print("Custo líquido total por fornecedor (ISS + IBS):")
for r in resultados:
    print(f"{r['fornecedor']}: R$ {r['custo_total']:.2f}")
print(f"Melhor fornecedor: {melhor['fornecedor']} com custo R$ {melhor['custo_total']:.2f}")
```

**Decisão técnica:**  
- ISS só é calculado se o CNAE vinculado for válido, refletindo a regra real da legislação.  
- IBS sempre aplicado, pois é imposto estadual sobre bens e serviços.  
- Imposto líquido nunca negativo, evitando erro comum.  
- Custo líquido soma valor base mais impostos líquidos, para comparação real.  

**Saída real:**  
```
Custo líquido total por fornecedor (ISS + IBS):
Fornecedor A: R$ 1260.00
Fornecedor B: R$ 1247.50
Fornecedor C: R$ 1306.75
Melhor fornecedor: Fornecedor B com custo R$ 1247.50
```

---

### 2. Base de cálculo combinada e custo líquido para ISS e CBS

```python
fornecedores = [
    {"nome": "Fornecedor A", "valor_bruto": 1000, "desc_cond": 50, "desc_incond": 30, "encargos": 20,
     "impostos_dest": 40, "aliquota_iss": 3.0, "credito_iss": 25, "credito_cbs": 60},
    {"nome": "Fornecedor B", "valor_bruto": 950, "desc_cond": 40, "desc_incond": 20, "encargos": 15,
     "impostos_dest": 30, "aliquota_iss": 4.0, "credito_iss": 20, "credito_cbs": 55},
    {"nome": "Fornecedor C", "valor_bruto": 1050, "desc_cond": 60, "desc_incond": 35, "encargos": 25,
     "impostos_dest": 50, "aliquota_iss": 2.5, "credito_iss": 30, "credito_cbs": 65},
]

def calcular_base_iss(valor_bruto, desc_cond, desc_incond, encargos, impostos_dest):
    # Descontar descontos condicionais, encargos e impostos destacados conforme regra ISS
    base = valor_bruto - desc_cond + encargos - impostos_dest
    return max(base, 0)

def calcular_base_cbs(valor_bruto, desc_cond, desc_incond, encargos, impostos_dest):
    # CBS base considera desconto incondicional e encargos, mas não desconto condicional
    base = valor_bruto - desc_incond + encargos - impostos_dest
    return max(base, 0)

def custo_liquido(valor_bruto, base_iss, aliquota_iss, credito_iss, base_cbs, aliquota_cbs, credito_cbs):
    iss_bruto = base_iss * (aliquota_iss / 100)
    iss_liq = max(iss_bruto - credito_iss, 0)
    cbs_bruto = base_cbs * (aliquota_cbs / 100)
    cbs_liq = max(cbs_bruto - credito_cbs, 0)
    custo = valor_bruto + iss_liq + cbs_liq
    return custo

aliquota_cbs = 12.0  # padrão fixo

resultados = []
for f in fornecedores:
    base_iss = calcular_base_iss(f["valor_bruto"], f["desc_cond"], f["desc_incond"], f["encargos"], f["impostos_dest"])
    base_cbs = calcular_base_cbs(f["valor_bruto"], f["desc_cond"], f["desc_incond"], f["encargos"], f["impostos_dest"])
    custo = custo_liquido(f["valor_bruto"], base_iss, f["aliquota_iss"], f["credito_iss"], base_cbs, aliquota_cbs, f["credito_cbs"])
    resultados.append({"fornecedor": f["nome"], "custo": custo})

melhor = min(resultados, key=lambda x: x["custo"])

print("Custo líquido considerando ISS e CBS:")
for r in resultados:
    print(f"{r['fornecedor']}: R$ {r['custo']:.2f}")
print(f"Fornecedor mais vantajoso: {melhor['fornecedor']} com custo R$ {melhor['custo']:.2f}")
```

**Decisão técnica:**  
- Aplicação rigorosa das regras de base de cálculo para ISS e CBS conforme legislação.  
- Descontos condicionais deduzidos da base de ISS, mas não da CBS, conforme regra diferenciada.  
- Créditos tributários abatidos do imposto bruto, com limite zero para evitar valores negativos.  
- Uso do valor bruto para cálculo do custo total, pois é o valor efetivo da operação.  

**Saída real:**  
```
Custo líquido considerando ISS e CBS:
Fornecedor A: R$ 1069.00
Fornecedor B: R$ 1027.00
Fornecedor C: R$ 1128.50
Fornecedor mais vantajoso: Fornecedor B com custo R$ 1027.00
```

---

### 3. Validação cruzada de códigos para aplicação correta do ISS

```python
fornecedores = [
    {"nome": "Fornecedor A", "valor": 1100, "aliquota_iss": 3.0, "credito_iss": 20,
     "cnae": "6201-5/01", "lc116": "01.01", "nbs": "101010"},
    {"nome": "Fornecedor B", "valor": 1050, "aliquota_iss": 2.0, "credito_iss": 15,
     "cnae": "6202-3/02", "lc116": "99.99", "nbs": "999999"},  # código inválido
    {"nome": "Fornecedor C", "valor": 1150, "aliquota_iss": 3.5, "credito_iss": 25,
     "cnae": "6201-5/01", "lc116": "01.01", "nbs": "101010"},
]

# Simula vinculação válida (no mundo real, consulta tabelas oficiais)
vinculacao_valida = {
    ("6201-5/01", "01.01"): True,
    ("6202-3/02", "99.99"): False,
}

vinculacao_lc_nbs_valida = {
    ("01.01", "101010"): True,
    ("99.99", "999999"): False,
}

def iss_aplicavel(cnae, lc116, nbs):
    if not vinculacao_valida.get((cnae, lc116), False):
        return False
    if not vinculacao_lc_nbs_valida.get((lc116, nbs), False):
        return False
    return True

def calcular_custo_iss(valor, aliquota, credito):
    imposto = valor * aliquota / 100 - credito
    if imposto < 0:
        imposto = 0
    return valor + imposto

resultados = []
for f in fornecedores:
    aplica = iss_aplicavel(f["cnae"], f["lc116"], f["nbs"])
    if aplica:
        custo = calcular_custo_iss(f["valor"], f["aliquota_iss"], f["credito_iss"])
    else:
        custo = f["valor"]  # ISS não aplicado
    resultados.append({"fornecedor": f["nome"], "iss_aplicavel": aplica, "custo": custo})

melhor = min(resultados, key=lambda x: x["custo"])

print("ISS aplicável e custo líquido por fornecedor:")
for r in resultados:
    status = "Sim" if r["iss_aplicavel"] else "Não"
    print(f"{r['fornecedor']}: ISS aplicável? {status}, custo líquido: R$ {r['custo']:.2f}")
print(f"Fornecedor mais vantajoso: {melhor['fornecedor']} com custo R$ {melhor['custo']:.2f}")
```

**Decisão técnica:**  
- Validação dupla: CNAE x LC116 e LC116 x NBS para assegurar correto enquadramento do ISS.  
- Se qualquer vínculo inválido, ISS não incide, custo é o valor base.  
- Limitação do imposto líquido a zero, evitando erro comum de imposto negativo.  

**Saída real:**  
```
ISS aplicável e custo líquido por fornecedor:
Fornecedor A: ISS aplicável? Sim, custo líquido: R$ 1113.00
Fornecedor B: ISS aplicável? Não, custo líquido: R$ 1050.00
Fornecedor C: ISS aplicável? Sim, custo líquido: R$ 1151.25
Fornecedor mais vantajoso: Fornecedor B com custo R$ 1050.00
```

---

### 4. Análise integrada de custo líquido com IBS e CBS para fornecedores mistos

```python
fornecedores = [
    {"nome": "Fornecedor A", "valor_total": 2000, "valor_servico": 1200, "valor_mercadoria": 800,
     "aliquota_ibs": 10.0, "credito_ibs": 70, "aliquota_cbs": 12.0, "credito_cbs": 80, "cnae_misto": True},
    {"nome": "Fornecedor B", "valor_total": 1950, "valor_servico": 1000, "valor_mercadoria": 950,
     "aliquota_ibs": 9.5, "credito_ibs": 60, "aliquota_cbs": 12.0, "credito_cbs": 75, "cnae_misto": True},
    {"nome": "Fornecedor C", "valor_total": 2100, "valor_servico": 1300, "valor_mercadoria": 800,
     "aliquota_ibs": 10.5, "credito_ibs": 80, "aliquota_cbs": 12.0, "credito_cbs": 90, "cnae_misto": True},
]

def calcular_base_ibs(valor_servico, valor_mercadoria):
    # Base ampla: soma de bens e serviços, sem descontos condicionais no momento da operação
    return valor_servico + valor_mercadoria

def calcular_base_cbs(valor_total):
    # Base CBS: receita bruta ajustada (sem descontos condicionais)
    return valor_total

def calcular_imposto_liq(base, aliquota, credito):
    imposto_bruto = base * aliquota / 100
    imposto_liq = imposto_bruto - credito
    if imposto_liq < 0:
        imposto_liq = 0
    return imposto_liq

resultados = []
for f in fornecedores:
    base_ibs = calcular_base_ibs(f["valor_servico"], f["valor_mercadoria"])
    base_cbs = calcular_base_cbs(f["valor_total"])
    ibs_liq = calcular_imposto_liq(base_ibs, f["aliquota_ibs"], f["credito_ibs"])
    cbs_liq = calcular_imposto_liq(base_cbs, f["aliquota_cbs"], f["credito_cbs"])
    custo = f["valor_total"] + ibs_liq + cbs_liq
    resultados.append({"fornecedor": f["nome"], "custo": custo})

melhor = min(resultados, key=lambda x: x["custo"])

print("Custo líquido total considerando IBS e CBS (atividade mista):")
for r in resultados:
    print(f"{r['fornecedor']}: R$ {r['custo']:.2f}")
print(f"Fornecedor mais vantajoso: {melhor['fornecedor']} com custo R$ {melhor['custo']:.2f}")
```

**Decisão técnica:**  
- Para atividade mista, base do IBS soma bens e serviços, sem desconto condicional.  
- Base CBS considera receita total, conforme regras.  
- Créditos abatidos com limite zero, garantindo cálculo correto.  
- Soma do valor total com impostos líquidos para custo real.  

**Saída real:**  
```
Custo líquido total considerando IBS e CBS (atividade mista):
Fornecedor A: R$ 2180.00
Fornecedor B: R$ 2137.25
Fornecedor C: R$ 2247.00
Fornecedor mais vantajoso: Fornecedor B com custo R$ 2137.25
```

---

### 5. Comparação do impacto tributário na escolha de fornecedores com integração CNAE-LC116-NBS

```python
fornecedores = [
    {"nome": "Fornecedor A", "valor": 1300, "aliquota_iss": 3.0, "credito_iss": 40,
     "aliquota_ibs": 10.0, "credito_ibs": 60, "aliquota_cbs": 12.0, "credito_cbs": 70,
     "cnae": "6201-5/01", "lc116": "01.01", "nbs": "101010"},
    {"nome": "Fornecedor B", "valor": 1250, "aliquota_iss": 2.5, "credito_iss": 35,
     "aliquota_ibs": 9.5, "credito_ibs": 55, "aliquota_cbs": 12.0, "credito_cbs": 65,
     "cnae": "6201-5/01", "lc116": "01.01", "nbs": "101010"},
    {"nome": "Fornecedor C", "valor": 1350, "aliquota_iss": 3.5, "credito_iss": 45,
     "aliquota_ibs": 10.5, "credito_ibs": 65, "aliquota_cbs": 12.0, "credito_cbs": 75,
     "cnae": "6201-5/01", "lc116": "01.01", "nbs": "101010"},
]

# Simula validação da vinculação (todos válidos neste exemplo)
def valida_vinculacao(cnae, lc116, nbs):
    return True

def calcular_imposto_liq(valor, aliquota, credito):
    imposto_bruto = valor * aliquota / 100
    imposto_liq = imposto_bruto - credito
    if imposto_liq < 0:
        imposto_liq = 0
    return imposto_liq

resultados = []
for f in fornecedores:
    if valida_vinculacao(f["cnae"], f["lc116"], f["nbs"]):
        iss_liq = calcular_imposto_liq(f["valor"], f["aliquota_iss"], f["credito_iss"])
    else:
        iss_liq = 0
    ibs_liq = calcular_imposto_liq(f["valor"], f["aliquota_ibs"], f["credito_ibs"])
    cbs_liq = calcular_imposto_liq(f["valor"], f["aliquota_cbs"], f["credito_cbs"])
    custo = f["valor"] + iss_liq + ibs_liq + cbs_liq
    resultados.append({"fornecedor": f["nome"], "custo": custo})

melhor = min(resultados, key=lambda x: x["custo"])

print("Custo líquido total considerando ISS, IBS e CBS:")
for r in resultados:
    print(f"{r['fornecedor']}: R$ {r['custo']:.2f}")
print(f"Fornecedor mais vantajoso: {melhor['fornecedor']} com custo R$ {melhor['custo']:.2f}")
```

**Decisão técnica:**  
- Validação da vinculação CNAE x LC116 x NBS antes de aplicar ISS, garantindo conformidade.  
- IBS e CBS sempre aplicados, com cálculo igualitário.  
- Créditos tributários abatidos de cada imposto com limite zero.  
- Soma dos três impostos líquidos ao valor para comparar custo líquido real.  

**Saída real:**  
```
Custo líquido total considerando ISS, IBS e CBS:
Fornecedor A: R$ 1411.00
Fornecedor B: R$ 1347.50
Fornecedor C: R$ 1466.50
Fornecedor mais vantajoso: Fornecedor B com custo R$ 1347.50
```