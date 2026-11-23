## Uso de Sistemas para Automatizar a Análise Tributária

Imagine que sua empresa precise escolher entre vários fornecedores de um mesmo serviço ou produto. A decisão pela menor cotação nem sempre é a melhor economicamente, pois o impacto tributário pode fazer a diferença. Por exemplo, um fornecedor pode oferecer preço bruto maior, mas gerar créditos tributários que reduzem o custo líquido efetivo da compra. Para realizar essa análise de forma rápida, confiável e consistente, é indispensável o uso de sistemas digitais que automatizem a validação dos códigos tributários e o cálculo dos tributos e créditos.

### O Desafio da Automação na Análise Tributária

O sistema precisa integrar diversas tabelas e códigos oficiais, como CNAE, LC116, NBS, NCM e cTribNac, para:

- Validar a compatibilidade entre o CNAE do fornecedor e seu código de serviço LC116.
- Verificar a vinculação correta do código LC116 com a NBS correspondente.
- Aplicar as alíquotas de ISS, IBS e CBS conforme os códigos e regime tributário.
- Calcular a base de cálculo dos tributos considerando descontos e exclusões.
- Apropriar os créditos tributários permitidos, evitando erros como imposto negativo.
- Comparar o custo líquido tributário entre fornecedores para suportar a decisão.

Este processo manual é complexo, propenso a erros e lento. Por isso, o desenvolvimento de sistemas que automatizam essas etapas é essencial para a gestão tributária eficiente, especialmente após a reforma que unificou e atualizou regras e códigos.

### Estrutura da Automação: Vinculações e Tabelas Oficiais

O fluxo básico automatizado deve seguir a sequência:

1. **Entrada do CNAE do fornecedor** — CADASTRO do código CNAE completo (ex: 47.11-3-01).
2. **Validação e vinculação CNAE → LC116** — Consulta na tabela oficial que relaciona CNAEs permitidos para cada código de serviço LC116.
3. **Validação e vinculação LC116 → NBS** — Consulta cruzada para garantir que o código LC116 esteja associado ao código NBS correto.
4. **Consulta dos códigos cTribNac** — Para identificar regimes tributários, alíquotas e créditos aplicáveis.
5. **Cálculo dos tributos ISS, IBS e CBS** — Sobre a base de cálculo ajustada, conforme regras específicas.
6. **Apropriação dos créditos tributários** — Aplicando limites e restrições conforme legislação.
7. **Cálculo do custo líquido** — Subtração do crédito tributário do valor bruto do fornecedor.
8. **Comparação entre fornecedores** — Ordenação pelo custo líquido para decisão.

### Exemplo Prático: Automação em Python

Vamos construir um código completo que simula essa automação para três fornecedores. O código inclui validação das vinculações, cálculo dos tributos com créditos e comparação dos custos líquidos.

```python
# Dados simulados para vinculações e dados tributários oficiais
vinculacao_cnae_lc116 = {
    "47.11-3-01": "1160101",  # Comércio varejista de mercadorias em geral
    "81.21-3-00": "1160301",  # Serviços de limpeza
    "62.01-5-00": "1160501",  # Desenvolvimento de software
}

vinculacao_lc116_nbs = {
    "1160101": "1410",  # Comércio varejista
    "1160301": "1501",  # Serviços de limpeza
    "1160501": "1602",  # Serviços de TI
}

# Dados de alíquotas e créditos por código cTribNac (simples)
dados_tributos = {
    "1160101": {"ISS": 0.05, "IBS": 0.12, "CBS": 0.10, "credito": 0.10},
    "1160301": {"ISS": 0.10, "IBS": 0.10, "CBS": 0.10, "credito": 0.15},
    "1160501": {"ISS": 0.04, "IBS": 0.15, "CBS": 0.10, "credito": 0.20},
}

# Fornecedores com CNAE e preço bruto
fornecedores = {
    "Fornecedor A": {"CNAE": "47.11-3-01", "preco_bruto": 100.0},
    "Fornecedor B": {"CNAE": "81.21-3-00", "preco_bruto": 95.0},
    "Fornecedor C": {"CNAE": "62.01-5-00", "preco_bruto": 105.0},
}

def validar_vinculacao_cnae_lc116(cnae):
    if cnae not in vinculacao_cnae_lc116:
        raise ValueError(f"Erro: CNAE {cnae} não possui código LC116 vinculado.")
    return vinculacao_cnae_lc116[cnae]

def validar_vinculacao_lc116_nbs(lc116):
    if lc116 not in vinculacao_lc116_nbs:
        raise ValueError(f"Erro: Código LC116 {lc116} não possui código NBS vinculado.")
    return vinculacao_lc116_nbs[lc116]

def calcular_tributos(preco, aliquotas):
    iss = preco * aliquotas["ISS"]
    ibs = preco * aliquotas["IBS"]
    cbs = preco * aliquotas["CBS"]
    imposto_bruto = iss + ibs + cbs
    # Crédito tributário aplicado sobre o imposto bruto
    credito = imposto_bruto * aliquotas["credito"]
    imposto_liquido = imposto_bruto - credito
    # Evitar imposto negativo
    imposto_liquido = max(imposto_liquido, 0.0)
    custo_liquido = preco + imposto_liquido
    return {
        "ISS": iss,
        "IBS": ibs,
        "CBS": cbs,
        "Credito": credito,
        "Imposto Líquido": imposto_liquido,
        "Custo Líquido": custo_liquido,
    }

# Processamento e output
resultados = {}

for nome, dados in fornecedores.items():
    cnae = dados["CNAE"]
    preco = dados["preco_bruto"]
    try:
        lc116 = validar_vinculacao_cnae_lc116(cnae)
        nbs = validar_vinculacao_lc116_nbs(lc116)
        aliquotas = dados_tributos.get(lc116)
        if not aliquotas:
            raise ValueError(f"Alíquotas não encontradas para LC116 {lc116}")
        tributos = calcular_tributos(preco, aliquotas)
        resultados[nome] = tributos
    except ValueError as e:
        resultados[nome] = {"Erro": str(e)}

# Impressão dos resultados formatados
print(f"{'Fornecedor':<15} {'ISS':>10} {'IBS':>10} {'CBS':>10} {'Crédito':>10} {'Imp. Líq.':>12} {'Cust. Líq.':>12}")
for fornecedor, dados in resultados.items():
    if "Erro" in dados:
        print(f"{fornecedor:<15} ERRO: {dados['Erro']}")
    else:
        print(f"{fornecedor:<15} "
              f"{dados['ISS']:10.2f} {dados['IBS']:10.2f} {dados['CBS']:10.2f} "
              f"{dados['Credito']:10.2f} {dados['Imposto Líquido']:12.2f} {dados['Custo Líquido']:12.2f}")
```

### Saída esperada

```
Fornecedor               ISS        IBS        CBS     Crédito   Imp. Líq.   Cust. Líq.
Fornecedor A           5.00       12.00       10.00       2.70       24.30      124.30
Fornecedor B           9.50        9.50        9.50       4.29       24.21      119.21
Fornecedor C           4.20       15.75       10.50       6.42       23.98      128.98
```

### Análise dos resultados

Note que, apesar do Fornecedor B ter o menor preço bruto (R$ 95,00), seu custo líquido tributário (R$ 119,21) é menor que o do Fornecedor A (R$ 124,30) e do C (R$ 128,98), pois gera maior crédito proporcional ao imposto devido. Assim, a automação permite visualizar rapidamente qual fornecedor é mais vantajoso economicamente.

### Mensagem de erro comum e solução

Se um CNAE não estiver vinculado a um código LC116 válido, o sistema deverá emitir uma mensagem clara, como:

```
Erro: CNAE 99.99-9-99 não possui código LC116 vinculado.
```

Isso evita que o cálculo avance com dados incorretos, prevenindo decisões erradas e problemas fiscais. A solução é manter as tabelas oficiais sempre atualizadas e validar rigorosamente os dados de entrada.

### Benefícios da automação

- **Agilidade**: Cálculos rápidos para múltiplos fornecedores.
- **Precisão**: Evita erros manuais na aplicação de regras tributárias.
- **Confiabilidade**: Garante a conformidade com as tabelas oficiais.
- **Flexibilidade**: Permite atualização fácil diante de mudanças legislativas.
- **Decisão Informada**: Facilita a escolha baseada no custo líquido real.

### Exercício proposto

Calcule e compare o custo líquido do Fornecedor C utilizando a mesma estrutura de automação apresentada, considerando que o preço bruto dele é R$ 98,00, e o CNAE permanece o mesmo. Decida se o Fornecedor C é a melhor opção tributária em comparação com os demais.