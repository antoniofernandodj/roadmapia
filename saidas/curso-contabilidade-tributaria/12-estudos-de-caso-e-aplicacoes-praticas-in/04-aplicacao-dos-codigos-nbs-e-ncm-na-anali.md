## Aplicação dos Códigos NBS e NCM na Análise Tributária

Na prática da contabilidade tributária, um dos maiores desafios para a escolha eficiente de fornecedores é a correta classificação dos serviços e mercadorias adquiridos, o que influencia diretamente o cálculo dos tributos e a apropriação dos créditos fiscais. Os códigos NBS (Nomenclatura Brasileira de Serviços) e NCM (Nomenclatura Comum do Mercosul) são ferramentas essenciais para essa classificação, e seu uso correto permite identificar, entre fornecedores com preços distintos, aquele que gera o menor custo líquido tributário, considerando os créditos a que a empresa tem direito.

### Por que usar NBS e NCM na análise tributária?

Imagine que sua empresa precise contratar um serviço de consultoria e adquirir equipamentos eletrônicos. Os fornecedores apresentam preços diferentes, mas saber qual representa o menor custo efetivo exige mais do que comparar valores nominais. Sem a correta aplicação dos códigos NBS para serviços e NCM para mercadorias, o cálculo automático dos impostos e créditos fica comprometido, podendo induzir a decisões equivocadas.

O uso do NBS e do NCM facilita a identificação precisa da natureza do serviço ou produto, permitindo aplicar alíquotas corretas de ISS, IBS, CBS e tributos federais como IPI e ICMS. Isso evita erros comuns, como:

- Aplicar alíquota errada por classificação incorreta;
- Perder créditos tributários por não reconhecer o código correto;
- Emitir documentos fiscais com códigos inadequados que geram rejeições;
- Subestimar o custo tributário real e comprometer a decisão de compra.

### Como aplicar os códigos NBS e NCM integrados na análise?

O processo inicia-se pela identificação do CNAE do fornecedor, que define a atividade econômica principal e auxilia na vinculação ao código de serviço LC116. A partir daí, para serviços, vincula-se o LC116 ao código NBS correspondente, enquanto para mercadorias, o código NCM é utilizado para classificar os produtos adquiridos.

Essa sequência possibilita:

- Aplicar a alíquota correta de ISS para serviços, conforme NBS vinculada ao LC116;
- Aplicar as alíquotas federais e estaduais corretas para mercadorias, com base no código NCM;
- Calcular créditos tributários vinculados à operação, reduzindo o custo líquido;
- Automatizar a validação e cálculo em sistemas, evitando erros manuais.

### Exemplo prático: comparação tributária entre fornecedores usando NBS e NCM

Suponha que a empresa analise dois fornecedores para um serviço de desenvolvimento de software e a compra de computadores:

| Fornecedor | Serviço (NBS)         | Preço Serviço (R$) | Mercadoria (NCM) | Preço Mercadoria (R$) | Crédito Tributário Estimado (R$) |
|------------|----------------------|--------------------|------------------|----------------------|---------------------------------|
| A          | 6201 (Serviço de TI) | 100.000,00         | 8471.30.12       | 50.000,00            | 15.000,00                       |
| B          | 6201 (Serviço de TI) | 90.000,00          | 8471.30.12       | 55.000,00            | 5.000,00                        |

**Passo 1:** Vincular CNAE do fornecedor ao código LC116 e então ao código NBS 6201, que corresponde a serviços de tecnologia da informação.

**Passo 2:** Para mercadoria, aplicar o código NCM 8471.30.12 (computadores portáteis), garantindo a alíquota correta de IPI, IBS e CBS.

**Passo 3:** Calcular o custo líquido considerando o crédito tributário:

- Fornecedor A:

  - Custo bruto total: R$150.000,00
  - Crédito tributário: R$15.000,00
  - Custo líquido: R$135.000,00

- Fornecedor B:

  - Custo bruto total: R$145.000,00
  - Crédito tributário: R$5.000,00
  - Custo líquido: R$140.000,00

Neste cenário, embora o preço bruto do fornecedor B seja menor no serviço, o maior crédito gerado pelo fornecedor A reduz o custo líquido, tornando-o a opção mais vantajosa.

### Implementação prática em código Python

A seguir, um exemplo de código que recebe os dados de fornecedores, seus códigos NBS e NCM, preços e créditos estimados, e calcula o custo líquido para comparação.

```python
# Definição dos fornecedores com códigos NBS e NCM, preços e créditos
fornecedores = [
    {
        "nome": "Fornecedor A",
        "nbs": "6201",  # Serviço de TI
        "preco_servico": 100000.00,
        "ncm": "84713012",  # Computadores portáteis
        "preco_mercadoria": 50000.00,
        "credito_tributario": 15000.00
    },
    {
        "nome": "Fornecedor B",
        "nbs": "6201",
        "preco_servico": 90000.00,
        "ncm": "84713012",
        "preco_mercadoria": 55000.00,
        "credito_tributario": 5000.00
    }
]

def calcular_custo_liquido(fornecedor):
    custo_bruto = fornecedor["preco_servico"] + fornecedor["preco_mercadoria"]
    custo_liquido = custo_bruto - fornecedor["credito_tributario"]
    return custo_liquido

# Comparação dos fornecedores
for fornecedor in fornecedores:
    custo_liquido = calcular_custo_liquido(fornecedor)
    print(f"{fornecedor['nome']}: Custo Bruto = R$ {fornecedor['preco_servico'] + fornecedor['preco_mercadoria']:,.2f} | Crédito Tributário = R$ {fornecedor['credito_tributario']:,.2f} | Custo Líquido = R$ {custo_liquido:,.2f}")
```

**Saída:**

```
Fornecedor A: Custo Bruto = R$ 150,000.00 | Crédito Tributário = R$ 15,000.00 | Custo Líquido = R$ 135,000.00
Fornecedor B: Custo Bruto = R$ 145,000.00 | Crédito Tributário = R$ 5,000.00 | Custo Líquido = R$ 140,000.00
```

### Erro comum na aplicação dos códigos NBS e NCM

Um erro frequente é a utilização incorreta dos códigos NBS ou NCM ao emitir notas fiscais, que resulta na rejeição do documento eletrônico ou em cálculos tributários incorretos. Por exemplo, usar um código NBS genérico não compatível com o serviço prestado gera a seguinte mensagem de erro no sistema:

```
Rejeição: Código NBS incompatível com o código LC116 informado - Consulte a tabela oficial para correção.
```

Para corrigir, deve-se:

- Confirmar a vinculação correta entre CNAE e LC116 (ver 3.12);
- Validar o código NBS correspondente ao código LC116 (ver 4.7);
- Atualizar as tabelas NBS conforme o calendário oficial de 2024 (ver 4.5).

Analogamente, erros na classificação do código NCM podem gerar problemas no cálculo do IPI, IBS ou CBS, com mensagens como:

```
Erro: Código NCM inválido ou desatualizado para a mercadoria informada.
```

A solução passa por consultar a tabela oficial do NCM vigente, verificar a especificidade do código e sua vinculação à operação (ver 4.11).

### Integração dos códigos para análise tributária automatizada

No cenário real, a integração dos códigos CNAE, LC116, NBS e NCM é essencial para alimentar sistemas que calculam automaticamente o custo líquido tributário. Esse fluxo permite:

- Validar automaticamente se o código NBS corresponde ao código LC116 vinculado ao CNAE do fornecedor;
- Aplicar as alíquotas corretas de ISS para serviços e de IPI, IBS e CBS para mercadorias;
- Calcular os créditos tributários disponíveis para cada operação, reduzindo o custo final;
- Facilitar a comparação entre fornecedores, permitindo a escolha baseada no custo líquido e não apenas no preço bruto.

Esse processo pode ser representado por uma função que, dada a entrada dos códigos e valores, valida as vinculações e calcula o custo líquido:

```python
def validar_vinculacao(cnae, lc116, nbs):
    # Simulação simplificada da validação cruzada entre códigos
    vinculacoes_validas = {
        ("6201000", "6201", "6201"): True,
        # Outras vinculações possíveis...
    }
    return vinculacoes_validas.get((cnae, lc116, nbs), False)

def calcular_custo_liquido_automatico(fornecedor):
    if not validar_vinculacao(fornecedor["cnae"], fornecedor["lc116"], fornecedor["nbs"]):
        raise ValueError(f"Incompatibilidade entre CNAE {fornecedor['cnae']}, LC116 {fornecedor['lc116']} e NBS {fornecedor['nbs']}")
    custo_bruto = fornecedor["preco_servico"] + fornecedor["preco_mercadoria"]
    custo_liquido = custo_bruto - fornecedor["credito_tributario"]
    return custo_liquido

# Exemplo de uso:
fornecedor_exemplo = {
    "nome": "Fornecedor C",
    "cnae": "6201000",
    "lc116": "6201",
    "nbs": "6201",
    "preco_servico": 95000.00,
    "preco_mercadoria": 52000.00,
    "credito_tributario": 12000.00
}

try:
    custo_liquido_c = calcular_custo_liquido_automatico(fornecedor_exemplo)
    print(f"{fornecedor_exemplo['nome']}: Custo Líquido Calculado = R$ {custo_liquido_c:,.2f}")
except ValueError as e:
    print(f"Erro na validação: {e}")
```

**Saída esperada:**

```
Fornecedor C: Custo Líquido Calculado = R$ 135,000.00
```

Caso haja incompatibilidade, a exceção apresentará a mensagem de erro, permitindo correção antes da decisão.

### Considerações finais

O domínio dos códigos NBS e NCM, em conjunto com a integração correta com o CNAE e o código de serviço LC116, é fundamental para garantir que a análise tributária seja precisa e reflita o custo real das operações. O uso automático dessas classificações evita erros comuns, permite a correta apropriação de créditos tributários e apoia a escolha do fornecedor que oferece a melhor relação custo-benefício tributário. Essa prática é indispensável para sistemas fiscais modernos e para a conformidade tributária pós-reforma.

---