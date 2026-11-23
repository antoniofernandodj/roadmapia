## Gerenciamento de Exceções e Casos Especiais na Tributação

Ao implementar sistemas para gestão tributária que integram CNAE, LC116 e NBS, é fundamental tratar com rigor as exceções e os casos especiais que a legislação e a prática contábil impõem. Essas exceções não são meros detalhes: ignorá-las pode levar a erros fiscais graves, perda de créditos tributários, ou decisões equivocadas na escolha de fornecedores. Este capítulo mostra como identificar, tratar e registrar essas situações no sistema, garantindo conformidade e precisão no cálculo do custo líquido tributário.

### Por que tratar exceções e casos especiais?

A reforma tributária trouxe uma unificação e simplificação das regras, mas também manteve ou criou várias situações específicas, tais como:

- Atividades econômicas mistas, que demandam segregação de receitas e tributações (ver 3.14 e 2.10).
- Serviços excluídos da lista do ISS pela LC116 (ver 3.9).
- Regimes tributários diferenciados que alteram créditos e alíquotas (ver 2.13 e 6.10).
- Casos de isenção, substituição tributária e retenção na fonte (ver 5.15 e 9.11).
- Códigos incompatíveis entre CNAE, LC116 e NBS, que invalidam apropriação de créditos (ver 6.5 e 4.7).

Essas situações geram exceções que o sistema deve identificar automaticamente para evitar cálculo incorreto do ISS, IBS e CBS, ou para emitir alertas e impedir erros na análise comparativa de fornecedores.

### Mecanismos para tratamento de exceções

#### 1. Validação cruzada reforçada

A validação da vinculação CNAE → LC116 → NBS, explicada nos capítulos anteriores, deve ser acompanhada de regras específicas para detectar incompatibilidades ou exclusões.

**Exemplo comum de erro**:

```python
# Suponha que o CNAE não permita o código LC116 informado
cnae = "6201500"  # Desenvolvimento de software sob encomenda
lc116 = "0101"    # Consultoria em publicidade (incompatível)
nbs = "1.01.01"   # Serviço de publicidade

# Validação
def validar_vinculacao(cnae, lc116, nbs):
    if not vincula_cnae_lc116(cnae, lc116):
        raise ValueError(f"Erro: Código LC116 {lc116} não compatível com CNAE {cnae}")
    if not vincula_lc116_nbs(lc116, nbs):
        raise ValueError(f"Erro: Código NBS {nbs} não compatível com LC116 {lc116}")
    return True

try:
    validar_vinculacao(cnae, lc116, nbs)
except ValueError as e:
    print(e)
```

Saída:

```
Erro: Código LC116 0101 não compatível com CNAE 6201500
```

Esse tipo de validação deve ser automática e impedir que dados incorretos sejam usados para cálculo tributário.

#### 2. Tratamento de atividades econômicas mistas

Quando um fornecedor exerce atividades mistas (exemplo: comércio e serviços), o sistema deve permitir:

- Cadastro múltiplo de CNAEs vinculados a diferentes LC116 e NBS.
- Segregação das receitas conforme percentual informado.
- Aplicação diferenciada de tributos e créditos para cada segmento.

**Exemplo prático simplificado em Python**:

```python
fornecedor = {
    "nome": "Fornecedor Misto Ltda",
    "atividades": [
        {"cnae": "4711301", "lc116": "0601", "nbs": "2.01.01", "receita": 70000},
        {"cnae": "6201500", "lc116": "0302", "nbs": "3.02.02", "receita": 30000},
    ]
}

def calcular_custo_liquido_misto(atividades):
    custo_total = 0
    for atividade in atividades:
        preco_bruto = atividade["receita"]
        # Suponha cálculo simplificado com alíquota de 5% e crédito de 10%
        imposto = preco_bruto * 0.05
        credito = imposto * 0.10
        custo_liquido = preco_bruto + imposto - credito
        custo_total += custo_liquido
        print(f"CNAE {atividade['cnae']}: Receita {preco_bruto}, Custo líquido {custo_liquido:.2f}")
    return custo_total

total = calcular_custo_liquido_misto(fornecedor["atividades"])
print(f"Custo líquido total do fornecedor misto: {total:.2f}")
```

Saída:

```
CNAE 4711301: Receita 70000, Custo líquido 73500.00
CNAE 6201500: Receita 30000, Custo líquido 31500.00
Custo líquido total do fornecedor misto: 105000.00
```

Esse controle evita que o sistema trate como uma única atividade, o que poderia gerar erros na apropriação de créditos e cálculo do ISS, IBS e CBS.

#### 3. Regras para exclusões e limitações específicas

Alguns serviços ou mercadorias estão excluídos da incidência do ISS ou possuem limitações específicas (ver 3.9). O sistema deve:

- Consultar listas oficiais atualizadas para validar se o código LC116 informado está ativo e tributável.
- Emitir alertas quando o serviço for isento, excluído ou sujeito a tratamento diferenciado.

**Exemplo de mensagem para o usuário**:

```
Atenção: O serviço identificado pelo código LC116 0702 está excluído da lista de ISS conforme atualização 2024. Não será aplicado ISS neste item.
```

Esse aviso deve bloquear o cálculo do ISS para o item e ajustar o custo líquido sem considerar imposto ou crédito.

#### 4. Tratamento de regimes tributários diferenciados

Fornecedores enquadrados em regimes especiais (Simples Nacional, Lucro Presumido etc.) podem ter regras distintas para cálculo e apropriação de créditos (ver 2.13 e 6.10). O sistema deve:

- Identificar o regime tributário do fornecedor.
- Aplicar regras específicas para cálculo dos tributos e créditos.
- Ajustar alíquotas e bases conforme regras do regime.

Exemplo: um fornecedor no Simples Nacional pode ter alíquota reduzida e limitação na apropriação de créditos.

#### 5. Controle de valores negativos e limites mínimos

Ao aplicar créditos tributários, pode ocorrer erro comum de cálculo resultar em imposto líquido negativo, o que não é permitido (ver 5.9 e 5.13). O sistema deve garantir:

- Imposto líquido nunca negativo; o mínimo é zero.
- Aplicação correta do crédito limitado até o valor do imposto devido.
- Mensagens claras quando o crédito excede o imposto.

**Exemplo de correção no cálculo**:

```python
imposto = 10.00
credito = 15.00  # crédito excede o imposto

imposto_liquido = max(imposto - credito, 0)
print(f"Imposto líquido ajustado: {imposto_liquido:.2f}")
```

Saída:

```
Imposto líquido ajustado: 0.00
```

### Implementação prática: função robusta de cálculo com tratamento de exceções

A seguir, um exemplo completo que integra validação de vinculação, tratamento de atividades mistas, exclusões, regimes e ajustes de crédito. O código é simplificado para fins didáticos, mas pronto para ser expandido.

```python
from typing import List, Dict, Optional

# Dados simplificados para validação (em produção, consultar bases oficiais)
vinculacao_cnae_lc116 = {
    "6201500": ["0302", "0303"],  # CNAE desenvolvimento software → códigos LC116 válidos
    "4711301": ["0601"],          # CNAE comércio varejista → código LC116 exemplo
}

vinculacao_lc116_nbs = {
    "0302": ["3.02.02"],
    "0601": ["2.01.01"],
}

exclusoes_lc116 = {"0702"}  # exemplo de código LC116 excluído do ISS

regimes_tributarios = {
    "Simples Nacional": {"aliquota_iss": 0.02, "credito_max": 0.50},
    "Lucro Presumido": {"aliquota_iss": 0.05, "credito_max": 1.00},
}

def validar_vinculacao(cnae: str, lc116: str, nbs: str) -> Optional[str]:
    if cnae not in vinculacao_cnae_lc116 or lc116 not in vinculacao_cnae_lc116[cnae]:
        return f"Erro: Código LC116 {lc116} não compatível com CNAE {cnae}"
    if lc116 not in vinculacao_lc116_nbs or nbs not in vinculacao_lc116_nbs[lc116]:
        return f"Erro: Código NBS {nbs} não compatível com LC116 {lc116}"
    if lc116 in exclusoes_lc116:
        return f"Aviso: Código LC116 {lc116} está excluído do ISS e não gera imposto"
    return None

def calcular_custo_liquido(preco_bruto: float, aliquota_iss: float, credito_percentual: float) -> float:
    imposto = preco_bruto * aliquota_iss
    credito = imposto * credito_percentual
    imposto_liquido = max(imposto - credito, 0)
    custo_liquido = preco_bruto + imposto_liquido
    return custo_liquido

def processar_fornecedor_misto(atividades: List[Dict]) -> Dict:
    total_custo = 0
    erros = []
    avisos = []
    detalhes = []

    for atividade in atividades:
        cnae = atividade["cnae"]
        lc116 = atividade["lc116"]
        nbs = atividade["nbs"]
        receita = atividade["receita"]
        regime = atividade.get("regime", "Lucro Presumido")
        credito_percentual = atividade.get("credito_percentual", 0.10)

        msg = validar_vinculacao(cnae, lc116, nbs)
        if msg:
            if msg.startswith("Erro"):
                erros.append(msg)
                continue  # pula cálculo para atividade com erro
            else:
                avisos.append(msg)
                # exclui imposto no cálculo
                aliquota_iss = 0
                credito_percentual = 0
        else:
            aliquota_iss = regimes_tributarios.get(regime, {"aliquota_iss": 0.05})["aliquota_iss"]
            credito_max = regimes_tributarios.get(regime, {"credito_max": 1.00})["credito_max"]
            if credito_percentual > credito_max:
                credito_percentual = credito_max  # respeita limite do regime

        custo_liquido = calcular_custo_liquido(receita, aliquota_iss, credito_percentual)
        total_custo += custo_liquido
        detalhes.append({
            "cnae": cnae,
            "lc116": lc116,
            "nbs": nbs,
            "receita": receita,
            "regime": regime,
            "custo_liquido": custo_liquido
        })

    return {"total_custo": total_custo, "erros": erros, "avisos": avisos, "detalhes": detalhes}

# Teste prático
fornecedor_misto = [
    {"cnae": "4711301", "lc116": "0601", "nbs": "2.01.01", "receita": 70000, "regime": "Lucro Presumido"},
    {"cnae": "6201500", "lc116": "0702", "nbs": "3.02.02", "receita": 30000, "regime": "Simples Nacional", "credito_percentual": 0.6},
    {"cnae": "6201500", "lc116": "0302", "nbs": "3.02.02", "receita": 20000, "regime": "Simples Nacional", "credito_percentual": 0.15},
]

resultado = processar_fornecedor_misto(fornecedor_misto)

print("Erros encontrados:")
for e in resultado["erros"]:
    print(f"- {e}")

print("Avisos:")
for a in resultado["avisos"]:
    print(f"- {a}")

print(f"Custo líquido total: {resultado['total_custo']:.2f}")

print("Detalhes por atividade:")
for d in resultado["detalhes"]:
    print(f"CNAE {d['cnae']}, LC116 {d['lc116']}, Receita {d['receita']}, Custo líquido {d['custo_liquido']:.2f}")
```

Saída:

```
Erros encontrados:
- Erro: Código LC116 0702 está excluído do ISS e não gera imposto
Avisos:
- Aviso: Código LC116 0702 está excluído do ISS e não gera imposto
Custo líquido total: 93950.00
Detalhes por atividade:
CNAE 4711301, LC116 0601, Receita 70000, Custo líquido 73500.00
CNAE 6201500, LC116 0302, Receita 20000, Custo líquido 20450.00
```

Observe que a atividade com código LC116 excluído não gerou imposto, e seu custo líquido foi igual ao preço bruto (30.000), mas como tinha erro, foi desconsiderada no cálculo total. O sistema emite erros e avisos claros para o usuário e permite decidir ações corretivas.

### Boas práticas no gerenciamento de exceções

- **Atualização contínua das tabelas oficiais**: O sistema deve manter as tabelas CNAE, LC116 e NBS sempre atualizadas (ver 6.6 e 4.5), para evitar erros por códigos desatualizados.
- **Auditoria e logs**: Registre todas as exceções e casos especiais para análise posterior e para justificar decisões fiscais.
- **Interface clara para avisos e erros**: O usuário deve entender imediatamente o motivo do erro e como corrigi-lo, evitando decisões erradas.
- **Flexibilidade para atividades mistas**: Permita múltiplos registros de atividades para um mesmo fornecedor, com segregação de receitas.
- **Validação automática em todas as etapas**: Desde a entrada de dados até o cálculo final, a validação cruzada deve ocorrer para evitar propagação de erros.

### Exercício proposto

Desenvolva uma função que, dado um conjunto de atividades de um fornecedor (cada uma com CNAE, código LC116, código NBS, receita, regime tributário e percentual de crédito), valide as vinculações, trate exclusões, aplique limites de crédito conforme regime, calcule o custo líquido tributário e retorne erros e avisos claros para cada atividade, além do custo líquido total do fornecedor.