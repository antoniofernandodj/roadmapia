## Regras para Apropriação de Créditos e Impacto na Escolha

Na prática da contabilidade tributária, a decisão sobre qual fornecedor contratar vai muito além da simples comparação de preços brutos. Considerar a apropriação de créditos tributários é essencial para uma avaliação econômica realista, especialmente no contexto pós-reforma tributária, que promoveu a integração e simplificação das regras para crédito em tributos como ISS, IBS e CBS. 

### Por que as regras para apropriação de créditos são decisivas?

Imagine dois fornecedores com preços diferentes para um mesmo serviço. O fornecedor A cobra R$ 100,00, mas gera direito a R$ 15,00 em créditos tributários para sua empresa. O fornecedor B cobra R$ 95,00, porém não gera créditos. Se você considerar apenas o preço bruto, o fornecedor B parecerá mais barato. Porém, ao descontar os créditos, o custo líquido com o fornecedor A será R$ 85,00, tornando-o mais vantajoso economicamente.

Essa análise exige conhecer as regras que determinam:

1. **Quando e como os créditos podem ser apropriados**, dependendo da vinculação correta dos códigos CNAE, LC116 e NBS.
2. **Limitações legais para apropriação de créditos**, que podem variar conforme o regime tributário e a natureza da atividade.
3. **Impacto da correta classificação econômica e do serviço prestado na validação do crédito tributário.**

### Processo prático para apropriação de créditos

A apropriação de créditos tributários envolve três etapas principais, baseadas na correta vinculação dos códigos:

1. **Identificação do CNAE do fornecedor**: Determina a atividade econômica principal e sua compatibilidade com a legislação tributária. A especificidade do CNAE impacta diretamente na possibilidade de crédito, pois atividades não relacionadas ou exclusas não geram créditos adequados.

2. **Vinculação do CNAE ao código de serviço LC116**: Esse código da LC116 identifica qual serviço foi prestado e qual tributo municipal (ISS) incide. A compatibilidade entre CNAE e LC116 é crucial para validar o crédito, evitando erros comuns que impedem o aproveitamento fiscal.

3. **Vinculação do LC116 ao código NBS**: A NBS detalha a classificação do serviço para fins tributários, permitindo identificar a base legal para apropriação do crédito e assegurar que o serviço está listado para crédito no ISS, IBS ou CBS.

A combinação dessas três classificações forma a base para calcular corretamente o crédito tributário, que será deduzido do custo bruto.

### Regras básicas para apropriação de créditos tributários

- **Crédito só pode ser apropriado se o serviço ou produto estiver claramente vinculado a códigos válidos e atualizados** (CNAE, LC116 e NBS). Por exemplo, um erro comum é usar CNAE ou LC116 genéricos, que não garantem a apropriação do crédito.

- **O crédito deve obedecer ao limite do tributo devido**: não pode gerar imposto negativo. Caso o crédito exceda o imposto devido, o saldo não pode ser apropriado naquele período.

- **Crédito tributário depende do regime fiscal do contribuinte**: empresas no Simples Nacional, por exemplo, têm limitações específicas para créditos de ISS e CBS.

- **Atividades mistas ou múltiplos CNAEs podem demandar segregação da receita** para apropriar créditos apenas relativos às atividades tributáveis.

- **Descontos e ajustes na base de cálculo** impactam o valor do crédito: descontos condicionais, encargos e exclusões devem ser considerados para evitar cálculo incorreto.

### Impacto na escolha do fornecedor

Ao aplicar as regras para apropriação de créditos, a comparação entre fornecedores deve levar em conta:

- **Preço bruto do serviço ou mercadoria**.
- **Valor dos créditos tributários gerados e apropriáveis**.
- **Compatibilidade das atividades econômicas e códigos vinculados** para assegurar a legitimidade do crédito.
- **Possibilidade de segregação e regime tributário da sua empresa** que permite ou limita o aproveitamento do crédito.

Um fornecedor com preço superior pode ser economicamente mais vantajoso se gerar créditos substanciais, reduzindo o custo líquido final. Por isso, sistemas fiscais precisam automatizar a validação das vinculações CNAE → LC116 → NBS e calcular o custo líquido tributário para auxiliar na decisão.

### Exemplo prático detalhado

Suponha o seguinte cenário:

| Fornecedor | Preço Bruto | CNAE        | Código LC116 | Código NBS | Crédito Tributário Apropriável |
|------------|-------------|-------------|--------------|------------|-------------------------------|
| A          | R$ 100,00   | 62.01-5/01  | 101020       | 12345      | R$ 15,00                      |
| B          | R$ 95,00    | 62.01-5/01  | 101020       | 12345      | R$ 0,00                       |

O fornecedor A, apesar de ter preço bruto maior, gera um crédito tributário de R$ 15,00 devido à sua correta classificação e atividade compatível. O custo líquido fica:

- Fornecedor A: R$ 100,00 - R$ 15,00 = R$ 85,00
- Fornecedor B: R$ 95,00 - R$ 0,00 = R$ 95,00

Logo, o fornecedor A é a opção mais vantajosa.

### Erro comum e mensagem típica de sistema

Um erro frequente é a tentativa de apropriar créditos sem a vinculação correta dos códigos, por exemplo, quando o CNAE do fornecedor não corresponde ao código LC116 usado na nota fiscal. Isso pode gerar mensagens de rejeição fiscal do tipo:

```
Rejeição: Código LC116 incompatível com CNAE do prestador – crédito não permitido.
```

Para evitar, é preciso validar as vinculações antes de registrar o crédito. Sistemas modernos devem cruzar os dados para garantir que o crédito possa ser apropriado, evitando custos inesperados.

### Código Python para cálculo simples do custo líquido tributário

```python
class Fornecedor:
    def __init__(self, nome, preco_bruto, cnae, lc116, nbs, credito):
        self.nome = nome
        self.preco_bruto = preco_bruto
        self.cnae = cnae
        self.lc116 = lc116
        self.nbs = nbs
        self.credito = credito

    def custo_liquido(self):
        custo = self.preco_bruto - self.credito
        return custo if custo >= 0 else 0  # Imposto não pode ser negativo

# Dados dos fornecedores
fornecedor_a = Fornecedor("Fornecedor A", 100.00, "62.01-5/01", "101020", "12345", 15.00)
fornecedor_b = Fornecedor("Fornecedor B", 95.00, "62.01-5/01", "101020", "12345", 0.00)

# Comparação
print(f"Custo líquido {fornecedor_a.nome}: R$ {fornecedor_a.custo_liquido():.2f}")
print(f"Custo líquido {fornecedor_b.nome}: R$ {fornecedor_b.custo_liquido():.2f}")

melhor_fornecedor = fornecedor_a if fornecedor_a.custo_liquido() < fornecedor_b.custo_liquido() else fornecedor_b
print(f"Melhor fornecedor: {melhor_fornecedor.nome}")
```

Saída:

```
Custo líquido Fornecedor A: R$ 85.00
Custo líquido Fornecedor B: R$ 95.00
Melhor fornecedor: Fornecedor A
```

### Exercício proposto

Considere dois fornecedores com os seguintes dados:

- Fornecedor X: Preço bruto R$ 120,00, CNAE compatível, crédito tributário R$ 20,00.
- Fornecedor Y: Preço bruto R$ 110,00, CNAE incompatível com código LC116, crédito tributário R$ 0,00.

Calcule o custo líquido tributário de ambos e indique qual fornecedor é economicamente mais vantajoso, justificando com base nas regras de apropriação de créditos e vinculação de códigos.

---