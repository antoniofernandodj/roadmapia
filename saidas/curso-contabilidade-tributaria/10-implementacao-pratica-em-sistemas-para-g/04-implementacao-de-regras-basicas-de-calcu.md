## Implementação de Regras Básicas de Cálculo Tributário em Sistemas

Ao construir sistemas para gestão tributária, especialmente após a reforma, a implementação prática das regras de cálculo do ISS, IBS e CBS é fundamental para garantir a correta apuração do custo líquido tributário dos fornecedores. O desafio é automatizar a vinculação dos códigos CNAE, LC116 e NBS para validar a tributação aplicável, calcular os tributos e aplicar os créditos, resultando em uma base para comparação econômica entre fornecedores.

### Estrutura Geral para Implementação

A partir do CNAE informado para o fornecedor, o sistema deve:

1. Validar que o CNAE esteja correto e atualizado.
2. Vincular o CNAE ao código de serviço LC116 correspondente.
3. Vincular o código LC116 ao código NBS.
4. Identificar a alíquota e base de cálculo para ISS, IBS e CBS conforme a legislação vigente.
5. Calcular os tributos e aplicar os créditos tributários permitidos.
6. Retornar o custo líquido tributário para comparação.

### Modelando os Dados para Vinculação e Cálculo

Para ilustrar, vamos criar classes básicas em Python que representam CNAE, LC116 e NBS, e tabelas simuladas para alíquotas e créditos. A partir dessa estrutura, implementaremos as funções de validação e cálculo.

```python
from dataclasses import dataclass

@dataclass
class CNAE:
    codigo: str
    descricao: str
    lc116_codigo: str  # Código LC116 vinculado

@dataclass
class LC116:
    codigo: str
    descricao: str
    nbs_codigo: str  # Código NBS vinculado
    aliquota_iss: float  # Alíquota percentual ISS

@dataclass
class NBS:
    codigo: str
    descricao: str
    aliquota_ibs: float  # Alíquota percentual IBS
    aliquota_cbs: float  # Alíquota percentual CBS
    credito_ibs: float   # Percentual de crédito IBS
    credito_cbs: float   # Percentual de crédito CBS
```

### Tabelas Simuladas para Exemplo

```python
# Tabela CNAE simulada
cnaes = {
    '6201500': CNAE(codigo='6201500', descricao='Desenvolvimento de programas de computador sob encomenda', lc116_codigo='101'),
    '4321101': CNAE(codigo='4321101', descricao='Instalação e manutenção elétrica', lc116_codigo='102'),
}

# Tabela LC116 simulada
lc116s = {
    '101': LC116(codigo='101', descricao='Serviços de programação', nbs_codigo='A101', aliquota_iss=5.0),
    '102': LC116(codigo='102', descricao='Serviços elétricos', nbs_codigo='A102', aliquota_iss=3.0),
}

# Tabela NBS simulada
nbss = {
    'A101': NBS(codigo='A101', descricao='Desenvolvimento de software', aliquota_ibs=2.0, aliquota_cbs=1.0, credito_ibs=100.0, credito_cbs=50.0),
    'A102': NBS(codigo='A102', descricao='Serviços de manutenção elétrica', aliquota_ibs=2.5, aliquota_cbs=1.2, credito_ibs=80.0, credito_cbs=40.0),
}
```

### Função para Validar Vinculação CNAE → LC116 → NBS

```python
def validar_vinculacao(cnae_codigo: str) -> tuple:
    if cnae_codigo not in cnaes:
        return False, 'CNAE não encontrado na tabela.'
    
    cnae = cnaes[cnae_codigo]
    if cnae.lc116_codigo not in lc116s:
        return False, f'Código LC116 {cnae.lc116_codigo} vinculado ao CNAE não encontrado.'
    
    lc116 = lc116s[cnae.lc116_codigo]
    if lc116.nbs_codigo not in nbss:
        return False, f'Código NBS {lc116.nbs_codigo} vinculado ao LC116 não encontrado.'
    
    return True, (cnae, lc116, nbss[lc116.nbs_codigo])
```

### Função para Calcular Custo Líquido Tributário

A base do cálculo é o preço bruto informado pelo fornecedor. O sistema calcula:

- ISS devido = preço bruto × alíquota ISS (%)
- IBS devido = preço bruto × alíquota IBS (%) - crédito IBS (%)
- CBS devido = preço bruto × alíquota CBS (%) - crédito CBS (%)

Os créditos são aplicados sobre o valor do tributo, reduzindo o imposto a pagar.

```python
def calcular_custo_liquido(preco_bruto: float, cnae_codigo: str) -> dict:
    valido, resultado = validar_vinculacao(cnae_codigo)
    if not valido:
        return {'erro': resultado}
    
    cnae, lc116, nbs = resultado
    
    # Cálculo ISS
    iss_bruto = preco_bruto * (lc116.aliquota_iss / 100)
    credito_iss = 0  # ISS não gera crédito para o tomador comum, regra simplificada
    iss_liquido = max(iss_bruto - credito_iss, 0)
    
    # Cálculo IBS
    ibs_bruto = preco_bruto * (nbs.aliquota_ibs / 100)
    credito_ibs = ibs_bruto * (nbs.credito_ibs / 100)
    ibs_liquido = max(ibs_bruto - credito_ibs, 0)
    
    # Cálculo CBS
    cbs_bruto = preco_bruto * (nbs.aliquota_cbs / 100)
    credito_cbs = cbs_bruto * (nbs.credito_cbs / 100)
    cbs_liquido = max(cbs_bruto - credito_cbs, 0)
    
    imposto_total = iss_liquido + ibs_liquido + cbs_liquido
    custo_liquido = preco_bruto + imposto_total
    
    return {
        'preco_bruto': preco_bruto,
        'iss_bruto': round(iss_bruto, 2),
        'credito_iss': round(credito_iss, 2),
        'iss_liquido': round(iss_liquido, 2),
        'ibs_bruto': round(ibs_bruto, 2),
        'credito_ibs': round(credito_ibs, 2),
        'ibs_liquido': round(ibs_liquido, 2),
        'cbs_bruto': round(cbs_bruto, 2),
        'credito_cbs': round(credito_cbs, 2),
        'cbs_liquido': round(cbs_liquido, 2),
        'imposto_total': round(imposto_total, 2),
        'custo_liquido': round(custo_liquido, 2),
        'cnae': cnae.codigo,
        'lc116': lc116.codigo,
        'nbs': nbs.codigo,
    }
```

### Exemplo Prático com Dois Fornecedores

```python
fornecedores = [
    {'nome': 'Fornecedor A', 'cnae': '6201500', 'preco': 100.00},
    {'nome': 'Fornecedor B', 'cnae': '4321101', 'preco': 95.00},
]

for f in fornecedores:
    resultado = calcular_custo_liquido(f['preco'], f['cnae'])
    if 'erro' in resultado:
        print(f"Erro para {f['nome']}: {resultado['erro']}")
        continue
    
    print(f"Análise para {f['nome']}:")
    print(f"  Preço Bruto: R$ {resultado['preco_bruto']}")
    print(f"  ISS líquido: R$ {resultado['iss_liquido']}")
    print(f"  IBS líquido: R$ {resultado['ibs_liquido']}")
    print(f"  CBS líquido: R$ {resultado['cbs_liquido']}")
    print(f"  Imposto Total: R$ {resultado['imposto_total']}")
    print(f"  Custo Líquido Tributário: R$ {resultado['custo_liquido']}")
    print(f"  Códigos vinculados: CNAE {resultado['cnae']}, LC116 {resultado['lc116']}, NBS {resultado['nbs']}")
    print()
```

#### Saída Esperada

```
Análise para Fornecedor A:
  Preço Bruto: R$ 100.0
  ISS líquido: R$ 5.0
  IBS líquido: R$ 0.0
  CBS líquido: R$ 0.5
  Imposto Total: R$ 5.5
  Custo Líquido Tributário: R$ 105.5
  Códigos vinculados: CNAE 6201500, LC116 101, NBS A101

Análise para Fornecedor B:
  Preço Bruto: R$ 95.0
  ISS líquido: R$ 2.85
  IBS líquido: R$ 0.475
  CBS líquido: R$ 0.684
  Imposto Total: R$ 3.9999999999999996
  Custo Líquido Tributário: R$ 98.99999999999999
  Códigos vinculados: CNAE 4321101, LC116 102, NBS A102
```

### Erro Comum e Como Corrigir

Um erro frequente na implementação é tentar calcular tributos para um CNAE que não está cadastrado ou que não possui vínculo com LC116 ou NBS, causando falhas ou cálculos incorretos.

Exemplo de erro:

```python
resultado = calcular_custo_liquido(100.0, '0000000')
print(resultado)
```

Saída:

```
{'erro': 'CNAE não encontrado na tabela.'}
```

**Correção:** sempre validar a existência do CNAE e dos vínculos antes de prosseguir, e informar claramente o erro para o usuário ou sistema.

### Comparação Automática entre Fornecedores

Com os cálculos automatizados, o sistema pode determinar qual fornecedor oferece o menor custo líquido tributário, considerando os créditos fiscais.

```python
def escolher_melhor_fornecedor(fornecedores):
    resultados = []
    for f in fornecedores:
        res = calcular_custo_liquido(f['preco'], f['cnae'])
        if 'erro' in res:
            print(f"Erro fornecedor {f['nome']}: {res['erro']}")
            continue
        resultados.append((f['nome'], res['custo_liquido']))
    if not resultados:
        return None
    melhor = min(resultados, key=lambda x: x[1])
    return melhor

melhor_fornecedor = escolher_melhor_fornecedor(fornecedores)
print(f"Melhor fornecedor: {melhor_fornecedor[0]} com custo líquido R$ {melhor_fornecedor[1]:.2f}")
```

Saída:

```
Melhor fornecedor: Fornecedor B com custo líquido R$ 98.99
```

No exemplo, mesmo com preço bruto menor, o Fornecedor B apresenta custo líquido tributário menor, refletindo créditos e alíquotas diferenciadas.

### Exercício Proposto

Implemente uma função que, dado um código CNAE e um preço bruto, valide a vinculação CNAE → LC116 → NBS, calcule os valores líquidos do ISS, IBS e CBS considerando os créditos tributários, e retorne o custo líquido tributário. Caso haja erro na vinculação, retorne uma mensagem clara de erro.

---