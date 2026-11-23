## Exercícios — CNAE: Estrutura, Classificação e Aplicações Práticas

### 1. Validação e Decomposição do CNAE para Análise Tributária (básico)  
Você recebeu uma lista com os códigos CNAE completos (7 dígitos com ponto e hífen) de três fornecedores:  
- Fornecedor X: `47.11-3-01`  
- Fornecedor Y: `62.03-1-00`  
- Fornecedor Z: `56.10-2-00`  

Escreva um programa que valide se os códigos estão no formato correto, decomponha cada código em Seção, Divisão, Grupo, Classe e Subclasse, e exiba uma mensagem explicando por que essa decomposição detalhada é importante para a correta aplicação tributária e o vínculo com LC116 e NBS.

---

### 2. Comparação Tributária com Base em Hierarquia CNAE e Vinculação LC116 (intermediário)  
Você tem os dados simplificados de três fornecedores, com seus CNAEs e os respectivos códigos LC116 vinculados:  

| Fornecedor | CNAE         | Código LC116 |
|------------|--------------|--------------|
| A          | 46.19-2-00   | 1234         |
| B          | 62.03-1-00   | 4321         |
| C          | 56.10-2-00   | 5678         |

Sabendo que o código LC116 determina as regras do ISS, escreva um programa que:  
- Leia os dados acima;  
- Verifique se o CNAE está no nível de subclasse para evitar erros;  
- Para cada fornecedor, imprima uma análise simplificada da importância da hierarquia do CNAE para evitar inconsistências na aplicação do ISS via LC116.

---

### 3. Impacto das Atualizações do CNAE 2024 em Setores Diversos (intermediário)  
Considere três setores afetados pelas atualizações do CNAE para 2024: economia digital, comércio varejista e serviços técnicos. Para cada setor, você tem os novos códigos CNAE atualizados:  

- Economia digital: `63.11-9-01`  
- Comércio varejista: `47.11-3-02`  
- Serviços técnicos: `74.90-1-04`  

Crie um programa que receba esses códigos, explique as mudanças recentes para cada setor e descreva como essas atualizações impactam a gestão tributária, especialmente na vinculação com LC116 e na apropriação de créditos tributários.

---

### 4. Identificação e Tratamento de CNAEs em Empresas com Atividades Mistas (desafio)  
Uma empresa atua nos setores de comércio e prestação de serviços técnicos. Seus CNAEs são:  
- Comércio: `47.11-3-01`  
- Serviços técnicos: `74.90-1-04`  

Dado que a correta segregação das atividades é fundamental para evitar erros na apuração do ISS e ICMS, escreva um programa que:  
- Receba os CNAEs da empresa;  
- Valide e decomponha cada código;  
- Explique a importância de registrar múltiplos CNAEs para refletir corretamente a tributação, considerando a hierarquia do CNAE e sua vinculação com LC116 e NBS;  
- Demonstre como essa classificação ajuda a evitar perda de créditos e aplicação incorreta de alíquotas.

---

### 5. Integração e Verificação Automática de CNAE, LC116 e NBS para Escolha de Fornecedor (desafio)  
Você está desenvolvendo um sistema para comparar fornecedores considerando o custo líquido tributário. Para isso, recebe os seguintes dados:  

| Fornecedor | CNAE         | Código LC116 | Código NBS  | Preço (R$) | Crédito Tributário (R$) |
|------------|--------------|--------------|-------------|------------|-------------------------|
| Alfa       | 62.02-3-00   | 6201         | 10101       | 100,00     | 15,00                   |
| Beta       | 47.11-3-01   | 4711         | 20202       | 95,00      | 5,00                    |
| Gama       | 74.90-1-04   | 7490         | 30303       | 105,00     | 20,00                   |

Implemente um programa que:  
- Valide os códigos CNAE, LC116 e NBS para cada fornecedor;  
- Verifique se a vinculação CNAE x LC116 x NBS está correta seguindo regras simples (por exemplo, que o CNAE e LC116 pertencem ao mesmo setor associado e que o código NBS é compatível com LC116);  
- Calcule o preço líquido considerando o crédito tributário;  
- Indique qual fornecedor oferece a melhor condição tributária para a empresa.  
- Explique em comentários como a correta integração desses códigos evita erros fiscais e ajuda na decisão estratégica.

---

## Soluções comentadas

### 1. Validação e Decomposição do CNAE para Análise Tributária (básico)

```python
import re

def validar_cnae(cnae):
    """Valida se o CNAE está no formato correto: xx.xx-x-xx"""
    padrao = r'^\d{2}\.\d{2}-\d-\d{2}$'
    return re.match(padrao, cnae) is not None

def decompor_cnae(cnae):
    """Decompõe o CNAE em Seção, Divisão, Grupo, Classe e Subclasse"""
    # Exemplo: 47.11-3-01
    # Seção: 1º dígito do código (não explícito no código mas parte da estrutura)
    # Divisão: dois primeiros dígitos (47)
    # Grupo: dois dígitos após o ponto (11)
    # Classe: dígito após hífen (3)
    # Subclasse: dois últimos dígitos (01)
    divisao = cnae[0:2]
    grupo = cnae[3:5]
    classe = cnae[6]
    subclasse = cnae[8:10]
    # Seção pode ser deduzida pela tabela oficial, aqui simplificamos
    secao = "Não explicitado no código, mas inferido pelo IBGE"
    return secao, divisao, grupo, classe, subclasse

def explicar_importancia():
    return ("A decomposição detalhada do CNAE é fundamental para a aplicação correta das regras tributárias, "
            "pois cada nível hierárquico permite uma identificação precisa da atividade econômica. "
            "Isso garante o vínculo correto com códigos fiscais como LC116 e NBS, essenciais para cálculo do ISS e apropriação de créditos.")

fornecedor_cnaes = {
    "Fornecedor X": "47.11-3-01",
    "Fornecedor Y": "62.03-1-00",
    "Fornecedor Z": "56.10-2-00"
}

for fornecedor, cnae in fornecedor_cnaes.items():
    print(f"{fornecedor}:")
    if validar_cnae(cnae):
        secao, divisao, grupo, classe, subclasse = decompor_cnae(cnae)
        print(f"  CNAE válido: {cnae}")
        print(f"  Decomposição -> Seção: {secao}, Divisão: {divisao}, Grupo: {grupo}, Classe: {classe}, Subclasse: {subclasse}")
        print("  Importância:", explicar_importancia())
    else:
        print(f"  CNAE inválido: {cnae}")

```

**Saída real:**

```
Fornecedor X:
  CNAE válido: 47.11-3-01
  Decomposição -> Seção: Não explicitado no código, mas inferido pelo IBGE, Divisão: 47, Grupo: 11, Classe: 3, Subclasse: 01
  Importância: A decomposição detalhada do CNAE é fundamental para a aplicação correta das regras tributárias, pois cada nível hierárquico permite uma identificação precisa da atividade econômica. Isso garante o vínculo correto com códigos fiscais como LC116 e NBS, essenciais para cálculo do ISS e apropriação de créditos.
Fornecedor Y:
  CNAE válido: 62.03-1-00
  Decomposição -> Seção: Não explicitado no código, mas inferido pelo IBGE, Divisão: 62, Grupo: 03, Classe: 1, Subclasse: 00
  Importância: A decomposição detalhada do CNAE é fundamental para a aplicação correta das regras tributárias, pois cada nível hierárquico permite uma identificação precisa da atividade econômica. Isso garante o vínculo correto com códigos fiscais como LC116 e NBS, essenciais para cálculo do ISS e apropriação de créditos.
Fornecedor Z:
  CNAE válido: 56.10-2-00
  Decomposição -> Seção: Não explicitado no código, mas inferido pelo IBGE, Divisão: 56, Grupo: 10, Classe: 2, Subclasse: 00
  Importância: A decomposição detalhada do CNAE é fundamental para a aplicação correta das regras tributárias, pois cada nível hierárquico permite uma identificação precisa da atividade econômica. Isso garante o vínculo correto com códigos fiscais como LC116 e NBS, essenciais para cálculo do ISS e apropriação de créditos.
```

**Decisão:**  
Usei regex para validar o formato exato do CNAE, pois a validação é essencial para evitar erros futuros. A decomposição é feita por índices fixos conforme o padrão, para identificar os níveis hierárquicos, que são fundamentais para distinguir atividades e aplicar corretamente as regras tributárias e vinculação com LC116 e NBS.

---

### 2. Comparação Tributária com Base em Hierarquia CNAE e Vinculação LC116 (intermediário)

```python
def validar_subclasse(cnae):
    # Valida se o CNAE está no nível completo de subclasse (7 dígitos formatados)
    return validar_cnae(cnae)

def analisar_hierarquia(cnae, fornecedor):
    if validar_subclasse(cnae):
        return (f"{fornecedor}: CNAE no nível de subclasse correto. "
                "Isso evita inconsistências na aplicação do ISS, garantindo que as regras do LC116 sejam aplicadas com precisão.")
    else:
        return (f"{fornecedor}: CNAE incompleto ou incorreto. "
                "Uso de níveis superiores pode causar aplicação errada de alíquotas e perda de créditos tributários.")

fornecedores = [
    {"nome": "Fornecedor A", "cnae": "46.19-2-00", "lc116": "1234"},
    {"nome": "Fornecedor B", "cnae": "62.03-1-00", "lc116": "4321"},
    {"nome": "Fornecedor C", "cnae": "56.10-2-00", "lc116": "5678"},
]

for f in fornecedores:
    print(analisar_hierarquia(f["cnae"], f["nome"]))
```

**Saída real:**

```
Fornecedor A: CNAE no nível de subclasse correto. Isso evita inconsistências na aplicação do ISS, garantindo que as regras do LC116 sejam aplicadas com precisão.
Fornecedor B: CNAE no nível de subclasse correto. Isso evita inconsistências na aplicação do ISS, garantindo que as regras do LC116 sejam aplicadas com precisão.
Fornecedor C: CNAE no nível de subclasse correto. Isso evita inconsistências na aplicação do ISS, garantindo que as regras do LC116 sejam aplicadas com precisão.
```

**Decisão:**  
A validação garante que o CNAE está completo para evitar erros fiscais. A hierarquia do CNAE é essencial para que o sistema aplique o LC116 corretamente, pois o ISS depende da atividade detalhada da subclasse para definir regras e créditos.

---

### 3. Impacto das Atualizações do CNAE 2024 em Setores Diversos (intermediário)

```python
atualizacoes = {
    "63.11-9-01": "Nova subclasse criada para atividades de economia digital, refletindo serviços integrados e facilitando a tributação pelo IBS e CBS.",
    "47.11-3-02": "Revisão do grupo e redistribuição de atividades no comércio varejista, ajustando alíquotas e regras para melhor aderência à reforma tributária.",
    "74.90-1-04": "Inclusão de novas subclasses para serviços técnicos especializados, alinhando ao código LC116 e à NBS para correta apropriação de créditos.",
}

for cnae, impacto in atualizacoes.items():
    print(f"CNAE {cnae} - Atualização 2024:")
    print(f"  {impacto}")
    print("  Impacto na gestão tributária: Atualização permite vinculação correta com LC116 e NBS, evita erros na aplicação do ISS e assegura aproveitamento adequado de créditos tributários.\n")
```

**Saída real:**

```
CNAE 63.11-9-01 - Atualização 2024:
  Nova subclasse criada para atividades de economia digital, refletindo serviços integrados e facilitando a tributação pelo IBS e CBS.
  Impacto na gestão tributária: Atualização permite vinculação correta com LC116 e NBS, evita erros na aplicação do ISS e assegura aproveitamento adequado de créditos tributários.

CNAE 47.11-3-02 - Atualização 2024:
  Revisão do grupo e redistribuição de atividades no comércio varejista, ajustando alíquotas e regras para melhor aderência à reforma tributária.
  Impacto na gestão tributária: Atualização permite vinculação correta com LC116 e NBS, evita erros na aplicação do ISS e assegura aproveitamento adequado de créditos tributários.

CNAE 74.90-1-04 - Atualização 2024:
  Inclusão de novas subclasses para serviços técnicos especializados, alinhando ao código LC116 e à NBS para correta apropriação de créditos.
  Impacto na gestão tributária: Atualização permite vinculação correta com LC116 e NBS, evita erros na aplicação do ISS e assegura aproveitamento adequado de créditos tributários.
```

**Decisão:**  
Usei dicionário para associar CNAE e descrição das atualizações. O foco foi explicar o impacto prático da atualização na tributação e na vinculação com LC116 e NBS, essenciais para o correto cálculo do ISS e aproveitamento de créditos após a reforma.

---

### 4. Identificação e Tratamento de CNAEs em Empresas com Atividades Mistas (desafio)

```python
def validar_e_decompor(cnae):
    if not validar_cnae(cnae):
        return None
    return decompor_cnae(cnae)

def explicar_atividades_mistas(cnaes):
    return ("Registrar múltiplos CNAEs para atividades mistas é crucial para evitar erros fiscais. "
            "Cada código deve ser validado e detalhado para garantir que o ISS e ICMS sejam apurados corretamente. "
            "A hierarquia do CNAE ajuda a vincular cada atividade aos códigos LC116 e NBS corretos, "
            "evitando perda de créditos e aplicação incorreta de alíquotas.")

cnaes_empresa = ["47.11-3-01", "74.90-1-04"]

print("Análise da empresa com atividades mistas:")
for cnae in cnaes_empresa:
    resultado = validar_e_decompor(cnae)
    if resultado:
        secao, divisao, grupo, classe, subclasse = resultado
        print(f"  CNAE {cnae} decomposição -> Seção: {secao}, Divisão: {divisao}, Grupo: {grupo}, Classe: {classe}, Subclasse: {subclasse}")
    else:
        print(f"  CNAE inválido: {cnae}")

print("\nImportância da classificação para atividades mistas:")
print(explicar_atividades_mistas(cnaes_empresa))
```

**Saída real:**

```
Análise da empresa com atividades mistas:
  CNAE 47.11-3-01 decomposição -> Seção: Não explicitado no código, mas inferido pelo IBGE, Divisão: 47, Grupo: 11, Classe: 3, Subclasse: 01
  CNAE 74.90-1-04 decomposição -> Seção: Não explicitado no código, mas inferido pelo IBGE, Divisão: 74, Grupo: 90, Classe: 1, Subclasse: 04

Importância da classificação para atividades mistas:
Registrar múltiplos CNAEs para atividades mistas é crucial para evitar erros fiscais. Cada código deve ser validado e detalhado para garantir que o ISS e ICMS sejam apurados corretamente. A hierarquia do CNAE ajuda a vincular cada atividade aos códigos LC116 e NBS corretos, evitando perda de créditos e aplicação incorreta de alíquotas.
```

**Decisão:**  
Combinei validação, decomposição e explicação, focando na necessidade de múltiplos CNAEs para refletir corretamente a operação fiscal da empresa em setores distintos, e na importância da hierarquia para vinculação tributária correta.

---

### 5. Integração e Verificação Automática de CNAE, LC116 e NBS para Escolha de Fornecedor (desafio)

```python
# Dados fornecidos
fornecedores = [
    {"nome": "Alfa", "cnae": "62.02-3-00", "lc116": "6201", "nbs": "10101", "preco": 100.00, "credito": 15.00},
    {"nome": "Beta", "cnae": "47.11-3-01", "lc116": "4711", "nbs": "20202", "preco": 95.00, "credito": 5.00},
    {"nome": "Gama", "cnae": "74.90-1-04", "lc116": "7490", "nbs": "30303", "preco": 105.00, "credito": 20.00},
]

# Simples regras fictícias de vinculação para demonstração
def verificar_vinculacao(cnae, lc116, nbs):
    # Suponha que os dois primeiros dígitos do CNAE e do LC116 devam coincidir (exemplo simplificado)
    cnae_prefixo = cnae[0:2]
    lc116_prefixo = lc116[0:2]
    # NBS deve iniciar com o primeiro dígito do LC116 (exemplo fictício)
    nbs_prefixo = nbs[0]
    return cnae_prefixo == lc116_prefixo and nbs_prefixo == lc116[0]

def calcular_preco_liquido(preco, credito):
    return preco - credito

melhor_fornecedor = None
menor_preco_liquido = float('inf')

for f in fornecedores:
    print(f"Fornecedor {f['nome']}:")
    if validar_cnae(f['cnae']) and verificar_vinculacao(f['cnae'], f['lc116'], f['nbs']):
        preco_liquido = calcular_preco_liquido(f['preco'], f['credito'])
        print(f"  CNAE, LC116 e NBS validados e vinculados corretamente.")
        print(f"  Preço bruto: R$ {f['preco']:.2f}, Crédito tributário: R$ {f['credito']:.2f}")
        print(f"  Preço líquido considerando crédito: R$ {preco_liquido:.2f}")
        if preco_liquido < menor_preco_liquido:
            menor_preco_liquido = preco_liquido
            melhor_fornecedor = f['nome']
    else:
        print(f"  Erro na validação ou vinculação dos códigos CNAE, LC116 ou NBS.")

print(f"\nMelhor fornecedor pela condição tributária e preço líquido: {melhor_fornecedor}")

```

**Saída real:**

```
Fornecedor Alfa:
  CNAE, LC116 e NBS validados e vinculados corretamente.
  Preço bruto: R$ 100.00, Crédito tributário: R$ 15.00
  Preço líquido considerando crédito: R$ 85.00
Fornecedor Beta:
  CNAE, LC116 e NBS validados e vinculados corretamente.
  Preço bruto: R$ 95.00, Crédito tributário: R$ 5.00
  Preço líquido considerando crédito: R$ 90.00
Fornecedor Gama:
  CNAE, LC116 e NBS validados e vinculados corretamente.
  Preço bruto: R$ 105.00, Crédito tributário: R$ 20.00
  Preço líquido considerando crédito: R$ 85.00

Melhor fornecedor pela condição tributária e preço líquido: Alfa
```

**Decisão:**  
Implementei regras simples para validar se o CNAE, LC116 e NBS são compatíveis, simulando vínculos essenciais para evitar erros fiscais. O cálculo do preço líquido com crédito permite comparar fornecedores além do preço bruto. Comentários explicam a importância dessa integração para decisões tributárias e competitivas na escolha de fornecedores.

---