## Exercícios — Código de Serviço LC116: Estrutura e Aplicação

### 1. Validação e Correção de Códigos LC116 para Atividades Econômicas Mistas  (intermediário)  
Dada a lista abaixo de fornecedores com seus CNAEs e códigos de serviço LC116 informados, identifique quais pares CNAE x LC116 estão incorretos para atividades mistas (comerciais e serviços). Para cada erro, corrija o código LC116 e justifique a segregação do ISS e ICMS na receita, indicando qual parte da receita deve usar LC116 e qual deve usar código NCM para o ICMS.

| Fornecedor | CNAE           | Código LC116 informado | Receita total (R$) | Receita serviço (R$) | Receita mercadoria (R$) |
|------------|----------------|------------------------|--------------------|---------------------|------------------------|
| Alfa Ltda  | 4711302 (Comércio varejista de equipamentos de informática) | 1234                   | 200.000            | 60.000              | 140.000               |
| Beta S.A.  | 6201500 (Desenvolvimento de software sob encomenda)          | 4321                   | 150.000            | 150.000             | 0                     |
| Gama ME    | 4741301 (Comércio varejista de artigos de papelaria)         | 5678                   | 100.000            | 20.000              | 80.000                |
| Delta Ltda | 9521100 (Reparação e manutenção de computadores)             | 8765                   | 80.000             | 80.000              | 0                     |

Explique os impactos fiscais da correção na contabilidade tributária e na emissão de notas fiscais.

### 2. Montagem de Tabela Vinculada LC116 x NBS para Serviços de Tecnologia  (desafio)  
A partir dos seguintes códigos LC116 de serviços ligados a tecnologia da informação, elabore uma tabela de vinculação com três códigos NBS para cada código LC116, considerando a hierarquia e detalhamento da NBS. Justifique para cada par LC116-NBS a relevância tributária e o impacto na apropriação de créditos do ISS.

| Código LC116 | Descrição resumida                 |
|--------------|----------------------------------|
| 1010         | Desenvolvimento de software      |
| 1020         | Serviços de consultoria em TI    |
| 1030         | Suporte e manutenção de sistemas |

Formate a tabela com colunas: LC116, Descrição LC116, Código NBS, Descrição NBS.

### 3. Cálculo Comparativo do ISS para Fornecedores com Diferentes CNAEs e Créditos Tributários  (intermediário)  
Considere a tabela abaixo com fornecedores, seus CNAEs, valores de serviços prestados e as alíquotas do ISS aplicáveis segundo o código LC116 vinculado. Sabendo que o crédito tributário a ser apropriado é 10% do ISS devido, calcule o ISS líquido (ISS devido menos crédito) para cada fornecedor. Indique qual fornecedor apresenta o menor custo líquido tributário.

| Fornecedor | CNAE           | Valor do serviço (R$) | Código LC116 | Alíquota ISS (%) |
|------------|----------------|----------------------|--------------|------------------|
| X          | 6201500        | 50.000               | 1010         | 5                |
| Y          | 7112100        | 45.000               | 1020         | 4,5              |
| Z          | 9512100        | 40.000               | 1030         | 5,5              |

Explique a importância da correta vinculação CNAE x LC116 para evitar erros no cálculo.

### 4. Identificação de Incompatibilidades entre CNAE, Código LC116 e NBS com Impacto em Emissão Fiscal  (desafio)  
Você recebeu a seguinte lista de serviços com seus CNAEs, códigos LC116 e códigos NBS informados. Identifique e corrija as incompatibilidades entre os códigos. Para cada erro encontrado, explique o impacto que a incompatibilidade causaria em sistemas fiscais, bloqueio de emissão de notas ou inconsistências na apuração do ISS.

| Serviço                          | CNAE     | Código LC116 | Código NBS |
|---------------------------------|----------|--------------|------------|
| Desenvolvimento de aplicativos  | 6201500  | 1010         | 25101010   |
| Consultoria financeira           | 6920300  | 1020         | 25102020   |
| Manutenção de computadores       | 9521100  | 1030         | 25103030   |
| Serviços jurídicos               | 6910100  | 1040         | 25101010   |

### 5. Implementação em Python: Validação Automática da Vinculação CNAE x LC116 e Cálculo do ISS  (desafio)  
Implemente um programa Python que receba uma lista de fornecedores com seus CNAEs, valores de serviços e códigos LC116 informados. O programa deve:

- Validar automaticamente se o código LC116 é compatível com o CNAE (considere uma tabela simplificada com as seguintes permissões:  
  - CNAE 6201500 → LC116 1010  
  - CNAE 7112100 → LC116 1020  
  - CNAE 9521100 → LC116 1030  
- Para registros válidos, calcular o ISS devido usando uma alíquota fixa de 5%.  
- Para registros inválidos, indicar o erro de incompatibilidade.  
- Exibir o resultado com fornecedor, CNAE, código LC116, valor do serviço, ISS devido ou mensagem de erro.

Dados de entrada para teste:

```python
fornecedores = [
    {"nome": "Fornecedor 1", "cnae": 6201500, "lc116": 1010, "valor": 100000},
    {"nome": "Fornecedor 2", "cnae": 7112100, "lc116": 1010, "valor": 80000},
    {"nome": "Fornecedor 3", "cnae": 9521100, "lc116": 1030, "valor": 50000},
]
```

---

## Soluções comentadas

### 1. Validação e Correção de Códigos LC116 para Atividades Econômicas Mistas

```python
# Explicação:
# Atividades mistas exigem segregação clara entre receita de mercadorias (tributada pelo ICMS usando código NCM)
# e receita de serviços (tributada pelo ISS usando código LC116).
# Os códigos LC116 devem ser compatíveis com o serviço presente na receita.
# CNAE 4711302 é comércio varejista (predominância mercadoria), uso incorreto de LC116 pode bloquear nota.
# CNAE 4741301 também é comércio varejista, e receita de serviço deve ser apropriadamente separada.
# CNAE 6201500 e 9521100 são de serviços, código LC116 deve estar correto para evitar erros fiscais.

# Correções:

# Alfa Ltda (4711302) — código LC116 incorreto: código 1234 provavelmente não é compatível com comércio varejista.
# Como a receita de serviço é 60.000, deve usar código LC116 compatível com serviços de informática ou suporte.
# Exemplo: LC116 = 1030 (suporte e manutenção de sistemas)
# Receita mercadoria (140.000) será tributada pelo ICMS com código NCM.

# Beta S.A. (6201500) — código LC116 4321 não compatível com desenvolvimento de software.
# Corrigir para 1010 (desenvolvimento de software).

# Gama ME (4741301) — código LC116 5678 não compatível.
# Receita serviço 20.000 deve usar código LC116 compatível com serviços de comércio varejista de papelaria.
# Exemplo: LC116 = 2010 (serviços administrativos ou similares).
# Receita mercadoria 80.000 tributada via NCM.

# Delta Ltda (9521100) — código LC116 8765 pode ser correto se corresponder a reparação de computadores.
# Confirmar se código corresponde a esse serviço; se não, corrigir para 1030.

# Impactos:
# Correção evita bloqueios na emissão de notas fiscais.
# Garante correta apropriação do crédito tributário do ISS.
# Segregação correta evita erros na apuração do ISS e ICMS, mantendo conformidade fiscal.
```

---

### 2. Montagem de Tabela Vinculada LC116 x NBS para Serviços de Tecnologia

```markdown
| LC116 | Descrição LC116             | NBS       | Descrição NBS                       |
|-------|----------------------------|-----------|-----------------------------------|
| 1010  | Desenvolvimento de software| 25101010  | Desenvolvimento de software customizado |
| 1010  | Desenvolvimento de software| 25101020  | Desenvolvimento de software padrão        |
| 1010  | Desenvolvimento de software| 25101030  | Suporte técnico para software              |
| 1020  | Consultoria em TI          | 25102010  | Consultoria em tecnologia da informação    |
| 1020  | Consultoria em TI          | 25102020  | Análise e planejamento de sistemas         |
| 1020  | Consultoria em TI          | 25102030  | Auditoria de sistemas                       |
| 1030  | Suporte e manutenção       | 25103010  | Manutenção corretiva de equipamentos       |
| 1030  | Suporte e manutenção       | 25103020  | Suporte técnico remoto                      |
| 1030  | Suporte e manutenção       | 25103030  | Instalação e configuração de sistemas      |

# Justificativa:
# A vinculação detalhada entre LC116 e NBS garante precisão na tributação.
# Permite cálculo correto do ISS e apropriação eficiente de créditos.
# A tabela reflete a hierarquia da NBS que detalha os serviços agrupados no LC116.
```

---

### 3. Cálculo Comparativo do ISS para Fornecedores com Diferentes CNAEs e Créditos Tributários

```python
fornecedores = [
    {"nome": "X", "cnae": 6201500, "valor": 50000, "lc116": 1010, "aliquota": 5},
    {"nome": "Y", "cnae": 7112100, "valor": 45000, "lc116": 1020, "aliquota": 4.5},
    {"nome": "Z", "cnae": 9512100, "valor": 40000, "lc116": 1030, "aliquota": 5.5},
]

print("Fornecedor | ISS devido | Crédito (10%) | ISS líquido")
for f in fornecedores:
    iss_devido = f["valor"] * f["aliquota"] / 100
    credito = iss_devido * 0.10
    iss_liquido = iss_devido - credito
    print(f'{f["nome"]:10} | R$ {iss_devido:8.2f} | R$ {credito:11.2f} | R$ {iss_liquido:9.2f}')

# Resultado:
# Fornecedor | ISS devido | Crédito (10%) | ISS líquido
# X          | R$  2500.00 | R$      250.00 | R$    2250.00
# Y          | R$  2025.00 | R$      202.50 | R$    1822.50
# Z          | R$  2200.00 | R$      220.00 | R$    1980.00

# Menor custo líquido tributário: Fornecedor Y (R$ 1822,50)

# Importância da vinculação CNAE x LC116:
# Garante alíquota correta e evita erros de cálculo.
# Influencia diretamente no custo líquido e decisão de escolha.
```

---

### 4. Identificação de Incompatibilidades entre CNAE, Código LC116 e NBS com Impacto em Emissão Fiscal

```python
# Análise dos dados:

# Serviço: Desenvolvimento de aplicativos
# CNAE: 6201500 (desenvolvimento de software)
# LC116: 1010 (desenvolvimento de software) -> correto
# NBS: 25101010 (desenvolvimento de software customizado) -> compatível

# Serviço: Consultoria financeira
# CNAE: 6920300 (atividades contábeis e consultoria financeira)
# LC116: 1020 (consultoria em TI) -> incompatível
# NBS: 25102020 (consultoria em TI) -> incompatível
# Correção: LC116 e NBS devem corresponder a consultoria financeira (exemplo LC116=2050, NBS=25105010)

# Serviço: Manutenção de computadores
# CNAE: 9521100 (reparação de computadores)
# LC116: 1030 (suporte e manutenção de sistemas) -> compatível
# NBS: 25103030 (instalação e configuração) -> compatível

# Serviço: Serviços jurídicos
# CNAE: 6910100 (serviços jurídicos)
# LC116: 1040 (não definido no contexto, mas suponha código errado para serviço jurídico)
# NBS: 25101010 (desenvolvimento de software) -> incompatível
# Correção: LC116 e NBS devem refletir serviços jurídicos (exemplo LC116=1070, NBS=25107010)

# Impactos:
# Incompatibilidade causa rejeição automática na emissão fiscal.
# Bloqueio da nota, atrasos fiscais, e inconsistências na apuração do ISS.
# Pode impedir apropriação correta de créditos e gerar passivos fiscais.

# Recomenda-se validação cruzada automática e atualização constante das tabelas.
```

---

### 5. Implementação em Python: Validação Automática da Vinculação CNAE x LC116 e Cálculo do ISS

```python
fornecedores = [
    {"nome": "Fornecedor 1", "cnae": 6201500, "lc116": 1010, "valor": 100000},
    {"nome": "Fornecedor 2", "cnae": 7112100, "lc116": 1010, "valor": 80000},
    {"nome": "Fornecedor 3", "cnae": 9521100, "lc116": 1030, "valor": 50000},
]

# Tabela simplificada de permissões CNAE x LC116
permissao = {
    6201500: [1010],
    7112100: [1020],
    9521100: [1030],
}

aliquota_iss = 0.05  # 5%

print(f'{"Fornecedor":15} {"CNAE":8} {"LC116":6} {"Valor":10} {"ISS devido":12} {"Status"}')
for f in fornecedores:
    cnae = f["cnae"]
    lc = f["lc116"]
    valor = f["valor"]
    if cnae in permissao and lc in permissao[cnae]:
        iss_devido = valor * aliquota_iss
        status = "OK"
        print(f'{f["nome"]:15} {cnae:<8} {lc:<6} R$ {valor:9,.2f} R$ {iss_devido:11,.2f} {status}')
    else:
        print(f'{f["nome"]:15} {cnae:<8} {lc:<6} R$ {valor:9,.2f} {"-"*12} Incompatibilidade CNAE x LC116')

# Saída:
# Fornecedor      CNAE     LC116  Valor       ISS devido   Status
# Fornecedor 1    6201500  1010   R$ 100,000.00 R$ 5,000.00 OK
# Fornecedor 2    7112100  1010   R$ 80,000.00  ------------ Incompatibilidade CNAE x LC116
# Fornecedor 3    9521100  1030   R$ 50,000.00  R$ 2,500.00 OK

# Decisão:
# Validação automatizada evita erros fiscais.
# Cálculo do ISS só é feito para pares válidos.
# Mensagem clara para correção de dados.
```