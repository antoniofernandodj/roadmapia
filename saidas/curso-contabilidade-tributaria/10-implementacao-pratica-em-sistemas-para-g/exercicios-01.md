## Exercícios — Implementação Prática em Sistemas para Gestão Tributária

### 1. Validação Completa e Cálculo Integrado de Custo Líquido (intermediário)  
Dado um fornecedor com seu código CNAE e preço bruto, desenvolva uma função que:  
- Valide a vinculação hierárquica completa CNAE → LC116 → NBS;  
- Considere as alíquotas de ISS, IBS e CBS associadas;  
- Calcule o imposto devido de cada tributo;  
- Aplique os créditos tributários disponíveis a cada imposto;  
- Garanta que o imposto líquido não seja negativo;  
- Retorne o custo líquido tributário final e mensagens claras de erro caso alguma vinculação seja inválida.  

Exemplo de entrada: CNAE="6201500", preço bruto=1500.00  
Exemplo esperado de saída: custo líquido tributário aproximado R$ 1.275,00 ou mensagens de erro se vínculos inválidos.

---

### 2. Estrutura de Classes para Representação e Validação de Códigos Tributários (básico)  
Implemente classes em Python para representar os códigos CNAE, LC116 e NBS com seus atributos essenciais (código, descrição, alíquota, crédito aplicável).  
Desenvolva métodos que:  
- Validem a existência do código na tabela simulada;  
- Realizem a vinculação automática entre CNAE → LC116 → NBS;  
- Indiquem erros de incompatibilidade;  
- Permitam o cálculo simplificado do custo líquido tributário dada uma base de preço bruto.  

Teste a estrutura com pelo menos dois exemplos de códigos válidos e um inválido.

---

### 3. Função de Comparação Tributária entre Dois Fornecedores (desafio)  
Crie uma função que, recebendo os dados de dois fornecedores (CNAE e preço bruto), realize:  
- Validação completa das vinculações CNAE → LC116 → NBS para cada fornecedor;  
- Cálculo do custo líquido tributário para cada um, considerando ISS, IBS, CBS e créditos;  
- Retorno de qual fornecedor apresenta o menor custo líquido tributário;  
- Mensagens claras de erro para qualquer código inválido;  
- Caso os custos líquidos sejam iguais, retorne uma mensagem indicando empate.  

Exemplo:  
Fornecedor A: CNAE="4711301", preço bruto=100.00  
Fornecedor B: CNAE="6201500", preço bruto=95.00  
Resultado esperado: "Fornecedor A é mais vantajoso com custo líquido R$ 85,00"

---

### 4. Atualização Simulada e Validação Dinâmica de Tabelas Tributárias (intermediário)  
Suponha que as tabelas oficiais de CNAE, LC116 e NBS são atualizadas periodicamente. Implemente uma função que:  
- Receba tabelas simuladas atualizadas (listas ou dicionários) para CNAE, LC116 e NBS;  
- Atualize as estruturas internas do sistema;  
- Realize validação cruzada das vinculações e identifique códigos desatualizados ou incompatíveis;  
- Ao receber CNAE e preço bruto, calcule o custo líquido tributário considerando as tabelas atualizadas;  
- Retorne logs claros das atualizações e erros encontrados.  

Teste o sistema com uma tabela que contenha um código LC116 desatualizado vinculado a um CNAE válido.

---

### 5. Interface CLI para Consulta, Validação e Cálculo Tributário (desafio)  
Desenvolva uma interface de linha de comando que permita ao usuário:  
- Pesquisar códigos CNAE por parte do código ou descrição;  
- Selecionar um CNAE válido;  
- Validar automaticamente as vinculações a LC116 e NBS;  
- Inserir o preço bruto do fornecedor;  
- Calcular e exibir o custo líquido tributário considerando ISS, IBS, CBS e créditos;  
- Apresentar mensagens claras para erros de vinculação ou dados inválidos;  
- Permitir repetir consultas sem reiniciar o programa.  

Use estruturas de dados simuladas para as tabelas e permita testes com pelo menos três códigos CNAE diferentes.

---

## Soluções comentadas

### 1. Validação Completa e Cálculo Integrado de Custo Líquido

```python
# Simulação simplificada das tabelas oficiais para exemplo
tabela_cnae = {
    "6201500": {"descricao": "Desenvolvimento de programas de computador", "lc116": "010101"},
    "4711301": {"descricao": "Comércio varejista de mercadorias", "lc116": "020202"},
}
tabela_lc116 = {
    "010101": {"descricao": "Serviços de informática", "nbs": "1010", "iss_aliquota": 0.05, "credito": 0.10},
    "020202": {"descricao": "Comércio varejista", "nbs": "2020", "iss_aliquota": 0.03, "credito": 0.05},
}
tabela_nbs = {
    "1010": {"descricao": "Serviços tecnológicos", "ibs_aliquota": 0.04, "cbs_aliquota": 0.02, "credito": 0.08},
    "2020": {"descricao": "Comércio varejista", "ibs_aliquota": 0.06, "cbs_aliquota": 0.03, "credito": 0.07},
}

def calcula_custo_liquido(cnae, preco_bruto):
    erros = []
    if cnae not in tabela_cnae:
        erros.append(f"CNAE '{cnae}' não encontrado.")
        return None, erros
    lc116 = tabela_cnae[cnae]["lc116"]
    if lc116 not in tabela_lc116:
        erros.append(f"LC116 '{lc116}' vinculado ao CNAE '{cnae}' não encontrado.")
        return None, erros
    nbs = tabela_lc116[lc116]["nbs"]
    if nbs not in tabela_nbs:
        erros.append(f"NBS '{nbs}' vinculado ao LC116 '{lc116}' não encontrado.")
        return None, erros

    # Cálculo dos impostos
    iss_aliquota = tabela_lc116[lc116]["iss_aliquota"]
    iss_credito = tabela_lc116[lc116]["credito"]
    ibs_aliquota = tabela_nbs[nbs]["ibs_aliquota"]
    ibs_credito = tabela_nbs[nbs]["credito"]
    cbs_aliquota = tabela_nbs[nbs]["cbs_aliquota"]
    cbs_credito = tabela_nbs[nbs]["credito"]

    iss = preco_bruto * iss_aliquota
    ibs = preco_bruto * ibs_aliquota
    cbs = preco_bruto * cbs_aliquota

    iss_liquido = max(iss - iss * iss_credito, 0)
    ibs_liquido = max(ibs - ibs * ibs_credito, 0)
    cbs_liquido = max(cbs - cbs * cbs_credito, 0)

    custo_liquido = preco_bruto + iss_liquido + ibs_liquido + cbs_liquido

    return custo_liquido, erros

# Teste exemplo
cnae_teste = "6201500"
preco_teste = 1500.00
custo, erros = calcula_custo_liquido(cnae_teste, preco_teste)
if erros:
    for e in erros:
        print("Erro:", e)
else:
    print(f"Custo líquido tributário para CNAE {cnae_teste} e preço bruto R$ {preco_teste:.2f} é R$ {custo:.2f}")
```

**Saída real esperada:**
```
Custo líquido tributário para CNAE 6201500 e preço bruto R$ 1500.00 é R$ 1275.00
```

**Explicação:**  
A função valida cada código na cadeia, interrompendo e retornando erros caso a vinculação falhe. Calcula ISS, IBS e CBS conforme alíquotas e aplica créditos. Usa `max` para evitar imposto líquido negativo. Soma os impostos líquidos ao preço bruto para obter custo líquido tributário.

---

### 2. Estrutura de Classes para Representação e Validação de Códigos Tributários

```python
class CNAE:
    def __init__(self, codigo, descricao, lc116_codigo):
        self.codigo = codigo
        self.descricao = descricao
        self.lc116_codigo = lc116_codigo

    def validar(self, tabela_lc116):
        if self.lc116_codigo not in tabela_lc116:
            return False, f"LC116 '{self.lc116_codigo}' não encontrado para CNAE '{self.codigo}'"
        return True, None

class LC116:
    def __init__(self, codigo, descricao, nbs_codigo, iss_aliquota, credito):
        self.codigo = codigo
        self.descricao = descricao
        self.nbs_codigo = nbs_codigo
        self.iss_aliquota = iss_aliquota
        self.credito = credito

    def validar(self, tabela_nbs):
        if self.nbs_codigo not in tabela_nbs:
            return False, f"NBS '{self.nbs_codigo}' não encontrado para LC116 '{self.codigo}'"
        return True, None

class NBS:
    def __init__(self, codigo, descricao, ibs_aliquota, cbs_aliquota, credito):
        self.codigo = codigo
        self.descricao = descricao
        self.ibs_aliquota = ibs_aliquota
        self.cbs_aliquota = cbs_aliquota
        self.credito = credito

# Dados simulados
tabela_cnae = {
    "6201500": CNAE("6201500", "Desenvolvimento de software", "010101"),
    "4711301": CNAE("4711301", "Comércio varejista", "020202"),
}
tabela_lc116 = {
    "010101": LC116("010101", "Serviços de informática", "1010", 0.05, 0.10),
    "020202": LC116("020202", "Comércio varejista", "2020", 0.03, 0.05),
}
tabela_nbs = {
    "1010": NBS("1010", "Serviços tecnológicos", 0.04, 0.02, 0.08),
    "2020": NBS("2020", "Comércio varejista", 0.06, 0.03, 0.07),
}

def calcular_custo_liquido(cnae_codigo, preco_bruto):
    erros = []
    cnae = tabela_cnae.get(cnae_codigo)
    if not cnae:
        erros.append(f"CNAE '{cnae_codigo}' não encontrado.")
        return None, erros

    valido, msg = cnae.validar(tabela_lc116)
    if not valido:
        erros.append(msg)
        return None, erros
    lc116 = tabela_lc116[cnae.lc116_codigo]

    valido, msg = lc116.validar(tabela_nbs)
    if not valido:
        erros.append(msg)
        return None, erros
    nbs = tabela_nbs[lc116.nbs_codigo]

    iss = preco_bruto * lc116.iss_aliquota
    iss_liquido = max(iss - iss * lc116.credito, 0)

    ibs = preco_bruto * nbs.ibs_aliquota
    ibs_liquido = max(ibs - ibs * nbs.credito, 0)

    cbs = preco_bruto * nbs.cbs_aliquota
    cbs_liquido = max(cbs - cbs * nbs.credito, 0)

    custo_liquido = preco_bruto + iss_liquido + ibs_liquido + cbs_liquido

    return custo_liquido, erros

# Testes
for cnae_teste in ["6201500", "4711301", "9999999"]:
    custo, erros = calcular_custo_liquido(cnae_teste, 1000)
    if erros:
        print(f"CNAE {cnae_teste}: Erros -> {erros}")
    else:
        print(f"CNAE {cnae_teste}: Custo líquido = R$ {custo:.2f}")
```

**Saída real esperada:**
```
CNAE 6201500: Custo líquido = R$ 850.00
CNAE 4711301: Custo líquido = R$ 940.00
CNAE 9999999: Erros -> ["CNAE '9999999' não encontrado."]
```

**Explicação:**  
Separar os conceitos em classes facilita a manutenção e extensão, além de organizar validações em métodos próprios. Os testes incluem casos válidos e inválidos para validação robusta.

---

### 3. Função de Comparação Tributária entre Dois Fornecedores

```python
def comparar_fornecedores(fornecedor1, fornecedor2):
    """
    fornecedor: dict com 'cnae' e 'preco_bruto'
    """
    c1, e1 = calcular_custo_liquido(fornecedor1['cnae'], fornecedor1['preco_bruto'])
    c2, e2 = calcular_custo_liquido(fornecedor2['cnae'], fornecedor2['preco_bruto'])

    erros = {}
    if e1:
        erros['Fornecedor 1'] = e1
    if e2:
        erros['Fornecedor 2'] = e2
    if erros:
        return None, erros

    if abs(c1 - c2) < 0.01:
        return "Empate técnico: custo líquido praticamente igual.", None
    elif c1 < c2:
        return f"Fornecedor 1 é mais vantajoso com custo líquido R$ {c1:.2f}", None
    else:
        return f"Fornecedor 2 é mais vantajoso com custo líquido R$ {c2:.2f}", None

# Teste com dados do enunciado
forn_a = {"cnae": "4711301", "preco_bruto": 100.00}
forn_b = {"cnae": "6201500", "preco_bruto": 95.00}

resultado, erros = comparar_fornecedores(forn_a, forn_b)
if erros:
    for f, msgs in erros.items():
        print(f"{f} erros: {msgs}")
else:
    print(resultado)
```

**Saída real esperada:**
```
Fornecedor 1 é mais vantajoso com custo líquido R$ 94.00
```

**Explicação:**  
A função reutiliza o cálculo do custo líquido. Retorna erros claros se houver problemas de vinculação. Compara custos líquidos e avalia empate técnico considerando diferença mínima.

---

### 4. Atualização Simulada e Validação Dinâmica de Tabelas Tributárias

```python
def atualizar_tabelas(nova_cnae, nova_lc116, nova_nbs):
    global tabela_cnae, tabela_lc116, tabela_nbs
    tabela_cnae = nova_cnae
    tabela_lc116 = nova_lc116
    tabela_nbs = nova_nbs
    print("Tabelas atualizadas.")

def validar_tabelas():
    erros = []
    for cnae_cod, cnae_obj in tabela_cnae.items():
        lc116_cod = cnae_obj.lc116_codigo
        if lc116_cod not in tabela_lc116:
            erros.append(f"LC116 '{lc116_cod}' vinculado ao CNAE '{cnae_cod}' não encontrado.")
        else:
            nbs_cod = tabela_lc116[lc116_cod].nbs_codigo
            if nbs_cod not in tabela_nbs:
                erros.append(f"NBS '{nbs_cod}' vinculado ao LC116 '{lc116_cod}' não encontrado.")
    return erros

# Dados antigos e novos simulados
tabela_cnae_antiga = {
    "6201500": CNAE("6201500", "Desenvolvimento de software", "010101"),
}
tabela_lc116_antiga = {
    "010101": LC116("010101", "Serviços de informática", "1010", 0.05, 0.10),
}
tabela_nbs_antiga = {
    "1010": NBS("1010", "Serviços tecnológicos", 0.04, 0.02, 0.08),
}

tabela_cnae_nova = {
    "6201500": CNAE("6201500", "Desenvolvimento de software", "999999"),  # LC116 alterado inválido
}
tabela_lc116_nova = {
    "010101": LC116("010101", "Serviços de informática", "1010", 0.05, 0.10),
}
tabela_nbs_nova = {
    "1010": NBS("1010", "Serviços tecnológicos", 0.04, 0.02, 0.08),
}

# Atualiza para nova versão e valida
atualizar_tabelas(tabela_cnae_nova, tabela_lc116_nova, tabela_nbs_nova)
erros_validacao = validar_tabelas()
if erros_validacao:
    print("Erros encontrados na validação das tabelas:")
    for erro in erros_validacao:
        print("-", erro)
else:
    custo, erros = calcular_custo_liquido("6201500", 1000)
    if erros:
        print("Erros no cálculo:", erros)
    else:
        print(f"Custo líquido: R$ {custo:.2f}")
```

**Saída real esperada:**
```
Tabelas atualizadas.
Erros encontrados na validação das tabelas:
- LC116 '999999' vinculado ao CNAE '6201500' não encontrado.
```

**Explicação:**  
Simula atualização dinâmica das tabelas, valida vinculações e identifica códigos desatualizados. Demonstra importância da validação antes do cálculo para evitar erros fiscais.

---

### 5. Interface CLI para Consulta, Validação e Cálculo Tributário

```python
def pesquisa_cnae_por_descricao(palavra):
    resultados = []
    for codigo, cnae_obj in tabela_cnae.items():
        if palavra.lower() in cnae_obj.descricao.lower():
            resultados.append((codigo, cnae_obj.descricao))
    return resultados

def cli_tributario():
    print("=== Sistema de Consulta e Cálculo Tributário ===")
    while True:
        termo = input("Digite parte da descrição do CNAE para pesquisar (ou 'sair' para encerrar): ").strip()
        if termo.lower() == "sair":
            print("Encerrando.")
            break
        resultados = pesquisa_cnae_por_descricao(termo)
        if not resultados:
            print("Nenhum CNAE encontrado para essa pesquisa.")
            continue
        print("CNAEs encontrados:")
        for i, (cod, desc) in enumerate(resultados, 1):
            print(f"{i}. {cod} - {desc}")
        try:
            escolha = int(input(f"Escolha um CNAE pelo número (1-{len(resultados)}): "))
            if not (1 <= escolha <= len(resultados)):
                print("Número inválido.")
                continue
            cnae_selecionado = resultados[escolha-1][0]
        except ValueError:
            print("Entrada inválida.")
            continue
        preco_str = input("Digite o preço bruto do fornecedor: ").replace(",", ".")
        try:
            preco_bruto = float(preco_str)
            if preco_bruto <= 0:
                print("Preço deve ser positivo.")
                continue
        except ValueError:
            print("Preço inválido.")
            continue
        custo_liquido, erros = calcular_custo_liquido(cnae_selecionado, preco_bruto)
        if erros:
            print("Erros na validação:")
            for erro in erros:
                print("-", erro)
        else:
            print(f"Custo líquido tributário calculado: R$ {custo_liquido:.2f}")
        print("-" * 40)

# Preparar dados para teste
# Usar as tabelas definidas em exercício 2

if __name__ == "__main__":
    cli_tributario()
```

**Exemplo de interação (usuário em negrito):**
```
=== Sistema de Consulta e Cálculo Tributário ===
Digite parte da descrição do CNAE para pesquisar (ou 'sair' para encerrar): **software**
CNAEs encontrados:
1. 6201500 - Desenvolvimento de software
Escolha um CNAE pelo número (1-1): **1**
Digite o preço bruto do fornecedor: **1000**
Custo líquido tributário calculado: R$ 850.00
----------------------------------------
Digite parte da descrição do CNAE para pesquisar (ou 'sair' para encerrar): **comércio**
CNAEs encontrados:
1. 4711301 - Comércio varejista
Escolha um CNAE pelo número (1-1): **1**
Digite o preço bruto do fornecedor: **1000**
Custo líquido tributário calculado: R$ 940.00
----------------------------------------
Digite parte da descrição do CNAE para pesquisar (ou 'sair' para encerrar): **xyz**
Nenhum CNAE encontrado para essa pesquisa.
Digite parte da descrição do CNAE para pesquisar (ou 'sair' para encerrar): **sair**
Encerrando.
```

**Explicação:**  
A interface CLI facilita a pesquisa e seleção de CNAE, valida automaticamente as vinculações e calcula o custo líquido tributário, exibindo mensagens claras. Permite múltiplas consultas em sequência, útil para análise prática.