## Métodos Simples para Comparação de Preços com Créditos

Na prática da análise tributária para escolha de fornecedores, o desafio maior é ir além da comparação do preço bruto apresentado na proposta ou na nota fiscal. Afinal, o preço líquido efetivo — aquele que incorpora o impacto dos tributos pagos e dos créditos tributários aproveitados — é que determina o custo real para a empresa. Um método simplificado, porém eficaz, para realizar essa comparação envolve basicamente três passos:

1. **Identificação do CNAE do fornecedor**: O CNAE define a atividade econômica principal do fornecedor e, como já visto (2.1 a 2.15), é a base para vincular corretamente os códigos tributários, principalmente o código de serviço LC116.
2. **Vinculação do CNAE ao código LC116 correspondente**: A partir do CNAE, associa-se o código de serviço LC116 que descreve o serviço tributado pelo ISS, definindo alíquota, base de cálculo e possibilidade de crédito (3.1 a 3.15).
3. **Vinculação do código LC116 ao código NBS**: O NBS detalha a classificação do serviço para fins de tributação e permite a correta identificação dos créditos tributários gerados e a aplicação das regras do ISS, IBS e CBS (4.1 a 4.14).

Com essas vinculações, é possível calcular o custo tributário líquido de cada fornecedor, que é o preço bruto menos os créditos tributários apropriáveis. A fórmula básica para comparação é:

\[
\text{Custo Líquido} = \text{Preço Bruto} - \text{Crédito Tributário}
\]

### Exemplo prático básico

Duas cotações para o mesmo serviço:

| Fornecedor | Preço Bruto (R$) | Crédito Tributário (R$) | Custo Líquido (R$) |
|------------|------------------|------------------------|--------------------|
| A          | 100,00           | 15,00                  | 85,00              |
| B          | 95,00            | 0,00                   | 95,00              |

À primeira vista, o fornecedor B tem o menor preço. Mas, ao considerar os créditos tributários, o custo líquido do fornecedor A é inferior, tornando-o a opção economicamente mais vantajosa.

### Construindo um cálculo simples em Python

Vamos implementar um código completo e funcional para comparar fornecedores considerando preço e crédito tributário. Esse código pode ser usado para automatizar a comparação em sistemas fiscais.

```python
class Fornecedor:
    def __init__(self, nome, preco_bruto, credito_tributario):
        self.nome = nome
        self.preco_bruto = preco_bruto
        self.credito_tributario = credito_tributario

    def custo_liquido(self):
        custo = self.preco_bruto - self.credito_tributario
        # Evita custo líquido negativo, que é incorreto na prática fiscal
        return custo if custo > 0 else 0

def comparar_fornecedores(fornecedores):
    print(f"{'Fornecedor':<12} {'Preço Bruto':>12} {'Crédito':>10} {'Custo Líquido':>15}")
    for f in fornecedores:
        print(f"{f.nome:<12} {f.preco_bruto:12.2f} {f.credito_tributario:10.2f} {f.custo_liquido():15.2f}")

    melhor = min(fornecedores, key=lambda x: x.custo_liquido())
    print(f"\nMelhor opção: {melhor.nome} com custo líquido de R$ {melhor.custo_liquido():.2f}")

# Dados dos fornecedores (exemplo realista)
fornecedor_a = Fornecedor("Fornecedor A", 100.00, 15.00)
fornecedor_b = Fornecedor("Fornecedor B", 95.00, 0.00)

comparar_fornecedores([fornecedor_a, fornecedor_b])
```

A saída será:

```
Fornecedor    Preço Bruto    Crédito   Custo Líquido
Fornecedor A       100.00      15.00           85.00
Fornecedor B        95.00       0.00           95.00

Melhor opção: Fornecedor A com custo líquido de R$ 85.00
```

### Erro comum: ignorar créditos tributários

Um erro frequente é comparar apenas os preços brutos, ignorando os créditos tributários, o que pode levar a decisões ruins. Por exemplo, se o código acima fosse alterado para considerar apenas o preço bruto:

```python
melhor = min(fornecedores, key=lambda x: x.preco_bruto)
```

A saída seria:

```
Melhor opção: Fornecedor B com custo líquido de R$ 95.00
```

Essa decisão desconsidera a redução real do custo via créditos, prejudicando a empresa financeiramente.

### Como incorporar as vinculações CNAE → LC116 → NBS neste método?

No cálculo simplificado acima, o valor do crédito tributário já deve estar previamente identificado com base na correta vinculação entre o CNAE, o código de serviço LC116 e o código NBS. Essas vinculações garantem:

- Identificação precisa da atividade tributada pelo fornecedor.
- Apuração correta da alíquota e base de cálculo do ISS, IBS ou CBS.
- Reconhecimento legítimo do crédito tributário gerado pela operação.

Na prática, um sistema automatizado pode consultar bases oficiais (ver 6.6 e 2.8) para obter essas vinculações e os parâmetros tributários, retornando o valor do crédito que alimenta o cálculo do custo líquido.

### Método simplificado para uso prático

1. **Obtenha o CNAE do fornecedor** (consultar cadastro oficial).
2. **Obtenha o código LC116 vinculado ao CNAE** (base oficial ou tabela interna).
3. **Obtenha o código NBS vinculado ao LC116**.
4. **Calcule os tributos incidentes (ISS, IBS, CBS) usando as alíquotas e bases de cálculo associadas**.
5. **Calcule os créditos tributários possíveis para o fornecedor** (de acordo com a legislação específica e o regime tributário).
6. **Calcule o custo líquido: preço bruto menos créditos apropriáveis**.
7. **Compare os custos líquidos dos fornecedores para decisão final**.

Esse processo, ainda que simplificado, é a base para decisões econômicas mais inteligentes e alinhadas à legislação pós-reforma.

---

### Exercício

Considere dois fornecedores de serviços com os seguintes dados:

- Fornecedor X: preço bruto R$ 120,00, CNAE 6201-5/01, crédito tributário estimado R$ 20,00.
- Fornecedor Y: preço bruto R$ 110,00, CNAE 6202-3/00, crédito tributário estimado R$ 5,00.

Calcule o custo líquido para cada fornecedor e determine qual deles oferece a melhor proposta econômica considerando o impacto dos créditos tributários.

---