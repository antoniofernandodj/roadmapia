## Exercícios — Legislação Complementar e Obrigações Acessórias

### 1. Comparação de fornecedores considerando LC116 e regime tributário (intermediário)  
Você recebeu dados de dois fornecedores que prestam serviços distintos. Cada fornecedor está enquadrado em regime tributário diferente (Simples Nacional e Lucro Presumido) e possui CNAE e código LC116 associados. Calcule o valor líquido a pagar para cada fornecedor considerando:  
- Preço bruto do serviço  
- Aplicação da alíquota ISS conforme LC116 e município fictício (5%)  
- Crédito tributário possível para cada regime (Simples Nacional não gera crédito; Lucro Presumido gera crédito de 12% do ISS)  
- Informe qual fornecedor é mais vantajoso economicamente pelo custo líquido (preço menos crédito).  

Dados:  
| Fornecedor | Regime Tributário | CNAE     | Código LC116 | Preço bruto (R$) |  
|------------|-------------------|----------|--------------|------------------|  
| A          | Simples Nacional   | 62.01-5/01 | 0601         | 1.200,00         |  
| B          | Lucro Presumido   | 62.09-1/00 | 0610         | 1.150,00         |  

Saída esperada: Texto explicando cálculo para cada fornecedor e indicação do mais vantajoso.

---

### 2. Validação cruzada de CNAE, LC116 e NBS em Python (desafio)  
Escreva um programa em Python que receba como entrada o CNAE, código LC116 e código NBS de um serviço prestado, e valide se a vinculação entre esses códigos está correta conforme as seguintes regras simplificadas:  
- CNAE 62.01-5/01 deve vincular ao LC116 0601 e NBS 01.01  
- CNAE 62.09-1/00 deve vincular ao LC116 0610 e NBS 01.10  
- CNAE 63.11-9/00 deve vincular ao LC116 0620 e NBS 02.01  

O programa deve:  
- Receber os três códigos como entrada do usuário  
- Informar se a vinculação é válida ou qual código está incorreto  
- Exibir mensagem de erro para incompatibilidade  

Exemplo:  
Entrada: CNAE=62.01-5/01, LC116=0601, NBS=01.01  
Saída: "Vinculação correta."  

---

### 3. Análise do impacto das obrigações acessórias na apropriação de créditos (intermediário)  
Uma empresa prestadora de serviços está com erros na emissão da NFS-e devido à incompatibilidade entre o CNAE 62.01-5/01 e o código LC116 usado (errado: 0610, correto: 0601). Descreva:  
- Quais obrigações acessórias são afetadas por esse erro  
- Consequências práticas na apropriação de créditos tributários para a empresa  
- Como a correção do código LC116 impacta o controle fiscal e a análise tributária para escolha de fornecedores  

Apresente o raciocínio com base nos conceitos da legislação complementar e obrigações acessórias.

---

### 4. Simulação de cálculo do ISS considerando base de cálculo e créditos (desafio)  
Considere a prestação de um serviço com os seguintes dados:  
- CNAE: 62.01-5/01  
- Código LC116: 0601  
- Código NBS: 01.01  
- Valor do serviço: R$ 3.000,00  
- Alíquota ISS: 5%  
- Crédito tributário aplicável: 15% do ISS calculado  

Calcule:  
- Valor do ISS devido antes do crédito  
- Valor do crédito tributário  
- Valor líquido do ISS a pagar após crédito  
- Custo líquido do serviço para a empresa (valor do serviço + ISS líquido)  

Explique cada passo do cálculo e o impacto do crédito tributário na decisão econômica.

---

### 5. Escrituração fiscal automática com integração CNAE-LC116-NBS (desafio)  
Você deve implementar um script em Python que registre uma operação fictícia de serviço prestado, vinculando CNAE, LC116 e NBS, e calcule o ISS líquido considerando base de cálculo, alíquota, e crédito tributário. O script deve:  
- Receber dados da operação (valor do serviço, CNAE, LC116, NBS, alíquota ISS, percentual de crédito)  
- Validar a vinculação entre CNAE, LC116 e NBS (usando a regra do exercício 2)  
- Calcular ISS bruto, crédito e ISS líquido  
- Gerar uma escrituração fiscal simulada em formato JSON com:  
  - Dados da operação  
  - Códigos vinculados  
  - Valores calculados  
  - Indicação de erros de vinculação (se houver)  

Exemplo de entrada:  
```
valor_servico = 2000.00  
CNAE = "62.09-1/00"  
LC116 = "0610"  
NBS = "01.10"  
aliquota_iss = 0.05  
percentual_credito = 0.12  
```

Exiba a saída JSON formatada, explicando cada campo e a importância da escrituração para conformidade fiscal.

---

## Soluções comentadas

### 1. Comparação de fornecedores considerando LC116 e regime tributário

```python
# Dados dos fornecedores
fornecedores = [
    {
        "nome": "A",
        "regime": "Simples Nacional",
        "CNAE": "62.01-5/01",
        "LC116": "0601",
        "preco_bruto": 1200.00,
        "aliquota_iss": 0.05,
        "creditos": 0.0  # Simples Nacional não gera crédito
    },
    {
        "nome": "B",
        "regime": "Lucro Presumido",
        "CNAE": "62.09-1/00",
        "LC116": "0610",
        "preco_bruto": 1150.00,
        "aliquota_iss": 0.05,
        "creditos": 0.12  # Crédito de 12% do ISS
    }
]

for fornecedor in fornecedores:
    iss = fornecedor["preco_bruto"] * fornecedor["aliquota_iss"]
    credito = iss * fornecedor["creditos"]
    custo_liquido = fornecedor["preco_bruto"] + iss - credito
    fornecedor["iss"] = iss
    fornecedor["credito"] = credito
    fornecedor["custo_liquido"] = custo_liquido

# Comparação
fornecedor_mais_barato = min(fornecedores, key=lambda f: f["custo_liquido"])

# Resultado
for f in fornecedores:
    print(f"Fornecedor {f['nome']} (Regime: {f['regime']}):")
    print(f"  Preço bruto: R$ {f['preco_bruto']:.2f}")
    print(f"  ISS calculado (5%): R$ {f['iss']:.2f}")
    print(f"  Crédito tributário: R$ {f['credito']:.2f}")
    print(f"  Custo líquido total: R$ {f['custo_liquido']:.2f}")
    print()

print(f"Fornecedor mais vantajoso: {fornecedor_mais_barato['nome']} com custo líquido de R$ {fornecedor_mais_barato['custo_liquido']:.2f}")
```

**Saída real:**
```
Fornecedor A (Regime: Simples Nacional):
  Preço bruto: R$ 1200.00
  ISS calculado (5%): R$ 60.00
  Crédito tributário: R$ 0.00
  Custo líquido total: R$ 1260.00

Fornecedor B (Regime: Lucro Presumido):
  Preço bruto: R$ 1150.00
  ISS calculado (5%): R$ 57.50
  Crédito tributário: R$ 6.90
  Custo líquido total: R$ 1200.60

Fornecedor mais vantajoso: B com custo líquido de R$ 1200.60
```

**Decisão:** Apesar do preço bruto do fornecedor B ser menor, o crédito tributário reduz o custo líquido do fornecedor B menos que o custo total do fornecedor A. Aqui, o fornecedor B ainda é mais barato após crédito, então é a melhor escolha.

---

### 2. Validação cruzada de CNAE, LC116 e NBS em Python

```python
# Mapeamento simplificado para validação
vinculacoes = {
    "62.01-5/01": {"LC116": "0601", "NBS": "01.01"},
    "62.09-1/00": {"LC116": "0610", "NBS": "01.10"},
    "63.11-9/00": {"LC116": "0620", "NBS": "02.01"}
}

def validar_vinculacao(cnae, lc116, nbs):
    if cnae not in vinculacoes:
        return "CNAE inválido ou não cadastrado."
    esperado = vinculacoes[cnae]
    erros = []
    if lc116 != esperado["LC116"]:
        erros.append(f"Código LC116 incorreto (esperado {esperado['LC116']}, informado {lc116}).")
    if nbs != esperado["NBS"]:
        erros.append(f"Código NBS incorreto (esperado {esperado['NBS']}, informado {nbs}).")
    if erros:
        return "Erro de vinculação: " + " ".join(erros)
    return "Vinculação correta."

# Exemplo de uso
entrada_cnae = input("Digite o CNAE: ").strip()
entrada_lc116 = input("Digite o código LC116: ").strip()
entrada_nbs = input("Digite o código NBS: ").strip()

resultado = validar_vinculacao(entrada_cnae, entrada_lc116, entrada_nbs)
print(resultado)
```

**Explicação:**  
O programa cria um dicionário com vinculações oficiais de códigos. Recebe os três códigos e verifica se correspondem à combinação correta. Caso algum esteja errado, informa qual código está incompatível, ajudando a evitar erros na emissão fiscal e na apropriação de créditos.

---

### 3. Análise do impacto das obrigações acessórias na apropriação de créditos

**Resposta:**

- **Obrigações afetadas:** A emissão da NFS-e (Nota Fiscal de Serviços Eletrônica) é diretamente impactada, pois a incompatibilidade do código LC116 com o CNAE impede a emissão correta da nota. Além disso, declarações acessórias como EFD (Escrituração Fiscal Digital) e controles de crédito ficam comprometidos.

- **Consequências práticas:** A empresa pode sofrer rejeição da NFS-e pela prefeitura, impossibilitando contabilizar a receita e apropriar créditos tributários relativos ao ISS. Também pode haver multas por emissão incorreta e atrasos na escrituração fiscal, prejudicando a conformidade.

- **Impacto da correção:** Corrigindo o código LC116 para o correto (0601 para CNAE 62.01-5/01), a empresa garante emissão válida da NFS-e, permite a apropriação correta dos créditos tributários, evita multas e melhora a análise tributária, facilitando a comparação justa entre fornecedores baseada no custo líquido efetivo.

---

### 4. Simulação de cálculo do ISS considerando base de cálculo e créditos

```python
# Dados da operação
valor_servico = 3000.00
aliquota_iss = 0.05
percentual_credito = 0.15  # 15%

# Cálculo do ISS bruto
iss_bruto = valor_servico * aliquota_iss

# Cálculo do crédito tributário
credito = iss_bruto * percentual_credito

# ISS líquido a pagar após crédito
iss_liquido = iss_bruto - credito

# Custo líquido do serviço para empresa
custo_liquido = valor_servico + iss_liquido

print(f"ISS bruto: R$ {iss_bruto:.2f}")
print(f"Crédito tributário: R$ {credito:.2f}")
print(f"ISS líquido a pagar: R$ {iss_liquido:.2f}")
print(f"Custo líquido do serviço: R$ {custo_liquido:.2f}")
```

**Saída real:**
```
ISS bruto: R$ 150.00
Crédito tributário: R$ 22.50
ISS líquido a pagar: R$ 127.50
Custo líquido do serviço: R$ 3127.50
```

**Explicação:**  
Primeiro calcula-se o ISS sobre o valor do serviço (5%). Em seguida, aplica-se o percentual de crédito permitido para reduzir o imposto devido. O ISS líquido é o valor a pagar após aproveitar o crédito. O custo líquido do serviço considera o valor do serviço mais o ISS líquido, pois o ISS é um custo adicional para a empresa. O crédito reduz o impacto tributário, otimizando o custo.

---

### 5. Escrituração fiscal automática com integração CNAE-LC116-NBS

```python
import json

vinculacoes = {
    "62.01-5/01": {"LC116": "0601", "NBS": "01.01"},
    "62.09-1/00": {"LC116": "0610", "NBS": "01.10"},
    "63.11-9/00": {"LC116": "0620", "NBS": "02.01"}
}

def validar_vinculacao(cnae, lc116, nbs):
    if cnae not in vinculacoes:
        return False, "CNAE inválido ou não cadastrado."
    esperado = vinculacoes[cnae]
    erros = []
    if lc116 != esperado["LC116"]:
        erros.append(f"LC116 incorreto (esperado {esperado['LC116']})")
    if nbs != esperado["NBS"]:
        erros.append(f"NBS incorreto (esperado {esperado['NBS']})")
    if erros:
        return False, "; ".join(erros)
    return True, "Vinculação correta."

def registrar_operacao(valor_servico, cnae, lc116, nbs, aliquota_iss, percentual_credito):
    valido, msg = validar_vinculacao(cnae, lc116, nbs)
    iss_bruto = valor_servico * aliquota_iss
    credito = iss_bruto * percentual_credito
    iss_liquido = iss_bruto - credito

    escrituração = {
        "valor_servico": valor_servico,
        "cnae": cnae,
        "lc116": lc116,
        "nbs": nbs,
        "aliquota_iss": aliquota_iss,
        "percentual_credito": percentual_credito,
        "iss_bruto": round(iss_bruto, 2),
        "credito": round(credito, 2),
        "iss_liquido": round(iss_liquido, 2),
        "validacao_vinculacao": {
            "valida": valido,
            "mensagem": msg
        }
    }

    return json.dumps(escrituração, indent=4, ensure_ascii=False)

# Exemplo de uso
valor_servico = 2000.00
CNAE = "62.09-1/00"
LC116 = "0610"
NBS = "01.10"
aliquota_iss = 0.05
percentual_credito = 0.12

saida = registrar_operacao(valor_servico, CNAE, LC116, NBS, aliquota_iss, percentual_credito)
print(saida)
```

**Saída real:**
```json
{
    "valor_servico": 2000.0,
    "cnae": "62.09-1/00",
    "lc116": "0610",
    "nbs": "01.10",
    "aliquota_iss": 0.05,
    "percentual_credito": 0.12,
    "iss_bruto": 100.0,
    "credito": 12.0,
    "iss_liquido": 88.0,
    "validacao_vinculacao": {
        "valida": true,
        "mensagem": "Vinculação correta."
    }
}
```

**Explicação:**  
O script recebe os dados da operação e valida se os códigos estão corretamente vinculados. Calcula o ISS bruto, o crédito e o ISS líquido. Gera uma escrituração fiscal em JSON, que pode ser usada para controle, auditoria e integração com sistemas fiscais. A validação evita erros que geram rejeição da NFS-e e perda de créditos tributários. A escrituração automatizada facilita a conformidade e a análise tributária.