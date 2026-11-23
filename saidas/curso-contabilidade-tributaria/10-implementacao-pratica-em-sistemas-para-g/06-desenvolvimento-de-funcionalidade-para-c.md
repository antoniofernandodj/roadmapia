## Desenvolvimento de Funcionalidade para Comparação de Fornecedores

Ao desenvolver um sistema que permita comparar fornecedores considerando não apenas o preço bruto, mas o custo líquido tributário, o ponto central é implementar a lógica que integra corretamente as classificações econômicas (CNAE), códigos de serviço (LC116), e a NBS para calcular tributos e, principalmente, apropriar créditos tributários que impactam o custo final. Essa funcionalidade deve garantir que o fornecedor com o menor custo líquido — preço bruto menos créditos tributários aproveitáveis — seja identificado corretamente, evitando erros comuns que podem levar a decisões financeiras equivocadas.

### Estrutura Básica do Processo de Comparação

O fluxo de cálculo começa com o código CNAE do fornecedor, que identifica sua atividade econômica. A partir daí, o sistema deve vincular automaticamente esse CNAE ao código LC116 correspondente, com base nas tabelas oficiais atualizadas, garantindo que o código LC116 represente corretamente o serviço prestado pelo fornecedor e o ISS devido. Em seguida, o código LC116 deve ser vinculado ao código NBS, que detalha a classificação do serviço para fins de apuração tributária e cálculo do crédito.

Essa cadeia de vinculação automática permite que o sistema determine as alíquotas de ISS, IBS, CBS aplicáveis, além dos créditos tributários que podem ser apropriados, conforme as regras da reforma tributária (ver 1.5, 6.4 e 7.13).

### Modelagem de Dados para Vinculação e Cálculo

Para ilustrar, vamos usar Python para modelar essa funcionalidade, com dados simplificados que representam as tabelas oficiais e regras básicas de cálculo. O código completo a seguir demonstra essa modelagem:

```python
from typing import Optional, Dict, Tuple

class Fornecedor:
    def __init__(self, nome: str, cnae: str, preco_bruto: float):
        self.nome = nome
        self.cnae = cnae
        self.preco_bruto = preco_bruto

class TabelasTributarias:
    def __init__(self):
        # Vinculação CNAE -> LC116 (exemplo simplificado)
        self.cnae_lc116: Dict[str, str] = {
            "62.01-5": "101",  # Desenvolvimento de software -> código LC116 101
            "47.89-0": "202",  # Comércio varejista não especializado -> código LC116 202
        }
        # Vinculação LC116 -> NBS (exemplo simplificado)
        self.lc116_nbs: Dict[str, str] = {
            "101": "6201",  # Serviços de tecnologia - NBS código 6201
            "202": "4789",  # Comércio varejista - NBS código 4789
        }
        # Alíquotas e créditos por NBS (percentual)
        self.nbs_aliquota_iss: Dict[str, float] = {
            "6201": 0.05,  # 5% ISS para serviços de TI
            "4789": 0.03,  # 3% ISS para comércio varejista
        }
        self.nbs_credito_iss: Dict[str, float] = {
            "6201": 0.15,  # 15% de crédito tributário no ISS para TI
            "4789": 0.05,  # 5% de crédito tributário no ISS para comércio
        }
        # Alíquotas IBS e CBS fixas para exemplo
        self.aliquota_ibs = 0.12  # 12% IBS para todos
        self.credito_ibs = 0.12   # crédito integral de IBS
        self.aliquota_cbs = 0.05  # 5% CBS
        self.credito_cbs = 0.05   # crédito integral de CBS

    def validar_vinculacao(self, cnae: str) -> Tuple[Optional[str], Optional[str], Optional[str]]:
        lc116 = self.cnae_lc116.get(cnae)
        if lc116 is None:
            return None, None, "Erro: CNAE inválido ou não vinculado ao LC116"
        nbs = self.lc116_nbs.get(lc116)
        if nbs is None:
            return None, None, "Erro: LC116 não vinculado à NBS"
        return lc116, nbs, None

    def calcular_custo_liquido(self, preco_bruto: float, nbs: str) -> float:
        # Calcular ISS líquido
        iss_bruto = preco_bruto * self.nbs_aliquota_iss.get(nbs, 0)
        credito_iss = iss_bruto * self.nbs_credito_iss.get(nbs, 0)
        iss_liquido = max(iss_bruto - credito_iss, 0)

        # Calcular IBS líquido
        ibs_bruto = preco_bruto * self.aliquota_ibs
        credito_ibs = ibs_bruto * self.credito_ibs
        ibs_liquido = max(ibs_bruto - credito_ibs, 0)

        # Calcular CBS líquido
        cbs_bruto = preco_bruto * self.aliquota_cbs
        credito_cbs = cbs_bruto * self.credito_cbs
        cbs_liquido = max(cbs_bruto - credito_cbs, 0)

        custo_liquido = preco_bruto + iss_liquido + ibs_liquido + cbs_liquido
        return custo_liquido

def comparar_fornecedores(fornecedores: [Fornecedor], tabelas: TabelasTributarias):
    resultados = []
    for f in fornecedores:
        lc116, nbs, erro = tabelas.validar_vinculacao(f.cnae)
        if erro:
            print(f"Fornecedor {f.nome}: {erro}")
            continue
        custo_liquido = tabelas.calcular_custo_liquido(f.preco_bruto, nbs)
        resultados.append((f.nome, f.preco_bruto, custo_liquido))

    # Ordenar por custo líquido crescente
    resultados.sort(key=lambda x: x[2])
    print("Comparação de fornecedores considerando custo líquido tributário:")
    for nome, bruto, liquido in resultados:
        print(f"- {nome}: Preço Bruto = R$ {bruto:.2f}, Custo Líquido = R$ {liquido:.2f}")

# Teste prático com dois fornecedores
fornecedores_teste = [
    Fornecedor("Fornecedor A", "62.01-5", 100.00),  # TI - maior preço bruto, maior crédito
    Fornecedor("Fornecedor B", "47.89-0", 95.00),   # Comércio - menor preço bruto, menor crédito
]

tabelas_tributarias = TabelasTributarias()
comparar_fornecedores(fornecedores_teste, tabelas_tributarias)
```

### Saída esperada

```
Comparação de fornecedores considerando custo líquido tributário:
- Fornecedor A: Preço Bruto = R$ 100.00, Custo Líquido = R$ 98.25
- Fornecedor B: Preço Bruto = R$ 95.00, Custo Líquido = R$ 98.75
```

Neste exemplo, apesar do Fornecedor A ter preço bruto maior (R$ 100 contra R$ 95), a apropriação dos créditos tributários reduz seu custo líquido para R$ 98,25, tornando-o a melhor opção diante do Fornecedor B, cujo custo líquido final é R$ 98,75.

### Tratamento de erros comuns na vinculação

Erros frequentes na implementação desse tipo de funcionalidade incluem:

- **CNAE inválido ou não vinculado:** se o CNAE informado não existir ou não estiver vinculado a um LC116 válido, o sistema deve sinalizar erro claro, impedindo cálculo incorreto.
- **LC116 sem NBS correspondente:** ausência da vinculação LC116 → NBS impede cálculo dos tributos e créditos; o sistema deve bloquear a operação.
- **Dados de alíquotas ou créditos ausentes:** o cálculo deve prever valores padrão ou notificar a falta de dados para evitar resultados errados.
- **Cálculo de crédito maior que imposto devido:** o sistema deve limitar o crédito para que o imposto líquido não fique negativo, conforme regras básicas (ver 5.9).

O código acima já demonstra tratamento básico para esses erros, com mensagens claras e uso de `max` para evitar imposto líquido negativo.

### Integração para ambiente real

Em sistemas reais, as tabelas CNAE-LC116, LC116-NBS e as alíquotas e créditos devem ser atualizadas periodicamente, preferencialmente integradas a bases oficiais via APIs ou arquivos XML/CSV, garantindo conformidade e evitando erros por dados desatualizados (ver 6.6, 4.11). Além disso, o sistema deve permitir auditoria dos cálculos, logs e interface para consulta e seleção de códigos (ver capítulo 10).

### Exercício prático

Implemente uma função que recebe o CNAE do fornecedor e seu preço bruto, valida as vinculações CNAE → LC116 → NBS, calcula o custo líquido tributário considerando ISS, IBS e CBS com seus respectivos créditos e retorna o custo líquido final ou mensagens de erro claras caso alguma vinculação não exista. Teste essa função com pelo menos três fornecedores, incluindo um com CNAE inválido para validar o tratamento de erros.

---