## Estrutura de Dados para Armazenar Códigos e Tabelas Tributárias

Ao implementar sistemas para gestão tributária que consideram a nova reforma, a correta estruturação dos dados referentes a códigos oficiais como CNAE, LC116, NBS, NCM e códigos de tributação (cTribNac) é fundamental. Essa estrutura não só garante a integridade e a consistência das informações, como também permite automações robustas para validação, cálculo e comparação tributária entre fornecedores, considerando créditos fiscais.

### Por que estruturar bem os dados dos códigos tributários?

Imagine um sistema simplificado onde você apenas grava o código CNAE do fornecedor e o preço bruto da sua proposta. Sem mais nada, qualquer análise de custo tributário será manual e sujeita a erros. Isso porque o CNAE sozinho não informa diretamente qual é o código LC116 do serviço, nem qual o código NBS associado, nem qual a alíquota ou crédito tributário aplicável.

Sem uma estrutura clara que integre e vincule essas informações, o sistema pode:

- Apresentar erros por incompatibilidade de códigos.
- Calcular tributos com alíquotas incorretas.
- Ignorar créditos tributários, levando a decisões econômicas erradas.
- Impedir a comparação automática entre fornecedores com base no custo tributário líquido.

Portanto, a estrutura de dados deve refletir as relações hierárquicas e vinculativas entre os códigos, permitindo consultas rápidas e validações automáticas.

---

### Modelagem básica para os principais códigos e tabelas

Para facilitar o entendimento e a implementação, apresentamos a seguir um modelo conceitual simplificado, com exemplos em Python, que pode ser adaptado para bancos de dados relacionais ou NoSQL, conforme a necessidade.

#### 1. Armazenando o CNAE

O CNAE, como visto em 2.2, é organizado em níveis hierárquicos (Seção, Divisão, Grupo, Classe, Subclasse). Cada código tem formato padronizado, como `47.11-3-01`.

```python
class CNAE:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo  # Exemplo: "47.11-3-01"
        self.descricao = descricao  # Exemplo: "Comércio varejista de mercadorias em geral"
```

Um repositório (lista, dicionário ou tabela) deve conter os CNAEs válidos, atualizados conforme 2.4 e 2.16.

#### 2. Armazenando o código LC116

O código de serviço LC116, conforme 3.2 e 3.5, também possui uma hierarquia numérica e estrutura fixa, como `14.01`.

```python
class LC116:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo  # Exemplo: "14.01"
        self.descricao = descricao  # Exemplo: "Serviços de informática"
```

Da mesma forma, a tabela oficial da LC116 deve estar atualizada (3.4, 3.10).

#### 3. Armazenando o código NBS

A NBS detalha os serviços para o ISS, vinculando-se à LC116 (4.1, 4.2, 4.7). Seu código é numérico, ex: `1401`.

```python
class NBS:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo  # Exemplo: "1401"
        self.descricao = descricao  # Exemplo: "Serviços de informática"
```

#### 4. Armazenando o código NCM

O NCM é o código para mercadorias, com estrutura hierárquica de 8 dígitos (4.4), por exemplo `10061000`.

```python
class NCM:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo  # Exemplo: "10061000"
        self.descricao = descricao  # Exemplo: "Arroz em casca"
```

#### 5. Armazenando códigos de tributação (cTribNac)

Os códigos cTribNac, essenciais para integração e apuração de créditos (6.1, 6.3), especificam regimes, naturezas e classificações tributárias.

```python
class CTribNac:
    def __init__(self, codigo: str, descricao: str, regime_tributario: str):
        self.codigo = codigo  # Exemplo: "101"
        self.descricao = descricao  # Exemplo: "Tributação normal"
        self.regime_tributario = regime_tributario  # Exemplo: "Simples Nacional"
```

---

### Vinculações entre tabelas

A estrutura de dados deve permitir a vinculação entre esses códigos. As relações principais são:

- **CNAE → LC116**  
  Cada CNAE pode estar vinculado a um ou mais códigos LC116, conforme a atividade econômica e a lista oficial (2.9, 3.6).

- **LC116 → NBS**  
  O código LC116 vincula-se diretamente a um ou mais códigos NBS, detalhando o serviço para ISS (3.13, 4.7).

- **CNAE → LC116 → NBS**  
  Essa cadeia é a base para validar o serviço do fornecedor e calcular corretamente o ISS e outros tributos (5.4, 6.3).

- **NCM → cTribNac**  
  Para mercadorias, o NCM vincula-se aos códigos de tributação que definem alíquotas e créditos para IBS, CBS, etc. (4.8, 6.8).

---

### Exemplo prático: estrutura em Python com vinculações

```python
class CNAE:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo
        self.descricao = descricao
        self.lc116_codigos = []  # lista de códigos LC116 vinculados

class LC116:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo
        self.descricao = descricao
        self.nbs_codigos = []  # lista de códigos NBS vinculados

class NBS:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo
        self.descricao = descricao

class NCM:
    def __init__(self, codigo: str, descricao: str):
        self.codigo = codigo
        self.descricao = descricao
        self.ctribnac_codigos = []  # lista de códigos de tributação vinculados

class CTribNac:
    def __init__(self, codigo: str, descricao: str, regime_tributario: str):
        self.codigo = codigo
        self.descricao = descricao
        self.regime_tributario = regime_tributario

# Exemplo de carregamento e vinculação:

# Criando objetos CNAE
cnae_4711301 = CNAE("47.11-3-01", "Comércio varejista de mercadorias em geral")

# Criando LC116 vinculados
lc116_1401 = LC116("14.01", "Serviços de informática")

# Criando NBS vinculados
nbs_1401 = NBS("1401", "Serviços de informática")

# Vinculando CNAE → LC116
cnae_4711301.lc116_codigos.append(lc116_1401)

# Vinculando LC116 → NBS
lc116_1401.nbs_codigos.append(nbs_1401)

# Criando NCM e cTribNac
ncm_10061000 = NCM("10061000", "Arroz em casca")
ctrib_101 = CTribNac("101", "Tributação normal", "Simples Nacional")

ncm_10061000.ctribnac_codigos.append(ctrib_101)
```

Essa estrutura permite consultas como: dado um CNAE, quais códigos LC116 e NBS são válidos? Ou, dado um NCM, quais códigos cTribNac aplicar?

---

### Validação dos códigos e vinculações

Erros comuns na implementação incluem:

- **Inserção de códigos não oficiais ou desatualizados**  
  Por exemplo, um código LC116 que não consta na lista oficial gera erro na validação. Mensagem típica:  
  `Código LC116 inválido: 99.99 não encontrado na tabela oficial.`

- **Vinculação incompatível entre códigos**  
  Exemplo: CNAE vinculado a LC116 que não está na lista permitida para aquela atividade. Erro:  
  `Incompatibilidade: CNAE 47.11-3-01 não pode ser vinculado ao código LC116 15.02.`

- **Ausência de vinculação obrigatória**  
  Se o CNAE não tem nenhum LC116 associado, o cálculo do ISS fica inválido, pois não há código de serviço definido.

Para evitar esses erros, o sistema deve implementar rotinas de validação automática que consultem as tabelas oficiais atualizadas (6.6, 6.10).

---

### Otimização para análise tributária e comparação de fornecedores

Com a estrutura acima, ao receber uma cotação, o sistema pode:

1. Identificar o CNAE do fornecedor.
2. Validar o CNAE contra a tabela oficial.
3. Buscar o LC116 vinculado ao CNAE para identificar o serviço.
4. Obter o NBS associado ao LC116 para detalhamento do serviço e cálculo do ISS.
5. Para mercadorias, identificar o NCM e seu código de tributação (cTribNac).
6. Calcular a base de cálculo, aplicar alíquotas (ver 5.4 a 5.8) e apropriar créditos (7.7).
7. Calcular o custo líquido tributário, considerando créditos tributários.
8. Comparar os custos líquidos entre fornecedores para decisão.

Essa sequência só é possível com uma estrutura de dados consistente e integrada, que assegure a confiabilidade do cálculo e a conformidade legal.

---

### Exemplo de estrutura para tabelas em banco de dados relacional (simplificado)

| Tabela CNAE               | Campos                           |
|--------------------------|---------------------------------|
| cnae                     | codigo (PK), descricao           |

| Tabela LC116              | Campos                           |
|--------------------------|---------------------------------|
| lc116                    | codigo (PK), descricao           |

| Tabela NBS                | Campos                           |
|--------------------------|---------------------------------|
| nbs                      | codigo (PK), descricao           |

| Tabela NCM                | Campos                           |
|--------------------------|---------------------------------|
| ncm                      | codigo (PK), descricao           |

| Tabela cTribNac           | Campos                           |
|--------------------------|---------------------------------|
| ctribnac                 | codigo (PK), descricao, regime   |

| Tabela CNAE_LC116         | Campos                           |
|--------------------------|---------------------------------|
| cnae_codigo (FK)          | lc116_codigo (FK)                |

| Tabela LC116_NBS          | Campos                           |
|--------------------------|---------------------------------|
| lc116_codigo (FK)         | nbs_codigo (FK)                  |

| Tabela NCM_cTribNac       | Campos                           |
|--------------------------|---------------------------------|
| ncm_codigo (FK)           | ctribnac_codigo (FK)             |

As tabelas de vinculação são essenciais para garantir flexibilidade, como múltiplos códigos LC116 por CNAE e múltiplos NBS por LC116.

---

### Exemplo prático completo: verificação e cálculo simplificado em Python

```python
# Dados simplificados para exemplo
cnaes = {
    "47.11-3-01": CNAE("47.11-3-01", "Comércio varejista de mercadorias em geral")
}

lc116s = {
    "14.01": LC116("14.01", "Serviços de informática")
}

nbss = {
    "1401": NBS("1401", "Serviços de informática")
}

# Vinculações
cnaes["47.11-3-01"].lc116_codigos.append(lc116s["14.01"])
lc116s["14.01"].nbs_codigos.append(nbss["1401"])

def validar_vinculacao_cnae_lc116_nbs(cnae_codigo, lc116_codigo, nbs_codigo):
    cnae = cnaes.get(cnae_codigo)
    if not cnae:
        raise ValueError(f"CNAE inválido: {cnae_codigo}")
    if lc116_codigo not in [lc.codigo for lc in cnae.lc116_codigos]:
        raise ValueError(f"LC116 '{lc116_codigo}' não vinculado ao CNAE '{cnae_codigo}'")
    lc116 = lc116s.get(lc116_codigo)
    if not lc116:
        raise ValueError(f"LC116 inválido: {lc116_codigo}")
    if nbs_codigo not in [nbs.codigo for nbs in lc116.nbs_codigos]:
        raise ValueError(f"NBS '{nbs_codigo}' não vinculado ao LC116 '{lc116_codigo}'")
    return True

def calcular_custo_liquido(preco_bruto, aliquota_iss, credito_iss):
    iss_devido = preco_bruto * aliquota_iss
    iss_liquido = max(iss_devido - credito_iss, 0)
    custo_liquido = preco_bruto + iss_liquido
    return custo_liquido

# Exemplo de uso
try:
    validar_vinculacao_cnae_lc116_nbs("47.11-3-01", "14.01", "1401")
    preco_bruto = 100.0
    aliquota_iss = 0.05  # 5%
    credito_iss = 15.0
    custo_liquido = calcular_custo_liquido(preco_bruto, aliquota_iss, credito_iss)
    print(f"Custo líquido tributário: R$ {custo_liquido:.2f}")
except ValueError as e:
    print(f"Erro: {e}")
```

Saída esperada:

```
Custo líquido tributário: R$ 90.00
```

---

### Erro comum e sua correção

**Erro:** Vincular um CNAE ao código LC116 errado, que não está previsto na tabela oficial.

**Mensagem:**  
`LC116 '15.02' não vinculado ao CNAE '47.11-3-01'`

**Correção:**  
Verifique a tabela oficial e corrija o código LC116 para um que esteja autorizado para o CNAE. Implementar uma rotina de validação automática evita esse erro.

---

### Exercício prático

Implemente uma função que, dado um código CNAE e o preço bruto de uma proposta, realize:

- Validação da existência do CNAE.
- Busca do código LC116 vinculado ao CNAE.
- Busca do código NBS vinculado ao LC116.
- Simulação do cálculo do custo líquido tributário aplicado ISS, considerando uma alíquota fixa (exemplo: 5%) e um crédito tributário informado.
- Retorne o custo líquido ou mensagem de erro detalhada caso haja incompatibilidade ou código inexistente.

Comente cada passo da função para explicar o fluxo.

---