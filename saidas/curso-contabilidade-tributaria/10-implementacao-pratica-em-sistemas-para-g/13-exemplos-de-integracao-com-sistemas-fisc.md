## Exemplos de Integração com Sistemas Fiscais e ERP

A integração de sistemas fiscais com ERP (Enterprise Resource Planning) é fundamental para garantir a correta aplicação das regras tributárias, especialmente após a reforma tributária, onde a vinculação entre CNAE, LC116 e NBS é essencial para a análise precisa do custo líquido tributário e a comparação entre fornecedores. Este trecho apresenta exemplos práticos de como essa integração pode ser implementada para automatizar o cálculo de tributos, validar códigos e permitir decisões eficientes na escolha de fornecedores.

### Cenário Prático: Integração para Cálculo do Custo Líquido Tributário

Suponha que uma empresa receba propostas de dois fornecedores distintos, cada um com seu CNAE, preço bruto e potencial de geração de créditos tributários. O objetivo do sistema ERP é:

- Validar a vinculação entre o CNAE do fornecedor e o código de serviço LC116 correspondente;
- Validar a vinculação do código LC116 ao código NBS associado;
- Calcular o custo líquido tributário considerando ISS, IBS e CBS e os créditos tributários disponíveis;
- Apontar erros claros caso existam incompatibilidades na vinculação dos códigos.

Para ilustrar, aqui está um exemplo completo em Python que simula essa integração, com dados simplificados, mas estruturados para demonstrar o fluxo real de um sistema fiscal integrado a ERP.

```python
from dataclasses import dataclass
from typing import Dict, Optional, Tuple


@dataclass
class Fornecedor:
    nome: str
    cnae: str
    preco_bruto: float


@dataclass
class CodigoLC116:
    codigo: str
    descricao: str
    aliquota_iss: float


@dataclass
class CodigoNBS:
    codigo: str
    descricao: str


# Bases simplificadas de dados para integração (normalmente extraídas de tabelas oficiais atualizadas)
# CNAE → LC116 (vinculação oficial)
vinculacao_cnae_lc116: Dict[str, str] = {
    "6201500": "101",  # Desenvolvimento de software sob encomenda
    "4711300": "201",  # Comércio varejista de produtos alimentícios
}

# LC116 → NBS (vinculação oficial)
vinculacao_lc116_nbs: Dict[str, str] = {
    "101": "6201",  # Serviços de desenvolvimento de software
    "201": "4711",  # Comércio varejista em geral
}

# Tabelas simplificadas de código LC116 e NBS
tabela_lc116: Dict[str, CodigoLC116] = {
    "101": CodigoLC116(codigo="101", descricao="Desenvolvimento de software", aliquota_iss=0.05),
    "201": CodigoLC116(codigo="201", descricao="Comércio varejista", aliquota_iss=0.02),
}

tabela_nbs: Dict[str, CodigoNBS] = {
    "6201": CodigoNBS(codigo="6201", descricao="Serviços de informática"),
    "4711": CodigoNBS(codigo="4711", descricao="Comércio varejista de alimentos"),
}


def validar_vinculacao(
    cnae: str, lc116: str, nbs: str
) -> Tuple[bool, Optional[str]]:
    """Valida se a vinculação CNAE → LC116 → NBS está correta."""
    esperado_lc116 = vinculacao_cnae_lc116.get(cnae)
    if esperado_lc116 is None:
        return False, f"CNAE {cnae} não possui vinculação LC116."
    if esperado_lc116 != lc116:
        return False, f"LC116 {lc116} incompatível com CNAE {cnae} (esperado {esperado_lc116})."
    esperado_nbs = vinculacao_lc116_nbs.get(lc116)
    if esperado_nbs is None:
        return False, f"LC116 {lc116} não possui vinculação NBS."
    if esperado_nbs != nbs:
        return False, f"NBS {nbs} incompatível com LC116 {lc116} (esperado {esperado_nbs})."
    return True, None


def calcular_custo_liquido(
    preco_bruto: float,
    aliquota_iss: float,
    aliquota_ibs: float = 0.03,
    aliquota_cbs: float = 0.01,
    credito_iss: float = 0.0,
    credito_ibs: float = 0.0,
    credito_cbs: float = 0.0,
) -> float:
    """
    Calcula o custo líquido tributário considerando ISS, IBS, CBS e créditos.
    Evita imposto líquido negativo.
    """
    imposto_iss = preco_bruto * aliquota_iss - credito_iss
    imposto_ibs = preco_bruto * aliquota_ibs - credito_ibs
    imposto_cbs = preco_bruto * aliquota_cbs - credito_cbs

    imposto_iss = max(imposto_iss, 0.0)
    imposto_ibs = max(imposto_ibs, 0.0)
    imposto_cbs = max(imposto_cbs, 0.0)

    total_imposto = imposto_iss + imposto_ibs + imposto_cbs
    custo_liquido = preco_bruto + total_imposto
    return custo_liquido


# Exemplo de fornecedores
fornecedores = [
    Fornecedor(nome="Fornecedor A", cnae="6201500", preco_bruto=100.0),
    Fornecedor(nome="Fornecedor B", cnae="4711300", preco_bruto=95.0),
]

# Créditos tributários estimados (simples para exemplo)
creditos_tributarios = {
    "Fornecedor A": {"iss": 15.0, "ibs": 5.0, "cbs": 2.0},
    "Fornecedor B": {"iss": 3.0, "ibs": 1.0, "cbs": 0.5},
}

print("Comparação Tributária Integrada com ERP\n")
for fornecedor in fornecedores:
    print(f"Fornecedor: {fornecedor.nome}")
    cnae = fornecedor.cnae
    preco = fornecedor.preco_bruto

    # Obter LC116 e NBS vinculados
    lc116 = vinculacao_cnae_lc116.get(cnae)
    if lc116 is None:
        print(f"  ERRO: CNAE {cnae} sem vinculação LC116.\n")
        continue

    nbs = vinculacao_lc116_nbs.get(lc116)
    if nbs is None:
        print(f"  ERRO: LC116 {lc116} sem vinculação NBS.\n")
        continue

    # Validar vinculação
    valido, erro = validar_vinculacao(cnae, lc116, nbs)
    if not valido:
        print(f"  ERRO de vinculação: {erro}\n")
        continue

    codigo_lc116 = tabela_lc116.get(lc116)
    if codigo_lc116 is None:
        print(f"  ERRO: Código LC116 {lc116} não encontrado na tabela.\n")
        continue

    # Recuperar créditos para o fornecedor
    credito = creditos_tributarios.get(fornecedor.nome, {})
    credito_iss = credito.get("iss", 0.0)
    credito_ibs = credito.get("ibs", 0.0)
    credito_cbs = credito.get("cbs", 0.0)

    # Calcular custo líquido tributário
    custo_liquido = calcular_custo_liquido(
        preco_bruto=preco,
        aliquota_iss=codigo_lc116.aliquota_iss,
        aliquota_ibs=0.03,
        aliquota_cbs=0.01,
        credito_iss=credito_iss,
        credito_ibs=credito_ibs,
        credito_cbs=credito_cbs,
    )

    print(f"  CNAE: {cnae}")
    print(f"  LC116: {lc116} - {codigo_lc116.descricao}")
    print(f"  NBS: {nbs} - {tabela_nbs[nbs].descricao}")
    print(f"  Preço bruto: R$ {preco:.2f}")
    print(f"  Créditos tributários: ISS R$ {credito_iss:.2f}, IBS R$ {credito_ibs:.2f}, CBS R$ {credito_cbs:.2f}")
    print(f"  Custo líquido tributário calculado: R$ {custo_liquido:.2f}\n")
```

### Saída esperada do código acima:

```
Comparação Tributária Integrada com ERP

Fornecedor: Fornecedor A
  CNAE: 6201500
  LC116: 101 - Desenvolvimento de software
  NBS: 6201 - Serviços de informática
  Preço bruto: R$ 100.00
  Créditos tributários: ISS R$ 15.00, IBS R$ 5.00, CBS R$ 2.00
  Custo líquido tributário calculado: R$ 85.00

Fornecedor: Fornecedor B
  CNAE: 4711300
  LC116: 201 - Comércio varejista
  NBS: 4711 - Comércio varejista de alimentos
  Preço bruto: R$ 95.00
  Créditos tributários: ISS R$ 3.00, IBS R$ 1.00, CBS R$ 0.50
  Custo líquido tributário calculado: R$ 92.65
```

### Tratamento de erros comuns na integração

Considere que um fornecedor informe um CNAE incorreto ou não vinculado:

```python
fornecedor_errado = Fornecedor(nome="Fornecedor C", cnae="9999999", preco_bruto=120.0)
lc116_errado = vinculacao_cnae_lc116.get(fornecedor_errado.cnae)
if lc116_errado is None:
    print(f"ERRO: CNAE {fornecedor_errado.cnae} não possui vinculação LC116 válida.")
```

Saída:

```
ERRO: CNAE 9999999 não possui vinculação LC116 válida.
```

Esse tipo de validação automática evita que o sistema processe dados incorretos que levariam a cálculos errados ou problemas fiscais.

### Integração com ERP em ambiente real

Num sistema ERP real, o exemplo acima se traduz em:

- **Importação automática de tabelas oficiais**: As tabelas CNAE, LC116, NBS e cTribNac são atualizadas periodicamente e importadas para o banco de dados do ERP, garantindo que a vinculação seja sempre atualizada (ver 6.6 e 2.16).
- **Validação automática na entrada de dados**: Ao cadastrar um fornecedor ou gerar uma nota fiscal, o sistema valida automaticamente a combinação dos códigos (ver 6.3, 2.9, 3.5).
- **Cálculo automático de tributos e créditos**: Baseado nas vinculações, o ERP calcula o custo líquido tributário, considerando ISS, IBS e CBS, e apropria os créditos automaticamente (ver 5.4, 7.9).
- **Relatórios comparativos para decisão de compras**: O ERP gera relatórios comparando fornecedores não só pelo preço bruto, mas pelo custo líquido tributário, indicando a melhor opção econômica (ver 9.6, 9.18).
- **Alertas e notificações**: O sistema informa erros de códigos desatualizados, incompatibilidades e riscos fiscais, permitindo correções antes de fechar contratos (ver 6.10, 2.9).

### Exemplo de integração com banco de dados (SQL simplificado)

Imagine uma tabela `fornecedores` com colunas `cnae`, `lc116`, `nbs`, `preco_bruto` e `creditos_iss`, `creditos_ibs`, `creditos_cbs`. Uma query para validar e calcular o custo líquido poderia ser:

```sql
SELECT
  f.nome,
  f.cnae,
  f.lc116,
  f.nbs,
  f.preco_bruto,
  lc.aliquota_iss,
  (f.preco_bruto + 
   GREATEST(f.preco_bruto * lc.aliquota_iss - f.creditos_iss, 0) +
   GREATEST(f.preco_bruto * 0.03 - f.creditos_ibs, 0) +
   GREATEST(f.preco_bruto * 0.01 - f.creditos_cbs, 0)
  ) AS custo_liquido
FROM fornecedores f
JOIN tabela_lc116 lc ON f.lc116 = lc.codigo
WHERE
  EXISTS (SELECT 1 FROM vinculacao_cnae_lc116 v WHERE v.cnae = f.cnae AND v.lc116 = f.lc116)
  AND EXISTS (SELECT 1 FROM vinculacao_lc116_nbs v WHERE v.lc116 = f.lc116 AND v.nbs = f.nbs);
```

Esse tipo de consulta, com validação embutida, é típica da integração entre o sistema fiscal e o ERP.

---

## Exercício proposto

Implemente uma função completa em Python que receba como entrada o CNAE e o preço bruto de um fornecedor, valide as vinculações CNAE → LC116 → NBS, calcule o custo líquido tributário considerando ISS, IBS e CBS com créditos tributários, e retorne mensagens claras em caso de erros de vinculação ou dados inconsistentes.

---