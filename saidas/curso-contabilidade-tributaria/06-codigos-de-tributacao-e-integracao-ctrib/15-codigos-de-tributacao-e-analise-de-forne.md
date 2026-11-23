## Códigos de Tributação e Análise de Fornecedores

Imagine que sua empresa precisa contratar um serviço de desenvolvimento de software. Você recebe propostas de dois fornecedores:

- Fornecedor A cobra R$ 100,00 pelo serviço.
- Fornecedor B cobra R$ 95,00 pelo mesmo serviço.

À primeira vista, o fornecedor B parece mais vantajoso, pois o preço é menor. Porém, ao analisar a tributação, o fornecedor A gera um crédito tributário de R$ 15,00 para sua empresa, enquanto o fornecedor B não oferece crédito algum. Portanto, o custo líquido real do fornecedor A é R$ 85,00, mais barato que o fornecedor B. Essa é a essência da análise tributária na comparação de fornecedores: considerar não apenas o preço bruto, mas o impacto dos créditos tributários gerados por cada fornecedor.

### Como os códigos tributários ajudam nessa análise

Para realizar essa comparação corretamente, é essencial usar os códigos de tributação nacionais (cTribNac) que integram informações do CNAE, do código de serviço LC116 e do código NBS. Esses códigos permitem identificar de forma precisa qual tributação incide sobre cada fornecedor, quais créditos são possíveis de apropriar e, assim, comparar custos líquidos tributários.

A sequência básica para vincular a tributação de um fornecedor é:

1. **Identificar o CNAE do fornecedor**: Classifica a atividade econômica principal da empresa.
2. **Vincular o CNAE ao código de serviço LC116 correspondente**: Determina o serviço tributado e a base legal.
3. **Associar o código LC116 ao código NBS**: Detalha o serviço para cálculo do ISS e análise de créditos.
4. **Determinar o código cTribNac correto**: Integra todos os códigos anteriores com o regime tributário para definir alíquotas e créditos aplicáveis.

### Exemplo prático de vinculação para análise de custo

Suponha que o Fornecedor A tenha:

- CNAE: 6201-5/01 (Desenvolvimento de programas de computador sob encomenda)
- Código LC116: 01.01 (Serviços de informática)
- Código NBS: 10.01.01 (Desenvolvimento de software sob encomenda)
- Regime tributário: Simples Nacional

O Fornecedor B tem os mesmos códigos, mas está no regime Lucro Real, sem aproveitamento de créditos.

Ao vincular esses códigos, o sistema identifica o código cTribNac correto para cada fornecedor, que define as alíquotas e os créditos tributários permitidos.

### Análise sem cálculos complexos: custo líquido simplificado

A ideia é que, mesmo sem cálculos complexos, o uso correto dos códigos permite saber se o fornecedor gera crédito tributário e de quanto é esse crédito, aproximando o custo líquido.

Por exemplo:

| Fornecedor | Preço Bruto | Crédito Tributário | Custo Líquido (Preço - Crédito) |
|------------|-------------|--------------------|---------------------------------|
| A          | R$ 100,00   | R$ 15,00           | R$ 85,00                        |
| B          | R$ 95,00    | R$ 0,00            | R$ 95,00                        |

Assim, o fornecedor A é mais vantajoso, apesar do preço bruto ser maior.

### Erro comum na escolha do código cTribNac

Um erro clássico ocorre quando se escolhe o código cTribNac incorreto, por exemplo, ignorando o regime tributário do fornecedor. Suponha que o sistema atribua para o Fornecedor A o código do Lucro Real, que não permite crédito de R$ 15,00. A análise indicaria erroneamente que o custo líquido é R$ 100,00, fazendo com que o fornecedor B pareça melhor, levando a uma decisão errada.

Além disso, utilizar códigos incompatíveis entre CNAE e LC116 pode gerar mensagens de erro no sistema, bloqueando a emissão fiscal ou causando inconsistências no cálculo do ISS e demais tributos.

### Como um sistema deve aplicar esses códigos para comparar fornecedores

Para garantir uma análise correta, o sistema deve:

- Validar o CNAE informado para o fornecedor.
- Verificar a compatibilidade entre o CNAE e o código LC116.
- Associar o código LC116 ao NBS correto para detalhamento do serviço.
- Considerar o regime tributário do fornecedor para escolher o código cTribNac adequado.
- Calcular o crédito tributário estimado com base no código cTribNac.
- Exibir o custo líquido para comparação entre fornecedores.
- Alertar para possíveis erros na vinculação ou códigos desatualizados.

### Exemplo de erro prático e sua correção

Suponha que o sistema receba um fornecedor com CNAE 6201-5/01 e código LC116 01.01 no regime Simples Nacional, mas atribua o código cTribNac do Lucro Real. O sistema emitirá a mensagem:

```
Erro: Código cTribNac incompatível com regime tributário informado para fornecedor CNAE 6201-5/01, LC116 01.01.
```

Para corrigir:

- Atualize a base de dados do sistema para vincular corretamente o CNAE, LC116 e regime tributário.
- Selecione o código cTribNac que corresponde ao Simples Nacional para esses códigos.
- Recalcule o crédito tributário e o custo líquido.

### Benefícios da análise tributária integrada para escolha de fornecedores

Com essa análise, a empresa:

- Evita decisões baseadas apenas no preço bruto.
- Maximiza a apropriação de créditos tributários.
- Reduz custos líquidos efetivos das compras e serviços.
- Evita riscos fiscais por erros na atribuição de códigos.
- Melhora a conformidade e transparência tributária.

### Exemplo completo em Python para comparação simplificada

```python
# Dados dos fornecedores: preço bruto, regime tributário e crédito estimado (segundo código cTribNac)
fornecedores = {
    "Fornecedor A": {"preco": 100.00, "credito": 15.00, "regime": "Simples Nacional"},
    "Fornecedor B": {"preco": 95.00, "credito": 0.00, "regime": "Lucro Real"},
}

def custo_liquido(preco, credito):
    custo = preco - credito
    return custo if custo >= 0 else 0

print("Comparação simplificada de fornecedores considerando créditos tributários:\n")
for nome, dados in fornecedores.items():
    custo = custo_liquido(dados["preco"], dados["credito"])
    print(f"{nome}: Preço bruto R$ {dados['preco']:.2f}, Crédito R$ {dados['credito']:.2f}, Custo líquido R$ {custo:.2f}")

# Saída esperada:
# Comparação simplificada de fornecedores considerando créditos tributários:
#
# Fornecedor A: Preço bruto R$ 100.00, Crédito R$ 15.00, Custo líquido R$ 85.00
# Fornecedor B: Preço bruto R$ 95.00, Crédito R$ 0.00, Custo líquido R$ 95.00
```

### Exercício prático

Um fornecedor tem CNAE 6201-5/01 e código LC116 01.01, atuando no regime Lucro Real. Você tem um orçamento de R$ 150,00 para um serviço. O crédito tributário estimado, com o código cTribNac correto, é de 10% sobre o valor da nota.

- Identifique o código cTribNac correto para esse fornecedor.
- Calcule o crédito tributário e o custo líquido para a nota de R$ 150,00.
- Compare com um fornecedor no Simples Nacional que cobra R$ 160,00 com crédito de 15%.

Explique qual fornecedor é mais vantajoso considerando o custo líquido e os riscos de erro na escolha do código cTribNac.

---