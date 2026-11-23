## Exemplo Prático: Comparação Entre Dois Fornecedores

Imagine que sua empresa precisa contratar um serviço de consultoria em TI e está analisando dois fornecedores diferentes. A decisão mais comum seria escolher aquele que oferece o menor preço. Contudo, como visto em 1.8, a contabilidade tributária pós-reforma exige que se considere também os créditos tributários que cada fornecedor gera, pois isso impacta diretamente no custo líquido final da contratação.

### Dados dos Fornecedores

| Fornecedor | Preço Bruto (R$) | CNAE          | Crédito Tributário (R$) |
|------------|------------------|---------------|-------------------------|
| A          | 100,00           | 62.01-5-01    | 15,00                   |
| B          | 95,00            | 62.01-5-01    | 5,00                    |

Ambos os fornecedores possuem o mesmo CNAE (62.01-5-01, que corresponde a “Desenvolvimento de programas de computador sob encomenda”), o que facilita a vinculação tributária conforme os processos detalhados em 2.9 e 3.12.

### Passo 1: Vinculação CNAE → LC116

Para cada CNAE, existe uma vinculação obrigatória a um código de serviço da LC116, que define a incidência do ISS e a possibilidade de crédito. No nosso exemplo, o CNAE 62.01-5-01 vincula-se ao código LC116 6201 (“Desenvolvimento de software personalizado”), conforme a tabela oficial e atualização de 2024 (3.10).

### Passo 2: Vinculação LC116 → NBS

O código LC116 6201 vincula-se ao código NBS 620100 (“Serviços de desenvolvimento de software”), que detalha a classificação para aplicação do ISS e a identificação dos créditos fiscais possíveis (4.11).

### Passo 3: Cálculo do Custo Líquido Tributário

O custo líquido tributário é calculado subtraindo-se o crédito tributário do preço bruto, conforme a regra simplificada já apresentada em 7.11 e 7.17:

\[
\text{Custo Líquido} = \text{Preço Bruto} - \text{Crédito Tributário}
\]

Aplicando aos fornecedores:

- Fornecedor A: \(100,00 - 15,00 = 85,00\)
- Fornecedor B: \(95,00 - 5,00 = 90,00\)

### Interpretação do Resultado

Embora o fornecedor B tenha o preço bruto menor (R$ 95,00), o fornecedor A gera um crédito tributário maior (R$ 15,00), o que reduz seu custo líquido para R$ 85,00. Portanto, o fornecedor A é a opção economicamente mais vantajosa.

### Código Python Completo para Cálculo e Comparação

```python
class Fornecedor:
    def __init__(self, nome, preco_bruto, cnae, credito_tributario):
        self.nome = nome
        self.preco_bruto = preco_bruto
        self.cnae = cnae
        self.credito_tributario = credito_tributario

    def custo_liquido(self):
        custo = self.preco_bruto - self.credito_tributario
        # Evita custo negativo, que não faz sentido prático
        return max(custo, 0.0)

# Dados dos fornecedores
fornecedor_a = Fornecedor("Fornecedor A", 100.00, "62.01-5-01", 15.00)
fornecedor_b = Fornecedor("Fornecedor B", 95.00, "62.01-5-01", 5.00)

# Cálculo dos custos líquidos
custo_a = fornecedor_a.custo_liquido()
custo_b = fornecedor_b.custo_liquido()

print(f"Custo líquido de {fornecedor_a.nome}: R$ {custo_a:.2f}")
print(f"Custo líquido de {fornecedor_b.nome}: R$ {custo_b:.2f}")

# Decisão baseada no custo líquido
if custo_a < custo_b:
    print(f"Melhor fornecedor: {fornecedor_a.nome}")
elif custo_b < custo_a:
    print(f"Melhor fornecedor: {fornecedor_b.nome}")
else:
    print("Ambos os fornecedores têm custo líquido igual.")
```

#### Saída do código:

```
Custo líquido de Fornecedor A: R$ 85.00
Custo líquido de Fornecedor B: R$ 90.00
Melhor fornecedor: Fornecedor A
```

### Erro Comum a Ser Evitado

Um erro comum é ignorar os créditos tributários e escolher apenas pelo preço bruto. Se ignorarmos o crédito do fornecedor A, a decisão seria incorreta:

```python
# Comparação incorreta sem considerar crédito tributário
if fornecedor_a.preco_bruto < fornecedor_b.preco_bruto:
    print("Melhor fornecedor (preço bruto):", fornecedor_a.nome)
else:
    print("Melhor fornecedor (preço bruto):", fornecedor_b.nome)
```

Saída incorreta:

```
Melhor fornecedor (preço bruto): Fornecedor B
```

Este erro pode gerar custos maiores para a empresa, conforme discutido em 1.8.

### Extensão: Validação da Vinculação dos Códigos

Para garantir que os créditos tributários podem ser realmente apropriados, é fundamental validar a vinculação correta entre o CNAE do fornecedor, o código LC116 e o código NBS (8.12). Se, por exemplo, o fornecedor A tivesse um CNAE que não vinculasse ao código LC116 usado para calcular o crédito, o crédito não seria válido, e o custo líquido ficaria incorreto.

### Exercício Proposto

Considere dois fornecedores com preços e créditos diferentes, porém com CNAEs distintos. Pesquise as vinculações CNAE → LC116 e LC116 → NBS correspondentes e calcule o custo líquido tributário para decidir qual fornecedor é a melhor opção econômica.

---