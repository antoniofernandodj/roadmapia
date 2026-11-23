## Testes e Verificação da Correção dos Cálculos Tributários

A implementação de sistemas para gestão tributária, especialmente no contexto da reforma tributária, envolve cálculos complexos que cruzam informações entre CNAE, LC116, NBS e outros códigos tributários para determinar o custo líquido tributário dos fornecedores. Garantir a precisão desses cálculos é fundamental para evitar decisões erradas que podem gerar prejuízos financeiros, autuações fiscais ou perda de créditos tributários. Por isso, é indispensável estruturar testes robustos e procedimentos de verificação que assegurem a correção e a confiabilidade do sistema.

### Por que testar os cálculos tributários?

Os cálculos tributários envolvem múltiplas variáveis: base de cálculo, alíquotas específicas, créditos tributários aplicáveis, e a correta vinculação entre códigos CNAE, LC116 e NBS, entre outros. Um erro na integração dessas informações pode levar a:

- Aplicação incorreta de alíquotas,
- Apropriação errada ou inexistente de créditos,
- Cálculo incorreto do custo líquido tributário,
- Comparação equivocada entre fornecedores,
- Rejeição de documentos fiscais pela Receita,
- Risco de autuações fiscais e multas.

Portanto, os testes não são apenas um requisito técnico, mas um componente estratégico para garantir decisões econômicas corretas.

### Tipos de testes essenciais para cálculos tributários

#### 1. Testes de Validação de Dados e Vinculação

Antes de calcular tributos, o sistema deve validar se o CNAE informado está correto, se o código LC116 está vinculado corretamente a esse CNAE e se o NBS está associado ao LC116, conforme as tabelas oficiais atualizadas.

**Exemplo de erro comum:**

```python
# Simulação simplificada de validação de vinculação CNAE → LC116
vinculacao_cnae_lc116 = {
    '6201500': '0601',  # CNAE 6201500 vinculado ao código LC116 0601
    '4741300': '0310',
}

cnae_fornecedor = '6201500'
lc116_informado = '0310'  # Código errado para esse CNAE

if vinculacao_cnae_lc116.get(cnae_fornecedor) != lc116_informado:
    raise ValueError(f"Erro: Código LC116 '{lc116_informado}' inválido para CNAE '{cnae_fornecedor}'.")
```

**Erro emitido:**

```
ValueError: Erro: Código LC116 '0310' inválido para CNAE '6201500'.
```

Esse tipo de validação precisa ocorrer antes do cálculo para garantir que os dados utilizados sejam coerentes.

#### 2. Testes de Cálculo de Tributos e Créditos

Após validar as vinculações, o sistema deve calcular os tributos ISS, IBS e CBS, aplicando as alíquotas corretas e considerando os créditos tributários disponíveis.

**Exemplo completo de cálculo simplificado:**

```python
def calcular_custo_liquido(preco_bruto, aliquota_iss, aliquota_ibs, aliquota_cbs, credito_iss, credito_ibs, credito_cbs):
    iss = preco_bruto * aliquota_iss
    ibs = preco_bruto * aliquota_ibs
    cbs = preco_bruto * aliquota_cbs

    imposto_bruto = iss + ibs + cbs
    credito_total = credito_iss + credito_ibs + credito_cbs

    imposto_liquido = imposto_bruto - credito_total
    if imposto_liquido < 0:
        imposto_liquido = 0  # Limite mínimo zero para evitar imposto negativo

    custo_liquido = preco_bruto + imposto_liquido
    return custo_liquido

# Dados exemplo
preco = 100.00
aliquota_iss = 0.05  # 5%
aliquota_ibs = 0.10  # 10%
aliquota_cbs = 0.02  # 2%
credito_iss = 3.00
credito_ibs = 8.00
credito_cbs = 1.00

custo = calcular_custo_liquido(preco, aliquota_iss, aliquota_ibs, aliquota_cbs, credito_iss, credito_ibs, credito_cbs)
print(f"Custo líquido tributário: R$ {custo:.2f}")
```

**Saída:**

```
Custo líquido tributário: R$ 107.00
```

Esse cálculo deve ser testado com diferentes combinações de alíquotas e créditos para garantir que o imposto líquido seja calculado corretamente e respeite os limites legais.

#### 3. Testes de Casos Limítrofes e Exceções

É fundamental testar situações que podem gerar erros ou resultados inesperados, como:

- Créditos tributários maiores que o imposto devido (não pode gerar imposto negativo),
- Códigos desatualizados ou inexistentes,
- CNAE com múltiplas atividades (atividades mistas),
- Descontos condicionais e incondicionais na base de cálculo,
- Exclusão de impostos destacados da base.

**Exemplo prático de teste para crédito maior que imposto:**

```python
# Valores onde crédito ultrapassa imposto
credito_iss = 10.00  # maior que o ISS calculado
credito_ibs = 20.00
credito_cbs = 5.00

custo = calcular_custo_liquido(preco, aliquota_iss, aliquota_ibs, aliquota_cbs, credito_iss, credito_ibs, credito_cbs)
print(f"Custo líquido tributário (crédito maior que imposto): R$ {custo:.2f}")
```

**Saída correta:**

```
Custo líquido tributário (crédito maior que imposto): R$ 100.00
```

Observe que o imposto líquido não ficou negativo, respeitando o limite mínimo zero.

#### 4. Testes de Atualização e Sincronização das Tabelas Tributárias

Como os códigos CNAE, LC116 e NBS são atualizados oficialmente, o sistema deve incluir rotinas para validar se as tabelas utilizadas estão atualizadas e sincronizadas. Um erro comum ocorre quando a tabela de vinculação está desatualizada, levando a rejeições fiscais.

**Exemplo de mensagem de alerta para código desatualizado:**

```python
codigo_cnae = '6201500'
tabela_cnae_atualizada = {'6201500', '4741300', '5611203'}

if codigo_cnae not in tabela_cnae_atualizada:
    print(f"Atenção: CNAE '{codigo_cnae}' não encontrado na tabela atualizada. Atualize as tabelas oficiais.")
```

### Estratégias para garantir a correção dos cálculos

- **Testes unitários automatizados:** Implemente testes para cada função de cálculo e validação, usando conjuntos de dados representativos e casos de borda.
- **Testes de integração:** Valide o fluxo completo de vinculação CNAE → LC116 → NBS → cTribNac e cálculo tributário, simulando operações reais.
- **Logs detalhados:** Registre as etapas do cálculo e as validações para facilitar auditorias e identificação de erros.
- **Alertas e mensagens claras:** Informe o usuário sobre erros de vinculação ou inconsistências para correção imediata.
- **Atualização automática das tabelas:** Automatize a importação das tabelas oficiais e a validação de versões para manter a conformidade.
- **Simulações comparativas:** Teste cenários com múltiplos fornecedores para validar a comparação tributária e a escolha correta do custo líquido.

### Exemplo prático de teste completo em Python

```python
# Dados das tabelas (simplificadas)
vinculacao_cnae_lc116 = {
    '6201500': '0601',
    '4741300': '0310',
}

vinculacao_lc116_nbs = {
    '0601': '12345678',
    '0310': '87654321',
}

tabelas_cnae_atualizadas = {'6201500', '4741300'}
tabelas_lc116_atualizadas = {'0601', '0310'}
tabelas_nbs_atualizadas = {'12345678', '87654321'}

def validar_vinculacoes(cnae, lc116, nbs):
    if cnae not in tabelas_cnae_atualizadas:
        raise ValueError(f"CNAE '{cnae}' não está na tabela atualizada.")
    if lc116 not in tabelas_lc116_atualizadas:
        raise ValueError(f"LC116 '{lc116}' não está na tabela atualizada.")
    if nbs not in tabelas_nbs_atualizadas:
        raise ValueError(f"NBS '{nbs}' não está na tabela atualizada.")

    if vinculacao_cnae_lc116.get(cnae) != lc116:
        raise ValueError(f"Incompatibilidade: LC116 '{lc116}' não vinculado ao CNAE '{cnae}'.")
    if vinculacao_lc116_nbs.get(lc116) != nbs:
        raise ValueError(f"Incompatibilidade: NBS '{nbs}' não vinculado ao LC116 '{lc116}'.")

def calcular_custo_liquido(preco_bruto, aliquotas, creditos):
    iss = preco_bruto * aliquotas['iss']
    ibs = preco_bruto * aliquotas['ibs']
    cbs = preco_bruto * aliquotas['cbs']

    imposto_bruto = iss + ibs + cbs
    credito_total = creditos['iss'] + creditos['ibs'] + creditos['cbs']

    imposto_liquido = imposto_bruto - credito_total
    if imposto_liquido < 0:
        imposto_liquido = 0

    return preco_bruto + imposto_liquido

# Teste
try:
    cnae = '6201500'
    lc116 = '0601'
    nbs = '12345678'

    validar_vinculacoes(cnae, lc116, nbs)

    preco_bruto = 100.00
    aliquotas = {'iss': 0.05, 'ibs': 0.10, 'cbs': 0.02}
    creditos = {'iss': 3.00, 'ibs': 8.00, 'cbs': 1.00}

    custo_liquido = calcular_custo_liquido(preco_bruto, aliquotas, creditos)
    print(f"Custo líquido tributário calculado: R$ {custo_liquido:.2f}")

except ValueError as e:
    print(f"Erro na validação: {e}")
```

**Saída esperada:**

```
Custo líquido tributário calculado: R$ 107.00
```

### Erro de incompatibilidade na prática

Se alterarmos o LC116 para um código não vinculado ao CNAE:

```python
lc116_errado = '0310'
try:
    validar_vinculacoes(cnae, lc116_errado, nbs)
except ValueError as e:
    print(f"Erro detectado: {e}")
```

**Saída:**

```
Erro detectado: Incompatibilidade: LC116 '0310' não vinculado ao CNAE '6201500'.
```

Assim, o sistema evita prosseguir com dados incorretos.

---

## Conclusão e recomendações para testes

A qualidade e confiabilidade dos cálculos tributários dependem da correta vinculação entre códigos e da aplicação precisa das regras de cálculo, incluindo o uso correto dos créditos tributários. Os testes estruturados devem cobrir desde a validação dos códigos até o cálculo final do custo líquido tributário, considerando casos normais e de exceção.

Além disso, a atualização periódica das tabelas oficiais e a automação das validações são essenciais para evitar erros decorrentes de desatualização, fato comum após a reforma tributária.

A implantação desses testes e validações aumenta a segurança do sistema, evita multas e permite decisões mais informadas e econômicas na escolha de fornecedores, considerando o impacto real dos tributos e créditos, conforme o objetivo central deste curso.

---

### Exercício proposto

Desenvolva uma função que, dado o CNAE, o código LC116, o código NBS e o preço bruto, valide todas as vinculações entre esses códigos com base em tabelas atualizadas e calcule o custo líquido tributário considerando ISS, IBS e CBS com seus respectivos créditos, retornando mensagens claras de erro quando as vinculações forem incorretas ou os códigos desatualizados.

---