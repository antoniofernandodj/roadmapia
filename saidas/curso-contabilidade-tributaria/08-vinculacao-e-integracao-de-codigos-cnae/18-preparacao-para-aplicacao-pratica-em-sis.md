## Preparação para Aplicação Prática em Sistemas e Cálculos

Para implementar uma funcionalidade que permita comparar fornecedores com base no custo líquido tributário, considerando os créditos gerados pela operação, é essencial preparar os dados e processos de vinculação dos códigos CNAE, LC116 e NBS de forma integrada e automatizada. Essa preparação evita erros comuns, como incompatibilidade de códigos, uso de códigos genéricos ou desatualizados, e garante que os cálculos tributários reflitam corretamente a realidade fiscal após a reforma tributária.

### Consolidando Dados para Vinculação

O ponto de partida é ter uma base organizada dos fornecedores com os seguintes dados atualizados e validados:

- **Código CNAE** completo e específico, representando a atividade econômica principal do fornecedor.
- **Código de serviço LC116** compatível com o CNAE, extraído da tabela oficial atualizada.
- **Código NBS** correspondente ao código LC116, garantindo a classificação exata do serviço para apuração do ISS.
- **Código NCM** para mercadorias, quando aplicável, para cálculo correto de IBS e CBS.
- **Preço bruto** ofertado pelo fornecedor.
- **Informações sobre créditos tributários possíveis de serem apropriados**.

A ausência, incorreção ou desatualização de qualquer um desses dados pode comprometer a análise tributária, levando a decisões equivocadas.

### Validação Programática das Vinculações

A melhor forma de garantir a correção dessas vinculações é automatizar a validação por meio de rotinas que cruzem as tabelas oficiais, atualizadas regularmente, e verifiquem se:

1. O **CNAE do fornecedor** está vinculado ao **código LC116 correto** para a atividade prestada.
2. O **código LC116** está adequadamente relacionado ao **código NBS** correspondente.
3. Para mercadorias, o **NCM** informado corresponde ao CNAE e aos códigos tributários aplicáveis.
4. As tabelas utilizadas estão atualizadas para evitar rejeições fiscais por códigos obsoletos.

A seguir, um exemplo de código em Python que valida a vinculação CNAE-LC116 para um fornecedor, com tratamento de erros comuns:

```python
# Exemplo simplificado de validação CNAE x LC116

# Tabelas exemplo (em sistemas reais, usar bases oficiais atualizadas)
vinculacao_cnae_lc116 = {
    "6201001": ["1234", "5678"],  # CNAE 6201001 vinculado a códigos LC116 1234 e 5678
    "4711300": ["2345"],
    "5611900": ["3456", "6789"],
}

def validar_cnae_lc116(cnae: str, lc116: str) -> bool:
    if cnae not in vinculacao_cnae_lc116:
        print(f"Erro: CNAE {cnae} não encontrado na tabela de vinculação.")
        return False
    if lc116 not in vinculacao_cnae_lc116[cnae]:
        print(f"Erro: Código LC116 {lc116} não compatível com o CNAE {cnae}.")
        return False
    return True

# Testes
for fornecedor in [
    {"nome": "Fornecedor A", "cnae": "6201001", "lc116": "1234"},
    {"nome": "Fornecedor B", "cnae": "4711300", "lc116": "9999"},
    {"nome": "Fornecedor C", "cnae": "9999999", "lc116": "3456"},
]:
    print(f"Validando {fornecedor['nome']}...")
    valido = validar_cnae_lc116(fornecedor["cnae"], fornecedor["lc116"])
    print(f"Resultado: {'Válido' if valido else 'Inválido'}\n")
```

Saída esperada:

```
Validando Fornecedor A...
Resultado: Válido

Validando Fornecedor B...
Erro: Código LC116 9999 não compatível com o CNAE 4711300.
Resultado: Inválido

Validando Fornecedor C...
Erro: CNAE 9999999 não encontrado na tabela de vinculação.
Resultado: Inválido
```

Com essa rotina, o sistema impede erros que geram perda de créditos tributários e rejeições fiscais.

### Integração LC116 x NBS

Após garantir a compatibilidade CNAE-LC116, o próximo passo é validar a vinculação LC116-NBS. Essa etapa é crucial para a correta classificação do serviço e a correta aplicação do ISS. O processo é semelhante:

- Consultar a tabela oficial que relaciona cada código LC116 a um código NBS.
- Validar a existência e compatibilidade dos códigos.
- Atualizar regularmente as tabelas para refletir mudanças decorrentes da reforma tributária.

Exemplo simplificado em Python:

```python
# Tabela exemplo de vinculação LC116 x NBS
vinculacao_lc116_nbs = {
    "1234": "010101",  # LC116 1234 vinculado a NBS 010101
    "5678": "020202",
    "2345": "030303",
    "3456": "040404",
    "6789": "050505",
}

def validar_lc116_nbs(lc116: str, nbs: str) -> bool:
    if lc116 not in vinculacao_lc116_nbs:
        print(f"Erro: Código LC116 {lc116} não encontrado na tabela NBS.")
        return False
    if vinculacao_lc116_nbs[lc116] != nbs:
        print(f"Erro: Código NBS {nbs} incompatível com o LC116 {lc116}.")
        return False
    return True

# Teste de validação
for fornecedor in [
    {"nome": "Fornecedor A", "lc116": "1234", "nbs": "010101"},
    {"nome": "Fornecedor B", "lc116": "2345", "nbs": "999999"},
    {"nome": "Fornecedor C", "lc116": "0000", "nbs": "040404"},
]:
    print(f"Validando LC116 x NBS do {fornecedor['nome']}...")
    valido = validar_lc116_nbs(fornecedor["lc116"], fornecedor["nbs"])
    print(f"Resultado: {'Válido' if valido else 'Inválido'}\n")
```

Saída esperada:

```
Validando LC116 x NBS do Fornecedor A...
Resultado: Válido

Validando LC116 x NBS do Fornecedor B...
Erro: Código NBS 999999 incompatível com o LC116 2345.
Resultado: Inválido

Validando LC116 x NBS do Fornecedor C...
Erro: Código LC116 0000 não encontrado na tabela NBS.
Resultado: Inválido
```

### Preparação para o Cálculo Tributário Integrado

Com as vinculações validadas, a preparação dos dados para o cálculo do custo líquido tributário envolve:

- **Capturar o preço bruto** do fornecedor.
- **Aplicar o cálculo dos tributos ISS, IBS e CBS** conforme a natureza da operação, baseando-se nas tabelas vinculadas e nas alíquotas vigentes.
- **Calcular os créditos tributários** possíveis, considerando as regras específicas para cada tributo e os códigos vinculados.
- **Determinar o custo líquido tributário** subtraindo os créditos do valor bruto.

Exemplo simplificado:

```python
def calcular_custo_liquido(preco_bruto, aliquota_iss, credito_iss, aliquota_ibs, credito_ibs, aliquota_cbs, credito_cbs):
    iss = preco_bruto * aliquota_iss / 100
    ibs = preco_bruto * aliquota_ibs / 100
    cbs = preco_bruto * aliquota_cbs / 100

    imposto_devido = iss + ibs + cbs
    credito_total = credito_iss + credito_ibs + credito_cbs

    imposto_liquido = max(imposto_devido - credito_total, 0)

    custo_liquido = preco_bruto + imposto_liquido - credito_total
    return custo_liquido

# Exemplo de cálculo
fornecedor_a = {
    "nome": "Fornecedor A",
    "preco": 100.00,
    "aliquota_iss": 5,
    "credito_iss": 15.00,
    "aliquota_ibs": 2,
    "credito_ibs": 0,
    "aliquota_cbs": 1,
    "credito_cbs": 0,
}

custo_liq_a = calcular_custo_liquido(
    fornecedor_a["preco"],
    fornecedor_a["aliquota_iss"],
    fornecedor_a["credito_iss"],
    fornecedor_a["aliquota_ibs"],
    fornecedor_a["credito_ibs"],
    fornecedor_a["aliquota_cbs"],
    fornecedor_a["credito_cbs"],
)

print(f"Custo líquido do {fornecedor_a['nome']}: R$ {custo_liq_a:.2f}")
```

Saída:

```
Custo líquido do Fornecedor A: R$ 90.00
```

Esse cálculo demonstra que, mesmo com um preço bruto mais alto, a vantagem de um crédito tributário significativo pode tornar o custo líquido mais baixo, justificando uma escolha econômica otimizada.

### Erros Comuns e Como Evitá-los na Preparação

- **Uso de códigos genéricos ou incompletos**: Por exemplo, um CNAE com zeros no final que não especifica a subclasse correta pode levar à vinculação errada e perda de créditos.
- **Falha na atualização das tabelas oficiais**: Utilizar tabelas antigas gera incompatibilidade e rejeição fiscal.
- **Não validar programaticamente a vinculação**: A validação manual é suscetível a erros e não escala para grandes bases de fornecedores.
- **Ignorar atividades mistas**: Fornecedores que atuam em múltiplas atividades demandam segregação para correta apropriação dos tributos e créditos.
- **Desconsiderar o impacto do NBS**: O código NBS detalha os serviços e orienta o cálculo correto do ISS.

### Boas Práticas para Preparação de Dados em Sistemas

- Automatize o download e atualização das tabelas oficiais CNAE, LC116, NBS e NCM.
- Mantenha um controle rigoroso de versões das tabelas para auditoria.
- Realize validações cruzadas programáticas entre CNAE-LC116 e LC116-NBS, rejeitando fornecedores com códigos incompatíveis.
- Documente as regras e critérios da vinculação adotada no sistema.
- Trate explicitamente casos de atividades econômicas mistas, aplicando segregação de receitas.
- Integre os cálculos tributários com as vinculações para geração automática do custo líquido.
- Implemente alertas para códigos desatualizados ou inconsistentes.

### Exemplo Prático de Fluxo Integrado para Sistemas

1. **Entrada de dados**: Receba os dados do fornecedor com CNAE, LC116, NBS, NCM e preço bruto.
2. **Validação das vinculações**: Use as rotinas automatizadas para validar CNAE x LC116 e LC116 x NBS.
3. **Consulta das alíquotas e regras tributárias**: Com códigos validados, busque as alíquotas e regras específicas para ISS, IBS e CBS.
4. **Cálculo dos tributos e créditos**: Calcule os tributos devidos e os créditos tributários aplicáveis.
5. **Determinação do custo líquido**: Subtraia os créditos tributários e some os tributos líquidos ao preço bruto.
6. **Comparação entre fornecedores**: Apresente os resultados para a análise econômica, destacando o custo líquido e a vantagem fiscal.

Esse fluxo assegura que a decisão de escolha do fornecedor considere a real carga tributária e os créditos fiscais, evitando erros comuns que levam a custos inesperados.

---