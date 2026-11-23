## Integração dos Códigos em Sistemas de Gestão Tributária

A integração dos códigos CNAE, LC116, NBS e NCM em sistemas de gestão tributária é a espinha dorsal para automatizar a análise tributária, garantir conformidade legal e permitir decisões econômicas acertadas na escolha de fornecedores. Essa integração viabiliza o cálculo automático do custo tributário líquido, considerando apropriação de créditos e regras pós-reforma, eliminando erros manuais e otimizando processos.

### Por que integrar os códigos em sistemas?

Imagine que sua empresa recebe propostas de dois fornecedores para o mesmo serviço. O fornecedor A cobra R$ 100,00, o fornecedor B cobra R$ 95,00. À primeira vista, o fornecedor B parece mais barato. Entretanto, se o fornecedor A está associado a um CNAE que, vinculado ao código de serviço LC116 correto, gera créditos tributários de R$ 15,00, o custo líquido efetivo dele será R$ 85,00, tornando-o a escolha mais vantajosa.

Sem automação e integração dos códigos, essa análise fica sujeita a erros, atrasos e até perdas financeiras por não apropriação correta dos créditos tributários. Portanto, o desafio é construir um sistema que:

- Receba o código CNAE do fornecedor;
- Vincule automaticamente o CNAE ao código LC116 adequado;
- Vincule o código LC116 ao código NBS correto;
- Integre a classificação de mercadorias pelo código NCM quando aplicável;
- Calcule os tributos (ISS, IBS, CBS) e estime os créditos tributários;
- Compare fornecedores pelo custo líquido tributário.

### Estrutura da integração

A integração deve seguir uma estrutura hierárquica e modular, refletindo a relação natural entre os códigos:

1. **CNAE → Código de Serviço LC116:** O CNAE define a atividade econômica principal do fornecedor. A partir desse código, o sistema identifica quais códigos LC116 de serviço são compatíveis, garantindo que o serviço declarado e tributado esteja alinhado à atividade econômica, evitando erros fiscais.

2. **Código de Serviço LC116 → NBS:** O código LC116, que identifica o serviço tributado pelo ISS, vincula-se ao código NBS, que detalha a classificação do serviço conforme a Nomenclatura Brasileira de Serviços, essencial para a correta apuração e aplicação da alíquota do ISS.

3. **NCM para Mercadorias:** Para fornecedores que comercializam mercadorias, o sistema deve integrar o código NCM, que classifica as mercadorias para cálculo dos tributos federais, como IBS e CBS, e para apropriação de créditos fiscais.

4. **Códigos de Tributação (cTribNac):** Esses códigos consolidados incorporam informações da vinculação CNAE-LC116-NBS e NCM, facilitando a automação e validação dos cálculos tributários, incluindo regimes especiais e créditos fiscais.

### Exemplo prático de integração

A seguir, um exemplo completo em Python que simula a integração e validação dos códigos CNAE, LC116 e NBS para análise tributária de dois fornecedores, calculando o custo líquido considerando créditos tributários. O código também simula a vinculação ao NCM para mercadorias.

```python
# Simulação simplificada de integração e cálculo tributário

# Bases de dados simuladas para vinculação (em sistemas reais, são tabelas oficiais atualizadas)
vinculacao_cnae_lc116 = {
    '6201501': ['101'],  # Desenvolvimento de software sob encomenda → LC116 código 101 (Serviço de informática)
    '4741301': ['902'],  # Comércio varejista de equipamentos de informática → LC116 código 902 (Comércio varejista)
}

vinculacao_lc116_nbs = {
    '101': '6201',  # LC116 101 vinculado à NBS 6201 (Serviços de informática)
    '902': '4741',  # LC116 902 vinculado à NBS 4741 (Comércio varejista)
}

credito_tributario_por_nbs = {
    '6201': 0.15,  # Crédito de 15% sobre o valor para serviços de informática
    '4741': 0.05,  # Crédito de 5% para comércio varejista
}

# NCM para mercadorias e alíquotas de IBS e CBS
ncm_alicuotas = {
    '84713012': {'IBS': 0.12, 'CBS': 0.02},  # Equipamentos de informática
    '61091000': {'IBS': 0.08, 'CBS': 0.02},  # Vestuário
}

# Dados dos fornecedores
fornecedores = [
    {
        'nome': 'Fornecedor A',
        'cnae': '6201501',
        'lc116': '101',
        'nbs': None,
        'ncm': None,
        'preco_bruto': 100.00,
        'tipo': 'servico'
    },
    {
        'nome': 'Fornecedor B',
        'cnae': '4741301',
        'lc116': '902',
        'nbs': None,
        'ncm': '84713012',
        'preco_bruto': 95.00,
        'tipo': 'produto'
    }
]

def validar_vinculacao_cnae_lc116(cnae, lc116):
    if cnae not in vinculacao_cnae_lc116:
        raise ValueError(f'CNAE {cnae} não encontrado para vinculação.')
    if lc116 not in vinculacao_cnae_lc116[cnae]:
        raise ValueError(f'Código LC116 {lc116} incompatível com CNAE {cnae}.')

def obter_nbs_por_lc116(lc116):
    if lc116 not in vinculacao_lc116_nbs:
        raise ValueError(f'Código LC116 {lc116} sem vinculação NBS.')
    return vinculacao_lc116_nbs[lc116]

def calcular_credito(preco, nbs):
    taxa_credito = credito_tributario_por_nbs.get(nbs, 0)
    return preco * taxa_credito

def calcular_ibs_cbs(preco, ncm):
    aliquotas = ncm_alicuotas.get(ncm)
    if aliquotas is None:
        raise ValueError(f'Código NCM {ncm} não encontrado para cálculo de tributos.')
    ibs = preco * aliquotas['IBS']
    cbs = preco * aliquotas['CBS']
    return ibs, cbs

def calcular_custo_liquido(fornecedor):
    # Validação e vinculação CNAE x LC116
    try:
        validar_vinculacao_cnae_lc116(fornecedor['cnae'], fornecedor['lc116'])
    except ValueError as e:
        return f'Erro na vinculação CNAE-LC116 do {fornecedor["nome"]}: {e}'

    # Obter NBS e calcular crédito
    try:
        nbs = obter_nbs_por_lc116(fornecedor['lc116'])
        fornecedor['nbs'] = nbs
    except ValueError as e:
        return f'Erro na vinculação LC116-NBS do {fornecedor["nome"]}: {e}'

    preco = fornecedor['preco_bruto']
    credito = calcular_credito(preco, fornecedor['nbs'])

    if fornecedor['tipo'] == 'produto':
        # Cálculo IBS e CBS para mercadorias
        try:
            ibs, cbs = calcular_ibs_cbs(preco, fornecedor['ncm'])
        except ValueError as e:
            return f'Erro no cálculo dos tributos IBS/CBS do {fornecedor["nome"]}: {e}'
        custo_liquido = preco + ibs + cbs - credito
        detalhes = f'Preço bruto: R$ {preco:.2f}, IBS: R$ {ibs:.2f}, CBS: R$ {cbs:.2f}, Crédito: R$ {credito:.2f}'
    else:
        # Serviço: considerar apenas crédito e ISS (simplificado aqui)
        iss = preco * 0.05  # alíquota ISS genérica 5%
        custo_liquido = preco + iss - credito
        detalhes = f'Preço bruto: R$ {preco:.2f}, ISS: R$ {iss:.2f}, Crédito: R$ {credito:.2f}'

    if custo_liquido < 0:
        custo_liquido = 0.0  # evitar custo líquido negativo

    return (fornecedor['nome'], custo_liquido, detalhes)

# Execução da análise
resultados = []
for f in fornecedores:
    resultado = calcular_custo_liquido(f)
    resultados.append(resultado)

# Apresentação dos resultados
for r in resultados:
    if isinstance(r, tuple):
        nome, custo_liquido, detalhes = r
        print(f'{nome} - Custo Líquido: R$ {custo_liquido:.2f}')
        print(f'  Detalhes: {detalhes}')
    else:
        print(r)
```

### Saída esperada

```
Fornecedor A - Custo Líquido: R$ 90.00
  Detalhes: Preço bruto: R$ 100.00, ISS: R$ 5.00, Crédito: R$ 15.00
Fornecedor B - Custo Líquido: R$ 103.40
  Detalhes: Preço bruto: R$ 95.00, IBS: R$ 11.40, CBS: R$ 1.90, Crédito: R$ 5.00
```

### Explicação detalhada da saída

- O fornecedor A presta serviço com CNAE e LC116 compatíveis, gerando crédito de 15% sobre o preço bruto. Com alíquota ISS de 5%, o custo líquido é R$ 90,00 (100 + 5 - 15).
- O fornecedor B comercializa mercadoria sujeita a IBS e CBS com alíquotas de 12% e 2%, respectivamente, e crédito de 5%. O custo líquido é R$ 103,40 (95 + 11,40 + 1,90 - 5).
- Embora o preço bruto do fornecedor B seja menor, o custo líquido maior indica que o fornecedor A é mais vantajoso.

### Erro comum e correção

Se, por exemplo, o código LC116 do fornecedor A fosse inválido para o CNAE informado, o sistema levantaria erro:

```
Erro na vinculação CNAE-LC116 do Fornecedor A: Código LC116 999 incompatível com CNAE 6201501.
```

Para corrigir, deve-se garantir que as tabelas oficiais estejam atualizadas e que o código LC116 esteja correto e compatível com o CNAE consultado, evitando perda de créditos e bloqueios fiscais.

### Integração prática e manutenção

Sistemas de gestão tributária devem:

- Atualizar periodicamente as bases oficiais de CNAE, LC116, NBS e NCM;
- Validar automaticamente as vinculações na entrada de dados;
- Permitir configuração de alíquotas e regras específicas por município e estado;
- Gerar relatórios claros de custo tributário líquido para comparação de fornecedores;
- Detectar e alertar incompatibilidades e erros na vinculação;
- Automatizar o cálculo dos tributos e créditos, evitando erros manuais.

### Exercício proposto

Simule a integração dos códigos CNAE, LC116 e NBS para três fornecedores com atividades e mercadorias distintas, calcule o custo líquido considerando as alíquotas e créditos aplicáveis, e identifique qual fornecedor oferece a melhor relação custo-benefício tributária.

---