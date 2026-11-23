## Exercícios Práticos de Implementação e Testes

A implementação prática em sistemas para gestão tributária não termina ao compreender os conceitos de CNAE, LC116, NBS, ISS, IBS, CBS e códigos cTribNac. A verdadeira segurança e eficiência vêm da aplicação contínua desses conceitos por meio de exercícios práticos que testam a correta vinculação, cálculo e comparação tributária entre fornecedores. Este trecho propõe exercícios que simulam cenários reais, incluindo erros comuns e seus tratamentos, para que o profissional desenvolva habilidades sólidas na automação tributária pós-reforma.

### Exercício 1: Validação da Vinculação CNAE → LC116 → NBS e Cálculo do Custo Líquido Tributário

**Objetivo:** Implementar uma função que recebe o código CNAE do fornecedor e o preço bruto da proposta, valida as vinculações para LC116 e NBS e calcula o custo líquido tributário considerando créditos tributários.

#### Passos e Requisitos

1. **Validação da Vinculação:**

   - Verifique se o CNAE informado está cadastrado e atualizado na tabela oficial.
   - Vincule o CNAE ao código de serviço LC116 correspondente; se não houver vinculação válida, retorne erro explicando a incompatibilidade.
   - Vincule o código LC116 ao código NBS; em caso de erro, informe a falha na correspondência.

2. **Cálculo do ISS, IBS e CBS:**

   - Com base no código LC116 e na NBS, determine as alíquotas vigentes para ISS, IBS e CBS.
   - Calcule o valor de cada tributo sobre o preço bruto, aplicando regras de base de cálculo e possíveis descontos condicionais conforme a legislação.
   - Aplique os créditos tributários de ISS, IBS e CBS conforme as regras vinculadas ao CNAE e códigos associados.

3. **Custo Líquido Tributário:**

   - Subtraia os créditos tributários do total dos tributos calculados.
   - Caso o imposto líquido seja negativo (créditos maiores que o tributo devido), limite o imposto a zero, conforme regras vigentes.
   - Calcule o custo líquido final: preço bruto + imposto líquido.

4. **Tratamento de Erros:**

   - Mensagens claras e específicas para cada falha de validação.
   - Registro do erro para auditoria e revisão futura.

#### Código Exemplo em Python

```python
# Dados simulados para exemplo (em produção, consulte base oficial atualizada)
tabela_cnae = {
    "6201500": {"descricao": "Desenvolvimento de Programas de Computador Sob Encomenda", "lc116": "0101"},
    "4611302": {"descricao": "Representantes Comerciais e Agentes do Comércio", "lc116": "0302"},
}

tabela_lc116_nbs = {
    "0101": {"descricao": "Serviços de programação", "nbs": "6201500"},
    "0302": {"descricao": "Agenciamento comercial", "nbs": "4611302"},
}

aliquotas_tributos = {
    "ISS": 0.05,
    "IBS": 0.12,
    "CBS": 0.06,
}

creditos_tributarios = {
    "6201500": {"ISS": 0.15, "IBS": 0.00, "CBS": 0.00},
    "4611302": {"ISS": 0.00, "IBS": 0.01, "CBS": 0.02},
}

def calcular_custo_liquido(cnae: str, preco_bruto: float):
    # Validação CNAE
    if cnae not in tabela_cnae:
        return {"erro": f"CNAE {cnae} não encontrado na base oficial."}

    lc116 = tabela_cnae[cnae]["lc116"]
    # Validação LC116
    if lc116 not in tabela_lc116_nbs:
        return {"erro": f"Código LC116 {lc116} correspondente ao CNAE {cnae} não encontrado."}

    nbs = tabela_lc116_nbs[lc116]["nbs"]
    if nbs != cnae:
        return {"erro": f"Incompatibilidade entre NBS {nbs} e CNAE {cnae}."}

    # Cálculo dos tributos
    iss = aliquotas_tributos["ISS"] * preco_bruto
    ibs = aliquotas_tributos["IBS"] * preco_bruto
    cbs = aliquotas_tributos["CBS"] * preco_bruto

    # Aplicação dos créditos tributários
    creditos = creditos_tributarios.get(cnae, {"ISS": 0, "IBS": 0, "CBS": 0})
    credito_iss = creditos["ISS"] * preco_bruto
    credito_ibs = creditos["IBS"] * preco_bruto
    credito_cbs = creditos["CBS"] * preco_bruto

    imposto_liquido = max(0, (iss - credito_iss) + (ibs - credito_ibs) + (cbs - credito_cbs))
    custo_liquido = preco_bruto + imposto_liquido

    return {
        "CNAE": cnae,
        "LC116": lc116,
        "NBS": nbs,
        "Preço Bruto": preco_bruto,
        "ISS": iss,
        "IBS": ibs,
        "CBS": cbs,
        "Crédito ISS": credito_iss,
        "Crédito IBS": credito_ibs,
        "Crédito CBS": credito_cbs,
        "Imposto Líquido": imposto_liquido,
        "Custo Líquido": custo_liquido,
    }

# Teste com fornecedor válido
resultado = calcular_custo_liquido("6201500", 100.00)
for k, v in resultado.items():
    print(f"{k}: {v}")
```

#### Saída Esperada

```
CNAE: 6201500
LC116: 0101
NBS: 6201500
Preço Bruto: 100.0
ISS: 5.0
IBS: 12.0
CBS: 6.0
Crédito ISS: 15.0
Crédito IBS: 0.0
Crédito CBS: 0.0
Imposto Líquido: 8.0
Custo Líquido: 108.0
```

> **Nota:** O exemplo acima simula créditos superiores ao ISS, porém não ultrapassa o imposto total, que é a soma dos três tributos, e o imposto líquido não se torna negativo, respeitando a regra de limite mínimo zero.

---

### Exercício 2: Tratamento de Erros na Vinculação e Mensagens Claras

**Objetivo:** Desenvolver um módulo que, ao receber códigos CNAE, LC116 e NBS, valide a vinculação cruzada, identifique erros comuns (ex.: código desatualizado, incompatibilidade entre códigos, ausência de crédito tributário definido) e retorne mensagens claras para o usuário e logs para auditoria.

#### Cenários de Erro Simulados

- CNAE inexistente na base.
- Código LC116 não associado ao CNAE.
- Código NBS incompatível com LC116.
- Falta de definição de crédito tributário para código CNAE.
- Créditos tributários maiores que o tributo devido.

#### Exemplo de Tratamento e Mensagens

```python
def validar_vinculacoes(cnae: str, lc116: str, nbs: str):
    erros = []

    if cnae not in tabela_cnae:
        erros.append(f"CNAE {cnae} não encontrado.")
    else:
        esperado_lc116 = tabela_cnae[cnae]["lc116"]
        if esperado_lc116 != lc116:
            erros.append(f"Código LC116 {lc116} não corresponde ao CNAE {cnae} (esperado {esperado_lc116}).")

    if lc116 not in tabela_lc116_nbs:
        erros.append(f"Código LC116 {lc116} não encontrado.")
    else:
        esperado_nbs = tabela_lc116_nbs[lc116]["nbs"]
        if esperado_nbs != nbs:
            erros.append(f"Código NBS {nbs} não corresponde ao LC116 {lc116} (esperado {esperado_nbs}).")

    if cnae in creditos_tributarios:
        pass  # créditos definidos
    else:
        erros.append(f"Créditos tributários não definidos para CNAE {cnae}.")

    return erros

# Teste de validação com dados incorretos
erros = validar_vinculacoes("6201500", "9999", "6201500")
if erros:
    for erro in erros:
        print(f"Erro: {erro}")
else:
    print("Vinculação válida.")
```

#### Saída Esperada

```
Erro: Código LC116 9999 não corresponde ao CNAE 6201500 (esperado 0101).
```

---

### Exercício 3: Comparação Prática de Dois Fornecedores com Diferentes Créditos Tributários

**Objetivo:** Criar uma função que, dado o CNAE e preço bruto de dois fornecedores, calcule o custo líquido tributário para ambos e indique qual fornecedor oferece a melhor opção econômica considerando o crédito tributário.

#### Implementação

```python
def comparar_fornecedores(fornecedor1: dict, fornecedor2: dict):
    resultado1 = calcular_custo_liquido(fornecedor1["cnae"], fornecedor1["preco"])
    resultado2 = calcular_custo_liquido(fornecedor2["cnae"], fornecedor2["preco"])

    if "erro" in resultado1:
        print(f"Fornecedor 1: {resultado1['erro']}")
        return
    if "erro" in resultado2:
        print(f"Fornecedor 2: {resultado2['erro']}")
        return

    custo1 = resultado1["Custo Líquido"]
    custo2 = resultado2["Custo Líquido"]

    print(f"Fornecedor 1 - Custo Líquido: R$ {custo1:.2f}")
    print(f"Fornecedor 2 - Custo Líquido: R$ {custo2:.2f}")

    if custo1 < custo2:
        print("Fornecedor 1 é a melhor opção econômica.")
    elif custo2 < custo1:
        print("Fornecedor 2 é a melhor opção econômica.")
    else:
        print("Ambos fornecedores têm custo líquido equivalente.")

# Dados de fornecedores
fornecedor_a = {"cnae": "6201500", "preco": 100.00}
fornecedor_b = {"cnae": "4611302", "preco": 95.00}

comparar_fornecedores(fornecedor_a, fornecedor_b)
```

#### Saída Esperada

```
Fornecedor 1 - Custo Líquido: R$ 108.00
Fornecedor 2 - Custo Líquido: R$ 104.20
Fornecedor 2 é a melhor opção econômica.
```

---

### Exercício 4: Atualização e Validação Automática das Tabelas Tributárias

**Objetivo:** Implementar uma rotina simples que simule a atualização anual das tabelas CNAE, LC116 e NBS, validando automaticamente a consistência das vinculações.

#### Fluxo Básico

1. Recebe arquivos atualizados das tabelas oficiais (simulados por dicionários).
2. Atualiza as tabelas internas do sistema.
3. Executa validação cruzada para garantir que cada CNAE tenha um LC116 válido e cada LC116 tenha um NBS válido.
4. Gera relatório de erros e inconsistências para correção.

#### Exemplo Simplificado

```python
def atualizar_tabelas(nova_cnae, nova_lc116_nbs):
    global tabela_cnae, tabela_lc116_nbs
    tabela_cnae = nova_cnae
    tabela_lc116_nbs = nova_lc116_nbs

    erros = []
    for cnae, dados in tabela_cnae.items():
        lc116 = dados.get("lc116")
        if lc116 not in tabela_lc116_nbs:
            erros.append(f"LC116 {lc116} do CNAE {cnae} não encontrado na tabela LC116-NBS.")
        else:
            nbs = tabela_lc116_nbs[lc116].get("nbs", None)
            if not nbs:
                erros.append(f"NBS não definido para LC116 {lc116}.")

    return erros

# Simulação de atualizações
nova_cnae = {
    "6201500": {"descricao": "Desenvolvimento de Software", "lc116": "0101"},
    "9999999": {"descricao": "Atividade Não Classificada", "lc116": "9999"},
}

nova_lc116_nbs = {
    "0101": {"descricao": "Serviços de TI", "nbs": "6201500"},
    # LC116 9999 ausente intencionalmente para teste
}

erros_update = atualizar_tabelas(nova_cnae, nova_lc116_nbs)
if erros_update:
    for erro in erros_update:
        print(f"Erro na atualização: {erro}")
else:
    print("Atualização concluída sem erros.")
```

#### Saída Esperada

```
Erro na atualização: LC116 9999 do CNAE 9999999 não encontrado na tabela LC116-NBS.
```

---

### Exercício 5: Interface CLI Básica para Consulta e Cálculo Tributário

**Objetivo:** Desenvolver uma interface simples em linha de comando para:

- Pesquisar códigos CNAE.
- Validar vinculações LC116 e NBS.
- Calcular custo líquido tributário a partir do preço bruto.
- Exibir mensagens de erro claras.

#### Esboço de Interface

```python
def interface_cli():
    while True:
        print("\nMenu:")
        print("1 - Pesquisar CNAE")
        print("2 - Validar vinculações e calcular custo")
        print("3 - Sair")
        opcao = input("Escolha uma opção: ")

        if opcao == "1":
            cnae = input("Digite o código CNAE: ")
            if cnae in tabela_cnae:
                print(f"CNAE {cnae}: {tabela_cnae[cnae]['descricao']}")
            else:
                print("CNAE não encontrado.")
        elif opcao == "2":
            cnae = input("Digite o código CNAE: ")
            preco = float(input("Digite o preço bruto: "))
            resultado = calcular_custo_liquido(cnae, preco)
            if "erro" in resultado:
                print(f"Erro: {resultado['erro']}")
            else:
                print("Resultado do cálculo:")
                for k, v in resultado.items():
                    if k != "CNAE" and k != "LC116" and k != "NBS":
                        print(f"{k}: {v}")
        elif opcao == "3":
            print("Encerrando.")
            break
        else:
            print("Opção inválida.")

# Para rodar a interface, descomente a linha abaixo:
# interface_cli()
```

---

## Considerações Finais

Os exercícios práticos acima são fundamentais para que o profissional de contabilidade tributária e desenvolvimento de sistemas compreenda a aplicação concreta dos conceitos em cenários reais, incluindo o tratamento de erros comuns, validação de tabelas, cálculo dos tributos e comparação entre fornecedores. A prática constante com esses exemplos prepara para o desenvolvimento de funcionalidades robustas e confiáveis, alinhadas à nova legislação pós-reforma.

---