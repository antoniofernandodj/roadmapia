## Base de Cálculo do ISS

Determinar corretamente a base de cálculo do ISS (Imposto Sobre Serviços) é fundamental para apurar o tributo devido e, consequentemente, para análise da carga tributária na comparação entre fornecedores. A base de cálculo do ISS corresponde ao valor sobre o qual a alíquota do imposto incide, ou seja, o montante financeiro que será tributado. Erros comuns na definição dessa base levam a cálculos incorretos do imposto e podem afetar decisões gerenciais e fiscais.

### O que compõe a base de cálculo do ISS?

Por definição legal e como visto em 3.1, a base de cálculo do ISS é o preço do serviço prestado, ou seja, o montante total cobrado pelo fornecedor pelo serviço tributado. No entanto, o que parece simples tem seus detalhes práticos cruciais:

- **Valor do serviço:** O valor bruto que o prestador cobra pelo serviço efetivamente realizado.
- **Inclusão de encargos acessórias:** Custos adicionais que estejam embutidos no preço do serviço, como despesas de deslocamento, materiais fornecidos pelo prestador (quando incluídos no preço do serviço), ou outras despesas acessórias, desde que não estejam sujeitas a outras tributação específicas.
- **Exclusão de descontos condicionais:** Descontos concedidos que dependem de condições futuras (como pagamento antecipado) geralmente não integram a base, desde que registrados corretamente.
- **Impostos destacados:** Impostos federais, estaduais ou municipais que incidem sobre o serviço, mas que sejam destacados na nota fiscal e recolhidos separadamente, não entram na base de cálculo do ISS para evitar bitributação.

### Como a legislação da LC 116 e a vinculação CNAE x LC116 x NBS impactam a base de cálculo?

A base de cálculo está ligada diretamente à correta identificação do serviço, que depende da vinculação do CNAE do fornecedor ao código de serviço da LC116 e à classificação NBS, conforme explicado em 3.4 e 8.3. Essa identificação correta garante que o valor considerado para o ISS seja o apropriado para o serviço efetivamente tributado, evitando erros como:

- Utilizar base de cálculo para serviço não tributado pelo ISS, gerando recolhimento indevido.
- Não considerar variações permitidas na base para serviços específicos listados na LC116, como exclusões parciais ou ajustes previstos em lei.

### Exemplos práticos: cálculo da base de cálculo do ISS

Considere três fornecedores prestando o mesmo serviço, com valores diferentes e características que alteram a base de cálculo:

| Fornecedor | Valor Bruto do Serviço | Desconto Condicional | Encargos Inclusos | Impostos Destacados |
|------------|-----------------------|---------------------|-------------------|---------------------|
| A          | R$ 1.000,00           | R$ 50,00            | R$ 100,00         | R$ 80,00            |
| B          | R$ 950,00             | R$ 0,00             | R$ 0,00           | R$ 0,00             |
| C          | R$ 1.050,00           | R$ 100,00           | R$ 50,00          | R$ 100,00           |

**Cálculo da base de cálculo do ISS para cada fornecedor:**

- **Fornecedor A:**

  - Valor bruto: 1.000,00
  - Desconto condicional: 50,00 (excluído da base)
  - Encargos inclusos: 100,00 (somados à base)
  - Impostos destacados: 80,00 (excluídos da base)

  Portanto, base de cálculo = (1.000,00 - 50,00) + 100,00 - 80,00  
  Base de cálculo = 950,00 + 100,00 - 80,00 = R$ 970,00

- **Fornecedor B:**

  - Valor bruto: 950,00
  - Sem descontos, encargos ou impostos destacados

  Base de cálculo = R$ 950,00

- **Fornecedor C:**

  - Valor bruto: 1.050,00
  - Desconto condicional: 100,00 (excluído)
  - Encargos inclusos: 50,00 (somados)
  - Impostos destacados: 100,00 (excluídos)

  Base de cálculo = (1.050,00 - 100,00) + 50,00 - 100,00  
  Base de cálculo = 950,00 + 50,00 - 100,00 = R$ 900,00

### Erro comum na apuração da base de cálculo do ISS

Um erro muito frequente é considerar como base de cálculo o valor total da nota fiscal, incluindo impostos destacados e sem realizar os ajustes de descontos condicionais e encargos. Por exemplo, usar simplesmente R$ 1.000,00 no Fornecedor A, ignorando os descontos e impostos destacados, resulta em base de cálculo incorreta, e portanto, imposto superestimado.

Esse erro pode causar problemas fiscais e de análise incorreta do custo tributário, levando a decisões financeiras erradas, como rejeitar um fornecedor mais vantajoso.

### Como programar a apuração da base de cálculo do ISS em sistema fiscal?

A regra de cálculo da base segue esses passos:

1. Receber o valor bruto do serviço.
2. Subtrair descontos condicionais devidamente registrados.
3. Somar encargos acessórios incluídos no valor do serviço.
4. Subtrair impostos destacados que não compõem a base do ISS.

A seguir, um código Python completo que calcula a base de cálculo do ISS para qualquer fornecedor, retornando um erro caso algum dado esteja inconsistente (por exemplo, valores negativos):

```python
def calcular_base_iss(valor_bruto, desconto_condicional=0.0, encargos=0.0, impostos_destacados=0.0):
    """
    Calcula a base de cálculo do ISS conforme regras da LC116 e prática contábil.

    Parâmetros:
    valor_bruto (float): valor total cobrado pelo serviço.
    desconto_condicional (float): descontos condicionais a serem excluídos da base.
    encargos (float): encargos acessórios incluídos na base.
    impostos_destacados (float): impostos destacados que não compõem a base.

    Retorna:
    float: base de cálculo apurada.
    """

    # Validação dos valores de entrada
    valores = [valor_bruto, desconto_condicional, encargos, impostos_destacados]
    if any(v < 0 for v in valores):
        raise ValueError("Nenhum valor pode ser negativo.")

    base = (valor_bruto - desconto_condicional) + encargos - impostos_destacados

    if base < 0:
        raise ValueError("Base de cálculo não pode ser negativa. Verifique os valores informados.")

    return base

# Teste prático com os fornecedores A, B e C
fornecedores = {
    "Fornecedor A": {"valor_bruto": 1000.0, "desconto_condicional": 50.0, "encargos": 100.0, "impostos_destacados": 80.0},
    "Fornecedor B": {"valor_bruto": 950.0, "desconto_condicional": 0.0, "encargos": 0.0, "impostos_destacados": 0.0},
    "Fornecedor C": {"valor_bruto": 1050.0, "desconto_condicional": 100.0, "encargos": 50.0, "impostos_destacados": 100.0},
}

for nome, dados in fornecedores.items():
    base = calcular_base_iss(**dados)
    print(f"{nome}: Base de Cálculo do ISS = R$ {base:.2f}")
```

Saída do código:

```
Fornecedor A: Base de Cálculo do ISS = R$ 970.00
Fornecedor B: Base de Cálculo do ISS = R$ 950.00
Fornecedor C: Base de Cálculo do ISS = R$ 900.00
```

### Como usar essa base para o cálculo do ISS

Depois de apurada a base de cálculo, aplica-se a alíquota do ISS conforme legislação municipal (geralmente entre 2% e 5%), obtendo-se o valor do imposto devido. Esse cálculo será abordado no próximo capítulo.

### Exercício prático

Dado o valor bruto do serviço, o desconto condicional, encargos acessórios e impostos destacados para três fornecedores diferentes, implemente uma função que calcule a base de cálculo do ISS para cada um, valide os dados de entrada e retorne os valores calculados. Em seguida, escolha o fornecedor com a menor base de cálculo do ISS.

---