## Exercícios Práticos para Fixação do Conteúdo Integrado

Este conjunto de exercícios integra os principais conceitos, códigos e cálculos tributários abordados na obra, permitindo consolidar o conhecimento para análise prática e automatizada na escolha do melhor fornecedor, considerando o custo líquido tributário real após a apropriação dos créditos fiscais. O foco está em aplicar a sequência lógica e a validação integrada: CNAE → LC116 → NBS → Códigos cTribNac, e o cálculo do ISS, IBS e CBS com seus respectivos créditos.

---

### Exercício 1: Validação e Cálculo do Custo Líquido para um Fornecedor

**Contexto:**  
O Fornecedor C apresenta as seguintes informações:

| Campo                    | Valor                        |
|--------------------------|-----------------------------|
| CNAE                     | 8110-2/00                   |
| Código de Serviço LC116  | 7.02 (Serviços de limpeza)  |
| Código NBS               | 7010100 (Serviços de limpeza) |
| Preço bruto do serviço   | R$ 1.200,00                 |
| Alíquota ISS             | 5%                          |
| Alíquota IBS             | 3%                          |
| Alíquota CBS             | 1,5%                        |
| Crédito tributário ISS   | 10% do ISS calculado        |
| Crédito tributário IBS   | 100% do IBS calculado       |
| Crédito tributário CBS   | 50% do CBS calculado        |

**Tarefa:**  
1. Valide a compatibilidade do CNAE com o código LC116. Caso haja incompatibilidade, mostre a mensagem literal de erro esperada e corrija-a com o código certo para o CNAE informado.  
2. Valide a vinculação entre LC116 e NBS, reportando erro se houver.  
3. Calcule os valores brutos de ISS, IBS e CBS.  
4. Aplique os créditos tributários conforme as porcentagens acima, respeitando o limite de imposto líquido não negativo.  
5. Calcule o custo líquido do serviço, subtraindo os créditos do preço bruto.  
6. Apresente todas as etapas, os cálculos e o resultado final do custo líquido.  

---

### Solução Comentada para Exercício 1

#### Passo 1: Validação CNAE x LC116

- CNAE informado: 8110-2/00 (Atividades de limpeza em prédios e em domicílios)
- Código LC116 informado: 7.02 (Serviços de limpeza)

Verificando a tabela vinculativa (ver 3.12 e 8.2), a vinculação correta para CNAE 8110-2/00 é LC116 7.02. Como o código informado está correto, nenhuma mensagem de erro será emitida.

Caso fosse incompatível, a mensagem típica seria:

```
Erro de incompatibilidade CNAE-LC116: CNAE 8110-2/00 não corresponde ao código LC116 7.05.
```

#### Passo 2: Validação LC116 x NBS

- LC116: 7.02 (Serviços de limpeza)
- NBS: 7010100 (Serviços de limpeza)

Segundo a tabela de vinculação (ver 4.7 e 6.8), esses códigos são compatíveis, então não há erro.

Se fosse incompatível, a mensagem típica seria:

```
Erro: Código NBS 7010100 não compatível com código LC116 7.02.
```

#### Passo 3: Cálculo dos tributos brutos

- ISS bruto = Preço bruto × alíquota ISS = R$ 1.200,00 × 5% = R$ 60,00  
- IBS bruto = R$ 1.200,00 × 3% = R$ 36,00  
- CBS bruto = R$ 1.200,00 × 1,5% = R$ 18,00  

#### Passo 4: Aplicação dos créditos tributários

- Crédito ISS = 10% × R$ 60,00 = R$ 6,00  
- Crédito IBS = 100% × R$ 36,00 = R$ 36,00  
- Crédito CBS = 50% × R$ 18,00 = R$ 9,00  

Verificar limite para imposto líquido não negativo (ver 5.9, 5.13):

- ISS líquido = R$ 60,00 - R$ 6,00 = R$ 54,00  
- IBS líquido = R$ 36,00 - R$ 36,00 = R$ 0,00 (não pode ser negativo)  
- CBS líquido = R$ 18,00 - R$ 9,00 = R$ 9,00  

#### Passo 5: Cálculo do custo líquido tributário

Custo líquido = Preço bruto + ISS líquido + IBS líquido + CBS líquido  
Custo líquido = R$ 1.200,00 + R$ 54,00 + R$ 0,00 + R$ 9,00 = R$ 1.263,00  

---

### Exercício 2: Comparação Tributária Entre Três Fornecedores

Considere os fornecedores A, B e C abaixo, com seus dados de CNAE, LC116, NBS, preço bruto e créditos tributários:

| Fornecedor | CNAE        | LC116 | NBS     | Preço Bruto | Créditos ISS | Créditos IBS | Créditos CBS | Alíquotas ISS/IBS/CBS (%) |
|------------|-------------|-------|---------|-------------|--------------|--------------|--------------|---------------------------|
| A          | 6201-5/01   | 9.01  | 8512100 | R$ 5.000,00 | 15%          | 100%         | 50%          | 5 / 3 / 1,5               |
| B          | 6202-3/00   | 9.02  | 8512100 | R$ 4.800,00 | 10%          | 100%         | 50%          | 5 / 3 / 1,5               |
| C          | 8110-2/00   | 7.02  | 7010100 | R$ 5.200,00 | 10%          | 100%         | 50%          | 5 / 3 / 1,5               |

**Tarefas:**

1. Para cada fornecedor, valide as vinculações CNAE x LC116 e LC116 x NBS; corrija eventuais inconsistências.  
2. Calcule o ISS, IBS e CBS brutos para cada um.  
3. Aplique os créditos tributários correspondentes.  
4. Calcule o custo líquido tributário total para cada fornecedor.  
5. Apresente os resultados ordenados do menor para o maior custo líquido e indique qual fornecedor é a melhor opção tributária.  

---

### Solução Comentada para Exercício 2

**Passo 1: Validação das vinculações**

- Fornecedor A: CNAE 6201-5/01 (Desenvolvimento de software sob encomenda)  
  Código LC116 9.01 (Serviços de informática)  
  Código NBS 8512100 (Serviços de informática)  
  Relações compatíveis conforme tabela  

- Fornecedor B: CNAE 6202-3/00 (Desenvolvimento e licenciamento de programas de computador)  
  Código LC116 9.02 (Serviços de informática e congêneres)  
  Código NBS 8512100 (Serviços de informática)  
  Relações compatíveis  

- Fornecedor C: já validado no exercício 1  

**Passo 2: Cálculo dos tributos brutos**

Para simplificar, aplicamos as alíquotas sobre o preço bruto:

| Fornecedor | ISS Bruto  | IBS Bruto  | CBS Bruto  |
|------------|------------|------------|------------|
| A          | 5.000 × 5% = 250,00  | 5.000 × 3% = 150,00  | 5.000 × 1,5% = 75,00   |
| B          | 4.800 × 5% = 240,00  | 4.800 × 3% = 144,00  | 4.800 × 1,5% = 72,00   |
| C          | 5.200 × 5% = 260,00  | 5.200 × 3% = 156,00  | 5.200 × 1,5% = 78,00   |

**Passo 3: Aplicação dos créditos tributários**

| Fornecedor | Crédito ISS | Crédito IBS | Crédito CBS |
|------------|-------------|-------------|-------------|
| A          | 15% × 250 = 37,50  | 100% × 150 = 150,00   | 50% × 75 = 37,50    |
| B          | 10% × 240 = 24,00  | 100% × 144 = 144,00   | 50% × 72 = 36,00    |
| C          | 10% × 260 = 26,00  | 100% × 156 = 156,00   | 50% × 78 = 39,00    |

**Passo 4: Imposto líquido (não negativo)**

| Fornecedor | ISS Líquido | IBS Líquido | CBS Líquido |
|------------|-------------|-------------|-------------|
| A          | 250 - 37,50 = 212,50 | 150 - 150 = 0,00   | 75 - 37,50 = 37,50  |
| B          | 240 - 24,00 = 216,00 | 144 - 144 = 0,00   | 72 - 36,00 = 36,00  |
| C          | 260 - 26,00 = 234,00 | 156 - 156 = 0,00   | 78 - 39,00 = 39,00  |

**Passo 5: Custo líquido tributário total**

| Fornecedor | Custo Líquido |
|------------|---------------|
| A          | 5.000 + 212,50 + 0 + 37,50 = R$ 5.250,00  |
| B          | 4.800 + 216,00 + 0 + 36,00 = R$ 5.052,00  |
| C          | 5.200 + 234,00 + 0 + 39,00 = R$ 5.473,00  |

**Resultado:** Fornecedor B apresenta o menor custo líquido, apesar do preço bruto inferior ao Fornecedor C, devido à combinação de alíquotas e créditos tributários. Fornecedor A é o mais caro.

---

### Exercício 3: Implementação Simplificada em Python para Comparação Tributária

```python
# Dados dos fornecedores
fornecedores = [
    {
        "nome": "A",
        "cnae": "6201-5/01",
        "lc116": "9.01",
        "nbs": "8512100",
        "preco_bruto": 5000.00,
        "aliquota_iss": 0.05,
        "aliquota_ibs": 0.03,
        "aliquota_cbs": 0.015,
        "credito_iss": 0.15,
        "credito_ibs": 1.00,
        "credito_cbs": 0.50,
    },
    {
        "nome": "B",
        "cnae": "6202-3/00",
        "lc116": "9.02",
        "nbs": "8512100",
        "preco_bruto": 4800.00,
        "aliquota_iss": 0.05,
        "aliquota_ibs": 0.03,
        "aliquota_cbs": 0.015,
        "credito_iss": 0.10,
        "credito_ibs": 1.00,
        "credito_cbs": 0.50,
    },
    {
        "nome": "C",
        "cnae": "8110-2/00",
        "lc116": "7.02",
        "nbs": "7010100",
        "preco_bruto": 5200.00,
        "aliquota_iss": 0.05,
        "aliquota_ibs": 0.03,
        "aliquota_cbs": 0.015,
        "credito_iss": 0.10,
        "credito_ibs": 1.00,
        "credito_cbs": 0.50,
    }
]

# Função para validar vinculação CNAE x LC116 (simplificada)
def validar_cnae_lc116(cnae, lc116):
    vinculos_validos = {
        "6201-5/01": "9.01",
        "6202-3/00": "9.02",
        "8110-2/00": "7.02",
    }
    return vinculos_validos.get(cnae) == lc116

# Função para validar vinculação LC116 x NBS (simplificada)
def validar_lc116_nbs(lc116, nbs):
    vinculos_validos = {
        "9.01": "8512100",
        "9.02": "8512100",
        "7.02": "7010100",
    }
    return vinculos_validos.get(lc116) == nbs

# Função para calcular custo líquido tributário
def calcular_custo_liquido(fornecedor):
    if not validar_cnae_lc116(fornecedor["cnae"], fornecedor["lc116"]):
        raise ValueError(
            f"Erro de incompatibilidade CNAE-LC116: CNAE {fornecedor['cnae']} não corresponde ao código LC116 {fornecedor['lc116']}."
        )
    if not validar_lc116_nbs(fornecedor["lc116"], fornecedor["nbs"]):
        raise ValueError(
            f"Erro: Código NBS {fornecedor['nbs']} não compatível com código LC116 {fornecedor['lc116']}."
        )

    preco = fornecedor["preco_bruto"]

    iss_bruto = preco * fornecedor["aliquota_iss"]
    ibs_bruto = preco * fornecedor["aliquota_ibs"]
    cbs_bruto = preco * fornecedor["aliquota_cbs"]

    credito_iss = iss_bruto * fornecedor["credito_iss"]
    credito_ibs = ibs_bruto * fornecedor["credito_ibs"]
    credito_cbs = cbs_bruto * fornecedor["credito_cbs"]

    iss_liquido = max(iss_bruto - credito_iss, 0)
    ibs_liquido = max(ibs_bruto - credito_ibs, 0)
    cbs_liquido = max(cbs_bruto - credito_cbs, 0)

    custo_liquido = preco + iss_liquido + ibs_liquido + cbs_liquido

    return {
        "fornecedor": fornecedor["nome"],
        "custo_liquido": custo_liquido,
        "iss_liquido": iss_liquido,
        "ibs_liquido": ibs_liquido,
        "cbs_liquido": cbs_liquido,
    }


# Cálculo e ordenação dos fornecedores por custo líquido
resultados = []
for f in fornecedores:
    try:
        resultado = calcular_custo_liquido(f)
        resultados.append(resultado)
    except ValueError as e:
        print(e)

# Ordenar do menor para o maior custo líquido
resultados.sort(key=lambda x: x["custo_liquido"])

# Exibir resultados
for r in resultados:
    print(f"Fornecedo {r['fornecedor']}: Custo Líquido = R$ {r['custo_liquido']:.2f} (ISS: R$ {r['iss_liquido']:.2f}, IBS: R$ {r['ibs_liquido']:.2f}, CBS: R$ {r['cbs_liquido']:.2f})")
```

---

**Saída esperada:**

```
Fornecedo B: Custo Líquido = R$ 5052.00 (ISS: R$ 216.00, IBS: R$ 0.00, CBS: R$ 36.00)
Fornecedo A: Custo Líquido = R$ 5250.00 (ISS: R$ 212.50, IBS: R$ 0.00, CBS: R$ 37.50)
Fornecedo C: Custo Líquido = R$ 5473.00 (ISS: R$ 234.00, IBS: R$ 0.00, CBS: R$ 39.00)
```

---

### Exercício 4: Diagnóstico de Erros Comuns em Vinculações

Considere que ao cadastrar o Fornecedor D você recebeu o seguinte erro em seu sistema:

```
Erro de incompatibilidade CNAE-LC116: CNAE 8110-2/00 não corresponde ao código LC116 9.01.
```

**Tarefas:**

1. Explique, com base nos conceitos já estudados, o que causou esse erro.  
2. Proponha a correção adequada para a vinculação CNAE x LC116 do Fornecedor D, cujo CNAE é 8110-2/00 (atividades de limpeza).  
3. Justifique a importância de corrigir essa incompatibilidade antes de prosseguir com o cálculo dos tributos.  

---

### Solução Comentada para Exercício 4

1. **Causa do erro:** O CNAE 8110-2/00 refere-se a atividades de limpeza, que devem ser vinculadas ao código LC116 7.02, não ao 9.01 (serviços de informática). A vinculação incorreta gera rejeição fiscal e impede o cálculo correto do ISS.  
2. **Correção:** Alterar o código LC116 para 7.02 para esse CNAE.  
3. **Justificativa:** A vinculação correta garante a aplicação das alíquotas e créditos tributários certos, evita erros fiscais e permite a apropriação correta dos créditos, impactando diretamente no custo líquido e na decisão de escolha do fornecedor.  

---

### Exercício 5: Atualização e Manutenção das Tabelas Tributárias em Sistema

Você está responsável por manter as tabelas oficiais no sistema para garantir que as análises tributárias estejam corretas.  

**Tarefas:**

1. Explique os riscos de trabalhar com tabelas desatualizadas de CNAE, LC116, NBS e cTribNac.  
2. Descreva uma rotina simples para validar automaticamente, ao iniciar o sistema, se as tabelas oficiais estão atualizadas para o ano corrente (2024).  
3. Demonstre em pseudocódigo a verificação da versão da tabela e o tratamento caso detecte desatualização.  

---

### Solução Comentada para Exercício 5

1. **Riscos:** Uso de códigos desatualizados pode causar rejeição fiscal na emissão de notas, perda de créditos tributários, cálculo incorreto dos impostos e autuações fiscais. Também compromete a comparação tributária entre fornecedores.  
2. **Rotina simples:** Ao iniciar o sistema, fazer consulta à fonte oficial (ex.: base da Receita Federal) para obter a data/versionamento da última atualização da tabela. Comparar com a versão local armazenada. Se diferente, sinalizar necessidade de atualização.  
3. **Pseudocódigo:**

```pseudo
versao_local = ler_versao_tabela_local()
versao_oficial = consultar_versao_tabela_oficial()

se versao_local < versao_oficial então
    emitir_alerta("Tabela desatualizada. Atualize para garantir conformidade fiscal.")
    bloquear_operacoes_que_dependem_das_tabelas()
senão
    permitir_operacoes_normais()
fim se
```

---

## Exercício Proposto:  
Calcule e compare o custo líquido do Fornecedor C considerando suas vinculações CNAE, LC116 e NBS, aplicando ISS, IBS e CBS com seus respectivos créditos tributários para decidir a melhor opção entre três fornecedores.

---