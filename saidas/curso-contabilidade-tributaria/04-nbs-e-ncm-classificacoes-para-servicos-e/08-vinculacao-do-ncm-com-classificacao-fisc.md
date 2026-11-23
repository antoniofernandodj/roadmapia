## Vinculação do NCM com Classificação Fiscal e Tributária

A Nomenclatura Comum do Mercosul (NCM) é o principal código utilizado para a classificação fiscal de mercadorias no Brasil, integrando a sistemática tributária nacional para impostos federais e estaduais como IPI, ICMS, IBS e CBS. A correta vinculação do NCM com a classificação fiscal e tributária é essencial para que os tributos incidentes sejam calculados adequadamente, evitando erros na emissão de documentos fiscais, rejeições pela Receita Federal e perdas financeiras decorrentes da não apropriação de créditos tributários.

### Por que a Vinculação do NCM é Crucial?

Imagine uma empresa que compra um notebook para uso interno. Se o código NCM informado na nota fiscal for genérico ou incorreto, a mercadoria poderá ser tributada com alíquota errada de IPI ou ICMS, além de impedir a apropriação correta dos créditos fiscais correspondentes. Isso impacta diretamente o custo líquido da compra, podendo tornar a operação mais cara do que o previsto, mesmo que o preço bruto do fornecedor seja menor.

A vinculação correta do NCM com a classificação fiscal ocorre porque cada código NCM possui uma descrição detalhada, associada a códigos fiscais específicos que determinam a alíquota aplicável, a possibilidade de crédito e a incidência de tributos. Esta associação é atualizada periodicamente para acompanhar mudanças na legislação e na composição do mercado, principalmente após a reforma tributária que alterou a forma de apuração e integração de tributos.

### Como o NCM se Vincula à Classificação Fiscal?

A estrutura do NCM, com seus 8 dígitos organizados hierarquicamente (capítulo, posição, subposição e código completo), permite granularidade suficiente para distinguir mercadorias similares, mas com tratamentos tributários diferentes. Por exemplo:

- Um notebook novo pode ter um código NCM específico com alíquota de IPI reduzida e crédito de ICMS integral.
- Um notebook usado, ainda que da mesma categoria, terá um código NCM distinto, com tratamento tributário diferente, possivelmente sem direito a crédito de ICMS.

Essa distinção é fundamental para a contabilidade tributária. A tabela oficial da Receita Federal e dos Estados relaciona cada NCM a códigos fiscais de tributação (códigos CFOP, CST, código de tributação cTribNac, entre outros), que determinam:

- Se o produto está sujeito a IPI e qual alíquota.
- Qual é a base de cálculo e alíquota do ICMS.
- Se a operação gera direito a crédito tributário.
- Qual é o tratamento no IBS e CBS, conforme a reforma.

### Exemplo Prático: Impacto do Código NCM na Tributação e Crédito

Suponha que uma empresa adquira dois equipamentos eletrônicos parecidos, mas com códigos NCM diferentes:

| Produto           | Código NCM    | Alíquota IPI | Alíquota ICMS | Crédito ICMS | Crédito IBS/CBS |
|-------------------|--------------|--------------|---------------|--------------|-----------------|
| Notebook novo     | 8471.30.12   | 0%           | 18%           | Sim          | Sim             |
| Notebook usado    | 8471.50.10   | Isento       | 18%           | Não          | Parcial         |

Neste exemplo, a compra do notebook novo permite a apropriação integral dos créditos de ICMS e IBS/CBS, reduzindo o custo tributário efetivo da empresa. Já o notebook usado, apesar de ter alíquota semelhante de ICMS, não gera crédito de ICMS e tem crédito parcial nos tributos IBS/CBS.

Se a empresa informar incorretamente o código NCM do notebook usado como se fosse o do novo, além de risco de autuação fiscal por divergência, perderá a oportunidade de calcular corretamente o custo líquido e os créditos, prejudicando a comparação entre fornecedores e a decisão de compra.

### Erro Comum e Mensagem Fiscal

Um erro frequente é utilizar um código NCM genérico ou incompleto na nota fiscal eletrônica (NF-e). O sistema da Receita Federal rejeita a nota com mensagens do tipo:

```
Rejeição: Código NCM inválido ou incompatível com a descrição do produto (cStat 204)
```

Outro problema comum é informar o código correto, mas sem vincular ao código de tributação correto, o que gera inconsistências na apuração e pode causar divergência nas declarações fiscais.

### Como Evitar Erros na Vinculação do NCM?

1. **Atualização constante das tabelas**: A NCM é atualizada anualmente. Sistemas fiscais devem incorporar as versões vigentes para evitar rejeições.
2. **Consulta cruzada com códigos fiscais**: O código NCM deve estar vinculado ao código de tributação (cTribNac) correto para IPI, ICMS, IBS e CBS.
3. **Validação automática**: Sistemas devem validar se o código NCM informado corresponde à descrição do item e à operação fiscal realizada.
4. **Treinamento e uso de tabelas oficiais**: Profissionais devem conhecer a estrutura do NCM e as regras fiscais associadas para classificar corretamente mercadorias.

### Vinculação Prática para Sistemas de Comparação de Fornecedores

No desenvolvimento de sistemas para suporte à decisão de compra que consideram créditos tributários, a vinculação do NCM é parte fundamental do cálculo do custo líquido tributário. O fluxo básico para tal sistema deve contemplar:

- Entrada do código NCM da mercadoria fornecida.
- Consulta automática das alíquotas e créditos permitidos para o NCM.
- Cálculo do imposto devido e do crédito tributário a ser apropriado.
- Ajuste do preço bruto do fornecedor pelo valor do crédito para comparação efetiva.

Assim, o sistema pode indicar que um fornecedor com preço nominal maior pode ser mais vantajoso, por oferecer mercadoria com código NCM que gera créditos tributários maiores, reduzindo o custo líquido.

### Exemplo de Código e Saída para Validação Simples de NCM em Python

```python
# Simulação simplificada de validação e cálculo tributário usando NCM

# Tabela fictícia de NCM e seus tributos
ncm_tributos = {
    "84713012": {"ipi": 0.0, "icms": 0.18, "credito_icms": True, "credito_ibs": True},
    "84715010": {"ipi": 0.0, "icms": 0.18, "credito_icms": False, "credito_ibs": 0.5},
}

def calcular_custo_liquido(preco_bruto, ncm):
    tributos = ncm_tributos.get(ncm)
    if not tributos:
        raise ValueError(f"Código NCM {ncm} inválido ou não cadastrado.")
    
    # Suponha que o crédito é igual ao imposto ICMS sobre o preço bruto, se permitido
    credito_icms = preco_bruto * tributos["icms"] if tributos["credito_icms"] else 0
    # Crédito IBS parcial ou total
    credito_ibs = preco_bruto * tributos["icms"] * tributos["credito_ibs"] if tributos["credito_ibs"] else 0

    credito_total = credito_icms + credito_ibs
    custo_liquido = preco_bruto - credito_total
    return custo_liquido, credito_total

# Teste prático
for fornecedor, dados in [("Fornecedor A", {"preco": 100.0, "ncm": "84713012"}),
                         ("Fornecedor B", {"preco": 95.0, "ncm": "84715010"})]:
    try:
        custo, credito = calcular_custo_liquido(dados["preco"], dados["ncm"])
        print(f"{fornecedor}: Preço bruto R$ {dados['preco']:.2f}, Crédito R$ {credito:.2f}, Custo líquido R$ {custo:.2f}")
    except ValueError as e:
        print(f"Erro para {fornecedor}: {e}")
```

Saída esperada:

```
Fornecedor A: Preço bruto R$ 100.00, Crédito R$ 36.00, Custo líquido R$ 64.00
Fornecedor B: Preço bruto R$ 95.00, Crédito R$ 8.55, Custo líquido R$ 86.45
```

Neste exemplo, mesmo com preço bruto maior, o Fornecedor A oferece melhor custo líquido devido ao maior crédito tributário gerado pelo NCM correto.

---

### Exercício proposto

Dado um produto com código NCM 84713012 e outro com código 84715010, calcule o custo líquido para uma compra de R$ 1.000,00 em cada um, considerando que o primeiro gera crédito integral de ICMS e IBS, e o segundo gera crédito parcial de IBS e nenhum crédito de ICMS. Explique como isso impacta a decisão de compra entre os dois fornecedores.

---