## Exercícios — Código de Serviço LC116: Estrutura e Aplicação

### 1. Verificação de Atividades e Códigos LC116 Atualizados (intermediário)  
Você recebeu a lista abaixo com 5 fornecedores, seus respectivos CNAEs e atividades econômicas. Após a reforma tributária, a tabela de códigos LC116 foi atualizada. Para cada fornecedor:  
- Verifique se a atividade está sujeita ao ISS conforme a LC116 atualizada.  
- Indique o código LC116 correto atualizado para o serviço principal.  
- Justifique a vinculação entre o CNAE e o código LC116 escolhido, considerando também a integração com a NBS (não precisa informar o código NBS).  

| Fornecedor | CNAE       | Atividade Econômica                 |  
|------------|------------|------------------------------------|  
| AlphaTech  | 6203100    | Desenvolvimento de software sob encomenda |  
| BetaSaúde  | 8630400    | Serviços de atendimento hospitalar |  
| GamaEdu    | 8542100    | Ensino de cursos técnicos          |  
| DeltaEng   | 7111000    | Serviços de engenharia              |  
| EpsilonTra | 4924200    | Transporte rodoviário municipal de passageiros |  

### 2. Análise Hierárquica e Validação de Código LC116 (básico)  
Você tem os seguintes códigos LC116 atribuídos a serviços de informática:  
- 1012  
- 1020  
- 1045  
Para cada código:  
- Descreva o significado dos dígitos do código (categoria, subcategoria, serviço específico).  
- Verifique se o código pode ser aplicável para serviços de manutenção de software.  
- Explique se o código está correto ou se pode gerar erro fiscal e por quê.

### 3. Exclusão e Limitação de Serviços para ISS (desafio)  
Considere a lista abaixo de atividades econômicas com seus CNAEs, sabendo que algumas são excluídas do ISS pela LC116:  
- 4511101: Comércio varejista de automóveis novos  
- 6830200: Serviços de intermediação e agenciamento de serviços e negócios em geral, exceto imobiliários  
- 8299200: Atividades de cobrança e informações cadastrais  
- 7490200: Serviços de manutenção e reparação de máquinas e equipamentos industriais  
- 8122100: Atividades de limpeza em prédios e em domicílios  

Para cada CNAE:  
- Indique se está sujeita ao ISS pela LC116 pós-reforma.  
- Justifique se a atividade está excluída ou limitada e explique o motivo tributário.  
- Caso esteja sujeita, informe um possível código LC116 para a atividade.

### 4. Atualização e Impacto da Reforma na Vinculação CNAE x LC116 (intermediário)  
Você recebeu uma tabela antiga que vincula CNAEs a códigos LC116. Com as mudanças da reforma, alguns códigos foram descontinuados ou alterados. Dado o conjunto abaixo:  

| CNAE       | Código LC116 antigo | Atividade Econômica                   |  
|------------|---------------------|-------------------------------------|  
| 6201500    | 1013                | Desenvolvimento e licenciamento de programas de computador customizáveis |  
| 7112000    | 1105                | Serviços técnicos de arquitetura e urbanismo |  
| 8622300    | 0709                | Atividades de atendimento em pronto-socorro e unidades hospitalares de urgência |  

Faça:  
- Identifique quais códigos LC116 precisam ser atualizados.  
- Informe os códigos LC116 atualizados para essas atividades conforme a reforma.  
- Explique o impacto dessa atualização para a apuração do ISS e análise de créditos tributários.

### 5. Comparação Tributária para Escolha de Fornecedor (desafio)  
Você tem duas propostas de fornecedores para um serviço de consultoria em tecnologia da informação, ambos com atividades sujeitas ao ISS:  

| Fornecedor | CNAE       | Preço bruto (R$) | Código LC116 | Crédito tributário (R$) |  
|------------|------------|------------------|--------------|-------------------------|  
| ConsultA   | 6203100    | 12.000,00        | 1014         | 1.800,00                |  
| ConsultB   | 6203100    | 11.500,00        | 1014         | 1.100,00                |  

- Calcule o custo líquido para cada fornecedor considerando o crédito tributário.  
- Explique qual fornecedor é mais vantajoso economicamente para a empresa, considerando o custo líquido.  
- Justifique a importância da correta vinculação do CNAE ao código LC116 para essa análise.  

---

## Soluções comentadas

### 1. Verificação de Atividades e Códigos LC116 Atualizados

```python
# Dados fornecidos
fornecedores = [
    {"nome": "AlphaTech", "cnae": "6203100", "atividade": "Desenvolvimento de software sob encomenda"},
    {"nome": "BetaSaúde", "cnae": "8630400", "atividade": "Serviços de atendimento hospitalar"},
    {"nome": "GamaEdu", "cnae": "8542100", "atividade": "Ensino de cursos técnicos"},
    {"nome": "DeltaEng", "cnae": "7111000", "atividade": "Serviços de engenharia"},
    {"nome": "EpsilonTra", "cnae": "4924200", "atividade": "Transporte rodoviário municipal de passageiros"},
]

# Simulação de função para verificar ISS e código LC116 atualizado
def verifica_iss_e_codigo(cnae):
    # Apenas exemplos simplificados para exercício
    iss_sujeito = False
    codigo_lc116 = None
    justificativa = ""
    
    # Serviços sujeitos ao ISS (exemplos simplificados)
    cnae_iss = {
        "6203100": "1014",  # Desenvolvimento de software sob encomenda
        "8630400": "0711",  # Serviços hospitalares
        "8542100": "0601",  # Ensino técnico
        "7111000": "1101",  # Serviços de engenharia
        # Transporte municipal geralmente não sujeito ao ISS
    }
    
    # Atividades sujeitas ao ISS
    if cnae in cnae_iss:
        iss_sujeito = True
        codigo_lc116 = cnae_iss[cnae]
        justificativa = ("O CNAE representa atividade de serviço sujeita ao ISS conforme lista atualizada da LC116, "
                         "e o código LC116 vinculado é o correspondente ao serviço específico, "
                         "facilitando integração com NBS e cálculo correto do imposto.")
    else:
        justificativa = ("Atividade não está sujeita ao ISS conforme LC116 atualizada, "
                         "pois transporte municipal de passageiros é excluído do ISS, "
                         "sendo tributado por outros regimes.")
    return iss_sujeito, codigo_lc116, justificativa

# Apresentação dos resultados
for f in fornecedores:
    iss, cod, just = verifica_iss_e_codigo(f["cnae"])
    print(f"Fornecedor: {f['nome']}")
    print(f"  CNAE: {f['cnae']} - {f['atividade']}")
    print(f"  Sujeito ao ISS? {'Sim' if iss else 'Não'}")
    if iss:
        print(f"  Código LC116 atualizado: {cod}")
    print(f"  Justificativa: {just}\n")
```

**Saída real esperada:**  
```
Fornecedor: AlphaTech
  CNAE: 6203100 - Desenvolvimento de software sob encomenda
  Sujeito ao ISS? Sim
  Código LC116 atualizado: 1014
  Justificativa: O CNAE representa atividade de serviço sujeita ao ISS conforme lista atualizada da LC116, e o código LC116 vinculado é o correspondente ao serviço específico, facilitando integração com NBS e cálculo correto do imposto.

Fornecedor: BetaSaúde
  CNAE: 8630400 - Serviços de atendimento hospitalar
  Sujeito ao ISS? Sim
  Código LC116 atualizado: 0711
  Justificativa: O CNAE representa atividade de serviço sujeita ao ISS conforme lista atualizada da LC116, e o código LC116 vinculado é o correspondente ao serviço específico, facilitando integração com NBS e cálculo correto do imposto.

Fornecedor: GamaEdu
  CNAE: 8542100 - Ensino de cursos técnicos
  Sujeito ao ISS? Sim
  Código LC116 atualizado: 0601
  Justificativa: O CNAE representa atividade de serviço sujeita ao ISS conforme lista atualizada da LC116, e o código LC116 vinculado é o correspondente ao serviço específico, facilitando integração com NBS e cálculo correto do imposto.

Fornecedor: DeltaEng
  CNAE: 7111000 - Serviços de engenharia
  Sujeito ao ISS? Sim
  Código LC116 atualizado: 1101
  Justificativa: O CNAE representa atividade de serviço sujeita ao ISS conforme lista atualizada da LC116, e o código LC116 vinculado é o correspondente ao serviço específico, facilitando integração com NBS e cálculo correto do imposto.

Fornecedor: EpsilonTra
  CNAE: 4924200 - Transporte rodoviário municipal de passageiros
  Sujeito ao ISS? Não
  Justificativa: Atividade não está sujeita ao ISS conforme LC116 atualizada, pois transporte municipal de passageiros é excluído do ISS, sendo tributado por outros regimes.
```

**Decisão:**  
- Usei um dicionário simplificado para associar CNAE a código LC116 atualizado.  
- Transporte municipal está excluído do ISS, justifica não sujeição.  
- Vinculação justificada pela integração com NBS e necessidade de código atualizado para cálculo correto do ISS e créditos.

---

### 2. Análise Hierárquica e Validação de Código LC116

```python
# Lista dos códigos para análise
codigos = ["1012", "1020", "1045"]

def interpreta_codigo_lc116(codigo):
    categoria = codigo[0]
    subcategoria = codigo[1:3]
    servico = codigo[3]
    
    interpretacao = (
        f"Código LC116: {codigo}\n"
        f"  Categoria (1º dígito): {categoria}\n"
        f"  Subcategoria (2º e 3º dígitos): {subcategoria}\n"
        f"  Serviço específico (4º dígito): {servico}\n"
    )
    
    # Suposição: categoria '1' = Informática e Tecnologia
    # Códigos para manutenção de software geralmente terminam em '2' ou '4' (exemplo)
    if categoria == '1':
        if servico in ['2', '4']:
            interpretacao += "  Aplicável para serviços de manutenção de software.\n"
        else:
            interpretacao += "  Serviço não específico para manutenção de software, pode gerar erro fiscal.\n"
    else:
        interpretacao += "  Categoria não corresponde a serviços de informática.\n"
    
    return interpretacao

for c in codigos:
    print(interpreta_codigo_lc116(c))
```

**Saída real esperada:**  
```
Código LC116: 1012
  Categoria (1º dígito): 1
  Subcategoria (2º e 3º dígitos): 01
  Serviço específico (4º dígito): 2
  Aplicável para serviços de manutenção de software.

Código LC116: 1020
  Categoria (1º dígito): 1
  Subcategoria (2º e 3º dígitos): 02
  Serviço específico (4º dígito): 0
  Serviço não específico para manutenção de software, pode gerar erro fiscal.

Código LC116: 1045
  Categoria (1º dígito): 1
  Subcategoria (2º e 3º dígitos): 04
  Serviço específico (4º dígito): 5
  Serviço não específico para manutenção de software, pode gerar erro fiscal.
```

**Decisão:**  
- Expliquei hierarquia do código.  
- Identifiquei que códigos terminando em dígitos específicos indicam serviços detalhados.  
- Códigos genéricos ou incorretos podem causar erro fiscal, pois o ISS deve ser apurado com código correto para o serviço.

---

### 3. Exclusão e Limitação de Serviços para ISS

```python
atividades = [
    {"cnae": "4511101", "descricao": "Comércio varejista de automóveis novos"},
    {"cnae": "6830200", "descricao": "Serviços de intermediação e agenciamento de serviços e negócios em geral, exceto imobiliários"},
    {"cnae": "8299200", "descricao": "Atividades de cobrança e informações cadastrais"},
    {"cnae": "7490200", "descricao": "Serviços de manutenção e reparação de máquinas e equipamentos industriais"},
    {"cnae": "8122100", "descricao": "Atividades de limpeza em prédios e em domicílios"},
]

def verifica_iss_exclusao(cnae):
    excluidos = ["4511101"]  # Comércio de mercadorias excluído do ISS
    # Transporte interestadual, atividades financeiras, mercadorias excluídas em geral
    
    if cnae in excluidos:
        return False, "Atividade relacionada a comércio de mercadorias, excluída do ISS."
    
    # Serviços de intermediação e agenciamento são sujeitos ao ISS
    # Cobrança e informações cadastrais sujeitas ao ISS
    # Manutenção industrial sujeita ao ISS
    # Limpeza sujeita ao ISS
    
    # Exemplo de códigos LC116 possíveis (simplificado)
    codigos_lc116 = {
        "6830200": "0902",
        "8299200": "1001",
        "7490200": "1203",
        "8122100": "1301",
    }
    
    if cnae in codigos_lc116:
        return True, f"Atividade sujeita ao ISS, código LC116 possível: {codigos_lc116[cnae]}"
    else:
        return False, "Atividade excluída do ISS ou não identificada na lista."

for a in atividades:
    sujeito, justificativa = verifica_iss_exclusao(a["cnae"])
    print(f"CNAE: {a['cnae']} - {a['descricao']}")
    print(f"  Sujeito ao ISS? {'Sim' if sujeito else 'Não'}")
    print(f"  Justificativa: {justificativa}\n")
```

**Saída real esperada:**  
```
CNAE: 4511101 - Comércio varejista de automóveis novos
  Sujeito ao ISS? Não
  Justificativa: Atividade relacionada a comércio de mercadorias, excluída do ISS.

CNAE: 6830200 - Serviços de intermediação e agenciamento de serviços e negócios em geral, exceto imobiliários
  Sujeito ao ISS? Sim
  Justificativa: Atividade sujeita ao ISS, código LC116 possível: 0902

CNAE: 8299200 - Atividades de cobrança e informações cadastrais
  Sujeito ao ISS? Sim
  Justificativa: Atividade sujeita ao ISS, código LC116 possível: 1001

CNAE: 7490200 - Serviços de manutenção e reparação de máquinas e equipamentos industriais
  Sujeito ao ISS? Sim
  Justificativa: Atividade sujeita ao ISS, código LC116 possível: 1203

CNAE: 8122100 - Atividades de limpeza em prédios e em domicílios
  Sujeito ao ISS? Sim
  Justificativa: Atividade sujeita ao ISS, código LC116 possível: 1301
```

**Decisão:**  
- Expliquei exclusão de mercadorias do ISS.  
- Mostrei exemplos de códigos LC116 para serviços sujeitos.  
- Justifiquei conforme regras da LC116 e exclusões pós-reforma.

---

### 4. Atualização e Impacto da Reforma na Vinculação CNAE x LC116

```python
tabela_antiga = [
    {"cnae": "6201500", "lc116_antigo": "1013", "atividade": "Desenvolvimento e licenciamento de programas de computador customizáveis"},
    {"cnae": "7112000", "lc116_antigo": "1105", "atividade": "Serviços técnicos de arquitetura e urbanismo"},
    {"cnae": "8622300", "lc116_antigo": "0709", "atividade": "Atividades de atendimento em pronto-socorro e unidades hospitalares de urgência"},
]

# Tabela de códigos LC116 atualizados pós reforma (exemplos)
atualizacao_lc116 = {
    "1013": "1014",  # Ajuste para desenvolvimento de software
    "1105": "1101",  # Padronização em arquitetura
    "0709": "0711",  # Atualização para pronto-socorro
}

for item in tabela_antiga:
    antigo = item["lc116_antigo"]
    atualizado = atualizacao_lc116.get(antigo, antigo)
    print(f"CNAE: {item['cnae']} - {item['atividade']}")
    if antigo != atualizado:
        print(f"  Código LC116 antigo: {antigo}")
        print(f"  Código LC116 atualizado: {atualizado}")
        print("  Impacto: Atualização garante conformidade fiscal, evita erros na apuração do ISS e permite apropriação correta de créditos tributários.")
    else:
        print(f"  Código LC116 mantido: {antigo}")
        print("  Impacto: Sem mudança no código, mas deve-se validar atualização da tabela para garantir conformidade.")
    print()
```

**Saída real esperada:**  
```
CNAE: 6201500 - Desenvolvimento e licenciamento de programas de computador customizáveis
  Código LC116 antigo: 1013
  Código LC116 atualizado: 1014
  Impacto: Atualização garante conformidade fiscal, evita erros na apuração do ISS e permite apropriação correta de créditos tributários.

CNAE: 7112000 - Serviços técnicos de arquitetura e urbanismo
  Código LC116 antigo: 1105
  Código LC116 atualizado: 1101
  Impacto: Atualização garante conformidade fiscal, evita erros na apuração do ISS e permite apropriação correta de créditos tributários.

CNAE: 8622300 - Atividades de atendimento em pronto-socorro e unidades hospitalares de urgência
  Código LC116 antigo: 0709
  Código LC116 atualizado: 0711
  Impacto: Atualização garante conformidade fiscal, evita erros na apuração do ISS e permite apropriação correta de créditos tributários.
```

**Decisão:**  
- Mostrei necessidade da atualização para evitar erros fiscais.  
- Expliquei impacto prático na apuração do imposto e créditos.  
- Reforcei a importância da manutenção contínua da tabela LC116 pós-reforma.

---

### 5. Comparação Tributária para Escolha de Fornecedor

```python
# Dados dos fornecedores
fornecedores = [
    {"nome": "ConsultA", "cnae": "6203100", "preco_bruto": 12000.00, "lc116": "1014", "credito": 1800.00},
    {"nome": "ConsultB", "cnae": "6203100", "preco_bruto": 11500.00, "lc116": "1014", "credito": 1100.00},
]

def custo_liquido(preco_bruto, credito):
    return preco_bruto - credito

for f in fornecedores:
    liquido = custo_liquido(f["preco_bruto"], f["credito"])
    print(f"Fornecedor: {f['nome']}")
    print(f"  Preço bruto: R$ {f['preco_bruto']:.2f}")
    print(f"  Crédito tributário: R$ {f['credito']:.2f}")
    print(f"  Custo líquido: R$ {liquido:.2f}\n")

# Comparação
custo_a = custo_liquido(fornecedores[0]["preco_bruto"], fornecedores[0]["credito"])
custo_b = custo_liquido(fornecedores[1]["preco_bruto"], fornecedores[1]["credito"])

if custo_a < custo_b:
    melhor = fornecedores[0]["nome"]
else:
    melhor = fornecedores[1]["nome"]

print(f"O fornecedor mais vantajoso economicamente é: {melhor}")
print("\nJustificativa:")
print("A correta vinculação do CNAE ao código LC116 permite identificar o crédito tributário aplicável ao serviço,")
print("o que afeta diretamente o custo líquido final para a empresa. Ignorar essa vinculação poderia levar à escolha")
print("do fornecedor com menor preço bruto, ignorando benefícios fiscais que reduzem o custo efetivo.")
```

**Saída real esperada:**  
```
Fornecedor: ConsultA
  Preço bruto: R$ 12000.00
  Crédito tributário: R$ 1800.00
  Custo líquido: R$ 10200.00

Fornecedor: ConsultB
  Preço bruto: R$ 11500.00
  Crédito tributário: R$ 1100.00
  Custo líquido: R$ 10400.00

O fornecedor mais vantajoso economicamente é: ConsultA

Justificativa:
A correta vinculação do CNAE ao código LC116 permite identificar o crédito tributário aplicável ao serviço,
o que afeta diretamente o custo líquido final para a empresa. Ignorar essa vinculação poderia levar à escolha
do fornecedor com menor preço bruto, ignorando benefícios fiscais que reduzem o custo efetivo.
```

**Decisão:**  
- Demonstrei cálculo do custo líquido com crédito tributário.  
- Mostrei que maior crédito pode compensar preço bruto maior.  
- Reforcei importância da vinculação correta CNAE x LC116 para análise tributária e decisão de compra.