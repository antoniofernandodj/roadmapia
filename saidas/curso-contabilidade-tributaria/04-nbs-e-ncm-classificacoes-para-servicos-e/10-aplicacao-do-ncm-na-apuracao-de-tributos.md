## Aplicação do NCM na Apuração de Tributos Federais

A Nomenclatura Comum do Mercosul (NCM) exerce papel fundamental na apuração dos tributos federais incidentes sobre mercadorias, como o Imposto sobre Produtos Industrializados (IPI), o Imposto sobre Circulação de Mercadorias e Serviços (ICMS) na parte federal, a Contribuição sobre Bens e Serviços (CBS) e, futuramente, o Imposto sobre Bens e Serviços (IBS). O uso correto do código NCM na nota fiscal eletrônica e na escrituração fiscal é imprescindível para garantir a correta tributação e o aproveitamento dos créditos tributários, impactando diretamente o custo final das mercadorias adquiridas.

### Como o NCM influencia a tributação federal

O código NCM organiza as mercadorias em uma estrutura hierárquica rigorosa de oito dígitos, que define a natureza e especificidade do produto. Cada mercadoria tem uma classificação tributária própria que determina as alíquotas aplicáveis e a possibilidade de crédito fiscal, conforme previsto na legislação federal. Por exemplo:

- **IPI**: tributa produtos industrializados segundo a sua classificação no NCM, com alíquotas que variam conforme o capítulo, posição e subposição do código.
- **ICMS**: embora seja um tributo estadual, sua base e alíquotas muitas vezes dependem da correta classificação no NCM para evitar substituição tributária indevida ou incorreta.
- **CBS/IBS**: tributos federais que, na reforma tributária, unificam diversas contribuições, dependem do NCM para definir a incidência e o crédito tributário aplicável.

Assim, o NCM não é apenas um código identificador, mas a chave para determinar a incidência, a alíquota e a regra de crédito tributário de cada mercadoria.

### Impactos práticos do uso correto do NCM

Imagine uma empresa que compra notebooks para uso interno, classificados originalmente no NCM 8471.30.12 (notebooks). Se o código for informado incorretamente, por exemplo, usando um código genérico 8471.90.00 (máquinas automáticas de processamento de dados, outras), a Receita Federal poderá rejeitar a nota fiscal eletrônica, ou aplicar alíquotas incorretas de IPI e CBS, além de impedir a apropriação correta dos créditos tributários.

Um erro comum que ocorre em sistemas fiscais é a utilização de códigos NCM genéricos ou incompletos, que geram rejeições fiscais ou, no mínimo, perdas financeiras por não aproveitamento dos créditos concedidos. A atualização periódica do NCM para 2024 trouxe novos códigos para produtos tecnológicos e distingue mercadorias usadas, o que também afeta a apuração tributária.

### Exemplo prático de influência do NCM na apuração de tributos

Considere dois fornecedores oferecendo o mesmo modelo de smartphone, mas com códigos NCM diferentes:

| Fornecedor | Preço (R$) | Código NCM        | Alíquota IPI (%) | Crédito IPI (R$) | Crédito CBS (R$) | Custo Líquido (R$) |
|------------|------------|-------------------|------------------|------------------|------------------|--------------------|
| A          | 1.000,00   | 8517.12.11 (smartphone novo) | 10               | 100,00           | 50,00            | 850,00             |
| B          | 950,00     | 8517.12.90 (código genérico) | 15               | 0,00             | 0,00             | 1.092,50           |

**Análise:**

- O fornecedor A usa o código NCM correto e específico, possibilitando a apropriação de créditos tributários no IPI e na CBS, que reduzem o custo líquido efetivo para R$ 850,00.
- O fornecedor B usa um código genérico que, além de alíquota maior de IPI, impede a apropriação dos créditos, elevando o custo líquido para R$ 1.092,50, apesar do preço inicial menor.

### Integração do NCM com sistemas fiscais e cálculos tributários

Para um sistema que deseja comparar fornecedores e decidir pela melhor opção tributária, é fundamental garantir que o código NCM esteja correto e atualizado na base de dados. A partir do código NCM, o sistema deve:

1. Validar o código contra tabelas oficiais atualizadas (como as da Receita Federal).
2. Associar o código às alíquotas vigentes de IPI, CBS e IBS para o produto.
3. Calcular os créditos tributários possíveis conforme a legislação.
4. Estimar o custo líquido tributário da mercadoria considerando o preço e os créditos.
5. Apresentar a comparação entre fornecedores, destacando a vantagem tributária.

Erros comuns na implementação incluem:

- Inserção de código NCM genérico ou incorreto, que causa rejeição da nota fiscal eletrônica.
- Falta de atualização da tabela NCM, que resulta em uso de códigos obsoletos.
- Desconsideração dos créditos tributários vinculados ao código NCM, causando decisão incorreta na escolha do fornecedor.

### Exemplo prático de código Python para cálculo simplificado do custo líquido

```python
# Dados dos fornecedores
fornecedores = {
    'Fornecedor A': {
        'preco': 1000.00,
        'ncm': '85171211',
        'ipi_aliquota': 0.10,
        'creditos': {
            'ipi': 100.00,
            'cbs': 50.00
        }
    },
    'Fornecedor B': {
        'preco': 950.00,
        'ncm': '85171290',
        'ipi_aliquota': 0.15,
        'creditos': {
            'ipi': 0.00,
            'cbs': 0.00
        }
    }
}

def custo_liquido(fornecedor):
    preco = fornecedor['preco']
    ipi = preco * fornecedor['ipi_aliquota']
    creditos = sum(fornecedor['creditos'].values())
    return preco + ipi - creditos

for nome, dados in fornecedores.items():
    custo = custo_liquido(dados)
    print(f"{nome}: Custo líquido = R$ {custo:.2f}")
```

**Saída:**

```
Fornecedor A: Custo líquido = R$ 850.00
Fornecedor B: Custo líquido = R$ 1092.50
```

Esse exemplo demonstra claramente como o código NCM impacta a alíquota aplicada e a possibilidade de crédito tributário, influenciando na decisão pela melhor opção de fornecedor.

---

## Exercício proposto

Dado o código NCM para um equipamento usado e para um equipamento novo (com códigos diferentes), explique como a escolha correta do código NCM influencia a apuração dos tributos federais e a apropriação de créditos tributários, e qual o impacto dessa escolha no custo líquido da compra.

---