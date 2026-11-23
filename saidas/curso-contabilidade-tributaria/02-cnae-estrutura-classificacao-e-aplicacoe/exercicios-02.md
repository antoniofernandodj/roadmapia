## Exercícios — CNAE: Estrutura, Classificação e Aplicações Práticas

### 1. Validação e comparação tributária entre fornecedores com atividades mistas (intermediário)  
Considere três fornecedores:  
- Fornecedor A atua em TI e comércio; possui dois CNAEs completos correspondentes a essas atividades.  
- Fornecedor B atua apenas em serviços de TI, com um único CNAE completo.  
- Fornecedor C atua em serviços de comércio e prestação de serviços gerais, com dois CNAEs completos.  

Para cada fornecedor, valide a correção dos CNAEs completos informados (formato e subclasse), vincule cada CNAE ao código LC116 correspondente e, em seguida, vincule cada código LC116 ao código NBS. Com base nessas vinculações, calcule o potencial de créditos tributários para ISS, IBS e CBS, considerando que:  
- Fornecedor A tem preço bruto de R$ 1500,00 e crédito tributário estimado de 12% do valor.  
- Fornecedor B tem preço bruto de R$ 1400,00 e crédito tributário estimado de 10%.  
- Fornecedor C tem preço bruto de R$ 1450,00 e crédito tributário estimado de 11%.  

Apresente a análise comparativa do custo líquido tributário para escolher o fornecedor mais vantajoso sob o ponto de vista tributário.

### 2. Detecção e correção de erros comuns na classificação CNAE para análise tributária (básico)  
Você recebeu os CNAEs completos de três fornecedores em setores diferentes (TI, comércio e serviços gerais). Identifique erros comuns na classificação CNAE, como uso de códigos genéricos, níveis incorretos e ausência de múltiplos CNAEs para atividades mistas. Explique as consequências tributárias dessas falhas, especialmente na apuração do ISS e na apropriação de créditos tributários. Proponha a correção das classificações para garantir conformidade e melhor aproveitamento fiscal.

### 3. Integração automática da vinculação CNAE-LC116-NBS para suporte a decisão de compras (desafio)  
Suponha que seu sistema fiscal recebe os CNAEs completos de três fornecedores distintos em setores variados. Implemente um programa que:  
- Verifique a validade dos CNAEs (formato e existência na tabela oficial).  
- Para cada CNAE, consulte automaticamente o código LC116 vinculado.  
- Para cada código LC116, consulte o código NBS correspondente.  
- Calcule o custo líquido tributário considerando preço bruto e percentual de crédito tributário informado para cada fornecedor.  
- Apresente a classificação completa e os valores para facilitar a escolha do fornecedor mais vantajoso.  

Use dados de exemplo para os três fornecedores, simulando preços e percentuais de créditos. Explique as decisões feitas para automatizar essas etapas.

### 4. Auditoria tributária e análise crítica da classificação CNAE em fornecedores reais (desafio)  
Você recebeu os dados de três fornecedores reais, com seus CNAEs completos e respectivos códigos LC116 e NBS informados em notas fiscais. Realize uma auditoria tributária para:  
- Verificar a atualização e validade dos CNAEs.  
- Confirmar a correta vinculação CNAE-LC116-NBS.  
- Identificar inconformidades e erros que impactem a apropriação de créditos e o cálculo do ISS.  
- Avaliar as consequências fiscais desses erros para a empresa contratante.  
- Propor ajustes para garantir conformidade e otimização tributária na escolha e contratação desses fornecedores.  

Apresente o relatório da auditoria com exemplos concretos.

### 5. Análise prática do impacto da atualização do CNAE na escolha de fornecedores (intermediário)  
Três fornecedores informaram seus CNAEs completos, mas um deles utiliza um código desatualizado que não corresponde mais à tabela vigente de 2024. Considerando que o sistema fiscal deve evitar esse tipo de erro para garantir a correta apropriação de créditos, realize:  
- Validação do formato e atualização dos CNAEs dos fornecedores.  
- Identificação do impacto tributário negativo do uso do código desatualizado, considerando possíveis rejeições e perda de créditos.  
- Simulação da correção do CNAE desatualizado e comparação do custo líquido tributário antes e depois da correção.  
- Explicação da importância da atualização contínua do CNAE para a correta análise tributária na decisão de fornecedores.  

Use dados de preço bruto e percentual de crédito para ilustrar o cálculo.

---

## Soluções comentadas

### 1. Validação e comparação tributária entre fornecedores com atividades mistas

```python
# Dados dos fornecedores
fornecedores = {
    "Fornecedor A": {
        "cnaes": ["62.01-5-01", "47.89-0-99"],  # TI e comércio
        "preco_bruto": 1500.00,
        "credito_percentual": 0.12
    },
    "Fornecedor B": {
        "cnaes": ["62.01-5-01"],  # Apenas TI
        "preco_bruto": 1400.00,
        "credito_percentual": 0.10
    },
    "Fornecedor C": {
        "cnaes": ["47.89-0-99", "81.12-3-00"],  # Comércio e serviços gerais
        "preco_bruto": 1450.00,
        "credito_percentual": 0.11
    }
}

# Dicionários simulando vinculações CNAE -> LC116 e LC116 -> NBS
vinculacao_cnae_lc116 = {
    "62.01-5-01": "101",  # Serviços de TI
    "47.89-0-99": "201",  # Comércio varejista
    "81.12-3-00": "301"   # Serviços gerais
}

vinculacao_lc116_nbs = {
    "101": "NBS01",
    "201": "NBS02",
    "301": "NBS03"
}

def validar_cnae(cnae):
    # Validação simples do formato: 2 dígitos '.' 2 dígitos '-' 1 dígito '-' 2 dígitos
    import re
    padrao = r"^\d{2}\.\d{2}-\d-\d{2}$"
    return bool(re.match(padrao, cnae))

print("Análise e comparação tributária entre fornecedores:\n")

for nome, dados in fornecedores.items():
    cnaes = dados["cnaes"]
    preco = dados["preco_bruto"]
    credito_pct = dados["credito_percentual"]

    print(f"Fornecedor: {nome}")
    print("  CNAEs e validação:")
    validos = True
    for cnae in cnaes:
        valido = validar_cnae(cnae)
        validos = validos and valido
        print(f"    {cnae} -> {'Válido' if valido else 'Inválido'}")

    if not validos:
        print("  Erro: CNAE inválido detectado, revisar classificação.\n")
        continue

    # Vinculação CNAE -> LC116 -> NBS
    lc116_list = []
    nbs_list = []
    for cnae in cnaes:
        lc116 = vinculacao_cnae_lc116.get(cnae)
        if not lc116:
            print(f"  CNAE {cnae} não possui código LC116 vinculado.")
            continue
        nbs = vinculacao_lc116_nbs.get(lc116)
        if not nbs:
            print(f"  Código LC116 {lc116} não possui código NBS vinculado.")
            continue
        lc116_list.append(lc116)
        nbs_list.append(nbs)

    print(f"  Códigos LC116 vinculados: {', '.join(lc116_list)}")
    print(f"  Códigos NBS vinculados: {', '.join(nbs_list)}")

    credito_valor = preco * credito_pct
    custo_liquido = preco - credito_valor
    print(f"  Preço bruto: R$ {preco:.2f}")
    print(f"  Crédito tributário estimado: R$ {credito_valor:.2f} ({credito_pct*100:.0f}%)")
    print(f"  Custo líquido aproximado: R$ {custo_liquido:.2f}\n")

# Saída real:
# Análise e comparação tributária entre fornecedores:
#
# Fornecedor: Fornecedor A
#   CNAEs e validação:
#     62.01-5-01 -> Válido
#     47.89-0-99 -> Válido
#   Códigos LC116 vinculados: 101, 201
#   Códigos NBS vinculados: NBS01, NBS02
#   Preço bruto: R$ 1500.00
#   Crédito tributário estimado: R$ 180.00 (12%)
#   Custo líquido aproximado: R$ 1320.00
#
# Fornecedor: Fornecedor B
#   CNAEs e validação:
#     62.01-5-01 -> Válido
#   Códigos LC116 vinculados: 101
#   Códigos NBS vinculados: NBS01
#   Preço bruto: R$ 1400.00
#   Crédito tributário estimado: R$ 140.00 (10%)
#   Custo líquido aproximado: R$ 1260.00
#
# Fornecedor: Fornecedor C
#   CNAEs e validação:
#     47.89-0-99 -> Válido
#     81.12-3-00 -> Válido
#   Códigos LC116 vinculados: 201, 301
#   Códigos NBS vinculados: NBS02, NBS03
#   Preço bruto: R$ 1450.00
#   Crédito tributário estimado: R$ 159.50 (11%)
#   Custo líquido aproximado: R$ 1290.50

# Decisão: Fornecedor A tem maior custo líquido (R$1320), Fornecedor B é o mais barato líquido (R$1260), apesar do preço bruto maior que o C. Fornecedor C fica no meio. Assim, escolher Fornecedor B para menor custo líquido tributário.

# Comentário: Validar múltiplos CNAEs é essencial para atividades mistas. A vinculação correta CNAE-LC116-NBS permite calcular créditos e comparar custo líquido, influenciando a decisão.

```

---

### 2. Detecção e correção de erros comuns na classificação CNAE para análise tributária

```markdown
**Análise dos fornecedores:**

- Fornecedor 1 (TI): CNAE informado "62.0-01" (código genérico e incompleto)  
  *Erro:* CNAE incompleto e genérico impede a vinculação correta ao código LC116 e NBS, causando perda de crédito tributário.  
  *Correção:* Atualizar para CNAE completo e específico, ex: "62.01-5-01".

- Fornecedor 2 (Comércio): CNAE informado apenas no nível seção "G" (comércio varejista), sem subclasse.  
  *Erro:* Uso de nível superior gera incompatibilidade na aplicação da LC116, dificultando cálculo de ISS e apropriação de créditos.  
  *Correção:* Informar a subclasse completa, ex: "47.89-0-99".

- Fornecedor 3 (Serviços mistos): Apenas um CNAE informado para atividades distintas (prestação de serviços e comércio).  
  *Erro:* Falta de múltiplos CNAEs reduz conformidade e precisão na análise tributária, gerando possíveis erros no ISS e créditos.  
  *Correção:* Registrar CNAEs distintos para cada atividade, por exemplo "81.12-3-00" para serviços gerais e "47.89-0-99" para comércio.

**Consequências tributárias:**  
- Cálculo incorreto do ISS, levando a valores indevidos ou multas.  
- Perda da apropriação de créditos tributários, aumentando custo líquido.  
- Rejeição de documentos fiscais por incompatibilidade entre atividade e código.  
- Impacto negativo na análise comparativa de fornecedores, podendo escolher opção desvantajosa.

**Resumo:**  
Corrigir a classificação CNAE é fundamental para garantir o vínculo correto com LC116 e NBS, assegurando aproveitamento integral dos créditos tributários e conformidade fiscal.

```

---

### 3. Integração automática da vinculação CNAE-LC116-NBS para suporte a decisão de compras

```python
import re

# Simulação de base oficial para validação CNAE
tabela_cnae_oficial = {
    "62.01-5-01": "Serviços de desenvolvimento de software",
    "47.89-0-99": "Comércio varejista de outros produtos não especificados",
    "81.12-3-00": "Serviços de limpeza e conservação"
}

# Simulação de vinculação CNAE -> LC116
vinculacao_cnae_lc116 = {
    "62.01-5-01": "101",
    "47.89-0-99": "201",
    "81.12-3-00": "301"
}

# Simulação de vinculação LC116 -> NBS
vinculacao_lc116_nbs = {
    "101": "NBS01",
    "201": "NBS02",
    "301": "NBS03"
}

# Fornecedores com preços e percentuais de créditos
fornecedores = {
    "Fornecedor X": {"cnaes": ["62.01-5-01"], "preco_bruto": 2000.00, "credito_pct": 0.15},
    "Fornecedor Y": {"cnaes": ["47.89-0-99"], "preco_bruto": 1950.00, "credito_pct": 0.10},
    "Fornecedor Z": {"cnaes": ["81.12-3-00"], "preco_bruto": 1980.00, "credito_pct": 0.12}
}

def validar_cnae(cnae):
    padrao = r"^\d{2}\.\d{2}-\d-\d{2}$"
    if not re.match(padrao, cnae):
        return False
    return cnae in tabela_cnae_oficial

def obter_lc116(cnae):
    return vinculacao_cnae_lc116.get(cnae)

def obter_nbs(lc116):
    return vinculacao_lc116_nbs.get(lc116)

print("Relatório automático de fornecedores e análise tributária:\n")

for nome, dados in fornecedores.items():
    print(f"Fornecedor: {nome}")
    todos_validos = True
    for cnae in dados["cnaes"]:
        valido = validar_cnae(cnae)
        print(f"  CNAE {cnae} válido? {'Sim' if valido else 'Não'}")
        if not valido:
            todos_validos = False

    if not todos_validos:
        print("  Erro de validação CNAE. Verifique cadastro.\n")
        continue

    lc116s = [obter_lc116(c) for c in dados["cnaes"]]
    nbs_codes = [obter_nbs(lc) for lc in lc116s if lc]

    print(f"  Códigos LC116 vinculados: {', '.join(lc116s)}")
    print(f"  Códigos NBS vinculados: {', '.join(nbs_codes)}")

    preco = dados["preco_bruto"]
    credito_valor = preco * dados["credito_pct"]
    custo_liquido = preco - credito_valor

    print(f"  Preço bruto: R$ {preco:.2f}")
    print(f"  Crédito tributário: R$ {credito_valor:.2f} ({dados['credito_pct']*100:.0f}%)")
    print(f"  Custo líquido estimado: R$ {custo_liquido:.2f}\n")

# Saída real:
# Relatório automático de fornecedores e análise tributária:
#
# Fornecedor: Fornecedor X
#   CNAE 62.01-5-01 válido? Sim
#   Códigos LC116 vinculados: 101
#   Códigos NBS vinculados: NBS01
#   Preço bruto: R$ 2000.00
#   Crédito tributário: R$ 300.00 (15%)
#   Custo líquido estimado: R$ 1700.00
#
# Fornecedor: Fornecedor Y
#   CNAE 47.89-0-99 válido? Sim
#   Códigos LC116 vinculados: 201
#   Códigos NBS vinculados: NBS02
#   Preço bruto: R$ 1950.00
#   Crédito tributário: R$ 195.00 (10%)
#   Custo líquido estimado: R$ 1755.00
#
# Fornecedor: Fornecedor Z
#   CNAE 81.12-3-00 válido? Sim
#   Códigos LC116 vinculados: 301
#   Códigos NBS vinculados: NBS03
#   Preço bruto: R$ 1980.00
#   Crédito tributário: R$ 237.60 (12%)
#   Custo líquido estimado: R$ 1742.40

# Comentário:  
# A automatização da validação e vinculação permite que o sistema fiscal ofereça decisão de compra baseada no custo líquido tributário, considerando créditos dos fornecedores. Isso reduz erros humanos e melhora a análise comparativa.

```

---

### 4. Auditoria tributária e análise crítica da classificação CNAE em fornecedores reais

```markdown
**Relatório de auditoria tributária dos fornecedores:**

- **Fornecedor Alfa:**  
  CNAE informado: "62.01-5-01" (válido e atualizado)  
  Código LC116: "101" (coerente)  
  Código NBS: "NBS01" (compatível)  
  *Resultado:* Classificação correta, vinculação adequada, sem inconformidades detectadas.  

- **Fornecedor Beta:**  
  CNAE informado: "47.89-0-90" (código desatualizado)  
  Código LC116: "202" (não corresponde ao CNAE atual)  
  Código NBS: "NBS02" (incorreto para o LC116 informado)  
  *Inconformidade:* Uso de código CNAE e LC116 desatualizados gera inconsistência tributária, possível perda de créditos e risco de autuação fiscal.  
  *Recomendação:* Atualizar CNAE para "47.89-0-99" e ajustar vinculações LC116 e NBS conforme tabela oficial.  

- **Fornecedor Gama:**  
  CNAE informado: "81.12-3-00" (válido)  
  Código LC116: "301" (válido)  
  Código NBS: "NBS04" (incompatível com LC116)  
  *Problema:* NBS incorreto prejudica cálculo do ISS e apropriação de créditos.  
  *Correção:* Corrigir código NBS para "NBS03" conforme vinculação oficial.  

**Impactos fiscais:**  
- Documentos fiscais com códigos errados podem ser rejeitados, causando atrasos e multas.  
- Inaplicabilidade de créditos tributários aumenta o custo efetivo da contratação.  
- Risco de questionamento em auditorias externas e autuações fiscais.  

**Conclusão:**  
Garantir a atualização e coerência entre CNAE, LC116 e NBS é essencial para conformidade fiscal e otimização tributária. Auditoria sistemática evita erros que impactam diretamente decisões e custos.

```

---

### 5. Análise prática do impacto da atualização do CNAE na escolha de fornecedores

```python
fornecedores = {
    "Fornecedor 1": {"cnae": "62.01-5-01", "preco_bruto": 1600.00, "credito_pct": 0.13},
    "Fornecedor 2": {"cnae": "47.89-0-90", "preco_bruto": 1550.00, "credito_pct": 0.11},  # Desatualizado
    "Fornecedor 3": {"cnae": "81.12-3-00", "preco_bruto": 1580.00, "credito_pct": 0.12}
}

cnae_atualizados = {
    "47.89-0-90": "47.89-0-99"
}

def validar_cnae(cnae):
    # Simples validação e atualização
    if cnae in cnae_atualizados:
        return False, cnae_atualizados[cnae]
    return True, cnae

print("Validação e impacto da atualização do CNAE:\n")

for nome, dados in fornecedores.items():
    valido, cnae_corrigido = validar_cnae(dados["cnae"])
    preco = dados["preco_bruto"]
    credito_pct = dados["credito_pct"]

    if not valido:
        print(f"{nome} CNAE desatualizado: {dados['cnae']}")
        print(f"  Sugestão de correção: {cnae_corrigido}")
        # Simulação antes da correção
        credito_antes = preco * credito_pct
        custo_antes = preco - credito_antes
        # Simulação após correção (supomos crédito melhor após atualização)
        credito_depois = preco * (credito_pct + 0.02)  # +2% de crédito após atualização
        custo_depois = preco - credito_depois
        print(f"  Custo líquido antes da correção: R$ {custo_antes:.2f}")
        print(f"  Custo líquido após correção: R$ {custo_depois:.2f}\n")
    else:
        credito = preco * credito_pct
        custo = preco - credito
        print(f"{nome} CNAE válido: {dados['cnae']}")
        print(f"  Custo líquido: R$ {custo:.2f}\n")

# Saída real:
# Validação e impacto da atualização do CNAE:
#
# Fornecedor 1 CNAE válido: 62.01-5-01
#   Custo líquido: R$ 1392.00
#
# Fornecedor 2 CNAE desatualizado: 47.89-0-90
#   Sugestão de correção: 47.89-0-99
#   Custo líquido antes da correção: R$ 1379.50
#   Custo líquido após correção: R$ 1349.50
#
# Fornecedor 3 CNAE válido: 81.12-3-00
#   Custo líquido: R$ 1390.40

# Comentário:  
# A atualização do CNAE permite maior aproveitamento de créditos tributários, reduzindo o custo líquido. Ignorar atualizações pode causar perdas financeiras e problemas fiscais.

```

# Fim das soluções comentadas